# API Route Map
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Purpose
This document defines the first-pass API contract for Version 1 of Esoh Creations AI Image Studio. It maps frontend screens and user flows to backend routes, request types, expected payloads, and response behaviors.

The API should be designed around product resources and real user flows. Current REST guidance recommends resource-oriented endpoints, plural nouns, predictable HTTP methods, and clear separation between collections and individual resources. [web:192][web:195][web:205]

## API Design Principles
1. Use nouns, not verbs, in endpoint paths.
2. Use plural resource names.
3. Keep one canonical path per resource where practical.
4. Let HTTP methods express the action.
5. Design endpoints around real screen needs and user flows.
6. Keep V1 focused on the minimum routes needed for the core workflow.

These principles align with common REST guidance and API-first design practices. [web:192][web:195][web:198][web:202][web:205]

## Base Conventions
### Base path
`/api/v1`

### Response format
JSON for both requests and responses is standard REST practice. [web:195]

### Common response envelope
Suggested response shape:

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

Error example:

```json
{
  "data": null,
  "meta": {},
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Project name is required"
  }
}
```

### Common status codes
- `200 OK` for successful reads and updates
- `201 Created` for successful creation
- `400 Bad Request` for validation/input issues
- `404 Not Found` when a resource does not exist
- `409 Conflict` for uniqueness/conflict issues
- `500 Internal Server Error` for unexpected failures

Standard status codes and graceful error handling are common REST API best practices. [web:195][web:196]

## Resource List
V1 resources:
- ventures
- projects
- job-types
- prompt-templates
- generation-jobs
- assets
- asset-status-history
- tags
- exports
- settings

## Screen-to-API Map
### Dashboard
Needs:
- ventures summary
- recent projects
- recent jobs
- recent approved assets

### New Job
Needs:
- ventures list
- projects list
- job types
- prompt templates
- create generation job
- poll/fetch generation job results

### Results Review
Needs:
- get job by id
- get generated assets by job
- save asset state
- update asset status
- mark favorite
- export selected asset

### Project Workspace
Needs:
- get project details
- list project jobs
- list project assets
- add project note

### Asset Library
Needs:
- list assets with filters
- get single asset
- update asset
- add/remove tags
- export asset

### Template Manager
Needs:
- list templates
- create template
- update template
- archive template

### Settings
Needs:
- get settings
- update settings

## Endpoint Map

## 1. Ventures
### GET /api/v1/ventures
Purpose:
Return all active ventures for selectors and filtering.

Used by:
- Dashboard
- New Job
- Asset Library
- Template Manager

Query params:
- `active=true|false` optional

Response:
- List of ventures with `id`, `slug`, `name`, `is_active`

### GET /api/v1/ventures/:ventureId
Purpose:
Return a single venture.

### POST /api/v1/ventures
Purpose:
Create a venture.
Note:
Likely admin-only and not part of everyday V1 flow, but useful for setup.

### PATCH /api/v1/ventures/:ventureId
Purpose:
Update venture metadata or active status.

## 2. Projects
### GET /api/v1/projects
Purpose:
Return projects for listing or selectors.

Used by:
- Dashboard
- New Job
- Projects view

Suggested query params:
- `ventureId`
- `status`
- `search`
- `limit`
- `offset`

### GET /api/v1/projects/:projectId
Purpose:
Return full project detail.

Used by:
- Project Workspace

Should include:
- project metadata
- venture info
- optional counts of jobs/assets

### POST /api/v1/projects
Purpose:
Create a new project.

Request body:
```json
{
  "ventureId": "uuid",
  "name": "Fall Coloring Pack",
  "slug": "fall-coloring-pack",
  "description": "Seasonal printable concepts"
}
```

### PATCH /api/v1/projects/:projectId
Purpose:
Update project metadata or archive status.

### GET /api/v1/projects/:projectId/jobs
Purpose:
Return jobs related to a project.

### GET /api/v1/projects/:projectId/assets
Purpose:
Return assets related to a project.

### GET /api/v1/projects/:projectId/notes
Purpose:
Return project notes.

