"use strict";

const STORAGE_KEY = "favorites";

const STAR_FILLED =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M12 2l2.9 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77 5.82 21l1.18-6.88-5-4.87 7.1-1.01z"/></svg>';
const STAR_OUTLINE =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round" d="M12 3.5l2.6 5.6 6.1.9-4.4 4.3 1.03 6.05L12 17.9 6.67 20.35 7.7 14.3 3.3 10l6.1-.9z"/></svg>';
const SAVE_ICON =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M17 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V7l-4-4zm-5 16a3 3 0 1 1 0-6 3 3 0 0 1 0 6zm3-10H6V5h9v4z"/></svg>';
const TRASH_ICON =
  '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="M6 7h12l-1 13a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2L6 7zm3-3h6l1 2h4v2H4V6h4l1-2z"/></svg>';

let currentTab = null;
let favorites = [];

document.addEventListener("DOMContentLoaded", init);

async function init() {
  document.getElementById("add-flag").addEventListener("click", () => addFlag());
  document.getElementById("apply").addEventListener("click", applyFlags);

  currentTab = await getActiveTab();
  favorites = await loadFavorites();

  updateHeader(currentTab);

  const urlFlags = currentTab ? parseFlags(currentTab.url) : {};
  const rows = mergeFlags(urlFlags, favorites);
  renderRows(rows);
}

function getActiveTab() {
  return new Promise((resolve) => {
    try {
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        resolve(tabs && tabs[0] ? tabs[0] : null);
      });
    } catch {
      resolve(null);
    }
  });
}

function loadFavorites() {
  return new Promise((resolve) => {
    try {
      chrome.storage.local.get([STORAGE_KEY], (data) => {
        const favs = data && Array.isArray(data[STORAGE_KEY]) ? data[STORAGE_KEY] : [];
        resolve(favs);
      });
    } catch {
      resolve([]);
    }
  });
}

function persistFavorites() {
  return new Promise((resolve) => {
    try {
      chrome.storage.local.set({ [STORAGE_KEY]: favorites }, () => resolve());
    } catch {
      resolve();
    }
  });
}

function parseFlags(urlString) {
  const result = {};
  try {
    const url = new URL(urlString);
    for (const [key, value] of url.searchParams.entries()) {
      if (key) result[key] = value;
    }
  } catch {
    /* not a valid URL - ignore */
  }
  return result;
}

function mergeFlags(urlFlags, favs) {
  const map = new Map();
  for (const fav of favs) {
    if (!fav || !fav.name) continue;
    map.set(fav.name, {
      name: fav.name,
      value: fav.value != null ? fav.value : "",
      active: false,
      favorite: true,
    });
  }
  for (const [name, value] of Object.entries(urlFlags)) {
    const existing = map.get(name);
    map.set(name, {
      name,
      value,
      active: true,
      favorite: existing ? existing.favorite : false,
    });
  }
  const rows = Array.from(map.values());
  rows.sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
  return rows;
}

function updateHeader(tab) {
  const label = document.getElementById("host-label");
  const warning = document.getElementById("host-warning");
  let host = "";
  let supported = false;
  try {
    const url = new URL(tab.url);
    host = url.hostname;
    supported = url.protocol === "http:" || url.protocol === "https:";
  } catch {
    host = "";
  }
  label.textContent = host;
  warning.hidden = supported;
}

function renderRows(rows) {
  const list = document.getElementById("flag-list");
  list.textContent = "";
  if (!rows.length) {
    const hint = document.createElement("div");
    hint.className = "empty-hint";
    hint.textContent = 'No feature flags found. Use "Add feature flag" to create one.';
    list.appendChild(hint);
    return;
  }
  for (const row of rows) {
    list.appendChild(createRow(row));
  }
}

