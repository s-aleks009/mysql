/*
 * Колличество подписчиков у машины
 */
SELECT count(*) AS total FROM subscriptions_cars WHERE car_page_id = 1;


/*
 * Представление: имя конкретного пользователя и список его машин
 */
CREATE OR REPLACE VIEW v_user_cars
AS
	SELECT
		u.id,
		concat(firstname, ' ', lastname) AS Name,
		cm.name AS Make,
		cmd.name AS Model
	FROM users u
	JOIN car_pages cp ON u.id = cp.user_id
	JOIN car_makes cm ON cp.car_make_id = cm.id
	JOIN car_models cmd ON cp.car_model_id = cmd.id
;

SELECT Name, Make, Model FROM v_user_cars WHERE id = 1;


/*
 * Представление: имена и почты пользователей, владеющих автомобилем заданной марки в заданном городе
 * (для рекламных рассылок)
 */
CREATE OR REPLACE VIEW v_car_hometown
AS
	SELECT 
		concat(firstname, ' ', lastname) AS Name,
		email,
		p.hometown AS Hometown,
		cm.name AS Car_make
	FROM users u
	JOIN profiles p ON u.id = p.user_id
	JOIN car_pages cp ON u.id = cp.user_id
	JOIN car_makes cm ON cp.car_make_id = cm.id
;

SELECT Name, email FROM v_car_hometown WHERE Hometown = 'Moscow' AND Car_make = 'Audi';


/*
 * Процедура: выводит страницы машин той же модели, 
 * что и у заданного пользователя, но на которые он ещё не подписан
 */
DROP PROCEDURE IF EXISTS sp_interesting_car_offers;

DELIMITER //
CREATE PROCEDURE sp_interesting_car_offers(IN for_user_id INT)
  BEGIN
	SELECT
		cp.id AS id,
		cp.name AS name,
		cm.name AS make,
		cmd.name AS model
	FROM car_pages cp
	JOIN car_makes cm ON cp.car_make_id = cm.id
	JOIN car_models cmd ON cp.car_model_id = cmd.id
	JOIN users u ON cp.user_id = u.id
	JOIN subscriptions_cars sc ON cp.id = sc.car_page_id AND sc.user_id <> for_user_id	-- исключить на которые уже подписан
	WHERE cmd.id IN (	-- Модели машин, которые есть у пользователя
		SELECT
			cmd.id
		FROM users u
		JOIN car_pages cp ON u.id = cp.user_id
		JOIN car_models cmd ON cp.car_model_id = cmd.id
		WHERE u.id = for_user_id
	) AND u.id <> for_user_id	-- исключить машины пользователя
	ORDER BY rand()	-- случайные записи
	LIMIT 4;	-- ограничение в 4 записи
  END//
DELIMITER ;

CALL sp_interesting_car_offers(1);


/*
 * Триггер: для корректировки возраста пользователя при вставке новых строк
 */
DROP TRIGGER IF EXISTS t_check_user_age_before_insert;

DELIMITER //
CREATE TRIGGER t_check_user_age_before_insert BEFORE INSERT ON profiles
FOR EACH ROW
  BEGIN
    IF NEW.birthday > CURRENT_DATE() THEN
        SET NEW.birthday = CURRENT_DATE();
    END IF;
  END//
DELIMITER ;