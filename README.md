# Prequisite

- Create an project on https://console.cloud.google.com/ and generate credentials

# Configuration

1. Copy .env.example to .env, open .env file
2. Generate operator_token, GOTRUE_JWT_SECRET with command `openssl rand -base64 32`
3. Edit GOTRUE_EXTERNAL_GOOGLE_* with your google credentials
4. Edit POSTGRES_PASSWORD
5. Copy STORAGE_ANON_KEY, STORAGE_SERVICE_KEY to jwt.io, sign it with your JWT_SECRET, and paste it back to .env file
6. Config STORAGE\_\* according to your aws account.

# Installation

```bash
docker-compose up
```
