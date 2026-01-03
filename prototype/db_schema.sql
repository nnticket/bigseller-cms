-- Database Schema for BigSeller (Refined)

-- 1. Members (Buyers / Users)
-- "Users" in the context of the platform are the ticket buyers.
CREATE TABLE members (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '會員ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '使用者名稱',
    password_hash VARCHAR(255) COMMENT '加密密碼',
    real_name VARCHAR(100) COMMENT '真實姓名',
    email VARCHAR(100) COMMENT '電子郵件',
    phone VARCHAR(20) COMMENT '電話號碼',
    country VARCHAR(50) DEFAULT 'Taiwan' COMMENT '國家',
    zip_code VARCHAR(10) COMMENT '郵遞區號',
    address VARCHAR(255) COMMENT '詳細地址',
    status ENUM('active', 'suspended') DEFAULT 'active' COMMENT '帳號狀態(active=啟用, suspended=停權)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間'
) COMMENT='會員資料表 (Members)';

-- 2. Sellers (Big Sellers & Small Sellers)
-- Controlled by the Platform. Requires approval.
CREATE TABLE sellers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '賣家ID',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '賣家帳號',
    password_hash VARCHAR(255) COMMENT '加密密碼',
    shop_name VARCHAR(100) NOT NULL COMMENT '商店顯示名稱',
    company_name VARCHAR(100) COMMENT '公司登記名稱',
    contact_person VARCHAR(100) COMMENT '聯絡人姓名',
    contact_email VARCHAR(100) COMMENT '聯絡人Email',
    contact_phone VARCHAR(20) COMMENT '聯絡電話',
    
    -- Payment Info (from settings.html)
    bank_code VARCHAR(20) COMMENT '銀行代碼',
    bank_name VARCHAR(100) COMMENT '銀行名稱',
    bank_branch_name VARCHAR(100) COMMENT '分行名稱',
    bank_account_name VARCHAR(100) COMMENT '戶名',
    bank_account_number VARCHAR(50) COMMENT '銀行帳號',
    
    percent DECIMAL(5, 2) DEFAULT 0.00 COMMENT '平台抽成百分比',
    balance DECIMAL(15, 2) DEFAULT 0.00 COMMENT '錢包餘額',
    
    -- "pending": Applied, waiting for Platform review
    -- "active": Approved, can list tickets
    -- "suspended": Banned or frozen
    status ENUM('pending', 'active', 'suspended', 'rejected') DEFAULT 'pending' COMMENT '賣家狀態(pending=審核中, active=啟用, suspended=停權, rejected=拒絕)',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '申請時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間'
) COMMENT='賣家資料表 (Sellers)';

-- 3. Venues & Cities
CREATE TABLE cities (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '城市ID',
    name VARCHAR(50) NOT NULL COMMENT '城市名稱',
    country VARCHAR(50) DEFAULT 'Taiwan' COMMENT '國家',
    code VARCHAR(10) COMMENT '城市代碼 (如 TPE, KHH)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間'
) COMMENT='城市資料表 (Cities)';

CREATE TABLE venues (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT '場館ID',
    name VARCHAR(100) NOT NULL COMMENT '場館名稱',
    city_id INT NOT NULL COMMENT '城市ID (關聯 cities table)', 
    address VARCHAR(255) COMMENT '場館地址',
    capacity INT COMMENT '容納人數',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    FOREIGN KEY (city_id) REFERENCES cities(id)
) COMMENT='場館資料表 (Venues)';

-- 4. Events (Concerts/Shows)
CREATE TABLE events (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '活動ID',
    venue_id INT NOT NULL COMMENT '場館ID (關聯 venues table)', 
    title VARCHAR(255) NOT NULL COMMENT '活動主標題',
    sub_title VARCHAR(255) COMMENT '活動副標題',
    poster_url VARCHAR(255) COMMENT '海報圖片路徑 (直式/小圖)',
    banner_url VARCHAR(255) COMMENT '活動橫幅大圖 (橫式/大圖)',
    description TEXT COMMENT '活動描述',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    FOREIGN KEY (venue_id) REFERENCES venues(id)
) COMMENT='活動資料表 (Events)';

