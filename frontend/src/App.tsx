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
    <main className="app">
      <div className="container">
        <Header />

        <JobForm onSubmit={handleSubmit} />

        <section className="jobs-card">
          <div className="jobs-header">
            <h2>Recent Jobs</h2>

            <span className="jobs-count">
              {jobs.length} jobs
            </span>
          </div>

          <JobTable jobs={jobs} />
        </section>
      </div>
    </main>
  );
}

export default App;