import { useState } from "react";

interface Props {
  onSubmit: (text: string) => Promise<void>;
}

export default function JobForm({ onSubmit }: Props) {
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    const value = text.trim();

    if (!value) {
      return;
    }

    setLoading(true);

    try {
      await onSubmit(value);
      setText("");
    } finally {
      setLoading(false);
    }
  };

  return (
    <section className="job-form-card">
      <h2 className="job-form-title">
        Submit a Job
      </h2>

      <p className="job-form-description">
        Enter any text and PulseOps will process it
        asynchronously and return the result in
        uppercase.
      </p>

      <div className="job-form">
        <input
          type="text"
          placeholder="e.g. hello pulseops"
          value={text}
          maxLength={5000}
          onChange={(e) => setText(e.target.value)}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              handleSubmit();
            }
          }}
        />

        <button
          onClick={handleSubmit}
          disabled={loading || !text.trim()}
        >
          {loading ? "Submitting..." : "Submit Job"}
        </button>
      </div>
    </section>
  );
}