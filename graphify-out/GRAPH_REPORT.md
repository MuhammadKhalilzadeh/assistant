# Graph Report - .  (2026-06-02)

## Corpus Check
- 191 files · ~131,998 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 382 nodes · 494 edges · 43 communities detected
- Extraction: 87% EXTRACTED · 12% INFERRED · 0% AMBIGUOUS · INFERRED: 60 edges (avg confidence: 0.71)
- Token cost: 0 input · 0 output

## God Nodes (most connected - your core abstractions)
1. `Team Workflow Orchestration` - 11 edges
2. `Ember Dark Design System` - 10 edges
3. `Ember Dark Color System` - 9 edges
4. `Flutter/Dart Code Best Practices Guide` - 8 edges
5. `Dark Theme Design Pattern` - 8 edges
6. `Orange Accent Color System` - 8 edges
7. `SOLID Principles in Flutter/Dart` - 7 edges
8. `StarBank Digital Banking App UI` - 7 edges
9. `FlowPay Finance Management App UI` - 7 edges
10. `Create()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `Core Code Philosophy (Readable, Maintainable, Testable, Performant, Simple)` --semantically_similar_to--> `Ember Dark Design System`  [INFERRED] [semantically similar]
  code/README.md → styles/README.md
- `DevOps Engineer Agent` --semantically_similar_to--> `Integration Testing`  [INFERRED] [semantically similar]
  agents/devops-engineer.md → code/07_testing.md
- `QA Engineer Agent` --semantically_similar_to--> `Testing Guidelines for Flutter`  [INFERRED] [semantically similar]
  agents/qa-engineer.md → code/07_testing.md
- `Technical Lead Agent` --conceptually_related_to--> `SOLID Principles in Flutter/Dart`  [INFERRED]
  agents/technical-lead.md → code/01_solid_principles.md
- `Technical Lead Agent` --conceptually_related_to--> `Architecture Patterns for Flutter`  [INFERRED]
  agents/technical-lead.md → code/05_architecture.md

## Hyperedges (group relationships)
- **Code Quality Standards (SOLID + Clean Code + Dart Style)** — solid_principles, clean_code_principles, dart_style_guide [INFERRED 0.85]
- **Core Leadership Triangle (PM + Tech Lead + Designer)** — agent_product_manager, agent_technical_lead, agent_ux_ui_designer, team_workflow_orchestration [EXTRACTED 1.00]
- **Flutter Application Architecture Stack** — clean_architecture, repository_pattern, dependency_injection, flutter_state_management, feature_based_folders [INFERRED 0.80]
- **Ember Dark Design Token System** — app_theme_dart, colors_color_system, typography_system, spacing_layout_system, components_system, animations_guidelines, dataviz_system [EXTRACTED 1.00]
- **Authentication Flow (OAuth + JWT + Per-User Isolation)** — agent_current_task_google_oauth, agent_current_task_jwt_service, agent_current_task_per_user_isolation, agent_current_task_auth_provider, agent_current_task_http_client_jwt, agent_current_task_crypto_service [EXTRACTED 1.00]
- **User Onboarding UI Flow** — agent_current_task_welcome_signin, agent_current_task_profile_setup, agent_current_task_dashboard_header, agent_current_task_account_sheet [EXTRACTED 1.00]
- **Dark Theme with Orange Accent Mobile Design System** — design_pattern_dark_theme, design_pattern_orange_accent, design_pattern_bottom_navigation, design_pattern_card_based_layout, sample1_real_estate_app, sample2_shipping_tracker_app, sample3_starbank_app, sample4_flowpay_app, sample5_astrology_app, sample6_networking_app, sample7_fintech_ui_kit [INFERRED 0.90]
- **Fintech and Banking App Design Cluster** — sample3_starbank_app, sample4_flowpay_app, sample7_fintech_ui_kit, sample3_account_dashboard, sample4_statistics_screen, sample7_overview_chart [INFERRED 0.85]
- **Financial Data Visualization with Bar Charts** — sample3_account_dashboard, sample4_statistics_screen, sample7_overview_chart [INFERRED 0.85]

## Communities

### Community 0 - "Data Models & Database"
Cohesion: 0.04
Nodes (3): ensureDatabaseExists(), initializeDatabase(), runMigrations()

### Community 1 - "Backend Controllers & Services"
Cohesion: 0.07
Nodes (10): authMiddleware(), getOrCreateDevUser(), AppError, ConflictError, DatabaseError, ForbiddenError, NotFoundError, RateLimitError (+2 more)

### Community 2 - "API Routes & Validation"
Cohesion: 0.07
Nodes (4): validate(), validateBody(), validateParams(), validateQuery()

### Community 3 - "Ember Dark Design System"
Cohesion: 0.06
Nodes (37): ProfileSetupPage, WelcomeSignInPage, Task: Font Contrast + Calendar Perf + Settings/Profile + AI Chat, Glow Pulse Animation (2s Breathing Cycle), Animation Guidelines, Shimmer Loading Effect, AppTheme (Source of Truth for Design Tokens), Core Code Philosophy (Readable, Maintainable, Testable, Performant, Simple) (+29 more)

### Community 4 - "UI Sample Designs"
Cohesion: 0.1
Nodes (31): Dark Theme Design Pattern, Orange Accent Color System, Property Detail Screen - Lacrosse Estates, Property Search Screen - DProperties, Real Estate Property App UI, Shipping App Onboarding Screen, Recent Shipping Orders List Screen, Smart Shipping Tracker App UI (+23 more)

### Community 5 - "Desktop Platform Runners"
Cohesion: 0.1
Nodes (2): GetCommandLineArguments(), Utf8FromUtf16()

### Community 6 - "Win32 Window Management"
Cohesion: 0.16
Nodes (16): Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle(), GetWindowClass(), MessageHandler(), OnCreate() (+8 more)

### Community 7 - "Agent Team & Testing"
Cohesion: 0.2
Nodes (18): DevOps Engineer Agent, Junior Backend Developer Agent, Junior Frontend Developer Agent, Mid-Level Backend Developer Agent, Mid-Level Frontend Developer Agent, Product Manager Agent, QA Engineer Agent, Senior Backend Developer Agent (+10 more)

### Community 8 - "Architecture & SOLID"
Cohesion: 0.2
Nodes (14): Architecture Patterns for Flutter, Clean Architecture (Presentation-Domain-Data layers), Dependency Injection (GetIt, Provider), Feature-Based Folder Structure, Rationale: Clean Architecture Dependency Rule, Rationale: DIP Enables Testability and Implementation Swapping, Clean Architecture by Robert C. Martin, Repository Pattern (+6 more)

### Community 9 - "Orchestration & Code Guidelines"
Cohesion: 0.17
Nodes (12): 8-Phase Software Delivery Lifecycle, API Contract Protocol (Backend-First), Master Orchestration Prompt (11 AI Agents), Wave-Based Parallelism Model, Clean Architecture, Repository, Service Patterns, Flutter/Dart Code Best Practices Guide, Clean Code (DRY, KISS, YAGNI), Effective Dart Style (+4 more)

### Community 10 - "Jarvis AI Chat"
Cohesion: 0.25
Nodes (0): 

### Community 11 - "Flutter Patterns & Performance"
Cohesion: 0.25
Nodes (8): Flutter Patterns and Widget Composition, State Management Patterns (Provider, Riverpod, setState), Widget Lifecycle (initState, dispose, didUpdateWidget), Build Method Optimization (const, avoid heavy computation), Flutter Performance Best Practices, Isolates for Heavy Computation, List Performance (ListView.builder, itemExtent, pagination), Memory Management (dispose, mounted check, image caching)

### Community 12 - "Auth Implementation"
Cohesion: 0.25
Nodes (8): User Authentication + Gmail/Inbox Integration (Complete), AuthNotifier (StateNotifier) Provider, AES-256-GCM Encryption for Gmail Tokens, Gmail Integration (Server-Side), Google OAuth 2.0 Authentication, HTTP Client with Bearer JWT + Token Refresh, JWT Session Management Service, Per-User Data Isolation (27 Tables)

### Community 13 - "Clean Code Principles"
Cohesion: 0.29
Nodes (7): DRY - Don't Repeat Yourself, KISS - Keep It Simple Stupid, Clean Code Principles for Flutter/Dart, YAGNI - You Aren't Gonna Need It, Rationale: KISS - Avoid Over-Engineering, Clean Code by Robert C. Martin, The Pragmatic Programmer by Hunt and Thomas

### Community 14 - "Android MainActivity"
Cohesion: 0.33
Nodes (1): MainActivity

### Community 15 - "macOS AppDelegate"
Cohesion: 0.33
Nodes (2): AppDelegate, FlutterAppDelegate

### Community 16 - "Plugin Registration"
Cohesion: 0.5
Nodes (1): GeneratedPluginRegistrant

### Community 17 - "Flutter LLDB Helper"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 18 - "iOS Runner Tests"
Cohesion: 0.5
Nodes (2): RunnerTests, XCTestCase

### Community 19 - "macOS Main Window"
Cohesion: 0.5
Nodes (2): MainFlutterWindow, NSWindow

### Community 20 - "Wave Execution Rationale"
Cohesion: 1.0
Nodes (2): Rationale: Wave-Based Parallel Execution, Wave-Based Execution Model

### Community 21 - "Dashboard & Account UI"
Cohesion: 1.0
Nodes (2): AccountSheet + Sign Out Dialogs, Dashboard Greeting Header + Avatar

### Community 22 - "Android Build Config"
Cohesion: 1.0
Nodes (0): 

### Community 23 - "Gradle Settings"
Cohesion: 1.0
Nodes (0): 

### Community 24 - "iOS Bridging Header"
Cohesion: 1.0
Nodes (0): 

### Community 25 - "Express Type Defs"
Cohesion: 1.0
Nodes (0): 

### Community 26 - "Project README"
Cohesion: 1.0
Nodes (1): Assistant Flutter Project

### Community 27 - "Team Workflow Lifecycle"
Cohesion: 1.0
Nodes (1): Workflow Lifecycle (REQUEST-DEFINE-DESIGN-PLAN-BUILD-TEST-REVIEW-DEPLOY-RETROSPECT)

### Community 28 - "Quality Gates"
Cohesion: 1.0
Nodes (1): Quality Gates (G1-G8)

### Community 29 - "Multi-Agent Plan"
Cohesion: 1.0
Nodes (1): MULTI_AGENT_PLAN.md Shared Artifact

### Community 30 - "Dart Style Guide"
Cohesion: 1.0
Nodes (1): Effective Dart Style Guide

### Community 31 - "Launch Image Config"
Cohesion: 1.0
Nodes (1): iOS Launch Screen Assets Configuration

### Community 32 - "Spacing Tokens"
Cohesion: 1.0
Nodes (1): Spacing Tokens (XS 4px to XXL 48px)

### Community 33 - "Border Radius Tokens"
Cohesion: 1.0
Nodes (1): Border Radius Tokens

### Community 34 - "Empty State Pattern"
Cohesion: 1.0
Nodes (1): Empty State Pattern

### Community 35 - "Animation Duration Tokens"
Cohesion: 1.0
Nodes (1): Animation Duration Tokens (100ms-8000ms)

### Community 36 - "Card Entrance Animation"
Cohesion: 1.0
Nodes (1): Card Entrance Animation (Staggered Fade+Slide)

### Community 37 - "Animation Decision Tree"
Cohesion: 1.0
Nodes (1): Animation Decision Tree

### Community 38 - "Data Viz Gauge"
Cohesion: 1.0
Nodes (1): Single-Metric Gauge Component

### Community 39 - "Data Viz Bar Chart"
Cohesion: 1.0
Nodes (1): Bar Chart Styling

### Community 40 - "Data Viz Line Chart"
Cohesion: 1.0
Nodes (1): Line Chart Styling

### Community 41 - "Bottom Navigation Pattern"
Cohesion: 1.0
Nodes (1): Bottom Navigation Bar Pattern

### Community 42 - "Card Layout Pattern"
Cohesion: 1.0
Nodes (1): Card-Based Content Layout Pattern

## Ambiguous Edges - Review These
- `Mobile App UI with Orange Theme - Blurred` → `Orange Accent Color System`  [AMBIGUOUS]
  samples/sample-8.jpg · relation: implements
- `Mobile App UI with Orange Theme - Blurred` → `Dark Theme Design Pattern`  [AMBIGUOUS]
  samples/sample-8.jpg · relation: implements

## Knowledge Gaps
- **84 isolated node(s):** `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `Assistant Flutter Project`, `Workflow Lifecycle (REQUEST-DEFINE-DESIGN-PLAN-BUILD-TEST-REVIEW-DEPLOY-RETROSPECT)`, `Quality Gates (G1-G8)`, `Wave-Based Execution Model` (+79 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Wave Execution Rationale`** (2 nodes): `Rationale: Wave-Based Parallel Execution`, `Wave-Based Execution Model`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Dashboard & Account UI`** (2 nodes): `AccountSheet + Sign Out Dialogs`, `Dashboard Greeting Header + Avatar`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Android Build Config`** (1 nodes): `build.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Gradle Settings`** (1 nodes): `settings.gradle.kts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `iOS Bridging Header`** (1 nodes): `Runner-Bridging-Header.h`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Express Type Defs`** (1 nodes): `express.d.ts`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Project README`** (1 nodes): `Assistant Flutter Project`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Team Workflow Lifecycle`** (1 nodes): `Workflow Lifecycle (REQUEST-DEFINE-DESIGN-PLAN-BUILD-TEST-REVIEW-DEPLOY-RETROSPECT)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Quality Gates`** (1 nodes): `Quality Gates (G1-G8)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Multi-Agent Plan`** (1 nodes): `MULTI_AGENT_PLAN.md Shared Artifact`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Dart Style Guide`** (1 nodes): `Effective Dart Style Guide`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Launch Image Config`** (1 nodes): `iOS Launch Screen Assets Configuration`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Spacing Tokens`** (1 nodes): `Spacing Tokens (XS 4px to XXL 48px)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Border Radius Tokens`** (1 nodes): `Border Radius Tokens`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Empty State Pattern`** (1 nodes): `Empty State Pattern`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Animation Duration Tokens`** (1 nodes): `Animation Duration Tokens (100ms-8000ms)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Card Entrance Animation`** (1 nodes): `Card Entrance Animation (Staggered Fade+Slide)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Animation Decision Tree`** (1 nodes): `Animation Decision Tree`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Data Viz Gauge`** (1 nodes): `Single-Metric Gauge Component`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Data Viz Bar Chart`** (1 nodes): `Bar Chart Styling`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Data Viz Line Chart`** (1 nodes): `Line Chart Styling`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Bottom Navigation Pattern`** (1 nodes): `Bottom Navigation Bar Pattern`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Card Layout Pattern`** (1 nodes): `Card-Based Content Layout Pattern`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What is the exact relationship between `Mobile App UI with Orange Theme - Blurred` and `Orange Accent Color System`?**
  _Edge tagged AMBIGUOUS (relation: implements) - confidence is low._
- **What is the exact relationship between `Mobile App UI with Orange Theme - Blurred` and `Dark Theme Design Pattern`?**
  _Edge tagged AMBIGUOUS (relation: implements) - confidence is low._
- **Why does `Ember Dark Design System` connect `Ember Dark Design System` to `Orchestration & Code Guidelines`?**
  _High betweenness centrality (0.009) - this node is a cross-community bridge._
- **Why does `Master Orchestration Prompt (11 AI Agents)` connect `Orchestration & Code Guidelines` to `Ember Dark Design System`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **Are the 7 inferred relationships involving `Dark Theme Design Pattern` (e.g. with `Real Estate Property App UI` and `Smart Shipping Tracker App UI`) actually correct?**
  _`Dark Theme Design Pattern` has 7 INFERRED edges - model-reasoned connections that need verification._
- **What connects `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `Assistant Flutter Project`, `Workflow Lifecycle (REQUEST-DEFINE-DESIGN-PLAN-BUILD-TEST-REVIEW-DEPLOY-RETROSPECT)` to the rest of the system?**
  _84 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Data Models & Database` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._