-- MOSTIK v5.4 — replace the old Baikal demo with five fresh demo animals.
-- Migration 056 is still pending in production, so this file is corrected before first application.
-- Idempotent: only touches demo-* records.
BEGIN;

-- Remove the old Baikal demo in FK-safe order.
DELETE FROM session_skills WHERE session_id IN (SELECT id FROM sessions WHERE animal_id='demo-animal-baikal');
DELETE FROM sessions WHERE animal_id='demo-animal-baikal';
DELETE FROM skill_steps WHERE skill_id IN (SELECT id FROM skills WHERE animal_id='demo-animal-baikal');
DELETE FROM skills WHERE animal_id='demo-animal-baikal';
DELETE FROM homework WHERE animal_id='demo-animal-baikal';
DELETE FROM vet_records WHERE animal_id='demo-animal-baikal';
DELETE FROM food_logs WHERE animal_id='demo-animal-baikal';
DELETE FROM observations WHERE animal_id='demo-animal-baikal';
DELETE FROM diet_meal_products WHERE meal_id IN (SELECT id FROM diet_meals WHERE diet_id IN (SELECT id FROM diets WHERE animal_id='demo-animal-baikal'));
DELETE FROM diet_meals WHERE diet_id IN (SELECT id FROM diets WHERE animal_id='demo-animal-baikal');
DELETE FROM diet_periods WHERE animal_id='demo-animal-baikal';
DELETE FROM diets WHERE animal_id='demo-animal-baikal';
DELETE FROM animal_access WHERE animal_id='demo-animal-baikal';
DELETE FROM animals WHERE id='demo-animal-baikal';

-- Five fresh animals.
INSERT INTO animals(id,name,species,breed,owner_id) VALUES
('demo-animal-archie','Арчи','Собака','Золотистый ретривер','demo-owner'),
('demo-animal-nora','Нора','Кошка','Мейн-кун','demo-owner2'),
('demo-animal-filya','Филя','Кролик','Карликовый баран','demo-owner3'),
('demo-animal-rocky','Рокки','Птица','Корелла','demo-owner4'),
('demo-animal-sonya','Соня','Черепаха','Среднеазиатская черепаха','demo-owner5')
ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name,species=EXCLUDED.species,breed=EXCLUDED.breed,owner_id=EXCLUDED.owner_id;

INSERT INTO animal_access(user_id,animal_id) VALUES
('demo-trainer','demo-animal-archie'),('demo-trainer','demo-animal-nora'),('demo-trainer','demo-animal-filya'),('demo-trainer','demo-animal-sonya'),
('demo-trainer2','demo-animal-archie'),('demo-trainer2','demo-animal-rocky'),
('demo-keeper','demo-animal-archie'),('demo-keeper','demo-animal-nora'),('demo-keeper','demo-animal-filya'),('demo-keeper','demo-animal-rocky'),('demo-keeper','demo-animal-sonya'),
('demo-vet','demo-animal-archie'),('demo-vet','demo-animal-nora'),('demo-vet','demo-animal-filya'),('demo-vet','demo-animal-rocky'),('demo-vet','demo-animal-sonya'),
('demo-vet2','demo-animal-archie'),('demo-vet2','demo-animal-sonya')
ON CONFLICT DO NOTHING;

-- Two training skills per animal.
INSERT INTO skills(id,animal_id,name,signal,goal) VALUES
('demo-skill-archie-sit','demo-animal-archie','Сидеть','Сидеть','Спокойно выполнять сигнал'),
('demo-skill-archie-place','demo-animal-archie','Место','Место','Оставаться на коврике'),
('demo-skill-nora-carrier','demo-animal-nora','Переноска','В переноску','Спокойно заходить в переноску'),
('demo-skill-nora-touch','demo-animal-nora','Контакт','Касание','Спокойно переносить осмотр'),
('demo-skill-filya-hand','demo-animal-filya','Подход к руке','Ко мне','Спокойно подходить к ладони'),
('demo-skill-filya-brush','demo-animal-filya','Расчёска','Стоять','Спокойно переносить уход'),
('demo-skill-rocky-hand','demo-animal-rocky','Шаг на руку','Шаг','Спокойно переходить на руку'),
('demo-skill-rocky-target','demo-animal-rocky','Таргет','Таргет','Следовать за мишенью'),
('demo-skill-sonya-touch','demo-animal-sonya','Контакт','Касание','Спокойно переносить осмотр'),
('demo-skill-sonya-station','demo-animal-sonya','Станция','На место','Спокойно оставаться на станции')
ON CONFLICT (id) DO UPDATE SET animal_id=EXCLUDED.animal_id,name=EXCLUDED.name,signal=EXCLUDED.signal,goal=EXCLUDED.goal;

