/*
  Phase 2 seed.

  There is nothing yet that creates a real analysis, and the acceptance check
  needs two organizations with rows in every table. Fixed ids and
  "on conflict do nothing" make this safe to run once.

  It is scaffolding. Phase 7 creates analyses from real parsing and this file
  stops being applied.
*/

insert into public.organizations (id, name)
values
  ('org_3LJO3Z5ul6yEpyewctTasDPyHqW', 'E-Corp'),
  ('org_3LMjDx4q5egO9IzSFiu8AiyYKp0', 'Initech')
on conflict do nothing;

insert into public.projects (id, organization_id, name, repo_url)
values
  (
    '11111111-1111-4111-8111-111111111111',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'checkout-web',
    'https://github.com/acme/checkout-web'
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'pointy-api',
    'https://github.com/initech/pointy-api'
  )
on conflict do nothing;

insert into public.analyses (
  id,
  project_id,
  organization_id,
  status,
  commit_sha,
  failure_reason,
  created_at,
  started_at,
  finished_at
)
values
  (
    'aaaaaaaa-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'ready',
    '4f1c9a2',
    null,
    now() - interval '2 days',
    now() - interval '2 days',
    now() - interval '2 days' + interval '43 seconds'
  ),
  (
    'aaaaaaaa-0000-4000-8000-000000000002',
    '11111111-1111-4111-8111-111111111111',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'parsing',
    null,
    null,
    now() - interval '14 minutes',
    now() - interval '13 minutes',
    null
  ),
  (
    'aaaaaaaa-0000-4000-8000-000000000003',
    '11111111-1111-4111-8111-111111111111',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'failed',
    null,
    'Clone timed out after 60s.',
    now() - interval '3 days',
    now() - interval '3 days',
    now() - interval '3 days' + interval '61 seconds'
  ),
  (
    'bbbbbbbb-0000-4000-8000-000000000001',
    '22222222-2222-4222-8222-222222222222',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'ready',
    '0b7de11',
    null,
    now() - interval '5 days',
    now() - interval '5 days',
    now() - interval '5 days' + interval '22 seconds'
  ),
  (
    'bbbbbbbb-0000-4000-8000-000000000002',
    '22222222-2222-4222-8222-222222222222',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'queued',
    null,
    null,
    now() - interval '3 hours',
    null,
    null
  ),
  (
    'bbbbbbbb-0000-4000-8000-000000000003',
    '22222222-2222-4222-8222-222222222222',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'ready',
    '9ac2038',
    null,
    now() - interval '9 days',
    now() - interval '9 days',
    now() - interval '9 days' + interval '31 seconds'
  )
on conflict do nothing;

insert into public.files (
  id,
  analysis_id,
  organization_id,
  path,
  folder,
  lines,
  content_hash,
  fan_in,
  fan_out
)
values
  (
    'cccccccc-0000-4000-8000-000000000001',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'src/checkout/cart.ts',
    'src/checkout',
    214,
    '9c1f4b1d6a2e8f0b3c5d7e9a1b2c4d6e8f0a1b3c5d7e9f0a1b2c4d6e8f0a1b3c',
    2,
    1
  ),
  (
    'cccccccc-0000-4000-8000-000000000002',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'src/checkout/totals.ts',
    'src/checkout',
    88,
    '1a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f809',
    1,
    0
  ),
  (
    'cccccccc-0000-4000-8000-000000000003',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'src/app/page.tsx',
    'src/app',
    32,
    '2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a',
    0,
    1
  ),
  (
    'cccccccc-0000-4000-8000-000000000004',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'src/checkout/legacy-discounts.ts',
    'src/checkout',
    167,
    '3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b',
    0,
    0
  ),
  (
    'dddddddd-0000-4000-8000-000000000001',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'src/orders/orders.service.ts',
    'src/orders',
    143,
    '4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c',
    2,
    1
  ),
  (
    'dddddddd-0000-4000-8000-000000000002',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'src/orders/orders.controller.ts',
    'src/orders',
    76,
    '5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d',
    0,
    1
  ),
  (
    'dddddddd-0000-4000-8000-000000000003',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'src/orders/legacy-export.ts',
    'src/orders',
    52,
    '6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d5e',
    1,
    1
  )
