CREATE OR REPLACE TABLE metriclite.TRUSTED_SMALL_BATCH AS
SELECT *
FROM `metriclite.TRUSTED_KANBANIZE`
WHERE Type_Name = 'Small Batch'
