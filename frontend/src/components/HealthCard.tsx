interface Props {
  status: string;
  region: string;
}

export default function HealthCard({
  status,
  region
}: Props) {

  return (

    <div className="border p-5 rounded">

      <h2>
        Application Health
      </h2>

      <p>Status : {status}</p>

      <p>Region : {region}</p>

    </div>

  );
}