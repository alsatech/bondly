# Project Skills — Bondly Frontend (Flutter)

## Product Vision
Bondly is a hybrid dating + social network app.
Target: ages 17–34, Americas region.
Feel: modern, attractive, emotional — like Hinge meets Instagram.

---

## Tech Stack
- **Framework**: Flutter (Dart)
- **Design System**: Material 3
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **WebSockets**: web_socket_channel
- **Storage**: flutter_secure_storage (JWT tokens)
- **Navigation**: GoRouter
- **Image**: cached_network_image

---

## Backend API
- Base URL: `https://such-platypus-pox.ngrok-free.dev` (development)
- Auth: JWT Bearer token in Authorization header
- All business logic lives in backend — frontend is display only

---

## Brand & Design System

### Color Palette

```dart
// Emotional (Branding)
static const primary     = Color(0xFFFF5A5F);
static const primaryHover= Color(0xFFFF7A7F);

// Action (CTAs)
static const accent      = Color(0xFF6C63FF);
static const accentHover = Color(0xFF8B85FF);
static const success     = Color(0xFF2ECC71); // match moment

// Neutral Base (UX)
static const background  = Color(0xFF0F0F12);
static const card        = Color(0xFF1C1C22);
static const border      = Color(0xFF2A2A33);
static const textPrimary = Color(0xFFFFFFFF);
static const textSecondary = Color(0xFFB0B0B8);
```

### Swipe UX
- Swipe right (like) → verde `#2ECC71`
- Swipe left (pass) → gris suave / soft red
- Match moment → gradient coral + purple + animación ligera (dopamine hit)

### Typography
- Display / Headlines: **Playfair Display** (elegante, emocional)
- Body / UI: **DM Sans** (legible, moderno)

### Tone
- Dark theme always (fondo `#0F0F12`)
- Cards con glassmorphism suave
- Bordes sutiles `#2A2A33`
- Animaciones ligeras: fade, slide, scale — nunca pesadas

---

## App Structure

```
lib/
├── core/
│   ├── constants/        # colors, typography, strings
│   ├── router/           # GoRouter config
│   ├── network/          # Dio client, interceptors
│   └── storage/          # secure storage, token management
├── features/
│   ├── auth/             # login, register, splash
│   ├── profile/          # ver/editar perfil, fotos, intereses
│   ├── feed/             # posts, likes
│   ├── discover/         # matching, swipe cards
│   ├── chat/             # conversaciones, WebSocket
│   ├── events/           # listar, crear, unirse
│   └── notifications/    # lista de notificaciones
├── shared/
│   ├── widgets/          # componentes reutilizables
│   └── models/           # DTOs / response models
└── main.dart
```

---

## Architecture Rules
- Feature-first folder structure
- No business logic en widgets — solo UI
- Toda lógica en providers (Riverpod)
- Repositorios hacen llamadas HTTP con Dio
- JWT se guarda en flutter_secure_storage
- Refresh token automático en Dio interceptor
- Never hardcode data

---

## Navigation (GoRouter)
```
/splash
/auth/login
/auth/register
/home          → bottom nav shell
  /feed
  /discover
  /chat
  /notifications
  /profile
```

---

## API Modules (ya implementados en backend)
- Auth: `/api/v1/auth/`
- Profile: `/api/v1/users/`
- Posts: `/api/v1/posts/`
- Follows: `/api/v1/follows/`
- Matching: `/api/v1/matches/`
- Chat: `/api/v1/conversations/` + WebSocket `ws://`
- Events: `/api/v1/events/`
- Notifications: `/api/v1/notifications/`

---

## MVP Screen List (V1 strict scope)
1. Splash / onboarding
2. Login
3. Register (multi-step)
4. Home Feed
5. Discover (swipe cards)
6. Profile (own)
7. Profile (other user)
8. Edit Profile
9. Chat list
10. Chat room (WebSocket)
11. Events list
12. Event detail
13. Notifications

---

## Development Rules
- Always read this skills.md before starting any screen
- Never generate backend code
- Never hardcode API responses
- Use shimmer loading states
- Handle errors gracefully (show snackbars, not crashes)
- All screens must be responsive (phone only for MVP)
- Dark theme only in V1
- Do NOT over-engineer — MVP minimal
