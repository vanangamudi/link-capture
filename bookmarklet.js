javascript:(function(){
  fetch("http://localhost:8080/capture",{
    method:"POST",
    headers:{
      "Content-Type":"application/x-www-form-urlencoded"
    },
    body:
      "token=CHANGE_ME"+
      "&url="+encodeURIComponent(location.href)+
      "&title="+encodeURIComponent(document.title)+
      "&body="+encodeURIComponent(window.getSelection())
  })
  .then(res => res.text().then(t => ({status:res.status, body:t})))
  .then(r => alert("Status: "+r.status+"\n"+r.body))
  .catch(e => alert("Error: "+e));
})();



javascript:(function(){
  location.href =
    "http://localhost:8080/capture" +
    "?token=CHANGE_ME" +
    "&url=" + encodeURIComponent(location.href) +
    "&title=" + encodeURIComponent(document.title) +
    "&body=" + encodeURIComponent(window.getSelection());
})();
