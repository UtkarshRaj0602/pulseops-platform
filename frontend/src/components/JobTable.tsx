import JobRow from "./JobRow";
import type { Job } from "../types/job";

interface Props {
  jobs: Job[];
}

export default function JobTable({ jobs }: Props) {
  if (jobs.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-state-icon">
          ◌
        </div>

        <h3>No jobs yet</h3>

        <p>
          Submit your first job to see it appear here.
        </p>
      </div>
    );
  }

  return (
    <div className="table-wrapper">
      <table>
        <thead>
          <tr>
            <th>Job ID</th>
            <th>Status</th>
            <th>Result</th>
          </tr>
        </thead>

        <tbody>
          {jobs.map((job) => (
            <JobRow
              key={job.id}
              job={job}
            />
          ))}
        </tbody>
      </table>
    </div>
  );
}