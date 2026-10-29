import { redirect } from "next/navigation";

/*
  Phase 13 turns this into the landing page. Until then the root is not a
  destination, and the middleware decides whether /dashboard is reachable.
*/
export default function Home() {
  redirect("/dashboard");
}
