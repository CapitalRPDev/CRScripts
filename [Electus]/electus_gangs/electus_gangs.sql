-- Core gang table
CREATE TABLE IF NOT EXISTS `electus_gangs` (
  `owner` varchar(46) DEFAULT NULL,
  `gang_id` int(11) NOT NULL AUTO_INCREMENT,
  `level` int(11) DEFAULT 1,
  `xp` int(11) DEFAULT 0,
  `name` varchar(255) DEFAULT NULL,
  `cash` int(11) DEFAULT 0,
  `dirty_cash` int(11) DEFAULT 0,
  `color` varchar(50) DEFAULT '#FFFFFF',
  `safe_house_zone` int(11) DEFAULT NULL,
  `gang_rep` int(11) DEFAULT 0,
  `logo` MEDIUMTEXT DEFAULT NULL,
  PRIMARY KEY (`gang_id`),
  KEY `idx_gang_owner` (`owner`),
  KEY `idx_gang_name` (`name`(191))
);

CREATE TABLE IF NOT EXISTS `electus_gangs_zones_data` (
  `id` int(11) NOT NULL,
  `name` text DEFAULT NULL,
  `points` longtext DEFAULT NULL,
  `types` text DEFAULT NULL,
  `capture` text DEFAULT NULL,
  `gang_menu` text DEFAULT NULL,
  `laundering_menu` text DEFAULT NULL,
  `capture_time` int(11) DEFAULT 15,
  `laundering_capacity` int(11) DEFAULT 0,
  `max_plants` int(11) DEFAULT 0,
  `max_recruits` int(11) DEFAULT 0,
  `ipl_id` varchar(255) DEFAULT NULL,
  `ipl_marker` text DEFAULT NULL,
  `garage` text DEFAULT NULL,
  `warehouse` text DEFAULT NULL,
  `weed_processing` text DEFAULT NULL,
  `vehicle_spawn_pos` text DEFAULT NULL,
  `max_cash` int(11) DEFAULT 0,
  `min_cash` int(11) DEFAULT 0,
  `max_npc` int(11) DEFAULT 0,
  `min_npc` int(11) DEFAULT 0,
  `zone_attack` tinyint(1) DEFAULT NULL,
  `progress_types` text DEFAULT NULL,
  `min_progress` int(11) DEFAULT NULL,
  `doors` text DEFAULT NULL,
  `warehouse_crates_locations` text DEFAULT NULL,
  `cash_safe` text DEFAULT NULL,
  `hide_from_map` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
);

