import React from "react";

interface ErrorBannerProps {
  message: string | null;
}

const ErrorBanner: React.FC<ErrorBannerProps> = ({ message }) => {
  if (!message) return null;

  return (
    <div style={{ padding: "8px 12px", backgroundColor: "#fee2e2", color: "#b91c1c", marginBottom: 16, borderRadius: 4 }}>
      {message}
    </div>
  );
};

export default ErrorBanner;
