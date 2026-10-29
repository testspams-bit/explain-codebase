import { auth } from "@clerk/nextjs/server";
import { createClient } from "@supabase/supabase-js";

import { supabasePublishableKey, supabaseUrl } from "@/lib/env";

/*
  The token is Clerk's session token, and it travels with every request, so the
  organization claim is what a row-level policy will read. There is no Supabase
  session here on purpose: no cookie to refresh, no second thing owning the same
  middleware slot. Nothing queries anything yet.
*/
export async function createSupabaseServerClient() {
  const { getToken } = await auth();

  return createClient(supabaseUrl, supabasePublishableKey, {
    accessToken: async () => getToken(),
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });
}
