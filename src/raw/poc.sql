CREATE OR REPLACE TABLE metriclite.TMP_RAW_KANBANIZE AS
SELECT *,
CASE ARRAY_LENGTH(Parents) WHEN 0 THEN NULL ELSE Parents[OFFSET(0)] END Parent,
FROM (
  SELECT *,
    REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Parents: ([0-9\,\s]+)"), r"(\w+)") Parents, 
    REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Children: ([0-9\,\s]+)"), r"(\w+)") Children,
  FROM `metriclite.TRANSIENT_KANBANIZE`
)


SELECT distinct Type_Name
FROM `metriclite.TMP_RAW_KANBANIZE` 

SELECT distinct Section
FROM `metriclite.TMP_RAW_KANBANIZE` 

