ALTER TABLE electus_gangs_zones_data ADD COLUMN hide_from_map TINYINT(1) DEFAULT 0;

ALTER TABLE electus_gangs_wars
DROP COLUMN peace_1;

ALTER TABLE electus_gangs_wars
DROP COLUMN peace_2;

ALTER TABLE electus_gangs_wars
ADD COLUMN duration INT;

ALTER TABLE electus_gangs_wars
ADD COLUMN gang_1_progress INT DEFAULT 0;

ALTER TABLE electus_gangs_wars
ADD COLUMN gang_2_progress INT DEFAULT 0;

CREATE TABLE IF NOT EXISTS `electus_gangs_previous_wars`
(
	`gang_id_1` int(11) NOT NULL,
	`gang_id_2` int(11) NOT NULL,
	`winner_id` int(11) NOT NULL,
	`prize` int(11) NOT NULL
);
