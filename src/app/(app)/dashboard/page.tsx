import { auth } from "@clerk/nextjs/server";
import { Suspense } from "react";

import { listAnalyses, type AnalysisListItem } from "@/lib/analyses/queries";

/*
  The list is scoped by the database, not by this file. Switching organization
  changes the session token, the token changes what the policy matches, and the
  same query returns the other team's rows.
*/
export default function DashboardPage() {
  return (
    <Suspense fallback={<AnalysesSkeleton />}>
      <Workspace />
    </Suspense>
  );
}

async function Workspace() {
  const [{ orgId, orgRole }, analyses] = await Promise.all([
    auth(),
    listAnalyses(),
  ]);

  return (
    <div className="flex min-h-0 flex-1 flex-col">
      <header className="flex items-baseline justify-between gap-4 border-b border-border px-3 py-2">
        <h1 className="text-[13px] font-semibold">Analyses</h1>
        <p className="font-mono text-[11px] text-muted-foreground">
          {orgId ?? "no organization"} · {orgRole ?? "—"}
        </p>
      </header>
      {analyses.length === 0 ? (
        <EmptyState />
      ) : (
        <div className="min-h-0 overflow-auto">
          <div className="grid grid-cols-[minmax(0,1fr)_5rem_minmax(0,1fr)_9rem] gap-x-4 border-b border-border px-3 py-1.5 text-[10px] uppercase tracking-wide text-muted-foreground">
            <span>Repository</span>
            <span>State</span>
            <span>Detail</span>
            <span>Created</span>
          </div>
          {analyses.map((analysis) => (
            <AnalysisRow key={analysis.id} analysis={analysis} />
          ))}
        </div>
      )}
    </div>
  );
}

function AnalysisRow({ analysis }: { analysis: AnalysisListItem }) {
  return (
    <div className="grid grid-cols-[minmax(0,1fr)_5rem_minmax(0,1fr)_9rem] items-baseline gap-x-4 border-b border-border px-3 py-2">
      <span className="flex min-w-0 items-baseline gap-2">
        <span className="truncate text-xs">{analysis.project.name}</span>
        <span className="truncate font-mono text-[11px] text-muted-foreground">
          {withoutProtocol(analysis.project.repoUrl)}
        </span>
      </span>
      <span className="font-mono text-[11px]">{analysis.status}</span>
      <span
        className="truncate font-mono text-[11px] text-muted-foreground"
        title={analysis.failureReason ?? undefined}
      >
        {analysis.failureReason ?? ""}
      </span>
      <span className="font-mono text-[11px] text-muted-foreground">
        {timestamp(analysis.createdAt)}
      </span>
    </div>
  );
}

function EmptyState() {
  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-1 px-6 text-center">
      <p className="text-xs">No analyses in this organization yet.</p>
      <p className="text-[11px] text-muted-foreground">
        An analysis belongs to the whole team, so it appears here for everyone.
      </p>
    </div>
  );
}

function AnalysesSkeleton() {
  return (
    <div className="flex min-h-0 flex-1 flex-col">
      <header className="flex items-baseline justify-between gap-4 border-b border-border px-3 py-2">
        <h1 className="text-[13px] font-semibold">Analyses</h1>
        <p className="font-mono text-[11px] text-muted-foreground">…</p>
      </header>
      <div>
        {["a", "b", "c"].map((key) => (
          <div
            key={key}
            className="grid grid-cols-[minmax(0,1fr)_5rem_minmax(0,1fr)_9rem] gap-x-4 border-b border-border px-3 py-2"
          >
            <span className="h-3 w-2/3 rounded-sm bg-surface-muted" />
            <span className="h-3 w-12 rounded-sm bg-surface-muted" />
            <span className="h-3 w-1/2 rounded-sm bg-surface-muted" />
            <span className="h-3 w-20 rounded-sm bg-surface-muted" />
          </div>
        ))}
      </div>
    </div>
  );
}

function withoutProtocol(url: string) {
  return url.replace(/^https?:\/\//, "").replace(/\/$/, "");
}

// Postgres sends ISO timestamps; a fixed-width slice keeps them monospace and
// identical on server and client rather than drifting by locale.
function timestamp(iso: string) {
  return iso.slice(0, 16).replace("T", " ");
}