-- 5. Event Sessions
CREATE TABLE event_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '場次ID',
    event_id BIGINT NOT NULL COMMENT '活動ID',
    session_time DATETIME NOT NULL COMMENT '場次時間',
    title VARCHAR(100) COMMENT '場次名稱 (如: 首場, 跨年場, 尾場)',
    status ENUM('onsale', 'soldout', 'past') DEFAULT 'onsale' COMMENT '場次狀態 (onsale=熱賣, soldout=完售, past=過期)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
) COMMENT='場次資料表 (Sessions)';

-- 5. Session Areas
CREATE TABLE session_areas (
    id VARCHAR(50) PRIMARY KEY COMMENT '區域ID (複合主鍵)',
    session_id BIGINT NOT NULL COMMENT '所屬場次ID',
    name VARCHAR(100) NOT NULL COMMENT '區域名稱 (如: 特區A)',
    total_seats INT DEFAULT 0 COMMENT '總座位數',
    min_price DECIMAL(10, 2) COMMENT '最低票價',
    avg_price DECIMAL(10, 2) COMMENT '平均票價',
    max_price DECIMAL(10, 2) COMMENT '最高票價',
    FOREIGN KEY (session_id) REFERENCES event_sessions(id) ON DELETE CASCADE
) COMMENT='區域資料表 (Areas)';

-- 6. Tickets (Inventory)
-- Linked to a specifically SELLER
CREATE TABLE tickets (
    id VARCHAR(50) PRIMARY KEY COMMENT '票券ID (唯一)',
    seller_id BIGINT NOT NULL COMMENT '賣家ID',
    event_id BIGINT NOT NULL COMMENT '活動ID',
    session_id BIGINT NOT NULL COMMENT '場次ID',
    area_id VARCHAR(50) NOT NULL COMMENT '區域ID',
    row_code VARCHAR(20) COMMENT '排號',
    seat_code VARCHAR(20) COMMENT '座號',
    quantity INT DEFAULT 1 COMMENT '數量',
    price DECIMAL(10, 2) NOT NULL COMMENT '售價',
    
    status ENUM('draft', 'on_shelf', 'off_shelf', 'locked', 'sold') DEFAULT 'on_shelf' COMMENT '票券狀態 (draft=草稿, on_shelf=上架, off_shelf=下架, locked=鎖定/交易中, sold=已售出)',
    
    batch_code VARCHAR(50) COMMENT '批次代碼',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間',

    FOREIGN KEY (seller_id) REFERENCES sellers(id),
    FOREIGN KEY (event_id) REFERENCES events(id),
    FOREIGN KEY (session_id) REFERENCES event_sessions(id),
    FOREIGN KEY (area_id) REFERENCES session_areas(id)
) COMMENT='票券庫存資料表 (Tickets)';

-- 7. Orders
-- Link Buyer (Member) and Seller
CREATE TABLE orders (
    id VARCHAR(50) PRIMARY KEY COMMENT '訂單ID',
    buyer_id BIGINT NOT NULL COMMENT '買家ID',
    seller_id BIGINT NOT NULL COMMENT '賣家ID',
    
    total_amount DECIMAL(15, 2) NOT NULL COMMENT '訂單總金額',
    platform_fee DECIMAL(15, 2) DEFAULT 0.00 COMMENT '平台手續費',
    payout_amount DECIMAL(15, 2) DEFAULT 0.00 COMMENT '賣家實收金額',
    
    payment_status ENUM('unpaid', 'paid', 'refunded', 'cancelled') DEFAULT 'unpaid' COMMENT '付款狀態',
    shipping_status ENUM('none', 'preparing', 'shipped', 'delivered', 'returned') DEFAULT 'none' COMMENT '物流狀態',
    
    -- Snapshots
    event_snapshot_title VARCHAR(255) COMMENT '活動名稱快照',
    event_snapshot_time DATETIME COMMENT '活動時間快照',
    event_snapshot_venue VARCHAR(100) COMMENT '場館名稱快照',
    
    -- Logistics / Recipient
    recipient_name VARCHAR(100) COMMENT '收件人姓名',
    recipient_phone VARCHAR(50) COMMENT '收件人電話',
    recipient_address VARCHAR(255) COMMENT '收件地址',
    tracking_number VARCHAR(100) COMMENT '物流單號',
    
    -- Payment
    payment_method VARCHAR(50) COMMENT '付款方式',
    payment_txn_id VARCHAR(100) COMMENT '金流交易號',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '訂單建立時間',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '訂單更新時間',

    FOREIGN KEY (buyer_id) REFERENCES members(id),
    FOREIGN KEY (seller_id) REFERENCES sellers(id)
) COMMENT='訂單資料表 (Orders)';

