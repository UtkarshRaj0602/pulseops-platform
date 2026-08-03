import axios from "axios";

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
  },
});

export default api;

/*
|--------------------------------------------------------------------------
| API Functions
|--------------------------------------------------------------------------
*/

export const submitJob = async (text: string) => {
  const response = await api.post("/jobs", {
    text,
  });

  return response.data;
};

export const getJobs = async () => {
  const response = await api.get("/jobs");

  return response.data;
};

export const getJob = async (jobId: string) => {
  const response = await api.get(`/jobs/${jobId}`);

  return response.data;
};