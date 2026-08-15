# Schema Notes
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Purpose
This document defines the initial PostgreSQL schema direction for Version 1 of Esoh Creations AI Image Studio. It explains the core entities, relationships, key fields, indexing approach, and V1 schema decisions.

The schema is designed to support a structured internal workflow for:
- venture-based asset separation
- project organization
- prompt template reuse
- image generation jobs
- generated asset storage
- approval/status tracking
- export history

Metadata and approval structure are especially important for digital asset workflows because asset findability, reusability, and governance depend on them. [web:150][web:153][web:156]

## Design Principles
1. Keep V1 normalized enough to stay clean, but not overengineered.
2. Separate ventures, projects, jobs, assets, and exports clearly.
3. Use metadata as a first-class part of the product.
4. Store workflow status explicitly.
5. Keep the schema flexible enough for future approvals, team roles, and billing.
6. Favor lookup tables or constrained text values over hard-to-change enums unless a value set is truly permanent. PostgreSQL schema guidance commonly recommends caution with enums because they are harder to evolve cleanly. [web:146][web:148][web:155]

## PostgreSQL Conventions
### Primary keys
Use `uuid` primary keys for app-facing tables.

### Timestamps
Use `timestamptz` for:
- `created_at`
- `updated_at`
- `submitted_at`
- `completed_at`
- `approved_at`
- `exported_at`

Current PostgreSQL guidance recommends `TIMESTAMPTZ` for audit and cross-timezone correctness. [web:158]

### Foreign keys
Define foreign keys explicitly and index the ones used in joins and filters. PostgreSQL does not automatically index foreign keys, so explicit indexing is recommended for performance. [web:149][web:158]

### Required audit columns
Most tables should include:
- `created_at`
- `updated_at`
- `created_by` where relevant

### Status fields
For V1, use `text` plus `check` constraints or lookup tables rather than PostgreSQL enums for statuses likely to evolve. Best-practice sources commonly recommend avoiding hard-to-change enums when the value set may grow or change. [web:146][web:148][web:158]

## Core Entity Model
The product’s main data relationships are:

1. A venture contains many projects.
2. A project contains many generation jobs.
3. A generation job can produce many generated assets.
4. A generated asset can have status history, approval data, tags, and exports.
5. Prompt templates can be reused across ventures or scoped to a specific venture.

This structure supports the internal multi-venture operating model of Esoh Creations and keeps assets separated and searchable across brands and product lines. [cite:19][cite:20]

## V1 Tables

### 1. ventures
Represents a business unit, brand, or internal operating area.

Purpose:
Keep assets and projects separated by venture from the start.

Suggested fields:
- `id uuid primary key`
- `slug text not null unique`
- `name text not null`
- `description text null`
- `is_active boolean not null default true`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Examples:
- `vv-styles`
- `coloring-books`
- `print-designs`
- `social-content`
- `parent-admin`

Notes:
This mirrors the umbrella-company structure where separate ventures need clear records and organization. [cite:19][cite:20]

### 2. users
Represents internal users first, with room for future collaborators.

Suggested fields:
- `id uuid primary key`
- `email text not null unique`
- `full_name text null`
- `role text not null default 'admin'`
- `is_active boolean not null default true`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

V1 roles:
- `admin`
- `editor`

Use a check constraint for V1 if you want lightweight validation.

### 3. projects
Represents a collection of related jobs and assets.

Suggested fields:
- `id uuid primary key`
- `venture_id uuid not null references ventures(id)`
- `name text not null`
- `slug text not null`
- `description text null`
- `status text not null default 'active'`
- `start_date date null`
- `target_date date null`
- `created_by uuid null references users(id)`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Suggested unique constraint:
- unique on (`venture_id`, `slug`)

V1 project statuses:
- `active`
- `archived`

### 4. job_types
Defines the main creation modes in the app.

Suggested fields:
- `id uuid primary key`
- `code text not null unique`
- `label text not null`
- `description text null`
- `is_active boolean not null default true`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Starter rows:
- `coloring_page`
- `social_post`
- `print_design`
- `brand_concept`

Why a table:
A lookup table is more flexible than hardcoded values and easier to manage as the product grows. Lookup-table approaches are commonly recommended where statuses or categories may evolve. [web:146][web:148]

### 5. prompt_templates
Stores reusable structured prompt formulas.

