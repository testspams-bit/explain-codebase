import { clerkMiddleware } from "@clerk/nextjs/server";

// Imported for its side effect: env validation runs on the first request rather
// than three screens into a blank value.
import "@/lib/env";

function isAuthScreen(pathname: string) {
  return (
    pathname === "/sign-in" ||
    pathname.startsWith("/sign-in/") ||
    pathname === "/sign-up" ||
    pathname.startsWith("/sign-up/")
  );
}

/*
  Deny by default. Only the auth screens pass through, so a route added later is
  protected without anyone remembering to come back here. The redirect happens
  in the middleware, which is why a protected page's HTML is never sent to a
  signed-out visitor.
*/
export default clerkMiddleware(async (auth, request) => {
  if (isAuthScreen(request.nextUrl.pathname)) {
    return;
  }

  await auth.protect();
});

export const config = {
  matcher: [
    "/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)",
    "/(api|trpc)(.*)",
  ],
};
