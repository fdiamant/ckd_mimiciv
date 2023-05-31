-- Query to retrieve patient information and flags for CKD, hypertension, and diabetes

-- Creating a temporary table (patient_info) to store patient information
WITH patient_info AS (
    SELECT 
        ag.subject_id,
        ag.hadm_id,
        ag.age,
        p.gender
    FROM mimiciv_derived.age AS ag
    LEFT JOIN mimiciv_hosp.patients AS p ON ag.subject_id = p.subject_id
    WHERE ag.age >= 18
),

-- Creating a temporary table (ckd) to flag patients with CKD
ckd AS (
    SELECT subject_id, hadm_id, MAX(1) AS ckd_flag
    FROM mimiciv_hosp.diagnoses_icd
    WHERE 
        (SUBSTR(icd_code, 1, 3) = '585' AND icd_version = 9)
        OR (SUBSTR(icd_code, 1, 3) = 'N18' AND icd_version = 10)
    GROUP BY 1, hadm_id
),

-- Creating a temporary table (hypertension) to flag patients with hypertension
hypertension AS (
    SELECT subject_id, hadm_id, MAX(1) AS hypertension_flag
    FROM mimiciv_hosp.diagnoses_icd
    WHERE 
        (SUBSTR(icd_code, 1, 2) = '40' AND icd_version = 9)
        OR (SUBSTR(icd_code, 1, 2) = 'I1' AND icd_version = 10)
    GROUP BY 1, hadm_id
),

-- Creating a temporary table (diabetes) to flag patients with diabetes
diabetes AS (
    SELECT subject_id, hadm_id, MAX(1) AS diabetes_flag
    FROM mimiciv_hosp.diagnoses_icd
    WHERE 
        (SUBSTR(icd_code, 1, 2) = '249' OR SUBSTR(icd_code, 1, 3) = '250' AND icd_version = 9)
        OR (
            SUBSTR(icd_code, 1, 3) = 'E08' OR 
            SUBSTR(icd_code, 1, 3) = 'E09' OR
            SUBSTR(icd_code, 1, 3) = 'E10' OR
            SUBSTR(icd_code, 1, 3) = 'E11' OR
            SUBSTR(icd_code, 1, 3) = 'E12' OR
            SUBSTR(icd_code, 1, 3) = 'E13'
            AND icd_version = 10
        )
    GROUP BY 1, hadm_id
)

-- Main query to retrieve patient information along with CKD, hypertension, and diabetes flags
SELECT
    patient_info.subject_id,
    patient_info.hadm_id,
    patient_info.age AS age,
    patient_info.gender,
    COALESCE(ckd.ckd_flag, 0) AS ckd,
    COALESCE(hypertension.hypertension_flag, 0) AS hypertension,
    COALESCE(diabetes.diabetes_flag, 0) AS diabetes
FROM patient_info
LEFT JOIN ckd ON patient_info.hadm_id = ckd.hadm_id
LEFT JOIN hypertension ON patient_info.hadm_id = hypertension.hadm_id
LEFT JOIN diabetes ON patient_info.hadm_id = diabetes.hadm_id
ORDER BY patient_info.subject_id, patient_info.hadm_id;
