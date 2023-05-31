---
# Creating a dataset for Chronic Kidney Disease
---

## Aim

This mini project stems from my master's thesis conducted at Stockholm
University[^1]<sup>,</sup>[^2]. The focus is on investigating the eGFR
calculation in the MIMIC-IV (Medical Information Mart for Intensive
Care) \[1\] database while identifying potential issues within the
dataset and proposing possible solutions to mitigate them. The primary
aim is to develop an understanding of the eGFR calculation process and
contribute to enhancing the accuracy and reliability of the results. The
insights gained from this project can be valuable for future researchers
seeking to extract information on kidney health or other health related
data projects from the dataset. 

## eGFR and the CKD-EPI(2021) equation

The acronym eGFR refers to estimated Glomerular Filtration Rate, which
serves as a cost-effective and accurate method for evaluating kidney
function. Depending on the eGFR value and other factors beyond the scope
of this project, healthcare professionals may recommend lifestyle
modifications and/or prescribe specialized medications tailored to each
individual patient.The National Kidney Foundation offers an informative
fact sheet[^3] and a CKD heat map[^4] documents that provide a
comprehensive introduction to eGFR and Chronic Kidney Disease (CKD).

For the most up-to-date calculation of eGFR, researchers have proposed
the CKD-EPI(2021) equation \[2\]. The National Kidney Foundation also
offers a concise information page dedicated to the CKD-EPI equation
\[3\]. The eGFR is expressed in milliliters per minute per 1.73 square
meters ($mL/min/1.73m^{2}$), and the equation is as follows:    


$eGFR = 142*\min\left( \frac{standardized\ Scr}{K},\ 1 \right)^{a}*{\max\left( \frac{standardized\ Scr}{K},\ 1 \right)}^{- 1.200}*{0.9938}^{age}*1.012\ \lbrack if\ female\rbrack$    


Where:

- **S<sub>cr</sub>** is the serum creatinine in mg/dL

- **K** is a constant, 0.7 for females or 0.9 for males

- **a** is a constant, -0.241 for females or -0.302 for males

- **age** is the patient’s age in years

## The standardized S<sub>cr</sub>

Standardized S<sub>cr</sub> refers to laboratory measurements of serum
creatinine (S<sub>cr</sub>) that have been calibrated based on the
National Institute of Standards and Technology (NIST) standard reference
material (SRM) 967. References \[4\], \[5\] outline the methodology of
the standardization and its importance in eGFR results, respectively.
With the introduction of the SRM 967 in 2007, manufacturers have been
required to follow this standard ever since \[5\].

## The MIMIC-IV dataset

