import "./globals.css";
import Navbar from "@/components/Navbar";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {

  return (
    <html>

      <body>

        <Navbar />

        <main className="p-8">
          {children}
        </main>

      </body>

    </html>
  );
}