on conflict do nothing;

insert into public.edges (
  id,
  analysis_id,
  organization_id,
  from_file_id,
  to_file_id,
  kind
)
values
  (
    'eeeeeeee-0000-4000-8000-000000000001',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'cccccccc-0000-4000-8000-000000000001',
    'cccccccc-0000-4000-8000-000000000002',
    'import'
  ),
  (
    'eeeeeeee-0000-4000-8000-000000000002',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'cccccccc-0000-4000-8000-000000000003',
    'cccccccc-0000-4000-8000-000000000001',
    'import'
  ),
  (
    'eeeeeeee-0000-4000-8000-000000000003',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000002',
    'dddddddd-0000-4000-8000-000000000001',
    'import'
  ),
  (
    'eeeeeeee-0000-4000-8000-000000000004',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000003',
    'dddddddd-0000-4000-8000-000000000001',
    'import'
  ),
  (
    'eeeeeeee-0000-4000-8000-000000000005',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000001',
    'dddddddd-0000-4000-8000-000000000003',
    'import'
  )
on conflict do nothing;

insert into public.routes (id, analysis_id, organization_id, file_id, method, path)
values
  (
    'f0f0f0f0-0000-4000-8000-000000000001',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'cccccccc-0000-4000-8000-000000000003',
    'GET',
    '/'
  ),
  (
    'f0f0f0f0-0000-4000-8000-000000000002',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000002',
    'GET',
    '/orders'
  ),
  (
    'f0f0f0f0-0000-4000-8000-000000000003',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000002',
    'POST',
    '/orders'
  )
on conflict do nothing;

insert into public.file_roles (
  id,
  analysis_id,
  organization_id,
  file_id,
  role,
  source
)
values
  (
    'a0a0a0a0-0000-4000-8000-000000000001',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'cccccccc-0000-4000-8000-000000000003',
    'page',
    'adapter'
  ),
  (
    'a0a0a0a0-0000-4000-8000-000000000002',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000002',
    'controller',
    'adapter'
  ),
  (
    'a0a0a0a0-0000-4000-8000-000000000003',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000001',
    'service',
    'adapter'
  )
on conflict do nothing;

insert into public.explanations (
  id,
  analysis_id,
  organization_id,
  file_id,
  folder_path,
  content_hash,
  prompt_version,
  model,
  body
)
values
  (
    'e0e0e0e0-0000-4000-8000-000000000001',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'cccccccc-0000-4000-8000-000000000001',
    null,
    '9c1f4b1d6a2e8f0b3c5d7e9a1b2c4d6e8f0a1b3c5d7e9f0a1b2c4d6e8f0a1b3c',
    'v1',
    'seed',
    'The cart holds line items for an in-progress checkout and delegates pricing to totals. Only the page imports it.'
  ),
  (
    'e0e0e0e0-0000-4000-8000-000000000002',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'dddddddd-0000-4000-8000-000000000002',
    null,
    '5e6f708192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f8091a2b3c4d',
    'v1',
    'seed',
    'Two order routes, both delegating to the orders service.'
  )
on conflict do nothing;

insert into public.insights (
  id,
  analysis_id,
  organization_id,
  kind,
  file_id,
  file_ids,
  sentence
)
values
  (
    'b0b0b0b0-0000-4000-8000-000000000001',
    'aaaaaaaa-0000-4000-8000-000000000001',
    'org_3LJO3Z5ul6yEpyewctTasDPyHqW',
    'unimported',
    'cccccccc-0000-4000-8000-000000000004',
    '{}',
    'Nothing imports this file.'
  ),
  (
    'b0b0b0b0-0000-4000-8000-000000000002',
    'bbbbbbbb-0000-4000-8000-000000000001',
    'org_3LMjDx4q5egO9IzSFiu8AiyYKp0',
    'cycle',
    null,
    array[
      'dddddddd-0000-4000-8000-000000000001'::uuid,
      'dddddddd-0000-4000-8000-000000000003'::uuid
    ],
    'These files import each other in a loop.'
  )
on conflict do nothing;
