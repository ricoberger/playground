package main

import (
	"context"
	"flag"
	"fmt"
	"log/slog"
	"math/rand"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/yugabyte/pgx/v5/pgxpool"
)

var (
	letters          = []rune("abcdefghijklmnopqrstuvwxyz")
	driver           string
	connectionString string
	goroutines       int
	createCustomers  bool
	createOrders     bool
)

func randSeq(n int) string {
	b := make([]rune, n)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func init() {
	flag.StringVar(&connectionString, "connection-string", "postgres://commerceuser:commercepassword@localhost:5433/commerce", "Connection string of the database instance")
	flag.IntVar(&goroutines, "goroutines", 5, "Number of Go routines")
	flag.BoolVar(&createCustomers, "create-customers", false, "Create customers")
	flag.BoolVar(&createOrders, "create-orders", false, "Create orders")
}

func main() {
	flag.Parse()

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))
	slog.SetDefault(logger)
	slog.Info("Start load generator")

	db, err := pgxpool.New(context.Background(), connectionString)
	if err != nil {
		slog.Error("Failed to connect to database", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()

	var wg sync.WaitGroup
	quit := make(chan struct{})

	for i := 0; i < goroutines; i++ {
		slog.Info("Start Go routine", slog.Int("num", i))
		wg.Add(1)

		if createCustomers {
			go createCustomer(&wg, quit, db, i)
		}

		if createOrders {
			go createOrder(&wg, quit, db, i)
		}
	}

	done := make(chan os.Signal, 1)
	signal.Notify(done, syscall.SIGINT, syscall.SIGTERM)
	slog.Info("Press Ctrl+C to stop")
	<-done

	close(quit)
	wg.Wait()
}

func createCustomer(wg *sync.WaitGroup, quit chan struct{}, db *pgxpool.Pool, i int) {
	defer wg.Done()

	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-quit:
			slog.Info("Stop Go routine")
			return
		case <-ticker.C:
			email := fmt.Sprintf("%s@domain.com", randSeq(10))
			_, err := db.Exec(context.Background(), "insert into customer(email) values($1)", email)
			if err != nil {
				slog.Error("Failed to create customer", slog.Int("goroutine", i), slog.String("email", email), slog.Any("error", err))
			} else {
				slog.Info("Customer was created", slog.Int("goroutine", i), slog.String("email", email))
			}
		}
	}
}

type Product struct {
	SKU         string
	Description string
	Price       int
}

func createOrder(wg *sync.WaitGroup, quit chan struct{}, db *pgxpool.Pool, i int) {
	defer wg.Done()

	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-quit:
			slog.Info("Stop Go routine")
			return
		case <-ticker.C:
			ctx := context.Background()

			var customerID int
			err := db.QueryRow(ctx, "select customer_id from customer order by random() limit 1").Scan(&customerID)
			if err != nil {
				slog.Error("Failed to get customer", slog.Int("goroutine", i), slog.Any("error", err))
				continue
			}

			results, err := db.Query(ctx, "SELECT sku, description, price FROM product")
			if err != nil {
				slog.Error("Failed to get products", slog.Int("goroutine", i), slog.Any("error", err))
				continue
			}

			var products []Product

			for results.Next() {
				var product Product
				err = results.Scan(&product.SKU, &product.Description, &product.Price)
				if err != nil {
					slog.Error("Failed to scan product", slog.Int("goroutine", i), slog.Any("error", err))
					continue
				}
				products = append(products, product)
			}

			product := products[rand.Intn(len(products))]

			_, err = db.Exec(ctx, "insert into corder(customer_id, sku, price) values($1, $2, $3);", customerID, product.SKU, product.Price)
			if err != nil {
				slog.Error("Failed to create order", slog.Int("goroutine", i), slog.Int("customer", customerID), slog.String("product", product.SKU), slog.Any("error", err))
			} else {
				slog.Info("Order was created", slog.Int("goroutine", i), slog.Int("customer", customerID), slog.String("product", product.SKU))
			}
		}
	}
}
