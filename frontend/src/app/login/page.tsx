export default function Login() {

  return (

    <div>

      <h1 className="text-3xl mb-5">

        Login

      </h1>

      <form className="flex flex-col gap-4">

        <input
          type="email"
          placeholder="Email"
          className="border p-2"
        />

        <input
          type="password"
          placeholder="Password"
          className="border p-2"
        />

        <button
          className="bg-black text-white p-2"
        >
          Login
        </button>

      </form>

    </div>
  );
}