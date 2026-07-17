const fs = require("node:fs");
const path = require("node:path");
const { chromium } = require("@playwright/test");

const baseURL = process.env.PRACTICAL1_URL || "http://127.0.0.1:49581";
const evidenceDir = process.env.PRACTICAL1_EVIDENCE_DIR || "/tmp/rpva-practical1-risk-probe";

function assert(condition, message, detail = "") {
  if (!condition) throw new Error(`${message}${detail ? `: ${detail}` : ""}`);
}

async function setSlider(page, id, value) {
  await page.locator(`#${id}`).evaluate((element, nextValue) => {
    const slider = window.jQuery?.(element).data("ionRangeSlider");
    if (slider) {
      slider.update({ from: nextValue });
    } else {
      element.value = String(nextValue);
      element.dispatchEvent(new Event("input", { bubbles: true }));
      element.dispatchEvent(new Event("change", { bubbles: true }));
    }
    window.Shiny?.setInputValue(element.id, nextValue, { priority: "event" });
  }, value);
  await page.waitForFunction(
    ({ inputId, expected }) => Number(document.querySelector(`#${inputId}`)?.value) === expected,
    { inputId: id, expected: value }
  );
}

async function setSelect(page, id, value) {
  await page.locator(`#${id}`).evaluate((element, nextValue) => {
    if (element.selectize) {
      element.selectize.setValue(String(nextValue));
      return;
    }
    element.value = String(nextValue);
    element.dispatchEvent(new Event("change", { bubbles: true }));
  }, value);
  await page.waitForFunction(
    ({ inputId, expected }) => document.querySelector(`#${inputId}`)?.value === expected,
    { inputId: id, expected: String(value) }
  );
}

async function waitForCompletedRun(page, beforeRunId) {
  await page.waitForFunction(
    (before) => {
      const cue = document.querySelector(".mission-complete");
      return cue?.dataset.runId && cue.dataset.runId !== before;
    },
    beforeRunId,
    { timeout: 60000 }
  );
}

async function completedRunId(page) {
  const cue = page.locator(".mission-complete");
  return await cue.count() ? cue.first().getAttribute("data-run-id") : null;
}

async function main() {
  fs.rmSync(evidenceDir, { recursive: true, force: true });
  fs.mkdirSync(evidenceDir, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  const consoleErrors = [];
  const pageErrors = [];
  page.on("console", (message) => {
    if (message.type() === "error") consoleErrors.push(message.text());
  });
  page.on("pageerror", (error) => pageErrors.push(error.message));

  try {
    await page.goto(baseURL, { waitUntil: "networkidle" });
    await page.getByRole("button", { name: "Create baseline run" }).click();
    await page.getByRole("button", { name: "Rerun baseline" }).waitFor();

    await setSlider(page, "years", 50);
    await page.getByLabel("Show advanced risk controls").check();
    await page.locator("#mortality_pct").waitFor({ state: "attached" });
    await setSelect(page, "mortality_pct", -10);
    await setSelect(page, "fecundity_pct", 5);

    const baselineBefore = await completedRunId(page);
    await page.getByRole("button", { name: "Rerun baseline" }).click();
    await waitForCompletedRun(page, baselineBefore);
    assert(await completedRunId(page) === "2", "Changed baseline did not create run 2");

    await page.locator(".mission-rail").getByRole("link", { name: /Core 2: Island ceiling/ }).click();
    await page.locator("#stage_text .mission-label").filter({ hasText: "Core 2: Island ceiling" }).waitFor();
    await page.locator("#advanced_years").waitFor({ state: "attached" });
    assert(await page.locator("#advanced_years").inputValue() === "50", "Projection years were not inherited");
    assert(await page.locator("#mortality_pct").inputValue() === "-10", "Mortality change was not inherited");
    assert(await page.locator("#fecundity_pct").inputValue() === "5", "Fecundity change was not inherited");

    await setSlider(page, "K_sd", 5);
    await setSelect(page, "advanced_reps", 1000);
    await page.evaluate(() => {
      window.__practical1Progress = [];
      window.__practical1ProgressObserver = new MutationObserver(() => {
        const messages = document.body.innerText.match(/Simulating future \d+ of 1000/g) || [];
        messages.forEach((text) => {
          if (!window.__practical1Progress.includes(text)) window.__practical1Progress.push(text);
        });
      });
      window.__practical1ProgressObserver.observe(document.body, {
        childList: true,
        subtree: true,
        characterData: true
      });
    });

    const missionBefore = await completedRunId(page);
    await page.getByRole("button", { name: "Run mission" }).click();
    await waitForCompletedRun(page, missionBefore);
    const progress = await page.evaluate(() => window.__practical1Progress || []);
    const simulatedFutures = progress
      .map((message) => message.match(/Simulating future (\d+) of 1000/))
      .filter(Boolean)
      .map((match) => Number(match[1]));
    assert(simulatedFutures.length > 1, "No completed-future progress messages were observed", JSON.stringify(progress));
    assert(
      simulatedFutures.every((value, index) => index === 0 || value >= simulatedFutures[index - 1]),
      "Completed-future progress was not monotonic",
      JSON.stringify(simulatedFutures)
    );

    const settingsRows = await page.locator("#settings_table tbody tr").evaluateAll((rows) => rows.map((row) =>
      [...row.querySelectorAll("td")].map((cell) => cell.textContent.trim())
    ));
    const yearsRow = settingsRows.find((row) => row[0] === "Projection years");
    assert(yearsRow?.[2] === "50", "Settings record did not retain 50 years", JSON.stringify(yearsRow));
    assert(yearsRow?.[3] === "Higher than baseline", "Settings record did not compare against pinned run 1", JSON.stringify(yearsRow));

    const extinctionImage = page.locator("#extinction_plot img");
    const quasiImage = page.locator("#quasi_extinction_plot img");
    await extinctionImage.waitFor({ state: "visible", timeout: 30000 });
    await quasiImage.waitFor({ state: "visible", timeout: 30000 });
    const imageState = await Promise.all([extinctionImage, quasiImage].map((locator) => locator.evaluate((image) => ({
      complete: image.complete,
      width: image.naturalWidth,
      height: image.naturalHeight
    }))));
    assert(imageState.every((image) => image.complete && image.width > 200 && image.height > 200), "A risk plot did not render", JSON.stringify(imageState));

    const screenshot = path.join(evidenceDir, "core2-integrated-risk-1440x900.png");
    await page.screenshot({ path: screenshot, fullPage: true });
    const result = {
      passed: true,
      assumptions: { years: 50, mortality_pct: -10, fecundity_pct: 5 },
      futures: 1000,
      progressMessagesObserved: progress.length,
      firstCompletedFuture: simulatedFutures[0],
      lastCompletedFuture: simulatedFutures.at(-1),
      settingsYearsRow: yearsRow,
      riskImages: imageState,
      consoleErrors,
      pageErrors,
      screenshot
    };
    fs.writeFileSync(path.join(evidenceDir, "result.json"), `${JSON.stringify(result, null, 2)}\n`);
    assert(consoleErrors.length === 0, "Browser console errors occurred", JSON.stringify(consoleErrors));
    assert(pageErrors.length === 0, "Browser page errors occurred", JSON.stringify(pageErrors));
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  } finally {
    await browser.close();
  }
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exitCode = 1;
});
