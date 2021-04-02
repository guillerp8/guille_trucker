CREATE TABLE `truckerroutes` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
	`coords` LONGTEXT NULL DEFAULT NULL COLLATE 'utf8mb4_bin',
	`point` INT(11) NULL DEFAULT NULL,
	`money` INT(200) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=50
;

CREATE TABLE `truckroutes` (
	`id` INT(20) NOT NULL AUTO_INCREMENT,
	`points` INT(11) NULL DEFAULT NULL,
	`money` INT(50) NULL DEFAULT NULL,
	`titulo` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`owner` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=18
;
