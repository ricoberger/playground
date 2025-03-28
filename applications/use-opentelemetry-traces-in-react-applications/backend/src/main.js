const { setupTracing } = require("./tracing");
setupTracing("express-app");

const express = require("express");

const app = express();
app.use(express.json());

let tasks = [];

app.get("/api/tasks", (req, res) => {
  res.json(tasks);
});

app.post("/api/tasks", (req, res) => {
  const task = {
    id: req.body.id,
    name: req.body.name,
    completed: req.body.completed || false,
  };
  tasks.push(task);
  res.status(201).json(task);
});

app.put("/api/tasks/:id", (req, res) => {
  const id = req.params.id;
  const task = tasks.find((t) => t.id === id);
  if (!task) {
    return res.status(404).json({ error: "Task not found" });
  }
  task.completed = !task.completed;
  res.json(task);
});

app.delete("/api/tasks/:id", (req, res) => {
  const id = req.params.id;
  const index = tasks.findIndex((t) => t.id === id);
  if (index === -1) {
    return res.status(404).json({ error: "Task not found" });
  }
  tasks.splice(index, 1);
  res.status(204).send();
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
