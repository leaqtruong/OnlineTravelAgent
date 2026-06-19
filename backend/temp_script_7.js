
let curPage='dashboard';
let data={destinations:[],hotels:[],flights:[],tours:[],trips:[],categories:[],users:[],documents:[]};

  const API = window.location.hostname==='localhost'?'http://localhost:3000':'';
  
  function getAuth(){
    return localStorage.getItem('partner_token')||'';
  }

  async function req(path,method='GET',body=null){
    const opt={method,headers:{}};
    const auth=getAuth();
    if(auth) opt.headers['Authorization']='Bearer '+auth;
    if(body){opt.headers['Content-Type']='application/json';opt.body=JSON.stringify(body);}
    const r=await fetch(API+path,opt);
    if(!r.ok) {
      const msg = await r.text() || r.statusText;
      throw new Error(msg);
    }
    return r.json();
  }

  async function checkHealth(){
    try{
      await req('/health');
      document.getElementById('statusDot').className='w-2 h-2 rounded-full bg-emerald-500 shadow-[0_0_12px_rgba(16,185,129,0.8)]';
      document.getElementById('statusText').textContent='Online';
    }catch(e){
      document.getElementById('statusDot').className='w-2 h-2 rounded-full bg-red-500';
      document.getElementById('statusText').textContent='Offline';
    }
  }

  async function doLogin(){
    const user = document.getElementById('login-user').value.trim();
    const pass = document.getElementById('login-pass').value.trim();
    if(!user || !pass) return toast('Vui lòng nhập đủ thông tin','error');
    document.getElementById('login-btn').innerText = 'Đang xử lý...';
    try {
      const r = await fetch(API+'/api/auth/login', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({email: user, password: pass})
      });
      const d = await r.json();
      if(!r.ok) throw new Error(d.message || 'Sai thông tin đăng nhập');
      if(d.user.role !== 'PARTNER' && d.user.role !== 'ADMIN') {
        throw new Error('Tài khoản không có quyền Đối tác');
      }
      localStorage.setItem('partner_token', d.token);
      
      document.getElementById('login-screen').style.opacity = '0';
      setTimeout(()=>document.getElementById('login-screen').style.display='none', 700);
      toast('Đăng nhập thành công!','success');
      
      checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
    } catch (e) {
      document.getElementById('login-btn').innerHTML = 'Đăng nhập <i class="fa-solid fa-arrow-right ml-2"></i>';
      toast(e.message, 'error');
    }
  }

  async function initPartner(){
    try{
      await req('/api/partner/stats');
      document.getElementById('login-screen').style.display='none';
      checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
    }catch(e){
      document.getElementById('login-screen').style.display='flex';
      document.getElementById('login-screen').style.opacity='1';
    }
  }
  
  async function loadDashboard(){
  const st = await req('/api/partner/stats');
  document.getElementById('st-dest').textContent=st.destinations;
  document.getElementById('st-hotel').textContent=st.hotels;
  document.getElementById('st-flight').textContent=st.flights;
  document.getElementById('st-tour').textContent=st.tours;
  document.getElementById('st-upcoming').textContent=st.tripsUpcoming;
}

