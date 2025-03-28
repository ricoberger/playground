import { useState } from "react";

function Add(props) {
  const [name, setName] = useState("");

  function handleSubmit(event) {
    event.preventDefault();
    props.addTask(name);
    setName("");
  }

  function handleChange(event) {
    setName(event.target.value);
  }

  return (
    <form onSubmit={handleSubmit}>
      <div className="flex mb-4">
        <input
          type="text"
          className="w-full px-4 py-2 mr-2 rounded-lg border-gray-300 focus:outline-none focus:border-blue-500"
          id="todo-input"
          placeholder="Add new task"
          required={true}
          value={name}
          onChange={handleChange}
        />
        <button
          tzpe="submit"
          className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        >
          Add
        </button>
      </div>
    </form>
  );
}

export default Add;
