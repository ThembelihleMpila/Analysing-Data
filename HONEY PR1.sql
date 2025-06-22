USE md_water_services;

SELECT *
FROM md_water_services.location;

SELECT *
FROM md_water_services.visits;

SELECT *
FROM md_water_services.data_dictionary;

 -- Dive into sources
 SELECT * FROM md_water_services.water_source;
 
 -- check the types of water sources
 SELECT DISTINCT type_of_water_source
 FROM md_water_services.water_source;
 
 -- unpack the visits to water source
 SELECT * FROM md_water_services.visits;
 
 -- Check records with abnormal queue time (>500)
SELECT * 
FROM md_water_services.visits 
WHERE time_in_queue>500
ORDER BY time_in_queue DESC;

SELECT * 
FROM md_water_services.water_source 
WHERE source_id IN ('AkRu05234224','HaZa21742224','AkKi00881224','SoRu37635224','SoRu36096224');

-- acess the quality of water source
SELECT * FROM md_water_services.water_quality;

-- Identify records with errors (homes with clean water source and had 2 visits)
SELECT count(record_id) 
FROM md_water_services.water_quality 
WHERE subjective_quality_score =10
AND visit_count =2;

-- Investigate pollution issues
SELECT *
FROM md_water_services.well_pollution 
LIMIT 5;

-- Identify records with results as 'Clean' but biological > 0.01
SELECT *
FROM md_water_services.well_pollution 
WHERE results='Clean' 
AND biological > 0.01;

-- Identify the records wrongly labelled as 'Clean'
SELECT *
FROM md_water_services.well_pollution 
WHERE description LIKE 'Clean_%';

-- Case 1a: Update descriptions that mistakenly mention `Clean Bacteria: E. coli` to `Bacteria: E. coli`
-- Case 1b: Update the descriptions that mistakenly mention `Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
-- Case 2: Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 plus current results is `Clean`

-- Case 1a
SET sql_safe_updates = 0;

UPDATE
well_pollution
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';

-- Case 1b
UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lambdia';

-- Case 2
UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE biological > 0.01
AND results = 'Clean';

CREATE TABLE md_water_services.well_pollution_copy
AS (
SELECT
*
FROM
md_water_services.well_pollution);

UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';

SELECT *
FROM well_pollution_copy
WHERE description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

-- Then if we're sure it works as intended, we can change the table back to the well_pollution and delete the well_pollution_copy tanle
UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';
DROP TABLE
md_water_services.well_pollution_copy;

