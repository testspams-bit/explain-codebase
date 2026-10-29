import { auth } from "@clerk/nextjs/server";
import { Suspense } from "react";

export default function DashboardPage() {
  return (
    <div className="flex flex-col gap-4 p-4">
      <h1 className="text-[13px] font-semibold">Workspace</h1>
      {/* Reading the token is request data, so it streams inside a boundary. */}
      <Suspense fallback={<OrganizationFields organization="…" role="…" />}>
        <CurrentOrganization />
      </Suspense>
    </div>
  );
}

async function CurrentOrganization() {
  const { orgId, orgRole } = await auth();

  return (
    <OrganizationFields
      organization={orgId ?? "No organization on this session"}
      role={orgRole ?? "—"}
    />
  );
}

function OrganizationFields({
  organization,
  role,
}: {
  organization: string;
  role: string;
}) {
  return (
    <dl className="grid w-fit grid-cols-[7rem_1fr] gap-x-3 gap-y-1 text-xs">
      <dt className="text-muted-foreground">Organization</dt>
      <dd className="font-mono">{organization}</dd>
      <dt className="text-muted-foreground">Role</dt>
      <dd className="font-mono">{role}</dd>
    </dl>
  );
}
