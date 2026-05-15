-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: coach_sport_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts_clienttraininglog`
--

DROP TABLE IF EXISTS `accounts_clienttraininglog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_clienttraininglog` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `time` time(6) NOT NULL,
  `weight` double DEFAULT NULL,
  `height` double DEFAULT NULL,
  `exercises` longtext NOT NULL,
  `notes` longtext NOT NULL,
  `goal` varchar(200) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_clienttrain_client_id_2d9ef2ee_fk_accounts_` (`client_id`),
  CONSTRAINT `accounts_clienttrain_client_id_2d9ef2ee_fk_accounts_` FOREIGN KEY (`client_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_clienttraininglog`
--

LOCK TABLES `accounts_clienttraininglog` WRITE;
/*!40000 ALTER TABLE `accounts_clienttraininglog` DISABLE KEYS */;
INSERT INTO `accounts_clienttraininglog` VALUES (1,'2026-05-05','02:11:00.000000',55,55,'gg','fg','hh','2026-05-05 01:12:05.266435',10);
/*!40000 ALTER TABLE `accounts_clienttraininglog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_coachclient`
--

DROP TABLE IF EXISTS `accounts_coachclient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_coachclient` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `client_name` varchar(120) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `goal` varchar(200) NOT NULL,
  `total_sessions` int(11) NOT NULL,
  `done_sessions` int(11) NOT NULL,
  `paid` tinyint(1) NOT NULL,
  `next_session_date` date DEFAULT NULL,
  `next_session_time` time(6) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `coach_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_coachclient_coach_id_17ea6e25_fk_accounts_user_id` (`coach_id`),
  CONSTRAINT `accounts_coachclient_coach_id_17ea6e25_fk_accounts_user_id` FOREIGN KEY (`coach_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_coachclient`
--

LOCK TABLES `accounts_coachclient` WRITE;
/*!40000 ALTER TABLE `accounts_coachclient` DISABLE KEYS */;
INSERT INTO `accounts_coachclient` VALUES (1,'ahmed','99999999','perte poid',9,0,1,'2026-06-21','20:40:00.000000','ddd','2026-05-05 01:33:47.520923',5),(2,'ahmed','25698277','perte poid',7,1,1,'2026-05-01','12:40:00.000000','cs','2026-05-05 01:37:42.913969',5),(3,'hh','55','ccc',9,3,1,'2026-05-21','14:30:00.000000','fff','2026-05-05 17:45:36.156808',15);
/*!40000 ALTER TABLE `accounts_coachclient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_coachprofile`
--

DROP TABLE IF EXISTS `accounts_coachprofile`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_coachprofile` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bio` longtext NOT NULL,
  `experience` varchar(100) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `location` varchar(150) NOT NULL,
  `name` varchar(100) NOT NULL,
  `speciality` varchar(150) NOT NULL,
  `photo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `accounts_coachprofile_user_id_9eec5bec_fk_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_coachprofile`
--

LOCK TABLES `accounts_coachprofile` WRITE;
/*!40000 ALTER TABLE `accounts_coachprofile` DISABLE KEYS */;
INSERT INTO `accounts_coachprofile` VALUES (1,'jj','jjj',1,'jj','jjkkk','jj',NULL),(2,'','',8,'','kkk','',NULL),(3,'Je suis coach de yoga, passionné(e) par le bien-être et l’harmonie entre le corps et l’esprit. À travers mes séances, je t’accompagne dans la découverte de ton corps, l’amélioration de ta souplesse et la gestion du stress du quotidien.\n\nMon approche est douce et adaptée à tous les niveaux. Que tu sois débutant(e) ou pratiquant(e) confirmé(e), je t’aide à progresser à ton rythme grâce à des postures, des exercices de respiration et des moments de relaxation.\n\nMon objectif est simple : t’aider à te sentir mieux dans ton corps, plus apaisé(e) dans ton esprit et plus aligné(e) avec toi-même.','10 ans',5,'sousse tunisie','malek','Yoga','coach_photos/images.jpeg'),(4,'je suis un coach de fitness j\'ai 10 ans d\'exepriance contacte moi','10 ans',12,'tunis','med','fitness','coach_photos/4.3.2.png'),(5,'je suis coach de box','12 ans',14,'gabes','pope','Boxe','coach_photos/2025-mercedes-amg-gt63-pro.jpg'),(6,'je suis un coach de musculation j\'ai 10 ans d\'expereince dans ce domaine','10 ans d\'experiance',15,'sousse','adem aziez','Musculation','coach_photos/istockphoto-1369509413-170667a.jpg');
/*!40000 ALTER TABLE `accounts_coachprofile` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_conversation`
--

DROP TABLE IF EXISTS `accounts_conversation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_conversation` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `coach_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_conversation_client_id_277db037_fk_accounts_user_id` (`client_id`),
  KEY `accounts_conversation_coach_id_40fc869e_fk_accounts_user_id` (`coach_id`),
  CONSTRAINT `accounts_conversation_client_id_277db037_fk_accounts_user_id` FOREIGN KEY (`client_id`) REFERENCES `accounts_user` (`id`),
  CONSTRAINT `accounts_conversation_coach_id_40fc869e_fk_accounts_user_id` FOREIGN KEY (`coach_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_conversation`
--

LOCK TABLES `accounts_conversation` WRITE;
/*!40000 ALTER TABLE `accounts_conversation` DISABLE KEYS */;
INSERT INTO `accounts_conversation` VALUES (1,'2026-04-28 20:53:46.201126',10,15),(2,'2026-05-04 22:55:44.351008',10,5),(3,'2026-05-05 00:16:21.863079',10,12);
/*!40000 ALTER TABLE `accounts_conversation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_message`
--

DROP TABLE IF EXISTS `accounts_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `text` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `conversation_id` bigint(20) NOT NULL,
  `sender_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_message_conversation_id_1ec6287c_fk_accounts_` (`conversation_id`),
  KEY `accounts_message_sender_id_184dd133_fk_accounts_user_id` (`sender_id`),
  CONSTRAINT `accounts_message_conversation_id_1ec6287c_fk_accounts_` FOREIGN KEY (`conversation_id`) REFERENCES `accounts_conversation` (`id`),
  CONSTRAINT `accounts_message_sender_id_184dd133_fk_accounts_user_id` FOREIGN KEY (`sender_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_message`
--

LOCK TABLES `accounts_message` WRITE;
/*!40000 ALTER TABLE `accounts_message` DISABLE KEYS */;
INSERT INTO `accounts_message` VALUES (1,'ffff','2026-04-28 20:53:53.428412',1,10),(2,'bonjour','2026-04-28 21:07:18.991934',1,15),(3,'je veux inscrire','2026-04-28 21:22:12.748110',1,10),(4,'bonjour','2026-05-04 22:55:49.072350',2,10),(5,'bonsoir','2026-05-04 23:37:42.845554',2,5),(6,'fff','2026-05-05 00:16:25.653651',3,10),(7,'bonsoir','2026-05-05 15:16:37.392816',1,10),(8,'gggg','2026-05-06 08:52:23.209601',2,10);
/*!40000 ALTER TABLE `accounts_message` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_plan`
--

DROP TABLE IF EXISTS `accounts_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_plan` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `price` double NOT NULL,
  `description` longtext NOT NULL,
  `coach_id` bigint(20) NOT NULL,
  `benefits` longtext NOT NULL,
  `duration` varchar(100) NOT NULL,
  `sessions_count` int(11) NOT NULL,
  `level` varchar(20) NOT NULL,
  `category` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_plan_coach_id_2ef495bd_fk_accounts_user_id` (`coach_id`),
  CONSTRAINT `accounts_plan_coach_id_2ef495bd_fk_accounts_user_id` FOREIGN KEY (`coach_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_plan`
--

LOCK TABLES `accounts_plan` WRITE;
/*!40000 ALTER TABLE `accounts_plan` DISABLE KEYS */;
INSERT INTO `accounts_plan` VALUES (1,'yy',55,'yy',1,'yy','02/02/2026',6,'basic','autre'),(3,'mm',99,'mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm',5,'dddddddddddddddddd','56',9,'basic','autre'),(5,'elite',500,'cettte formation et bien',12,'whatsapp','3 mois',9,'basic','autre'),(6,'ville',900,'ddddd',14,'ddd','1 mois',5,'premium','autre'),(7,'aziez',500,'adem',15,'fff','3',9,'basic','autre'),(8,'ggggg',99,'hgg',5,'fff','ggg',5,'basic','autre'),(9,'premier',55,'dddd',5,'jjjj','1 mois',19,'basic','autre'),(10,'elite',600,'effrf\"eef',15,'dafaf','6 semaine',30,'basic','autre'),(11,'premiem',100,'Offrez-vous un moment de détente et de reconnexion avec vous-même grâce à ce forfait de yoga adapté à tous les niveaux. Chaque séance combine des postures, des exercices de respiration et des techniques de relaxation pour améliorer votre souplesse, réduire le stress et renforcer votre corps en douceur.  Ce forfait inclut plusieurs séances personnalisées, encadrées par un coach attentif à vos besoins et à votre progression. Idéal pour instaurer une routine bien-être et retrouver équilibre et sérénité au quotidien.',5,'','3mois',9,'premium','autre');
/*!40000 ALTER TABLE `accounts_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_planimage`
--

DROP TABLE IF EXISTS `accounts_planimage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_planimage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `image` varchar(100) NOT NULL,
  `plan_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_planimage_plan_id_5cc6ad27_fk_accounts_plan_id` (`plan_id`),
  CONSTRAINT `accounts_planimage_plan_id_5cc6ad27_fk_accounts_plan_id` FOREIGN KEY (`plan_id`) REFERENCES `accounts_plan` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_planimage`
--

LOCK TABLES `accounts_planimage` WRITE;
/*!40000 ALTER TABLE `accounts_planimage` DISABLE KEYS */;
INSERT INTO `accounts_planimage` VALUES (7,'plans/images/laravel4.1.png',10),(8,'plans/images/persone.png',10),(9,'plans/images/photo-1575936123452-b67c3203c357.jpeg',10),(10,'plans/images/porsche-911-gts-reveiw-2025-001.jpg',10),(11,'plans/images/unnamed.jpg',10),(13,'plans/images/66ed9599d17aa3c7b2b48d19.webp',11),(14,'plans/images/images_1.jpeg',9),(15,'plans/images/images_1_WfyBSzj.jpeg',8),(16,'plans/images/66ed9599d17aa3c7b2b48d19_GEHbpBC.webp',3);
/*!40000 ALTER TABLE `accounts_planimage` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_trainingsession`
--

DROP TABLE IF EXISTS `accounts_trainingsession`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_trainingsession` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `date` date NOT NULL,
  `time` time(6) NOT NULL,
  `exercises` longtext NOT NULL,
  `status` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `client_id` bigint(20) NOT NULL,
  `coach_id` bigint(20) NOT NULL,
  `plan_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `accounts_trainingsession_client_id_3e4f3967_fk_accounts_user_id` (`client_id`),
  KEY `accounts_trainingsession_coach_id_94856fa0_fk_accounts_user_id` (`coach_id`),
  KEY `accounts_trainingsession_plan_id_e3dd5730_fk_accounts_plan_id` (`plan_id`),
  CONSTRAINT `accounts_trainingsession_client_id_3e4f3967_fk_accounts_user_id` FOREIGN KEY (`client_id`) REFERENCES `accounts_user` (`id`),
  CONSTRAINT `accounts_trainingsession_coach_id_94856fa0_fk_accounts_user_id` FOREIGN KEY (`coach_id`) REFERENCES `accounts_user` (`id`),
  CONSTRAINT `accounts_trainingsession_plan_id_e3dd5730_fk_accounts_plan_id` FOREIGN KEY (`plan_id`) REFERENCES `accounts_plan` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_trainingsession`
--

LOCK TABLES `accounts_trainingsession` WRITE;
/*!40000 ALTER TABLE `accounts_trainingsession` DISABLE KEYS */;
INSERT INTO `accounts_trainingsession` VALUES (1,'Séance Fitness Full Body','2026-05-05','18:00:00.000000','Pompes: 3x15\nSquats: 4x12\nGainage: 3x30 sec','planned','2026-05-05 00:43:05.840968',1,2,1);
/*!40000 ALTER TABLE `accounts_trainingsession` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_user`
--

DROP TABLE IF EXISTS `accounts_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `role` varchar(10) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `speciality` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_user`
--

LOCK TABLES `accounts_user` WRITE;
/*!40000 ALTER TABLE `accounts_user` DISABLE KEYS */;
INSERT INTO `accounts_user` VALUES (1,'pbkdf2_sha256$600000$6WRS5nKGAExiU8SApOyDIL$HPePpeakS0+XbuoBdz1cNs/m9NAyZPxIj/AiUGEUQmA=',NULL,0,'malek','','','malek@test.com',0,1,'2026-04-24 00:01:30.618394','client','12345678',''),(2,'pbkdf2_sha256$600000$ybpJDHqXlU3wS7C4bTGs72$8laRtixDlrwKR4ELwXaz0E0CjCYLwmjRmiuRq26xRfE=',NULL,0,'coach1','','','coach@test.com',0,1,'2026-04-24 00:01:45.735389','coach','12345678','Fitness'),(3,'pbkdf2_sha256$600000$D6vF9LvBi3DMQ79DB8VaZ0$hkNkFdfrlR1AEV43Gq1Dz9A7r91AKhPs1OtGffsZ9s0=',NULL,0,'malekk','','','malek@gmail.com',0,1,'2026-04-24 00:53:18.217724','client','50479374',''),(4,'pbkdf2_sha256$600000$Bw0a0wtRevfG0KXRkx22Hr$XKbhKTQgkLt83D1+ILh381XNQU+AWHXNlwN8623Lh0U=',NULL,0,'adem','','','adem@gmail.com',0,1,'2026-04-24 00:53:59.603468','coach','55555555','fitness'),(5,'pbkdf2_sha256$600000$4ydU3PSzsV2VN4KBhhm4D0$fdvvhVgBKml1tqLo5+gmSgXjqePlatzXxA4DE2Za3n8=',NULL,0,'malekkk','','','mm@kk.com',0,1,'2026-04-24 23:45:54.944507','coach','222222','Yoga'),(6,'pbkdf2_sha256$600000$jAq0e4ysU3Z30P1Qe5sPWe$rYYqdWOQe7PIBhWR6vYg5/Ia96uNVoKsg92y4l9ux1o=',NULL,0,'mm','','','mmm@mm.com',0,1,'2026-04-25 01:49:35.013944','coach','999999','football'),(7,'pbkdf2_sha256$600000$A0twBb5Jap0OlmsvwLQyUb$LjG5lJ4Ez/kqABUCvDpefC5IylOSxqAAyHCazShGByU=',NULL,0,'ademm','','','aa@aa.com',0,1,'2026-04-25 02:12:49.532771','client','6666666',''),(8,'pbkdf2_sha256$600000$LhNsVEaVnsqkaQy4Wt1Gvd$0sAylDhLtgkSo12QZGak39RUTfRNId8nytOHe+3u1n8=',NULL,0,'hhh','','','hhh@hh.com',0,1,'2026-04-25 02:13:25.585631','coach','55555555','hh'),(9,'pbkdf2_sha256$600000$ntZZdmCFKSHwo5wO4vZ6ON$9Y3DQQZQ28+vPw/CGXRefRcO4p4hl1FLdZEI0K4rCdY=',NULL,0,'maleke','','','kkk@kk.com',0,1,'2026-04-25 02:25:45.324185','client','9999999',''),(10,'pbkdf2_sha256$600000$Mvu5icQscsmKVLtnWBH0B6$aePdeJAamednQacnGTsId1UVH4tOqFdsXboKSflAZRs=',NULL,0,'kala','','','kk@kk.com',0,1,'2026-04-27 20:50:52.121911','client','555555',''),(12,'pbkdf2_sha256$600000$yThsiLSrQXmCKxnungJmvL$0Xs2gcmyp57CS+PZrM5VuhdMZjshecJv9RbMjh7g2sE=',NULL,0,'med','','','fff@ffh.com',0,1,'2026-04-27 23:22:03.978086','coach','55555','hhh'),(13,'pbkdf2_sha256$600000$9nyGnVoNZSydoBb94sL8ox$IxXakm9Fcx8S0w+HgEO6cgi4KagwfIdxf0aO+0RVjCk=',NULL,0,'pop','','','pp@pp.com',0,1,'2026-04-28 00:27:08.239929','client','999999',''),(14,'pbkdf2_sha256$600000$vlQyDyVifH41QK2SQpCUI4$Ml0rSjDL7dbAory7wADS3+ISpmDyqq0F35iPdww29qY=',NULL,0,'pope','','','pp@pp.com',0,1,'2026-04-28 00:27:41.447337','coach','123456','mm'),(15,'pbkdf2_sha256$600000$TLq3A2glsBNJUs39Op8Bqq$V5KeDjiMjzHnomrG8kRQukHra4No/UQmflKADYze3Tw=',NULL,0,'aziez','','','aa@aaa.com',0,1,'2026-04-28 18:13:50.837274','coach','5555555','ddd');
/*!40000 ALTER TABLE `accounts_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_user_groups`
--

DROP TABLE IF EXISTS `accounts_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_user_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_user_groups_user_id_group_id_59c0b32f_uniq` (`user_id`,`group_id`),
  KEY `accounts_user_groups_group_id_bd11a704_fk_auth_group_id` (`group_id`),
  CONSTRAINT `accounts_user_groups_group_id_bd11a704_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `accounts_user_groups_user_id_52b62117_fk_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_user_groups`
--

LOCK TABLES `accounts_user_groups` WRITE;
/*!40000 ALTER TABLE `accounts_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_user_user_permissions`
--

DROP TABLE IF EXISTS `accounts_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_user_user_permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `accounts_user_user_permi_user_id_permission_id_2ab516c2_uniq` (`user_id`,`permission_id`),
  KEY `accounts_user_user_p_permission_id_113bb443_fk_auth_perm` (`permission_id`),
  CONSTRAINT `accounts_user_user_p_permission_id_113bb443_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `accounts_user_user_p_user_id_e4f0a161_fk_accounts_` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_user_user_permissions`
--

LOCK TABLES `accounts_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `accounts_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add content type',4,'add_contenttype'),(14,'Can change content type',4,'change_contenttype'),(15,'Can delete content type',4,'delete_contenttype'),(16,'Can view content type',4,'view_contenttype'),(17,'Can add session',5,'add_session'),(18,'Can change session',5,'change_session'),(19,'Can delete session',5,'delete_session'),(20,'Can view session',5,'view_session'),(21,'Can add user',6,'add_user'),(22,'Can change user',6,'change_user'),(23,'Can delete user',6,'delete_user'),(24,'Can view user',6,'view_user'),(25,'Can add coach profile',7,'add_coachprofile'),(26,'Can change coach profile',7,'change_coachprofile'),(27,'Can delete coach profile',7,'delete_coachprofile'),(28,'Can view coach profile',7,'view_coachprofile'),(29,'Can add plan',8,'add_plan'),(30,'Can change plan',8,'change_plan'),(31,'Can delete plan',8,'delete_plan'),(32,'Can view plan',8,'view_plan'),(33,'Can add plan image',9,'add_planimage'),(34,'Can change plan image',9,'change_planimage'),(35,'Can delete plan image',9,'delete_planimage'),(36,'Can view plan image',9,'view_planimage'),(37,'Can add conversation',10,'add_conversation'),(38,'Can change conversation',10,'change_conversation'),(39,'Can delete conversation',10,'delete_conversation'),(40,'Can view conversation',10,'view_conversation'),(41,'Can add message',11,'add_message'),(42,'Can change message',11,'change_message'),(43,'Can delete message',11,'delete_message'),(44,'Can view message',11,'view_message'),(45,'Can add training session',12,'add_trainingsession'),(46,'Can change training session',12,'change_trainingsession'),(47,'Can delete training session',12,'delete_trainingsession'),(48,'Can view training session',12,'view_trainingsession'),(49,'Can add client training log',13,'add_clienttraininglog'),(50,'Can change client training log',13,'change_clienttraininglog'),(51,'Can delete client training log',13,'delete_clienttraininglog'),(52,'Can view client training log',13,'view_clienttraininglog'),(53,'Can add coach client',14,'add_coachclient'),(54,'Can change coach client',14,'change_coachclient'),(55,'Can delete coach client',14,'delete_coachclient'),(56,'Can view coach client',14,'view_coachclient');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_accounts_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_accounts_user_id` FOREIGN KEY (`user_id`) REFERENCES `accounts_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (13,'accounts','clienttraininglog'),(14,'accounts','coachclient'),(7,'accounts','coachprofile'),(10,'accounts','conversation'),(11,'accounts','message'),(8,'accounts','plan'),(9,'accounts','planimage'),(12,'accounts','trainingsession'),(6,'accounts','user'),(1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'contenttypes','contenttype'),(5,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-04-23 23:59:53.371118'),(2,'contenttypes','0002_remove_content_type_name','2026-04-23 23:59:53.420202'),(3,'auth','0001_initial','2026-04-23 23:59:53.634816'),(4,'auth','0002_alter_permission_name_max_length','2026-04-23 23:59:53.685827'),(5,'auth','0003_alter_user_email_max_length','2026-04-23 23:59:53.691430'),(6,'auth','0004_alter_user_username_opts','2026-04-23 23:59:53.697894'),(7,'auth','0005_alter_user_last_login_null','2026-04-23 23:59:53.705404'),(8,'auth','0006_require_contenttypes_0002','2026-04-23 23:59:53.708763'),(9,'auth','0007_alter_validators_add_error_messages','2026-04-23 23:59:53.715738'),(10,'auth','0008_alter_user_username_max_length','2026-04-23 23:59:53.722414'),(11,'auth','0009_alter_user_last_name_max_length','2026-04-23 23:59:53.729883'),(12,'auth','0010_alter_group_name_max_length','2026-04-23 23:59:53.761359'),(13,'auth','0011_update_proxy_permissions','2026-04-23 23:59:53.768968'),(14,'auth','0012_alter_user_first_name_max_length','2026-04-23 23:59:53.777687'),(15,'accounts','0001_initial','2026-04-23 23:59:54.023641'),(16,'admin','0001_initial','2026-04-23 23:59:54.128069'),(17,'admin','0002_logentry_remove_auto_add','2026-04-23 23:59:54.135368'),(18,'admin','0003_logentry_add_action_flag_choices','2026-04-23 23:59:54.142611'),(19,'sessions','0001_initial','2026-04-23 23:59:54.175399'),(20,'accounts','0002_plan_coachprofile','2026-04-25 00:28:12.351825'),(21,'accounts','0003_coachprofile_location_coachprofile_name_and_more','2026-04-25 01:40:04.475169'),(22,'accounts','0004_plan_benefits_plan_duration_plan_sessions_count','2026-04-25 02:01:33.357286'),(23,'accounts','0005_plan_level','2026-04-25 02:06:13.801886'),(24,'accounts','0006_coachprofile_photo','2026-04-27 21:06:08.586887'),(25,'accounts','0007_planimage','2026-04-28 20:05:05.939617'),(26,'accounts','0008_conversation_message','2026-04-28 20:41:55.736568'),(27,'accounts','0009_plan_category','2026-05-04 22:54:56.078293'),(28,'accounts','0010_trainingsession','2026-05-05 00:40:40.178575'),(29,'accounts','0011_clienttraininglog','2026-05-05 00:52:36.380806'),(30,'accounts','0012_coachclient','2026-05-05 01:18:25.236252');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-15  5:22:22
