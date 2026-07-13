import HealthCard from "@/components/HealthCard";
import { getHealth } from "@/services/api";

export default async function Home() {

  const health = await getHealth();

  return (

    <div>

      <h1 className="text-3xl mb-4">
        DR Automator
      </h1>

      <HealthCard
        status={health.status}
        region={health.region}
      />

    </div>
  );
}