INSERT INTO skill_steps(id,skill_id,step_no,title,goal,criterion,bridge,reinforcement,reinforcement_other,reinforcement_schedule) VALUES
('demo-step-archie-1','demo-skill-archie-sit',1,'Захват положения','Сесть по сигналу','4 из 5','кликер','пищевое','','постоянный'),
('demo-step-archie-2','demo-skill-archie-place',1,'Заход на коврик','Самостоятельно зайти','4 из 5','жест','пищевое','','постоянный'),
('demo-step-nora-1','demo-skill-nora-carrier',1,'Подход к переноске','Подойти без избегания','3 спокойных подхода','звук','пищевое','','постоянный'),
('demo-step-nora-2','demo-skill-nora-touch',1,'Касание','Не отдёргиваться','10 секунд','жест','пищевое','','переменный'),
('demo-step-filya-1','demo-skill-filya-hand',1,'Нос к руке','Подойти к ладони','4 из 5','нет','пищевое','','постоянный'),
('demo-step-filya-2','demo-skill-filya-brush',1,'Спокойный уход','Стоять рядом с расчёской','20 секунд','жест','пищевое','','переменный'),
('demo-step-rocky-1','demo-skill-rocky-hand',1,'Шаг на руку','Поставить лапу','3 из 4','жест','игровое','','переменный'),
('demo-step-rocky-2','demo-skill-rocky-target',1,'Следование за мишенью','Коснуться мишени','4 из 5','звук','пищевое','','постоянный'),
('demo-step-sonya-1','demo-skill-sonya-touch',1,'Спокойное касание','Не втягиваться','10 секунд','жест','пищевое','','постоянный'),
('demo-step-sonya-2','demo-skill-sonya-station',1,'Станция','Оставаться на месте','30 секунд','жест','пищевое','','переменный')
ON CONFLICT (id) DO NOTHING;

-- Three sessions per animal, with valid 1-5 concentration/arousal values.
INSERT INTO sessions(id,animal_id,trainer_id,started_at,ended_at,duration_minutes,ending_type,ending_other,success_score,external_stimulus,external_reason,internal_stimulus,internal_reason,concentration,arousal)
SELECT 'demo-new-session-'||a.code||'-'||n,a.id,
       CASE WHEN n%2=0 THEN 'demo-trainer2' ELSE 'demo-trainer' END,
       now()-((n*8+a.ord)||' days')::interval,
       now()-((n*8+a.ord)||' days')::interval+interval '25 minutes',25,
       'успешно','',6+n,'низкий','Обычная обстановка','низкий','Хорошая мотивация',
       3+(n%3),2+(n%2)
FROM (VALUES
 ('archie','demo-animal-archie',1),('nora','demo-animal-nora',2),('filya','demo-animal-filya',3),('rocky','demo-animal-rocky',4),('sonya','demo-animal-sonya',5)
) AS a(code,id,ord),generate_series(1,3) AS n
ON CONFLICT (id) DO NOTHING;

INSERT INTO session_skills(session_id,skill_id,repetitions)
SELECT 'demo-new-session-'||a.code||'-'||n,CASE WHEN n%2=1 THEN a.skill1 ELSE a.skill2 END,5+n
FROM (VALUES
 ('archie','demo-skill-archie-sit','demo-skill-archie-place'),('nora','demo-skill-nora-carrier','demo-skill-nora-touch'),('filya','demo-skill-filya-hand','demo-skill-filya-brush'),('rocky','demo-skill-rocky-hand','demo-skill-rocky-target'),('sonya','demo-skill-sonya-touch','demo-skill-sonya-station')
) AS a(code,skill1,skill2),generate_series(1,3) AS n
ON CONFLICT DO NOTHING;

