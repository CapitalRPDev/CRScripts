CREATE TABLE IF NOT EXISTS `lbracing_accounts` (
    `id` VARCHAR(100) NOT NULL PRIMARY KEY, -- the player identifier

    `username` VARCHAR(100) NOT NULL,
    `avatar` VARCHAR(500) DEFAULT NULL,
    `public_profile` BOOLEAN NOT NULL DEFAULT TRUE,

    `rating` INT UNSIGNED NOT NULL DEFAULT 0,
    `races_won` INT UNSIGNED NOT NULL DEFAULT 0,
    `races_played` INT UNSIGNED NOT NULL DEFAULT 0,
    `money_won` INT UNSIGNED NOT NULL DEFAULT 0,
    `last_race` INT UNSIGNED DEFAULT NULL,

    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_tracks` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

    `creator` VARCHAR(100) NOT NULL, -- the player identifier

    `track_name` VARCHAR(100) NOT NULL,
    `vehicle_type` VARCHAR(100) NOT NULL,
    `track_type` VARCHAR(15) NOT NULL DEFAULT 'circuit', -- circuit or sprint
    `track_length` INT UNSIGNED NOT NULL, -- the track length in meters

    `start_position` LONGTEXT NOT NULL,
    `checkpoints` LONGTEXT NOT NULL,
    `barriers` LONGTEXT,

    `uses` INT UNSIGNED NOT NULL DEFAULT 0,
    `likes` INT UNSIGNED NOT NULL DEFAULT 0,

    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_liked_tracks` (
    `track_id` INT UNSIGNED NOT NULL,
    `player_id` VARCHAR(100) NOT NULL,

    PRIMARY KEY (`track_id`, `player_id`),
    FOREIGN KEY (`track_id`) REFERENCES `lbracing_tracks`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `lbracing_accounts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_races` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `host` VARCHAR(100) NOT NULL, -- the player identifier

    `race_name` VARCHAR(100) NOT NULL,

    `track_id` INT UNSIGNED NOT NULL,

    `vehicle_tiers` TEXT DEFAULT NULL, -- array of vehicle tiers allowed to participate
    `vehicle_class` VARCHAR(100) DEFAULT NULL, -- the vehicle class restriction (if any)
    `vehicle_model` INT DEFAULT NULL, -- the specific vehicle model restriction (if any)

    `laps` TINYINT UNSIGNED NOT NULL DEFAULT 1,

    `starting_prize` INT UNSIGNED NOT NULL DEFAULT 0,
    `entry_fee` INT UNSIGNED NOT NULL DEFAULT 0,
    `payment_method` VARCHAR(50) NOT NULL DEFAULT 'bank',
    `commission` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `prize_distribution` TEXT NOT NULL,

    `participants` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `min_participants` TINYINT UNSIGNED NOT NULL,
    `max_participants` TINYINT UNSIGNED NOT NULL,

    `require_sign_up` BOOLEAN NOT NULL DEFAULT TRUE,
    `invite_only` BOOLEAN NOT NULL DEFAULT FALSE,
    `collision` BOOLEAN NOT NULL DEFAULT TRUE,
    `first_person_only` BOOLEAN NOT NULL DEFAULT FALSE,
    `personal_vehicle` BOOLEAN NOT NULL DEFAULT TRUE,
    `disable_npc_traffic` BOOLEAN NOT NULL DEFAULT FALSE,
    `assign_vehicle` BOOLEAN NOT NULL DEFAULT FALSE,
    `ranked` BOOLEAN NOT NULL DEFAULT TRUE,

    `min_rating` INT UNSIGNED DEFAULT NULL,
    `max_rating` INT UNSIGNED DEFAULT NULL,

    `finished` BOOLEAN NOT NULL DEFAULT FALSE,
    `canceled` BOOLEAN NOT NULL DEFAULT FALSE,

    `start_date` DATETIME NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_repeating_races` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

    `creator` VARCHAR(100) NOT NULL, -- the player identifier

    `original_race_id` INT UNSIGNED NOT NULL,
    `latest_race_id` INT UNSIGNED NOT NULL,

    `tracks` VARCHAR(5000) NOT NULL,

    `repeat_minute_interval` MEDIUMINT UNSIGNED NOT NULL,
    `next_race_date` DATETIME NOT NULL,
    `start_time` SMALLINT UNSIGNED NOT NULL DEFAULT 15, -- minutes before the race starts

    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (`original_race_id`) REFERENCES `lbracing_races`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`latest_race_id`) REFERENCES `lbracing_races`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

ALTER TABLE `lbracing_accounts` ADD FOREIGN KEY (`last_race`) REFERENCES `lbracing_races`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

CREATE TABLE IF NOT EXISTS `lbracing_race_participants` (
    `race_id` INT UNSIGNED NOT NULL,
    `participant_id` VARCHAR(100) NOT NULL,

    `vehicle_tier` VARCHAR(100) DEFAULT NULL,
    `vehicle_model` INT DEFAULT NULL,

    `placing` TINYINT UNSIGNED DEFAULT NULL,
    `rating_change` TINYINT DEFAULT NULL,
    `finish_time` INT UNSIGNED DEFAULT NULL,

    PRIMARY KEY (`race_id`, `participant_id`),
    FOREIGN KEY (`race_id`) REFERENCES `lbracing_races`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`participant_id`) REFERENCES `lbracing_accounts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_race_invites` (
    `race_id` INT UNSIGNED NOT NULL,
    `invitee_id` VARCHAR(100) NOT NULL,
    `inviter_id` VARCHAR(100) NOT NULL,
    `invite_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (`race_id`, `invitee_id`),
    FOREIGN KEY (`race_id`) REFERENCES `lbracing_races`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`invitee_id`) REFERENCES `lbracing_accounts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_track_times` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

    `track_id` INT UNSIGNED NOT NULL,
    `race_id` INT UNSIGNED NOT NULL,
    `player_id` VARCHAR(100) NOT NULL,

    `lap_number` TINYINT UNSIGNED NOT NULL,
    `lap_time` INT UNSIGNED NOT NULL,
    `vehicle_tier` VARCHAR(100) NOT NULL,
    `vehicle_model` INT DEFAULT NULL,

    UNIQUE KEY (`track_id`, `race_id`, `player_id`, `lap_number`),
    FOREIGN KEY (`track_id`) REFERENCES `lbracing_tracks`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`race_id`) REFERENCES `lbracing_races`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `lbracing_accounts`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `lbracing_converted_scripts` (
    `script_name` VARCHAR(100) NOT NULL PRIMARY KEY
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
