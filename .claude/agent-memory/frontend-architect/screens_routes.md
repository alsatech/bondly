---
name: Screens & Routes
description: Completed screens with GoRouter paths and file locations
type: project
---

## Completed Screens

| Screen | Route | File |
|---|---|---|
| SplashScreen | `/` | `lib/features/auth/presentation/screens/splash_screen.dart` |
| LoginScreen | `/auth/login` | `lib/features/auth/presentation/screens/login_screen.dart` |
| RegisterScreen | `/auth/register` | `lib/features/auth/presentation/screens/register_screen.dart` |
| DiscoverScreen | `/home` | `lib/features/discover/presentation/screens/discover_screen.dart` |
| FeedScreen | `/home` (tab 0 of HomeShell) | `lib/features/feed/presentation/screens/feed_screen.dart` |
| CreatePostScreen | `/home/create-post` | `lib/features/posts/presentation/screens/create_post_screen.dart` |
| ProfileScreen | `/home` (tab 2 of HomeShell) | `lib/features/profile/presentation/screens/profile_screen.dart` |

## Router config
File: `lib/core/router/app_router.dart`
Provider: `routerProvider`
Route constants: `AppRoutes` abstract class

## Navigation notes
- GoRouter redirect logic watches `authNotifierProvider` state
- AuthInitial/AuthLoading → stays on splash
- AuthAuthenticated → redirected to /home from splash or /auth/*
- AuthUnauthenticated/AuthError → redirected to /auth/login from non-auth routes
- All transitions: fade (splash/home) or fade+slide (auth screens)
- `/home/create-post` uses slide-from-bottom transition
- FeedScreen has FAB that calls `context.push(AppRoutes.createPost)` and refreshes feed on return
