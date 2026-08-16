# Build Plan
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Purpose
This document defines the implementation approach for Version 1 of Esoh Creations AI Image Studio. It translates the PRD, Design Plan, API Route Map, and Schema Notes into phases, milestones, dependencies, technical modules, and delivery order.

Software implementation guidance consistently emphasizes planning, requirements, design, coding, testing, deployment, and maintenance as distinct phases, with milestones and dependency tracking used to reduce risk and keep scope under control. [web:129][web:130][web:131][web:139]

## Product Goal
Build an internal MVP that allows Esoh Creations to:
1. Choose a venture and project
2. Generate image jobs from templates or custom prompts
3. Review generated outputs
4. Save and approve selected assets
5. Search assets later
6. Export finalized assets

MVP guidance emphasizes focusing on the smallest product that solves the core problem and supports real-world testing rather than building every possible feature up front. [web:193][web:206]

## Implementation Strategy
Use a phased hybrid development plan:
- lock scope first
- scaffold the app shell early
- establish the database and route contract
- build the core workflow before secondary modules
- launch internally as soon as the main value loop is functional

This approach aligns with milestone-based MVP planning that prioritizes fast learning and reduced scope risk. [web:193][web:200][web:206]

## Stack Alignment
The build plan assumes the team’s preferred custom-coded workflow:
- Visual Studio Code for development. [cite:18]
- GitHub for version control. [cite:18]
- Netlify for frontend-oriented deployment patterns already used by the team. [cite:21]
- Railway for backend/app infrastructure and PostgreSQL hosting patterns already familiar through Meeting Now. [cite:16]
- PostgreSQL as the system of record. [cite:16]

## Repo Structure
Recommended starting structure:

```text
esoh-ai-image-studio/
  apps/
    web/
    api/
  packages/
    db/
    ui/
    types/
  docs/
    PRD.md
    design-plan.md
    api-route-map.md
    build-plan.md
    schema-notes.md
  .env.example
  package.json
  README.md
```

This structure keeps planning documents near the implementation and supports a clean separation between frontend, backend, and shared code. A visible structure also supports the user’s preference for organized, step-by-step execution. [cite:17][cite:18]

## Implementation Phases

### Phase 0: Scope lock and repo setup
Objective:
Freeze the V1 direction and create the development foundation.

Tasks:
- Finalize PRD
- Finalize Design Plan
- Finalize API Route Map
- Finalize Schema Notes
- Create GitHub repository
- Add repo folders
- Add `.env.example`
- Choose frontend framework
- Choose API structure
- Add README and docs

Deliverables:
- working repository scaffold
- committed docs set
- initial project scripts

Exit criteria:
- repo runs locally
- docs are complete enough to build from
- folder structure is stable

### Phase 1: Database foundation
Objective:
Create the database layer and verify the core data model.

Tasks:
- create `packages/db/schema.sql`
- create migration strategy
- run schema locally
- verify tables and indexes
- add starter seed approach for reference data only
- create DB connection module

Deliverables:
- working schema
- working DB connection
- starter reference data plan

Exit criteria:
- database builds successfully
- ventures and job types exist
- application can connect locally

Dependencies:
- Phase 0 complete

### Phase 2: App shell and routing
Objective:
Build the visible frame of the app before deep business logic.

Tasks:
- app shell layout
- sidebar nav
- top bar
- route structure
- placeholder screens:
  - Dashboard
  - New Job
  - Projects
  - Asset Library
  - Templates
  - Settings

Deliverables:
- navigable UI shell
- stable route layout
- shared layout components

Exit criteria:
- user can move through core screens
- screen hierarchy matches design plan

Dependencies:
- Phase 0 complete

### Phase 3: Core reference endpoints
Objective:
Expose the basic lookup data needed by the app.

Tasks:
- `GET /ventures`
- `GET /projects`
- `POST /projects`
- `GET /job-types`
- `GET /prompt-templates`
- create response formatting and error handling pattern

Deliverables:
- first working API endpoints
- connected selectors in UI

Exit criteria:
- New Job screen can load ventures, job types, and templates
- project creation works

Dependencies:
- Phase 1 database
- Phase 2 app shell

### Phase 4: Generation job workflow
Objective:
Implement the primary job-creation loop.

Tasks:
- build New Job form
- validate request input
- implement `POST /generation-jobs`
- implement `GET /generation-jobs/:jobId`
- integrate one image-generation provider
- handle queued, processing, success, and failed states
- store generation job records

Deliverables:
- working job submission flow
- provider integration
- job status retrieval

Exit criteria:
- user can submit a job and see job status
- job record persists in database

Dependencies:
- Phase 3 core reference endpoints

### Phase 5: Results Review and asset persistence
Objective:
Turn generated outputs into saved assets.

Tasks:
- implement `GET /generation-jobs/:jobId/assets`
- create Results Review UI
- create `generated_assets` records from provider results
- implement `GET /assets/:assetId`
- implement `PATCH /assets/:assetId`
- support favorite and approved states
- optionally write status history automatically

Deliverables:
- results grid
- asset detail retrieval
- asset update flow
- status persistence

Exit criteria:
- user can review outputs and save/approve an asset
- saved asset appears in DB and UI

Dependencies:
- Phase 4 generation workflow

### Phase 6: Asset Library and Project Workspace
Objective:
Enable reuse, search, and project-level organization.

Tasks:
- implement `GET /assets`
- add filters for venture, project, status, favorite, and tags later
- implement `GET /projects/:projectId`
- implement `GET /projects/:projectId/jobs`
- implement `GET /projects/:projectId/assets`
- build Asset Library UI
- build Project Workspace UI

Deliverables:
- searchable asset listing
- project detail view
- related jobs/assets view

