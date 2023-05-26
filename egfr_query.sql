/* 
   This script creates a new table named 'egfr' in the 'mimiciv_derived' schema, which contains the following information:

   1. Unique patient number, admission ID, specimen ID, and item ID from the 'labevents' table.
   2. Patient gender from the 'patients' table.
   3. Calculated age from the 'mimiciv_derived.age' table.

   The script follows the steps below:
   1. Drops the 'egfr' table if it already exists.
   2. Creates the 'egfr' table.
   3. Defines a Common Table Expression (CTE) named 'creatinine_itemid' to store the item ID for Creatinine lab results.
   4. Defines a CTE named 'selected_data' to retrieve the desired data from various tables.
   5. Inserts the selected data into the 'egfr' table.
*/

DROP TABLE IF EXISTS mimiciv_derived.egfr; -- Drop the 'egfr' table if it already exists

CREATE TABLE mimiciv_derived.egfr (
	labevent_id INTEGER,
    subject_id INTEGER,
    hadm_id INTEGER,
    specimen_id INTEGER,
    gender CHAR(1),
    age FLOAT,
    serum_creatinine FLOAT
    
); -- Create the 'egfr' table with appropriate column definitions

WITH creatinine_itemid AS (
	SELECT
		itemid
	FROM
		mimiciv_hosp.d_labitems
	WHERE
		label LIKE 'Creatinine'
),
selected_data AS (
	SELECT
		lab.labevent_id,
		lab.subject_id,
		lab.hadm_id,
		lab.specimen_id,
		pat.gender,
		a.age,
		lab.valuenum
	FROM
		mimiciv_hosp.labevents AS lab
		JOIN mimiciv_hosp.patients AS pat ON lab.subject_id = pat.subject_id
		JOIN mimiciv_derived.age AS a ON lab.hadm_id = a.hadm_id
	WHERE
		itemid IN (
			SELECT
				itemid
			FROM
				creatinine_itemid))
	INSERT INTO mimiciv_derived.egfr -- Insert the selected data into the 'egfr' table
	SELECT
		*
	FROM
		selected_data;

