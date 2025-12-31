/**
 * MockDatabase - Simulating backend behavior based on db_schema.sql
 */
class MockDatabase {
    constructor() {
        this.initData();
    }

    initData() {
        // 1. Users (Sellers)
        this.sellers = [
            { id: 1, username: 'TicketMasterTW', real_name: '台灣票務大王', balance: 0 }
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

        // 6. Orders
        this.orders = [
            {
                id: 'ORD-2025-001',
                buyer_name: '王小明',
                total_amount: 11000,
                status: 'paid',
                created_at: '2025-12-31 10:30',
                items: [
                    { ticket_name: '特區 Rock A - 5排 - 12號', price: 5500 },
                    { ticket_name: '特區 Rock A - 5排 - 13號', price: 5500 }
                ]
            },
            { id: 'ORD-2025-002', buyer_name: '陳大文', total_amount: 3800, status: 'shipping', created_at: '2025-12-31 14:15', items: [{ ticket_name: '看台 Stand A - 20排 - 5號', price: 3800 }] },
            { id: 'ORD-2025-003', buyer_name: '吳美丽', total_amount: 16500, status: 'completed', created_at: '2025-12-30 09:12', items: [{ ticket_name: '特區 Rock A - 1排 - 1號', price: 5500 }, { ticket_name: '特區 Rock A - 1排 - 2號', price: 5500 }, { ticket_name: '特區 Rock A - 1排 - 3號', price: 5500 }] },
            { id: 'ORD-2025-004', buyer_name: '林志豪', total_amount: 3200, status: 'pending', created_at: '2025-12-31 16:45', items: [{ ticket_name: '看台 Stand B - 45排 - 10號', price: 3200 }] },
            // New Orders
            { id: 'ORD-2025-005', buyer_name: '張惠妹粉', total_amount: 12000, status: 'paid', created_at: '2025-12-31 11:20', items: [{ ticket_name: '特一區 Vip - 1排 - 8號', price: 6000 }, { ticket_name: '特一區 Vip - 1排 - 9號', price: 6000 }] },
            { id: 'ORD-2025-006', buyer_name: 'Kevine', total_amount: 7000, status: 'paid', created_at: '2025-12-31 13:00', items: [{ ticket_name: 'Standing A - Seq 102', price: 3500 }, { ticket_name: 'Standing A - Seq 103', price: 3500 }] },
            { id: 'ORD-2025-007', buyer_name: 'John Doe', total_amount: 2200, status: 'cancelled', created_at: '2025-12-29 18:00', items: [{ ticket_name: 'Seated B - Row 55 - 12', price: 2200 }] },
            { id: 'ORD-2025-008', buyer_name: 'Alice', total_amount: 4500, status: 'shipping', created_at: '2025-12-31 09:00', items: [{ ticket_name: 'Standing A - Seq 500', price: 4500 }] },
            { id: 'ORD-2025-009', buyer_name: 'Bob', total_amount: 9600, status: 'pending', created_at: '2025-12-31 17:10', items: [{ ticket_name: '特區 Rock A - 10排 - 1號', price: 4800 }, { ticket_name: '特區 Rock A - 10排 - 2號', price: 4800 }] },
            { id: 'ORD-2025-010', buyer_name: 'Charlie', total_amount: 4200, status: 'completed', created_at: '2025-12-28 10:00', items: [{ ticket_name: '搖滾區 Rock - 300號', price: 4200 }] },
            { id: 'ORD-2025-011', buyer_name: 'David', total_amount: 5500, status: 'paid', created_at: '2025-12-31 15:30', items: [{ ticket_name: '特區 Rock A - 2排 - 5號', price: 5500 }] },
            { id: 'ORD-2025-012', buyer_name: 'Eve', total_amount: 2800, status: 'pending', created_at: '2025-12-31 17:45', items: [{ ticket_name: '看台 Stand B - 12排 - 22號', price: 2800 }] }
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

    // --- Methods ---

    getDashboardStats() {
        const totalRevenue = this.orders
            .filter(o => o.status !== 'cancelled')
            .reduce((sum, o) => sum + o.total_amount, 0);

        const processingOrders = this.orders
            .filter(o => ['pending', 'shipping'].includes(o.status)).length;

        // Mocking Active Listings count
        const activeListings = 156;

        return { totalRevenue, processingOrders, activeListings };
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

    addListing(listingData) {
        // Mock adding to DB
        // listingData: { areaId, price, quantity, batchCode, ... }
        console.log("Adding listing to DB:", listingData);
        return true;
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
    document.getElementById('statListings').textContent = stats.activeListings;

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
