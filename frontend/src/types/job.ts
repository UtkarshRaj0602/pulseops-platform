export interface Job {
  id: string;
  input: string;
  status: "QUEUED" | "PROCESSING" | "COMPLETED" | "FAILED";
  result: string | null;
  created_at: string;
  updated_at: string;
}