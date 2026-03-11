-- Permanent Props table for envi-zone-tool
-- Props stored here will be synced for all players and persist across restarts

CREATE TABLE IF NOT EXISTS `envi_permanent_props` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `resource_name` VARCHAR(64) NOT NULL COMMENT 'Resource that owns this prop',
    `owner_id` VARCHAR(64) DEFAULT NULL COMMENT 'Optional owner identifier (e.g., restaurant_id)',
    `model` VARCHAR(128) NOT NULL COMMENT 'Prop model name or hash',
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `heading` FLOAT NOT NULL DEFAULT 0,
    `metadata` JSON DEFAULT NULL COMMENT 'Optional metadata (zone info, etc.)',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_resource` (`resource_name`),
    INDEX `idx_owner` (`owner_id`),
    INDEX `idx_resource_owner` (`resource_name`, `owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

