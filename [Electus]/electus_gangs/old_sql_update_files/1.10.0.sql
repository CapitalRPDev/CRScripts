ALTER TABLE electus_gangs_drug_capture RENAME TO electus_gangs_capture_progress;

ALTER TABLE electus_gangs_capture_progress RENAME COLUMN sold_drugs TO progress;
ALTER TABLE electus_gangs_zones_data RENAME COLUMN min_drug_capture TO min_progress;
ALTER TABLE electus_gangs_zones_data RENAME COLUMN drug_capture TO progress_types;
ALTER TABLE electus_gangs_zones_data MODIFY COLUMN progress_types TEXT;


CREATE TABLE IF NOT EXISTS `electus_gangs_alerts` (
  `gang_id` int(11) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(255) DEFAULT NULL,
  `message` mediumtext DEFAULT NULL,
  `coords` varchar(255) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_electus_gangs_alerts_gang_id` (`gang_id`),
  CONSTRAINT `fk_electus_gangs_alerts_gang_id` FOREIGN KEY (`gang_id`) REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `electus_gangs_tasks` (
  `gang_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `label` varchar(255) DEFAULT NULL,
  `description` mediumtext DEFAULT NULL,
  `progress` int(11) DEFAULT 0,
  `reward` int(11) DEFAULT NULL,
  `min_level` int(11) DEFAULT NULL,
  `goal_progress` int(11) DEFAULT NULL,
  `should_remove` int(11) DEFAULT 0,
  KEY `fk_electus_gangs_tasks_gang_id` (`gang_id`),
  CONSTRAINT `fk_electus_gangs_tasks_gang_id` FOREIGN KEY (`gang_id`) REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);