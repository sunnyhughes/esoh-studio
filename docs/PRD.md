# Product Requirements Document
## Project
Esoh Creations AI Image Studio

## Status
Draft v1

## Owner
Esoh Creations LLC

## Background
Esoh Creations LLC operates multiple ventures and creative product lines, including apparel, digital products, and app-based ventures under one umbrella business structure. [cite:19]

The business needs a centralized internal tool to generate, organize, review, and export business-ready images for multiple use cases such as coloring book pages, VV-Styles visuals, print-ready graphics, and social media content. Current workflows spread this work across multiple tools, which increases friction, rework, and inconsistency. Creative operations guidance emphasizes that value comes from connecting asset creation, review, organization, and approval rather than treating generation as a one-off action. [cite:20][web:71][web:74][web:77]

## Problem Statement
The current image-creation workflow requires switching between multiple outside tools for prompt writing, generation, selection, cleanup, organization, and export. This creates unnecessary time loss, inconsistent naming and storage, limited reuse of prior work, and more mental strain than a centralized workflow should require. DAM and creative-ops sources consistently describe scattered workflows as a bottleneck that is best solved by centralized assets, metadata, and approvals. [web:63][web:68][web:74]

## Product Vision
Build an internal creative operations app for Esoh Creations that helps the team generate images faster, keep assets organized by venture and project, standardize reusable prompt templates, and move approved outputs into business-ready formats.

## Goal for Version 1
Version 1 should let an internal user:
1. Choose a venture or brand.
2. Start a new image generation job from a structured template.
3. Generate image options.
4. Save selected outputs to a project.
5. Mark assets by status such as draft, favorite, or approved.
6. Search and export saved assets later.

This follows MVP guidance to focus on a small number of essential user outcomes rather than overbuilding the first release. [web:101][web:102][web:104]

## Target Users
### Primary user
Internal Esoh Creations operator creating assets for multiple ventures and product lines. The product should support structured workflows and clear separation across business units, matching Esoh Creations’ umbrella-company model. [cite:19][cite:20]

### Secondary users
Future internal collaborators, contractors, or approved business partners who may need to review, organize, or export assets.

## Core Use Cases
- Create printable coloring book page concepts.
- Create VV-Styles campaign and fashion visuals.
- Create print-ready graphics for products or packaging.
- Create social media post graphics in standard aspect ratios.
- Reuse prior prompts, templates, and approved assets for faster production.

## In Scope for V1
- Venture/brand selection.
- Project creation and project-level asset organization.
- Job type selection, such as coloring page, social graphic, print design, or branded concept image.
- Structured prompt form using templates and settings.
- Image generation through one provider to start.
- Results review screen showing multiple outputs.
- Save selected outputs to asset library.
- Asset statuses: draft, favorite, approved.
- Search/filter asset library by venture, project, job type, and status.
- Download/export selected assets.

## Out of Scope for V1
- Public/client-facing portal.
- Stripe billing or credit system.
- Advanced team permissions.
- Full collaborative commenting.
- Batch generation pipelines.
- Integrated advanced editing suite.
- Multi-provider model routing.
- Automated social scheduling.

Documenting non-goals is recommended in MVP PRDs so scope stays protected during early development. [web:98][web:101][web:107]

## Success Metrics
- A user can complete a new image job from prompt to saved output in one workflow.
- Approved assets can be found later by venture and project without manual digging.
- Prompt reuse reduces repeated setup work across recurring image tasks.
- The tool reduces switching between multiple external apps for common image-production tasks.

Success metrics should measure outcomes, not just whether the app shipped. [web:101][web:103][web:109]

## User Stories
1. As an internal Esoh Creations user, I want to choose a venture before I generate images so assets stay separated by business unit. This aligns with the business’s multi-venture structure and need for clear operational separation. [cite:19][cite:20]

2. As a user, I want to start from a saved template such as coloring page, social post, or print design so I do not have to rebuild prompts from scratch every time. Template reuse supports creative standardization and repeatable workflow. [web:74][web:77]

