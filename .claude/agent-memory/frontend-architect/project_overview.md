---
name: Project Overview
description: Bondly app tech stack, base URL, theme constraints, and current build state
type: project
---

Bondly is a dating + social app (ages 17–34, Americas). Flutter MVP with dark theme only.

**Stack**: Flutter + Riverpod (NotifierProvider) + Dio + GoRouter + flutter_secure_storage + google_fonts + shimmer + image_picker + cached_network_image + equatable

**Base URL (dev)**: `https://such-platypus-pox.ngrok-free.dev`
- Always add header `ngrok-skip-browser-warning: true` in Dio BaseOptions

**Auth**: Bearer JWT via Dio interceptor (AuthInterceptor). Auto-refresh on 401 using refresh_token from secure storage.

**Theme**: Dark only in V1. Background #0F0F12, card #1C1C22, border #2A2A33. Primary #FF5A5F, Accent #6C63FF.

**Fonts**: Playfair Display (headlines/display), DM Sans (body/UI) — via google_fonts.

**Current state**: Auth module complete (splash, login, register multi-step). Home is a placeholder. Other features not yet started.

**Why:** MVP scope — dark only, no over-engineering, strict feature-first folder structure.
**How to apply:** Always verify theme is dark-only. No light theme variants. Read skills.md before any new screen.
