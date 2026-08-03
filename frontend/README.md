# PulseOps Platform - Frontend

## Overview

The frontend is a lightweight React + TypeScript application that provides a simple interface for submitting processing jobs and viewing their execution status.

The application has been intentionally kept minimal, as the primary focus of this assessment is Infrastructure as Code, CI/CD, Kubernetes, containerization, deployment reliability, observability, and platform engineering.

---

## Tech Stack

- React
- TypeScript
- Vite
- Axios
- React Hot Toast
- React Icons

---

## Features

- Submit processing jobs
- Simple and responsive UI
- Job status table
- Empty state when no jobs are available
- API abstraction using Axios
- Environment variable support
- Ready for backend integration

---

## Project Structure

```
frontend/
│
├── src/
│   ├── components/
│   │   ├── Header.tsx
│   │   ├── JobForm.tsx
│   │   ├── JobRow.tsx
│   │   ├── JobTable.tsx
│   │   └── StatusBadge.tsx
│   │
│   ├── services/
│   │   └── api.ts
│   │
│   ├── types/
│   │   └── job.ts
│   │
│   ├── App.tsx
│   ├── App.css
│   ├── main.tsx
│   └── index.css
│
├── Dockerfile
├── nginx.conf
├── .env.example
└── README.md
```

---

## Environment Variables

Create a `.env` file from `.env.example`.

```env
VITE_API_BASE_URL=http://localhost:8000
```

---

## Install Dependencies

```bash
npm install
```

---

## Start Development Server

```bash
npm run dev
```

Frontend will be available at

```
http://localhost:5173
```

---

## Production Build

Generate an optimized production build.

```bash
npm run build
```

Preview the production build locally.

```bash
npm run preview
```

---

## Lint

```bash
npm run lint
```

---

## Application Workflow

```
User

↓

Enter Text

↓

Submit Job

↓

POST /jobs

↓

Receive Job ID

↓

Display Job Status

↓

Poll Backend

↓

Status Updated

↓

Result Displayed
```

---

## API Endpoints

The frontend expects the backend to expose the following APIs.

| Method | Endpoint      | Description               |
| ------ | ------------- | ------------------------- |
| GET    | /health/live  | Liveness probe            |
| GET    | /health/ready | Readiness probe           |
| POST   | /jobs         | Submit new processing job |
| GET    | /jobs         | List all jobs             |
| GET    | /jobs/{id}    | Get job details           |

---

## Current Status

✔ Frontend UI completed

✔ Component structure completed

✔ API layer created

✔ Ready for backend integration

✔ Docker-ready

---

## Future Improvements

- Real backend integration
- Automatic polling for job updates
- Loading indicators
- Error handling
- Authentication (optional)
- Pagination for job history
