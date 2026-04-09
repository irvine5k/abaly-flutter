# Abaly ABA Therapy App - Implementation Plan

## Context

Build a mobile-only Flutter app to replace spreadsheet-based ABA session tracking. The app must be faster than spreadsheets, reduce therapist cognitive load, enable structured session tracking, and auto-generate AI clinical summaries. Architecture: MVVM+R with flutter_bloc (Cubit), go_router, and Supabase. Development follows strict TDD.

---

## Supabase Database Schema

Provision these tables before Flutter code connects. All use UUID PKs and `timestamptz` timestamps.

| Table | Key Columns |
|-------|-------------|
| `organizations` | id, name, created_at |
| `profiles` | id (FK auth.users), email, full_name, role (admin/therapist), organization_id |
| `invitations` | id, email, organization_id, invited_by, status (pending/accepted/expired) |
| `patients` | id, full_name, date_of_birth, organization_id, created_by |
| `templates` | id, name, organization_id, fields (jsonb), created_by |
| `sessions` | id, patient_id, template_id, therapist_id, organization_id, status (pending/in_progress/completed), scheduled_at, completed_at |
| `responses` | id, session_id, field_label, field_type, value (text), updated_at |
| `ai_summaries` | id, session_id (unique), summary, created_at |

RLS: Users can only access rows matching their organization_id.

---

## Phase 1 - Project Setup & Auth

### 1.1 Dependencies
- [ ] Add flutter_bloc, equatable, go_router, supabase_flutter to pubspec.yaml
- [ ] Add bloc_test, mocktail to dev_dependencies
- [ ] Run `flutter pub get`

### 1.2 Folder Structure
- [ ] Create `lib/core/{router,supabase,theme}/`
- [ ] Create `lib/features/{auth,home,patients,templates,sessions,organization,ai_summary}/{data,cubit,view}/`
- [ ] Create `lib/shared/{models,widgets}/`
- [ ] Create matching `test/features/` directories

### 1.3 Core Setup
- [ ] `lib/core/supabase/supabase_config.dart` - URL and anon key constants
- [ ] `lib/core/supabase/supabase_init.dart` - `initSupabase()`
- [ ] `lib/core/theme/app_theme.dart` - light theme with clinical feel
- [ ] `lib/core/router/app_router.dart` - GoRouter with routes: /login, /home, /patients, /sessions, /session/:id, /create-session, /templates, /organization
- [ ] Auth redirect logic in router

### 1.4 Auth Feature
- [ ] `lib/shared/models/app_user.dart` - AppUser (id, email, fullName, role, organizationId)
- [ ] `lib/features/auth/data/auth_repository.dart` - abstract interface
- [ ] `lib/features/auth/data/supabase_auth_repository.dart` - Supabase impl
- [ ] `lib/features/auth/cubit/auth_state.dart` - Initial, Loading, Authenticated, Unauthenticated, Error
- [ ] `lib/features/auth/cubit/auth_cubit.dart` - signIn, signUp, signOut, checkAuthStatus
- [ ] `lib/features/auth/view/login_page.dart` - email + password + sign-in
- [ ] `lib/features/auth/view/sign_up_page.dart` - email + password + name

### 1.5 Home Shell
- [ ] `lib/features/home/view/home_page.dart` - bottom nav: Sessions, Patients, Templates, Organization
- [ ] Wire up `main.dart` with MaterialApp.router + BlocProvider<AuthCubit>

### 1.6 Tests
- [ ] `test/features/auth/cubit/auth_cubit_test.dart` - all state transitions
- [ ] `test/features/auth/view/login_page_test.dart` - renders fields, calls cubit

---

## Phase 2 - Core Models & Repositories

### 2.1 Models (all extend Equatable, have fromJson/toJson)
- [ ] `lib/shared/models/organization.dart`
- [ ] `lib/shared/models/patient.dart`
- [ ] `lib/shared/models/template.dart` + `template_field.dart` (FieldType enum: boolean, scale, text)
- [ ] `lib/shared/models/session.dart` + SessionStatus enum
- [ ] `lib/shared/models/response.dart`
- [ ] `lib/shared/models/ai_summary.dart`

### 2.2 Repositories (abstract + Supabase impl for each)
- [ ] `lib/features/patients/data/patient_repository.dart` - getPatients, createPatient, getPatient
- [ ] `lib/features/templates/data/template_repository.dart` - getTemplates, createTemplate, getTemplate
- [ ] `lib/features/sessions/data/session_repository.dart` - getSessions, createSession, getSession, updateSessionStatus
- [ ] `lib/features/sessions/data/response_repository.dart` - getResponses, upsertResponse, upsertResponses
- [ ] `lib/features/ai_summary/data/ai_summary_repository.dart` - getSummary, requestSummary

### 2.3 Tests
- [ ] Model fromJson/toJson round-trip tests for all models

---

## Phase 3 - Sessions Feature (First Vertical Slice, TDD)

### 3.1 Session List (TDD)
- [ ] **TEST FIRST:** `test/features/sessions/cubit/session_list_cubit_test.dart`
- [ ] Implement `session_list_cubit.dart` + `session_list_state.dart`
- [ ] **TEST FIRST:** `test/features/sessions/view/session_list_page_test.dart`
- [ ] Implement `session_list_page.dart`

