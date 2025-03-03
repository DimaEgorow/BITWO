-- CREATE TABLE olympiad_results (
--     id SERIAL PRIMARY KEY,
--     region VARCHAR(100),
--     contest VARCHAR(100),
--     participants INT,
--     scores TEXT,
--     average_score FLOAT,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );
-- select * from olympiad_results
-- -- Создание роли для администратора
-- CREATE ROLE admin WITH LOGIN PASSWORD '12345';

-- -- Создание роли для обычного пользователя
-- CREATE ROLE regular_user WITH LOGIN PASSWORD '123';  

-- -- Предоставление всех прав администратору
-- GRANT ALL PRIVILEGES ON TABLE olympiad_results TO admin;

-- -- Запрет всех прав для обычного пользователя
-- REVOKE ALL PRIVILEGES ON TABLE olympiad_results FROM regular_user;



-- добавление расширения для работы с криптографией
CREATE EXTENSION IF NOT EXISTS pgcrypto;
-- Создаем таблицу olympiad_results3
CREATE TABLE olympiad_results3 (
    id SERIAL PRIMARY KEY,  -- Уникальный идентификатор записи
    region VARCHAR(100),     -- Регион
    contest VARCHAR(100),    -- Название конкурса
    participants INT,        -- Количество участников
    scores TEXT,             -- Храним зашифрованные данные о баллах в формате TEXT
    average_score TEXT,      -- Храним зашифрованные данные о среднем балле в формате TEXT
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Дата и время создания записи
);

-- Создаем функцию триггера для шифрования данных
CREATE OR REPLACE FUNCTION encrypt_olympiad_results()
RETURNS TRIGGER AS $$
BEGIN
    -- Шифруем поля scores и average_score с использованием симметричного ключа
    NEW.scores := PGP_SYM_ENCRYPT(NEW.scores, '123');  -- Замените '123' на ваш секретный пароль
    NEW.average_score := PGP_SYM_ENCRYPT(NEW.average_score, '123');  -- Замените '123' на ваш секретный пароль
    RETURN NEW;  -- Возвращаем измененную запись
END;
$$ LANGUAGE plpgsql;

-- Создаем триггер, который будет вызываться перед вставкой данных в таблицу
CREATE TRIGGER encrypt_scores_before_insert
BEFORE INSERT ON olympiad_results3  -- Указываем, что триггер срабатывает перед вставкой
FOR EACH ROW  -- Для каждой вставляемой строки
EXECUTE PROCEDURE encrypt_olympiad_results();  -- Вызываем функцию шифрования

-- Пример запроса для выборки данных с расшифровкой
SELECT 
    id,  -- Идентификатор записи
    region,  -- Регион
    contest,  -- Название конкурса
    participants,  -- Количество участников
    PGP_SYM_DECRYPT(scores::bytea, '123') AS scores,  -- Расшифровываем зашифрованные баллы
    PGP_SYM_DECRYPT(average_score::bytea, '123') AS average_score,  -- Расшифровываем зашифрованный средний балл
    created_at  -- Дата и время создания записи
FROM olympiad_results3;  -- Из таблицы olympiad_results3