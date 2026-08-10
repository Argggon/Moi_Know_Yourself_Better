---
name: moi
description: Moi Daily Self-Discovery Agent Skill - Manages dynamic anti-duplicate questioning (3:3:1 ratio), incremental user profile consolidation, monthly poetic letter generation, and Ask decision guidance.
---

# Moi – Daily Self-Discovery Skill

Moi (French for "Me") is a minimal daily self-discovery engine. It acts as a mirror—reflecting without judging.

This Skill coordinates three core capabilities:
1. **Daily Question Generation (`01_daily_question.md`)**: Generates non-repetitive, context-aware daily questions balanced across a 3:3:1 depth ratio (Light:Medium:Deep).
2. **Monthly Story & Profile Update (`02_monthly_story.md`)**: Incremental memory consolidation. Takes 30 days of raw logs + existing internal user profile (`user_profile.json`), updating the profile and writing a warm, poetic monthly letter (`Story_YYYY_MM.md`).
3. **Ask Decision Guidance (`03_ask_guidance.md`)**: Takes user dilemmas, cross-references user profile & past quotes, and delivers a firm, empathetic stance with mandatory reflection prompt.

---

## Directory & Component Map

- `schemas/user_profile.json`: Schema for the internal structured user profile (values, traits, growth notes).
- `schemas/asked_questions.json`: Schema for historical question fingerprints (prevents duplicates).
- `prompts/01_daily_question.md`: System prompt for daily question generation.
- `prompts/02_monthly_story.md`: System prompt for monthly letter & profile update.
- `prompts/03_ask_guidance.md`: System prompt for Ask decision synthesis.
- `mock/test_dataset.json`: Pre-populated 30-day mock dataset for fast-forward testing.

---

## Workflow Commands

### 1. `daily-question`
**Purpose**: Generate today's question.
**Input Context Required**:
- `today_date` & `day_of_week` (e.g. `Wednesday, July 19`)
- `weather_context` (optional, e.g. `Rainy 18°C, Shanghai`)
- `asked_questions_history` (from `asked_questions.json`)
- `yesterday_user_answer` (optional, if user wants a follow-up)

**Execution Rule**: Read `prompts/01_daily_question.md`, output valid JSON containing the new question, assigned depth level, and fingerprint tag.

---

### 2. `monthly-story`
**Purpose**: Run at the end of a 30-day period / monthly story day.
**Input Context Required**:
- `user_profile.json` (Existing internal profile, can be empty in Month 1)
- `month_raw_logs.json` (30 days of Q&As + spontaneous thoughts)

**Execution Rule**: Read `prompts/02_monthly_story.md`, output two distinct JSON payloads:
1. `updated_user_profile`: The newly consolidated internal persona.
2. `monthly_story_letter`: The user-facing letter in poetic, warm narrative style.

---

### 3. `ask-guidance`
**Purpose**: Answer a user's decision dilemma.
**Input Context Required**:
- `user_dilemma`: The core question (e.g., "Should I quit my job?")
- `user_profile.json`: Current internal user profile
- `relevant_past_quotes`: (Pro version) 2-3 past verbatim statements retrieved from raw logs

**Execution Rule**: Read `prompts/03_ask_guidance.md`, output a firm stance + evidence + mandatory reflection line:
> *"If this doesn’t feel right, maybe you already know a different answer."*