3. As a user, I want to review multiple generated outputs in one place so I can quickly compare, favorite, and save the best option. Centralized review is part of effective creative operations and approval handling. [web:68][web:71]

4. As a user, I want to save outputs into a project so all related work stays together and is easier to find later.

5. As a user, I want to mark an asset as approved so I can clearly separate candidate images from final-use images. Approval states are a standard part of asset governance and digital asset workflows. [web:63][web:73]

6. As a user, I want to search saved assets by venture, project, type, and status so I can reuse existing work instead of recreating it. DAM guidance repeatedly emphasizes organization, metadata, and retrieval as core value. [web:71][web:74][web:76]

## Functional Requirements
### FR1 Venture selection
The system must allow the user to choose a venture or brand before creating a job.

### FR2 Project organization
The system must allow the user to create or select a project when starting a new job.

### FR3 Job type selection
The system must support predefined job types for at least:
- Coloring page
- Social post
- Print design
- Branded concept image

### FR4 Prompt templates
The system must allow the user to select a reusable prompt template and edit the prompt fields before submission.

### FR5 Image generation
The system must submit the job to an image-generation provider and return multiple image results for review.

### FR6 Results review
The system must display generated results in a gallery/grid view and allow the user to:
- Favorite an output
- Save an output
- Regenerate from the same job

### FR7 Asset library
The system must store saved outputs with metadata and allow users to filter/search by:
- Venture
- Project
- Job type
- Status

### FR8 Approval status
The system must support at least three statuses:
- Draft
- Favorite
- Approved

### FR9 Export
The system must allow the user to download/export a selected approved or saved asset.

## Non-functional Requirements
- The app should feel organized and simple enough for repeated daily use.
- The app should support clear data separation across ventures and projects.
- The app should support future growth into approvals, billing, and expanded team workflows.
- The app should align with a structured internal documentation and development process.

## Assumptions
- The app will begin as an internal tool, not a public SaaS product.
- One image-generation provider is sufficient for V1.
- Users already understand the business context of the ventures they are working in.
- Storage and metadata are as important as image generation itself in the workflow. Creative-ops and DAM guidance strongly support this assumption. [web:63][web:71][web:74]

## Constraints
- The first release must remain narrow enough to build and test quickly.
- The product should fit the team’s preferred code-based workflow in VS Code and GitHub. [cite:18]
- The architecture should remain compatible with Netlify-style frontend deployment and Railway/PostgreSQL-backed app infrastructure where needed. [cite:21][cite:16]

## Screens in V1
1. Dashboard
2. New Job
3. Results Review
4. Project Workspace
5. Asset Library
6. Template Manager
7. Settings

## Acceptance Criteria
### AC1 New job creation
A user can select a venture, select or create a project, choose a job type, enter prompt data, and submit a new generation job. Acceptance criteria should be specific and testable so completion is clear. [web:69][web:72]

### AC2 Results review
After submission, the system shows generated image results in one review view and allows the user to favorite or save at least one result. [web:72]

### AC3 Asset saving
A saved result appears inside the relevant project and in the asset library with venture, project, type, and status metadata.

### AC4 Asset search
A user can filter the asset library by venture and status and open a matching saved asset. DAM systems depend on structured retrieval and workflow states. [web:63][web:74]

### AC5 Approval status
A user can change an asset status from draft to approved and the updated status remains stored on refresh.

### AC6 Export
A user can download a selected saved asset from the interface.

## Future Considerations
- Approval board with richer workflow lanes.
- Team roles and permissions.
- Batch generation.
- Stripe-based paid credits or internal usage tracking.
- Client request portal.
- Multi-provider model routing.
- Advanced print packaging/export sets.

## Open Questions
- What should the internal product name be?
- Which image provider should V1 use first?
- Should “VV-Styles” and “Coloring Books” be separate ventures or job types under one venture structure?
- What file naming convention should exports follow?
- Should print dimensions be template-based or manually configurable in V1?
