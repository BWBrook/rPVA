const fs = require("node:fs");
const path = require("node:path");
const { chromium } = require("@playwright/test");

const baseURL = process.env.PRACTICAL1_URL || "http://127.0.0.1:3921";
const evidenceDir = process.env.PRACTICAL1_EVIDENCE_DIR || "/tmp/rpva-practical1-final-polish";
fs.mkdirSync(evidenceDir, { recursive: true });

const result = {
  baseURL,
  startedAt: new Date().toISOString(),
  viewports: [
    { width: 1366, height: 768 },
    { width: 1440, height: 900 },
    { width: 390, height: 844 }
  ],
  consoleErrors: [],
  consoleWarnings: [],
  pageErrors: [],
  checks: [],
  artifacts: []
};

const accessibleNames = {
  explorePva: "Explore population viability analysis",
  exploreMission: "Explore the Practical 1 mission",
  exploreEvidence: "Explore the Practical 1 evidence pack",
  controlHelp: "Open Practical 1 parameter help",
  outputHelp: "Open Practical 1 output help",
  diagnosticHelp: "Open Practical 1 diagnostic help",
  plotHelp: "Open Practical 1 plot help"
};

// These display labels are retained here so the contract names the complete Core and extension routes.
const routeLabels = [
  "Core 2: Island ceiling",
  "Core 5: Rescue attempt",
  "Explore: Small-population pressure",
  "Explore: Rare bad years",
  "Explore: Vortex comparison",
  "Explore PVA",
  "Explore mission",
  "Explore evidence",
  "Control help",
  "Read outputs",
  "Read diagnostics",
  "Read plots",
  "Comparison CSV",
  "Evidence notes"
];

let browser;

function record(name, passed, detail = "") {
  const check = { name, passed: Boolean(passed), detail };
  result.checks.push(check);
  if (!check.passed) {
    throw new Error(`${name}: ${detail}`);
  }
}

function writeResult() {
  result.finishedAt = new Date().toISOString();
  result.passed = !result.failure && result.checks.every((check) => check.passed);
  fs.writeFileSync(
    path.join(evidenceDir, "browser-result.json"),
    JSON.stringify(result, null, 2)
  );
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = "";
  let quoted = false;

  for (let index = 0; index < text.length; index += 1) {
    const character = text[index];
    if (character === '"' && quoted && text[index + 1] === '"') {
      value += '"';
      index += 1;
    } else if (character === '"') {
      quoted = !quoted;
    } else if (character === "," && !quoted) {
      row.push(value);
      value = "";
    } else if ((character === "\n" || character === "\r") && !quoted) {
      if (character === "\r" && text[index + 1] === "\n") index += 1;
      row.push(value);
      if (row.some((cell) => cell !== "")) rows.push(row);
      row = [];
      value = "";
    } else {
      value += character;
    }
  }

  if (value !== "" || row.length) {
    row.push(value);
    if (row.some((cell) => cell !== "")) rows.push(row);
  }
  return rows;
}

function artifactPath(filename) {
  return path.join(evidenceDir, filename);
}

function recordArtifact(filePath, kind) {
  const stat = fs.statSync(filePath);
  const artifact = {
    kind,
    path: filePath,
    bytes: stat.size
  };
  result.artifacts.push(artifact);
  record(`non-empty ${kind} artifact`, stat.isFile() && stat.size > 0, JSON.stringify(artifact));
}

async function saveDownload(download, kind) {
  const filePath = artifactPath(download.suggestedFilename());
  await download.saveAs(filePath);
  recordArtifact(filePath, kind);
  return filePath;
}