-- Four observations per animal. All numeric ratings stay within the schema's 1-5 checks.
INSERT INTO observations(id,animal_id,author_id,observed_at,behavior_note,health_note,arousal,stress,concentration,appetite,pain,sleep,note)
SELECT 'demo-new-obs-'||a.code||'-'||n,a.id,
       CASE WHEN n%3=0 THEN 'demo-keeper' WHEN n%3=1 THEN 'demo-owner' ELSE 'demo-trainer' END,
       now()-((n*7+a.ord)||' days')::interval,
       CASE WHEN n<3 THEN 'Спокойно исследует окружение и постепенно привыкает к новой задаче' ELSE 'Уверенно взаимодействует с человеком и быстрее возвращает внимание к задаче' END,
       'Без заметных изменений.',2+(n%3),1+(n%3),2+(n%3),3+(n%2),1,3+(n%3),
       'Демонстрационная запись наблюдения'
FROM (VALUES
 ('archie','demo-animal-archie',1),('nora','demo-animal-nora',2),('filya','demo-animal-filya',3),('rocky','demo-animal-rocky',4),('sonya','demo-animal-sonya',5)
) AS a(code,id,ord),generate_series(1,4) AS n
ON CONFLICT (id) DO NOTHING;

INSERT INTO homework(id,animal_id,trainer_id,skill_id,title,instructions,due_date,status) VALUES
('demo-new-hw-archie','demo-animal-archie','demo-trainer','demo-skill-archie-sit','Сидеть дома','3 подхода по 5 повторений.',current_date+3,'active'),
('demo-new-hw-nora','demo-animal-nora','demo-trainer','demo-skill-nora-carrier','Спокойная переноска','Открытая переноска и поощрение добровольного подхода.',current_date+5,'active'),
('demo-new-hw-filya','demo-animal-filya','demo-trainer','demo-skill-filya-hand','Подход к руке','Короткие добровольные подходы к ладони.',current_date+4,'active'),
('demo-new-hw-rocky','demo-animal-rocky','demo-trainer2','demo-skill-rocky-hand','Шаг на руку','Два коротких подхода в спокойной комнате.',current_date+4,'active'),
('demo-new-hw-sonya','demo-animal-sonya','demo-trainer','demo-skill-sonya-touch','Спокойный контакт','Короткие касания без удержания.',current_date+6,'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO vet_records(id,animal_id,vet_id,record_type,note,medication_name,dosage,frequency,start_date,end_date,instructions) VALUES
('demo-new-vet-archie','demo-animal-archie','demo-vet','note','Общее состояние стабильное',NULL,NULL,NULL,NULL,NULL,'Плановый контроль.'),
('demo-new-vet-nora','demo-animal-nora','demo-vet','prescription','Профилактическое наблюдение','Препарат А','по инструкции','1 раз в день',current_date,current_date+7,'Давать после еды.'),
('demo-new-vet-filya','demo-animal-filya','demo-vet','note','Аппетит и активность сохранены',NULL,NULL,NULL,NULL,NULL,'Контролировать потребление сена.'),
('demo-new-vet-rocky','demo-animal-rocky','demo-vet2','prescription','Плановый витаминный курс','Витамины B','по инструкции','1 раз в сутки',current_date,current_date+10,'Не сочетать с другими комплексами.'),
('demo-new-vet-sonya','demo-animal-sonya','demo-vet','note','Активность соответствует обычной',NULL,NULL,NULL,NULL,NULL,'Следить за аппетитом и сном.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO diets(id,animal_id,name,description,active,target_calories,created_by) VALUES
('demo-diet-archie','demo-animal-archie','Рацион Арчи','Демонстрационный рацион собаки.',true,1450,'demo-keeper'),
('demo-diet-nora','demo-animal-nora','Рацион Норы','Демонстрационный рацион кошки.',true,280,'demo-keeper'),
('demo-diet-filya','demo-animal-filya','Рацион Фили','Сено как основа, зелень и гранулы.',true,220,'demo-keeper'),
('demo-diet-rocky','demo-animal-rocky','Рацион Рокки','Зерновая смесь и овощи.',true,90,'demo-keeper'),
('demo-diet-sonya','demo-animal-sonya','Рацион Сони','Зелень и овощи.',true,120,'demo-keeper')
ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name,description=EXCLUDED.description,active=true,target_calories=EXCLUDED.target_calories,updated_at=now();

INSERT INTO diet_periods(id,diet_id,animal_id,start_date,end_date) VALUES
('demo-diet-period-archie','demo-diet-archie','demo-animal-archie',current_date-20,NULL),
('demo-diet-period-nora','demo-diet-nora','demo-animal-nora',current_date-20,NULL),
('demo-diet-period-filya','demo-diet-filya','demo-animal-filya',current_date-20,NULL),
('demo-diet-period-rocky','demo-diet-rocky','demo-animal-rocky',current_date-20,NULL),
('demo-diet-period-sonya','demo-diet-sonya','demo-animal-sonya',current_date-20,NULL)
ON CONFLICT (id) DO UPDATE SET start_date=EXCLUDED.start_date,end_date=NULL;

INSERT INTO diet_meals(id,diet_id,day_offset,time_of_day,title,sort_order) VALUES
('demo-meal-archie-am','demo-diet-archie',0,'08:00','Утро',0),('demo-meal-archie-pm','demo-diet-archie',0,'19:00','Вечер',1),
('demo-meal-nora-am','demo-diet-nora',0,'08:00','Утро',0),('demo-meal-nora-pm','demo-diet-nora',0,'18:30','Вечер',1),
('demo-meal-filya-am','demo-diet-filya',0,'09:00','Утро',0),('demo-meal-filya-pm','demo-diet-filya',0,'18:00','Вечер',1),
('demo-meal-rocky-am','demo-diet-rocky',0,'09:00','Утро',0),('demo-meal-rocky-pm','demo-diet-rocky',0,'17:00','Вечер',1),
('demo-meal-sonya-am','demo-diet-sonya',0,'10:00','Утро',0),('demo-meal-sonya-pm','demo-diet-sonya',0,'16:00','День',1)
ON CONFLICT (id) DO UPDATE SET time_of_day=EXCLUDED.time_of_day,title=EXCLUDED.title,sort_order=EXCLUDED.sort_order;

INSERT INTO diet_meal_products(id,meal_id,name,quantity,calories,sort_order) VALUES
('demo-prod-archie-am','demo-meal-archie-am','Сухой корм премиум','160 г',480,0),('demo-prod-archie-pm','demo-meal-archie-pm','Влажный корм','120 г',330,0),
('demo-prod-nora-am','demo-meal-nora-am','Влажный корм для кошек','90 г',100,0),('demo-prod-nora-pm','demo-meal-nora-pm','Сухой корм для кошек','45 г',140,0),
('demo-prod-filya-am','demo-meal-filya-am','Сено','без ограничения',NULL,0),('demo-prod-filya-pm','demo-meal-filya-pm','Зелень','50 г',30,0),
('demo-prod-rocky-am','demo-meal-rocky-am','Зерновая смесь','15 г',55,0),('demo-prod-rocky-pm','demo-meal-rocky-pm','Овощи','10 г',20,0),
('demo-prod-sonya-am','demo-meal-sonya-am','Листовая зелень','40 г',30,0),('demo-prod-sonya-pm','demo-meal-sonya-pm','Овощи','30 г',25,0)
ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name,quantity=EXCLUDED.quantity,calories=EXCLUDED.calories,sort_order=EXCLUDED.sort_order;

INSERT INTO food_logs(id,animal_id,author_id,logged_at,meal,offered,eaten,not_eaten,appetite,note)
SELECT 'demo-new-food-'||a.code||'-'||n,a.id,'demo-keeper',now()-((n+a.ord)||' days')::interval,
       CASE WHEN n%2=0 THEN 'Утро' ELSE 'Вечер' END,a.food,
       CASE WHEN n=1 THEN '100%' ELSE '90%' END,
       CASE WHEN n=1 THEN 'Ничего' ELSE 'Небольшая часть' END,
       CASE WHEN n=1 THEN 5 ELSE 4 END,'Демонстрационная запись питания'
FROM (VALUES
('archie','demo-animal-archie',1,'Сухой корм премиум 160 г'),
('nora','demo-animal-nora',2,'Влажный корм 90 г'),
('filya','demo-animal-filya',3,'Сено и зелень'),
('rocky','demo-animal-rocky',4,'Зерновая смесь 15 г'),
('sonya','demo-animal-sonya',5,'Листовая зелень 40 г')
) AS a(code,id,ord,food),generate_series(1,3) AS n
ON CONFLICT (id) DO NOTHING;

COMMIT;