// ── HOTELS & ROOMS ──
async function loadHotels(){ data.hotels=await req('/api/partner/hotels'); renderHotels(data.hotels); }
function renderHotels(rows){
  const tb=document.getElementById('tb-hotels'), em=document.getElementById('empty-hotels');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(h=>listRow([
    {label:'Tên Khách Sạn', val:h.name, cls:'w-1/3'},
    {label:'Địa điểm', val:h.location, cls:'w-1/4'},
    {label:'Phòng', val:`<span class="px-2 py-1 bg-silver rounded-full text-xs">${h.rooms?.length||0}</span>`},
    {label:'Giá từ', val:`$${h.priceFrom}`}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editHotel('${h.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('hotel','${h.id}','${h.name.replace(/'/g,"\\'")}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function setImg(id, url){
  document.getElementById(id).value = url;
  const img = document.getElementById(id+'-preview');
  if(url){ img.src = url.startsWith('/') ? API+url : url; img.classList.add('show'); }
  else { img.classList.remove('show'); }
}
function openHotelModal(hotel=null){
  document.getElementById('mhotel-title').textContent=hotel?'Cập nhật Khách Sạn':'Thêm mới Khách Sạn';
  document.getElementById('h-id').value=hotel?.id??'';
  document.getElementById('h-slug').value=hotel?.id??'';
  document.getElementById('h-slug').disabled=!!hotel;
  ['name','loc','addr','rating','price','desc'].forEach(k=>document.getElementById(`h-${k}`).value=hotel?.[k==='loc'?'location':k==='addr'?'address':k==='price'?'priceFrom':k==='desc'?'description':k]??'');
  setImg('h-img', hotel?.imagePath??'');
  document.getElementById('h-amenities').value=hotel?.amenities?.join(', ')??'';
  
  const roomSec=document.getElementById('h-rooms-section');
  if(hotel){ roomSec.style.display='block'; renderRooms(hotel.rooms||[]); } else { roomSec.style.display='none'; }
  openModal('modal-hotel');
}
function editHotel(id){openHotelModal(data.hotels.find(x=>x.id===id));}
async function saveHotel(){
  const id=document.getElementById('h-id').value;
  const body={ id:id||v('h-slug')||`hotel-${Date.now()}`, name:v('h-name'), location:v('h-loc'), address:v('h-addr'), rating:v('h-rating'), priceFrom:parseFloat(v('h-price'))||0, imagePath:v('h-img'), description:v('h-desc'), amenities: v('h-amenities').split(',').map(a=>a.trim()).filter(Boolean)};
  try{ if(id)await req(`/api/partner/hotels/${id}`,'PUT',body); else await req('/api/partner/hotels','POST',body); closeModal('modal-hotel'); await loadHotels(); toast(id?'Đã cập nhật':'Đã thêm mới','success'); }catch(e){toast(e.message,'error');}
}

function renderRooms(rooms){
  const tb = document.getElementById('h-rooms-list');
  if(!rooms.length){tb.innerHTML='<div class="text-xs text-muted">Khách sạn này chưa có phòng nào.</div>';return;}
  tb.innerHTML = rooms.map(r=>`
    <div class="flex items-center justify-between p-4 bg-white border border-silver rounded-2xl">
      <div><div class="text-sm font-bold text-ink">${r.name}</div><div class="text-xs text-muted">Sức chứa: ${r.capacity} khách - $${r.price}</div></div>
      <div class="flex gap-2">
        <button class="w-8 h-8 rounded-full bg-offwhite hover:bg-silver text-ink" onclick="editRoom('${r.id}')"><i class="fa-solid fa-pen text-xs"></i></button>
        <button class="w-8 h-8 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500" onclick="confirmDel('room','${r.id}','${r.name}')"><i class="fa-solid fa-trash text-xs"></i></button>
      </div>
    </div>
  `).join('');
}
function openRoomModal(room=null){
  document.getElementById('mroom-title').textContent=room?'Sửa Phòng':'Thêm Phòng';
  document.getElementById('r-id').value=room?.id??'';
  ['name','cap','price','desc'].forEach(k=>document.getElementById(`r-${k}`).value=room?.[k==='cap'?'capacity':k==='desc'?'description':k]??'');
  setImg('r-img', room?.imagePath??'');
  document.getElementById('r-amenities').value=room?.amenities?.join(', ')??'';
  openModal('modal-room');
}
function editRoom(id){
  const hotel=data.hotels.find(h=>h.id===document.getElementById('h-id').value);
  openRoomModal(hotel.rooms.find(r=>r.id===id));
}
async function saveRoom(){
  const hotelId=document.getElementById('h-id').value;
  const id=document.getElementById('r-id').value;
  const body={ name:v('r-name'), capacity:parseInt(v('r-cap'))||1, price:parseFloat(v('r-price'))||0, imagePath:v('r-img'), description:v('r-desc'), amenities:v('r-amenities').split(',').map(a=>a.trim()).filter(Boolean)};
  try{ 
    if(id) await req(`/api/partner/hotels/${hotelId}/rooms/${id}`,'PUT',body); 
    else await req(`/api/partner/hotels/${hotelId}/rooms`,'POST',body); 
    closeModal('modal-room'); await loadHotels(); editHotel(hotelId); toast('Lưu phòng thành công','success'); 
  }catch(e){toast(e.message,'error');}
}

// ── FLIGHTS ──
async function loadFlights(){ data.flights=await req('/api/partner/flights'); renderFlights(data.flights); }
function renderFlights(rows){
  const tb=document.getElementById('tb-flights'), em=document.getElementById('empty-flights');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(f=>listRow([
    {label:'Hãng bay', val:f.airline, cls:'w-1/4'},
    {label:'Hành trình', val:`${f.departure} <i class="fa-solid fa-arrow-right text-[10px] mx-1 text-muted"></i> ${f.arrival}`, cls:'w-1/4'},
    {label:'Thời gian', val:`${f.departureTime} - ${f.arrivalTime}`},
    {label:'Giá', val:fmtUSD(f.price)}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editFlight('${f.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('flight','${f.id}','${f.airline.replace(/'/g,"\\'")}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openFlightModal(fl=null){
  document.getElementById('mflight-title').textContent=fl?'Sửa chuyến bay':'Thêm chuyến bay';
  document.getElementById('f-id').value=fl?.id??'';
  document.getElementById('f-slug').value=fl?.id??'';
  document.getElementById('f-slug').disabled=!!fl;
  ['airline','dep','arr','dep-time','arr-time','price','dur'].forEach(k=>{
    const mk=k==='dep'?'departure':k==='arr'?'arrival':k==='dep-time'?'departureTime':k==='arr-time'?'arrivalTime':k==='dur'?'duration':k;
    document.getElementById(`f-${k}`).value=fl?.[mk]??'';
  });
  setImg('f-logo', fl?.airlineLogo??'');
  openModal('modal-flight');
}
function editFlight(id){openFlightModal(data.flights.find(x=>x.id===id));}
async function saveFlight(){
  const id=document.getElementById('f-id').value;
  const body={id:id||v('f-slug')||`fl-${Date.now()}`,airline:v('f-airline'),airlineLogo:v('f-logo'),departure:v('f-dep'),arrival:v('f-arr'),departureTime:v('f-dep-time'),arrivalTime:v('f-arr-time'),price:parseFloat(v('f-price'))||0,duration:v('f-dur')};
  try{ if(id)await req(`/api/partner/flights/${id}`,'PUT',body); else await req('/api/partner/flights','POST',body); closeModal('modal-flight'); await loadFlights(); toast('Lưu thành công','success'); }catch(e){toast(e.message,'error');}
}

// ── TOURS ──
async function loadTours(){ data.tours=await req('/api/partner/tours'); renderTours(data.tours); }
function renderTours(rows){
  const tb=document.getElementById('tb-tours'), em=document.getElementById('empty-tours');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(t=>listRow([
    {label:'Tên Tour', val:t.name, cls:'w-1/3'},
    {label:'Khởi hành', val:t.departure},
    {label:'Giá', val:`${fmtUSD(t.price)} ${t.originalPrice?`<s class="text-muted font-normal ml-2">${fmtUSD(t.originalPrice)}</s>`:''}`},
    {label:'Tag', val:t.isPopular?'<span class="px-3 py-1 bg-primary text-white rounded-full text-[10px]">HOT</span>':''}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editTour('${t.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('tour','${t.id}','${t.name.replace(/'/g,"\\'")}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openTourModal(tour=null){
  document.getElementById('mtour-title').textContent=tour?'Sửa tour':'Thêm tour';
  document.getElementById('t-id').value=tour?.id??'';
  document.getElementById('t-slug').value=tour?.id??'';
  document.getElementById('t-slug').disabled=!!tour;
  ['name','dep','dur','price','orig','dests','incl','desc'].forEach(k=>{
    const mk=k==='dep'?'departure':k==='dur'?'duration':k==='orig'?'originalPrice':k==='dests'?'destinations':k==='incl'?'includes':k==='desc'?'description':k;
    let v=tour?.[mk]??''; if(Array.isArray(v))v=v.join(', ');
    document.getElementById(`t-${k}`).value=v;
  });
  document.getElementById('t-depdate').value=tour?.departureDate??'';
  setImg('t-img', tour?.imagePath??'');
  document.getElementById('t-popular').checked=tour?.isPopular??false;
  document.getElementById('t-guide').checked=tour?.includesGuide??true;
  openModal('modal-tour');
}
function editTour(id){openTourModal(data.tours.find(x=>x.id===id));}
async function saveTour(){
  const id=document.getElementById('t-id').value;
  const body={id:id||v('t-slug')||`tour-${Date.now()}`,name:v('t-name'),departure:v('t-dep'),duration:v('t-dur'),departureDate:v('t-depdate')||null,price:parseFloat(v('t-price'))||0,originalPrice:parseFloat(v('t-orig'))||null,imagePath:v('t-img'),description:v('t-desc'),isPopular:document.getElementById('t-popular').checked,includesGuide:document.getElementById('t-guide').checked,destinations:v('t-dests').split(',').map(s=>s.trim()).filter(Boolean),includes:v('t-incl').split(',').map(s=>s.trim()).filter(Boolean)};
  try{ if(id)await req(`/api/partner/tours/${id}`,'PUT',body); else await req('/api/partner/tours','POST',body); closeModal('modal-tour'); await loadTours(); toast('Lưu thành công','success'); }catch(e){toast(e.message,'error');}
}

// ── TRIPS ──
async function loadTrips(){ data.trips=await req('/api/partner/trips'); renderTrips(data.trips); }
function renderTrips(rows){
  const tb=document.getElementById('tb-trips'), em=document.getElementById('empty-trips');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(t=>listRow([
    {label:'Điểm đến', val:t.destination, cls:'w-1/3'},
    {label:'Ngày đi', val:t.date},
    {label:'Khách', val:t.guests??'—'},
    {label:'Trạng thái', val:`<span class="px-3 py-1 bg-silver text-ink rounded-full text-[10px] uppercase">${t.status}</span>`}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-primary hover:text-white text-ink transition-all flex items-center justify-center" onclick="openTripSchedule('${t.id}')"><i class="fa-solid fa-calendar-alt"></i></button>
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editTrip('${t.id}')"><i class="fa-solid fa-eye"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('trip','${t.id}','${t.destination.replace(/'/g,"\\'")}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function editTrip(id){
  const t = data.trips.find(x=>x.id===id);
  document.getElementById('tr-id').value=id; 
  document.getElementById('tr-dest-disp').textContent=t.destination;
  document.getElementById('tr-price-disp').textContent=t.totalPrice ? fmtUSD(t.totalPrice) : 'Chưa có';
  document.getElementById('tr-flight-disp').textContent=t.flightId || 'Không có';
  document.getElementById('tr-hotel-disp').textContent=t.hotelId || 'Không có';
  document.getElementById('tr-status').value=t.status; 
  openModal('modal-trip');
}
async function saveTripStatus(){
  const id=document.getElementById('tr-id').value, status=document.getElementById('tr-status').value;
  try{ await req(`/api/partner/trips/${id}`,'PUT',{status,isUpcoming:!['Đã đi','Đã hủy'].includes(status)}); closeModal('modal-trip'); await loadTrips(); toast('Cập nhật thành công','success'); }catch(e){toast(e.message,'error');}
}

// ── TRIP SCHEDULE ──
async function openTripSchedule(id) {
  document.getElementById('ts-trip-id').value = id;
  await loadTripSchedule(id);
  openModal('modal-trip-schedule');
}

async function loadTripSchedule(id) {
  try {
    const data = await req(`/api/partner/trips/${id}/schedule`);
    renderTripSchedule(data.days);
    renderTripUpdates(data.updates);
  } catch (e) {
    toast(e.message, 'error');
  }
}

function renderTripSchedule(days) {
  const container = document.getElementById('ts-days-list');
  if (!days || !days.length) {
    container.innerHTML = `<div class="text-sm font-bold text-muted text-center py-10">Chuyến đi này chưa có lịch trình. Nhấn "Thêm ngày mới" để bắt đầu.</div>`;
    return;
  }
  container.innerHTML = days.map(d => `
    <div class="bg-white rounded-3xl p-6 shadow-sm border border-silver mb-4" data-day-id="${d.id}">
      <div class="flex items-center justify-between mb-4">
        <div class="text-lg font-extrabold text-ink">Ngày ${d.dayNumber} ${d.title ? `- <input type="text" class="inline-block bg-transparent border-b border-silver focus:border-primary outline-none text-lg font-extrabold text-ink w-48" value="${d.title || ''}" onblur="updateDayTitle('${d.id}', this.value)" placeholder="Thêm tiêu đề...">` : `- <input type="text" class="inline-block bg-transparent border-b border-silver focus:border-primary outline-none text-lg font-extrabold text-ink w-48" value="" onblur="updateDayTitle('${d.id}', this.value)" placeholder="Thêm tiêu đề...">`}</div>
        <button class="w-8 h-8 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center text-xs" onclick="deleteDay('${d.id}', ${d.dayNumber})"><i class="fa-solid fa-trash"></i></button>
      </div>
      <div class="flex flex-col gap-3" id="day-items-${d.id}">
        ${d.items.map((item, idx) => renderItemRow(item, idx)).join('')}
      </div>
      <button class="mt-3 w-full bg-offwhite hover:bg-primary/10 text-muted hover:text-primary font-bold py-2 rounded-xl transition-all text-xs border border-dashed border-silver hover:border-primary" onclick="addItemToDay('${d.id}')">
        <i class="fa-solid fa-plus mr-1"></i>Thêm mục
      </button>
    </div>
  `).join('');
}

function renderItemRow(item, idx) {
  return `
    <div class="flex items-start gap-3 bg-offwhite rounded-2xl p-4 border border-silver group" data-item-id="${item.id}">
      <div class="flex flex-col gap-1 w-14 shrink-0">
        <input type="text" class="w-full text-xs font-bold text-ink bg-white border border-silver rounded-lg p-1.5 text-center focus:border-primary outline-none" value="${item.startTime}" placeholder="08:00" onblur="updateItem('${item.id}','startTime',this.value)">
        <input type="text" class="w-full text-[10px] font-bold text-muted bg-white border border-silver rounded-lg p-1.5 text-center focus:border-primary outline-none" value="${item.endTime || ''}" placeholder="--:--" onblur="updateItem('${item.id}','endTime',this.value)">
      </div>
      <div class="flex-1 flex flex-col gap-1.5">
        <input type="text" class="w-full text-sm font-bold text-ink bg-white border border-silver rounded-lg px-3 py-1.5 focus:border-primary outline-none" value="${item.title}" placeholder="Tên hoạt động" onblur="updateItem('${item.id}','title',this.value)">
        <div class="flex gap-2">
          <input type="text" class="flex-1 text-xs text-muted bg-white border border-silver rounded-lg px-3 py-1.5 focus:border-primary outline-none" value="${item.locationName || ''}" placeholder="Địa điểm" onblur="updateItem('${item.id}','locationName',this.value)">
          <input type="text" class="flex-1 text-xs text-muted bg-white border border-silver rounded-lg px-3 py-1.5 focus:border-primary outline-none" value="${item.description || ''}" placeholder="Mô tả" onblur="updateItem('${item.id}','description',this.value)">
        </div>
      </div>
      <div class="flex flex-col gap-2 shrink-0 w-36">
        <select class="text-[10px] bg-white border border-silver rounded-lg p-1.5 font-bold" onchange="updateItem('${item.id}','statusOverride',this.value)">
          <option value="" ${!item.statusOverride ? 'selected' : ''}>-- Mặc định --</option>
          <option value="pending" ${item.statusOverride==='pending'?'selected':''}>Chưa diễn ra</option>
          <option value="ongoing" ${item.statusOverride==='ongoing'?'selected':''}>Đang diễn ra</option>
          <option value="completed" ${item.statusOverride==='completed'?'selected':''}>Đã hoàn thành</option>
          <option value="skipped" ${item.statusOverride==='skipped'?'selected':''}>Đã bỏ qua</option>
        </select>
        <input type="text" class="text-[10px] bg-white border border-silver rounded-lg px-2 py-1.5" placeholder="Ghi chú" value="${item.note || ''}" onblur="updateItem('${item.id}','note',this.value)">
      </div>
      <button class="w-7 h-7 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center text-xs opacity-0 group-hover:opacity-100 shrink-0" onclick="deleteItem('${item.id}')"><i class="fa-solid fa-xmark"></i></button>
    </div>
  `;
}

function renderTripUpdates(updates) {
  const container = document.getElementById('ts-updates-list');
  if (!updates || !updates.length) {
    container.innerHTML = `<div class="text-xs text-muted">Chưa có cập nhật nào.</div>`;
    return;
  }
  container.innerHTML = updates.map(u => `
    <div class="bg-offwhite p-4 rounded-xl border border-silver">
      <div class="text-[10px] text-muted font-bold mb-1">${new Date(u.createdAt).toLocaleString('vi-VN')}</div>
      <div class="text-sm font-semibold text-ink">${u.message}</div>
    </div>
  `).join('');
}

async function updateItem(itemId, field, value) {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    const body = {};
    body[field] = value || null;
    await req(`/api/partner/trips/${tripId}/schedule/items/${itemId}`, 'PUT', body);
    toast('Đã lưu', 'success');
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function deleteItem(itemId) {
  const tripId = document.getElementById('ts-trip-id').value;
  if (!confirm('Xóa mục này?')) return;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/items/${itemId}`, 'DELETE');
    toast('Đã xóa', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function addItemToDay(dayId) {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/items`, 'POST', {
      dayId,
      startTime: '08:00',
      title: 'Hoạt động mới',
    });
    toast('Đã thêm mục', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function updateDayTitle(dayId, title) {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/days/${dayId}`, 'PUT', { title: title || null });
  } catch (e) {
    // silent
  }
}

async function addTripDay() {
  const tripId = document.getElementById('ts-trip-id').value;
  try {
    const data = await req(`/api/partner/trips/${tripId}/schedule`);
    const maxDay = data.days.length ? Math.max(...data.days.map(d => d.dayNumber)) : 0;
    await req(`/api/partner/trips/${tripId}/schedule/days`, 'POST', {
      dayNumber: maxDay + 1,
      title: '',
    });
    toast('Đã thêm ngày mới', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function deleteDay(dayId, dayNumber) {
  const tripId = document.getElementById('ts-trip-id').value;
  if (!confirm(`Xóa ngày ${dayNumber} và tất cả mục bên trong?`)) return;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/days/${dayId}`, 'DELETE');
    toast('Đã xóa ngày', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi: ' + e.message, 'error');
  }
}

async function sendTripUpdate() {
  const tripId = document.getElementById('ts-trip-id').value;
  const msgInput = document.getElementById('ts-update-msg');
  const message = msgInput.value.trim();
  if (!message) return;
  try {
    await req(`/api/partner/trips/${tripId}/schedule/updates`, 'POST', { message });
    msgInput.value = '';
    toast('Đã gửi thông báo!', 'success');
    loadTripSchedule(tripId);
  } catch (e) {
    toast('Lỗi gửi thông báo: ' + e.message, 'error');
  }
}


async function loadUsers(){ data.users=await req('/api/partner/users'); renderUsers(data.users); }
function renderUsers(rows){
  const tb=document.getElementById('tb-users'), em=document.getElementById('empty-users');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(u=>listRow([
    {label:'Tên', val:u.name, cls:'w-1/3'},
    {label:'Email', val:u.email},
    {label:'Ngày tạo', val:new Date(u.createdAt).toLocaleDateString('vi-VN')}
  ], `
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('user','${u.id}','${u.name}')"><i class="fa-solid fa-ban"></i></button>
  `)).join('');
}
function openUserModal(){ document.getElementById('u-name').value=''; document.getElementById('u-email').value=''; document.getElementById('u-pass').value=''; openModal('modal-user'); }
async function saveUser(){
  try{ await req('/api/partner/users','POST',{name:v('u-name'), email:v('u-email'), password:v('u-pass')}); closeModal('modal-user'); await loadUsers(); toast('Đã tạo User','success'); }catch(e){toast(e.message,'error');}
}

// ── DOCUMENTS ──
async function loadDocuments(){ data.documents=await req('/api/partner/documents'); renderDocuments(data.documents); }
function renderDocuments(rows){
  const tb=document.getElementById('tb-documents'), em=document.getElementById('empty-documents');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(d=>listRow([
    {label:'Icon', val:`<i class="fa-solid ${d.icon} ${d.color} text-xl"></i>`},
    {label:'Tiêu đề', val:d.title, cls:'w-1/3'},
    {label:'Mô tả', val:d.description}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editDocument('${d.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('document','${d.id}','${d.title}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openDocumentModal(doc=null){
  document.getElementById('mdoc-title').textContent=doc?'Sửa Tài Liệu':'Thêm Tài Liệu';
  document.getElementById('d-id').value=doc?.id??'';
  ['title','icon','color','desc'].forEach(k=>document.getElementById(`d-${k}`).value=doc?.[k==='desc'?'description':k]??'');
  openModal('modal-document');
}
function editDocument(id){openDocumentModal(data.documents.find(x=>x.id===id));}
async function saveDocument(){
  const id=document.getElementById('d-id').value;
  const body={title:v('d-title'), icon:v('d-icon'), color:v('d-color'), description:v('d-desc')};
  try{ if(id)await req(`/api/partner/documents/${id}`,'PUT',body); else await req('/api/partner/documents','POST',body); closeModal('modal-document'); await loadDocuments(); toast('Lưu thành công','success'); }catch(e){toast(e.message,'error');}
}

// ── CATEGORIES & MISC ──

// ── DESTINATIONS ──
async function loadDestinations(){ data.destinations=await req('/api/partner/destinations'); renderDestinations(data.destinations); }
function renderDestinations(rows){
  const tb=document.getElementById('tb-destinations'), em=document.getElementById('empty-destinations');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(d=>listRow([
    {label:'Tên', val:d.name, cls:'w-1/3'},
    {label:'Vị trí', val:d.location},
    {label:'Danh mục', val:d.category},
    {label:'Tags', val:(d.isFavorite?'<span class="px-2 py-1 bg-red-100 text-red-500 rounded-full text-xs mr-2"><i class="fa-solid fa-heart"></i></span>':'')+(d.isRecommended?'<span class="px-2 py-1 bg-blue-100 text-blue-500 rounded-full text-xs"><i class="fa-solid fa-thumbs-up"></i></span>':'')}
  ], `
    <button class="w-10 h-10 rounded-full bg-offwhite hover:bg-silver text-ink transition-all flex items-center justify-center" onclick="editDestination('${d.id}')"><i class="fa-solid fa-pen"></i></button>
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('destination','${d.id}','${d.name.replace(/'/g,"\\'")}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
function openDestinationModal(dest=null){
  document.getElementById('mdest-title').textContent=dest?'Cập nhật Điểm đến':'Thêm Điểm đến';
  document.getElementById('ds-id').value=dest?.id??'';
  document.getElementById('ds-slug').value=dest?.id??'';
  document.getElementById('ds-slug').disabled=!!dest;
  ['name','loc','cat','rating','desc'].forEach(k=>document.getElementById(`ds-${k}`).value=dest?.[k==='loc'?'location':k==='cat'?'category':k==='desc'?'description':k]??'');
  setImg('ds-img', dest?.imagePath??'');
  document.getElementById('ds-fav').checked=dest?.isFavorite??false;
  document.getElementById('ds-rec').checked=dest?.isRecommended??false;
  openModal('modal-destination');
}
function editDestination(id){openDestinationModal(data.destinations.find(x=>x.id===id));}
async function saveDestination(){
  const id=document.getElementById('ds-id').value;
  const body={ id:id||v('ds-slug')||`dest-${Date.now()}`, name:v('ds-name'), location:v('ds-loc'), category:v('ds-cat'), rating:v('ds-rating'), imagePath:v('ds-img'), description:v('ds-desc'), isFavorite:document.getElementById('ds-fav').checked, isRecommended:document.getElementById('ds-rec').checked };
  try{ if(id)await req(`/api/partner/destinations/${id}`,'PUT',body); else await req('/api/partner/destinations','POST',body); closeModal('modal-destination'); await loadDestinations(); toast(id?'Đã cập nhật':'Đã thêm mới','success'); }catch(e){toast(e.message,'error');}
}

async function loadCategories(){ data.categories=await req('/api/partner/categories'); renderCategories(data.categories); }
function renderCategories(rows){
  const tb=document.getElementById('tb-categories'), em=document.getElementById('empty-categories');
  if(!rows.length){tb.innerHTML='';em.style.display='block';return;}
  em.style.display='none';
  tb.innerHTML=rows.map(c=>listRow([ {label:'ID', val:c.id, cls:'font-mono text-muted'}, {label:'Tên danh mục', val:c.name, cls:'w-1/2'} ], `
    <button class="w-10 h-10 rounded-full bg-red-50 hover:bg-red-500 hover:text-white text-red-500 transition-all flex items-center justify-center" onclick="confirmDel('category','${c.id}','${c.name}')"><i class="fa-solid fa-trash"></i></button>
  `)).join('');
}
async function saveCategory(){ try{ await req('/api/partner/categories','POST',{name:v('cat-name')}); closeModal('modal-category'); await loadCategories(); toast('Đã thêm','success'); }catch(e){toast(e.message,'error');} }

function confirmDel(type,id,name){
  document.getElementById('confirm-msg').textContent=`Chắc chắn xóa "${name}"?`;
  document.getElementById('confirm-ok').onclick = async ()=>{
    let path=`/api/partner/${type}s/${id}`;
    if(type==='room') path=`/api/partner/hotels/${document.getElementById('h-id').value}/rooms/${id}`;
    try{ await req(path,'DELETE'); closeModal('modal-confirm'); if(type==='room'){await loadHotels(); editHotel(document.getElementById('h-id').value);}else await loadPage(curPage); toast('Đã xóa','success'); }catch(e){toast(e.message,'error');}
  };
  openModal('modal-confirm');
}

function openModal(id){document.getElementById(id).classList.add('open');}
function closeModal(id){document.getElementById(id).classList.remove('open');}
document.querySelectorAll('.modal-overlay').forEach(o=>o.addEventListener('click',e=>{if(e.target===o)o.classList.remove('open');}));
function toast(msg,type='info'){
  const el=document.createElement('div'); el.className=`toast`;
  el.innerHTML=`<div class="w-2 h-2 rounded-full ${type==='error'?'bg-red-500':'bg-primary'}"></div><span class="text-ink">${msg}</span>`;
  document.getElementById('toasts').appendChild(el);
  setTimeout(()=>{el.style.opacity='0';el.style.transform='translateY(20px)';setTimeout(()=>el.remove(),600);},3000);
}
const v=id=>document.getElementById(id).value.trim();
const fmtUSD=p=>p!=null?new Intl.NumberFormat('en-US',{style:'currency',currency:'USD',maximumFractionDigits:0}).format(p):'—';

function promptLogin(){
  const user=prompt('Admin Username:');
  if(user===null) return false;
  const pass=prompt('Admin Password:');
  if(pass===null) return false;
  sessionStorage.setItem('adminAuth',btoa(user+':'+pass));
  return true;
}


async function OLD_initAdmin(){
  try{
    await req('/api/partner/stats');
    document.getElementById('login-screen').style.display='none';
    checkHealth(); loadDashboard(); setInterval(checkHealth, 30000);
  }catch(e){
    // Show login
    document.getElementById('login-screen').style.display='flex';
    document.getElementById('login-screen').style.opacity='1';
  }
}

initPartner();
