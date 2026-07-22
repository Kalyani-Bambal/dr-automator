const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://backend-service:5000";

export async function getHealth() {
  const response = await fetch(`${API_URL}/health`, {
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error(`Health check failed with status ${response.status}`);
  }

  return response.json();
}

export async function getUsers() {
  const response = await fetch(`${API_URL}/users`, {
    cache: "no-store",
  });

  if (!response.ok) {
    throw new Error(`Users fetch failed with status ${response.status}`);
  }

  return response.json();
}