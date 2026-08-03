import { useState } from "react";
import Header from "./components/Header";
import JobForm from "./components/JobForm";
import JobTable from "./components/JobTable";
import type { Job } from "./types/job";
import "./App.css";

function App() {
  const [jobs] = useState<Job[]>([]);

  const handleSubmit = async (text: string) => {
    console.log("Submitted:", text);
    alert(`Job submitted: ${text}`);
  };

  return (
    <div className="container">
      <Header />
      <JobForm onSubmit={handleSubmit} />
      <JobTable jobs={jobs} />
    </div>
  );
}

export default App;