/**
 * MockDatabase - Simulating backend behavior based on db_schema.sql
 */
class MockDatabase {
    constructor() {
        this.initData();
    }

    initData() {
        // 1. Members (Buyers)
        this.members = [
            { id: 1001, username: 'user001', real_name: '王小明' },
            { id: 1002, username: 'user002', real_name: '陳大文' }
        ];

        // 2. Sellers
        this.sellers = [
            { id: 1, username: 'TicketMasterTW', shop_name: '台灣票務大王', status: 'active' }
        ];

        // 3. Events & Sessions
        this.events = [
            { id: 101, title: '周杰倫嘉年華世界巡迴演唱會 - 臺北站', poster: 'jay.jpg' },
            { id: 102, title: 'aMEI ASMR MAX 演唱會 - 高雄站', poster: 'amei.jpg' },
            { id: 103, title: 'Maroon 5 Asia Tour 2025 - Kaohsiung', poster: 'm5.jpg' },
            { id: 104, title: 'BLACKPINK BORN PINK FINALE - Taipei', poster: 'bp.jpg' },
            { id: 105, title: 'Coldplay: Music of the Spheres - Kaohsiung', poster: 'coldplay.jpg' }
        ];

        this.sessions = [
            // Jay Chou (Taipei Dome)
            { id: 201, event_id: 101, session_time: '2025-12-31T20:00:00', venue: '臺北大巨蛋' },
            { id: 202, event_id: 101, session_time: '2026-01-01T19:30:00', venue: '臺北大巨蛋' },
            { id: 203, event_id: 101, session_time: '2026-01-02T19:30:00', venue: '臺北大巨蛋' },
            // aMEI (Kaohsiung Arena)
            { id: 204, event_id: 102, session_time: '2025-12-25T19:30:00', venue: '高雄巨蛋' },
            { id: 205, event_id: 102, session_time: '2025-12-26T19:30:00', venue: '高雄巨蛋' },
            { id: 206, event_id: 102, session_time: '2025-12-31T21:30:00', venue: '高雄巨蛋' },
            // Maroon 5 (Kaohsiung National Stadium)
            { id: 207, event_id: 103, session_time: '2025-02-14T20:00:00', venue: '高雄世運主場館' },
            // BLACKPINK (Taipei Dome)
            { id: 208, event_id: 104, session_time: '2026-03-18T19:00:00', venue: '臺北大巨蛋' },
            { id: 209, event_id: 104, session_time: '2026-03-19T19:00:00', venue: '臺北大巨蛋' },
            // Coldplay (Kaohsiung National Stadium)
            { id: 210, event_id: 105, session_time: '2025-11-11T19:30:00', venue: '高雄世運主場館' },
            { id: 211, event_id: 105, session_time: '2025-11-12T19:30:00', venue: '高雄世運主場館' }
        ];

        // --- Generate Large Volume of Mock Data for Testing ---
        const venues = ['台北小巨蛋', '高雄巨蛋', '臺北流行音樂中心', 'Zepp New Taipei', 'Legacy Taipei'];
        const artists = ['五月天', '蔡依林', '林俊傑', '告五人', '草東沒有派對', '伍佰', '動力火車', '田馥甄'];

        for (let i = 1; i <= 60; i++) {
            const artist = artists[Math.floor(Math.random() * artists.length)];
            const venue = venues[Math.floor(Math.random() * venues.length)];
            const evId = 1000 + i;

            this.events.push({
                id: evId,
                title: `${artist} 2026 巡迴演唱會 - ${i}號場`,
                poster: 'default.jpg'
            });

            // Add 1-3 sessions per event
            const sessCount = Math.floor(Math.random() * 3) + 1;
            for (let j = 0; j < sessCount; j++) {
                this.sessions.push({
                    id: 20000 + (i * 10) + j,
                    event_id: evId,
                    session_time: new Date(2026, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1, 19, 30).toISOString(),
                    venue: venue
                });
            }
        }

        // 3.1 Session Areas (Standardized)
        this.sessionAreas = [];
        this.sessions.forEach(session => {
            let areas = [];
            // Determine Type based on venue or event
            if (session.venue.includes('大巨蛋')) {
                areas = this._generateAreas(session.id, 'DOME_JAY');
            } else if (session.venue.includes('高雄巨蛋')) {
                areas = this._generateAreas(session.id, 'ARENA_AMEI');
            } else {
                areas = this._generateAreas(session.id, 'STADIUM');
            }
            this.sessionAreas.push(...areas);
        });

        // 4. Seller Tickets (Inventory)
        this.tickets = [];
        this._generateMockTickets();

        // 6. Orders
        // 6. Orders (Enriched with Event, Recipient, Payment Info)
        this.orders = [
            {
                id: 'ORD-2025-001',
                buyer_name: '王小明',
                buyer_id: 'USER_001',
                total_amount: 11000,
                status: 'paid',
                created_at: '2025-12-31 10:30',
                event_title: '周杰倫嘉年華世界巡迴演唱會 - 臺北站',
                session_time: '2025-12-31 20:00',
                venue: '臺北大巨蛋',
                recipient_info: {
                    name: '王小明',
                    phone: '0912-345-678',
                    address: '台北市信義區信義路五段7號 (Taipei 101)'
                },
                payment_info: {
                    method: 'Credit Card',
                    transaction_id: 'TXN_1234567890'
                },
                tracking_number: null,
                items: [
                    { ticket_name: '特區 Rock A - 5排 - 12號', price: 5500 },
                    { ticket_name: '特區 Rock A - 5排 - 13號', price: 5500 }
                ]
            },
            {
                id: 'ORD-2025-002',
                buyer_name: '陳大文',
                buyer_id: 'USER_002',
                total_amount: 3800,
                status: 'shipping', // Shipped
                created_at: '2025-12-31 14:15',
                event_title: 'aMEI ASMR MAX 演唱會 - 高雄站',
                session_time: '2025-12-25 19:30',
                venue: '高雄巨蛋',
                recipient_info: {
                    name: '陳大文',
                    phone: '0922-000-111',
                    address: '高雄市左營區博愛二路777號'
                },
                payment_info: {
                    method: 'LinePay',
                    transaction_id: 'TXN_LINE_9988'
                },
                tracking_number: 'TRK-881239912',
                items: [{ ticket_name: '看台 Stand A - 20排 - 5號', price: 3800 }]
            },
            {
                id: 'ORD-2025-005',
                buyer_name: '張惠妹粉',
                buyer_id: 'USER_005',
                total_amount: 12000,
                status: 'paid',
                created_at: '2025-12-31 11:20',
                event_title: 'aMEI ASMR MAX 演唱會 - 高雄站',
                session_time: '2025-12-31 21:30',
                venue: '高雄巨蛋',
                recipient_info: {
                    name: '張惠妹粉',
                    phone: '0933-444-555',
                    address: '台中市西屯區台灣大道三段'
                },
                payment_info: {
                    method: 'Credit Card',
                    transaction_id: 'TXN_CC_556677'
                },
                tracking_number: null,
                items: [{ ticket_name: '特一區 Vip - 1排 - 8號', price: 6000 }, { ticket_name: '特一區 Vip - 1排 - 9號', price: 6000 }],
                logs: [
                    { status: 'created', time: '2025-12-31 11:20', operator: 'System' },
                    { status: 'paid', time: '2025-12-31 11:25', operator: 'System' }
                ]
            },
            {
                id: 'ORD-2025-010',
                buyer_name: 'Charlie',
                buyer_id: 'USER_010',
                total_amount: 4200,
                status: 'completed',
                created_at: '2025-12-28 10:00',
                event_title: 'Maroon 5 Asia Tour 2025',
                session_time: '2025-02-14 20:00',
                venue: '高雄世運主場館',
                recipient_info: {
                    name: 'Charlie',
                    phone: '0955-666-777',
                    address: '台南市東區中華東路'
                },
                payment_info: {
                    method: 'ATM Transfer',
                    transaction_id: 'TXN_ATM_112233'
                },
                tracking_number: 'TRK-FINISHED-001',
                items: [{ ticket_name: '搖滾區 Rock - 300號', price: 4200 }],
                logs: [
                    { status: 'created', time: '2025-12-28 10:00', operator: 'System' },
                    { status: 'completed', time: '2025-12-28 10:05', operator: 'System' }
                ]
            },
            {
                id: 'ORD-2025-009',
                buyer_name: 'Bob',
                buyer_id: 'USER_009',
                total_amount: 9600,
                status: 'pending',
                created_at: '2025-12-31 17:10',
                event_title: '周杰倫嘉年華世界巡迴演唱會',
                session_time: '2026-01-01 19:30',
                venue: '臺北大巨蛋',
                recipient_info: {
                    name: 'Bob',
                    phone: '0988-777-666',
                    address: '新北市板橋區縣民大道'
                },
                payment_info: null,
                tracking_number: null,
                items: [{ ticket_name: '特區 Rock A - 10排 - 1號', price: 4800 }, { ticket_name: '特區 Rock A - 10排 - 2號', price: 4800 }],
                logs: [
                    { status: 'created', time: '2025-12-31 17:10', operator: 'System' },
                    { status: 'pending', time: '2025-12-31 17:10', operator: 'System' }
                ]
            }
        ];

        // 7. Sub-accounts (Settings)
        this.subAccounts = [
            { id: 1, username: 'Seller_Assistant_01', status: 'active' },
            { id: 2, username: 'Intern_Dave', status: 'active' }
        ];
    }

