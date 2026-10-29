import type { Database } from "@/lib/supabase/database.types";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type AnalysisStatus = Database["public"]["Enums"]["analysis_status"];

export type AnalysisListItem = {
  id: string;
  status: AnalysisStatus;
  failureReason: string | null;
  commitSha: string | null;
  createdAt: string;
  project: {
    name: string;
    repoUrl: string;
  };
};

/*
  The query carries no organization predicate, deliberately. The row policy
  already limits it to the organization on the request's token, so the same
  statement returns a different list after switching teams. A where clause here
  would hide a broken policy rather than expose it.
*/
export async function listAnalyses(): Promise<AnalysisListItem[]> {
  const supabase = await createSupabaseServerClient();

  const { data, error } = await supabase
    .from("analyses")
    .select(
      "id, status, failure_reason, commit_sha, created_at, projects ( name, repo_url )",
    )
    .order("created_at", { ascending: false })
    .limit(50);

  if (error) {
    throw new Error(`Could not read analyses: ${error.message}`);
  }

  return data.map((row) => ({
    id: row.id,
    status: row.status,
    failureReason: row.failure_reason,
    commitSha: row.commit_sha,
    createdAt: row.created_at,
    project: {
      name: row.projects.name,
      repoUrl: row.projects.repo_url,
    },
  }));
}
