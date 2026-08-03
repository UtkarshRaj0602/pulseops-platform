export interface Job {
  id: string;
  input: string;
  status: "QUEUED" | "PROCESSING" | "COMPLETED" | "FAILED";
  result: string;
  created_at: string;
}