    _generateAreas(sessionId, type) {
        if (type === 'DOME_JAY') {
            return [
                { id: `3${sessionId}01`, session_id: sessionId, name: '特區 Rock A', total_seats: 500, minPrice: 4800, avgPrice: 5500, maxPrice: 8000 },
                { id: `3${sessionId}02`, session_id: sessionId, name: '特區 Rock B', total_seats: 500, minPrice: 4500, avgPrice: 5200, maxPrice: 7500 },
                { id: `3${sessionId}03`, session_id: sessionId, name: '看台 Stand A', total_seats: 2000, minPrice: 3200, avgPrice: 3800, maxPrice: 4800 },
                { id: `3${sessionId}04`, session_id: sessionId, name: '看台 Stand B', total_seats: 2000, minPrice: 2800, avgPrice: 3200, maxPrice: 4200 },
                { id: `3${sessionId}05`, session_id: sessionId, name: '看台 L2 Vip', total_seats: 100, minPrice: 6000, avgPrice: 8000, maxPrice: 12000 }
            ];
        } else if (type === 'ARENA_AMEI') {
            return [
                { id: `3${sessionId}01`, session_id: sessionId, name: '搖滾區 Rock', total_seats: 800, minPrice: 3800, avgPrice: 4200, maxPrice: 5000 },
                { id: `3${sessionId}02`, session_id: sessionId, name: '特一區 Vip', total_seats: 200, minPrice: 5800, avgPrice: 6000, maxPrice: 12000 },
                { id: `3${sessionId}03`, session_id: sessionId, name: '2F 看台區', total_seats: 3000, minPrice: 2800, avgPrice: 3200, maxPrice: 3800 },
                { id: `3${sessionId}04`, session_id: sessionId, name: '3F 看台區', total_seats: 3000, minPrice: 1800, avgPrice: 2400, maxPrice: 3000 }
            ];
        } else {
            // STADIUM
            return [
                { id: `3${sessionId}01`, session_id: sessionId, name: 'Standing A', total_seats: 3000, minPrice: 3800, avgPrice: 4500, maxPrice: 5500 },
                { id: `3${sessionId}02`, session_id: sessionId, name: 'Standing B', total_seats: 3000, minPrice: 3200, avgPrice: 3800, maxPrice: 4800 },
                { id: `3${sessionId}03`, session_id: sessionId, name: 'Seated C', total_seats: 5000, minPrice: 2800, avgPrice: 3200, maxPrice: 4200 },
                { id: `3${sessionId}04`, session_id: sessionId, name: 'Seated D', total_seats: 8000, minPrice: 1800, avgPrice: 2200, maxPrice: 2800 }
            ];
        }
    }