function createRow(data) {
  const row = document.createElement("div");
  row.className = "flag-row";

  const checkbox = document.createElement("input");
  checkbox.type = "checkbox";
  checkbox.className = "flag-active";
  checkbox.checked = !!data.active;
  checkbox.title = "Include this flag when applying";

  const name = document.createElement("input");
  name.type = "text";
  name.className = "flag-name";
  name.placeholder = "feature.name";
  name.value = data.name || "";
  name.spellcheck = false;
  name.autocapitalize = "off";

  const sep = document.createElement("span");
  sep.className = "sep";
  sep.textContent = ":";

  const value = document.createElement("input");
  value.type = "text";
  value.className = "flag-value";
  value.setAttribute("list", "common-values");
  value.placeholder = "value";
  value.value = data.value || "";
  value.spellcheck = false;
  value.autocapitalize = "off";

  const saveBtn = document.createElement("button");
  saveBtn.type = "button";
  saveBtn.className = "icon-btn save-btn";
  saveBtn.title = "Save current value to favorites";
  saveBtn.innerHTML = SAVE_ICON;

  const starBtn = document.createElement("button");
  starBtn.type = "button";
  starBtn.className = "icon-btn star-btn";
  starBtn.title = "Toggle favorite";
  updateStar(starBtn, !!data.favorite);

  const delBtn = document.createElement("button");
  delBtn.type = "button";
  delBtn.className = "icon-btn del-btn";
  delBtn.title = "Remove flag";
  delBtn.innerHTML = TRASH_ICON;

  saveBtn.addEventListener("click", async () => {
    const n = name.value.trim();
    if (!n) {
      name.focus();
      return;
    }
    upsertFavorite(n, value.value.trim());
    updateStar(starBtn, true);
    await persistFavorites();
    flash(saveBtn);
  });

  starBtn.addEventListener("click", async () => {
    const n = name.value.trim();
    if (!n) {
      name.focus();
      return;
    }
    const isFav = toggleFavorite(n, value.value.trim());
    updateStar(starBtn, isFav);
    await persistFavorites();
  });

  delBtn.addEventListener("click", async () => {
    const n = name.value.trim();
    if (removeFavorite(n)) {
      await persistFavorites();
    }
    row.remove();
  });

  row.append(checkbox, name, sep, value, saveBtn, starBtn, delBtn);
  return row;
}

function updateStar(btn, isFavorite) {
  btn.classList.toggle("active", isFavorite);
  btn.innerHTML = isFavorite ? STAR_FILLED : STAR_OUTLINE;
}

function upsertFavorite(name, value) {
  const idx = favorites.findIndex((f) => f.name === name);
  if (idx >= 0) {
    favorites[idx].value = value;
  } else {
    favorites.push({ name, value });
  }
}

function toggleFavorite(name, value) {
  const idx = favorites.findIndex((f) => f.name === name);
  if (idx >= 0) {
    favorites.splice(idx, 1);
    return false;
  }
  favorites.push({ name, value });
  return true;
}

function removeFavorite(name) {
  const idx = favorites.findIndex((f) => f.name === name);
  if (idx >= 0) {
    favorites.splice(idx, 1);
    return true;
  }
  return false;
}

function flash(btn) {
  btn.classList.add("flash");
  setTimeout(() => btn.classList.remove("flash"), 800);
}

function addFlag() {
  const list = document.getElementById("flag-list");
  const hint = list.querySelector(".empty-hint");
  if (hint) hint.remove();
  const row = createRow({ name: "", value: "", active: true, favorite: false });
  list.appendChild(row);
  row.scrollIntoView({ block: "nearest" });
  const nameInput = row.querySelector(".flag-name");
  if (nameInput) nameInput.focus();
}

function applyFlags() {
  if (!currentTab || !currentTab.url) return;

  const parts = [];
  const seen = new Set();
  const rows = document.querySelectorAll(".flag-row");
  rows.forEach((row) => {
    const active = row.querySelector(".flag-active").checked;
    const name = row.querySelector(".flag-name").value.trim();
    const value = row.querySelector(".flag-value").value.trim();
    if (!active || !name || seen.has(name)) return;
    seen.add(name);
    parts.push(
      value === ""
        ? encodeURIComponent(name)
        : `${encodeURIComponent(name)}=${encodeURIComponent(value)}`
    );
  });

  let target;
  try {
    const url = new URL(currentTab.url);
    const search = parts.length ? "?" + parts.join("&") : "";
    target = url.origin + url.pathname + search + url.hash;
  } catch {
    return;
  }

  try {
    chrome.tabs.update(currentTab.id, { url: target }, () => window.close());
  } catch {
    window.close();
  }
}
