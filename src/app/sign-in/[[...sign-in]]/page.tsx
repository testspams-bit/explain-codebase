import { SignIn } from "@clerk/nextjs";
import { Suspense } from "react";

// Every enabled method ends here and leaves for the same place.
export default function SignInPage() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <Suspense>
        <SignIn fallbackRedirectUrl="/dashboard" />
      </Suspense>
    </div>
  );
}