Exit criteria:
- user can find assets later by project and status
- project workspace reflects related records

Dependencies:
- Phase 5 asset persistence

### Phase 7: Exports and templates management
Objective:
Support repeatable workflows and useful outputs.

Tasks:
- implement `POST /assets/:assetId/exports`
- optionally implement `GET /assets/:assetId/exports`
- build export actions in UI
- build Template Manager UI
- implement create/update template endpoints if needed in V1
- connect templates to New Job flow

Deliverables:
- export action
- reusable templates flow

Exit criteria:
- user can export selected assets
- user can reuse template-driven setup

Dependencies:
- Phase 6 asset and project flows

### Phase 8: QA, polish, and internal launch
Objective:
Stabilize the MVP for real internal use.

Tasks:
- test all must-have user stories
- review empty states
- review validation and error messages
- verify search behavior
- verify export flow
- verify responsive behavior
- deploy internal MVP
- create launch checklist
- log known issues and Phase 2 backlog

Deliverables:
- deployable internal MVP
- QA pass notes
- backlog for next iteration

Exit criteria:
- core flow works end to end
- app is usable for real internal image workflow

Dependencies:
- Phases 1 through 7 sufficiently complete

## Milestones
1. Docs locked
2. Repo scaffold created
3. Schema runs successfully
4. App shell navigable
5. Core lookup endpoints live
6. First generation job succeeds
7. First asset saved and approved
8. Asset Library searchable
9. First export completes
10. Internal MVP launch

Milestones create review checkpoints and reduce hidden drift during development. [web:131][web:134][web:200]

## Dependency Chain
- PRD → Design Plan → API Route Map → Schema/DB
- Schema → core endpoints
- core endpoints → New Job UI
- New Job UI → generation workflow
- generation workflow → Results Review
- Results Review → saved assets
- saved assets → Asset Library and exports

Dependency visibility is a core part of a workable implementation plan because it reveals blockers before they cause rework. [web:130][web:131][web:139]

## Technical Modules

### Frontend modules
- app shell
- sidebar/top bar
- dashboard
- new job form
- results review
- project workspace
- asset library
- template manager
- settings

### Backend modules
- DB connection
- ventures controller/service
- projects controller/service
- job types controller/service
- templates controller/service
- generation jobs controller/service
- assets controller/service
- exports controller/service
- provider integration service
- error handling middleware

### Database modules
- schema
- migrations
- seed/reference data
- query helpers
- future reporting queries

## Risks and Mitigations

### Risk 1: Scope creep
Risk:
Secondary features get added before the main workflow works.

Mitigation:
Build only the must-have endpoints and screens first. MVP guidance repeatedly warns against overbuilding too soon. [web:193][web:206]

### Risk 2: Provider instability
Risk:
Image provider behavior or pricing changes unexpectedly.

Mitigation:
Put provider logic behind one service layer so you can swap providers later.

### Risk 3: Weak metadata discipline
Risk:
Assets become hard to retrieve later.

Mitigation:
Require core metadata fields from the start and keep asset filters simple but consistent. DAM-style workflows depend on structured metadata and approvals. [web:194][web:204]

### Risk 4: Frontend-backend mismatch
Risk:
Screens ask for data the API does not cleanly provide.

Mitigation:
Use the API route map as the contract before implementing screens fully. API-first design recommends sketching the contract before deep implementation. [web:198][web:201]

### Risk 5: Planning fatigue
Risk:
Too much time is spent documenting and not enough time shipping.

Mitigation:
Move from docs into the app shell and first endpoints immediately after locking the route map and schema.

## Testing Plan
Test in the order of the real user flow:

1. Load ventures, projects, job types, and templates
2. Create project
3. Create generation job
4. Retrieve job status
5. Retrieve generated assets
6. Save/approve asset
7. Find asset in library
8. Export asset

Testing and QA are distinct stages in the development lifecycle and should happen before deployment, not after it. [web:129][web:200]

### Test types
- manual smoke tests
- route-level API tests
- basic form validation tests
- DB integrity checks
- end-to-end workflow test for the main job flow

## Deployment Plan
### Local
- run database locally
- run API locally
- run frontend locally

### Staging/internal preview
- deploy frontend preview
- deploy API preview
- connect preview database

### Internal production
- frontend on the chosen web deployment path already familiar to the team. [cite:21]
- backend and PostgreSQL on Railway-style infrastructure already familiar from Meeting Now. [cite:16]

## Environment Variables
Likely examples:
- `DATABASE_URL`
- `PORT`
- `APP_BASE_URL`
- `IMAGE_PROVIDER_API_KEY`
- `IMAGE_PROVIDER_NAME`
- `STORAGE_BUCKET`
- `STORAGE_REGION`
- `STORAGE_ACCESS_KEY`
- `STORAGE_SECRET_KEY`

Use `.env.example` to document required values, matching the team’s existing code-based workflow habits. [cite:93][cite:176]

## Out of Scope for V1
- public portal
- advanced auth/permissions
- Stripe billing
- batch generation
- multi-provider routing
- collaborative approvals board
- comments system
- analytics dashboards

## Immediate Next Actions
1. Save this build plan.
2. Save the API Route Map.
3. Create `packages/db/schema.sql` and run it locally.
4. Scaffold the repo/app shell.
5. Implement the core reference routes first:
   - `GET /ventures`
   - `GET /projects`
   - `POST /projects`
   - `GET /job-types`
   - `GET /prompt-templates`
6. Then implement the generation job flow.

## Open Build Questions
- Will the frontend start in React or Next.js?
- Will the API live as a separate app or inside the web framework initially?
- Which image provider should V1 target first?
- Should exports be immediate downloads or queued actions in V1?
- How much auth should be included before internal testing begins?