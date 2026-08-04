interface Props {
  status: string;
}

export default function StatusBadge({ status }: Props) {
  return (
    <span className={`badge ${status.toLowerCase()}`}>
      {status}
    </span>
  );
}