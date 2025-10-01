-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: streamix
-- ------------------------------------------------------
-- Server version	5.5.5-10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `assinaturas`
--

DROP TABLE IF EXISTS `assinaturas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assinaturas` (
  `id_assinatura` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `id_plano` int(11) NOT NULL,
  `data_inicio` date NOT NULL,
  `data_fim` date DEFAULT NULL,
  `status_assinatura` enum('ATIVA','CANCELADA','EXPIRADA') NOT NULL,
  PRIMARY KEY (`id_assinatura`),
  KEY `id_usuario` (`id_usuario`),
  KEY `id_plano` (`id_plano`),
  CONSTRAINT `assinaturas_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`),
  CONSTRAINT `assinaturas_ibfk_2` FOREIGN KEY (`id_plano`) REFERENCES `planos` (`id_plano`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assinaturas`
--

LOCK TABLES `assinaturas` WRITE;
/*!40000 ALTER TABLE `assinaturas` DISABLE KEYS */;
/*!40000 ALTER TABLE `assinaturas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conteudos`
--

DROP TABLE IF EXISTS `conteudos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conteudos` (
  `id_conteudo` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) NOT NULL,
  `descricao` text DEFAULT NULL,
  `ano_lancamento` int(11) DEFAULT NULL,
  `classificacao_indicativa` varchar(10) DEFAULT NULL,
  `duracao_minutos` int(11) DEFAULT NULL,
  `genero` varchar(100) DEFAULT NULL,
  `tipo_conteudo` enum('FILME','SERIE') NOT NULL,
  PRIMARY KEY (`id_conteudo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conteudos`
--

LOCK TABLES `conteudos` WRITE;
/*!40000 ALTER TABLE `conteudos` DISABLE KEYS */;
/*!40000 ALTER TABLE `conteudos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `episodios`
--

DROP TABLE IF EXISTS `episodios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `episodios` (
  `id_episodio` int(11) NOT NULL AUTO_INCREMENT,
  `id_temporada` int(11) NOT NULL,
  `numero_episodio` int(11) NOT NULL,
  `titulo_episodio` varchar(255) NOT NULL,
  `descricao` text DEFAULT NULL,
  `duracao_minutos` int(11) NOT NULL,
  `data_lancamento` date DEFAULT NULL,
  PRIMARY KEY (`id_episodio`),
  KEY `id_temporada` (`id_temporada`),
  CONSTRAINT `episodios_ibfk_1` FOREIGN KEY (`id_temporada`) REFERENCES `temporadas` (`id_temporada`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `episodios`
--

LOCK TABLES `episodios` WRITE;
/*!40000 ALTER TABLE `episodios` DISABLE KEYS */;
/*!40000 ALTER TABLE `episodios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `historico_reproducao`
--

DROP TABLE IF EXISTS `historico_reproducao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `historico_reproducao` (
  `id_historico` int(11) NOT NULL AUTO_INCREMENT,
  `id_perfil` int(11) NOT NULL,
  `id_conteudo` int(11) DEFAULT NULL,
  `id_episodio` int(11) DEFAULT NULL,
  `progresso_segundos` int(11) NOT NULL DEFAULT 0,
  `ultima_visualizacao` datetime NOT NULL DEFAULT current_timestamp(),
  `status_reproducao` enum('ASSISTINDO','CONCLUIDO') NOT NULL DEFAULT 'ASSISTINDO',
  PRIMARY KEY (`id_historico`),
  KEY `id_perfil` (`id_perfil`),
  KEY `id_conteudo` (`id_conteudo`),
  KEY `id_episodio` (`id_episodio`),
  CONSTRAINT `historico_reproducao_ibfk_1` FOREIGN KEY (`id_perfil`) REFERENCES `perfis` (`id_perfil`) ON DELETE CASCADE,
  CONSTRAINT `historico_reproducao_ibfk_2` FOREIGN KEY (`id_conteudo`) REFERENCES `conteudos` (`id_conteudo`),
  CONSTRAINT `historico_reproducao_ibfk_3` FOREIGN KEY (`id_episodio`) REFERENCES `episodios` (`id_episodio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `historico_reproducao`
--

LOCK TABLES `historico_reproducao` WRITE;
/*!40000 ALTER TABLE `historico_reproducao` DISABLE KEYS */;
/*!40000 ALTER TABLE `historico_reproducao` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pagamentos`
--

DROP TABLE IF EXISTS `pagamentos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagamentos` (
  `id_pagamento` int(11) NOT NULL AUTO_INCREMENT,
  `id_assinatura` int(11) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `data_pagamento` datetime NOT NULL DEFAULT current_timestamp(),
  `metodo_pagamento` varchar(100) DEFAULT NULL,
  `status_pagamento` enum('APROVADO','RECUSADO','PENDENTE') NOT NULL,
  PRIMARY KEY (`id_pagamento`),
  KEY `id_assinatura` (`id_assinatura`),
  CONSTRAINT `pagamentos_ibfk_1` FOREIGN KEY (`id_assinatura`) REFERENCES `assinaturas` (`id_assinatura`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pagamentos`
--

LOCK TABLES `pagamentos` WRITE;
/*!40000 ALTER TABLE `pagamentos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pagamentos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfis`
--

DROP TABLE IF EXISTS `perfis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfis` (
  `id_perfil` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `nome_perfil` varchar(100) NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `tipo_perfil` enum('ADULTO','INFANTIL') NOT NULL DEFAULT 'ADULTO',
  PRIMARY KEY (`id_perfil`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `perfis_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfis`
--

LOCK TABLES `perfis` WRITE;
/*!40000 ALTER TABLE `perfis` DISABLE KEYS */;
/*!40000 ALTER TABLE `perfis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planos`
--

DROP TABLE IF EXISTS `planos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `planos` (
  `id_plano` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `descricao` text DEFAULT NULL,
  `preco` decimal(10,2) NOT NULL,
  `qualidade_video` varchar(50) DEFAULT NULL,
  `telas_simultaneas` int(11) NOT NULL,
  PRIMARY KEY (`id_plano`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planos`
--

LOCK TABLES `planos` WRITE;
/*!40000 ALTER TABLE `planos` DISABLE KEYS */;
/*!40000 ALTER TABLE `planos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temporadas`
--

DROP TABLE IF EXISTS `temporadas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `temporadas` (
  `id_temporada` int(11) NOT NULL AUTO_INCREMENT,
  `id_serie` int(11) NOT NULL,
  `numero_temporada` int(11) NOT NULL,
  `titulo_temporada` varchar(255) DEFAULT NULL,
  `ano_lancamento` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_temporada`),
  KEY `id_serie` (`id_serie`),
  CONSTRAINT `temporadas_ibfk_1` FOREIGN KEY (`id_serie`) REFERENCES `conteudos` (`id_conteudo`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temporadas`
--

LOCK TABLES `temporadas` WRITE;
/*!40000 ALTER TABLE `temporadas` DISABLE KEYS */;
/*!40000 ALTER TABLE `temporadas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `data_cadastro` datetime NOT NULL DEFAULT current_timestamp(),
  `data_nascimento` date DEFAULT NULL,
  `id_plano_ativo` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`),
  KEY `id_plano_ativo` (`id_plano_ativo`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_plano_ativo`) REFERENCES `planos` (`id_plano`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-30 20:11:03
