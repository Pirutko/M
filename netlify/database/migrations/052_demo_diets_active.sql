-- MOSTIK v5.3.23: demo diet plans for testing GET /api/diets/active
-- Safe for the current production state: Baikal is intentionally removed by the later demo replacement migration.
-- Migration 052 was not applied in production, so this pending migration is corrected before first application.

-- Keep the original Dymka demo diet, but only create it when its referenced
-- animal and owner exist. This makes the migration safe if demo records were
-- removed manually before deployment.
INSERT INTO diets(id, animal_id, name, description, active, target_calories, created_by)
SELECT
  'demo-diet-dymka',
  a.id,
  'Рацион Дымки',
  'Демо-рацион кошки',
  true,
  250,
  'demo-owner2'
FROM animals a
JOIN users u ON u.id = 'demo-owner2'
WHERE a.id = 'demo-animal-dymka'
ON CONFLICT (id) DO UPDATE SET
  active = true,
  updated_at = now();

UPDATE diets SET active = false
WHERE animal_id = 'demo-animal-dymka'
  AND id <> 'demo-diet-dymka'
  AND active = true;

INSERT INTO diet_periods(id, diet_id, animal_id, start_date, end_date)
SELECT
  'demo-diet-period-dymka',
  'demo-diet-dymka',
  a.id,
  (CURRENT_DATE - 7),
  NULL
FROM animals a
WHERE a.id = 'demo-animal-dymka'
  AND EXISTS (SELECT 1 FROM diets d WHERE d.id = 'demo-diet-dymka')
ON CONFLICT (id) DO UPDATE SET
  start_date = EXCLUDED.start_date,
  end_date = NULL;

INSERT INTO diet_meals(id, diet_id, day_offset, time_of_day, title, sort_order)
SELECT 'demo-meal-dymka-am', 'demo-diet-dymka', 0, '07:30', 'Утро', 0
WHERE EXISTS (SELECT 1 FROM diets WHERE id = 'demo-diet-dymka')
UNION ALL
SELECT 'demo-meal-dymka-pm', 'demo-diet-dymka', 0, '18:30', 'Вечер', 1
WHERE EXISTS (SELECT 1 FROM diets WHERE id = 'demo-diet-dymka')
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  time_of_day = EXCLUDED.time_of_day;

INSERT INTO diet_meal_products(id, meal_id, name, quantity, calories, sort_order)
SELECT 'demo-prod-da1', 'demo-meal-dymka-am', 'Влажный корм для кошек', '80 г', 90, 0
WHERE EXISTS (SELECT 1 FROM diet_meals WHERE id = 'demo-meal-dymka-am')
UNION ALL
SELECT 'demo-prod-dp1', 'demo-meal-dymka-pm', 'Сухой корм для кошек', '40 г', 120, 0
WHERE EXISTS (SELECT 1 FROM diet_meals WHERE id = 'demo-meal-dymka-pm')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  quantity = EXCLUDED.quantity,
  calories = EXCLUDED.calories;
