CREATE OR REPLACE TABLE metriclite.RAW_KANBANIZE AS
SELECT *,
REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Children: ([0-9\,\s]+)"), r"(\w+)") Children,
REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Parents: ([0-9\,\s]+)"), r"(\w+)") Parents,
REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Predecessors: ([0-9\,\s]+)"), r"(\w+)") Predecessors,
REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Successors: ([0-9\,\s]+)"), r"(\w+)") Successors,
REGEXP_EXTRACT_ALL(REGEXP_EXTRACT(Links, r"Relatives: ([0-9\,\s]+)"), r"(\w+)") Relatives
FROM `metriclite.TRANSIENT_KANBANIZE`


