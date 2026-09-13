-- MOSTIK v5.4.0
-- Final demo enrichment for Байкал.
-- Idempotent: only demo-* records are added/updated.

BEGIN;

UPDATE diets
SET name='Базовый рацион Байкала',
    description='Сбалансированный демонстрационный план: два основных приёма пищи и небольшой дневной перекус. Количество можно корректировать по фактическому аппетиту и активности.',
    active=true,
    target_calories=1350,
    updated_at=now()
WHERE id='demo-diet-baikal';

INSERT INTO observations(
  id,animal_id,author_id,observed_at,behavior_note,health_note,
  arousal,stress,concentration,appetite,pain,sleep,note
)
VALUES
('demo-baikal-obs-34','demo-animal-baikal','demo-owner',now()-interval '28 days','На прогулке Байкал спокоен, охотно следует за проводником и быстро переключается после отвлекающего стимула.','Общее состояние без заметных изменений.',3,2,4,4,1,4,'Демо: стабильная исходная точка.'),
('demo-baikal-obs-35','demo-animal-baikal','demo-keeper',now()-interval '21 days','Байкал активно исследует новую игрушку, сохраняет мягкое возбуждение и легко возвращается к взаимодействию.','Аппетит обычный, признаков дискомфорта не отмечено.',3,1,4,5,1,4,'Демо: хорошая реакция на обогащение среды.'),
('demo-baikal-obs-36','demo-animal-baikal','demo-trainer',now()-interval '14 days','После нескольких повторений Байкал увереннее удерживает позицию и меньше отвлекается на движение вокруг.','Состояние стабильное.',2,1,4,4,1,5,'Демо: промежуточный прогресс тренировки.'),
('demo-baikal-obs-37','demo-animal-baikal','demo-owner',now()-interval '7 days','На спокойной прогулке Байкал быстро откликается на знакомые сигналы и сохраняет устойчивое внимание.','Без заметных изменений.',2,1,5,4,1,5,'Демо: улучшение концентрации.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO sessions(
  id,animal_id,trainer_id,started_at,ended_at,duration_minutes,
  ending_type,ending_other,success_score,external_stimulus,external_reason,
  internal_stimulus,internal_reason,concentration,arousal
)
VALUES
('demo-baikal-session-14','demo-animal-baikal','demo-trainer',now()-interval '12 days',now()-interval '12 days'+interval '20 minutes',20,'успешно','',8,'умеренный','Спокойная прогулка рядом с домом','низкий','Хорошая мотивация к лакомству',4,2),
('demo-baikal-session-15','demo-animal-baikal','demo-trainer',now()-interval '6 days',now()-interval '6 days'+interval '26 minutes',26,'успешно','',9,'низкий','Домашняя спокойная обстановка','низкий','Высокая готовность работать',5,2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO session_skills(session_id,skill_id,repetitions)
VALUES
 ('demo-baikal-session-14','demo-skill-baikal-sit',7),
 ('demo-baikal-session-14','demo-skill-baikal-place',5),
 ('demo-baikal-session-15','demo-skill-baikal-sit',9),
 ('demo-baikal-session-15','demo-skill-baikal-place',7)
ON CONFLICT DO NOTHING;

COMMIT;
