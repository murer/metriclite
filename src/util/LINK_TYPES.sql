select DISTINCT l
FROM `metriclite.TRANSIENT_KANBANIZE` w
INNER JOIN UNNEST(REGEXP_EXTRACT_ALL(w.Links, r"(\w+:)")) l