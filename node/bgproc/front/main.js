let dl_dir = null
function checkDownload(dl_dir, success) {
  $.ajax({
    url: "/api/download/" + dl_dir,
    success: success,
    dataType: 'json',
  })
}

function success(data) {
  if (data.success) {
    window.location = "/download/" + dl_dir
  } else {
    setTimeout(() => {
      checkDownload(dl_dir, success)
    }, 5000)
  }
}

function fetchData() {
  dl_dir = document.getElementById('dl-dir').value
  $.get("/api/mkdownload/" + dl_dir, (data) => {
    $('#msg').html('Requested download')
    checkDownload(dl_dir, success)
  })
}
