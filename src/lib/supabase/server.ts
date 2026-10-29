import { auth } from "@clerk/nextjs/server";
import { createClient } from "@supabase/supabase-js";

import { supabasePublishableKey, supabaseUrl } from "@/lib/env";
import type { Database } from "@/lib/supabase/database.types";

/*
  The token is Clerk's session token, and it travels with every request, so the
  organization claim is what a row-level policy reads. There is no Supabase
  session here on purpose: no cookie to refresh, no second thing owning the same
  middleware slot.
*/
export async function createSupabaseServerClient() {
  const { getToken } = await auth();

  return createClient<Database>(supabaseUrl, supabasePublishableKey, {
    accessToken: async () => getToken(),
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false,
    },
  });
}
