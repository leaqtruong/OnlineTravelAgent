// ─── API BASE CONFIG ─────────────────────────────────────────────────────────
const API_BASE = window.location.origin; // Since served by the backend directly!

// State variables
let destinations = [];
let trips = [];
let flights = [];
let charts = {};

// Elements
const elStats = {
  revenue: document.getElementById('stat-revenue'),
  bookings: document.getElementById('stat-bookings'),
  destinations: document.getElementById('stat-destinations'),
  flights: document.getElementById('stat-flights')
};

// ─── INIT APP ────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  setupNavigation();
  setupThemeToggle();
  setupModalHandlers();
  refreshAllData();
});

// ─── NAVIGATION (TAB SWITCHING) ──────────────────────────────────────────────
function setupNavigation() {
  const navBtns = document.querySelectorAll('.nav-btn');
  const tabPanes = document.querySelectorAll('.tab-pane');

  navBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetTab = btn.getAttribute('data-tab');

      // Update Nav Buttons
      navBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      // Update Tab Panes
      tabPanes.forEach(pane => {
        if (pane.id === targetTab) {
          pane.classList.add('active');
        } else {
          pane.classList.remove('active');
        }
      });

      // Resize charts if tab is Overview
      if (targetTab === 'tab-overview') {
        Object.values(charts).forEach(chart => chart.resize());
      }
    });
  });
}

// ─── THEME TOGGLE (DARK / LIGHT) ─────────────────────────────────────────────
function setupThemeToggle() {
  const btn = document.getElementById('btn-theme-toggle');
  const icon = btn.querySelector('.material-icons');

  // Check saved theme
  const savedTheme = localStorage.getItem('theme') || 'light';
  document.documentElement.setAttribute('data-theme', savedTheme);
  icon.textContent = savedTheme === 'dark' ? 'light_mode' : 'dark_mode';

  btn.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    icon.textContent = newTheme === 'dark' ? 'light_mode' : 'dark_mode';
  });
}

// ─── FETCH & REFRESH DATA ────────────────────────────────────────────────────
async function refreshAllData() {
  try {
    // 1. Fetch Bootstrap
    const bootRes = await fetch(`${API_BASE}/api/bootstrap`);
    const bootData = await bootRes.json();
    
    destinations = bootData.destinations || [];
    trips = bootData.trips || [];
    
    // 2. Fetch Flights (admin direct endpoint)
    const flightsRes = await fetch(`${API_BASE}/api/flights`);
    flights = await flightsRes.json();

    // Update Dashboard UI
    updateStats();
    renderCharts();
    
    // Render Tables
    renderDestinationsTable();
    renderTripsTable();
    renderFlightsTable();
  } catch (error) {
    console.error("Error refreshing data from server:", error);
  }
}

// ─── STATS CALCULATION ───────────────────────────────────────────────────────
function updateStats() {
  // Total Revenue: sum of all trips that are not cancelled
  let totalUsd = 0;
  let totalVnd = 0;

  trips.forEach(trip => {
    if (trip.status !== "Đã hủy" && trip.status !== "Cancelled") {
      const amount = Number(trip.totalAmount) || 0;
      if (trip.currency === "VND") {
        totalVnd += amount;
      } else {
        // default USD
        totalUsd += amount;
      }
    }
  });

  // Display revenue
  if (totalVnd > 0) {
    elStats.revenue.innerHTML = `${totalUsd.toLocaleString()}$ <span style="font-size:0.9rem; opacity:0.8">+ ${totalVnd.toLocaleString()}đ</span>`;
  } else {
    elStats.revenue.textContent = `$${totalUsd.toLocaleString()}`;
  }

  elStats.bookings.textContent = trips.length;
  elStats.destinations.textContent = destinations.length;
  elStats.flights.textContent = flights.length;
}