### 3.2 Create Session (TDD)
- [ ] **TEST FIRST:** `test/features/sessions/cubit/create_session_cubit_test.dart`
- [ ] Implement `create_session_cubit.dart` + `create_session_state.dart`
- [ ] **TEST FIRST:** `test/features/sessions/view/create_session_page_test.dart`
- [ ] Implement `create_session_page.dart`

### 3.3 Session Detail
- [ ] Implement `session_detail_page.dart` - shows session info, status badge, "Start Session" button

---

## Phase 4 - Patients & Templates (TDD)

### 4.1 Patients
- [ ] **TEST FIRST:** patient_list_cubit_test.dart + create_patient_cubit_test.dart
- [ ] Implement cubits
- [ ] **TEST FIRST:** patient_list_page_test.dart
- [ ] Implement patient_list_page.dart + create_patient_page.dart

### 4.2 Templates
- [ ] **TEST FIRST:** template_list_cubit_test.dart + create_template_cubit_test.dart
- [ ] Implement cubits (including addField/removeField for dynamic fields)
- [ ] **TEST FIRST:** template_list_page_test.dart + create_template_page_test.dart
- [ ] Implement views (dynamic field builder: pick type + label, list with remove)

---

## Phase 5 - Organization & Invite (TDD)

- [ ] `lib/features/organization/data/invitation_repository.dart` - sendInvitation, getInvitations, acceptInvitation
- [ ] **TEST FIRST:** organization_cubit_test.dart
- [ ] Implement organization_cubit.dart - loadOrganization, sendInvitation
- [ ] **TEST FIRST:** organization_page_test.dart
- [ ] Implement organization_page.dart - org name, member list, invite form (admin only)
- [ ] Accept invitation flow: on sign-up, check pending invitations, auto-assign org + therapist role

---

## Phase 6 - Session Execution (TDD)

### 6.1 Execution Cubit
- [ ] **TEST FIRST:** session_execution_cubit_test.dart (load, updateResponse, autosave debounce, completeSession, validation)
- [ ] Implement session_execution_cubit.dart + state

### 6.2 Dynamic Form Widgets
- [ ] `boolean_field_widget.dart` - toggle switch
- [ ] `scale_field_widget.dart` - slider 0-5
- [ ] `text_field_widget.dart` - text input
- [ ] `session_field_builder.dart` - factory widget

### 6.3 Execution View
- [ ] **TEST FIRST:** session_execution_page_test.dart
- [ ] Implement session_execution_page.dart - scrollable field list, complete button
- [ ] Autosave: 2s debounce timer, "Saving..."/"Saved" indicator
- [ ] Wire "Start Session" from detail page to execution page

---

## Phase 7 - AI Summary (TDD)

- [ ] Supabase Edge Function `generate-summary`: fetch session data, call LLM, store in ai_summaries
- [ ] **TEST FIRST:** ai_summary_cubit_test.dart (loadSummary, requestSummary)
- [ ] Implement ai_summary_cubit.dart + state
- [ ] **TEST FIRST:** ai_summary_widget_test.dart
- [ ] Implement ai_summary_section.dart - embed in session detail page
- [ ] Auto-trigger: on completeSession(), call requestSummary()

---

## Phase 8 - Polish & Integration

- [ ] Error handling: reusable error_snackbar, user-friendly messages in all cubits
- [ ] Loading states: skeleton loading for lists
- [ ] Empty states: "No sessions/patients/templates yet" with CTAs
- [ ] Navigation guards: therapist vs admin role visibility
- [ ] End-to-end widget tests: create session flow, fill session flow, invite flow

---

## Dependency Graph

```
Phase 1 (Setup + Auth)
  |
Phase 2 (Models + Repos)
  |
  +--------+--------+
  |        |        |
Phase 3  Phase 4  Phase 5
Sessions Patients  Org
         Templates
  |        |
  +--------+
  |
Phase 6 (Session Execution)
  |
Phase 7 (AI Summary)
  |
Phase 8 (Polish)
```

Phases 3, 4, 5 can run in parallel after Phase 2.

---

## Key Implementation Notes

- **TDD:** Write test -> red -> implement -> green -> refactor
- **Repos:** Abstract class + Supabase impl. Cubits only depend on abstract. Mock with mocktail.
- **profiles table:** DB trigger on auth.users INSERT to auto-create profile row, OR insert in signUp()
- **templates.fields:** JSONB column. Example: `[{"label":"Eye Contact","type":"boolean"},{"label":"Notes","type":"text"}]`
- **responses.value:** Always stored as text. Boolean: "true"/"false". Scale: "0"-"5". Parse in Dart model.
- **Autosave:** Timer-based 2s debounce in SessionExecutionCubit. Cancel previous timer on each update.

---

## Verification

After each phase:
1. Run `flutter test` - all tests must pass
2. Run `flutter analyze` - no errors
3. Run app on simulator - verify feature works end-to-end
4. Check Supabase dashboard - verify data persisted correctly
