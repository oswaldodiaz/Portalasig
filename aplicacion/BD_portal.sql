-- MySQL dump 10.13  Distrib 5.6.10, for Win32 (x86)
--
-- Host: localhost    Database: portal
-- ------------------------------------------------------
-- Server version	5.6.10

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `administrador`
--

DROP TABLE IF EXISTS `administrador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `administrador` (
  `id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `aministrador_usuario` FOREIGN KEY (`id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `administrador`
--

LOCK TABLES `administrador` WRITE;
/*!40000 ALTER TABLE `administrador` DISABLE KEYS */;
INSERT INTO `administrador` VALUES (151,'2013-10-11 01:00:00','2013-10-11 01:00:00');
/*!40000 ALTER TABLE `administrador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `archivo`
--

DROP TABLE IF EXISTS `archivo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `archivo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `nombre` varchar(200) NOT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  `url` varchar(1000) NOT NULL,
  `nombre_original` varchar(200) NOT NULL,
  `tamano` int(11) NOT NULL,
  `ext` varchar(45) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `archivo_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `archivo_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `archivo`
--

LOCK TABLES `archivo` WRITE;
/*!40000 ALTER TABLE `archivo` DISABLE KEYS */;
/*!40000 ALTER TABLE `archivo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignatura`
--

DROP TABLE IF EXISTS `asignatura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignatura` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `codigo` varchar(4) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `unidades_credito` int(11) NOT NULL,
  `tipo` varchar(45) NOT NULL,
  `requisitos` varchar(200) DEFAULT 'Ninguno',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo_UNIQUE` (`codigo`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `nombre_UNIQUE` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=173 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignatura`
--

LOCK TABLES `asignatura` WRITE;
/*!40000 ALTER TABLE `asignatura` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignatura` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignatura_carrera`
--

DROP TABLE IF EXISTS `asignatura_carrera`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignatura_carrera` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asignatura_id` int(11) NOT NULL,
  `carrera_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `asignatura_carrera_asignatura_idx` (`asignatura_id`),
  KEY `asignatura_carrera_carrera_idx` (`carrera_id`),
  CONSTRAINT `asignatura_carrera_asignatura` FOREIGN KEY (`asignatura_id`) REFERENCES `asignatura` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `asignatura_carrera_carrera` FOREIGN KEY (`carrera_id`) REFERENCES `carrera` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=119 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignatura_carrera`
--

LOCK TABLES `asignatura_carrera` WRITE;
/*!40000 ALTER TABLE `asignatura_carrera` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignatura_carrera` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignatura_clasificacion`
--

DROP TABLE IF EXISTS `asignatura_clasificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignatura_clasificacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asignatura_id` int(11) NOT NULL,
  `clasificacion_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `asignatura_clasificacion_asignatura_idx` (`asignatura_id`),
  KEY `asignatura_clasificacion_clasificacion_idx` (`clasificacion_id`),
  CONSTRAINT `asignatura_clasificacion_asignatura` FOREIGN KEY (`asignatura_id`) REFERENCES `asignatura` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `asignatura_clasificacion_clasificacion` FOREIGN KEY (`clasificacion_id`) REFERENCES `clasificacion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignatura_clasificacion`
--

LOCK TABLES `asignatura_clasificacion` WRITE;
/*!40000 ALTER TABLE `asignatura_clasificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignatura_clasificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asignatura_mencion`
--

DROP TABLE IF EXISTS `asignatura_mencion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asignatura_mencion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asignatura_id` int(11) NOT NULL,
  `mencion_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `asignatura_mencion_mencion_idx` (`mencion_id`),
  KEY `asignatura_mencion_asignatura_idx` (`asignatura_id`),
  CONSTRAINT `asignatura_mencion_asignatura` FOREIGN KEY (`asignatura_id`) REFERENCES `asignatura` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `asignatura_mencion_mencion` FOREIGN KEY (`mencion_id`) REFERENCES `mencion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignatura_mencion`
--

LOCK TABLES `asignatura_mencion` WRITE;
/*!40000 ALTER TABLE `asignatura_mencion` DISABLE KEYS */;
/*!40000 ALTER TABLE `asignatura_mencion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bibliography`
--

DROP TABLE IF EXISTS `bibliography`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bibliography` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` varchar(1000) NOT NULL,
  `autores` varchar(200) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bibliography_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `bibliography_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bibliography`
--

LOCK TABLES `bibliography` WRITE;
/*!40000 ALTER TABLE `bibliography` DISABLE KEYS */;
/*!40000 ALTER TABLE `bibliography` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bitacora`
--

DROP TABLE IF EXISTS `bitacora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bitacora` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) DEFAULT NULL,
  `ip` varchar(45) NOT NULL,
  `descripcion` varchar(1000) NOT NULL,
  `fecha` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bitacora_usuario_idx` (`usuario_id`),
  CONSTRAINT `bitacora_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4319 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitacora`
--

LOCK TABLES `bitacora` WRITE;
/*!40000 ALTER TABLE `bitacora` DISABLE KEYS */;
/*!40000 ALTER TABLE `bitacora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bitacora_sitio_web`
--

DROP TABLE IF EXISTS `bitacora_sitio_web`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bitacora_sitio_web` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `ip` varchar(45) NOT NULL,
  `descripcion` text NOT NULL,
  `fecha` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `bitacora_sitio_web_sitio_web_idx` (`sitio_web_id`),
  KEY `bitacora_sitio_web_usuario_idx` (`usuario_id`),
  CONSTRAINT `bitacora_sitio_web_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `bitacora_sitio_web_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitacora_sitio_web`
--

LOCK TABLES `bitacora_sitio_web` WRITE;
/*!40000 ALTER TABLE `bitacora_sitio_web` DISABLE KEYS */;
/*!40000 ALTER TABLE `bitacora_sitio_web` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calificacion`
--

DROP TABLE IF EXISTS `calificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calificacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `estudiante_id` int(11) NOT NULL,
  `evaluacion_id` int(11) NOT NULL,
  `calificacion` float DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `calificacion_estudiante_idx` (`estudiante_id`),
  KEY `calificacion_evaluacion_idx` (`evaluacion_id`),
  CONSTRAINT `calificacion_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiante` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `calificacion_evaluacion` FOREIGN KEY (`evaluacion_id`) REFERENCES `evaluacion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificacion`
--

LOCK TABLES `calificacion` WRITE;
/*!40000 ALTER TABLE `calificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carrera`
--

DROP TABLE IF EXISTS `carrera`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `carrera` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre_UNIQUE` (`nombre`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrera`
--

LOCK TABLES `carrera` WRITE;
/*!40000 ALTER TABLE `carrera` DISABLE KEYS */;
/*!40000 ALTER TABLE `carrera` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clasificacion`
--

DROP TABLE IF EXISTS `clasificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clasificacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clasificacion`
--

LOCK TABLES `clasificacion` WRITE;
/*!40000 ALTER TABLE `clasificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `clasificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comentario`
--

DROP TABLE IF EXISTS `comentario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comentario` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usuario_id` int(11) NOT NULL,
  `foro_id` int(11) NOT NULL,
  `comentario` varchar(10000) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `comentario_usuario_idx` (`usuario_id`),
  KEY `comentario_foro_idx` (`foro_id`),
  CONSTRAINT `comentario_foro` FOREIGN KEY (`foro_id`) REFERENCES `foro` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `comentario_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comentario`
--

LOCK TABLES `comentario` WRITE;
/*!40000 ALTER TABLE `comentario` DISABLE KEYS */;
/*!40000 ALTER TABLE `comentario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contenido_tematico`
--

DROP TABLE IF EXISTS `contenido_tematico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contenido_tematico` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `descripcion` varchar(1000) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `contenido_tematico_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `contenido_tematico_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenido_tematico`
--

LOCK TABLES `contenido_tematico` WRITE;
/*!40000 ALTER TABLE `contenido_tematico` DISABLE KEYS */;
/*!40000 ALTER TABLE `contenido_tematico` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `docente`
--

DROP TABLE IF EXISTS `docente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `docente` (
  `id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cedula_UNIQUE` (`id`),
  CONSTRAINT `docente_usuario` FOREIGN KEY (`id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `docente`
--

LOCK TABLES `docente` WRITE;
/*!40000 ALTER TABLE `docente` DISABLE KEYS */;
/*!40000 ALTER TABLE `docente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `docente_sitio_web`
--

DROP TABLE IF EXISTS `docente_sitio_web`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `docente_sitio_web` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `docente_id` int(11) NOT NULL,
  `sitio_web_id` int(11) NOT NULL,
  `seccion_id` int(11) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `docente_asignatura_docente_idx` (`docente_id`),
  KEY `docente_sitio_web_idx` (`sitio_web_id`),
  KEY `docente_sitio_web_seccion_idx` (`seccion_id`),
  CONSTRAINT `docente_asignatura_docente` FOREIGN KEY (`docente_id`) REFERENCES `docente` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `docente_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `docente_sitio_web_seccion` FOREIGN KEY (`seccion_id`) REFERENCES `seccion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `docente_sitio_web`
--

LOCK TABLES `docente_sitio_web` WRITE;
/*!40000 ALTER TABLE `docente_sitio_web` DISABLE KEYS */;
/*!40000 ALTER TABLE `docente_sitio_web` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entrega`
--

DROP TABLE IF EXISTS `entrega`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entrega` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `fecha_entrega` datetime NOT NULL,
  `evento_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entrega`
--

LOCK TABLES `entrega` WRITE;
/*!40000 ALTER TABLE `entrega` DISABLE KEYS */;
/*!40000 ALTER TABLE `entrega` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entregable`
--

DROP TABLE IF EXISTS `entregable`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entregable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entrega_id` int(11) NOT NULL,
  `estudiante_id` int(11) NOT NULL,
  `url` varchar(1000) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `nombre_original` varchar(100) NOT NULL,
  `tamano` int(11) NOT NULL,
  `ext` varchar(45) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entregable`
--

LOCK TABLES `entregable` WRITE;
/*!40000 ALTER TABLE `entregable` DISABLE KEYS */;
/*!40000 ALTER TABLE `entregable` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estudiante`
--

DROP TABLE IF EXISTS `estudiante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estudiante` (
  `id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cedula_UNIQUE` (`id`),
  CONSTRAINT `estudiante_usuario` FOREIGN KEY (`id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estudiante`
--

LOCK TABLES `estudiante` WRITE;
/*!40000 ALTER TABLE `estudiante` DISABLE KEYS */;
/*!40000 ALTER TABLE `estudiante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estudiante_seccion_sitio_web`
--

DROP TABLE IF EXISTS `estudiante_seccion_sitio_web`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `estudiante_seccion_sitio_web` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `estudiante_id` int(11) NOT NULL,
  `seccion_sitio_web_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `estudiante_seccion_estudiante_idx` (`estudiante_id`),
  KEY `estudiante_seccion_sitio_web_seccion_sitio_web_idx` (`seccion_sitio_web_id`),
  CONSTRAINT `estudiante_seccion_sitio_web_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiante` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `estudiante_seccion_sitio_web_seccion_sitio_web` FOREIGN KEY (`seccion_sitio_web_id`) REFERENCES `seccion_sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estudiante_seccion_sitio_web`
--

LOCK TABLES `estudiante_seccion_sitio_web` WRITE;
/*!40000 ALTER TABLE `estudiante_seccion_sitio_web` DISABLE KEYS */;
/*!40000 ALTER TABLE `estudiante_seccion_sitio_web` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evaluacion`
--

DROP TABLE IF EXISTS `evaluacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evaluacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  `nombre` varchar(45) NOT NULL,
  `valor` float DEFAULT '0',
  `fecha_inicio` datetime DEFAULT NULL,
  `fecha_fin` datetime DEFAULT NULL,
  `evento_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `evaluacion_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `evaluacion_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evaluacion`
--

LOCK TABLES `evaluacion` WRITE;
/*!40000 ALTER TABLE `evaluacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `evaluacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evento`
--

DROP TABLE IF EXISTS `evento`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `evento` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `titulo` varchar(45) NOT NULL,
  `descripcion` varchar(200) NOT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  `evaluacion_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `evento_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `evento_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evento`
--

LOCK TABLES `evento` WRITE;
/*!40000 ALTER TABLE `evento` DISABLE KEYS */;
/*!40000 ALTER TABLE `evento` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `foro`
--

DROP TABLE IF EXISTS `foro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `foro` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `titulo` varchar(200) NOT NULL,
  `descripcion` varchar(10000) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `foro_sitio_web_idx` (`sitio_web_id`),
  KEY `foro_usuario_id_idx` (`usuario_id`),
  CONSTRAINT `foro_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `foro_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `foro`
--

LOCK TABLES `foro` WRITE;
/*!40000 ALTER TABLE `foro` DISABLE KEYS */;
/*!40000 ALTER TABLE `foro` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `horario`
--

DROP TABLE IF EXISTS `horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `horario` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `seccion_id` int(11) DEFAULT NULL,
  `usuario_id` int(11) NOT NULL,
  `dia` varchar(45) NOT NULL,
  `hora_inicio` int(11) NOT NULL,
  `hora_fin` int(11) NOT NULL,
  `tipo` varchar(45) NOT NULL,
  `aula` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `horario_sitio_web_idx` (`sitio_web_id`),
  KEY `horario_seccion_id_idx` (`seccion_id`),
  KEY `horario_usuario_id_idx` (`usuario_id`),
  CONSTRAINT `horario_seccion_id` FOREIGN KEY (`seccion_id`) REFERENCES `seccion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `horario_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `horario_usuario_id` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `horario`
--

LOCK TABLES `horario` WRITE;
/*!40000 ALTER TABLE `horario` DISABLE KEYS */;
/*!40000 ALTER TABLE `horario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mencion`
--

DROP TABLE IF EXISTS `mencion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mencion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre_UNIQUE` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mencion`
--

LOCK TABLES `mencion` WRITE;
/*!40000 ALTER TABLE `mencion` DISABLE KEYS */;
/*!40000 ALTER TABLE `mencion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mencion_carrera`
--

DROP TABLE IF EXISTS `mencion_carrera`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mencion_carrera` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mencion_id` int(11) NOT NULL,
  `carrera_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `mencion_carrerra_mencion_idx` (`mencion_id`),
  KEY `mencion_carrerar_carrerra_idx` (`carrera_id`),
  CONSTRAINT `mencion_carrera_carrera` FOREIGN KEY (`carrera_id`) REFERENCES `carrera` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `mencion_carrerra_mencion` FOREIGN KEY (`mencion_id`) REFERENCES `mencion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mencion_carrera`
--

LOCK TABLES `mencion_carrera` WRITE;
/*!40000 ALTER TABLE `mencion_carrera` DISABLE KEYS */;
/*!40000 ALTER TABLE `mencion_carrera` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice`
--

DROP TABLE IF EXISTS `notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `titulo` varchar(45) NOT NULL,
  `noticia` varchar(200) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `notice_sitio_web_idx` (`sitio_web_id`),
  KEY `notice_usuario_idx` (`usuario_id`),
  CONSTRAINT `notice_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `notice_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice`
--

LOCK TABLES `notice` WRITE;
/*!40000 ALTER TABLE `notice` DISABLE KEYS */;
/*!40000 ALTER TABLE `notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `objetivo`
--

DROP TABLE IF EXISTS `objetivo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `objetivo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `descripcion` varchar(1000) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `objetivo_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `objetivo_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `objetivo`
--

LOCK TABLES `objetivo` WRITE;
/*!40000 ALTER TABLE `objetivo` DISABLE KEYS */;
/*!40000 ALTER TABLE `objetivo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planificacion`
--

DROP TABLE IF EXISTS `planificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planificacion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sitio_web_id` int(11) NOT NULL,
  `semana` int(11) NOT NULL,
  `titulo` varchar(45) NOT NULL,
  `descripcion` varchar(200) NOT NULL,
  `fecha` datetime NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `planificacion_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `planificacion_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planificacion`
--

LOCK TABLES `planificacion` WRITE;
/*!40000 ALTER TABLE `planificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `planificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `preparador`
--

DROP TABLE IF EXISTS `preparador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `preparador` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `estudiante_id` int(11) NOT NULL,
  `sitio_web_id` int(11) NOT NULL,
  `seccion_id` int(11) DEFAULT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `preparador_sitio_web_idx` (`sitio_web_id`),
  KEY `preparador_estudiante_idx` (`estudiante_id`),
  KEY `preparador_seccion_idx` (`seccion_id`),
  CONSTRAINT `preparador_estudiante` FOREIGN KEY (`estudiante_id`) REFERENCES `estudiante` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `preparador_seccion` FOREIGN KEY (`seccion_id`) REFERENCES `seccion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `preparador_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `preparador`
--

LOCK TABLES `preparador` WRITE;
/*!40000 ALTER TABLE `preparador` DISABLE KEYS */;
/*!40000 ALTER TABLE `preparador` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20130707024331'),('20130707024354'),('20130707024447'),('20130707024502'),('20130707024517'),('20130707024532'),('20130707024550'),('20130707024605'),('20130707024619'),('20130707024633'),('20130707024647'),('20130708033650'),('20130708033716'),('20130708033734'),('20130708033751'),('20130708033808'),('20130708033824'),('20130708033841'),('20130708033857'),('20130708033912'),('20130708033926'),('20130708033941'),('20130708033956'),('20130712070250'),('20130712070316'),('20130712071410'),('20130716021133'),('20130722154045'),('20130812204413'),('20130812204936'),('20130812205659'),('20130812210052'),('20130812211050'),('20130919014213'),('20130919014324'),('20130920163659'),('20130924123502'),('20130924124019'),('20130924124124'),('20130924154949'),('20130924171247'),('20130930040154'),('20130930040424'),('20130930195855'),('20131010205359'),('20131022144226');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seccion`
--

DROP TABLE IF EXISTS `seccion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seccion` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(10) NOT NULL,
  `asignatura_id` int(11) NOT NULL,
  `semestre_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seccion`
--

LOCK TABLES `seccion` WRITE;
/*!40000 ALTER TABLE `seccion` DISABLE KEYS */;
/*!40000 ALTER TABLE `seccion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seccion_sitio_web`
--

DROP TABLE IF EXISTS `seccion_sitio_web`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `seccion_sitio_web` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `seccion_id` int(11) NOT NULL,
  `sitio_web_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `seccion_sitio_web_seccion__idx` (`seccion_id`),
  KEY `seccion_sitio_web_sitio_web_idx` (`sitio_web_id`),
  CONSTRAINT `seccion_sitio_web_seccion_` FOREIGN KEY (`seccion_id`) REFERENCES `seccion` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `seccion_sitio_web_sitio_web` FOREIGN KEY (`sitio_web_id`) REFERENCES `sitio_web` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seccion_sitio_web`
--

LOCK TABLES `seccion_sitio_web` WRITE;
/*!40000 ALTER TABLE `seccion_sitio_web` DISABLE KEYS */;
/*!40000 ALTER TABLE `seccion_sitio_web` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semestre`
--

DROP TABLE IF EXISTS `semestre`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `semestre` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `periodo_academico` varchar(2) NOT NULL,
  `ano_lectivo` int(4) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semestre`
--

LOCK TABLES `semestre` WRITE;
/*!40000 ALTER TABLE `semestre` DISABLE KEYS */;
/*!40000 ALTER TABLE `semestre` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session`
--

DROP TABLE IF EXISTS `session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `session` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_session_on_session_id` (`session_id`),
  KEY `index_session_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session`
--

LOCK TABLES `session` WRITE;
/*!40000 ALTER TABLE `session` DISABLE KEYS */;
INSERT INTO `session` VALUES (4,'5b0a1d86503cd45a74070956d22f473a','BAh7CUkiDHVzdWFyaW8GOgZFRm86DFVzdWFyaW8QOhBAYXR0cmlidXRlc3sP\nSSIHaWQGOwBUaQGXSSILY2VkdWxhBjsAVGkGSSIKY2xhdmUGOwBUSSIlMjEy\nMzJmMjk3YTU3YTVhNzQzODk0YTBlNGE4MDFmYzMGOwBUSSILbm9tYnJlBjsA\nVEkiCkFkbWluBjsAVEkiDWFwZWxsaWRvBjsAVEkiCkFkbWluBjsAVEkiC2Nv\ncnJlbwY7AFRJIitwb3J0YWxkZXNpdGlvc3dlYmNpZW5jaWFzdWN2QGdtYWls\nLmNvbQY7AFRJIgp0b2tlbgY7AFRJIltFa2hIdHJ6a2xxUnBfWGp3SFhUSDJa\ndmxELUU5dWRfZHE3Q2ZnczBnLW9idHlSa1VDUjhCbHkxNGZ3MlRwSGhFQW9m\nY2lkLUUwX3BmRWNTZTkwWnlQdwY7AFRJIgthY3Rpdm8GOwBUaQZJIg9jcmVh\ndGVkX2F0BjsAVEl1OglUaW1lDWBlHMAAALDlBjoLQF96b25lSSIIVVRDBjsA\nVEkiD3VwZGF0ZWRfYXQGOwBUSXU7CA1hZRzAAADgAgY7CUkiCFVUQwY7AFQ6\nDkByZWxhdGlvbjA6GEBjaGFuZ2VkX2F0dHJpYnV0ZXN7ADoYQHByZXZpb3Vz\nbHlfY2hhbmdlZHsAOhZAYXR0cmlidXRlc19jYWNoZXsAOhdAYXNzb2NpYXRp\nb25fY2FjaGV7ADoXQGFnZ3JlZ2F0aW9uX2NhY2hlewA6HEBtYXJrZWRfZm9y\nX2Rlc3RydWN0aW9uRjoPQGRlc3Ryb3llZEY6DkByZWFkb25seUY6EEBuZXdf\ncmVjb3JkRkkiCHJvbAY7AEZvOhJBZG1pbmlzdHJhZG9yEDsHewhJIgdpZAY7\nAFRpAZdJIg9jcmVhdGVkX2F0BjsAVEl1OwgNYWUcwAAAAAAGOwlJIghVVEMG\nOwBUSSIPdXBkYXRlZF9hdAY7AFRJdTsIDWFlHMAAAAAABjsJSSIIVVRDBjsA\nVDsKMDsLewA7DHsAOw17ADsOewA7D3sAOxBGOxFGOxJGOxNGSSIQX2NzcmZf\ndG9rZW4GOwBGSSIxeTdsRWo2YUswbmZlN0VhaGZRQ2EzY252c3BNRFBvUmti\nb1cvMzZ5S2o2MD0GOwBGSSIKZmxhc2gGOwBGbzolQWN0aW9uRGlzcGF0Y2g6\nOkZsYXNoOjpGbGFzaEhhc2gJOgpAdXNlZG86CFNldAY6CkBoYXNoewY6CmV4\naXRvVDoMQGNsb3NlZEY6DUBmbGFzaGVzewY7GUkiPlNlIGVsaW1pbmFyb24g\nbG9zIGVzdHVkaWFudGVzIHNlbGVjY2lvbmFkb3MgZXhpdG9zYW1lbnRlLgY7\nAFQ6CUBub3cw\n','2013-10-22 18:53:25','2013-10-22 19:37:15');
/*!40000 ALTER TABLE `session` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sitio_web`
--

DROP TABLE IF EXISTS `sitio_web`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sitio_web` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `asignatura_id` int(11) NOT NULL,
  `semestre_id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `sitio_web_asignatura_idx` (`asignatura_id`),
  KEY `asdfasdf_idx` (`semestre_id`),
  KEY `odsijfslkd_idx` (`usuario_id`),
  CONSTRAINT `sitio_web_asignatura` FOREIGN KEY (`asignatura_id`) REFERENCES `asignatura` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `sitio_web_semestre` FOREIGN KEY (`semestre_id`) REFERENCES `semestre` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `sitio_web_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sitio_web`
--

LOCK TABLES `sitio_web` WRITE;
/*!40000 ALTER TABLE `sitio_web` DISABLE KEYS */;
/*!40000 ALTER TABLE `sitio_web` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuario` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `cedula` int(11) NOT NULL,
  `clave` varchar(200) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `correo` varchar(45) NOT NULL,
  `token` varchar(200) NOT NULL,
  `activo` int(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cedula_UNIQUE` (`cedula`),
  UNIQUE KEY `correo_UNIQUE` (`correo`),
  UNIQUE KEY `token_UNIQUE` (`token`)
) ENGINE=InnoDB AUTO_INCREMENT=176 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (151,1,'21232f297a57a5a743894a0e4a801fc3','Admin','Admin','portaldesitioswebcienciasucv@gmail.com','EkhHtrzklqRp_XjwHXTH2ZvlD-E9ud_dq7Cfgs0g-obtyRkUCR8Bly14fw2TpHhEAofcid-E0_pfEcSe90ZyPw',1,'2013-10-11 00:57:27','2013-10-11 01:00:46');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-10-22 15:22:45