// ─── CHARTS DRAWING ──────────────────────────────────────────────────────────
function renderCharts() {
  const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
  const textColor = isDark ? '#94a3b8' : '#64748b';
  const gridColor = isDark ? '#1f293d' : '#e2e8f0';

  // --- Chart 1: Revenue by Destination ---
  const destRevenueMap = {};
  destinations.forEach(d => {
    destRevenueMap[d.name] = 0;
  });

  trips.forEach(trip => {
    if (trip.status !== "Đã hủy" && trip.status !== "Cancelled") {
      const amt = Number(trip.totalAmount) || 0;
      const convertedAmt = trip.currency === "VND" ? (amt / 25000) : amt; // normalize to USD for chart
      
      if (destRevenueMap[trip.destination] !== undefined) {
        destRevenueMap[trip.destination] += convertedAmt;
      } else {
        destRevenueMap[trip.destination] = convertedAmt;
      }
    }
  });

  const destLabels = Object.keys(destRevenueMap);
  const destData = Object.values(destRevenueMap);

  if (charts.destinationsChart) {
    charts.destinationsChart.destroy();
  }

  const ctxDest = document.getElementById('chart-destinations').getContext('2d');
  charts.destinationsChart = new Chart(ctxDest, {
    type: 'bar',
    data: {
      labels: destLabels,
      datasets: [{
        label: 'Doanh thu quy đổi (USD)',
        data: destData,
        backgroundColor: 'rgba(79, 70, 229, 0.75)',
        borderColor: 'rgba(79, 70, 229, 1)',
        borderWidth: 1.5,
        borderRadius: 6
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      },
      scales: {
        x: {
          ticks: { color: textColor },
          grid: { color: gridColor }
        },
        y: {
          ticks: { color: textColor },
          grid: { color: gridColor },
          beginAtZero: true
        }
      }
    }
  });

  // --- Chart 2: Trip Status Breakdown ---
  const statusMap = {
    'Sắp tới': 0,
    'Đã đi': 0,
    'Đã thanh toán': 0,
    'Đã hủy': 0
  };

  trips.forEach(trip => {
    const s = trip.status;
    if (statusMap[s] !== undefined) {
      statusMap[s]++;
    } else {
      statusMap[s] = 1;
    }
  });

  const statusLabels = Object.keys(statusMap);
  const statusData = Object.values(statusMap);

  if (charts.statusChart) {
    charts.statusChart.destroy();
  }

  const ctxStatus = document.getElementById('chart-statuses').getContext('2d');
  charts.statusChart = new Chart(ctxStatus, {
    type: 'doughnut',
    data: {
      labels: statusLabels,
      datasets: [{
        data: statusData,
        backgroundColor: [
          '#06b6d4', // Sắp tới - Info
          '#64748b', // Đã đi - Muted
          '#10b981', // Đã thanh toán - Success
          '#ef4444'  // Đã hủy - Danger
        ],
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
          labels: { color: textColor, padding: 12 }
        }
      },
      cutout: '70%'
    }
  });
}

// ─── DESTINATIONS TABLE RENDERING & ACTIONS ──────────────────────────────────
function renderDestinationsTable() {
  const tbody = document.querySelector('#table-destinations tbody');
  tbody.innerHTML = '';

  destinations.forEach(dest => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>
        <img class="table-img" src="${API_BASE}/${dest.imagePath}" onerror="this.src='https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=200'" alt="${dest.name}">
      </td>
      <td>
        <div class="cell-bold">${dest.name}</div>
        <div class="cell-sub">${dest.id}</div>
      </td>
      <td>${dest.location}</td>
      <td><span class="category-tag">${dest.category}</span></td>
      <td>${dest.duration}</td>
      <td class="cell-bold">$${dest.price}</td>
      <td>
        <div style="display:flex; align-items:center; gap:4px; font-weight:500;">
          <span class="material-icons" style="color:var(--color-warning); font-size:16px;">star</span>
          <span>${dest.rating}</span>
          <span style="color:var(--text-muted); font-size:0.8rem; font-weight:400;">(${dest.reviewsCount})</span>
        </div>
      </td>
      <td>
        <div class="action-btn-group">
          <button class="table-action-btn edit-dest-btn" data-id="${dest.id}">
            <span class="material-icons">edit</span>
          </button>
          <button class="table-action-btn delete delete-dest-btn" data-id="${dest.id}">
            <span class="material-icons">delete</span>
          </button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });

  // Attach event listeners
  document.querySelectorAll('.edit-dest-btn').forEach(btn => {
    btn.addEventListener('click', () => openDestinationModal(btn.getAttribute('data-id')));
  });
  document.querySelectorAll('.delete-dest-btn').forEach(btn => {
    btn.addEventListener('click', () => deleteDestination(btn.getAttribute('data-id')));
  });
}

