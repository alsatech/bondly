# Tech Debt — Bondly Frontend

Bugs, shortcuts, and deferred work. Each entry: **what**, **why**, **where**, **proposed fix**, **target milestone**.

---

## Onboarding / Auth

### 1. Hardcoded interests list (Music, Fitness, Coffee, …)
- **What:** `_availableInterests` in `lib/features/auth/presentation/screens/register_screen.dart` is a static Dart constant mirroring the backend `interests` table.
- **Why:** No public `GET /api/v1/interests` endpoint exists yet, so we cannot fetch the catalog dynamically. Hardcoding lets us ship the onboarding flow now.
- **Risk:** Every time product wants to add/remove/rename a tag, we need a frontend release. If backend and frontend drift, users either miss options or create duplicate tags (bypassing the shared catalog).
- **Fix:** Add backend endpoint `GET /api/v1/interests` returning `[{id, name, category}]`. Frontend fetches on step 3 mount, caches in memory, shows a loader on cold start. Group chips by `category`.
- **Target:** MVP v2.

### 2. Profile photo upload is not wired end-to-end
- **What:** `AuthRepository._uploadProfilePhoto` sends `multipart/form-data` to `POST /api/v1/users/me/photos`, but the backend endpoint expects a JSON body with an already-uploaded URL (`PhotoCreate` schema).
- **Why:** No upload service yet (S3/Cloudinary/GCS). We kept the multipart call wrapped in a best-effort try/catch so registration still succeeds.
- **Risk:** Photo picked during signup is silently discarded. User lands on Home with no avatar.
- **Fix:** Either (a) add a backend multipart endpoint that streams to object storage and returns the URL, or (b) use presigned URLs: backend returns upload URL, frontend PUTs the file, then backend receives the final URL via `POST /photos`. Option (b) scales better.
- **Target:** MVP v2 (photos are P1 for a dating app).

### 3. Age input instead of birth date
- **What:** Register step 1 asks for an integer `Edad` and the frontend synthesizes `birth_date` as `today - age years`.
- **Why:** Faster UI to ship; backend requires a real date.
- **Risk:** Synthesized date is wrong for everyone whose birthday has not yet occurred this year — their stored `birth_date` will be off by up to ~1 year. Distorts any age-range filter built on top of `birth_date`.
- **Fix:** Replace the age `TextFormField` with a `DatePicker` (min age 18 enforced via `firstDate`/`lastDate`). Send the real date.
- **Target:** MVP v2, before any matching/discovery feature that filters by age.

### 4. No logout UI anywhere in the app
- **What:** Tokens are persisted in `flutter_secure_storage`, so once a user signs in they stay logged in across app restarts. There is no button or gesture to call `AuthNotifier.logout()`.
- **Why:** Deferred until the Home screen exists — didn't want to put a temporary button on the `_HomePlaceholder` and then throw it away.
- **Risk:** During development, the only way to test the login flow is to clear app data from the emulator. For QA, hard to hand a build to someone without a way to sign out.
- **Fix:** Add a "Cerrar sesión" action in the Home AppBar (or Settings when that exists) that calls `ref.read(authNotifierProvider.notifier).logout()`. The router redirect will send them back to `/auth/login` automatically.
- **Target:** Ship with the first Home screen iteration (not a separate milestone).

### 5. Interest step UX does not enforce "min 3"
- **What:** Step 3 label says "Selecciona al menos 3 intereses" but the submit button does not block on count; backend accepts 1+.
- **Why:** Oversight during multi-step wiring.
- **Fix:** Either drop the copy to "1 o más" (match backend rule) or add a validator before `_submit()`.
- **Target:** Polish pass before v1.0.

---

## Networking

### 6. Error mapping conflates 400 and 409 as `EmailAlreadyInUse`
- **What:** `AuthRepository._mapDioException` returns `EmailAlreadyInUse` for both HTTP 400 and 409.
- **Why:** Early stub before backend error contract was stabilized.
- **Risk:** Any 400 from the backend (generic validation error) is shown as "email ya registrado" — confusing for users hitting a password-strength failure, etc.
- **Fix:** Only map 409 to `EmailAlreadyInUse`. For 400/422 surface the `detail` field from the response verbatim or map known codes.
- **Target:** Before v1.0.

### 7. Router rebuilds on every auth state change
- **What:** `routerProvider` watches `authNotifierProvider` and rebuilds the whole `GoRouter` instance on each state transition.
- **Why:** Simplest way to plumb auth state into routing without `ChangeNotifier`.
- **Risk:** Loses in-flight navigation state (e.g. pushed modal routes). Each rebuild resets to `initialLocation`. Works today because the graph is small.
- **Fix:** Use `GoRouter`'s `refreshListenable` with a `ValueNotifier` bumped by `ref.listen(authNotifierProvider, …)`. Router instance stays stable; only the redirect re-runs.
- **Target:** Before adding nested flows (chat, onboarding completion, etc.).

---

## Coupling with backend

### 8. `Interest.name` capitalization mismatch
- **What:** Backend repo `get_or_create` stores interest names in lowercase, but seed data was inserted capitalized (`Music`, `Fitness`). Required a one-off `UPDATE interests SET name = LOWER(name);`.
- **Why:** Initial seed did not respect the documented invariant.
- **Risk (already mitigated):** Duplicate rows (`Music` vs `music`) breaking matching by shared interests.
- **Fix:** Either enforce lowercase at the DB level (citext column or `CHECK (name = LOWER(name))`) or normalize in the repo's `get_or_create` query (`WHERE LOWER(name) = :name`). The schema comment must not be the only source of truth.
- **Target:** Backend — before first user data migration.

---

## How to use this file

- Add an entry when we take a shortcut we know we'll pay for later. Don't wait until it breaks.
- Remove an entry when the fix ships, and link the PR in the commit message.
- If an item grows beyond a paragraph, promote it to an issue and link it here.
