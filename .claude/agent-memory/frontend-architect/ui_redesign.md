---
name: UI Redesign 2026-04-30
description: Summary of which screens were redesigned, visual decisions made, and files changed during the design-ref-driven UI overhaul
type: project
---

## Redesign scope (2026-04-30)

Design references were in `design_refs/` (feed x4, post x5, profile x2; no discover refs).

**Why:** Align production app with Bondly visual identity — editorial typography, gold founder accents, drop-cap captions, bond-index layout.

**How to apply:** When touching feed/post/discover/profile screens, follow conventions established here; do not revert to the old card layout.

---

## Files changed per screen

### Feed (`lib/features/feed/presentation/`)
- `widgets/feed_app_bar.dart` — "Bondly." now white (textPrimary) not coral; increased font to 28px
- `widgets/feed_tabs.dart` — pill chips with border; Founders tab gets diamond icon; active = white pill with black text
- `widgets/post_header.dart` — username as "first.last" format; "+ BOND" text CTA replaces overflow menu; time shown inline
- `widgets/post_card.dart` — Complete rewrite: left-edge vertical like column; PLACE/category in caps + Playfair location name; square image left + drop-cap text right; THREADS / REPLY / SHARE text actions at bottom; bookmark icon right
- `screens/feed_screen.dart` — Removed horizontal card padding (edge-to-edge cards); kept FAB

### Create Post (`lib/features/posts/presentation/`)
- `screens/create_post_screen.dart` — Full rewrite: full-bleed photo at top with overlay "CANCEL | New Bond. | DRAFT" bar; WHAT IS THIS BOND WITH? type chips (PLACE/BRAND/EVENT/RESTAURANT); search field + recent row; caption with drop-cap hint + char counter; soundtrack as track card or two input fields; audience selector (Public/Circles/Founders) with radio tiles; gold gradient SHARE BOND CTA button

### Discover (`lib/features/discover/presentation/`)
- `widgets/discover_card.dart` — Steeper gradient for readability; gold affinity badge with star icon; larger Playfair name (34px); cleaner swipe stamps
- `widgets/discover_action_button.dart` — Skip button gets border; reduced glow alpha
- `screens/discover_screen.dart` — AppBar title now Playfair "Discover"; filter icon added to actions

### Profile (`lib/features/profile/presentation/`) — NEW FEATURE
- Created from scratch (no existing profile feature). Entirely presentation-only.
- `screens/profile_screen.dart` — Full scroll layout matching refs
- `widgets/profile_header.dart` — ♦ FOUNDER badge; large Playfair name; vol watermark; gold dash subtitle; bio
- `widgets/profile_stats_row.dart` — BONDS | CIRCLE | FOUNDER TIES in italic Playfair
- `widgets/profile_patterns_section.dart` — 2-col insight cards with § PATTERNS header
- `widgets/profile_bonds_section.dart` — Numbered bond index list (No01…No04) with category, Playfair title, subtitle

### Core
- `core/constants/app_colors.dart` — Added `gold = Color(0xFFC8A97E)` and `goldDark = Color(0xFF9C7A4E)`
- `core/layout/home_shell.dart` — Added Profile as third nav tab (person icon)

---

## Visual decisions (ambiguous refs)

- **Post card layout**: ref shows location name only (no full image when no caption). Chose image-left + text-right for richer layout; degrades gracefully to full-width image or full-width caption when one is missing.
- **Discover refs absent**: No discover/ images found. Applied consistent design language (gold badge, deeper gradient) without changing swipe mechanics.
- **Profile — no backend**: Profile feature had no provider/repo. Built pure presentation-only screen with placeholder data. Thumbnail slots in bond index show icon placeholders.
- **Recent locations in Create Post**: Shown as static UI chips (Bellweather Coffee, Cape Formentor, Atelier Nord from ref). They populate the search field on tap — no API call.
- **"Founders only" audience toggle**: Maps to `isPrivate = true` since no separate founders-only backend field exists yet.

---

## What was intentionally skipped

- Filter / audio filters (ONYX, CINDER, VELLUM, TIDE shown in CreatePost3 ref) — no backend field for this; skipped to keep MVP lean
- "Sign this bond with your insignia" / FOUNDER OPTION toggle (CreatePost4 ref) — no backend field; skipped
- Profile events section (§ EVENTS 02 visible at bottom of profile2.png) — cut from MVP to avoid over-engineering
- Light theme — not implemented per V1 constraint

---

## Untouched

- All auth screens (login, register, splash)
- All models, providers, repositories, services, API clients
- GoRouter config (only `home_shell.dart` added the Profile tab; router itself unchanged)
