DROP DATABASE IF EXISTS soco_development;
DROP DATABASE IF EXISTS soco_test;
CREATE DATABASE soco_development;
CREATE DATABASE soco_test;

DROP USER 'soco'@'localhost';
CREATE USER 'soco'@'localhost' IDENTIFIED BY 'monkey';

GRANT ALL PRIVILEGES ON `soco_development`.* TO 'soco'@'localhost';
GRANT ALL PRIVILEGES ON `soco_test`.* TO 'soco'@'localhost';
