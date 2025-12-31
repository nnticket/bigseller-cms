const Utils = {
    formatCurrency: (amount) => {
        return new Intl.NumberFormat('zh-TW', { style: 'currency', currency: 'TWD', minimumFractionDigits: 0 }).format(amount);
    },
    formatDate: (dateString) => {
        const date = new Date(dateString);
        return date.toLocaleString('zh-TW', { hour12: false });
    },
    statusMap: {
        'pending': { text: '待付款', class: 'status-pending', color: '#f59e0b' },
        'paid': { text: '已付款', class: 'status-paid', color: '#10b981' },
        'shipping': { text: '出貨中', class: 'status-shipping', color: '#3b82f6' },
        'completed': { text: '已完成', class: 'status-completed', color: '#6366f1' },
        'cancelled': { text: '已取消', class: 'status-cancelled', color: '#ef4444' }
    },
    getStatus: (statusKey) => {
        return Utils.statusMap[statusKey] || { text: statusKey, class: '', color: '#999' };
    }
};