-- Base tasks progression
CREATE TABLE IF NOT EXISTS `electus_gangs_base_tasks` (
  `gang_id` int(11) NOT NULL,
  `task_stage` int(11) DEFAULT NULL,
  `progress` int(11) DEFAULT NULL,
  PRIMARY KEY (`gang_id`),
  CONSTRAINT `fk_base_tasks_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Current weekly tasks
CREATE TABLE IF NOT EXISTS `electus_gangs_current_weekly_task` (
  `task_id` int(11) NOT NULL
);

-- Door access control
CREATE TABLE IF NOT EXISTS `electus_gangs_doors` (
  `gang_id` int(11) NOT NULL,
  `door_id` varchar(50) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`gang_id`, `door_id`),
  CONSTRAINT `fk_doors_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Drug capture tracking
CREATE TABLE IF NOT EXISTS `electus_gangs_capture_progress` (
  `zone_id` int(11) NOT NULL,
  `gang_id` int(11) NOT NULL,
  `progress` int(11) DEFAULT 0,
  PRIMARY KEY (`zone_id`, `gang_id`)
);

-- Activity logging
CREATE TABLE IF NOT EXISTS `electus_gangs_logs` (
  `gang_id` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` varchar(50) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `date_stamp` datetime DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `idx_logs_gang` (`gang_id`),
  CONSTRAINT `fk_logs_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Gang members
CREATE TABLE IF NOT EXISTS `electus_gangs_members` (
  `gang_id` int(11) NOT NULL,
  `identifier` varchar(46) NOT NULL,
  `role_id` int(11) DEFAULT NULL,
  `joined` datetime DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`gang_id`, `identifier`),
  KEY `idx_member_role` (`role_id`),
  CONSTRAINT `fk_members_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Money laundering operations
CREATE TABLE IF NOT EXISTS `electus_gangs_money_laundering` (
  `zone_id` int(11) NOT NULL,
  `load` int(11) UNSIGNED DEFAULT 0,
  `washed` int(11) UNSIGNED DEFAULT 0,
  PRIMARY KEY (`zone_id`),
  CONSTRAINT `fk_laundering_zone` FOREIGN KEY (`zone_id`)
    REFERENCES `electus_gangs_zones_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Gang roles structure
CREATE TABLE IF NOT EXISTS `electus_gangs_roles` (
  `role_id` int(11) NOT NULL AUTO_INCREMENT,
  `gang_id` int(11) NOT NULL,
  `grade` int(11) DEFAULT NULL,
  `role_data` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`),
  KEY `idx_roles_gang` (`gang_id`),
  CONSTRAINT `fk_roles_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Statistical tracking
CREATE TABLE IF NOT EXISTS `electus_gangs_stats` (
  `gang_id` int(11) NOT NULL,
  `date_stamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `cash` int(11) DEFAULT NULL,
  `dirty_cash` int(11) DEFAULT NULL,
  `members` int(11) DEFAULT NULL,
  `gang_rep` int(11) DEFAULT NULL,
  `zones` int(11) DEFAULT NULL,
  PRIMARY KEY (`gang_id`, `date_stamp`),
  CONSTRAINT `fk_stats_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Financial transactions
CREATE TABLE IF NOT EXISTS `electus_gangs_transactions` (
  `gang_id` int(11) NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `handled_by` varchar(50) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `amount` int(11) DEFAULT 0,
  `date_stamp` datetime DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  KEY `idx_transactions_gang` (`gang_id`),
  CONSTRAINT `fk_transactions_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Gang upgrades
CREATE TABLE IF NOT EXISTS `electus_gangs_upgrades` (
  `gang_id` int(11) NOT NULL,
  `upgrades` json DEFAULT NULL,
  PRIMARY KEY (`gang_id`),
  CONSTRAINT `fk_upgrades_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Vehicle storage
CREATE TABLE IF NOT EXISTS `electus_gangs_vehicles` (
  `gang_id` int(11) NOT NULL,
  `plate` varchar(50) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  PRIMARY KEY (`plate`),
  KEY `idx_vehicles_gang` (`gang_id`),
  CONSTRAINT `fk_vehicles_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Gang conflicts
CREATE TABLE IF NOT EXISTS `electus_gangs_wars` (
  `gang_id_1` int(11) NOT NULL,
  `gang_id_2` int(11) NOT NULL,
  `duration` int(11) DEFAULT NULL,
  `gang_1_progress` int(11) DEFAULT 0,
  `gang_2_progress` int(11) DEFAULT 0,
  `started` datetime DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`gang_id_1`, `gang_id_2`),
  CONSTRAINT `fk_wars_gang1` FOREIGN KEY (`gang_id_1`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_wars_gang2` FOREIGN KEY (`gang_id_2`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `electus_gangs_previous_wars`
(
	`gang_id_1` int(11) NOT NULL,
	`gang_id_2` int(11) NOT NULL,
	`winner_id` int(11) NOT NULL,
	`prize` int(11) NOT NULL
);


-- Weed processing
CREATE TABLE IF NOT EXISTS `electus_gangs_weed_drying` (
  `gang_id` int(11) NOT NULL,
  `rack_id` int(11) NOT NULL,
  `start_time` datetime DEFAULT CURRENT_TIMESTAMP(),
  `weed_index` int(11) DEFAULT NULL,
  KEY `idx_weed_gang` (`gang_id`),
  CONSTRAINT `fk_weed_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Plant growth tracking
CREATE TABLE IF NOT EXISTS `electus_gangs_weed_plants` (
  `zone_id` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coords` text DEFAULT NULL,
  `growth` int(11) DEFAULT 0,
  `health` int(11) DEFAULT 100,
  `water` int(11) DEFAULT 0,
  `fertilizer` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_plants_zone` (`zone_id`)
);

-- Weekly task progress
CREATE TABLE IF NOT EXISTS `electus_gangs_weekly_tasks` (
  `gang_id` int(11) NOT NULL,
  `progress` int(11) DEFAULT NULL,
  PRIMARY KEY (`gang_id`),
  CONSTRAINT `fk_weekly_tasks_gang` FOREIGN KEY (`gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Zone control
CREATE TABLE IF NOT EXISTS `electus_gangs_zones` (
  `controlling_gang_id` int(11) DEFAULT NULL,
  `zone_id` int(11) NOT NULL,
  `captured` datetime DEFAULT CURRENT_TIMESTAMP(),
  PRIMARY KEY (`zone_id`),
  KEY `idx_zones_gang` (`controlling_gang_id`),
  CONSTRAINT `fk_zones_controller` FOREIGN KEY (`controlling_gang_id`)
    REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_zones_data` FOREIGN KEY (`zone_id`)
    REFERENCES `electus_gangs_zones_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Zone relationships
CREATE TABLE IF NOT EXISTS `electus_gangs_zone_connections` (
  `connected_id_1` int(11) NOT NULL,
  `connected_id_2` int(11) NOT NULL,
  PRIMARY KEY (`connected_id_1`, `connected_id_2`),
  CONSTRAINT `fk_connections_zone1` FOREIGN KEY (`connected_id_1`)
    REFERENCES `electus_gangs_zones_data` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_connections_zone2` FOREIGN KEY (`connected_id_2`)
    REFERENCES `electus_gangs_zones_data` (`id`) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS `electus_gangs_zone_attacks` (
  `attacker` int(11) DEFAULT NULL,
  `zone_id` int(11) DEFAULT NULL,
  `activation_time` BIGINT DEFAULT NULL,
  KEY `fk_attacker` (`attacker`),
  KEY `fk_zone_id` (`zone_id`),
  CONSTRAINT `fk_attacker` FOREIGN KEY (`attacker`) REFERENCES `electus_gangs` (`gang_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_zone_id` FOREIGN KEY (`zone_id`) REFERENCES `electus_gangs_zones_data` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

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