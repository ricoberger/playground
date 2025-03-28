import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

import App from "./App.jsx";
import { TraceProvider } from "./components/TraceProvider.jsx";

import "./index.css";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <TraceProvider>
      <App />
    </TraceProvider>
  </StrictMode>,
);
