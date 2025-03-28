function Task(props) {
  return (
    <li className="border-b border-gray-200 flex items-center justify-between py-4">
      <label class="flex items-center">
        <input
          id={props.id}
          type="checkbox"
          defaultChecked={props.completed}
          onChange={() => props.toggleTaskCompleted(props.id)}
          class="mr-2"
        />
        <span className={props.completed && "line-through"}>{props.name}</span>
      </label>
      <div>
        <button
          type="button"
          class="text-red-500 hover:text-red-700 mr-2 delete-btn"
          onClick={() => props.deleteTask(props.id)}
        >
          Delete
        </button>
      </div>
    </li>
  );
}

export default Task;