### POST /api/v1/projects/:projectId/notes
Purpose:
Add a project note.

## 3. Job Types
### GET /api/v1/job-types
Purpose:
Return available job types.

Used by:
- New Job
- Template Manager

This endpoint supports the structured creation modes defined in the schema and PRD. [web:192][web:205]

## 4. Prompt Templates
### GET /api/v1/prompt-templates
Purpose:
Return templates for selection and management.

Suggested query params:
- `ventureId`
- `jobTypeId`
- `active`
- `search`

### GET /api/v1/prompt-templates/:templateId
Purpose:
Return one template.

### POST /api/v1/prompt-templates
Purpose:
Create a new template.

Request body example:
```json
{
  "ventureId": "uuid-or-null",
  "jobTypeId": "uuid",
  "name": "Kids Animal Coloring Page",
  "slug": "kids-animal-coloring-page",
  "description": "Simple clean line art template",
  "templateText": "Create a black and white coloring page of {{subject}}...",
  "defaultSettingsJson": {
    "aspectRatio": "8.5x11",
    "lineArt": true
  }
}
```

### PATCH /api/v1/prompt-templates/:templateId
Purpose:
Update template fields.

### DELETE /api/v1/prompt-templates/:templateId
Purpose:
Soft-delete or archive template.
Recommendation:
Use archive behavior instead of hard delete in V1.

## 5. Generation Jobs
### GET /api/v1/generation-jobs
Purpose:
Return jobs list for dashboards or project views.

Suggested query params:
- `ventureId`
- `projectId`
- `status`
- `jobTypeId`
- `limit`
- `offset`

### GET /api/v1/generation-jobs/:jobId
Purpose:
Return one job and its status.

Used by:
- Results Review
- Project Workspace

### POST /api/v1/generation-jobs
Purpose:
Create and submit a generation job.

This is the central API action for the V1 workflow because it turns prompt context into a tracked job record that can later produce assets. API-first guidance recommends designing this around the user story rather than generic CRUD thinking. [web:198][web:199][web:204]

Request body example:
```json
{
  "ventureId": "uuid",
  "projectId": "uuid",
  "jobTypeId": "uuid",
  "promptTemplateId": "uuid-or-null",
  "title": "Autumn fox coloring page",
  "promptText": "Create a printable black-and-white line art coloring page of a fox in autumn leaves...",
  "settingsJson": {
    "aspectRatio": "8.5x11",
    "lineArt": true,
    "numImages": 4
  },
  "providerName": "provider-key"
}
```

Behavior:
1. Validate input
2. Create `generation_jobs` row
3. Submit to image provider
4. Update job status
5. Create `generated_assets` rows when results return

Response:
- created job record
- initial status
- optional placeholder for results

### PATCH /api/v1/generation-jobs/:jobId
Purpose:
Update limited fields such as title or metadata if needed.

### POST /api/v1/generation-jobs/:jobId/retry
Purpose:
Retry a failed job.
Note:
This is a controlled exception where a verb-like subresource action can be acceptable because it represents a domain event rather than plain CRUD. The main route structure still remains resource-based. [web:192][web:195]

### GET /api/v1/generation-jobs/:jobId/assets
Purpose:
Return all assets created by a generation job.

Used by:
- Results Review

## 6. Assets
### GET /api/v1/assets
Purpose:
Return saved/generated assets for library and filtered browsing.

Suggested query params:
- `ventureId`
- `projectId`
- `jobTypeId`
- `status`
- `favorite`
- `tag`
- `search`
- `limit`
- `offset`
- `sortBy`
- `sortOrder`

Filtering, sorting, and pagination are standard API design best practices for collection endpoints. [web:195]

### GET /api/v1/assets/:assetId
Purpose:
Return a single asset with metadata.

### POST /api/v1/assets
Purpose:
Optional in V1 if assets are only created from generation jobs.
Recommendation:
Do not expose unless manual asset creation becomes necessary.

### PATCH /api/v1/assets/:assetId
Purpose:
Update asset metadata such as:
- `assetName`
- `status`
- `isFavorite`
- selected metadata fields

