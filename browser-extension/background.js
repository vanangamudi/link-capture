const SERVER = "http://localhost:8080/capture";
const TOKEN = "CHANGE_ME";

browser.browserAction.onClicked.addListener(async (tab) => {
  try {
    const results = await browser.tabs.executeScript(tab.id, {
      code: `
        ({
          url: location.href,
          title: document.title,
          selection: window.getSelection().toString()
        });
      `
    });

    const data = results[0];

    await fetch(SERVER, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body:
        "token=" + encodeURIComponent(TOKEN) +
        "&url=" + encodeURIComponent(data.url) +
        "&title=" + encodeURIComponent(data.title) +
        "&body=" + encodeURIComponent(data.selection)
    });

    console.log("Saved:", data.url);

  } catch (e) {
    console.error("Failed:", e);
  }
});
