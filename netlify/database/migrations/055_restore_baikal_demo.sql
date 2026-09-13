-- MOSTIK v5.3.x — restore the Baikal demo dataset after duplicate cleanup.
-- Idempotent: only touches demo-* records and safely recreates missing demo records.
BEGIN;

INSERT INTO users(id,email,display_name,password_hash,role) VALUES
('demo-owner','demo.owner@mostik.local','Анна Владелец','mostik-demo-salt:ff50cbd1457ea36cb28d033c6d310dec8f10c665cfac01a03847c0a2a31cbbe3','owner'),
('demo-trainer','demo.trainer@mostik.local','Илья Тренер','mostik-demo-salt:ff50cbd1457ea36cb28d033c6d310dec8f10c665cfac01a03847c0a2a31cbbe3','trainer'),
('demo-keeper','demo.keeper@mostik.local','Олег Кипер','mostik-demo-salt:ff50cbd1457ea36cb28d033c6d310dec8f10c665cfac01a03847c0a2a31cbbe3','keeper'),
('demo-vet','demo.vet@mostik.local','Елена Ветеринар','mostik-demo-salt:ff50cbd1457ea36cb28d033c6d310dec8f10c665cfac01a03847c0a2a31cbbe3','vet')
ON CONFLICT (id) DO NOTHING;

INSERT INTO animals(id,name,species,breed,owner_id)
VALUES ('demo-animal-baikal','Байкал','Собака','Лабрадор-ретривер','demo-owner')
ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name,
  species=EXCLUDED.species,
  breed=EXCLUDED.breed,
  owner_id=EXCLUDED.owner_id;

INSERT INTO animal_access(user_id,animal_id) VALUES
('demo-trainer','demo-animal-baikal'),
('demo-keeper','demo-animal-baikal'),
('demo-vet','demo-animal-baikal')
ON CONFLICT DO NOTHING;

INSERT INTO skills(id,animal_id,name,signal,goal) VALUES
('demo-skill-baikal-sit','demo-animal-baikal','Сидеть','Сидеть','Спокойно выполнять сигнал'),
('demo-skill-baikal-place','demo-animal-baikal','Место','Место','Оставаться на коврике')
ON CONFLICT (id) DO UPDATE SET
  animal_id=EXCLUDED.animal_id,
  name=EXCLUDED.name,
  signal=EXCLUDED.signal,
  goal=EXCLUDED.goal;

INSERT INTO skill_steps(id,skill_id,step_no,title,goal,criterion,bridge,reinforcement,reinforcement_other,reinforcement_schedule) VALUES
('demo-step-1','demo-skill-baikal-sit',1,'Захват положения','Сесть по сигналу','Садится сразу','кликер','пищевое','','постоянный'),
('demo-step-2','demo-skill-baikal-sit',2,'Увеличение выдержки','Сохранять положение','5 секунд','кликер','игровое','','переменный'),
('demo-step-3','demo-skill-baikal-place',1,'Заход на коврик','Самостоятельно зайти','4 из 5 попыток','жест','пищевое','','постоянный')
ON CONFLICT (id) DO NOTHING;

