DROP DATABASE IF EXISTS drive2;
CREATE DATABASE drive2;
USE drive2;

-- Список пользователей
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(120) UNIQUE,
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

-- Список автопроизводителей
DROP TABLE IF EXISTS car_makes;
CREATE TABLE car_makes (
	id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    INDEX car_makes_name_idx(name)
);

-- Список моделей
DROP TABLE IF EXISTS car_models;
CREATE TABLE car_models (
	id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    INDEX car_models_name_idx(name)
);

-- Сообщества
DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(150),
    INDEX communities_name_idx(name)
);

-- Сообщества пользователей
DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, community_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

-- Тип блога (машина, юзер, сообщество)
DROP TABLE IF EXISTS blog_types;
CREATE TABLE blog_types(
	id SERIAL PRIMARY KEY,
    name ENUM('car', 'user', 'community')
);

-- Блог
DROP TABLE IF EXISTS blog;
CREATE TABLE blog(
	id SERIAL PRIMARY KEY,
    blog_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	name VARCHAR(50),
    body text,
    filename VARCHAR(255),
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
    INDEX blog_user_idx(user_id),
    INDEX blog_name_idx(name),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (blog_type_id) REFERENCES blog_types(id)
);

-- Комментарии блога
DROP TABLE IF EXISTS comments;
CREATE TABLE comments (
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
    blog_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (blog_id) REFERENCES blog(id)
);

-- Фото
DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos` (
	id SERIAL PRIMARY KEY,
	name VARCHAR(255)
);

--  Сообщения
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    INDEX messages_from_user_id (from_user_id),
    INDEX messages_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

-- Страничка машины
DROP TABLE IF EXISTS car_pages;
CREATE TABLE car_pages(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    car_make_id BIGINT UNSIGNED NOT NULL,
    car_model_id BIGINT UNSIGNED NOT NULL,
  	name VARCHAR(50),
    body text,
    photo_id BIGINT UNSIGNED NULL,
	created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
    INDEX car_pages_user_idx(user_id),
    INDEX car_pages_car_make_idx(car_make_id),
    INDEX car_pages_car_model_idx(car_model_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (car_make_id) REFERENCES car_makes(id),
    FOREIGN KEY (car_model_id) REFERENCES car_models(id),
    FOREIGN KEY (photo_id) REFERENCES photos(id)
);

-- Лайки машины
DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    car_page_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (car_page_id) REFERENCES car_pages(id)
);

-- Подписки на юзера
DROP TABLE IF EXISTS subscription_users;
CREATE TABLE subscriptions_users (
	id SERIAL PRIMARY KEY,
    from_user_id BIGINT UNSIGNED NOT NULL,
    to_users_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (from_user_id) REFERENCES users(id),
	FOREIGN KEY (to_users_id) REFERENCES users(id)
);

-- Подписки на машину
DROP TABLE IF EXISTS subscription_cars;
CREATE TABLE subscriptions_cars (
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    car_page_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (car_page_id) REFERENCES car_pages(id)
);

-- Профиль
DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (photo_id) REFERENCES photos(id)
);

-- Последний раз в онлайне
DROP TABLE IF EXISTS online;
CREATE TABLE online(
	user_id SERIAL PRIMARY KEY,
    online_at DATETIME ON UPDATE NOW(),
	FOREIGN KEY (user_id) REFERENCES users(id)
);