const API_URL =
process.env.NEXT_PUBLIC_API_URL;

export async function getHealth() {

  const response = await fetch(
    `${API_URL}/health`,
    {
      cache: "no-store"
    }
  );

  return response.json();
}

export async function getUsers() {

  const response = await fetch(
    `${API_URL}/users`,
    {
      cache: "no-store"
    }
  );

  return response.json();
}