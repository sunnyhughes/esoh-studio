# Build Plan
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Purpose
This document defines the implementation approach for Version 1 of Esoh Creations AI Image Studio. It translates the PRD and Design Plan into development phases, technical modules, milestones, dependencies, and delivery order.

Implementation planning should describe what will be built, in what order, how completion will be measured, and what dependencies or risks may affect the work. [web:133][web:139][web:141][web:142]

## Project Approach
Use a phased hybrid development plan:
1. Lock requirements and flows.
2. Build a lean internal MVP.
3. Add stable database structure early.
4. Expand workflow modules after the core loop works.
5. Add advanced business features only after the internal workflow is validated.

This approach aligns with MVP and software planning guidance that recommends phased delivery, clear scope, and milestone-based execution. [web:129][web:131][web:134][web:135]

## Preferred Stack
The implementation plan assumes a custom-coded approach using the team’s preferred workflow and tools:
- Visual Studio Code for development. [cite:18]
- GitHub for source control. [cite:18]
- Netlify for frontend-oriented deployment patterns already familiar to the team. [cite:21]
- Railway for app/backend infrastructure where needed. [cite:16]
- PostgreSQL for structured application data. [cite:16]

## Recommended Technical Architecture
### Frontend
- React or Next.js web application
- App-shell layout with sidebar, top bar, and module-based screens

### Backend
- Node.js/TypeScript API layer
- Service modules for prompts, jobs, assets, templates, and exports

### Database
- PostgreSQL with migration-based schema management

### Storage
- Cloud object storage for generated images and exports

### Documentation
- `docs/` directory in the repo for PRD, design plan, build plan, schema notes, and future operating rules

## Monorepo / Project Structure
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
    build-plan.md
    schema-notes.md
    user-stories.md
  .env.example
  package.json
  README.md
  