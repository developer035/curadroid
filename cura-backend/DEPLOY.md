# Deploying CuraTrail LLM Coach Proxy

## Render.com (Free Tier)
1. Push this repository to GitHub.
2. Log into Render.com and create a new **Web Service**.
3. Connect your GitHub repository.
4. Settings:
   - **Environment**: Node
   - **Build Command**: `npm install && npm run build`
   - **Start Command**: `npm start`
5. Environment Variables:
   - `PORT` = `3000` (Render will override this, which is fine)
   - `LLM_PROVIDER` = `gemini`
   - `GEMINI_API_KEY` = `your-api-key`
   - `DAILY_GLOBAL_CAP` = `1000`
   - `RATE_LIMIT_PER_MINUTE` = `10`
6. Click **Create Web Service**.

## Fly.io (Free Tier)
1. Install `flyctl`.
2. Run `fly launch` in the root of this project.
3. Fly will automatically detect the Dockerfile (or you can let it use the Node.js buildpack).
4. Do NOT set up a Postgres/Redis database if asked (unless you want persistent rate limits).
5. Set your secrets: `fly secrets set GEMINI_API_KEY="your-api-key"`
6. Deploy: `fly deploy`

## Local Development
1. Create a `.env` file based on `.env.example`.
2. Run `npm install`.
3. Run `npm run dev`.
4. The server runs on `http://localhost:3000`.
1`