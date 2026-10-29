/*
  Phase 2 — the workspace schema.

  organizations mirrors the identity provider's teams one-for-one by id. Every
  other table owns its rows through a foreign key to it, so deleting the row
  removes the whole tenancy. The bridge from a Clerk delete to that row is not
  part of this phase.

  Authorization lives in the policies at the bottom and nowhere else. RLS is
  enabled on every table, so a table that gains no policy returns nothing
  instead of everything.
*/

create table public.organizations (
  id text primary key,
  name text not null,
  created_at timestamptz not null default now()
);

create type public.analysis_status as enum (
  'queued',
  'parsing',
  'ready',
  'failed'
);

/*
  A project is a repository. Analyses are runs of it, so re-running is a second
  analysis rather than a second repository.
*/
create table public.projects (
  id uuid primary key default gen_random_uuid(),
  organization_id text not null
    references public.organizations (id) on delete cascade,
  name text not null,
  repo_url text not null,
  created_at timestamptz not null default now(),
  constraint projects_org_repo_key unique (organization_id, repo_url),
  -- Composite keys let children prove they belong to the same tenant.
  constraint projects_id_org_key unique (id, organization_id)
);

create table public.analyses (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  status public.analysis_status not null default 'queued',
  commit_sha text,
  failure_reason text,
  -- The coverage report belongs to the parser. Its shape is settled in phase 3,
  -- so it is stored whole rather than broken into columns guessed at here.
  coverage jsonb,
  created_at timestamptz not null default now(),
  started_at timestamptz,
  finished_at timestamptz,
  constraint analyses_id_org_key unique (id, organization_id),
  constraint analyses_project_fkey
    foreign key (project_id, organization_id)
    references public.projects (id, organization_id) on delete cascade
);

create table public.files (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  path text not null,
  folder text not null,
  lines integer not null check (lines >= 0),
  content_hash text not null,
  fan_in integer not null default 0 check (fan_in >= 0),
  fan_out integer not null default 0 check (fan_out >= 0),
  created_at timestamptz not null default now(),
  constraint files_analysis_path_key unique (analysis_id, path),
  constraint files_id_analysis_key unique (id, analysis_id),
  constraint files_analysis_fkey
    foreign key (analysis_id, organization_id)
    references public.analyses (id, organization_id) on delete cascade
);

/*
  An edge exists because the parser resolved a real import to a real file.
  Unresolved imports are coverage, never rows here.
*/
create table public.edges (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  from_file_id uuid not null,
  to_file_id uuid not null,
  kind text not null check (kind in ('import', 'reexport', 'dynamic', 'require')),
  created_at timestamptz not null default now(),
  constraint edges_analysis_fkey
    foreign key (analysis_id, organization_id)
    references public.analyses (id, organization_id) on delete cascade,
  constraint edges_from_file_fkey
    foreign key (from_file_id, analysis_id)
    references public.files (id, analysis_id) on delete cascade,
  constraint edges_to_file_fkey
    foreign key (to_file_id, analysis_id)
    references public.files (id, analysis_id) on delete cascade,
  constraint edges_unique unique (analysis_id, from_file_id, to_file_id)
);

create table public.routes (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  file_id uuid not null,
  method text not null,
  path text not null,
  created_at timestamptz not null default now(),
  constraint routes_unique unique (analysis_id, method, path),
  constraint routes_analysis_fkey
    foreign key (analysis_id, organization_id)
    references public.analyses (id, organization_id) on delete cascade,
  constraint routes_file_fkey
    foreign key (file_id, analysis_id)
    references public.files (id, analysis_id) on delete cascade
);

/*
  One role per file. source says who decided it: an adapter by convention, or
  the classifier in phase 10 for files convention could not name.
*/
create table public.file_roles (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  file_id uuid not null,
  role text not null,
  source text not null check (source in ('adapter', 'ai')),
  created_at timestamptz not null default now(),
  constraint file_roles_file_key unique (file_id),
  constraint file_roles_analysis_fkey
    foreign key (analysis_id, organization_id)
    references public.analyses (id, organization_id) on delete cascade,
  constraint file_roles_file_fkey
    foreign key (file_id, analysis_id)
    references public.files (id, analysis_id) on delete cascade
);

