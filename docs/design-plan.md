# Design Plan
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Purpose
This document translates the PRD into product structure, navigation, user flows, screen responsibilities, and UI behavior for Version 1.

The design goal is to create a clean internal creative workflow app that reduces friction across image generation, review, organization, and export. Information architecture should keep content easy to understand and locate, while user flows should make the main tasks short and predictable. [web:110][web:114][web:117][web:120]

## Design Principles
1. Reduce tool-switching friction.
2. Keep the primary workflow short and obvious.
3. Make venture and project context visible at all times.
4. Favor reusable templates over repeated manual setup.
5. Make saved work easy to find and reuse.
6. Keep the interface calm, structured, and operational rather than decorative.

These principles follow MVP UX guidance that emphasizes removing unnecessary steps, organizing essential functionality clearly, and building around key tasks first. [web:111][web:115][web:118][web:124]

## Primary User
Internal Esoh Creations operator creating images for multiple ventures and use cases.

User characteristics:
- Works across multiple business ventures and creative outputs.
- Needs organization and clarity across projects and assets.
- Benefits from step-by-step, structured workflow paths.
- Needs repeatable results more than exploratory design complexity.

## Product Structure
The product structure should prioritize wayfinding and repeatability. Information architecture organizes the content hierarchy and navigation system so users know where work begins, where it is stored, and how to return to it later. [web:110][web:114][web:117]

### Top-level navigation
- Dashboard
- New Job
- Projects
- Asset Library
- Templates
- Settings

### Supporting navigation
- Venture switcher
- Current project breadcrumb
- Filters/search in library views
- Quick actions: New Job, Save, Approve, Export

## Information Architecture
### Main objects in the product
- Venture
- Project
- Job Type
- Prompt Template
- Generation Job
- Generated Asset
- Asset Status
- Export

### Hierarchy
1. Venture
2. Project
3. Generation Job
4. Generated Asset
5. Approval/Export state

This hierarchy should stay visible in screen labels and breadcrumbs because IA works best when the content structure mirrors the user’s mental model. [web:110][web:117][web:120]

## Core User Flows
User flows should focus on the shortest path to the main outcomes. UX guidance recommends starting with primary tasks and mapping the actions and decisions required to complete them. [web:111][web:115][web:123][web:124]

### Flow 1: Create a new image job
Entry point:
- Dashboard quick action
- New Job nav item
- Project detail quick action

Steps:
1. Choose venture.
2. Choose existing project or create new project.
3. Choose job type.
4. Choose template.
5. Fill prompt fields and settings.
6. Submit generation job.
7. Wait for result state.
8. Review outputs.

Success state:
- User reaches Results Review with generated outputs visible.

### Flow 2: Save and approve an output
Entry point:
- Results Review screen
- Project Workspace screen

Steps:
1. Open results.
2. Compare outputs.
3. Favorite one or more.
4. Save selected output.
5. Change asset status to approved if ready.
6. Return to project or export.

Success state:
- Selected output is stored in the project and asset library with correct metadata and status.

### Flow 3: Find an existing asset
Entry point:
- Asset Library
- Project Workspace

Steps:
1. Open asset search/filter view.
2. Filter by venture, project, type, or status.
3. Open matching asset record.
4. Download/export or reuse prompt context.

Success state:
- User locates a previously saved asset without leaving the app.

### Flow 4: Reuse a prompt template
Entry point:
- New Job
- Templates

Steps:
1. Open template list.
2. Select a template by job type or venture.
3. Edit fields if needed.
4. Submit a new generation job.

Success state:
- User starts a job faster than building prompt settings from scratch.

## Screen Definitions
### 1. Dashboard
Purpose:
- Provide a snapshot of recent work and fast entry to main actions.

Key content:
- Recent projects
- Recent approved assets
- Jobs in progress
- Quick start buttons
- Venture summary cards

Primary actions:
- New Job
- Open Project
- View Library

Design notes:
- Prioritize actionable content over analytics in V1.
- Keep the layout simple and scannable.

### 2. New Job
Purpose:
- Create a structured image generation request.

Key content:
- Venture selector
- Project selector/create new project
- Job type selector
- Template selector
- Prompt form fields
- Settings panel
- Submit button

Primary action:
- Generate Images

Design notes:
- Use progressive disclosure where useful, but keep required fields visible.
- Avoid overwhelming the user with all possible options at once.
- Group fields by meaning: context, style, output, generation settings.

### 3. Results Review
Purpose:
- Review, compare, save, and approve generated outputs.

Key content:
- Grid of generated outputs
- Favorite button
- Save button
- Regenerate action
- Status indicators
- Quick metadata summary

Primary actions:
- Save Asset
- Approve Asset
- Regenerate

Design notes:
- This screen is decision-focused.
- Make comparison easy and actions unmistakable.
- Keep image cards visually consistent.

### 4. Project Workspace
Purpose:
- Central home for all work related to one project.

Key content:
- Project metadata
- Related jobs
- Saved assets
- Approval statuses
- Export history
- Notes

