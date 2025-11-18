CREATE DATABASE IF NOT EXISTS streaming;
USE streaming;

CREATE TABLE IF NOT EXISTS countries (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS languages (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  birthdate DATE NULL,
  country_id INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_country FOREIGN KEY (country_id) REFERENCES countries(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS profiles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  profile_name VARCHAR(100) NOT NULL,
  maturity_rating VARCHAR(10) NOT NULL DEFAULT 'ALL',
  avatar_url VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_profiles_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS devices (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  device_type VARCHAR(50) NOT NULL,
  os VARCHAR(50) NULL,
  app_version VARCHAR(20) NULL,
  last_active_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_devices_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_devices_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sessions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  profile_id INT NOT NULL,
  device_id INT NOT NULL,
  ip VARCHAR(45) NULL,
  token_jti VARCHAR(255) NULL, 
  started_at DATETIME NOT NULL,
  ended_at DATETIME NULL,
  CONSTRAINT fk_sessions_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_sessions_device FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
  INDEX idx_sessions_profile (profile_id),
  INDEX idx_sessions_device (device_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS plans (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL,
  price_cents INT NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'BRL',
  max_profiles TINYINT NOT NULL DEFAULT 1,
  max_devices TINYINT NOT NULL DEFAULT 1,
  quality ENUM('SD','HD','UHD') NOT NULL DEFAULT 'HD',
  downloadable BOOLEAN NOT NULL DEFAULT TRUE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subscriptions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  plan_id INT NOT NULL,
  status ENUM('ACTIVE','PAST_DUE','CANCELED','PAUSED') NOT NULL DEFAULT 'ACTIVE',
  start_date DATE NOT NULL,
  end_date DATE NULL,
  auto_renew BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_sub_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_sub_plan FOREIGN KEY (plan_id) REFERENCES plans(id),
  INDEX idx_sub_user_status (user_id, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  subscription_id INT NOT NULL,
  amount_cents INT NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'BRL',
  provider VARCHAR(50) NOT NULL,
  provider_tx_id VARCHAR(120) NULL,
  status ENUM('PENDING','PAID','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  paid_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_sub FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE,
  INDEX idx_payment_sub (subscription_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS titles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  type ENUM('MOVIE','SERIES') NOT NULL,
  original_title VARCHAR(300) NOT NULL,
  synopsis TEXT NULL,
  release_year SMALLINT NULL,
  age_rating VARCHAR(10) NULL,
  poster_url VARCHAR(500) NULL,
  backdrop_url VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FULLTEXT KEY ft_titles (original_title, synopsis)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS series (
  title_id INT PRIMARY KEY, 
  CONSTRAINT fk_series_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS seasons (
  id INT PRIMARY KEY AUTO_INCREMENT,
  series_id INT NOT NULL,
  season_number INT NOT NULL,
  name VARCHAR(200) NULL,
  overview TEXT NULL,
  release_year SMALLINT NULL,
  CONSTRAINT fk_seasons_series FOREIGN KEY (series_id) REFERENCES series(title_id) ON DELETE CASCADE,
  UNIQUE KEY uq_season (series_id, season_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS episodes (
  id INT PRIMARY KEY AUTO_INCREMENT,
  season_id INT NOT NULL,
  episode_number INT NOT NULL,
  title VARCHAR(300) NOT NULL,
  overview TEXT NULL,
  duration_minutes SMALLINT NULL,
  release_date DATE NULL,
  CONSTRAINT fk_episodes_season FOREIGN KEY (season_id) REFERENCES seasons(id) ON DELETE CASCADE,
  UNIQUE KEY uq_episode (season_id, episode_number)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS movies_details (
  title_id INT PRIMARY KEY, 
  duration_minutes SMALLINT NULL,
  release_date DATE NULL,
  CONSTRAINT fk_movies_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS genres (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS title_genres (
  title_id INT NOT NULL,
  genre_id INT NOT NULL,
  PRIMARY KEY (title_id, genre_id),
  CONSTRAINT fk_tg_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE,
  CONSTRAINT fk_tg_genre FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS people (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(200) NOT NULL,
  birthdate DATE NULL,
  bio TEXT NULL,
  photo_url VARCHAR(500) NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS castings (
  title_id INT NOT NULL,
  person_id INT NOT NULL,
  role ENUM('ACTOR','DIRECTOR','WRITER','PRODUCDUTER','COMPOSER','OTHER') NOT NULL,
  character_name VARCHAR(200) NULL,
  PRIMARY KEY (title_id, person_id, role),
  CONSTRAINT fk_cast_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE,
  CONSTRAINT fk_cast_person FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE,
  INDEX idx_cast_person (person_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS title_audio_languages (
  title_id INT NOT NULL,
  language_id INT NOT NULL,
  PRIMARY KEY (title_id, language_id),
  CONSTRAINT fk_tal_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE,
  CONSTRAINT fk_tal_lang FOREIGN KEY (language_id) REFERENCES languages(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS title_subtitle_languages (
  title_id INT NOT NULL,
  language_id INT NOT NULL,
  PRIMARY KEY (title_id, language_id),
  CONSTRAINT fk_tsl_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE,
  CONSTRAINT fk_tsl_lang FOREIGN KEY (language_id) REFERENCES languages(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS title_availability (
  title_id INT NOT NULL,
  country_id INT NOT NULL,
  available_from DATE NOT NULL,
  available_until DATE NULL,
  PRIMARY KEY (title_id, country_id),
  CONSTRAINT fk_ta_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE,
  CONSTRAINT fk_ta_country FOREIGN KEY (country_id) REFERENCES countries(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS watch_history (
  id INT PRIMARY KEY AUTO_INCREMENT,
  profile_id INT NOT NULL,
  title_id INT NOT NULL,
  episode_id INT NULL, 
  position_seconds INT NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_wh_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  CONSTRAINT fk_wh_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE,
  CONSTRAINT fk_wh_episode FOREIGN KEY (episode_id) REFERENCES episodes(id) ON DELETE SET NULL,
  UNIQUE KEY uq_wh_profile_title_episode (profile_id, title_id, episode_id),
  INDEX idx_wh_profile_updated (profile_id, updated_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ratings_aggregate (
  title_id INT PRIMARY KEY, 
  avg_rating DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  ratings_count INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_ra_title FOREIGN KEY (title_id) REFERENCES titles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE OR REPLACE VIEW v_active_subscriptions AS
SELECT s.*, u.email, p.name AS plan_name
FROM subscriptions s
JOIN users u ON u.id = s.user_id
JOIN plans p ON p.id = s.plan_id
WHERE s.status = 'ACTIVE' AND (s.end_date IS NULL OR s.end_date >= CURRENT_DATE());

CREATE OR REPLACE VIEW v_title_catalog AS
SELECT
  t.id AS title_id,
  t.type,
  t.original_title,
  t.release_year,
  t.age_rating,
  GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ') AS genres,
  ra.avg_rating,
  ra.ratings_count
FROM titles t
LEFT JOIN title_genres tg ON tg.title_id = t.id
LEFT JOIN genres g ON g.id = tg.genre_id
LEFT JOIN ratings_aggregate ra ON ra.title_id = t.id
GROUP BY t.id;

CREATE INDEX IF NOT EXISTS idx_titles_year ON titles(release_year);
CREATE INDEX IF NOT EXISTS idx_titles_type_year ON titles(type, release_year);