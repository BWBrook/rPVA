const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const baseURL = process.env.PRACTICAL1_URL || "http://127.0.0.1:3921";
const evidenceDirectoryPrefix = "rpva-practical1-";

function validateEvidenceDirectory(directory) {
  if (typeof directory !== "string" || directory.trim() === "") {
    throw new Error("PRACTICAL1_EVIDENCE_DIR must be a non-empty path");
  }

  const resolved = path.resolve(directory);
  const root = path.parse(resolved).root;
  const tmpRoot = path.resolve(os.tmpdir());
  const cwd = path.resolve(process.cwd());
  const home = path.resolve(os.homedir());
  const forbidden = new Set([
    root,
    cwd,
    home,
    path.dirname(cwd),
    tmpRoot,
    path.resolve(tmpRoot, "..")
  ]);

  if (forbidden.has(resolved)) {
    throw new Error(`Refusing to remove unsafe evidence directory: ${resolved}`);
  }
  if (path.dirname(resolved) !== tmpRoot || !path.basename(resolved).startsWith(evidenceDirectoryPrefix)) {
    throw new Error(`Evidence directory must be a direct ${evidenceDirectoryPrefix}* child of ${tmpRoot}: ${resolved}`);
  }

  if (fs.existsSync(resolved)) {
    const stat = fs.lstatSync(resolved);
    if (stat.isSymbolicLink()) {
      throw new Error(`Refusing to remove symlink evidence directory: ${resolved}`);
    }
    if (!stat.isDirectory()) {
      throw new Error(`Evidence directory path is not a directory: ${resolved}`);
    }
  }

  return resolved;
}

function prepareEvidenceDirectory(directory) {
  const resolved = validateEvidenceDirectory(directory);
  fs.rmSync(resolved, { recursive: true, force: true });
  fs.mkdirSync(resolved, { recursive: true });
  return resolved;
}

let evidenceDir = null;

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

// These labels are the routes/actions that this acceptance flow must actually visit.
const expectedRouteLabels = [
  "Core 1: Baseline compass",
  "Core 2: Island ceiling",
  "Core 3: Individual chance",
  "Core 4: Shared bad years",
  "Core 5: Rescue attempt",
  "Explore: Small-population pressure",
  "Explore: Rare bad years",
  "Explore: Vortex comparison",
  "Introduction",
  "Explore PVA",
  "Explore mission",
  "Explore evidence",
  "Control help",
  "Read outputs",
  "Read diagnostics",
  "Read plots",
  "Comparison CSV",
  "Evidence notes",
  "Risk PNG"
];

const visitedRouteLabels = new Set();
const allowedRiskStages = new Set([
  "carrying_capacity",
  "demographic_stochasticity",
  "environmental_stochasticity",
  "genetic_stochasticity",
  "catastrophe"
]);
const allowedActionStages = new Set(["intervention", "extinction_vortex"]);

let browser;

function record(name, passed, detail = "") {
  const check = { name, passed: Boolean(passed), detail };
  result.checks.push(check);
  if (!check.passed) {
    throw new Error(`${name}: ${detail}`);
  }
}

