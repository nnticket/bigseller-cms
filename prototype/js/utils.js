const Utils = {
    formatCurrency: (amount) => {
        return new Intl.NumberFormat('zh-TW', { style: 'currency', currency: 'TWD', minimumFractionDigits: 0 }).format(amount);
    },
    formatDate: (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleString('zh-TW', { hour12: false });
    },
    statusMap: {
        'pending': { text: '待處理', class: 'status-pending', color: '#f59e0b' },
        'unpaid': { text: '未付款', class: 'status-pending', color: '#f59e0b' },
        'paid': { text: '已付款', class: 'status-paid', color: '#10b981' },
        'shipping': { text: '運送中', class: 'status-shipping', color: '#3b82f6' },
        'completed': { text: '已完成', class: 'status-completed', color: '#6366f1' },
        'cancelled': { text: '已取消', class: 'status-cancelled', color: '#ef4444' },

        'none': { text: '-', class: 'status-none', color: '#94a3b8' },
        'preparing': { text: '備貨中', class: 'status-preparing', color: '#60a5fa' },
        'shipped': { text: '已寄出', class: 'status-shipping', color: '#3b82f6' },
        'delivered': { text: '已送達', class: 'status-completed', color: '#10b981' },
        'returned': { text: '已退貨', class: 'status-cancelled', color: '#ef4444' }
    },
    getStatus: (statusKey) => {
        return Utils.statusMap[statusKey] || { text: statusKey, class: '', color: '#999' };
    }
};