    _generateMockTickets() {
        const targetSessions = [
            { id: 201, event_id: 101, type: 'DOME_JAY' },     // Jay Chou
            { id: 204, event_id: 102, type: 'ARENA_AMEI' },   // aMEI
            { id: 207, event_id: 103, type: 'STADIUM' }       // Maroon 5
        ];

        const statuses = ['on_shelf', 'on_shelf', 'on_shelf', 'off_shelf', 'sold', 'draft'];

        targetSessions.forEach(sess => {
            const areas = this._generateAreas(sess.id, sess.type);
            // Generate ~12 tickets per session
            for (let i = 0; i < 12; i++) {
                const area = areas[Math.floor(Math.random() * areas.length)];
                const row = Math.floor(Math.random() * 20) + 1;
                const seat = Math.floor(Math.random() * 100) + 1;
                const status = statuses[Math.floor(Math.random() * statuses.length)];

                // Randomize price slightly around average
                let finalPrice = area.avgPrice + (Math.floor(Math.random() * 5) - 2) * 100;

                this.tickets.push({
                    id: `T${2025000 + this.tickets.length + 1}`,
                    event_id: sess.event_id,
                    session_id: sess.id,
                    area_id: area.id,
                    area_name: area.name,
                    row: row,
                    seat: seat,
                    price: finalPrice,
                    status: status,
                    quantity: 1
                });
            }
        });
    }

