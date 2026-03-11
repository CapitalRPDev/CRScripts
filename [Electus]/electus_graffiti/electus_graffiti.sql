CREATE TABLE IF NOT EXISTS `electus_graffiti` (
  `identifier` varchar(46) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`)
);

CREATE TABLE IF NOT EXISTS `electus_graffiti_placed` (
  `identifier` varchar(46) DEFAULT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `graffiti_id` int(11) NOT NULL,
  `width` float DEFAULT NULL,
  `height` float DEFAULT NULL,
  `coords` varchar(255) DEFAULT NULL,
  `direction` varchar(255) DEFAULT NULL,
  `up_vector` varchar(255) DEFAULT NULL,
  `heading` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `graffiti_id` (`graffiti_id`),
  CONSTRAINT `graffiti_id_fk` FOREIGN KEY (`graffiti_id`) REFERENCES `electus_graffiti` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);