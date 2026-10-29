/*
  Read once, at module load, so a blank value stops the app on the request that
  needs it instead of turning into a confusing failure later. Imported by the
  middleware, which is the first server code to run on every request.
*/
function read(name: string): string {
  const value = process.env[name];

  if (!value || value.trim() === "") {
    throw new Error(
      `Missing ${name}. Add it to .env.local; the app refuses to start with it blank.`,
    );
  }

  return value;
}

export const supabaseUrl = read("NEXT_PUBLIC_SUPABASE_URL");
export const supabasePublishableKey = read(
  "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY",
);