async function deleteDestination(id) {
  if (!confirm(`Bạn có chắc chắn muốn xóa điểm đến "${id}"?`)) return;
  try {
    const res = await fetch(`${API_BASE}/api/destinations/${id}`, { method: 'DELETE' });
    if (res.ok) {
      refreshAllData();
    } else {
      const err = await res.json();
      alert(`Lỗi: ${err.message}`);
    }
  } catch (error) {
    alert("Không thể kết nối đến server để xóa.");
  }
}

// ─── TRIPS TABLE RENDERING & ACTIONS ─────────────────────────────────────────
function renderTripsTable() {
  const tbody = document.querySelector('#table-trips tbody');
  tbody.innerHTML = '';

  trips.forEach(trip => {
    const tr = document.createElement('tr');
    
    // Choose status badge
    let statusClass = 'badge-info';
    if (trip.status === 'Đã thanh toán' || trip.status === 'Paid') statusClass = 'badge-success';
    if (trip.status === 'Đã đi' || trip.status === 'Completed') statusClass = 'badge-success';
    if (trip.status === 'Đã hủy' || trip.status === 'Cancelled') statusClass = 'badge-danger';
    if (trip.status === 'Chờ thanh toán' || trip.status === 'Pending') statusClass = 'badge-warning';

    const formattedAmount = trip.totalAmount 
      ? (trip.currency === "VND" ? `${trip.totalAmount.toLocaleString()} đ` : `$${trip.totalAmount}`)
      : 'N/A';

    tr.innerHTML = `
      <td class="cell-bold">${trip.id}</td>
      <td>
        <div class="cell-bold">${trip.destination}</div>
      </td>
      <td>${trip.location}</td>
      <td>${trip.date}</td>
      <td>${trip.guests || '1 Người lớn'}</td>
      <td class="cell-bold" style="color:var(--accent-primary);">${formattedAmount}</td>
      <td>
        <select class="status-select select-trip-status" data-id="${trip.id}">
          <option value="Sắp tới" ${trip.status === 'Sắp tới' ? 'selected' : ''}>Sắp tới</option>
          <option value="Đã thanh toán" ${trip.status === 'Đã thanh toán' ? 'selected' : ''}>Đã thanh toán</option>
          <option value="Chờ thanh toán" ${trip.status === 'Chờ thanh toán' ? 'selected' : ''}>Chờ thanh toán</option>
          <option value="Đã đi" ${trip.status === 'Đã đi' ? 'selected' : ''}>Đã đi</option>
          <option value="Đã hủy" ${trip.status === 'Đã hủy' ? 'selected' : ''}>Đã hủy</option>
        </select>
      </td>
      <td>
        <div class="action-btn-group">
          <button class="table-action-btn delete delete-trip-btn" data-id="${trip.id}">
            <span class="material-icons">delete</span>
          </button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });

  // Attach status change events
  document.querySelectorAll('.select-trip-status').forEach(select => {
    select.addEventListener('change', async () => {
      const id = select.getAttribute('data-id');
      const newStatus = select.value;
      const isUpcoming = (newStatus === "Sắp tới" || newStatus === "Chờ thanh toán" || newStatus === "Đã thanh toán");
      try {
        const res = await fetch(`${API_BASE}/api/trips/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: jsonEncode({ status: newStatus, isUpcoming })
        });
        if (res.ok) {
          refreshAllData();
        } else {
          alert("Không thể cập nhật trạng thái chuyến đi.");
        }
      } catch (error) {
        alert("Lỗi kết nối khi cập nhật chuyến đi.");
      }
    });
  });

  // Attach delete booking event
  document.querySelectorAll('.delete-trip-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const id = btn.getAttribute('data-id');
      if (!confirm(`Xóa đơn đặt chỗ "${id}"?`)) return;
      try {
        const res = await fetch(`${API_BASE}/api/trips/${id}`, { method: 'DELETE' });
        if (res.ok) {
          refreshAllData();
        } else {
          alert("Không thể xóa đơn đặt chỗ.");
        }
      } catch (e) {
        alert("Lỗi kết nối.");
      }
    });
  });
}

