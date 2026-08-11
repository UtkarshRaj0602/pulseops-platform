import { useEffect, useState } from "react";

import Header from "./components/Header";
import JobForm from "./components/JobForm";
import JobTable from "./components/JobTable";

import type { Job } from "./types/job";

import {
  submitJob,
  getJobs,
  getJob,
} from "./services/api";

import "./App.css";

function App() {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);

  const loadJobs = async () => {
    try {
      const data = await getJobs();
      setJobs(data);
    } catch (error) {
      console.error("Failed to load jobs:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (text: string) => {
    try {
      const response = await submitJob(text);

      const jobId = response.job_id;

      console.log("Job submitted:", jobId);

      // Immediately show the newly created job.
      await loadJobs();

      // Poll until the worker completes the job.
      for (let attempt = 0; attempt < 30; attempt++) {
        await new Promise((resolve) =>
          setTimeout(resolve, 1000)
        );

        try {
          const job = await getJob(jobId);

          setJobs((currentJobs) => {
            const exists = currentJobs.some(
              (item) => item.id === job.id
            );

            if (exists) {
              return currentJobs.map((item) =>
                item.id === job.id ? job : item
              );
            }

            return [job, ...currentJobs];
          });

          if (
            job.status === "COMPLETED" ||
            job.status === "FAILED"
          ) {
            break;
          }
        } catch (error) {
          console.error("Failed to poll job:", error);
          break;
        }
      }
    } catch (error) {
      console.error("Failed to submit job:", error);
      alert("Failed to submit job.");
    }
  };

  useEffect(() => {
    loadJobs();
  }, []);

  return (
    <main className="app">
      <div className="container">
        <Header />

        <JobForm onSubmit={handleSubmit} />

        <section className="jobs-card">
          <div className="jobs-header">
            <h2>Recent Jobs</h2>

            <span className="jobs-count">
              {loading ? "Loading..." : `${jobs.length} jobs`}
            </span>
          </div>

          <JobTable jobs={jobs} />
        </section>
      </div>
    </main>
  );
}

export default App;