import "../styles/globals.css";
import Link from "next/link";

function MyApp({ Component, pageProps }) {
  return (
    <div>
      <nav className=" border-b p-6">
        <p className="text-4xl font-bold">NextGen MarketPlace</p>
        <div className="flex pt-4">
          <Link href="/">
            <p className="mr-4 text-pink-500">Home</p>
          </Link>
          <Link href="/create-item">
            <p className="mr-4 text-pink-500">Sell Digital Asset</p>
          </Link>
          <Link href="/my-assets">
            <p className="mr-4 text-pink-500">My Digital Assets</p>
          </Link>
          <Link href="/creator-dashboard">
            <p className="mr-4 text-pink-500">Creator Dashboard</p>
          </Link>
        </div>
      </nav>
      <Component {...pageProps} />
    </div>
  );
}

export default MyApp;