    // --- Methods ---

    getDashboardStats() {
        const totalRevenue = this.orders
            .filter(o => o.status !== 'cancelled')
            .reduce((sum, o) => sum + o.total_amount, 0);

        const processingOrders = this.orders
            .filter(o => ['pending', 'shipping'].includes(o.status)).length;

        // Mocking Active Tickets count
        const activeTickets = 156;

        return { totalRevenue, processingOrders, activeTickets };
    }

    getEvents() {
        return this.events;
    }

    getSessions(eventId) {
        return this.sessions.filter(s => s.event_id === eventId);
    }

    getRecentOrders(limit = 5) {
        return this.orders.slice(0, limit);
    }

    getAllOrders() {
        return this.orders;
    }

    getSessionAreas(sessionId) {
        return this.sessionAreas.filter(a => a.session_id === sessionId);
    }

    getSessionTickets(sessionId) {
        return this.tickets.filter(t => t.session_id === sessionId);
    }

    getAllTickets() {
        return this.tickets;
    }

    updateTicket(id, updates) {
        const t = this.tickets.find(x => x.id === id);
        if (t) {
            Object.assign(t, updates);
            return true;
        }
        return false;
    }

    deleteTicket(id) {
        this.tickets = this.tickets.filter(t => t.id !== id);
    }

    updateOrder(id, updates) {
        const order = this.orders.find(o => o.id === id);
        if (order) {
            // Check for status change
            if (updates.status && updates.status !== order.status) {
                // Initialize logs if missing
                if (!order.logs) order.logs = [];

                order.logs.push({
                    status: updates.status,
                    time: new Date().toISOString(), // Use format compatible with UI
                    operator: 'Seller' // Default operator
                });
            }

            Object.assign(order, updates);
            return true;
        }
        return false;
    }

    addTicket(ticketData) {
        // Mock adding to DB
        // ticketData: { areaId, price, quantity, batchCode, ... }
        console.log("Adding ticket to DB:", ticketData);
        return true;
    }

    // --- Registration ---
    registerSeller(data) {
        const newId = this.sellers.length + 1;
        const newSeller = {
            id: newId,
            username: data.username,
            shop_name: data.shopName,
            status: 'pending', // Default pending
            created_at: new Date().toISOString()
        };
        this.sellers.push(newSeller);
        console.log("New Seller Application:", newSeller);
        return newSeller;
    }

    // --- Settings Methods ---
    getSubAccounts() {
        return this.subAccounts;
    }

    addSubAccount(user) {
        user.id = Date.now();
        user.status = 'active'; // Default active
        this.subAccounts.push(user);
        return user;
    }

    toggleSubAccountStatus(id) {
        const user = this.subAccounts.find(u => u.id === id);
        if (user) {
            user.status = user.status === 'active' ? 'inactive' : 'active';
        }
    }

    deleteSubAccount(id) {
        this.subAccounts = this.subAccounts.filter(u => u.id !== id);
    }
}

// Global Instance
window.db = new MockDatabase();

// --- Page Logic ---

