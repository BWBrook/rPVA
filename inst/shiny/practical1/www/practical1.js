$(document).on("shiny:busy", function () {
  $("#run_stage").prop("disabled", true).attr("aria-busy", "true");
});

$(document).on("shiny:idle", function () {
  $("#run_stage").prop("disabled", false).removeAttr("aria-busy");
});

(function () {
  var lastModalTrigger = null;

  function syncActiveTabAria() {
    $(".navbar-nav > li > a").removeAttr("aria-current");
    $(".navbar-nav > li.active > a").attr("aria-current", "page");
  }

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
  $(document).on("shiny:connected", syncActiveTabAria);
  $(syncActiveTabAria);
})();
