(() => {
  "use strict";

  const STORE_KEY = "counter.value";
  const countNode = document.querySelector("#count");
  const statusNode = document.querySelector("#runtime-status");
  const activityNode = document.querySelector("#activity");
  let count = 0;
  let nativeApi = null;

  const setStatus = (kind, label) => {
    statusNode.className = `status ${kind}`;
    statusNode.lastElementChild.textContent = label;
  };

  const render = () => {
    countNode.value = String(count);
    countNode.textContent = String(count);
  };

  const hasNativeRoutes = (api) => {
    const required = ["store.get", "store.set", "store.delete", "log.write"];
    return api && typeof api.can === "function" && required.every((route) => api.can(route));
  };

  const loadCount = async () => {
    if (nativeApi) {
      const result = await nativeApi.invoke("store.get", { key: STORE_KEY });
      if (result && result.found) {
        count = Number.parseInt(result.value, 10) || 0;
      }
      return;
    }
    count = Number.parseInt(localStorage.getItem(STORE_KEY) || "0", 10) || 0;
  };

  const saveCount = async () => {
    if (nativeApi) {
      await nativeApi.invoke("store.set", { key: STORE_KEY, value: String(count) });
      await nativeApi.invoke("log.write", {
        level: "info",
        target: "counter-demo",
        message: `count changed to ${count}`,
      });
      return;
    }
    localStorage.setItem(STORE_KEY, String(count));
  };

  const resetCount = async () => {
    count = 0;
    if (nativeApi) {
      await nativeApi.invoke("store.delete", { key: STORE_KEY });
      await nativeApi.invoke("log.write", {
        level: "info",
        target: "counter-demo",
        message: "count reset",
      });
    } else {
      localStorage.removeItem(STORE_KEY);
    }
  };

  const perform = async (action) => {
    try {
      if (action === "increment") {
        count += 1;
        await saveCount();
        activityNode.textContent = `已增加到 ${count}`;
      } else if (action === "decrement") {
        count -= 1;
        await saveCount();
        activityNode.textContent = `已减少到 ${count}`;
      } else {
        await resetCount();
        activityNode.textContent = "计数已重置";
      }
      render();
    } catch (error) {
      setStatus("error", "Bridge error");
      activityNode.textContent = error instanceof Error ? error.message : String(error);
    }
  };

  const start = async () => {
    nativeApi = hasNativeRoutes(window.lepusa) ? window.lepusa : null;
    setStatus(nativeApi ? "native" : "fallback", nativeApi ? "Native bridge" : "Browser preview");
    try {
      await loadCount();
      render();
    } catch (error) {
      setStatus("error", "Bridge error");
      activityNode.textContent = error instanceof Error ? error.message : String(error);
    }
  };

  document.querySelectorAll("[data-action]").forEach((button) => {
    button.addEventListener("click", () => perform(button.dataset.action));
  });

  start();
})();