function initDashboard() {
    const stats = db.getDashboardStats();

    document.getElementById('statRevenue').textContent = Utils.formatCurrency(stats.totalRevenue).replace('TWD', '$'); // Keep it simple with $ sign sometimes
    document.getElementById('statOrders').textContent = stats.processingOrders;
    document.getElementById('statTickets').textContent = stats.activeTickets;

    const tableBody = document.getElementById('dashboardOrderList');
    if (tableBody) {
        tableBody.innerHTML = '';
        db.getRecentOrders(3).forEach(order => {
            const statusInfo = Utils.getStatus(order.status);
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td><span style="color:var(--primary)">${order.id}</span></td>
                <td>${order.items.length} 張票</td>
                <td>${Utils.formatCurrency(order.total_amount)}</td>
                <td><span class="status-badge" style="background:${statusInfo.color}20; color:${statusInfo.color}">${statusInfo.text}</span></td>
            `;
            tableBody.appendChild(tr);
        });
    }
}

function initListingFlow() {
    const areaGrid = document.getElementById('areaGrid');
    if (!areaGrid) return;

    // Use hardcoded session ID 201 for demo
    const areas = db.getSessionAreas(201);

    areas.forEach(area => {
        const btn = document.createElement('div');
        btn.className = 'area-btn glass-card';
        btn.innerHTML = `<strong>${area.name}</strong><br><span style="font-size:0.8rem; opacity:0.7">${area.total_seats} 席</span>`;
        btn.onclick = () => selectArea(area, btn);
        areaGrid.appendChild(btn);
    });

    const priceInput = document.getElementById('priceInput');
    if (priceInput) {
        priceInput.addEventListener('input', (e) => updatePriceMeter(e.target.value));
    }
}

let legacyCurrentArea = null;

function selectArea(area, btnElement) {
    document.querySelectorAll('.area-btn').forEach(b => b.classList.remove('selected'));
    btnElement.classList.add('selected');

    document.getElementById('priceSection').style.display = 'block';

    legacyCurrentArea = area;
    document.getElementById('selectedAreaName').textContent = area.name;
    document.getElementById('compMin').textContent = `$${area.minPrice}`;
    document.getElementById('compAvg').textContent = `$${area.avgPrice}`;
    document.getElementById('compMax').textContent = `$${area.maxPrice}`;

    document.getElementById('priceInput').value = '';
    updatePriceMeter(0);
}

function updatePriceMeter(userPrice) {
    if (!legacyCurrentArea || !userPrice) return;
    const meter = document.getElementById('priceMarker');
    const label = document.getElementById('priceLabel');
    const min = legacyCurrentArea.minPrice * 0.8;
    const max = legacyCurrentArea.maxPrice * 1.2;

    let percent = ((userPrice - min) / (max - min)) * 100;
    percent = Math.max(0, Math.min(100, percent));

    meter.style.left = `${percent}%`;
    label.textContent = `$${userPrice}`;

    if (userPrice < legacyCurrentArea.minPrice) {
        label.style.background = '#22c55e';
        label.textContent += " (超值!)";
    } else if (userPrice > legacyCurrentArea.maxPrice) {
        label.style.background = '#ef4444';
    } else {
        label.style.background = '#eab308';
    }
}

function initOrderFlow() {
    const tableBody = document.getElementById('orderTableBody');
    if (!tableBody) return;

    db.getAllOrders().forEach(order => {
        const statusInfo = Utils.getStatus(order.status);

        const tr = document.createElement('tr');
        tr.className = "cursor-pointer hover:bg-white/5";
        tr.innerHTML = `
            <td><span style="color:var(--primary)">${order.id}</span></td>
            <td>${order.buyer_name}</td>
            <td>${Utils.formatCurrency(order.total_amount)} (${order.items.length} 商品)</td>
            <td><span class="status-badge" style="background:${statusInfo.color}20; color:${statusInfo.color}">${statusInfo.text}</span></td>
            <td>${order.created_at}</td>
            <td><button class="btn-outline" style="padding:4px 8px; font-size:0.8rem">查看</button></td>
        `;

        // Detail Row
        const detailTr = document.createElement('tr');
        detailTr.className = 'item-row';
        detailTr.id = `detail-${order.id}`;

        let itemsHtml = order.items.map(item =>
            `<div style="display:flex; justify-content:space-between; margin-bottom:0.5rem; border-bottom:1px dashed var(--border); padding-bottom:0.5rem">
                <span>🎫 ${item.ticket_name}</span>
                <span>${Utils.formatCurrency(item.price)}</span>
            </div>`
        ).join('');

        detailTr.innerHTML = `
            <td colspan="6">
                <div class="item-detail glass-card">
                    <h4 style="margin:0 0 1rem 0">訂單明細 (Order Items)</h4>
                    ${itemsHtml}
                </div>
            </td>
        `;

        tr.onclick = () => {
            const d = document.getElementById(`detail-${order.id}`);
            d.classList.toggle('show');
        };

        tableBody.appendChild(tr);
        tableBody.appendChild(detailTr);
    });
}