Request body example:
```json
{
  "status": "approved",
  "isFavorite": true,
  "assetName": "fox-autumn-approved-01"
}
```

### DELETE /api/v1/assets/:assetId
Purpose:
Archive or soft-delete asset if needed.
Recommendation:
Avoid hard delete in V1 unless truly necessary.

## 7. Asset Status History
### GET /api/v1/assets/:assetId/status-history
Purpose:
Return status changes for one asset.

### POST /api/v1/assets/:assetId/status-history
Purpose:
Create a status event.

Recommendation:
In many implementations, status history can be written automatically when asset status changes rather than manually called from the frontend.

## 8. Tags
### GET /api/v1/tags
Purpose:
Return tags for filters and tagging UI.

### POST /api/v1/tags
Purpose:
Create a new tag.

### POST /api/v1/assets/:assetId/tags
Purpose:
Attach one or more tags to an asset.

Request body example:
```json
{
  "tagIds": ["uuid1", "uuid2"]
}
```

### DELETE /api/v1/assets/:assetId/tags/:tagId
Purpose:
Remove a tag from an asset.

## 9. Exports
### GET /api/v1/exports
Purpose:
Return export history if needed for admin or project tracking.

### POST /api/v1/assets/:assetId/exports
Purpose:
Create an export event for an asset.

Request body example:
```json
{
  "exportFormat": "png",
  "exportPreset": "instagram-square"
}
```

Behavior:
- validate asset exists
- generate or prepare export
- record export event
- return export path or download URL token

### GET /api/v1/assets/:assetId/exports
Purpose:
Return export history for a specific asset.

## 10. Settings
### GET /api/v1/settings
Purpose:
Return app-level defaults for the current user or workspace.

### PATCH /api/v1/settings
Purpose:
Update naming rules, export defaults, and similar preferences.

Note:
Settings can begin as a lightweight single-row or per-user implementation and grow later.

## Route Priorities for V1
### Must-have routes
- `GET /ventures`
- `GET /projects`
- `POST /projects`
- `GET /job-types`
- `GET /prompt-templates`
- `POST /generation-jobs`
- `GET /generation-jobs/:jobId`
- `GET /generation-jobs/:jobId/assets`
- `GET /assets`
- `GET /assets/:assetId`
- `PATCH /assets/:assetId`
- `POST /assets/:assetId/exports`

These routes are enough to support the primary V1 loop: choose context, create job, review results, save/approve asset, find asset later, and export it. MVP guidance recommends keeping early scope tied tightly to the minimum functional loop. [web:193][web:200][web:206]

### Should-have routes
- `GET /projects/:projectId`
- `GET /projects/:projectId/jobs`
- `GET /projects/:projectId/assets`
- `POST /projects/:projectId/notes`
- `GET /tags`
- `POST /assets/:assetId/tags`

### Later routes
- venture creation/update
- template archive/delete
- retry failed jobs
- settings update
- exports history
- richer admin routes

## Validation Rules
Examples:
- `ventureId`, `projectId`, and `jobTypeId` must be valid UUIDs where required.
- `promptText` is required for generation jobs.
- `providerName` is required when creating a generation job.
- `status` must match allowed values.
- `name` and `slug` are required for project creation.

Validation should happen before DB writes to protect data quality and improve API reliability. [web:192][web:201]

## Auth Notes
For V1 internal use, auth can be lightweight or deferred, but the route map should be written with future auth in mind.

Suggested future pattern:
- authenticated user context available on protected routes
- `created_by` and `submitted_by` populated from session/user context
- admin/editor role enforcement for selected routes

## Error Handling
Return consistent error bodies for:
- invalid input
- missing records
- uniqueness conflicts
- provider failures
- unexpected server errors

Consistent error handling is a core API usability principle. [web:195][web:201]

## Open API Questions
- Should `projects` be a first-class top-level screen in V1 or mostly a selector plus workspace view?
- Should asset approval be represented only by `PATCH /assets/:assetId` or also as a dedicated subresource event?
- Should template deletion be hard delete, soft delete, or archive-only?
- Should exports return direct URLs, queued export jobs, or simple metadata in V1?