function writeResult() {
  if (!evidenceDir) return;
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

function parseMarkdownTable(notesText, heading) {
  const lines = notesText.split(/\r?\n/);
  const headingIndex = lines.indexOf(heading);
  if (headingIndex < 0) {
    throw new Error(`Missing Markdown table heading: ${heading}`);
  }
  const tableLines = [];
  for (let index = headingIndex + 1; index < lines.length; index += 1) {
    if (lines[index] === "" || lines[index].startsWith("## ")) break;
    tableLines.push(lines[index]);
  }
  if (tableLines.length < 2) {
    throw new Error(`Markdown table is empty: ${heading}`);
  }
  return tableLines.map((line) => line.split("\t"));
}

function columnValues(rows, headers, name) {
  const index = headers.indexOf(name);
  if (index < 0) throw new Error(`Missing export column: ${name}`);
  return rows.map((row) => row[index]);
}

function sameSequence(left, right) {
  return left.length === right.length && left.every((value, index) => value === right[index]);
}

function sameSet(left, right) {
  const normalise = (values) => [...new Set(values)].sort();
  return sameSequence(normalise(left), normalise(right));
}

function markVisited(label) {
  visitedRouteLabels.add(label);
}

function assertExportConsistency(csvRows, notesText, options = {}) {
  const csvHeaders = csvRows[0] || [];
  const csvData = csvRows.slice(1);
  const comparisonTable = parseMarkdownTable(notesText, "## Comparison table");
  const settingsTable = parseMarkdownTable(notesText, "## Settings and provenance");
  const comparisonHeaders = comparisonTable[0];
  const comparisonData = comparisonTable.slice(1);
  const settingsHeaders = settingsTable[0];
  const settingsData = settingsTable.slice(1);
  const csvRunIds = columnValues(csvData, csvHeaders, "run_id");
  const markdownRunIds = columnValues(comparisonData, comparisonHeaders, "run_id");
  const csvStages = columnValues(csvData, csvHeaders, "stage");
  const markdownStages = columnValues(comparisonData, comparisonHeaders, "stage");
  const csvLabels = columnValues(csvData, csvHeaders, "label");
  const markdownLabels = columnValues(comparisonData, comparisonHeaders, "label");

  const selectedCount = notesText.match(/^Selected evidence: (\d+) runs from (\d+) successful session runs$/m);
  record(
    "Markdown selected evidence count matches CSV",
    Boolean(selectedCount) && Number(selectedCount[1]) === csvData.length,
    `markdown=${selectedCount ? selectedCount[1] : "missing"}; csv=${csvData.length}`
  );
  if (options.sessionRunCount !== undefined) {
    record(
      "Markdown selected evidence count matches live history",
      Boolean(selectedCount) && Number(selectedCount[2]) === options.sessionRunCount,
      `markdown=${selectedCount ? selectedCount[2] : "missing"}; live=${options.sessionRunCount}`
    );
  }
  record(
    "CSV and Markdown selected run counts match",
    csvData.length === comparisonData.length,
    `csv=${csvData.length}; markdown=${comparisonData.length}`
  );
  record(
    "CSV and Markdown ordered run IDs match",
    sameSequence(csvRunIds, markdownRunIds),
    JSON.stringify({ csv: csvRunIds, markdown: markdownRunIds })
  );
  record(
    "CSV and Markdown selected stages match",
    sameSequence(csvStages, markdownStages),
    JSON.stringify({ csv: csvStages, markdown: markdownStages })
  );
  record(
    "CSV and Markdown selected labels match",
    sameSequence(csvLabels, markdownLabels),
    JSON.stringify({ csv: csvLabels, markdown: markdownLabels })
  );

  if (options.expectedRunIds) {
    record(
      "export selected run IDs match the final rendered selection",
      sameSequence(csvRunIds, options.expectedRunIds.map(String)),
      JSON.stringify({ expected: options.expectedRunIds, csv: csvRunIds })
    );
  }
  if (options.expectedStages) {
    record(
      "export selected stages match the final rendered selection",
      sameSequence(csvStages, options.expectedStages),
      JSON.stringify({ expected: options.expectedStages, csv: csvStages })
    );
  }

  const sharedFields = csvHeaders.filter((field) => comparisonHeaders.includes(field));
  const sharedFieldsMatch =
    sharedFields.length === csvHeaders.length &&
    comparisonHeaders.length === csvHeaders.length &&
    csvData.length === comparisonData.length &&
    sharedFields.every((field) => {
      const csvIndex = csvHeaders.indexOf(field);
      const markdownIndex = comparisonHeaders.indexOf(field);
      return csvData.every((row, rowIndex) => row[csvIndex] === comparisonData[rowIndex][markdownIndex]);
    });
  record(
    "CSV and Markdown shared comparison fields match",
    sharedFieldsMatch,
    JSON.stringify({ csvHeaders, markdownHeaders: comparisonHeaders, sharedFields })
  );

  const settingsRunIds = columnValues(settingsData, settingsHeaders, "run_id");
  record(
    "Markdown settings rows refer to exactly the selected run-ID set",
    sameSet(settingsRunIds, csvRunIds),
    JSON.stringify({ selected: csvRunIds, settings: [...new Set(settingsRunIds)] })
  );
  record(
    "Markdown settings has at least one row per selected run",
    csvRunIds.every((runId) => settingsRunIds.includes(runId)),
    JSON.stringify({ selected: csvRunIds, settings: [...new Set(settingsRunIds)] })
  );

  record(
    "selected evidence has exactly one deterministic baseline",
    csvStages.filter((stage) => stage === "deterministic_baseline").length === 1,
    JSON.stringify(csvStages)
  );
  record(
    "selected evidence has exactly one allowed risk stage",
    csvStages.filter((stage) => allowedRiskStages.has(stage)).length === 1,
    JSON.stringify(csvStages)
  );
  record(
    "selected evidence has exactly one allowed intervention or vortex stage",
    csvStages.filter((stage) => allowedActionStages.has(stage)).length === 1,
    JSON.stringify(csvStages)
  );
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

async function saveDownload(download, kind, filename = download.suggestedFilename()) {
  const filePath = artifactPath(filename);
  await download.saveAs(filePath);
  recordArtifact(filePath, kind);
  return filePath;
}

async function assertNoOverlap(page, selectors, viewportLabel) {
  const missingSelectors = await page.evaluate((items) =>
    items.filter((selector) => !document.querySelector(selector)), selectors
  );
  record(
    `required overlap selectors exist at ${viewportLabel}`,
    missingSelectors.length === 0,
    JSON.stringify(missingSelectors)
  );
  const overlaps = await page.evaluate((items) => {
    const boxes = items.map((selector) => {
      const element = document.querySelector(selector);
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
      box.left < other.right && box.right > other.left &&
      box.top < other.bottom && box.bottom > other.top
    ));
  }, selectors);
  record(`no overlap at ${viewportLabel}`, overlaps.length === 0, JSON.stringify(overlaps));
}

async function assertNoHorizontalOverflow(page, viewportLabel) {
  const overflow = await page.evaluate(() => ({
    viewportWidth: document.documentElement.clientWidth,
    documentWidth: Math.max(document.documentElement.scrollWidth, document.body.scrollWidth),
    bodyWidth: document.body.getBoundingClientRect().width
  }));
  record(
    `no page horizontal overflow at ${viewportLabel}`,
    overflow.documentWidth <= overflow.viewportWidth + 1,
    JSON.stringify(overflow)
  );
}

async function renderedRunNumbers(page) {
  return page.locator(".session-run-row .run-number").evaluateAll((elements) => elements.map((element) => {
    const match = element.textContent.trim().match(/^Run\s+(\d+)$/);
    return match ? Number(match[1]) : NaN;
  }));
}

function assertRenderedRunNumbers(numbers, expectedCount) {
  record(
    "rendered run numbers are positive",
    numbers.length === expectedCount && numbers.every((number) => Number.isInteger(number) && number > 0),
    JSON.stringify(numbers)
  );
  record(
    "rendered run numbers are unique",
    new Set(numbers).size === numbers.length,
    JSON.stringify(numbers)
  );
  record(
    "rendered run numbers are strictly increasing",
    numbers.every((number, index) => index === 0 || number > numbers[index - 1]),
    JSON.stringify(numbers)
  );
  const expected = Array.from({ length: expectedCount }, (_value, index) => index + 1);
  record(
    `rendered run numbers are exactly 1..${expectedCount}`,
    sameSequence(numbers, expected),
    JSON.stringify({ expected, actual: numbers })
  );
}

async function renderedSelectedRunNumbers(page) {
  return page.locator(".run-card .run-card-kicker").evaluateAll((elements) => elements.map((element) => {
    const match = element.textContent.trim().match(/^Run\s+(\d+)$/);
    return match ? Number(match[1]) : NaN;
  }));
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
  markVisited(mission);
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
  const { chromium } = require("@playwright/test");
  evidenceDir = prepareEvidenceDirectory(
    process.env.PRACTICAL1_EVIDENCE_DIR === undefined
      ? path.join(os.tmpdir(), "rpva-practical1-final-polish")
      : process.env.PRACTICAL1_EVIDENCE_DIR
  );
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
  markVisited("Explore PVA");
  await page.keyboard.press("Escape");
  if (await page.locator(".modal").isVisible()) {
    await closeModal(page);
  }
  for (const action of [
    { name: accessibleNames.exploreMission, label: "Explore mission" },
    { name: accessibleNames.exploreEvidence, label: "Explore evidence" }
  ]) {
    await page.getByRole("button", { name: action.name }).click();
    markVisited(action.label);
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
  markVisited("Core 1: Baseline compass");

  for (const mission of [
    "Core 2: Island ceiling",
    "Core 3: Individual chance",
    "Core 4: Shared bad years",
    "Core 5: Rescue attempt"
  ]) {
    await runMission(page, mission);
  }

  for (const action of [
    { name: "Introduction", label: "Introduction", tab: "Concept Lab" },
    { name: accessibleNames.controlHelp, label: "Control help" },
    { name: accessibleNames.outputHelp, label: "Read outputs" },
    { name: accessibleNames.diagnosticHelp, label: "Read diagnostics" },
    { name: accessibleNames.plotHelp, label: "Read plots" }
  ]) {
    await page.getByRole("button", { name: action.name }).click();
    markVisited(action.label);
    if (action.tab) {
      await tabLink(page, action.tab).click();
    } else {
      await closeModal(page);
    }
  }

  await page.locator(".mission-rail").waitFor();
  await page.getByRole("button", { name: "Run mission" }).waitFor();
  record("Concept Lab mission rail is usable at 1366x768", await page.locator(".mission-rail").isVisible());
  record("Concept Lab Run mission is usable at 1366x768", await page.getByRole("button", { name: "Run mission" }).isEnabled());
  await page.screenshot({ path: artifactPath("concept-lab-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("concept-lab-1366x768.png"), "screenshot");
  await assertNoOverlap(page, [
    ".lab-grid > .panel-block:first-child",
    ".lab-grid > .output-region",
    ".plot-region"
  ], "Concept Lab 1366x768");
  await assertNoHorizontalOverflow(page, "Concept Lab 1366x768");

  await page.setViewportSize({ width: 1440, height: 900 });
  await page.screenshot({ path: artifactPath("concept-lab-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("concept-lab-1440x900.png"), "screenshot");
  await assertNoOverlap(page, [
    ".lab-grid > .panel-block:first-child",
    ".lab-grid > .output-region",
    ".plot-region"
  ], "Concept Lab 1440x900");
  await assertNoHorizontalOverflow(page, "Concept Lab 1440x900");
  await page.setViewportSize({ width: 1366, height: 768 });

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
  const csvPath = await saveDownload(await csvPromise, "initial CSV", "initial-comparison.csv");

  const notesPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Evidence notes" }).click();
  const notesPath = await saveDownload(await notesPromise, "initial Markdown", "initial-evidence-notes.md");

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
  assertExportConsistency(csvRows, notesText, { sessionRunCount: 5 });
  markVisited("Comparison CSV");
  markVisited("Evidence notes");
  await page.screenshot({ path: artifactPath("minimum-success-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("minimum-success-1366x768.png"), "screenshot");
  await assertNoOverlap(page, [".compare-history-panel", ".compare-evidence-panel"], "1366x768");
  await assertCompareTableScrollRegion(page, "1366x768");
  await assertNoHorizontalOverflow(page, "Compare 1366x768");

  await tabLink(page, "Transfer").click();
  await activePane(page).getByText("This session is temporary.", { exact: false }).waitFor();
  await page.getByText("Comparison CSV: Download requested", { exact: false }).waitFor();
  await page.getByText("Evidence notes: Download requested", { exact: false }).waitFor();
  record("Transfer reports both requested downloads", true);
  await page.screenshot({ path: artifactPath("transfer-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("transfer-1366x768.png"), "screenshot");

  await page.setViewportSize({ width: 390, height: 844 });
  await tabLink(page, "Concept Lab").click();
  await missionLink(page, "Core 5: Rescue attempt").click();
  await page.locator("#stage_text .mission-label").filter({ hasText: "Core 5: Rescue attempt" }).waitFor();
  await page.locator("#K").evaluate((element) => {
    element.value = "70";
    element.dispatchEvent(new Event("input", { bubbles: true }));
    element.dispatchEvent(new Event("change", { bubbles: true }));
  });
  await page.waitForTimeout(500);
  record("Concept Lab mission rail is usable at 390x844", await page.locator(".mission-rail").isVisible());
  record("Concept Lab Run mission is visible and enabled at 390x844", await page.getByRole("button", { name: "Run mission" }).isVisible() && await page.getByRole("button", { name: "Run mission" }).isEnabled());
  await page.screenshot({ path: artifactPath("concept-lab-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("concept-lab-390x844.png"), "screenshot");
  await assertNoOverlap(page, [
    ".lab-grid > .panel-block:first-child",
    ".lab-grid > .output-region",
    ".plot-region"
  ], "Concept Lab 390x844");
  await assertNoHorizontalOverflow(page, "Concept Lab 390x844");

  await tabLink(page, "Compare").click();
  await page.getByRole("link", { name: "Comparison CSV" }).waitFor();
  await page.getByRole("link", { name: "Evidence notes" }).waitFor();
  record("Compare controls and downloads are visible at 390x844", await page.getByLabel("One-sentence interpretation").isVisible() && await page.getByRole("link", { name: "Comparison CSV" }).isVisible() && await page.getByRole("link", { name: "Evidence notes" }).isVisible());
  await page.screenshot({ path: artifactPath("compare-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("compare-390x844.png"), "screenshot");
  await assertNoOverlap(page, [".compare-history-panel", ".compare-evidence-panel"], "Compare 390x844");
  await assertNoHorizontalOverflow(page, "Compare 390x844");

  await page.setViewportSize({ width: 1366, height: 768 });
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
  markVisited("Risk PNG");

  await tabLink(page, "Compare").click();
  await page.locator(".session-run-row").nth(8).waitFor();
  record("extension route keeps duplicate attempts", await page.locator(".session-run-row").count() === 9);
  const finalRenderedRunNumbers = await renderedRunNumbers(page);
  assertRenderedRunNumbers(finalRenderedRunNumbers, 9);
  await page.locator('input[name="selected_risk_run_id"]').last().check();
  await page.locator('input[name="selected_action_run_id"]').last().check();
  await page.getByText("Review required", { exact: false }).waitFor();
  await tabLink(page, "Transfer").click();
  await activePane(page).getByText("This session is temporary.", { exact: false }).waitFor();
  await page.getByText("Comparison CSV: Not requested yet", { exact: false }).waitFor();
  await page.getByText("Evidence notes: Not requested yet", { exact: false }).waitFor();
  record("extension selection invalidates the old CSV request", true);
  record("extension selection invalidates the old notes request", true);
  record("Transfer remains incomplete until final downloads", await page.getByText("Both evidence requests are complete", { exact: false }).count() === 0);

  await tabLink(page, "Compare").click();
  const extensionInterpretation = "Extension runs showed that rare bad years and the extinction vortex changed risk and action evidence; uncertainty remains.";
  await page.getByLabel("One-sentence interpretation").fill(extensionInterpretation);
  await page.getByRole("button", { name: "Use this interpretation" }).click();
  await page.locator(".review-required").waitFor({ state: "hidden" });
  await page.getByRole("link", { name: "Comparison CSV" }).waitFor();
  await page.getByRole("link", { name: "Evidence notes" }).waitFor();
  const finalSelectedRunNumbers = await renderedSelectedRunNumbers(page);
  record(
    "final selected evidence is rendered as runs 1, 8, and 9",
    sameSequence(finalSelectedRunNumbers, [1, 8, 9]),
    JSON.stringify(finalSelectedRunNumbers)
  );
  await page.screenshot({ path: artifactPath("extension-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("extension-1366x768.png"), "screenshot");

  await page.setViewportSize({ width: 1440, height: 900 });
  await page.screenshot({ path: artifactPath("compare-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("compare-1440x900.png"), "screenshot");
  await assertNoOverlap(page, [".compare-history-panel", ".compare-evidence-panel"], "1440x900");
  await assertCompareTableScrollRegion(page, "1440x900");
  await assertNoHorizontalOverflow(page, "Compare 1440x900");

  const finalCsvPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Comparison CSV" }).click();
  const finalCsvPath = await saveDownload(await finalCsvPromise, "final CSV", "final-comparison.csv");
  await tabLink(page, "Transfer").click();
  await activePane(page).getByText("Comparison CSV: Download requested", { exact: false }).waitFor();
  record("Transfer remains incomplete after only the fresh final CSV", await page.getByText("Evidence notes: Not requested yet", { exact: false }).count() > 0 && await page.getByText("Both evidence requests are complete", { exact: false }).count() === 0);

  await tabLink(page, "Compare").click();
  const finalNotesPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Evidence notes" }).click();
  const finalNotesPath = await saveDownload(await finalNotesPromise, "final Markdown", "final-evidence-notes.md");
  const finalCsvRows = parseCsv(fs.readFileSync(finalCsvPath, "utf8"));
  const finalNotesText = fs.readFileSync(finalNotesPath, "utf8");
  const finalExpectedStages = ["deterministic_baseline", "catastrophe", "extinction_vortex"];
  const finalEvidenceSummary = "Selected evidence: 3 runs from 9 successful session runs";
  record(
    "final notes assert the exact live-history summary",
    finalRenderedRunNumbers.length === 9 && finalNotesText.includes(finalEvidenceSummary),
    finalEvidenceSummary
  );
  record("final notes retain extension-specific interpretation", finalNotesText.includes(extensionInterpretation));
  assertExportConsistency(finalCsvRows, finalNotesText, {
    expectedRunIds: [1, 8, 9],
    expectedStages: finalExpectedStages,
    sessionRunCount: 9
  });
  markVisited("Comparison CSV");
  markVisited("Evidence notes");

  await tabLink(page, "Transfer").click();
  await activePane(page).getByText("Comparison CSV: Download requested", { exact: false }).waitFor();
  await activePane(page).getByText("Evidence notes: Download requested", { exact: false }).waitFor();
  record("Transfer completes only after both fresh final downloads", await page.getByText("Both evidence requests are complete", { exact: false }).count() > 0);

  await page.setViewportSize({ width: 390, height: 844 });
  await tabLink(page, "Start").click();
  await page.screenshot({ path: artifactPath("start-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("start-390x844.png"), "screenshot");
  await assertNoOverlap(page, [".landing-copy", ".landing-hero-visual", ".landing-card-grid"], "390x844");
  await assertNoHorizontalOverflow(page, "Start 390x844");

  await tabLink(page, "Compare").click();
  await page.getByRole("button", { name: "Reset comparison" }).click();
  await page.getByText("Run history, evidence selection, interpretation", { exact: false }).waitFor();
  await page.keyboard.press("Escape");
  if (await page.locator(".modal").isVisible()) {
    await page.getByRole("button", { name: "Keep my work" }).click();
  }
  await page.locator(".modal").waitFor({ state: "hidden" });
  record("reset confirmation cancel preserves session history", await page.locator(".session-run-row").count() === 9);

  const missingRouteLabels = expectedRouteLabels.filter((label) => !visitedRouteLabels.has(label));
  const unexpectedRouteLabels = [...visitedRouteLabels].filter((label) => !expectedRouteLabels.includes(label));
  record(
    "visited contextual and mission labels match expected set",
    missingRouteLabels.length === 0 && unexpectedRouteLabels.length === 0,
    JSON.stringify({ expected: expectedRouteLabels, visited: [...visitedRouteLabels], missing: missingRouteLabels, unexpected: unexpectedRouteLabels })
  );
  record("no console errors", result.consoleErrors.length === 0, JSON.stringify(result.consoleErrors));
  record("no console warnings", result.consoleWarnings.length === 0, JSON.stringify(result.consoleWarnings));
  record("no page errors", result.pageErrors.length === 0, JSON.stringify(result.pageErrors));
}

if (require.main === module) {
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
}

module.exports = {
  validateEvidenceDirectory,
  prepareEvidenceDirectory
};
