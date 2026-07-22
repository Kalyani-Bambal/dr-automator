import UserTable from "@/components/UserTable";
import { getUsers } from "@/services/api";

export default async function Dashboard() {
  try {
    const users = await getUsers();

    return (
      <div>
        <h1 className="text-3xl mb-4">Dashboard</h1>
        <UserTable users={users} />
      </div>
    );
  } catch (error) {
    return (
      <div>
        <h1 className="text-3xl mb-4">Dashboard</h1>
        <p className="text-red-600">Unable to load users right now.</p>
      </div>
    );
  }
}