Suggested fields:
- `id uuid primary key`
- `venture_id uuid null references ventures(id)`
- `job_type_id uuid not null references job_types(id)`
- `name text not null`
- `slug text not null`
- `description text null`
- `template_text text not null`
- `default_settings_json jsonb not null default '{}'::jsonb`
- `is_system_template boolean not null default false`
- `is_active boolean not null default true`
- `created_by uuid null references users(id)`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Suggested unique constraint:
- unique on (`job_type_id`, `venture_id`, `slug`)

Notes:
- `venture_id` null means global template.
- `default_settings_json` can store aspect ratio, output format, line-art preference, or style preferences.

### 6. generation_jobs
Represents each submitted image-generation request.

Suggested fields:
- `id uuid primary key`
- `venture_id uuid not null references ventures(id)`
- `project_id uuid not null references projects(id)`
- `job_type_id uuid not null references job_types(id)`
- `prompt_template_id uuid null references prompt_templates(id)`
- `submitted_by uuid null references users(id)`
- `title text null`
- `prompt_text text not null`
- `settings_json jsonb not null default '{}'::jsonb`
- `provider_name text not null`
- `provider_job_id text null`
- `status text not null default 'queued'`
- `error_message text null`
- `submitted_at timestamptz not null default now()`
- `completed_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

V1 statuses:
- `queued`
- `processing`
- `succeeded`
- `failed`

Notes:
This table is the operational backbone of the workflow because it separates “the request” from “the returned images.”

### 7. generated_assets
Represents each image output returned from a generation job.

Suggested fields:
- `id uuid primary key`
- `generation_job_id uuid not null references generation_jobs(id)`
- `venture_id uuid not null references ventures(id)`
- `project_id uuid not null references projects(id)`
- `asset_name text not null`
- `storage_path text not null`
- `thumbnail_path text null`
- `mime_type text not null`
- `file_extension text null`
- `width integer null`
- `height integer null`
- `file_size_bytes bigint null`
- `status text not null default 'draft'`
- `is_favorite boolean not null default false`
- `source_variant_index integer null`
- `metadata_json jsonb not null default '{}'::jsonb`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

V1 asset statuses:
- `draft`
- `approved`
- `rejected`

Notes:
Metadata is critical for retrieval and reuse in digital asset workflows, so `metadata_json` should be intentional rather than an afterthought. [web:150][web:153]

### 8. asset_status_history
Tracks workflow changes over time.

Suggested fields:
- `id uuid primary key`
- `asset_id uuid not null references generated_assets(id)`
- `old_status text null`
- `new_status text not null`
- `changed_by uuid null references users(id)`
- `notes text null`
- `changed_at timestamptz not null default now()`

Why keep this:
Approval workflows benefit from a visible state trail rather than only a single current status field. DAM approval guidance emphasizes structured review and authorization flow. [web:63][web:156]

### 9. exports
Tracks download/export actions.

Suggested fields:
- `id uuid primary key`
- `asset_id uuid not null references generated_assets(id)`
- `exported_by uuid null references users(id)`
- `export_format text not null`
- `export_preset text null`
- `export_path text null`
- `notes text null`
- `exported_at timestamptz not null default now()`
- `created_at timestamptz not null default now()`

Example formats:
- `png`
- `jpg`
- `webp`
- `pdf`
- `zip`

Why keep this:
Export history helps operational traceability and later reporting.

### 10. tags
Supports flexible metadata classification.

Suggested fields:
- `id uuid primary key`
- `name text not null unique`
- `slug text not null unique`
- `created_at timestamptz not null default now()`

### 11. asset_tags
Join table for many-to-many tagging.

Suggested fields:
- `asset_id uuid not null references generated_assets(id)`
- `tag_id uuid not null references tags(id)`
- `created_at timestamptz not null default now()`

Primary key:
- composite primary key (`asset_id`, `tag_id`)

### 12. project_notes
Optional but useful for V1 internal workflow context.

Suggested fields:
- `id uuid primary key`
- `project_id uuid not null references projects(id)`
- `author_id uuid null references users(id)`
- `note_body text not null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