*“MIMIC is a large, freely-available database comprising deidentified
health-related data from patients who were admitted to the critical care
units of the Beth Israel Deaconess Medical Center”* \[6\]. While the
database is freely-available, individuals are required to complete the
necessary training in [CITI Data or Specimens Only
Research](https://physionet.org/about/citi-course/), and subsequently
apply for data access through the
[physionet.org](https://physionet.org/) website. You can find my
training certificate confirming completion of the required training
[here](https://www.citiprogram.org/verify/?wf6b514f4-d64e-4448-96bb-977173e0a3b1-47385825).
Access to MIMIC is offered through two methods: cloud-based \[7\] or
local \[8\]. For my master thesis I chose to extract the necessary data
through BigQuery db. In this project, I have chosen to set up the local
database, specifically utilizing a Postgres installation as outlined in
the mimic-IV [GitHub
page](https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iv/buildmimic/postgres),
as I wanted to explore the capabilities of the PostgresSQL language.

## Workflow

Here there is a list with the steps taken towards the dataset creation.

- Install the database locally. A comprehensive guide can be found
  [here](https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iv/buildmimic/postgres).

- Identify the tables needed for the specific project. Thankfully, the
  MIMIC project community provides some ready-made queries for creating
  concepts such as complete blood count or demographics. I have used the
  [age
  query](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iv/concepts/demographics/age.sql),
  the
  [complete_blood_count](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iv/concepts/measurement/complete_blood_count.sql)
  and the
  [chemistry](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iv/concepts/measurement/chemistry.sql)
  from the demographics, and the diagnoses_icd from the hosp module.
  MIMIC comes with a comprehensive documentation found
  [here](https://mimic.mit.edu/docs/iv/).

- I created two sql queries and saved the results into two separate csv
  files.

  - The
    [lab_query.sql](https://github.com/fdiamant/mimiciv_ckd/blob/main/lab_query.sql)
    extracts blood lab results (complete blood count and chemistry
    results) from the database for the same
    [subject_id](https://mimic.mit.edu/docs/iv/modules/hosp/labevents/#subject_id),
    with the same
    [hadm_id](https://mimic.mit.edu/docs/iv/modules/hosp/labevents/#hadm_id)
    where the blood samples have been taken simultaneously.

  - The
    [patients_query.sql](https://github.com/fdiamant/mimiciv_ckd/blob/main/patients_query.sql)
    extracts basic patient demographics along with flags for diabetes,
    hypertension and ckd diagnoses for each patient (1 means positive
    diagnosis).

- I imported the csv files into a JupyterLab notebook where I joined the
  two Dataframes and proceded with further deidentification of the data
  using a SHA256 algorithm. I exported the results into a new csv file,
  and created [this
  notebook](https://github.com/fdiamant/mimiciv_ckd/blob/main/main_notebook.ipynb),
  where the rest of the analysis takes place.

## Issues and decisions 

1.  There are no urine lab results in the datasets.There is no derived
    query (like the chemistry query) that return lab results for urine
    tests. I have decided to not include anything from urine tests at
    the current version as it would bloat the project.

2.  Since MIMIC-IV includes data from patient admissions between 2008
    and 2019, I assume that S<sub>cr</sub> laboratory measurements are
    standaridized.

3.  The mimiciv_derived.age table contains a calculated age column where
    the values are floats containing many decimal places. I have decided
    to convert the column into int, in effect rounding the number, as in
    a hospital environment the whole part of the age is used most of the
    times.

## Future versions

1.  Create a query for urine lab results and modify the dataset.

2.  Do a comprehensive statistical analysis of the dataset.

3.  Check variations in eGFR calculation that might occur as a result of
    the age rounding decision.

## References

\[1\] A. E. W. Johnson *et al.*, ‘MIMIC-IV, a freely accessible
electronic health record dataset’, *Sci. Data*, vol. 10, no. 1, p. 1,
Jan. 2023, doi: 10.1038/s41597-022-01899-x.

\[2\] L. A. Inker *et al.*, ‘New Creatinine- and Cystatin C–Based
Equations to Estimate GFR without Race’, *N. Engl. J. Med.*, vol. 385,
no. 19, pp. 1737–1749, Nov. 2021, doi: 10.1056/NEJMoa2102953.

\[3\] ‘CKD-EPI Creatinine Equation (2021)’, *National Kidney
Foundation*, Oct. 01, 2021.
https://www.kidney.org/professionals/kdoqi/gfr_calculator/formula
(accessed May 19, 2023).

\[4\] N. G. Dodder, S. S.-C. Tai, L. T. Sniegoski, N. F. Zhang, and M.
J. Welch, ‘Certification of Creatinine in a Human Serum Reference
Material by GC-MS and LC-MS’, *Clin. Chem.*, vol. 53, no. 9, pp.
1694–1699, Sep. 2007, doi: 10.1373/clinchem.2007.090027.

\[5\] H. Pottel *et al.*, ‘Standardization of serum creatinine is
essential for accurate use of unbiased estimated GFR equations: evidence
from three cohorts matched on renal function’, *Clin. Kidney J.*, vol.
15, no. 12, pp. 2258–2265, Dec. 2022, doi: 10.1093/ckj/sfac182.

\[6\] ‘About MIMIC’, *MIMIC*. https://mimic.mit.edu/docs/about/
(accessed May 24, 2023).

\[7\] ‘Cloud’, *MIMIC*. https://mimic.mit.edu/docs/gettingstarted/cloud/
(accessed May 24, 2023).

\[8\] ‘Local database setup’, *MIMIC*.
https://mimic.mit.edu/docs/gettingstarted/local/ (accessed May 24,
2023).

[^1]: https://drive.google.com/file/d/1R_RTf9gSW9CxZMnw5xjPyk8NLDtpDk8B/view?usp=sharing

[^2]: https://github.com/fdiamant/Thesis

[^3]: https://www.kidney.org/sites/default/files/01-10-8374_2212_patflyer_egfr.pdf

[^4]: https://www.kidney.org/sites/default/files/kidney-numbers_ckd-heatmap.pdf