-- 8. Order Items
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '項目ID',
    order_id VARCHAR(50) NOT NULL COMMENT '所屬訂單ID',
    ticket_id VARCHAR(50) NOT NULL COMMENT '票券ID',
    
    price_at_purchase DECIMAL(10, 2) NOT NULL COMMENT '購買時單價',
    ticket_name_snapshot VARCHAR(255) COMMENT '票券顯示名稱快照',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '建立時間',
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id)
) COMMENT='訂單明細資料表 (Order Items)';

-- 9. Order Logs (Status History)
CREATE TABLE order_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '紀錄ID',
    order_id VARCHAR(50) NOT NULL COMMENT '訂單ID',
    status_type ENUM('payment', 'shipping') NOT NULL COMMENT '狀態類型(付款/物流)',
    old_status VARCHAR(50) COMMENT '變更前狀態',
    new_status VARCHAR(50) NOT NULL COMMENT '變更後狀態',
    operator VARCHAR(100) DEFAULT 'System' COMMENT '操作者',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '紀錄時間',
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) COMMENT='訂單歷程資料表 (Order Logs)';

-- Indexes
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_session ON tickets(session_id);
CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_seller ON orders(seller_id);

-- 10. System Settings (Key-Value Store)
CREATE TABLE system_settings (
    setting_key VARCHAR(50) PRIMARY KEY COMMENT '設定鍵名 (Key)',
    setting_value TEXT COMMENT '設定值 (Value)',
    description VARCHAR(255) COMMENT '設定說明',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新時間'
) COMMENT='系統設定表 (System Settings)';

-- ==========================================
-- MOCK DATA INJECTION (Massive Dataset)
-- ==========================================

-- 0. System Settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('register_agreement', '歡迎加入 BigSeller！\n1. 本平台僅提供票券媒合，不負擔交易風險。\n2. 請勿使用外掛程式搶票。\n3. 會員資料將嚴格保密。\n4. 同意以上條款方可註冊。', '會員註冊同意書'),
('site_announcement', '【重要公告】系統將於每週三凌晨 03:00 - 05:00 進行例行維護，造成不便請見諒。', '網站公告'),
('customer_service_email', 'support@bigseller.com', '客服信箱'),
('max_tickets_per_order', '4', '單筆訂單最大購票數');

-- 1. Members (Buyers)
INSERT INTO members (id, username, real_name, email, country, zip_code, address, status) VALUES
(1001, 'user001', '王小明', 'ming@example.com', 'Taiwan', '100', '台北市中正區重慶南路一段122號', 'active'),
(1002, 'user002', '陳大文', 'dawen@example.com', 'Taiwan', '220', '新北市板橋區縣民大道二段7號', 'active'),
(1003, 'alice', 'Alice', 'alice@example.com', 'Taiwan', '407', '台中市西屯區台灣大道三段251號', 'active'),
(1004, 'bob', 'Bob', 'bob@example.com', 'Taiwan', '813', '高雄市左營區博愛二路777號', 'active'),
(1005, 'charlie', 'Charlie', 'charlie@example.com', 'Taiwan', '300', '新竹市東區中央路229號', 'active'),
(1006, 'david', 'David', 'david@example.com', 'Japan', '100-0005', 'Tokyo, Chiyoda City, Marunouchi, 1 Chome−9−1', 'suspended'),
(1007, 'eve', 'Eve', 'eve@example.com', 'South Korea', '04524', 'Seoul, Jung District, Sejong-daero, 110', 'active'),
(1008, 'frank', 'Frank', 'frank@example.com', 'Taiwan', '970', '花蓮縣花蓮市中山路80號', 'active'),
(1009, 'grace', 'Grace', 'grace@example.com', 'Taiwan', '700', '台南市中西區西門路一段658號', 'active'),
(1010, 'heidi', 'Heidi', 'heidi@example.com', 'Hong Kong', '999077', 'Central, Hong Kong', 'active');

