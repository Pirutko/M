-- MOSTIK v5.4.0
-- Demo data correction for Байкал.
-- Safe/idempotent: updates only demo-* records and does not create duplicate animals.

BEGIN;

-- Demo users: repair previously stored mojibake display names.
UPDATE users SET display_name='Анна Владелец' WHERE id='demo-owner';
UPDATE users SET display_name='Иван Тренер' WHERE id='demo-trainer';
UPDATE users SET display_name='Ольга Кипер' WHERE id='demo-keeper';
UPDATE users SET display_name='Елена Ветеринар' WHERE id='demo-vet';

-- Байкал: keep the existing stable demo animal ID.
UPDATE animals
SET name='Байкал',
    species='Собака',
    breed='Лабрадор-ретривер'
WHERE id='demo-animal-baikal';

-- Demo skills.
UPDATE skills
SET name='Сидеть',
    signal='Сидеть',
    goal='Спокойно выполнять команду «Сидеть» по сигналу человека.'
WHERE id='demo-skill-baikal-sit';

UPDATE skills
SET name='Место',
    signal='Место',
    goal='Уверенно занимать указанное место и оставаться там до разрешения.'
WHERE id='demo-skill-baikal-place';

-- Demo diet.
UPDATE diets
SET name='Рацион Байкала',
    notes='Сбалансированный демонстрационный рацион Байкала. Данные можно редактировать.'
WHERE id='demo-diet-baikal';

-- Correct the most important visible demo observations.
UPDATE observations
SET note='Байкал спокойно исследовал новое обогащение среды, сохранял интерес и быстро возвращался к проводнику.'
WHERE id='demo-baikal-obs-31';

UPDATE observations
SET note='Во время прогулки Байкал сохранял устойчивое внимание, спокойно реагировал на внешние стимулы и охотно включался во взаимодействие.'
WHERE id='demo-baikal-obs-32';

UPDATE observations
SET note='После тренировки Байкал быстро восстановил спокойное состояние, интерес к окружающей среде сохранялся.'
WHERE id='demo-baikal-obs-33';

-- Correct the dedicated demo training session.
UPDATE sessions
SET ending_type='успешно',
    ending_other='',
    external_stimulus='Умеренный шум и прохожие',
    external_reason='Обычная городская обстановка',
    internal_stimulus='Высокая мотивация к лакомству',
    internal_reason='Хорошее рабочее состояние',
    concentration='высокая',
    arousal='умеренное'
WHERE id='demo-baikal-session-13';

COMMIT;
