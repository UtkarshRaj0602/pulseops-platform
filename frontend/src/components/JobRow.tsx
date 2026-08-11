import type { Job } from "../types/job";
import StatusBadge from "./StatusBadge";

interface Props {
  job: Job;
}

export default function JobRow({ job }: Props) {
  return (
    <tr>
      <td>
        <div className="job-id">
          {job.id}
        </div>
      </td>

      <td>
        <StatusBadge status={job.status} />
      </td>

      <td>
        <div className="job-result">
          {job.result || "-"}
        </div>
      </td>
    </tr>
  );
}