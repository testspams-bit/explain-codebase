/*
  Phase 2, follow-up.

  Two things the advisors caught after the first migration:

  1. A policy predicate wrapped in one subquery still contained both auth.jwt()
     calls inside it, so the planner had no InitPlan to hoist. Two subqueries,
     one per claim, evaluates the token once per statement rather than per row.

  2. The composite foreign keys that keep a row in its tenant had no covering
     index, and neither did organization_id on the tables the policy filters by
     it. Both are on cascade and read paths.
*/

drop policy organizations_same_organization on public.organizations;
create policy organizations_same_organization on public.organizations
  for all
  to authenticated
  using (
    id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy projects_same_organization on public.projects;
create policy projects_same_organization on public.projects
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy analyses_same_organization on public.analyses;
create policy analyses_same_organization on public.analyses
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy files_same_organization on public.files;
create policy files_same_organization on public.files
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy edges_same_organization on public.edges;
create policy edges_same_organization on public.edges
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy routes_same_organization on public.routes;
create policy routes_same_organization on public.routes
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy file_roles_same_organization on public.file_roles;
create policy file_roles_same_organization on public.file_roles
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy explanations_same_organization on public.explanations;
create policy explanations_same_organization on public.explanations
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop policy insights_same_organization on public.insights;
create policy insights_same_organization on public.insights
  for all
  to authenticated
  using (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  )
  with check (
    organization_id = coalesce(
      (select auth.jwt() ->> 'org_id'),
      (select auth.jwt() -> 'o' ->> 'id')
    )
  );

drop index public.analyses_project_idx;
create index analyses_project_idx
  on public.analyses (project_id, organization_id);

drop index public.files_analysis_idx;
create index files_analysis_idx
  on public.files (analysis_id, organization_id);
create index files_organization_idx
  on public.files (organization_id);

drop index public.edges_from_file_idx;
create index edges_from_file_idx
  on public.edges (from_file_id, analysis_id);
drop index public.edges_to_file_idx;
create index edges_to_file_idx
  on public.edges (to_file_id, analysis_id);
create index edges_analysis_idx
  on public.edges (analysis_id, organization_id);
create index edges_organization_idx
  on public.edges (organization_id);

drop index public.routes_file_idx;
create index routes_file_idx
  on public.routes (file_id, analysis_id);
create index routes_analysis_idx
  on public.routes (analysis_id, organization_id);
create index routes_organization_idx
  on public.routes (organization_id);

drop index public.file_roles_analysis_idx;
create index file_roles_analysis_idx
  on public.file_roles (analysis_id, organization_id);
create index file_roles_file_idx
  on public.file_roles (file_id, analysis_id);
create index file_roles_organization_idx
  on public.file_roles (organization_id);

create index explanations_analysis_idx
  on public.explanations (analysis_id, organization_id);
drop index public.explanations_file_idx;
create index explanations_file_idx
  on public.explanations (file_id, analysis_id);
create index explanations_organization_idx
  on public.explanations (organization_id);

drop index public.insights_analysis_idx;
create index insights_analysis_idx
  on public.insights (analysis_id, organization_id);
create index insights_file_idx
  on public.insights (file_id, analysis_id);
create index insights_organization_idx
  on public.insights (organization_id);