## Relationship Summary
- `ventures` 1 → many `projects`
- `ventures` 1 → many `generation_jobs`
- `ventures` 1 → many `generated_assets`
- `projects` 1 → many `generation_jobs`
- `projects` 1 → many `generated_assets`
- `job_types` 1 → many `prompt_templates`
- `job_types` 1 → many `generation_jobs`
- `prompt_templates` 1 → many `generation_jobs`
- `generation_jobs` 1 → many `generated_assets`
- `generated_assets` 1 → many `asset_status_history`
- `generated_assets` many ↔ many `tags` through `asset_tags`
- `generated_assets` 1 → many `exports`

## Required Indexes
At minimum, add indexes on:
- `projects(venture_id)`
- `generation_jobs(venture_id)`
- `generation_jobs(project_id)`
- `generation_jobs(job_type_id)`
- `generation_jobs(prompt_template_id)`
- `generation_jobs(status)`
- `generated_assets(generation_job_id)`
- `generated_assets(venture_id)`
- `generated_assets(project_id)`
- `generated_assets(status)`
- `generated_assets(is_favorite)`
- `asset_status_history(asset_id)`
- `exports(asset_id)`

PostgreSQL best-practice sources recommend explicit indexing on foreign keys and frequently filtered fields. [web:149][web:158]

## Search and Metadata Strategy
The asset library depends on metadata quality. DAM sources describe metadata as the foundation for searchability, trackability, and reuse. [web:150][web:153]

For V1, ensure each saved asset can be filtered by:
- venture
- project
- job type
- status
- favorite
- tag
- created date

Suggested searchable metadata to store either as explicit columns or in `metadata_json`:
- aspect ratio
- intended channel
- prompt style
- line-art flag
- print-ready flag
- color mode
- series or collection name

## JSONB Guidance
Use `jsonb` for settings and provider-specific metadata, but do not use `jsonb` as an excuse to skip core relational structure.

Good uses in V1:
- provider response fragments
- generation settings
- optional asset metadata
- template defaults

Avoid storing these only in JSON:
- venture identity
- project identity
- status
- user identity
- asset path
- timestamps

## Suggested Constraints
Examples:
- `check (status in ('active','archived'))` on projects
- `check (status in ('queued','processing','succeeded','failed'))` on generation_jobs
- `check (status in ('draft','approved','rejected'))` on generated_assets
- `check (role in ('admin','editor'))` on users

Constraint-driven validation helps preserve data quality at the database layer. [web:149][web:152][web:158]

## Deletion Strategy
Recommended V1 deletion rules:
- Do not hard-delete ventures if linked records exist.
- Restrict deleting projects with linked jobs or assets.
- Restrict deleting generation jobs with linked assets.
- Cascade delete `asset_tags` when an asset is deleted.
- Preserve `asset_status_history` and `exports` unless a deliberate purge policy exists.

Why:
Operational records should not disappear casually in a workflow system.

## Naming Strategy
Recommended naming rules:
- Table names plural
- Primary key field always `id`
- Foreign keys named `{table_singular}_id`
- Timestamps use explicit names like `created_at`, `updated_at`, `submitted_at`
- Slugs for stable human-readable identifiers where needed

## V1 Seed Data
Seed these tables early:
- `ventures`
- `job_types`
- `users` (optional local admin)
- basic `prompt_templates`

Starter ventures could reflect actual business use areas:
- VV-Styles
- Coloring Books
- Print Designs
- Social Content
- Parent/Admin

This supports your need for clear separation across ventures and structured organization under Esoh Creations. [cite:19][cite:20]

## Future Schema Expansion
Not required in V1, but plan for:
- `approval_requests`
- `comments`
- `attachments`
- `provider_configs`
- `billing_events`
- `usage_credits`
- `teams`
- `permissions`
- `collections`
- `asset_derivatives`

## Example Migration Order
1. `ventures`
2. `users`
3. `job_types`
4. `projects`
5. `prompt_templates`
6. `generation_jobs`
7. `generated_assets`
8. `asset_status_history`
9. `tags`
10. `asset_tags`
11. `exports`
12. `project_notes`

Migration ordering should respect foreign-key dependencies and keep setup predictable. [web:149][web:158]

## Open Schema Questions
- Should “Coloring Books” and “Social Content” be true ventures, or should they be job categories under a smaller venture list?
- Should asset approval allow only one current approved version per project/output set?
- Will exports ever need bundled records, such as multi-file ZIP packages or print kits?
- Should `generated_assets` support parent-child versioning in V1, or can version relationships wait for Phase 2?
- Which metadata fields deserve first-class columns instead of `jsonb` storage?
