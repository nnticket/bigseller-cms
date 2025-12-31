-- 建立資料庫與使用
CREATE DATABASE IF NOT EXISTS concert_ticketing_system;
USE concert_ticketing_system;

-- 1. 會員與權限擴展 (包含小賣家管理)
CREATE TABLE `users` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `parent_seller_id` BIGINT NULL, -- 用於小賣家關聯大帳號
  `username` VARCHAR(50) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('master_seller', 'sub_seller', 'buyer') NOT NULL,
  `real_name` VARCHAR(50),
  `phone` VARCHAR(20),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`parent_seller_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
);

-- 2. 賣家帳務資訊 (僅限大帳使用)
CREATE TABLE `seller_profiles` (
  `user_id` BIGINT PRIMARY KEY,
  `bank_name` VARCHAR(100),
  `bank_account_name` VARCHAR(100),
  `bank_account_number` VARCHAR(50),
  `company_tax_id` VARCHAR(20),
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
);

-- 3. 活動與場次 (基本結構)
CREATE TABLE `events` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `poster_url` VARCHAR(255)
);

CREATE TABLE `event_sessions` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT,
  `session_time` DATETIME NOT NULL,
  `venue_name` VARCHAR(100),
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
);

-- [NEW] 3.1 場次區域 (標準化區域，用於比價與統計)
CREATE TABLE `session_areas` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `session_id` BIGINT NOT NULL,
  `name` VARCHAR(50) NOT NULL, -- e.g. "Rock Zone A", "Red 2B"
  `total_seats` INT DEFAULT NULL,
  FOREIGN KEY (`session_id`) REFERENCES `event_sessions`(`id`)
);

-- 4. 門票管理 (包含複製功能所需的詳細欄位)
CREATE TABLE `seller_tickets` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `seller_id` BIGINT NOT NULL,
  `session_id` BIGINT NOT NULL,
  `area_id` BIGINT NOT NULL, -- [MODIFIED] 改為關聯 session_areas 以利比價
  `batch_code` VARCHAR(50) DEFAULT NULL, -- [NEW] 批次代號，用於整批管理/上架
  `row_name` VARCHAR(20), -- 排
  `seat_number_start` VARCHAR(20), -- 起始號碼 (支援批次/數量概念)
  `quantity` INT DEFAULT 1, -- 數量
  `price` DECIMAL(10, 2) NOT NULL,
  `ticket_type` ENUM('e-ticket', 'paper_ticket') NOT NULL,
  `status` ENUM('unpublished', 'published', 'sold') DEFAULT 'unpublished',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`seller_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`session_id`) REFERENCES `event_sessions`(`id`),
  FOREIGN KEY (`area_id`) REFERENCES `session_areas`(`id`),
  INDEX `idx_batch_code` (`batch_code`),
  INDEX `idx_session_area_price` (`session_id`, `area_id`, `price`) -- 加速比價查詢
);

-- 5. 使用限制 (Checkbox 多選關聯)
CREATE TABLE `restriction_types` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL -- 視線受阻、只有站票、需實名制等
);

CREATE TABLE `ticket_restriction_map` (
  `ticket_id` BIGINT,
  `restriction_id` INT,
  PRIMARY KEY (`ticket_id`, `restriction_id`),
  FOREIGN KEY (`ticket_id`) REFERENCES `seller_tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`restriction_id`) REFERENCES `restriction_types`(`id`)
);

-- 6. 訂單管理 (支援購物車/多票購買)
CREATE TABLE `orders` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `buyer_id` BIGINT NOT NULL,
  `seller_id` BIGINT NOT NULL,
  -- ticket_id 移除，改由 order_items 關聯
  `order_status` ENUM('pending', 'paid', 'shipping', 'completed', 'cancelled') DEFAULT 'pending',
  `total_amount` DECIMAL(10, 2) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`buyer_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`seller_id`) REFERENCES `users`(`id`)
);

-- [NEW] 6.1 訂單明細
CREATE TABLE `order_items` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `ticket_id` BIGINT NOT NULL,
  `quantity` INT DEFAULT 1,
  `price_at_purchase` DECIMAL(10, 2) NOT NULL, -- 記錄當下購買價格
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`),
  FOREIGN KEY (`ticket_id`) REFERENCES `seller_tickets`(`id`)
);

-- 7. 財務與收益報表
CREATE TABLE `seller_revenues` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `seller_id` BIGINT NOT NULL,
  `order_id` BIGINT NOT NULL,
  `gross_amount` DECIMAL(10, 2) NOT NULL, -- 銷售總額
  `platform_fee` DECIMAL(10, 2) NOT NULL, -- 平台抽成
  `net_amount` DECIMAL(10, 2) NOT NULL,   -- 賣家實收
  `payout_status` ENUM('unpaid', 'processing', 'paid') DEFAULT 'unpaid',
  `payout_date` DATETIME NULL,
  FOREIGN KEY (`seller_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
);