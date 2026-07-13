import UserTable from "@/components/UserTable";
import { getUsers } from "@/services/api";

export default async function Dashboard() {

  const users = await getUsers();

  return (

    <div>

      <h1 className="text-3xl mb-4">

        Dashboard

      </h1>

      <UserTable users={users} />

    </div>
  );
}