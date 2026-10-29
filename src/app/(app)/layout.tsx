import { OrganizationSwitcher, UserButton } from "@clerk/nextjs";
import Link from "next/link";

import { ThemeToggle } from "@/components/theme-toggle";

/*
  The shell: header now, and the three columns of phase 4 render inside main.
  Nothing here rearranges later, and nothing moves without a click.
*/
export default function WorkspaceLayout({ children }: LayoutProps<"/">) {
  return (
    <div className="flex min-h-full flex-1 flex-col">
      <header className="flex h-11 shrink-0 items-center justify-between gap-4 border-b border-border px-3">
        <Link
          href="/dashboard"
          className="font-mono text-[13px] font-semibold tracking-tight"
        >
          explain-codebase
        </Link>
        <div className="flex items-center gap-2">
          <OrganizationSwitcher
            // organizationProfileUrl="/organization-profile"
            organizationProfileMode="modal"
            afterSelectOrganizationUrl="/dashboard"
            afterSelectPersonalUrl="/dashboard"
          />
          <ThemeToggle />
          <UserButton />
        </div>
      </header>
      <main className="flex min-h-0 flex-1 flex-col">{children}</main>
    </div>
  );
}