/*
  This table is the explanation cache. A row is keyed on the content it was
  written from, the prompt version and the exact model, so any of those changing
  asks the model again rather than serving a stale paragraph. folder_path is set
  for a folder explanation, file_id for a file one, never both.
*/
create table public.explanations (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  file_id uuid,
  folder_path text,
  content_hash text not null,
  prompt_version text not null,
  model text not null,
  body text not null,
  created_at timestamptz not null default now(),
  constraint explanations_target_key
    check ((file_id is null) <> (folder_path is null)),
  constraint explanations_cache_key unique nulls not distinct (
    analysis_id,
    file_id,
    folder_path,
    content_hash,
    prompt_version,
    model
  ),
  constraint explanations_analysis_fkey
    foreign key (analysis_id, organization_id)
    references public.analyses (id, organization_id) on delete cascade,
  constraint explanations_file_fkey
    foreign key (file_id, analysis_id)
    references public.files (id, analysis_id) on delete cascade
);

/*
  Facts read off the edge list, stored as the sentence that will be shown. A
  cycle names several files; file_id names the single-file kinds.
*/
create table public.insights (
  id uuid primary key default gen_random_uuid(),
  analysis_id uuid not null,
  organization_id text not null
    references public.organizations (id) on delete cascade,
  kind text not null
    check (kind in ('cycle', 'unimported', 'high_fan_in', 'long_file')),
  file_id uuid,
  file_ids uuid[] not null default '{}',
  sentence text not null,
  created_at timestamptz not null default now(),
  constraint insights_analysis_fkey
    foreign key (analysis_id, organization_id)
    references public.analyses (id, organization_id) on delete cascade,
  constraint insights_file_fkey
    foreign key (file_id, analysis_id)
    references public.files (id, analysis_id) on delete cascade
);

create index projects_organization_idx
  on public.projects (organization_id);
create index analyses_organization_created_idx
  on public.analyses (organization_id, created_at desc);
create index analyses_project_idx
  on public.analyses (project_id);
create index files_analysis_idx
  on public.files (analysis_id);
create index edges_from_file_idx
  on public.edges (from_file_id);
create index edges_to_file_idx
  on public.edges (to_file_id);
create index routes_file_idx
  on public.routes (file_id);
create index file_roles_analysis_idx
  on public.file_roles (analysis_id);
create index explanations_file_idx
  on public.explanations (file_id);
create index insights_analysis_idx
  on public.insights (analysis_id);

/*
  Row-level security, everywhere. The predicate is the organization claim on the
  Clerk session token; a request without one matches nothing. No table is
  readable through a check the application remembers to run.
*/
alter table public.organizations enable row level security;
alter table public.projects enable row level security;
alter table public.analyses enable row level security;
alter table public.files enable row level security;
alter table public.edges enable row level security;
alter table public.routes enable row level security;
alter table public.file_roles enable row level security;
alter table public.explanations enable row level security;
alter table public.insights enable row level security;

create policy organizations_same_organization on public.organizations
  for all
  to authenticated
  using (
    id = (select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id'))
  )
  with check (
    id = (select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id'))
  );

create policy projects_same_organization on public.projects
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy analyses_same_organization on public.analyses
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy files_same_organization on public.files
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy edges_same_organization on public.edges
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy routes_same_organization on public.routes
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy file_roles_same_organization on public.file_roles
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy explanations_same_organization on public.explanations
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

create policy insights_same_organization on public.insights
  for all
  to authenticated
  using (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = (
      select coalesce(auth.jwt() ->> 'org_id', auth.jwt() -> 'o' ->> 'id')
    )
  );

/*
  Privileges follow the policies. An unauthenticated request has no table grant,
  so it fails before a policy is even consulted.
*/
revoke all on table
  public.organizations,
  public.projects,
  public.analyses,
  public.files,
  public.edges,
  public.routes,
  public.file_roles,
  public.explanations,
  public.insights
from anon;

grant select, insert, update, delete on table
  public.organizations,
  public.projects,
  public.analyses,
  public.files,
  public.edges,
  public.routes,
  public.file_roles,
  public.explanations,
  public.insights
to authenticated;
