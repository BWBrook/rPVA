(function () {
  "use strict";

  var DATABASE_NAME = "rPVA-practical2-projects";
  var STORE_NAME = "project_snapshots";
  var CONTRACT_VERSION = "woodhen-project-store-contract-v1";
  var DATABASE_VERSION = 1;
  var MAX_SNAPSHOT_BYTES = 50 * 1024 * 1024;
  var SAVE_DELAY_MS = 350;
  var pendingSaves = new Map();
  var lastModalTrigger = null;

  function isObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
  }

  function hasExactKeys(value, keys) {
    if (!isObject(value)) {
      return false;
    }
    var actual = Object.keys(value).sort();
    var expected = keys.slice().sort();
    return actual.length === expected.length && actual.every(function (key, index) {
      return key === expected[index];
    });
  }

  function isText(value) {
    return typeof value === "string" && value.length > 0;
  }

  function isFingerprint(value) {
    return typeof value === "string" && /^[0-9a-f]{64}$/.test(value);
  }

  function storageKey(schema_version, project_id) {
    return schema_version + "::" + project_id;
  }

  function validIdentity(value) {
    return isText(value.schema_version) &&
      /^woodhen_project_[0-9a-f]{16}$/.test(value.project_id) &&
      isFingerprint(value.project_fingerprint) &&
      value.key === storageKey(value.schema_version, value.project_id);
  }

  function validRecord(record) {
    var fields = [
      "key", "contract_version", "schema_version", "project_id",
      "project_fingerprint", "title", "modified_at", "saved_at",
      "portable_request_fingerprint", "snapshot_json"
    ];
    if (!hasExactKeys(record, fields) || record.contract_version !== CONTRACT_VERSION ||
        !validIdentity(record) ||
        !(record.title === null || typeof record.title === "string") ||
        !isText(record.modified_at) || !isText(record.saved_at) ||
        !(record.portable_request_fingerprint === null ||
          isFingerprint(record.portable_request_fingerprint)) ||
        typeof record.snapshot_json !== "string") {
      return false;
    }
    return new TextEncoder().encode(record.snapshot_json).byteLength <= MAX_SNAPSHOT_BYTES;
  }

  function validRequest(message, fields) {
    return hasExactKeys(message, fields) &&
      message.contract_version === CONTRACT_VERSION &&
      isText(message.request_id) &&
      isText(message.key);
  }

  function openDatabase(onSuccess, onError) {
    var request = window.indexedDB.open(DATABASE_NAME, DATABASE_VERSION);
    request.onupgradeneeded = function (event) {
      var database = event.target.result;
      if (!database.objectStoreNames.contains(STORE_NAME)) {
        database.createObjectStore(STORE_NAME, { keyPath: "key" });
      }
    };
    request.onerror = function () {
      onError(request.error || new Error("IndexedDB could not be opened."));
    };
    request.onsuccess = function () {
      onSuccess(request.result);
    };
  }

  function withStore(mode, operation, onError) {
    openDatabase(function (database) {
      var transaction = database.transaction(STORE_NAME, mode);
      var store = transaction.objectStore(STORE_NAME);
      transaction.onerror = function () {
        onError(transaction.error || new Error("IndexedDB transaction failed."));
      };
      transaction.addEventListener("complete", function () {
        database.close();
      });
      operation(store, transaction);
    }, onError);
  }

  function inventoryMetadata(record) {
    return {
      key: record.key,
      contract_version: record.contract_version,
      schema_version: record.schema_version,
      project_id: record.project_id,
      project_fingerprint: record.project_fingerprint,
      title: record.title,
      modified_at: record.modified_at,
      saved_at: record.saved_at,
      portable_request_fingerprint: record.portable_request_fingerprint
    };
  }

  function publishInventory() {
    withStore("readonly", function (store) {
      var request = store.getAll();
      request.onerror = function () {
        Shiny.setInputValue("project_store_inventory", {
          contract_version: CONTRACT_VERSION,
          records: []
        }, { priority: "event" });
      };
      request.onsuccess = function () {
        var records = request.result.filter(validRecord).map(inventoryMetadata);
        records.sort(function (left, right) {
          return right.saved_at.localeCompare(left.saved_at);
        });
        Shiny.setInputValue("project_store_inventory", {
          contract_version: CONTRACT_VERSION,
          records: records
        }, { priority: "event" });
      };
    }, function () {
      Shiny.setInputValue("project_store_inventory", {
        contract_version: CONTRACT_VERSION,
        records: []
      }, { priority: "event" });
    });
  }

  function sendStatus(message, status, detail) {
    Shiny.setInputValue("project_store_status", {
      contract_version: CONTRACT_VERSION,
      request_id: message.request_id,
      key: message.key,
      status: status,
      project_id: message.record ? message.record.project_id : message.project_id,
      project_fingerprint: message.record ?
        message.record.project_fingerprint : message.project_fingerprint,
      message: detail
    }, { priority: "event" });
  }

  function sendRestore(message, record) {
    Shiny.setInputValue("project_store_restore", {
      contract_version: CONTRACT_VERSION,
      request_id: message.request_id,
      key: message.key,
      record: record
    }, { priority: "event" });
  }

  function restoreProject(message) {
    var fields = [
      "contract_version", "request_id", "key", "schema_version",
      "project_id", "project_fingerprint"
    ];
    if (!validRequest(message, fields) || !validIdentity(message)) {
      return;
    }
    withStore("readonly", function (store) {
      var request = store.get(message.key);
      request.onerror = function () {
        sendRestore(message, null);
      };
      request.onsuccess = function () {
        var record = request.result;
        if (!validRecord(record) || record.project_id !== message.project_id ||
            record.project_fingerprint !== message.project_fingerprint) {
          record = null;
        }
        sendRestore(message, record);
      };
    }, function () {
      sendRestore(message, null);
    });
  }

  function saveProject(message) {
    var fields = ["contract_version", "request_id", "key", "record"];
    if (!validRequest(message, fields) || !validRecord(message.record) ||
        message.key !== message.record.key) {
      return;
    }
    var earlier = pendingSaves.get(message.key);
    var portableRequests = [];
    if (earlier && !earlier.inFlight) {
      window.clearTimeout(earlier.timer);
      portableRequests = earlier.portableRequests;
      if (portableRequests.length) {
        message.record.portable_request_fingerprint =
          portableRequests[portableRequests.length - 1].project_fingerprint;
      }
      sendStatus(earlier.message, "superseded", "A newer save replaced this request.");
    }
    var entry = {
      timer: null,
      message: message,
      portableRequests: portableRequests,
      inFlight: false
    };
    var timer = window.setTimeout(function () {
      entry.inFlight = true;
      var settled = false;
      function fail() {
        if (!settled) {
          settled = true;
          if (pendingSaves.get(message.key) === entry) {
            pendingSaves.delete(message.key);
          }
          sendStatus(message, "save_error", "Browser autosave failed.");
          entry.portableRequests.forEach(function (portableMessage) {
            sendStatus(
              portableMessage,
              "portable_error",
              "Portable download status was not stored."
            );
          });
        }
      }
      withStore("readwrite", function (store, transaction) {
        var request = store.put(message.record);
        request.onerror = fail;
        transaction.onerror = fail;
        transaction.oncomplete = function () {
          if (!settled) {
            settled = true;
            if (pendingSaves.get(message.key) === entry) {
              pendingSaves.delete(message.key);
            }
            sendStatus(message, "saved", "Autosaved in this browser.");
            entry.portableRequests.forEach(function (portableMessage) {
              sendStatus(
                portableMessage,
                "portable_marked",
                "Project copy download requested."
              );
            });
          }
        };
      }, fail);
    }, SAVE_DELAY_MS);
    entry.timer = timer;
    pendingSaves.set(message.key, entry);
  }

  function markPortable(message) {
    var fields = [
      "contract_version", "request_id", "key", "schema_version",
      "project_id", "project_fingerprint"
    ];
    if (!validRequest(message, fields) || !validIdentity(message)) {
      return;
    }
    var pending = pendingSaves.get(message.key);
    if (pending && !pending.inFlight &&
        pending.message.record.project_id === message.project_id &&
        pending.message.record.project_fingerprint === message.project_fingerprint) {
      pending.message.record.portable_request_fingerprint = message.project_fingerprint;
      pending.portableRequests.push(message);
      return;
    }
    var settled = false;
    function fail() {
      if (!settled) {
        settled = true;
        sendStatus(message, "portable_error", "Portable download status was not stored.");
      }
    }
    withStore("readwrite", function (store, transaction) {
      var request = store.get(message.key);
      request.onerror = fail;
      request.onsuccess = function () {
        var record = request.result;
        if (!validRecord(record) || record.project_id !== message.project_id ||
            record.project_fingerprint !== message.project_fingerprint) {
          fail();
          return;
        }
        record.portable_request_fingerprint = message.project_fingerprint;
        var putRequest = store.put(record);
        putRequest.onerror = fail;
      };
      transaction.onerror = fail;
      transaction.oncomplete = function () {
        if (!settled) {
          settled = true;
          sendStatus(message, "portable_marked", "Project copy download requested.");
        }
      };
    }, fail);
  }

  function syncActiveTabAria() {
    $(".navbar-nav > li > a").removeAttr("aria-current");
    $(".navbar-nav > li.active > a").attr("aria-current", "page");
  }

  Shiny.addCustomMessageHandler("woodhen-project-store-restore", restoreProject);
  Shiny.addCustomMessageHandler("woodhen-project-store-save", saveProject);
  Shiny.addCustomMessageHandler("woodhen-project-store-mark-portable", markPortable);

  $(document).on("click", "button, a", function () {
    if (!$(this).closest("#shiny-modal").length) {
      lastModalTrigger = this;
    }
  });
  $(document).on("shown.bs.modal", "#shiny-modal", function () {
    var modal = $(this);
    var title = modal.find(".modal-title").first();
    title.attr("id", "shiny-modal-title");
    modal.attr({
      role: "dialog",
      "aria-modal": "true",
      "aria-labelledby": "shiny-modal-title"
    });
  });
  $(document).on("hidden.bs.modal", "#shiny-modal", function () {
    var trigger = lastModalTrigger;
    lastModalTrigger = null;
    window.setTimeout(function () {
      if (trigger && document.contains(trigger)) {
        trigger.focus();
      }
    }, 0);
  });
  $(document).on("shown.bs.tab", ".navbar-nav a", syncActiveTabAria);
  $(document).on("shiny:connected", function () {
    syncActiveTabAria();
    publishInventory();
  });
  $(syncActiveTabAria);
})();
