# Persona Mirror API v1

## Auth
- `POST /api/v1/auth/google` -> `{ id_token }` -> `{ access_token, user }`

## Scenarios
- `GET /api/v1/scenarios` -> `{ scenarios }`
- `POST /api/v1/scenarios` -> `{ title, context, category }` -> `{ scenario }`
- `GET /api/v1/scenarios/templates` -> `{ templates }`

## Sessions
- `POST /api/v1/sessions` -> `{ scenario_id }` -> `{ session, first_message }`
- `GET /api/v1/sessions/:sessionId` -> `{ session, messages }`
- `POST /api/v1/sessions/:sessionId/message` -> `{ content }` -> `{ message }`
- `PATCH /api/v1/sessions/:sessionId/end` -> `{ status, analysis }`

## Analysis
- `POST /api/v1/sessions/:sessionId/analyse` -> `{ analysis }`
- `GET /api/v1/sessions/:sessionId/analyse` -> `{ analysis }`
