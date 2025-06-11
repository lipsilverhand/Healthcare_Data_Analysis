# Healthcare Utilization & Cost Report (2019 - 2024)

Date: June 11th, 2025

## Techstack: PostgreSQL, Excel, Tableau

## ETL Process Breakdown
1. Extract: pulled raw data from Kaggle
2. Transform: Cleaned data in PgAdmin4 by using PostgreSQL and made adjusment in Excel
3. Load: Loaded cleaned data into Tableau for sheets and dashboard

## SQL:
### Create table
```sql
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
```

### Create stage table for data cleaning
```sql
  CREATE TABLE healthcare_1_stage (
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
```
### Remove duplicates
```sql
WITH CTE_duplicate AS (
	SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY name, age, gender, blood_type, medical_condition, date_of_admission, doctor,         hospital, insurance_provider, billing_amount, room_number, admission_type, discharge_date,       medication, test_results
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

-- Check duplicates
SELECT COUNT(id) FROM healthcare_1; -- 55500 rows
SELECT COUNT(id) FROM healthcare_1_stage; -- 54966 rows
-- Duplicates successfully removed!

```

### Fix formatt
```sql
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
```

### Final cleaned data query
```sql
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
```

## Tableau with interactive filters:
![{8B8224CA-6555-4FCB-922D-B37576540BF8}](https://github.com/user-attachments/assets/1a36ecb4-5b0d-475b-b0fd-4e3837110851)
![{8AEDDD2E-941D-4AAD-9B5A-2AE5019B8E3D}](https://github.com/user-attachments/assets/40d4fb7f-9c99-45d6-84bd-a7388c4d27b7)
![{11214D6E-13E3-4769-82BF-4D1FB526E71C}](https://github.com/user-attachments/assets/ea0b3686-8eae-4aca-9860-4aca0c7c799a)

## Findings and conclusion:
### Summary:
- Between 2019 and 2024, the healthcare system recorded 54,966 total admissions and $1.404 trillion in total billing. This report provides strategic insights into admission trends, patient demographics, insurance performance, and key medical cost drivers — aimed to inform cost optimization, resource allocation, and preventive care strategies.

### Findings:
Total Admissions: 54,966                
Total Billing Amount: $1.404 Trillion      
Timeframe: 2019–2024               
Peak Admission Year: 2020 (11,172)          
Lowest Admission Year: 2024 (3,827)            
Highest Billed Condition: **Diabetes (\$237B)**  
Most Frequent Conditions: **Arthritis & Diabetes** 

- Care services are heavily concentrated among working-age adults, followed by seniors, suggesting targeted chronic care support for aging populations. Pediatric care demand is negligible in this dataset.
- Billing is distributed evenly across providers, ensuring no dominant dependency. Cigna has a slightly higher share, which may be worth monitoring for claim efficiency or policy design differences.
- High case concentration in a few physicians may indicate overutilization. Consider workforce balancing or capacity enhancement strategies.
- Diabetes and Arthritis are top cost drivers across genders, with slightly higher asthma spending in males. This points to potential gender-sensitive intervention planning.

### Conclusion:
1. Prioritize Chronic Condition Management
- Diabetes and arthritis are both high-cost and high-frequency → target with preventive care initiatives and patient education.

2. Investigate 2024 Drop
- Audit for billing barriers or policy shifts.
- Verify if care is shifting to outpatient or alternate providers.

3. Evaluate High Case-Load Physicians
- Support high-volume physicians with team-based care or digital triage tools.

4. Segment Age-Specific Health Programs
- Adult and senior populations dominate admissions. Tailor chronic care and mental health services accordingly.

5. Monitor Gender-Specific Trends
- Slight variations in billing by gender can inform targeted campaigns (e.g., asthma in males).