-- 2. Sellers
INSERT INTO sellers (id, username, shop_name, company_name, contact_person, status, percent) VALUES
(1, 'TicketMasterTW', '台灣票務大王', '台灣票務股份有限公司', '李老闆', 'active', 2.5),
(2, 'SuperScalper', '黃牛剋星二手票', '正規轉讓行', '張經理', 'active', 5.0),
(3, 'NewSeller01', '新手賣家', '新手工作室', '王小弟', 'pending', 10.0);

-- 3. Cities
INSERT INTO cities (id, name, country, code) VALUES
(1, 'Taipei', 'Taiwan', 'TPE'),
(2, 'Kaohsiung', 'Taiwan', 'KHH'),
(3, 'Taichung', 'Taiwan', 'RMQ'),
(4, 'Taoyuan', 'Taiwan', 'TPE'),
(5, 'Tokyo', 'Japan', 'TYO'),
(6, 'Seoul', 'South Korea', 'SEL'),
(7, 'Hong Kong', 'Hong Kong', 'HKG'),
(8, 'Shanghai', 'China', 'SHA'),
(9, 'Beijing', 'China', 'BJS'),
(10, 'Singapore', 'Singapore', 'SIN'),
(11, 'Bangkok', 'Thailand', 'BKK'),
(12, 'Osaka', 'Japan', 'OSA'),
(13, 'Saitama', 'Japan', 'SAI'),
(14, 'Incheon', 'South Korea', 'ICN'),
(15, 'Macau', 'Macau', 'MFM');

-- 3.1 Venues
INSERT INTO venues (id, name, city_id, capacity) VALUES
-- Taiwan
(1, '臺北大巨蛋 (Taipei Dome)', 1, 40000),
(2, '台北小巨蛋 (Taipei Arena)', 1, 11000),
(3, '高雄巨蛋 (Kaohsiung Arena)', 2, 15000),
(4, '高雄世運主場館 (National Stadium)', 2, 55000),
(5, '台中洲際棒球場', 3, 20000),
(6, '桃園樂天棒球場', 4, 20000),
(7, '台北流行音樂中心 (Taipei Music Center)', 1, 5000),
-- Japan
(11, '東京巨蛋 (Tokyo Dome)', 5, 55000),
(12, '日本武道館 (Nippon Budokan)', 5, 14500),
(13, '埼玉超級競技場 (Saitama Super Arena)', 13, 37000),
(14, '京瓷巨蛋 (Kyocera Dome Osaka)', 12, 36000),
(15, '大阪城大廳 (Osaka-Jo Hall)', 12, 16000),
-- South Korea
(21, '首爾奧林匹克主競技場 (Jamsil)', 6, 69000),
(22, '高尺天空巨蛋 (Gocheok Sky Dome)', 6, 16000),
(23, 'KSPO Dome (Olympic Gymnastics Arena)', 6, 15000),
(24, 'Inspire Arena', 14, 15000),
(25, '首爾世界盃競技場', 6, 66000),
-- China
(31, '梅賽德斯-奔馳文化中心 (Shanghai)', 8, 18000),
(32, '上海體育場 (Shanghai Stadium)', 8, 56000),
(33, '北京國家體育場 (鳥巢)', 9, 80000),
(34, '五棵松體育館 (Wukesong Arena)', 9, 18000),
-- Hong Kong / Macau
(41, '紅磡體育館 (Hong Kong Coliseum)', 7, 12500),
(42, '亞洲國際博覽館 (AsiaWorld-Arena)', 7, 14000),
(43, '啟德體育園 (Kai Tak Sports Park)', 7, 50000),
(44, '澳門威尼斯人金光綜藝館 (Cotai Arena)', 15, 15000),
-- SE Asia
(51, '新加坡國家體育場 (National Stadium)', 10, 55000),
(52, '新加坡室內體育館 (Singapore Indoor Stadium)', 10, 12000),
(53, '曼谷 IMPACT Arena', 11, 12000),
(54, '曼谷拉加曼加拉體育場 (Rajamangala)', 11, 51000);

