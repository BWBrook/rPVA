$(document).on("shiny:busy", function () {
  $("#run_stage").prop("disabled", true).attr("aria-busy", "true");
});

$(document).on("shiny:idle", function () {
  $("#run_stage").prop("disabled", false).removeAttr("aria-busy");
});