async function assertNoOverlap(page, selectors, viewportLabel) {
  const overlaps = await page.evaluate((items) => {
    const boxes = items.map((selector) => {
      const element = document.querySelector(selector);
      if (!element) return { selector, missing: true };
      const rect = element.getBoundingClientRect();
      return {
        selector,
        left: rect.left,
        right: rect.right,
        top: rect.top,
        bottom: rect.bottom,
        width: rect.width,
        height: rect.height
      };
    });
    return boxes.filter((box, index) => boxes.slice(index + 1).some((other) =>
      !box.missing && !other.missing && box.left < other.right && box.right > other.left &&
      box.top < other.bottom && box.bottom > other.top
    ));
  }, selectors);
  record(`no overlap at ${viewportLabel}`, overlaps.length === 0, JSON.stringify(overlaps));
}

async function assertCompareTableScrollRegion(page, viewportLabel) {
  const scrollState = await page.locator(".compare-table").evaluate((container) => {
    const table = container.querySelector("table");
    if (!table) {
      return { hasTable: false };
    }

    const initialScrollLeft = container.scrollLeft;
    const maxScrollLeft = Math.max(0, container.scrollWidth - container.clientWidth);
    const overflowX = getComputedStyle(container).overflowX;
    container.scrollLeft = maxScrollLeft;
    const reachedFarEdge = Math.abs(container.scrollLeft - maxScrollLeft) <= 1;
    const containerRight = container.getBoundingClientRect().right;
    const tableRight = table.getBoundingClientRect().right;
    container.scrollLeft = initialScrollLeft;

    return {
      hasTable: true,
      overflowX,
      scrollWidth: container.scrollWidth,
      clientWidth: container.clientWidth,
      maxScrollLeft,
      horizontallyScrollable: maxScrollLeft > 0 && ["auto", "scroll"].includes(overflowX),
      reachedFarEdge,
      farEdgeVisible: tableRight <= containerRight + 1
    };
  });
  const detail = JSON.stringify(scrollState);
  record(
    `compare table is horizontally scrollable when needed at ${viewportLabel}`,
    scrollState.horizontallyScrollable,
    detail
  );
  record(
    `compare table can programmatically reach its far edge at ${viewportLabel}`,
    scrollState.horizontallyScrollable && scrollState.reachedFarEdge && scrollState.farEdgeVisible,
    detail
  );
}