-- 4. Events
INSERT INTO events (id, venue_id, title, sub_title, poster_url, banner_url) VALUES
(101, 1, '周杰倫嘉年華世界巡迴演唱會', '2025 Taipei Carnival', 'poster_jay.jpg', 'banner_jay.jpg'),
(102, 3, 'aMEI ASMR MAX 演唱會', 'Since 2025 World Tour', 'poster_amei.jpg', 'banner_amei.jpg'),
(103, 4, 'Maroon 5 Asia Tour 2025', 'Live in Kaohsiung', 'poster_m5.jpg', 'banner_m5.jpg'),
(104, 2, '五月天諾亞方舟復刻', '10週年進化無限放大版', 'poster_mayday.jpg', 'banner_mayday.jpg'),
(105, 1, 'BLACKPINK BORN PINK FINALE', 'The Final Encore in Taipei', 'poster_bp.jpg', 'banner_bp.jpg'),
(106, 4, 'Coldplay: Music of the Spheres', 'Kaohsiung Stadium Show', 'poster_coldplay.jpg', 'banner_coldplay.jpg'),
(107, 2, '蔡依林 Ugly Beauty Finale', '怪美的 最終章', 'poster_jolin.jpg', 'banner_jolin.jpg'),
(108, 11, '林俊傑 JJ20 世界巡迴 (Tokyo)', 'Road to 20th Anniversary', 'poster_jj.jpg', 'banner_jj.jpg'),
(109, 11, 'Taylor Swift The Eras Tour Tokyo', 'Japan Exclusive 4 Nights', 'poster_taylor.jpg', 'banner_taylor.jpg'),
(110, 21, 'BTS Reunion Concert Seoul', 'Welcome Home 2026', 'poster_bts.jpg', 'banner_bts.jpg'),
(111, 41, '張學友 60+ 巡迴演唱會', 'Hong Kong Station', 'poster_jacky.jpg', 'banner_jacky.jpg'),
(112, 1, '告五人 帶你飛', 'First Live Tour', 'poster_accusefive.jpg', 'banner_accusefive.jpg'),
(113, 31, '薛之謙 天外來物 (Shanghai)', 'Extraterrestrial Tour', 'poster_joker.jpg', 'banner_joker.jpg'),
(114, 51, 'Ed Sheeran +-=÷x Tour (Singapore)', 'Mathematics Tour Asia', 'poster_ed.jpg', 'banner_ed.jpg');

-- 5. Sessions
-- 5. Sessions
INSERT INTO event_sessions (id, event_id, session_time, title) VALUES
-- Jay Chou (101)
(201, 101, '2025-12-31 20:00:00', '跨年特別場'),
(202, 101, '2026-01-01 19:30:00', '元旦場'),
(203, 101, '2026-01-02 19:30:00', '加開場'),
-- aMEI (102)
(204, 102, '2025-12-25 19:30:00', 'Xmas Party'),
(205, 102, '2025-12-26 19:30:00', 'Boxing Day'),
-- Maroon 5 (103)
(206, 103, '2025-02-14 20:00:00', 'Valentine Special'),
-- Mayday (104)
(207, 104, '2025-12-31 21:00:00', '跨年狂歡夜'),
(208, 104, '2026-01-01 18:30:00', '新年第一天'),
-- BLACKPINK (105)
(209, 105, '2026-03-18 19:00:00', 'Day 1'),
(210, 105, '2026-03-19 19:00:00', 'The Finale'),
-- Coldplay (106)
(211, 106, '2025-11-11 19:30:00', 'Kaohsiung One Night'),
-- Jolin (107)
(212, 107, '2026-05-20 19:30:00', '520 愛你特別場'),
-- JJ (108)
(213, 108, '2026-06-01 19:30:00', 'Tokyo Night'),
-- Taylor Swift (109)
(214, 109, '2026-02-07 18:00:00', 'Tokyo Night 1'),
(215, 109, '2026-02-08 18:00:00', 'Tokyo Night 2'),
-- BTS (110)
(216, 110, '2026-06-13 18:00:00', 'Festa Anniversary'),
-- Jacky Cheung (111)
(217, 111, '2025-12-10 20:00:00', 'Opening Night'),
(218, 111, '2025-12-11 20:00:00', 'Second Night'),
-- Accusefive (112)
(219, 112, '2026-04-04 19:30:00', '兒童節場'),
-- Joker Xue (113)
(220, 113, '2026-07-17 19:30:00', 'Shanghai Home'),
-- Ed Sheeran (114)
(221, 114, '2026-04-18 20:00:00', 'Singapore National Stadium');

