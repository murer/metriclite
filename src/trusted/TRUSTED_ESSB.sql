CREATE OR REPLACE TABLE metriclite.TRUSTED_ESSB AS
SELECT epic.Card_ID epic_id, story.Card_ID story_id, small_batch.Card_Id small_batch_id
FROM `metriclite.TRUSTED_KANBANIZE` epic
INNER JOIN UNNEST (epic.Children) epic_child
INNER JOIN `metriclite.TRUSTED_KANBANIZE` story
  ON story.Type_Name = 'Story' AND story.Card_ID = CAST(epic_child as Integer)
INNER JOIN UNNEST (story.Children) story_child
INNER JOIN `metriclite.TRUSTED_KANBANIZE` small_batch
  ON small_batch.Type_Name = 'Small Batch' AND small_batch.Card_ID = CAST(story_child as Integer)
WHERE epic.Type_Name = 'Epic'
