# 🧠 AI-First PRD — ABA Mobile App (Agent-Executable)

## 1. 🎯 Product Goal

Build a **mobile-only Flutter app** to replace spreadsheet-based ABA session tracking.

The system must:
- Be faster than spreadsheets
- Reduce therapist cognitive load
- Enable structured session tracking
- Automatically generate clinical summaries via AI

---

## 2. ⚙️ Engineering Principles (MANDATORY)

### 2.1 TDD (Test-Driven Development)
The agent MUST:

1. Write failing tests first
2. Implement minimal code to pass tests
3. Refactor safely

No feature is complete without:
- Unit tests (ViewModel/Cubit)
- Widget tests (user flows)

---

### 2.2 Plan → Execute → Validate Loop

The agent MUST:

1. Create an implementation plan before coding
2. Break work into small, testable tasks
3. Execute tasks sequentially
4. Validate via tests before moving forward

No ad-hoc coding allowed.

---

### 2.3 Simplicity First

- Avoid abstraction unless necessary
- Prefer duplication over premature generalization
- Optimize for readability and speed

---

## 3. 🏗️ Architecture — MVVM + Repository (MVVM+R)

### Layers:

#### 📦 Model
- Pure data structures
- No business logic

#### 🧠 ViewModel (Cubit)
- State management using `flutter_bloc`
- Handles UI logic and orchestration

#### 🎨 View
- Flutter widgets
- No business logic
- Reacts to state changes

#### 🔌 Repository
- Data access layer
- Communicates with Supabase

---

### Architecture Flow

View → ViewModel (Cubit) → Repository → Supabase  
                         → emits state → View updates  

---

## 4. 🧱 Core Features (MVP)

### 4.1 Organization & Invite AT
- Admin can invite users via email
- User joins organization

---

### 4.2 Patient Management
- Create patient
- View patient list

---

### 4.3 Templates
- Create template with:
  - boolean
  - scale (0–5)
  - text

---

### 4.4 Sessions
- Create session
- Assign therapist
- Track status

---

### 4.5 Session Execution
- Therapist fills session data
- Autosave responses
- Complete session

---

### 4.6 AI Summary
- Triggered after completion
- Generated via Edge Function

---

## 5. 🧠 Data Model (Simplified)

- Organization
- User
- Patient
- Template
- Session
- Response
- AiSummary

(All stored in Supabase)

---

## 6. 🧪 Testing Strategy

## 6.1 Unit Tests (Cubit)

Test:
- State transitions
- Business logic
- Error handling

---

## 6.2 Widget Tests (CRITICAL)

Focus on **user behavior**, not implementation.

### Required Flows:

#### ✅ Create Session Flow
- User navigates to create session
- Fills required fields
- Submits
- Sees session in list

---

#### ✅ Invite AT Flow
- Admin enters email
- Sends invite
- Confirmation appears

---

#### ✅ Fill Session Flow
- Therapist opens session
- Inputs data
- Completes session
- Sees confirmation

---

### Rules:
- No testing internal widget structure
- Test user-visible behavior only

---

## 7. 📱 Feature Modules (Flutter)
lib/
├── core/
├── features/
│    ├── auth/
│    ├── organization/
│    ├── patients/
│    ├── templates/
│    ├── sessions/
│    ├── ai_summary/
├── shared/

---

## 8. 🔁 State Management (flutter_bloc)

Each feature has:

- Cubit
- State
- Repository

Example:

SessionCubit:
- createSession()
- loadSessions()
- completeSession()

---

## 9. 🧭 Navigation (go_router)

Routes:

- /login
- /home
- /patients
- /sessions
- /session/:id
- /create-session

---

## 10. 🧠 AI Integration

### Flow:
1. Session completed
2. Backend Edge Function triggered
3. LLM generates summary
4. Stored in DB
5. UI fetches and displays

---

## 11. 📋 Agent Execution Plan

## Phase 1 — Setup

- Initialize Flutter project
- Setup Supabase
- Configure auth
- Setup routing (go_router)
- Setup bloc structure

---

## Phase 2 — Core Models + Repositories

- Define models
- Implement repositories
- Connect to Supabase

---

## Phase 3 — Sessions Feature (First Vertical Slice)

TDD Order:

1. Write widget test → create session flow
2. Implement UI
3. Implement Cubit
4. Implement Repository
5. Make test pass

---

## Phase 4 — Organization / Invite

Same TDD cycle:
- Test → Implement → Pass

---

## Phase 5 — Session Execution

- Widget test for filling session
- Implement dynamic form rendering

---

## Phase 6 — AI Summary

- Implement Edge Function
- Integrate into app

---

## 12. 🚫 Constraints (Do NOT Violate)

- No skipping tests
- No complex abstractions
- No premature optimization
- No over-engineering

---

## 13. ✅ Definition of Done

A feature is complete only if:

- Tests exist and pass
- Code follows MVVM+R
- UI is usable with one hand
- Flow is validated end-to-end

---

## 14. 📊 Success Metric

- Session entry time < 60 seconds
- Zero training required for therapists

---

## 15. 🧭 Final Principle

This is not a “system”.

This is a **tool used during real therapy sessions**.

If it slows the therapist down, it fails.
