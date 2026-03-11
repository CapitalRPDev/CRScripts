ALTER TABLE electus_gangs_zones_data
ADD warehouse_crates_locations TEXT(255) DEFAULT NULL,
ADD cash_safe TEXT(255) DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `electus_gangs_zone_attacks` (
  `attacker` int(11) DEFAULT NULL,
  `zone_id` int(11) DEFAULT NULL,
  `activation_time` datetime DEFAULT current_timestamp(),
  KEY `fk_attacker` (`attacker`),
  KEY `fk_zone_id` (`zone_id`),
  CONSTRAINT `fk_attacker` FOREIGN KEY (`attacker`) REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_zone_id` FOREIGN KEY (`zone_id`) REFERENCES `electus_gangs_zones_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

ALTER TABLE electus_gangs_drug_capture
DROP FOREIGN KEY fk_drug_capture_gang;

ALTER TABLE electus_gangs_drug_capture
DROP FOREIGN KEY fk_drug_capture_zone;

ALTER TABLE electus_gangs_weed_plants
DROP FOREIGN KEY fk_plants_zone;