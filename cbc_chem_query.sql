-- Retrieve lab measurements from complete_blood_count and chemistry tables
SELECT
	cbc.subject_id,
	cbc.hadm_id,
	cbc.charttime,
	cbc.specimen_id,
	cbc.hematocrit,
	cbc.hemoglobin,
	cbc.mch,
	cbc.mchc,
	cbc.mcv,
	cbc.platelet,
	cbc.rbc,
	cbc.rdw,
	cbc.wbc,
	chem.albumin,
	chem.globulin,
	chem.total_protein,
	chem.aniongap,
	chem.bicarbonate,
	chem.bun,
	chem.calcium,
	chem.chloride,
	chem.creatinine,
	chem.glucose,
	chem.sodium,
	chem.potassium
FROM
	mimiciv_derived.complete_blood_count AS cbc
	JOIN mimiciv_derived.chemistry AS chem ON cbc.charttime = chem.charttime
WHERE
	cbc.hadm_id IS NOT NULL
	AND chem.hadm_id IS NOT NULL
	AND cbc.subject_id = chem.subject_id
	AND cbc.hadm_id = chem.hadm_id
ORDER BY
	cbc.subject_id,
	cbc.hadm_id,
	cbc.charttime
