import { useState, useEffect } from "react";
import { context, trace } from "@opentelemetry/api";

import Task from "./components/Task.jsx";
import Add from "./components/Add.jsx";
import { webTracer } from "./components/TraceProvider.jsx";

function createId(length) {
  const chars =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

function App() {
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const span = webTracer.startSpan("getTasks");
    context.with(trace.setSpan(context.active(), span), () => {
      fetch("/api/tasks")
        .then((res) => {
          trace.getSpan(context.active()).addEvent("parseJson");
          return res.json();
        })
        .then((data) => {
          trace.getSpan(context.active()).addEvent("setTasks");
          span.end();
          setTasks(data);
        });
    });
  }, []);

  function addTask(name) {
    const span = webTracer.startSpan("addTask");
    context.with(trace.setSpan(context.active(), span), () => {
      trace.getSpan(context.active()).addEvent("create-id");
      const newTask = { id: createId(6), name: name, completed: false };

      fetch("/api/tasks", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: JSON.stringify(newTask),
      })
        .then((res) => {
          trace.getSpan(context.active()).addEvent("parseJson");
          return res.json();
        })
        .then((data) => {
          trace.getSpan(context.active()).addEvent("setTasks");
          span.end();
          setTasks([...tasks, data]);
        });
    });
  }

  function toggleTaskCompleted(id) {
    const span = webTracer.startSpan("toggleTaskCompleted");
    context.with(trace.setSpan(context.active(), span), () => {
      fetch("/api/tasks/" + id, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      })
        .then((res) => {
          trace.getSpan(context.active()).addEvent("parseJson");
          return res.json();
        })
        .then((data) => {
          trace.getSpan(context.active()).addEvent("updateTask");
          const updatedTasks = tasks.map((task) => {
            if (id === task.id) {
              return data;
            }
            return task;
          });

          trace.getSpan(context.active()).addEvent("setTasks");
          span.end();
          setTasks(updatedTasks);
        });
    });
  }

  function deleteTask(id) {
    const span = webTracer.startSpan("deleteTask");
    context.with(trace.setSpan(context.active(), span), () => {
      fetch("/api/tasks/" + id, {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      }).then(() => {
        trace.getSpan(context.active()).addEvent("filterTasks");
        const remainingTasks = tasks.filter((task) => id !== task.id);

        trace.getSpan(context.active()).addEvent("setTasks");
        span.end();
        setTasks(remainingTasks);
      });
    });
  }

  return (
    <div className="container mx-auto my-10">
      <h1 className="text-center text-3xl font-semibold mb-4">Tasks</h1>
      <div className="md:w-1/2 mx-auto">
        <div className="bg-white shadow-md rounded-lg p-6">
          <Add addTask={addTask} />
          <ul id="todo-list">
            {tasks.map((task) => (
              <Task
                key={task.id}
                id={task.id}
                name={task.name}
                completed={task.completed}
                toggleTaskCompleted={toggleTaskCompleted}
                deleteTask={deleteTask}
              />
            ))}
          </ul>
        </div>
      </div>
    </div>
  );
}

export default App;
