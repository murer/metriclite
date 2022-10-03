CREATE OR REPLACE TABLE metriclite.RAW_GIT_HEXBLADE_FILES AS
WITH ids AS (
  SELECT *, LEAD(n) OVER(ORDER BY n) AS nextn, LEAD(v) OVER(ORDER BY n) AS nextv
  FROM `metriclite.TRANSIENT_GIT_HEXBLADE_FILES`
  WHERE k = 'ID'
)
SELECT ids.v H, nonids.k K, nonids.v V
FROM `metriclite.TRANSIENT_GIT_HEXBLADE_FILES` nonids
INNER JOIN ids ON nonids.n > ids.n and nonids.n < ids.nextn
WHERE nonids.k <> 'ID'
ORDER BY nonids.n
 