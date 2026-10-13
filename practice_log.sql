-- Создание базы
CREATE DATABASE IF NOT EXISTS company;
USE company;

-- Создание таблицы departments
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL
);

-- Создание таблицы employees
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) DEFAULT 0.00,
    hire_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Вставка тестовых данных (как в лекции 39)
INSERT INTO departments (name) VALUES
('Разработка'),
('Маркетинг'),
('Финансы');

INSERT INTO employees (name, salary, hire_date, department_id) VALUES
('Иван Петров',     85000.00, '2019-03-15', 1),
('Мария Сидорова',  92000.00, '2018-11-01', 1),
('Алексей Иванов',  78000.00, '2020-06-20', 2),
('Ольга Кузнецова', 95000.00, '2017-02-10', 3),
('Дмитрий Смирнов', 88000.00, '2021-09-05', 1),
('Елена Волкова',   76000.00, '2022-01-17', 2),
('Сергей Козлов',   92000.00, '2019-08-30', 3),
('Анна Морозова',   85000.00, '2023-04-12', 1),
('Павел Лебедев',   99000.00, '2016-05-23', 3),
('Наталья Орлова',  81000.00, '2021-12-01', 2);



-- ЗАДАНИЕ 1
USE company;

INSERT INTO departments (name) VALUES ('Продажи');

INSERT INTO employees (name, salary, hire_date, department_id) VALUES
('Виктор Ерёмин',   83000.00, '2020-09-14', 4),
('Татьяна Белова',  87000.00, '2018-04-02', 4),
('Григорий Фомин',  79000.00, '2022-07-25', 4),
('Инна Соколова',   94000.00, '2017-11-30', 4),
('Кирилл Данилов',  86000.00, '2023-01-09', 4),
('Вера Гусева',     82000.00, '2021-05-18', 4);

-- Задание 2

SELECT 
	name,
	salary,
    department_id,
    ROUND(AVG(salary) OVER(), 2) as company_avg,
    ROUND(salary / SUM(salary) OVER () * 100, 2) AS percent_of_total
FROM employees
ORDER BY salary DESC;

-- Задание 3

SELECT 
	salary,
    hire_date,
	department_id,
    MAX(salary) OVER(PARTITION BY department_id) AS dept_max,
    ROUND(AVG(salary) OVER (PARTITION BY department_id), 2) AS dept_avg,
    ROUND(salary - AVG(salary) OVER(PARTITION BY department_id), 2) AS diff
FROM employees
ORDER BY department_id, salary DESC;

-- Задание 4

SELECT 
	name,
    salary,
    department_id,
    ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS row_num,
    RANK() OVER (ORDER BY salary DESC) as row_rank,
    DENSE_RANK() OVER (ORDER BY salary DESC) as dens_rank,
    NTILE(4) OVER(ORDER BY salary DESC) as ntle
FROM employees
ORDER BY department_id, row_num;

-- Задание 5

SELECT 
	name,
    salary,
    hire_date,
    department_id,
    SUM(salary) OVER (ORDER BY hire_date) as running_total,
    SUM(salary) OVER (PARTITION BY department_id ORDER BY hire_date) as dept_running_total
FROM employees
ORDER BY hire_date;

-- Задание 6

SELECT 
	name,
    salary,
    hire_date,
    LAG(salary) OVER(ORDER BY hire_date) as prev_salary,
    ROUND((salary - LAG(salary) OVER(ORDER BY hire_date)) / LAG(salary) OVER(ORDER BY hire_date) * 100, 2)  as growth_pct,
    LEAD(salary) OVER (ORDER BY hire_date) as next_salary
FROM employees
ORDER BY hire_date;

-- Задание 7 

SELECT
	name,
    salary,
    hire_date,
    department_id,
	ROUND(AVG(salary) OVER (ORDER BY hire_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2 ) as rolling_avg_3,
    SUM(salary) OVER (PARTITION BY department_id ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as dept_total,
    SUM(salary) OVER (ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as rows_running,
    SUM(salary) OVER (ORDER BY salary DESC RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as range_running
FROM employees
ORDER by hire_date;

-- Задание 8 

SELECT 
	name,
    salary,
    hire_date,
    department_id,
    FIRST_VALUE(salary) OVER(PARTITION BY department_id ORDER BY hire_date ) as first_salary,
    LAST_VALUE(salary) OVER(PARTITION BY department_id ORDER BY hire_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS last_salary,
    NTH_VALUE(salary, 2) OVER(PARTITION BY department_id ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_highest
FROM employees
ORDER BY department_id , hire_date ASC;

-- Задание 9

WITH ranked AS(
	SELECT 
		name,
		salary,
        department_id,
        ROW_NUMBER() OVER(PARTITION BY department_id ORDER BY salary DESC) as rn
	FROM employees
    )
    
SELECT 
	d.name,
    r.name,
    r.salary,
    r.department_id
FROM ranked r 
JOIN departments d ON r.department_id = d.id
WHERE rn <= 2;

-- Задание 10

INSERT INTO employees (name, salary, hire_date, department_id) VALUES
('Дмитрий Смирнов', 87000.00, '2024-02-01', 1),
('Дмитрий Смирнов', 86000.00, '2024-03-01', 1);

WITH duplic AS (
	SELECT
		id,
		name,
        salary,
        department_id,
        hire_date,
        ROW_NUMBER() OVER (PARTITION BY name, department_id ORDER BY id) as rn
	FROM employees

)
SELECT *
FROM duplic 
WHERE rn > 1;

WITH duplic AS (
	SELECT
		id,
		name,
        salary,
        department_id,
        hire_date,
        ROW_NUMBER() OVER (PARTITION BY name, department_id ORDER BY id) as rn
	FROM employees

)

DELETE e
FROM employees e

JOIN duplic d ON d.id = e.id
WHERE d.rn > 1;

-- Задание 11

SELECT 
	name,
    salary,
    ROUND(CUME_DIST() OVER (ORDER BY salary ASC), 3) as cume,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary ASC), 3) as percent
FROM employees
ORDER BY salary ASC;

WITH dist AS (
	SELECT
		name,
		salary,
		ROUND(CUME_DIST() OVER (ORDER BY salary ASC), 3) as cume
FROM employees
)

SELECT d.name, d.salary, cume
FROM dist d
WHERE cume >= 0.75;

-- Задание 12

SELECT
	d.name as department,
	e.name,
    e.salary,
    e.department_id,
    RANK() OVER(PARTITION BY e.department_id ORDER BY salary DESC) as dept_rank
FROM employees e
JOIN departments d ON e.department_id = d.id
ORDER BY e.department_id, dept_rank asc;

SELECT 
	name,
    salary,
    department_id,
    ROUND(AVG(salary) OVER (PARTITION BY department_id), 2) as avg_salary,
    CASE
		WHEN salary > AVG(salary) OVER (PARTITION BY department_id) THEN 'выше среднего'
        WHEN salary < AVG(salary) OVER (PARTITION BY department_id) THEN 'ниже среднего'
		ELSE
			'равна средней'
	END AS salary_status
    FROM employees
    ORDER BY department_id, salary DESC;
    
WITH median AS(
SELECT 
	name,
	salary,
	ROW_NUMBER() OVER(ORDER BY salary ASC) as rn,
	COUNT(*) OVER () as total
FROM employees
)

SELECT AVG(salary)
FROM median
WHERE rn IN (
	FLOOR((total + 1) / 2),
    CEIL(( total + 1) / 2)
)