Primary actions:
- Start New Job
- Open Asset
- Export

Design notes:
- Use tabs or clearly separated sections.
- Keep the project context visible at the top.

### 5. Asset Library
Purpose:
- Search, browse, and retrieve saved assets.

Key content:
- Filter bar
- Search input
- Asset cards/list
- Venture/project/status labels
- Sort controls

Primary actions:
- Open Asset
- Export Asset
- Filter Results

Design notes:
- Retrieval speed matters more than visual novelty.
- Metadata should be visible enough to support quick scanning.

### 6. Template Manager
Purpose:
- Create, edit, and reuse prompt templates.

Key content:
- Template list
- Template categories
- Template editor
- Venture association
- Job type association

Primary actions:
- Create Template
- Save Template
- Use Template

Design notes:
- Favor standardization.
- Templates should feel operational, not buried.

### 7. Settings
Purpose:
- Hold system preferences and future configuration options.

Key content:
- Naming rules
- Export defaults
- Venture defaults
- Provider/config placeholders
- User preferences

Primary actions:
- Save Settings

Design notes:
- Keep this minimal in V1.

## Navigation Model
Use a persistent left sidebar for primary navigation on desktop:
- Dashboard
- New Job
- Projects
- Asset Library
- Templates
- Settings

Use top-bar context for:
- Active venture
- Search
- User menu
- Current page title

For mobile or narrow layouts:
- Collapse primary nav into a menu or bottom-access pattern while keeping New Job easy to reach.

Information architecture guidance emphasizes clear labeling, hierarchy, and wayfinding, while user-flow guidance stresses that navigation should support task completion rather than distract from it. [web:110][web:114][web:120]

## Layout Behavior
### Overall layout
- App shell with sidebar, top bar, and main content region.
- One clear primary action per major screen.
- Use cards, lists, and panels for organization.
- Keep spacing consistent and functional.

### Content density
- Moderate density.
- Enough metadata for business use, but not cluttered.
- Prioritize readable labels and scannable states.

### Empty states
Every empty state should explain:
- What belongs here.
- Why it matters.
- What action to take next.

Example:
“No assets saved yet. Generate or save an image from a project to build your library.”

## Interaction Rules
### Primary actions
Each major screen should have one clearly dominant action:
- Dashboard → New Job
- New Job → Generate Images
- Results Review → Save Asset
- Asset Library → Open Asset / Export

### Status behavior
Assets should display simple status states:
- Draft
- Favorite
- Approved

Status should be visible in:
- Asset cards
- Project Workspace
- Library results
- Asset detail view

### Confirmation behavior
Use confirmation only for destructive actions such as delete.
Do not overuse modal interruptions for standard save/approve flows.

### Feedback behavior
The user should always know:
- When a job is processing.
- When generation succeeded.
- When an asset was saved.
- When a status changed.
- When an export completed.

MVP UX best practices recommend clear, lightweight feedback and logical paths that reduce uncertainty. [web:115][web:118][web:124]

## Design System Direction
Version 1 should use a clean internal-app design system focused on consistency rather than high brand theatrics. Design-system guidance describes a system as a reusable set of components, patterns, and rules that create consistency and reduce duplicated decision-making. [web:112][web:116][web:122]

### Visual direction
- Calm, structured, professional.
- Neutral surfaces with one controlled accent color.
- High readability.
- Minimal visual noise.

### Component priorities
- Buttons
- Inputs
- Select menus
- Cards
- Status badges
- Tabs
- Search/filter bar
- Modal/drawer
- Toast/inline feedback

### Typography
- Clean, legible sans-serif for UI.
- Clear hierarchy between page title, section title, body, and metadata.

### Accessibility
- Strong contrast.
- Keyboard-friendly navigation.
- Clear focus states.
- Descriptive labels for controls.
- Alt text or asset labeling where relevant.

## V1 Wireframe Notes
This phase does not require high-fidelity visual exploration first. Start with low-fidelity wireframes for:
1. Dashboard
2. New Job
3. Results Review
4. Project Workspace
5. Asset Library

Low-fidelity flows are often the fastest way to validate MVP UX because they keep attention on user tasks and structure before visual polish. [web:111][web:123][web:124]

## Design Risks
- Too many options on New Job could overwhelm the user.
- Weak project/venture labeling could cause asset confusion.
- Poor metadata display could reduce library usefulness.
- Overdesigned image cards could distract from decision-making.
- Navigation drift could make repeat tasks feel slower instead of faster.

## Open Design Questions
- Should Projects and Asset Library be separate top-level items or should Library live inside Projects in V1?
- Does Results Review need side-by-side compare in V1, or is selection/favorite enough?
- Should templates be global, venture-specific, or both?
- What metadata must always be visible on an asset card?
- Should export happen from results, project view, library view, or all three?

## Deliverables from this document
- Low-fidelity wireframes
- Navigation map
- User flow diagrams
- Initial component list
- UI implementation priorities

