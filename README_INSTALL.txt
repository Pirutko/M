MOSTIK patch v5.3.23 — diets/active 404 fix + demo diets
========================================================

Содержимое
----------
netlify/functions/api.mjs     — исправленный API (версия 5.3.23)
api.mjs                       — зеркало корня (если используете)
package.json                  — version 5.3.23
netlify/database/migrations/052_demo_diets_active.sql
PATCH_NOTES_v5.3.23.txt
scripts/test_diets_active.sh
docs/templates/diets_active_responses.md

Установка в репозиторий
-----------------------
1. Скопируйте файлы поверх проекта MOSTIK (сохраняя пути):
     cp netlify/functions/api.mjs  <repo>/netlify/functions/api.mjs
     cp api.mjs                    <repo>/api.mjs   # опционально
     cp package.json               <repo>/package.json
     cp netlify/database/migrations/052_demo_diets_active.sql \
        <repo>/netlify/database/migrations/

2. Commit + push в main (Netlify задеплоит сам):
     git add netlify/functions/api.mjs api.mjs package.json \
             netlify/database/migrations/052_demo_diets_active.sql
     git commit -m "fix(api): diets/active 404 (v5.3.23)"
     git push

3. Миграция БД (Netlify Database / Neon SQL Editor):
     выполните содержимое 052_demo_diets_active.sql целиком.

4. Проверка:
     BASE=https://mostikik.netlify.app ./scripts/test_diets_active.sh
   или вручную: войти demo.owner@mostik.local / demo123,
   открыть животное «Байкал», Network → diets/active → 200.

Без миграции 052 API после фикса всё равно отдаёт 200 {active:null,meals:[]}
вместо 404 — этого достаточно, чтобы убрать ошибку в консоли.