INSERT INTO sessions(id,animal_id,trainer_id,started_at,ended_at,duration_minutes,ending_type,ending_other,success_score,external_stimulus,external_reason,internal_stimulus,internal_reason,concentration,arousal)
VALUES
('demo-baikal-session-14','demo-animal-baikal','demo-trainer',now()-interval '12 days',now()-interval '12 days'+interval '20 minutes',20,'успешно','',8,'умеренный','Спокойная прогулка рядом с домом','низкий','Хорошая мотивация к лакомству',4,2),
('demo-baikal-session-15','demo-animal-baikal','demo-trainer',now()-interval '6 days',now()-interval '6 days'+interval '26 minutes',26,'успешно','',9,'низкий','Домашняя спокойная обстановка','низкий','Высокая готовность работать',5,2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO session_skills(session_id,skill_id,repetitions) VALUES
('demo-baikal-session-14','demo-skill-baikal-sit',7),
('demo-baikal-session-14','demo-skill-baikal-place',5),
('demo-baikal-session-15','demo-skill-baikal-sit',9),
('demo-baikal-session-15','demo-skill-baikal-place',7)
ON CONFLICT DO NOTHING;

INSERT INTO observations(id,animal_id,author_id,observed_at,behavior_note,health_note,arousal,stress,concentration,appetite,pain,sleep,note)
VALUES
('demo-baikal-obs-34','demo-animal-baikal','demo-owner',now()-interval '28 days','На прогулке Байкал спокоен, охотно следует за проводником и быстро переключается после отвлекающего стимула.','Общее состояние без заметных изменений.',3,2,4,4,1,4,'Демо: стабильная исходная точка.'),
('demo-baikal-obs-35','demo-animal-baikal','demo-keeper',now()-interval '21 days','Байкал активно исследует новую игрушку, сохраняет мягкое возбуждение и легко возвращается к взаимодействию.','Аппетит обычный, признаков дискомфорта не отмечено.',3,1,4,5,1,4,'Демо: хорошая реакция на обогащение среды.'),
('demo-baikal-obs-36','demo-animal-baikal','demo-trainer',now()-interval '14 days','После нескольких повторений Байкал увереннее удерживает позицию и меньше отвлекается на движение вокруг.','Состояние стабильное.',2,1,4,4,1,5,'Демо: промежуточный прогресс тренировки.'),
('demo-baikal-obs-37','demo-animal-baikal','demo-owner',now()-interval '7 days','На спокойной прогулке Байкал быстро откликается на знакомые сигналы и сохраняет устойчивое внимание.','Без заметных изменений.',2,1,5,4,1,5,'Демо: улучшение концентрации.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO homework(id,animal_id,trainer_id,skill_id,title,instructions,due_date,status)
VALUES
('demo-hw-1','demo-animal-baikal','demo-trainer','demo-skill-baikal-sit','Сидеть дома','3 подхода по 5 повторений. Заканчивать на успешном повторе, поощрение сразу после выполнения.',current_date+3,'active'),
('demo-hw-2','demo-animal-baikal','demo-trainer','demo-skill-baikal-place','Место на коврике','Тренировать 5 минут вечером. Постепенно увеличивать дистанцию до коврика.',current_date+5,'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO vet_records(id,animal_id,vet_id,record_type,note,medication_name,dosage,frequency,start_date,end_date,instructions)
VALUES
('demo-vet-1','demo-animal-baikal','demo-vet','prescription','Контроль состояния после нагрузки','Омега-3','1 капсула','1 раз в день с кормом',current_date-10,current_date+20,'Наблюдать аппетит и стул.'),
('demo-vet-2','demo-animal-baikal','demo-vet','note','Общее состояние стабильное',NULL,NULL,NULL,NULL,NULL,'Плановый контроль через 2 недели.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO diets(id,animal_id,name,description,active,target_calories,created_by)
VALUES ('demo-diet-baikal','demo-animal-baikal','Базовый рацион Байкала','Сбалансированный демонстрационный план: два основных приёма пищи и небольшой дневной перекус. Количество можно корректировать по фактическому аппетиту и активности.',true,1350,'demo-keeper')
ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name,
  description=EXCLUDED.description,
  active=true,
  target_calories=EXCLUDED.target_calories,
  updated_at=now();

UPDATE diets SET active=false
WHERE animal_id='demo-animal-baikal' AND id<>'demo-diet-baikal' AND active=true;

INSERT INTO diet_periods(id,diet_id,animal_id,start_date,end_date)
VALUES ('demo-diet-period-baikal','demo-diet-baikal','demo-animal-baikal',current_date-30,NULL)
ON CONFLICT (id) DO UPDATE SET start_date=EXCLUDED.start_date,end_date=NULL;

INSERT INTO diet_meals(id,diet_id,day_offset,time_of_day,title,sort_order) VALUES
('demo-meal-baikal-breakfast','demo-diet-baikal',0,'08:00','Завтрак',0),
('demo-meal-baikal-lunch','demo-diet-baikal',0,'13:00','Обед',1),
('demo-meal-baikal-dinner','demo-diet-baikal',0,'19:00','Ужин',2)
ON CONFLICT (id) DO UPDATE SET time_of_day=EXCLUDED.time_of_day,title=EXCLUDED.title,sort_order=EXCLUDED.sort_order;

INSERT INTO diet_meal_products(id,meal_id,name,quantity,calories,sort_order) VALUES
('demo-prod-b1','demo-meal-baikal-breakfast','Сухой корм премиум','150 г',450,0),
('demo-prod-b2','demo-meal-baikal-breakfast','Вода','свежая',NULL,1),
('demo-prod-l1','demo-meal-baikal-lunch','Влажный корм','100 г',280,0),
('demo-prod-d1','demo-meal-baikal-dinner','Сухой корм премиум','120 г',360,0),
('demo-prod-d2','demo-meal-baikal-dinner','Лакомство тренировочное','10 г',40,1)
ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name,quantity=EXCLUDED.quantity,calories=EXCLUDED.calories,sort_order=EXCLUDED.sort_order;

INSERT INTO food_logs(id,animal_id,author_id,logged_at,meal,offered,eaten,not_eaten,appetite,note)
VALUES
('demo-baikal-food-1','demo-animal-baikal','demo-keeper',now()-interval '3 days','Утро','Сухой корм премиум 150 г','100%','Ничего',5,'Демо: аппетит хороший.'),
('demo-baikal-food-2','demo-animal-baikal','demo-keeper',now()-interval '2 days','Вечер','Влажный корм 100 г','90%','Небольшая часть',4,'Демо: съел почти весь рацион.'),
('demo-baikal-food-3','demo-animal-baikal','demo-owner',now()-interval '1 day','Утро','Сухой корм премиум 150 г','100%','Ничего',5,'Демо: рацион принят полностью.')
ON CONFLICT (id) DO NOTHING;

COMMIT;
