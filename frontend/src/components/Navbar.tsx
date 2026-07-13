import Link from "next/link";

export default function Navbar() {

  return (

    <nav className="bg-black text-white p-4">

      <div className="flex gap-6">

        <Link href="/">
          Home
        </Link>

        <Link href="/dashboard">
          Dashboard
        </Link>

        <Link href="/login">
          Login
        </Link>

      </div>

    </nav>

  );
}