-- Database Schema for BigSeller (Refined)

-- 1. Members (Buyers / Users)
-- "Users" in the context of the platform are the ticket buyers.
CREATE TABLE members (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    real_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    status ENUM('active', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Sellers (Big Sellers & Small Sellers)
-- Controlled by the Platform. Requires approval.
CREATE TABLE sellers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    shop_name VARCHAR(100) NOT NULL, -- Display name
    company_name VARCHAR(100),       -- Legal name
    contact_person VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    
    -- Payment Info (from settings.html)
    bank_code VARCHAR(20),
    bank_name VARCHAR(100),
    bank_branch_name VARCHAR(100),
    bank_account_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    
    balance DECIMAL(15, 2) DEFAULT 0.00,
    
    -- "pending": Applied, waiting for Platform review
    -- "active": Approved, can list tickets
    -- "suspended": Banned or frozen
    status ENUM('pending', 'active', 'suspended', 'rejected') DEFAULT 'pending',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Events (Concerts/Shows)
CREATE TABLE events (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    poster_url VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Event Sessions
CREATE TABLE event_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    event_id BIGINT NOT NULL,
    session_time DATETIME NOT NULL,
    venue VARCHAR(100) NOT NULL,
    status ENUM('onsale', 'soldout', 'past') DEFAULT 'onsale',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

-- 5. Session Areas
CREATE TABLE session_areas (
    id VARCHAR(50) PRIMARY KEY,
    session_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    total_seats INT DEFAULT 0,
    min_price DECIMAL(10, 2),
    avg_price DECIMAL(10, 2),
    max_price DECIMAL(10, 2),
    FOREIGN KEY (session_id) REFERENCES event_sessions(id) ON DELETE CASCADE
);

-- 6. Tickets (Inventory)
-- Linked to a specifically SELLER
CREATE TABLE tickets (
    id VARCHAR(50) PRIMARY KEY,
    seller_id BIGINT NOT NULL,
    event_id BIGINT NOT NULL,   -- Pulled up from Session level
    session_id BIGINT NOT NULL, -- Specific session/time
    area_id VARCHAR(50) NOT NULL,
    row_number VARCHAR(20),
    seat_number VARCHAR(20),
    quantity INT DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL,
    
    status ENUM('draft', 'on_shelf', 'off_shelf', 'locked', 'sold') DEFAULT 'on_shelf',
    
    batch_code VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (seller_id) REFERENCES sellers(id),
    FOREIGN KEY (event_id) REFERENCES events(id),
    FOREIGN KEY (session_id) REFERENCES event_sessions(id),
    FOREIGN KEY (area_id) REFERENCES session_areas(id)
);

-- 7. Orders
-- Link Buyer (Member) and Seller
CREATE TABLE orders (
    id VARCHAR(50) PRIMARY KEY,
    buyer_id BIGINT NOT NULL,   -- Links to members table
    seller_id BIGINT NOT NULL,  -- Links to sellers table
    
    total_amount DECIMAL(15, 2) NOT NULL,
    platform_fee DECIMAL(15, 2) DEFAULT 0.00,
    payout_amount DECIMAL(15, 2) DEFAULT 0.00,
    
    payment_status ENUM('unpaid', 'paid', 'refunded', 'cancelled') DEFAULT 'unpaid',
    shipping_status ENUM('none', 'preparing', 'shipped', 'delivered', 'returned') DEFAULT 'none',
    
    -- Snapshots
    event_snapshot_title VARCHAR(255),
    event_snapshot_time DATETIME,
    event_snapshot_venue VARCHAR(100),
    
    -- Logistics / Recipient
    recipient_name VARCHAR(100),
    recipient_phone VARCHAR(50),
    recipient_address VARCHAR(255),
    tracking_number VARCHAR(100),
    
    -- Payment
    payment_method VARCHAR(50),
    payment_txn_id VARCHAR(100),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (buyer_id) REFERENCES members(id),
    FOREIGN KEY (seller_id) REFERENCES sellers(id)
);

-- 8. Order Items
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    ticket_id VARCHAR(50) NOT NULL,
    
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    ticket_name_snapshot VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id)
);

-- 9. Order Logs (Status History)
CREATE TABLE order_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    status_type ENUM('payment', 'shipping') NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    operator VARCHAR(100) DEFAULT 'System',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Indexes
CREATE INDEX idx_tickets_status ON tickets(status);
CREATE INDEX idx_tickets_session ON tickets(session_id);
CREATE INDEX idx_orders_buyer ON orders(buyer_id);
CREATE INDEX idx_orders_seller ON orders(seller_id);

-- ==========================================
-- MOCK DATA INJECTION
-- ==========================================

-- 1. Members (Buyers)
INSERT INTO members (id, username, real_name, email, status) VALUES
(1001, 'user001', '王小明', 'ming@example.com', 'active'),
(1002, 'user002', '陳大文', 'dawen@example.com', 'active'),
(1005, 'user005', '張惠妹粉', 'ameilover@example.com', 'active'),
(1009, 'bob', 'Bob', 'bob@example.com', 'active'),
(1010, 'charlie', 'Charlie', 'charlie@example.com', 'active');

-- 2. Sellers
INSERT INTO sellers (id, username, shop_name, company_name, contact_person, status) VALUES
(1, 'TicketMasterTW', '台灣票務大王', '台灣票務股份有限公司', '李老闆', 'active');
-- New pending seller example
INSERT INTO sellers (id, username, shop_name, company_name, contact_person, status) VALUES
(2, 'NewSeller01', '小張票券', '小張工作室', '張小弟', 'pending');

-- 3. Events
INSERT INTO events (id, title, poster_url) VALUES
(101, '周杰倫嘉年華世界巡迴演唱會 - 臺北站', 'jay.jpg'),
(102, 'aMEI ASMR MAX 演唱會 - 高雄站', 'amei.jpg'),
(103, 'Maroon 5 Asia Tour 2025 - Kaohsiung', 'm5.jpg');

-- 4. Sessions
INSERT INTO event_sessions (id, event_id, session_time, venue) VALUES
(201, 101, '2025-12-31 20:00:00', '臺北大巨蛋'),
(202, 101, '2026-01-01 19:30:00', '臺北大巨蛋'),
(204, 102, '2025-12-25 19:30:00', '高雄巨蛋'),
(206, 102, '2025-12-31 21:30:00', '高雄巨蛋'),
(207, 103, '2025-02-14 20:00:00', '高雄世運主場館');

-- 5. Session Areas
INSERT INTO session_areas (id, session_id, name, total_seats, min_price, avg_price, max_price) VALUES
('320101', 201, '特區 Rock A', 500, 4800, 5500, 8000),
('320102', 201, '特區 Rock B', 500, 4500, 5200, 7500),
('320103', 201, '看台 Stand A', 2000, 3200, 3800, 4800);

-- 6. Tickets
INSERT INTO tickets (id, seller_id, event_id, session_id, area_id, row_number, seat_number, price, status) VALUES
('T2025001', 1, 101, 201, '320101', '5', '12', 5500, 'sold'),
('T2025002', 1, 101, 201, '320101', '5', '13', 5500, 'sold'),
('T2025003', 1, 101, 201, '320101', '10', '1', 4800, 'locked'),
('T2025004', 1, 101, 201, '320101', '10', '2', 4800, 'locked'),
('T2025005', 1, 101, 201, '320101', '1', '1', 5500, 'on_shelf'),
('T2025006', 1, 101, 201, '320101', '1', '2', 5500, 'on_shelf');

-- 7. Orders
INSERT INTO orders (id, buyer_id, seller_id, total_amount, status, created_at, event_snapshot_title, event_snapshot_time, event_snapshot_venue, recipient_name, recipient_phone, recipient_address, payment_method, payment_txn_id, tracking_number) VALUES
('ORD-2025-001', 1001, 1, 11000, 'paid', '2025-12-31 10:30:00', '周杰倫嘉年華世界巡迴演唱會 - 臺北站', '2025-12-31 20:00:00', '臺北大巨蛋', '王小明', '0912-345-678', '台北市信義區信義路五段7號', 'Credit Card', 'TXN_1234567890', NULL),
('ORD-2025-002', 1002, 1, 3800, 'shipping', '2025-12-31 14:15:00', 'aMEI ASMR MAX 演唱會 - 高雄站', '2025-12-25 19:30:00', '高雄巨蛋', '陳大文', '0922-000-111', '高雄市左營區博愛二路777號', 'LinePay', 'TXN_LINE_9988', 'TRK-881239912'),
('ORD-2025-005', 1005, 1, 12000, 'paid', '2025-12-31 11:20:00', 'aMEI ASMR MAX 演唱會 - 高雄站', '2025-12-31 21:30:00', '高雄巨蛋', '張惠妹粉', '0933-444-555', '台中市西屯區台灣大道三段', 'Credit Card', 'TXN_CC_556677', NULL),
('ORD-2025-010', 1010, 1, 4200, 'completed', '2025-12-28 10:00:00', 'Maroon 5 Asia Tour 2025', '2025-02-14 20:00:00', '高雄世運主場館', 'Charlie', '0955-666-777', '台南市東區中華東路', 'ATM Transfer', 'TXN_ATM_112233', 'TRK-FINISHED-001'),
('ORD-2025-009', 1009, 1, 9600, 'pending', '2025-12-31 17:10:00', '周杰倫嘉年華世界巡迴演唱會', '2026-01-01 19:30:00', '臺北大巨蛋', 'Bob', '0988-777-666', '新北市板橋區縣民大道', NULL, NULL, NULL);

-- 8. Order Items
INSERT INTO order_items (order_id, ticket_id, price_at_purchase, ticket_name_snapshot) VALUES
('ORD-2025-001', 'T2025001', 5500, '特區 Rock A - 5排 - 12號'),
('ORD-2025-001', 'T2025002', 5500, '特區 Rock A - 5排 - 13號'),
('ORD-2025-002', 'T2025000_fake', 3800, '看台 Stand A - 20排 - 5號'),
('ORD-2025-005', 'T2025005_fake', 6000, '特一區 Vip - 1排 - 8號'),
('ORD-2025-005', 'T2025006_fake', 6000, '特一區 Vip - 1排 - 9號'),
('ORD-2025-010', 'T2025010_fake', 4200, '搖滾區 Rock - 300號'),
('ORD-2025-009', 'T2025003', 4800, '特區 Rock A - 10排 - 1號'),
('ORD-2025-009', 'T2025004', 4800, '特區 Rock A - 10排 - 2號');
