---
name: Auth Module
description: Complete auth feature architecture — providers, repository, models, endpoints
type: project
---

## Folder: lib/features/auth/

### Data layer
- `data/models/auth_tokens.dart` — AuthTokens (access_token, refresh_token)
- `data/models/user_model.dart` — UserModel with flexible fromJson (supports id/_id, name/full_name keys)
- `data/models/register_request.dart` — RegisterRequest for multi-step form
- `data/auth_repository.dart` — AuthRepository with login(), register(), refreshToken(), getMe(), logout()

### Domain layer
- `domain/auth_failure.dart` — Sealed class: InvalidCredentials, EmailAlreadyInUse, NetworkFailure, ServerFailure, TokenExpired, UnknownFailure

### Presentation/providers
- `presentation/providers/auth_providers.dart` — secureStorageProvider, dioProvider, authRepositoryProvider
- `presentation/providers/auth_notifier.dart` — AuthNotifier (NotifierProvider), AuthState sealed class, currentUserProvider

### AuthState variants
- AuthInitial, AuthLoading, AuthAuthenticated(user), AuthUnauthenticated, AuthError(failure)

## Endpoints consumed
- POST /api/v1/auth/login → { access_token, refresh_token }
- POST /api/v1/auth/register → { access_token, refresh_token }
- POST /api/v1/auth/refresh → { access_token, refresh_token }
- GET  /api/v1/auth/me → { user: {...} } or { data: {...} } or flat

## Core network
- `lib/core/network/dio_client.dart` — DioClient.create(storage) factory
- `lib/core/network/auth_interceptor.dart` — AuthInterceptor (injects Bearer, auto-refresh 401)
- `lib/core/storage/secure_storage.dart` — SecureStorageService (saveTokens, getAccessToken, getRefreshToken, clearTokens, hasValidToken)

## Register flow (multi-step)
- Step 1: name, email, age, gender (chips), password, confirm password
- Step 2: profile photo via image_picker (optional/skippable)
- Step 3: interests (chips from predefined list of 15)
- Photo uploaded after register via POST /api/v1/users/me/photo (multipart)