// Helper function to safely output JSON in older browser/node environments
function jsonEncode(obj) {
  return JSON.stringify(obj);
}

// ─── FLIGHTS TABLE RENDERING & ACTIONS ───────────────────────────────────────
function renderFlightsTable() {
  const tbody = document.querySelector('#table-flights tbody');
  tbody.innerHTML = '';

  flights.forEach(f => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>
        <div style="display:flex; align-items:center; gap:8px;">
          <img class="table-logo" src="${API_BASE}/${f.airlineLogo}" onerror="this.src='https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=100'" alt="${f.airline}">
          <span style="font-weight:600;">${f.airline}</span>
        </div>
      </td>
      <td class="cell-bold">${f.id}</td>
      <td class="cell-bold">${f.departure}</td>
      <td class="cell-bold">${f.arrival}</td>
      <td>${f.departureTime}</td>
      <td>${f.arrivalTime}</td>
      <td>${f.duration}</td>
      <td class="cell-bold" style="color:var(--accent-primary);">$${f.price}</td>
      <td>
        <div class="action-btn-group">
          <button class="table-action-btn edit-flight-btn" data-id="${f.id}">
            <span class="material-icons">edit</span>
          </button>
          <button class="table-action-btn delete delete-flight-btn" data-id="${f.id}">
            <span class="material-icons">delete</span>
          </button>
        </div>
      </td>
    `;
    tbody.appendChild(tr);
  });

  // Attach event listeners
  document.querySelectorAll('.edit-flight-btn').forEach(btn => {
    btn.addEventListener('click', () => openFlightModal(btn.getAttribute('data-id')));
  });
  document.querySelectorAll('.delete-flight-btn').forEach(btn => {
    btn.addEventListener('click', () => deleteFlight(btn.getAttribute('data-id')));
  });
}

async function deleteFlight(id) {
  if (!confirm(`Bạn có chắc chắn muốn xóa chuyến bay "${id}"?`)) return;
  try {
    const res = await fetch(`${API_BASE}/api/flights/${id}`, { method: 'DELETE' });
    if (res.ok) {
      refreshAllData();
    } else {
      const err = await res.json();
      alert(`Lỗi: ${err.message}`);
    }
  } catch (error) {
    alert("Không thể kết nối đến server để xóa.");
  }
}

// ─── MODAL DIALOG HANDLERS ───────────────────────────────────────────────────
function setupModalHandlers() {
  // Destinations
  const destModal = document.getElementById('modal-destination');
  const btnAddDest = document.getElementById('btn-add-destination');
  const btnCloseDest1 = document.getElementById('btn-close-dest-modal');
  const btnCloseDest2 = document.getElementById('btn-cancel-dest');
  const formDest = document.getElementById('form-destination');

  btnAddDest.addEventListener('click', () => openDestinationModal(null));
  btnCloseDest1.addEventListener('click', () => destModal.classList.remove('open'));
  btnCloseDest2.addEventListener('click', () => destModal.classList.remove('open'));

  formDest.addEventListener('submit', async (e) => {
    e.preventDefault();
    const action = document.getElementById('dest-action').value;
    const id = document.getElementById('dest-id').value.trim();
    
    const bodyData = {
      id,
      name: document.getElementById('dest-name').value.trim(),
      location: document.getElementById('dest-location').value.trim(),
      category: document.getElementById('dest-category').value,
      price: document.getElementById('dest-price').value,
      duration: document.getElementById('dest-duration').value.trim() || undefined,
      rating: document.getElementById('dest-rating').value.trim() || undefined,
      reviewsCount: document.getElementById('dest-reviews').value.trim() || undefined,
      latitude: document.getElementById('dest-latitude').value ? Number(document.getElementById('dest-latitude').value) : undefined,
      longitude: document.getElementById('dest-longitude').value ? Number(document.getElementById('dest-longitude').value) : undefined,
      imagePath: document.getElementById('dest-image').value.trim() || undefined,
      description: document.getElementById('dest-description').value.trim() || undefined
    };

    try {
      let res;
      if (action === 'create') {
        res = await fetch(`${API_BASE}/api/destinations`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(bodyData)
        });
      } else {
        res = await fetch(`${API_BASE}/api/destinations/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(bodyData)
        });
      }

      if (res.ok) {
        destModal.classList.remove('open');
        refreshAllData();
      } else {
        const err = await res.json();
        alert(`Thất bại: ${err.message}`);
      }
    } catch (err) {
      alert("Lỗi kết nối server.");
    }
  });

  // Flights
  const flightModal = document.getElementById('modal-flight');
  const btnAddFlight = document.getElementById('btn-add-flight');
  const btnCloseFlight1 = document.getElementById('btn-close-flight-modal');
  const btnCloseFlight2 = document.getElementById('btn-cancel-flight');
  const formFlight = document.getElementById('form-flight');

  btnAddFlight.addEventListener('click', () => openFlightModal(null));
  btnCloseFlight1.addEventListener('click', () => flightModal.classList.remove('open'));
  btnCloseFlight2.addEventListener('click', () => flightModal.classList.remove('open'));

  formFlight.addEventListener('submit', async (e) => {
    e.preventDefault();
    const action = document.getElementById('flight-action').value;
    const id = document.getElementById('flight-id').value.trim();

    const bodyData = {
      id,
      airline: document.getElementById('flight-airline').value.trim(),
      departure: document.getElementById('flight-dep').value.trim().toUpperCase(),
      arrival: document.getElementById('flight-arr').value.trim().toUpperCase(),
      departureTime: document.getElementById('flight-dep-time').value.trim() || undefined,
      arrivalTime: document.getElementById('flight-arr-time').value.trim() || undefined,
      price: Number(document.getElementById('flight-price').value),
      duration: document.getElementById('flight-duration').value.trim() || undefined,
      airlineLogo: document.getElementById('flight-logo').value.trim() || undefined
    };

    try {
      let res;
      if (action === 'create') {
        res = await fetch(`${API_BASE}/api/flights`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(bodyData)
        });
      } else {
        res = await fetch(`${API_BASE}/api/flights/${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(bodyData)
        });
      }

      if (res.ok) {
        flightModal.classList.remove('open');
        refreshAllData();
      } else {
        const err = await res.json();
        alert(`Thất bại: ${err.message}`);
      }
    } catch (err) {
      alert("Lỗi kết nối server.");
    }
  });
}

// ─── OPEN MODALS WITH PREFILLED VALUES FOR EDIT ──────────────────────────────
function openDestinationModal(id = null) {
  const modal = document.getElementById('modal-destination');
  const title = document.getElementById('modal-destination-title');
  const action = document.getElementById('dest-action');
  
  const inpId = document.getElementById('dest-id');
  const inpName = document.getElementById('dest-name');
  const inpLocation = document.getElementById('dest-location');
  const inpCategory = document.getElementById('dest-category');
  const inpPrice = document.getElementById('dest-price');
  const inpDuration = document.getElementById('dest-duration');
  const inpRating = document.getElementById('dest-rating');
  const inpReviews = document.getElementById('dest-reviews');
  const inpLat = document.getElementById('dest-latitude');
  const inpLng = document.getElementById('dest-longitude');
  const inpImg = document.getElementById('dest-image');
  const inpDesc = document.getElementById('dest-description');

  if (id) {
    // Edit Mode
    title.textContent = "Chỉnh sửa Điểm đến";
    action.value = "edit";
    inpId.value = id;
    inpId.disabled = true;

    const dest = destinations.find(d => d.id === id);
    if (dest) {
      inpName.value = dest.name || '';
      inpLocation.value = dest.location || '';
      inpCategory.value = dest.category || 'Địa điểm';
      inpPrice.value = dest.price || '';
      inpDuration.value = dest.duration || '';
      inpRating.value = dest.rating || '';
      inpReviews.value = dest.reviewsCount || '';
      inpLat.value = dest.latitude || '';
      inpLng.value = dest.longitude || '';
      inpImg.value = dest.imagePath || '';
      inpDesc.value = dest.description || '';
    }
  } else {
    // Add Mode
    title.textContent = "Thêm điểm đến mới";
    action.value = "create";
    inpId.value = '';
    inpId.disabled = false;

    // Reset all inputs
    inpName.value = '';
    inpLocation.value = '';
    inpCategory.value = 'Địa điểm';
    inpPrice.value = '';
    inpDuration.value = '3N/2Đ';
    inpRating.value = '5.0';
    inpReviews.value = '0';
    inpLat.value = '';
    inpLng.value = '';
    inpImg.value = 'assets/images/dalat_image.jpg';
    inpDesc.value = '';
  }

  modal.classList.add('open');
}

function openFlightModal(id = null) {
  const modal = document.getElementById('modal-flight');
  const title = document.getElementById('modal-flight-title');
  const action = document.getElementById('flight-action');

  const inpId = document.getElementById('flight-id');
  const inpAirline = document.getElementById('flight-airline');
  const inpDep = document.getElementById('flight-dep');
  const inpArr = document.getElementById('flight-arr');
  const inpDepTime = document.getElementById('flight-dep-time');
  const inpArrTime = document.getElementById('flight-arr-time');
  const inpPrice = document.getElementById('flight-price');
  const inpDuration = document.getElementById('flight-duration');
  const inpLogo = document.getElementById('flight-logo');

  if (id) {
    // Edit
    title.textContent = "Chỉnh sửa Chuyến bay";
    action.value = "edit";
    inpId.value = id;
    inpId.disabled = true;

    const f = flights.find(item => item.id === id);
    if (f) {
      inpAirline.value = f.airline || '';
      inpDep.value = f.departure || '';
      inpArr.value = f.arrival || '';
      inpDepTime.value = f.departureTime || '';
      inpArrTime.value = f.arrivalTime || '';
      inpPrice.value = f.price || '';
      inpDuration.value = f.duration || '';
      inpLogo.value = f.airlineLogo || '';
    }
  } else {
    // Add
    title.textContent = "Thêm chuyến bay mới";
    action.value = "create";
    inpId.value = '';
    inpId.disabled = false;

    inpAirline.value = '';
    inpDep.value = '';
    inpArr.value = '';
    inpDepTime.value = '08:00';
    inpArrTime.value = '10:00';
    inpPrice.value = '';
    inpDuration.value = '2h 00m';
    inpLogo.value = 'assets/images/vna_logo.png';
  }

  modal.classList.add('open');
}
