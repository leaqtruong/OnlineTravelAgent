
function renderUploadField(idLabel, idInput, idImg){
  return `
    <div class="col-span-2">
      <label class="text-[10px] uppercase tracking-widest text-muted font-bold block mb-2">${idLabel} (Upload Ảnh)</label>
      <div class="upload-box h-32 flex flex-col items-center justify-center group">
        <div class="text-silver group-hover:text-primary transition-all text-3xl mb-2"><i class="fa-solid fa-cloud-arrow-up"></i></div>
        <div class="text-xs font-bold text-muted group-hover:text-primary transition-all">Click để chọn file</div>
        <img id="${idImg}" class="upload-img">
        <input type="file" id="file-${idInput}" class="upload-input" accept="image/*" onchange="handleUpload(this, '${idInput}', '${idImg}')">
        <input type="hidden" id="${idInput}">
      </div>
    </div>
  `;
}
async function handleUpload(fileInput, hiddenId, imgId){
  const file = fileInput.files[0];
  if(!file) return;
  const fd = new FormData(); fd.append('file', file);
  try {
    const r = await fetch(API+'/api/partner/upload', {method:'POST', headers:{'Authorization':'Bearer '+localStorage.getItem('token')}, body:fd});
    if(!r.ok) throw new Error("Upload failed");
    const json = await r.json();
    document.getElementById(hiddenId).value = json.url;
    const imgEl = document.getElementById(imgId);
    imgEl.src = API + json.url;
    imgEl.classList.add('show');
    toast("Upload thành công", "success");
  }catch(e){ toast(e.message, "error"); }
}
