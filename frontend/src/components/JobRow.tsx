import type { Job } from "../types/job";
import StatusBadge from "./StatusBadge";

interface Props {
  job: Job;
}

export default function JobRow({ job }: Props) {
  return (
    <tr>
      <td>{job.id}</td>
      <td>
        <StatusBadge status={job.status} />
      </td>
      <td>{job.result || "-"}</td>
    </tr>
  );
}