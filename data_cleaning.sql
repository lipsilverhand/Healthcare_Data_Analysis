DROP TABLE IF EXISTS healthcare_1;

CREATE TABLE healthcare_1 (
	id SERIAL PRIMARY KEY,
    name TEXT,
    age INTEGER,
    gender TEXT,
    blood_type TEXT,
    medical_condition TEXT,
    date_of_admission DATE,
    doctor TEXT,
    hospital TEXT,
    insurance_provider TEXT,
    billing_amount NUMERIC(10,2),
    room_number TEXT,
    admission_type TEXT,
    discharge_date DATE,
    medication TEXT,
    test_results TEXT
);

SELECT * FROM healthcare_1;


-- Remove duplicates
-- Formatting

CREATE TABLE healthcare_1_stage 
(
	id SERIAL PRIMARY KEY,
    name TEXT,
    age INTEGER,
    gender TEXT,
    blood_type TEXT,
    medical_condition TEXT,
    date_of_admission DATE,
    doctor TEXT,
    hospital TEXT,
    insurance_provider TEXT,
    billing_amount NUMERIC(10,2),
    room_number TEXT,
    admission_type TEXT,
    discharge_date DATE,
    medication TEXT,
    test_results TEXT
);

INSERT INTO healthcare_1_stage
SELECT * FROM healthcare_1;

SELECT * FROM healthcare_1_stage;


-- Remove duplicate
WITH CTE_duplicate AS (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY name, age, gender, blood_type, medical_condition, date_of_admission, doctor, hospital, insurance_provider, billing_amount, room_number, admission_type, discharge_date, medication, test_results
		ORDER BY id
	) AS row_number
	FROM healthcare_1_stage
)

DELETE FROM healthcare_1_stage 
WHERE id IN (
	SELECT id
	FROM CTE_duplicate
	WHERE row_number > 1
);

--SELECT id, row_number 
--FROM CTE_duplicate
--WHERE row_number > 1;

SELECT COUNT(id) FROM healthcare_1; -- 55500 rows
SELECT COUNT(id) FROM healthcare_1_stage; -- 54966 rows
-- Successfully removing duplicates.


-- Fix name format
UPDATE healthcare_1_stage
SET name = INITCAP(name);

SELECT * FROM healthcare_1_stage;

SELECT 
	id, 
	name,
	TO_CHAR(date_of_admission, 'MM-DD-YYYY') as date_admission_fm,
	TO_CHAR(discharge_date, 'MM-DD-YYYY') as date_discharge_fm
FROM healthcare_1_stage;

WITH CTE_final AS (
	SELECT
		id,
		name,
		age,
		gender,
		blood_type,
		medical_condition,
		TO_CHAR(date_of_admission, 'MM-DD-YYYY') as date_admission_fm,
		doctor,
		hospital,
		insurance_provider,
		billing_amount,
		room_number,
		admission_type,
		TO_CHAR(discharge_date, 'MM-DD-YYYY') as date_discharge_fm,
		medication,
		test_results
	FROM healthcare_1_stage
)

SELECT * FROM CTE_final;


