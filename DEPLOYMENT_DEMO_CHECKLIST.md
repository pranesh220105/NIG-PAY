# College Fee Wallet - Deployment and Demo Checklist

## 1) Backend hosting (Render/Railway/Fly)

### Render (recommended quick path)
1. Use Blueprint deploy with `render.yaml` (recommended), or create service manually from `backend`.
2. Manual build command:
`npm install && npm run render-build`
3. Manual start command:
`npm start`
4. Add environment variables:
- `JWT_SECRET=<strong-secret>`
- `DATABASE_URL=<cloud-postgres-url>`
- `NODE_ENV=production`

## 2) Database migration to cloud Postgres

1. Provision Postgres (Render Postgres, Railway Postgres, Neon, Supabase, etc.).
2. In `backend/prisma/schema.prisma`, change datasource to:
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```
3. Initialize schema:
`npx prisma db push`
4. Verify tables are created and app can login/register.

## 3) Flutter env switching (dev/prod)

The app supports compile-time env switching through `AppConstants`.

- Dev run:
`flutter run --dart-define=APP_ENV=dev --dart-define=DEV_BASE_URL=https://<your-ngrok-or-dev-url>`
- Prod run:
`flutter run --dart-define=APP_ENV=prod --dart-define=PROD_BASE_URL=https://<your-hosted-backend>`

## 4) Build APK/AAB

### Debug APK
`flutter build apk --debug`

### Release APK
`flutter build apk --release --dart-define=APP_ENV=prod --dart-define=PROD_BASE_URL=https://<prod-url>`

### Release AAB (Play Store)
`flutter build appbundle --release --dart-define=APP_ENV=prod --dart-define=PROD_BASE_URL=https://<prod-url>`

## 5) Submission UI assets

Add:
- App icon (1024x1024 source)
- Splash screen background + logo
- Branded color palette and typography tokens

Recommended packages:
- `flutter_launcher_icons`
- `flutter_native_splash`

## 6) Demo video plan (2-4 minutes)

Record these flows:
1. Admin login
2. Create student
3. Set semester fee + due date + fine
4. Mark partial/paid
5. Student login
6. Dashboard real-time totals
7. Payment flow + instant dashboard update
8. History and receipts
9. Auto logout on token expiry/401
10. Dark mode + loading skeleton states

## 7) Screenshot checklist

Capture and submit:
1. Login screen
2. Student dashboard (with semester breakdown)
3. Payment form
4. Payment history
5. Receipts
6. Admin controls
7. Dark theme view
