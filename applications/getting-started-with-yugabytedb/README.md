# Getting Started with YugabyteDB

```sh
helm repo add yugabytedb https://charts.yugabyte.com
helm repo update
```

```sh
kubectl create namespace yugabytedb
```

```sh
helm upgrade --install yugabytedb yugabytedb/yugabyte --version 2.25.1 --namespace yugabytedb --wait -f values.yaml
```

```sh
# Password: ysqlpassword
kubectl exec -it -n yugabytedb yb-tserver-0 -- ysqlsh --dbname yugabyte --username ysqluser --password
```

```sql
-- Show relations
\d

-- See the state of the cluster
select * from yb_servers();

-- Create tables
create table if not exists product(
  sku varchar(128),
  description varchar(128),
  price bigint,
  primary key(sku)
);

create table if not exists customer(
  customer_id bigserial,
  email varchar(128),
  primary key(customer_id)
);

create table if not exists corder(
  order_id bigserial,
  customer_id bigint,
  sku varchar(128),
  price bigint,
  primary key(order_id)
);

-- Create products
insert into product(sku, description, price) values('SKU-1001', 'Monitor', 100);
insert into product(sku, description, price) values('SKU-1002', 'Keyboard', 30);

-- Close the database session
\q
```

```sh
kubectl apply --server-side -f deployment.yaml
```
