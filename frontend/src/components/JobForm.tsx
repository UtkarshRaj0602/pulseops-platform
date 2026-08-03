import { useState } from "react";

interface Props {
  onSubmit: (text: string) => Promise<void>;
}

export default function JobForm({ onSubmit }: Props) {

  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {

    if (!text.trim()) return;

    setLoading(true);

    try {

      await onSubmit(text);

      setText("");

    } finally {

      setLoading(false);

    }
  };

  return (
    <div className="job-form">

      <input
        type="text"
        placeholder="Enter text"
        value={text}
        onChange={(e) => setText(e.target.value)}
      />

      <button
        onClick={handleSubmit}
        disabled={loading}
      >
        {loading ? "Submitting..." : "Submit Job"}
      </button>

    </div>
  );
}