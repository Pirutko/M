# MOSTIK — локальный сервер

## Вариант A: свой Postgres (проще всего)

1. Установите PostgreSQL 14+ (или Docker):
   ```bash
   docker run --name mostik-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=mostik -p 5432:5432 -d postgres:16
   ```

2. В корне проекта скопируйте env:
   ```bash
   cp .env.example .env
   ```
   В `.env` укажите:
   ```env
   DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/mostik
   ```

3. Примените миграции (по порядку):
   ```bash
   # если есть psql:
   for f in netlify/database/migrations/*.sql; do
     psql "$DATABASE_URL" -f "$f" || exit 1
   done
   ```
   Либо откройте GUI (pgAdmin / DBeaver) и выполните файлы `001` … `042`.

4. Установите зависимости и запустите:
   ```bash
   npm install
   npx netlify dev
   ```
   Сайт: http://localhost:8888  
   Health: http://localhost:8888/api/health  → `"db":"up"`

5. Демо-вход (после `004_demo_seed.sql`):
   - `demo.owner@mostik.local` / `demo123`
   - `demo.trainer@mostik.local` / `demo123`
   - `demo.keeper@mostik.local` / `demo123`
   - `demo.vet@mostik.local` / `demo123`

## Вариант B: Netlify Database через CLI

1. `npm i -g netlify-cli`
2. `netlify login`
3. `netlify link` — привяжите сайт, где уже включена Database
4. `netlify env:pull` — подтянет переменные (в т.ч. URL БД)
5. `netlify dev`

## Если «Ошибка базы данных»

| Симптом | Что сделать |
|---------|-------------|
| `db":"down"` в /api/health | Проверьте `DATABASE_URL` в `.env`, что Postgres запущен |
| `relation "users" does not exist` | Не применены миграции — выполните SQL 001→042 |
| `password authentication failed` | Неверный логин/пароль в URL |
| `ECONNREFUSED 127.0.0.1:5432` | Postgres не слушает порт 5432 |
| Работает `netlify dev`, но API 502 | Смотрите терминал, где запущен `netlify dev` |

## Важно

- Файл `.env` **не коммитьте** (уже в `.gitignore`).
- Cookie сессии `Secure` на `http://localhost` может вести себя иначе; при проблемах с логином проверьте, что API отвечает с `/api/auth/login`.
