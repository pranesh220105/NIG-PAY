# College Fee Wallet

Flutter app + Node/Express backend for student fee management.

## Run locally (ngrok/dev)

1. Backend:
```bash
cd backend
npm install
npm run dev
```

2. Flutter:
```bash
flutter pub get
flutter run -d <device_id>
```

## Deploy backend to Render

This repo includes `render.yaml` for one-click Blueprint deploy.

### Option A: Blueprint deploy
1. Push repo to GitHub.
2. In Render, create new Blueprint and select this repo.
3. Render will create:
- Web service `college-fee-wallet-api`
- Postgres database `college-fee-wallet-db`
4. Set `JWT_SECRET` in Render dashboard.

### Option B: Manual service deploy
- Root dir: `backend`
- Build command: `npm install && npm run render-build`
- Start command: `npm start`
- Env:
  - `DATABASE_URL=<render postgres url>`
  - `JWT_SECRET=<strong secret>`
  - `NODE_ENV=production`

## Point Flutter app to Render backend

Run Flutter with:
```bash
flutter run -d <device_id> --dart-define=APP_ENV=prod --dart-define=PROD_BASE_URL=https://<your-render-service>.onrender.com
```

You can also edit defaults in `lib/core/constants/app_constants.dart`.