-- 6. Session Areas
INSERT INTO session_areas (id, session_id, name, total_seats, min_price, avg_price, max_price) VALUES
-- Jay Chou (201)
('320101', 201, '特區 Rock A', 500, 4800, 5500, 8000), ('320102', 201, '看台 Stand B', 2000, 2000, 2500, 3000),
-- Jay Chou (202)
('320201', 202, '特區 Rock A', 500, 4800, 5500, 8000), ('320202', 202, '看台 Stand B', 2000, 2000, 2500, 3000),
-- aMEI (204)
('320401', 204, '特一區 Vip', 300, 5800, 5800, 5800), ('320402', 204, '紅區 Red', 1000, 3200, 3200, 3200),
-- Maroon 5 (206)
('320601', 206, '搖滾區 GA', 3000, 3800, 3800, 3800), ('320602', 206, '看台區 Seated', 20000, 1800, 2400, 2800),
-- Mayday (207)
('320701', 207, '瘋狂區 Crazy', 1000, 4280, 4280, 4280),
-- BLACKPINK (209)
('320901', 209, 'BORN PINK VIP', 200, 8800, 8800, 8800), ('320902', 209, 'Floor A', 1500, 5800, 5800, 5800),
-- Coldplay (211)
('321101', 211, 'Infinity Station', 500, 6000, 6000, 6000),
-- Taylor Swift (214)
('321401', 214, 'Karma Is My BF Vip', 100, 15000, 15000, 15000), ('321402', 214, 'General Admission', 50000, 5000, 8000, 12000),
-- Additional Areas for diverse tickets
('321201', 212, 'Jolin Floor', 3000, 4500, 4500, 4500),
('321301', 213, 'JJ 20 Zone', 2000, 5000, 5000, 5000),
('321601', 216, 'ARMY Zone', 5000, 9999, 9999, 9999),
('321701', 217, 'Jacky Classic', 1000, 6000, 6000, 6000),
('321901', 219, 'Accusefive GA', 2000, 1500, 1500, 1500);

-- 7. Tickets
-- IDs: T2026 + 3 digits
INSERT INTO tickets (id, seller_id, event_id, session_id, area_id, row_code, seat_code, price, status) VALUES
-- Jay Chou (201) - Sold
('T2026001', 1, 101, 201, '320101', '1', '1', 5500, 'sold'),
('T2026002', 1, 101, 201, '320101', '1', '2', 5500, 'sold'),
('T2026003', 1, 101, 201, '320101', '5', '10', 5500, 'sold'),
('T2026004', 1, 101, 201, '320102', '20', '55', 2500, 'sold'),
-- aMEI (204) - On Shelf
('T2026005', 1, 102, 204, '320401', '3', '8', 5800, 'on_shelf'),
('T2026006', 1, 102, 204, '320401', '3', '9', 5800, 'on_shelf'),
('T2026007', 1, 102, 204, '320402', '10', '12', 3200, 'locked'),
-- Maroon 5 (206)
('T2026008', 1, 103, 206, '320601', 'GA', '1001', 3800, 'sold'),
('T2026009', 1, 103, 206, '320601', 'GA', '1002', 3800, 'sold'),
-- Mayday (207)
('T2026010', 1, 104, 207, '320701', 'A', '1', 4280, 'off_shelf'),
-- BLACKPINK (209)
('T2026011', 1, 105, 209, '320901', 'VIP', '1', 8800, 'sold'),
('T2026012', 1, 105, 209, '320901', 'VIP', '2', 8800, 'sold'),
('T2026013', 1, 105, 209, '320902', '10', '5', 5800, 'on_shelf'),
-- Coldplay (211)
('T2026014', 1, 106, 211, '321101', '1', '100', 6000, 'sold'),
-- Taylor Swift (214)
('T2026015', 1, 109, 214, '321401', '1', '1', 15000, 'off_shelf'),
('T2026016', 1, 109, 214, '321402', 'Stand', '500', 8000, 'on_shelf'),
-- Additional Tickets
('T2026017', 1, 107, 212, '321201', '5', '1', 4500, 'draft'),
('T2026018', 1, 107, 212, '321201', '5', '2', 4500, 'draft'),
('T2026019', 1, 108, 213, '321301', '1', '10', 5000, 'locked'),
('T2026020', 1, 110, 216, '321601', '100', '1', 9999, 'sold'),
('T2026021', 1, 111, 217, '321701', 'Red', '1', 6000, 'sold'),
('T2026022', 1, 112, 219, '321901', 'GA', '900', 1500, 'on_shelf');

