import JobRow from "./JobRow";
import type { Job } from "../types/job";

interface Props {
  jobs: Job[];
}

export default function JobTable({ jobs }: Props) {

  if (jobs.length === 0) {

    return (
      <p style={{ textAlign: "center" }}>
        No jobs submitted yet.
      </p>
    );

  }

  return (

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
          <JobRow key={job.id} job={job} />
        ))}

      </tbody>

    </table>

  );
}