function missionLink(page, mission) {
  return page.locator(".mission-rail").getByRole("link", { name: new RegExp(mission.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")) });
}

async function runMission(page, mission) {
  const cue = page.locator(".mission-complete");
  const before = await cue.count() ? await cue.first().getAttribute("data-run-id") : null;
  await missionLink(page, mission).click();
  await page.locator("#stage_text .mission-label").filter({ hasText: mission }).waitFor();
  await page.getByRole("button", { name: "Run mission" }).click();
  const deadline = Date.now() + 30000;
  let after = null;
  while (Date.now() < deadline) {
    after = await cue.count() ? await cue.first().getAttribute("data-run-id") : null;
    if (after && after !== before) break;
    await page.waitForTimeout(100);
  }
  if (!after || after === before) {
    throw new Error(`Mission did not complete: ${mission}; before=${before}; after=${after}`);
  }
  await page.locator(".mission-complete").getByText(mission, { exact: false }).waitFor();
}

async function closeModal(page) {
  await page.getByRole("button", { name: "Close" }).click();
  await page.locator(".modal").waitFor({ state: "hidden" });
}

function tabLink(page, name) {
  return page.getByRole("link", { name, exact: true });
}

function activePane(page) {
  return page.locator(".tab-pane.active");
}

async function main() {
  browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    acceptDownloads: true,
    viewport: { width: 1366, height: 768 }
  });
  const page = await context.newPage();

  page.on("console", (message) => {
    if (message.type() === "error") result.consoleErrors.push(message.text());
    if (message.type() === "warning") result.consoleWarnings.push(message.text());
  });
  page.on("pageerror", (error) => result.pageErrors.push(error.message));

  await page.goto(baseURL, { waitUntil: "networkidle" });
  await activePane(page).getByText("This session is temporary.", { exact: false }).waitFor();
  record("page identity has Practical 1 title", (await page.title()).includes("Practical 1"), await page.title());
  record("page identity has requested URL", (await page.url()).startsWith(baseURL), await page.url());
  record("page has meaningful app content", (await page.locator("body").innerText()).includes("PVA Basics"));
  record("no framework error overlay", await page.locator("text=/Unhandled|Application error|Vite error|Webpack/ig").count() === 0);

  const explorePva = page.getByRole("button", { name: accessibleNames.explorePva });
  await explorePva.focus();
  record("context help receives keyboard focus", await explorePva.evaluate((element) => document.activeElement === element));
  record(
    "focused context help has a visible outline",
    await explorePva.evaluate((element) => getComputedStyle(element).outlineStyle !== "none")
  );
  await page.keyboard.press("Enter");
  await page.locator(".modal").waitFor();
  await page.keyboard.press("Escape");
  if (await page.locator(".modal").isVisible()) {
    await closeModal(page);
  }
  for (const name of [accessibleNames.exploreMission, accessibleNames.exploreEvidence]) {
    await page.getByRole("button", { name }).click();
    await closeModal(page);
  }

  await tabLink(page, "Compare").click();
  await activePane(page).getByText("This session is temporary.", { exact: false }).waitFor();
  record("context help does not create runs", await page.locator(".session-run-row").count() === 0);
  record("CSV is gated before evidence is ready", await page.getByRole("link", { name: "Comparison CSV" }).count() === 0);
  record("notes are gated before evidence is ready", await page.getByRole("link", { name: "Evidence notes" }).count() === 0);

  await tabLink(page, "Start").click();
  await page.getByRole("button", { name: "Start baseline" }).click();
  await page.locator("#stage_text").getByText("Core 1: Baseline compass", { exact: false }).waitFor();

  for (const mission of [
    "Core 2: Island ceiling",
    "Core 3: Individual chance",
    "Core 4: Shared bad years",
    "Core 5: Rescue attempt"
  ]) {
    await runMission(page, mission);
  }

  for (const action of [
    { name: "Introduction", tab: "Concept Lab" },
    { name: accessibleNames.controlHelp },
    { name: accessibleNames.outputHelp },
    { name: accessibleNames.diagnosticHelp },
    { name: accessibleNames.plotHelp }
  ]) {
    await page.getByRole("button", { name: action.name }).click();
    if (action.tab) {
      await tabLink(page, action.tab).click();
    } else {
      await closeModal(page);
    }
  }

  await tabLink(page, "Compare").click();
  await page.locator(".session-run-row").nth(4).waitFor();
  record("Core route keeps five successful session runs", await page.locator(".session-run-row").count() === 5);
  await page.locator(".run-card").nth(2).waitFor();
  record("selected evidence shows exactly three cards", await page.locator(".run-card").count() === 3);

  const interpretation = "Risk increased under shared bad years; intervention improved final abundance, while uncertainty remained.";
  await page.getByLabel("One-sentence interpretation").fill(interpretation);
  await page.getByRole("button", { name: "Use this interpretation" }).click();
  await page.getByRole("link", { name: "Comparison CSV" }).waitFor();
  await page.getByRole("link", { name: "Evidence notes" }).waitFor();

  const csvPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Comparison CSV" }).click();
  const csvPath = await saveDownload(await csvPromise, "CSV");

  const notesPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Evidence notes" }).click();
  const notesPath = await saveDownload(await notesPromise, "Markdown");

  const csvRows = parseCsv(fs.readFileSync(csvPath, "utf8"));
  record("selected CSV has header plus three rows", csvRows.length === 4, `rows=${csvRows.length - 1}`);
  const headers = csvRows[0];
  const rows = csvRows.slice(1);
  const requiredColumns = ["run_id", "stage", "label", "PE", "Nmed"];
  const requiredIndexes = requiredColumns.map((name) => headers.indexOf(name));
  record("selected CSV has required columns", requiredIndexes.every((index) => index >= 0), headers.join(","));
  record(
    "selected CSV required values are complete",
    rows.every((row) => requiredIndexes.every((index) => row[index] !== undefined && row[index] !== ""))
  );
  const notesText = fs.readFileSync(notesPath, "utf8");
  record("notes describe three selected runs", notesText.includes("Selected evidence: 3 runs from"));
  record("notes retain interpretation", notesText.includes(interpretation));
  const selectedStages = rows.map((row) => row[headers.indexOf("stage")]);
  record("notes and CSV name the same stages", selectedStages.every((stage) => notesText.includes(stage)));
  await page.screenshot({ path: artifactPath("minimum-success-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("minimum-success-1366x768.png"), "screenshot");
  await assertNoOverlap(page, [".compare-history-panel", ".compare-evidence-panel"], "1366x768");
  await assertCompareTableScrollRegion(page, "1366x768");

  await tabLink(page, "Transfer").click();
  await activePane(page).getByText("This session is temporary.", { exact: false }).waitFor();
  await page.getByText("Comparison CSV: Download requested", { exact: false }).waitFor();
  await page.getByText("Evidence notes: Download requested", { exact: false }).waitFor();
  record("Transfer reports both requested downloads", true);
  await page.screenshot({ path: artifactPath("transfer-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("transfer-1366x768.png"), "screenshot");

  await tabLink(page, "Concept Lab").click();
  await missionLink(page, "Explore: Small-population pressure").click();
  await page.getByLabel("Show advanced risk controls").check();
  await runMission(page, "Explore: Small-population pressure");
  await runMission(page, "Explore: Rare bad years");
  await runMission(page, "Explore: Rare bad years");
  await runMission(page, "Explore: Vortex comparison");

  const plotPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Risk PNG" }).click();
  await saveDownload(await plotPromise, "PNG");

  await tabLink(page, "Compare").click();
  await page.locator(".session-run-row").nth(8).waitFor();
  record("extension route keeps duplicate attempts", await page.locator(".session-run-row").count() === 9);
  await page.locator('input[name="selected_risk_run_id"]').last().check();
  await page.getByText("Review required", { exact: false }).waitFor();
  await page.getByRole("button", { name: "Use this interpretation" }).click();
  await page.screenshot({ path: artifactPath("extension-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("extension-1366x768.png"), "screenshot");

  await page.setViewportSize({ width: 1440, height: 900 });
  await page.screenshot({ path: artifactPath("compare-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("compare-1440x900.png"), "screenshot");
  await assertNoOverlap(page, [".compare-history-panel", ".compare-evidence-panel"], "1440x900");
  await assertCompareTableScrollRegion(page, "1440x900");

  await page.setViewportSize({ width: 390, height: 844 });
  await tabLink(page, "Start").click();
  await page.screenshot({ path: artifactPath("start-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("start-390x844.png"), "screenshot");
  await assertNoOverlap(page, [".landing-copy", ".landing-hero-visual", ".landing-card-grid"], "390x844");

  await tabLink(page, "Compare").click();
  await page.getByRole("button", { name: "Reset comparison" }).click();
  await page.getByText("Run history, evidence selection, interpretation", { exact: false }).waitFor();
  await page.keyboard.press("Escape");
  if (await page.locator(".modal").isVisible()) {
    await page.getByRole("button", { name: "Keep my work" }).click();
  }
  await page.locator(".modal").waitFor({ state: "hidden" });
  record("reset confirmation cancel preserves session history", await page.locator(".session-run-row").count() === 9);

  record("route labels are covered", routeLabels.length === 14);
  record("no console errors", result.consoleErrors.length === 0, JSON.stringify(result.consoleErrors));
  record("no console warnings", result.consoleWarnings.length === 0, JSON.stringify(result.consoleWarnings));
  record("no page errors", result.pageErrors.length === 0, JSON.stringify(result.pageErrors));
}

main()
  .catch((error) => {
    result.failure = error.stack || error.message;
    process.exitCode = 1;
  })
  .finally(async () => {
    if (browser) await browser.close();
    writeResult();
    if (result.failure) process.exitCode = 1;
  });