-- 7. Orders
INSERT INTO orders (id, buyer_id, seller_id, total_amount, payment_status, shipping_status, created_at, recipient_name, recipient_phone, recipient_address) VALUES
('ORD-2026-001', 1001, 1, 11000, 'paid', 'delivered', '2025-11-01 10:00:00', '王小明', '0912345678', '台北市'),
('ORD-2026-002', 1002, 1, 5500, 'paid', 'shipped', '2025-11-02 14:00:00', '陳大文', '0922333444', '新北市'),
('ORD-2026-003', 1003, 1, 2500, 'paid', 'preparing', '2025-11-05 09:30:00', 'Alice', '0933555666', '台中市'),
('ORD-2026-004', 1005, 1, 7600, 'paid', 'none', '2025-12-01 12:00:00', 'Charlie', '0955666777', '高雄市'),
('ORD-2026-005', 1008, 1, 17600, 'paid', 'preparing', '2026-01-15 15:00:00', 'Frank', '0988999000', '台北市'),
('ORD-2026-006', 1009, 1, 6000, 'unpaid', 'none', '2025-10-30 20:00:00', 'Grace', '0977888999', '台南市'),
-- Additional Orders
('ORD-2026-007', 1010, 1, 9999, 'refunded', 'returned', '2025-09-01 10:00:00', 'Heidi', '0911222333', '基隆市'),
('ORD-2026-008', 1001, 1, 6000, 'paid', 'shipped', '2025-09-05 15:00:00', '王小明', '0912345678', '台北市'),
('ORD-2026-009', 1004, 1, 1500, 'cancelled', 'none', '2026-04-01 09:00:00', 'Bob', '0944555666', '新竹市');

-- 8. Order Items
INSERT INTO order_items (order_id, ticket_id, price_at_purchase, ticket_name_snapshot) VALUES
-- Ord 1: Jay 2 tickets
('ORD-2026-001', 'T2026001', 5500, '周杰倫 - 特區 Rock A'), ('ORD-2026-001', 'T2026002', 5500, '周杰倫 - 特區 Rock A'),
-- Ord 2: Jay 1 single
('ORD-2026-002', 'T2026003', 5500, '周杰倫 - 特區 Rock A'),
-- Ord 3: Jay Cheap
('ORD-2026-003', 'T2026004', 2500, '周杰倫 - 看台 Stand B'),
-- Ord 4: Maroon 5 (2 tickets)
('ORD-2026-004', 'T2026008', 3800, 'Maroon 5 - GA'), ('ORD-2026-004', 'T2026009', 3800, 'Maroon 5 - GA'),
-- Ord 5: BP VIP
('ORD-2026-005', 'T2026011', 8800, 'BLACKPINK - VIP'), ('ORD-2026-005', 'T2026012', 8800, 'BLACKPINK - VIP'),
-- Ord 6: Coldplay
('ORD-2026-006', 'T2026014', 6000, 'Coldplay - Infinity Station'),
-- Ord 7: BTS (Refunded)
('ORD-2026-007', 'T2026020', 9999, 'BTS - VIP'),
-- Ord 8: Jacky Cheung
('ORD-2026-008', 'T2026021', 6000, '張學友 - Red'),
-- Ord 9: Accusefive (Cancelled)
('ORD-2026-009', 'T2026022', 1500, '告五人 - GA');

-- 9. Order Logs
INSERT INTO order_logs (order_id, status_type, old_status, new_status) VALUES
('ORD-2026-001', 'payment', 'unpaid', 'paid'), ('ORD-2026-001', 'shipping', 'none', 'delivered'),
('ORD-2026-002', 'payment', 'unpaid', 'paid'), ('ORD-2026-002', 'shipping', 'none', 'shipped'),
('ORD-2026-005', 'payment', 'unpaid', 'paid'),
('ORD-2026-007', 'payment', 'unpaid', 'paid'), ('ORD-2026-007', 'payment', 'paid', 'refunded'), ('ORD-2026-007', 'shipping', 'shipped', 'returned'),
('ORD-2026-008', 'shipping', 'none', 'shipped'),
('ORD-2026-009', 'payment', 'unpaid', 'cancelled');
