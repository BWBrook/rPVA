const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const baseURL = process.env.PRACTICAL1_URL || "http://127.0.0.1:3921";
const evidenceDirectoryPrefix = "rpva-practical1-";

function validateEvidenceDirectory(directory) {
  if (typeof directory !== "string" || directory.trim() === "") {
    throw new Error("PRACTICAL1_EVIDENCE_DIR must be a non-empty path");
  }
  if (!path.isAbsolute(directory)) {
    throw new Error(`Evidence directory must be an absolute path: ${directory}`);
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

  let stat = null;
  try {
    stat = fs.lstatSync(resolved);
  } catch (error) {
    if (error.code !== "ENOENT") throw error;
  }
  if (stat) {
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
  coreExploreHelp: "Open Core and Explore mission help",
  controlHelp: "Open Practical 1 parameter help",
  outputHelp: "Open Practical 1 output help",
  diagnosticHelp: "Open Practical 1 diagnostic help",
  plotHelp: "Open Practical 1 plot help",
  selectionHelp: "Open Practical 1 evidence selection help",
  outcomesHelp: "Open Practical 1 comparison outcome help",
  notebookHelp: "Open Practical 1 evidence notebook help",
  transferHelp: "Open Practical 1 evidence pack help"
};

// These labels are the routes/actions that this acceptance flow must actually visit.
const expectedRouteLabels = [
  "Core 1: Baseline compass",
  "Core 2: Island ceiling",
  "Core 3: Individual chance",
  "Core 4: Environmental variability",
  "Core 5: Rescue attempt",
  "Explore: Small-population pressure",
  "Explore: Rare bad years",
  "Explore: Vortex comparison",
  "Core and Explore",
  "Explore PVA",
  "Explore mission",
  "Explore evidence",
  "Control help",
  "Read outputs",
  "Read diagnostics",
  "Read plots",
  "Selection help",
  "Read outcomes",
  "Notebook help",
  "Evidence pack help",
  "Comparison CSV",
  "Evidence notebook",
  "Extinction risk PNG",
  "Quasi-extinction PNG"
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

const requiredComparisonFields = [
  "run_id",
  "stage",
  "label",
  "scenario",
  "years",
  "reps",
  "PE",
  "Nmed",
  "Nlo95",
  "Nhi95",
  "extinct_reps",
  "surviving_reps",
  "trajectory_available",
  "delta_PE",
  "delta_Nmed",
  "uncertainty_change"
];

const renderedStageByLabel = new Map([
  ["Deterministic baseline", "deterministic_baseline"],
  ["Ceiling carrying capacity", "carrying_capacity"],
  ["Demographic stochasticity", "demographic_stochasticity"],
  ["Environmental stochasticity", "environmental_stochasticity"],
  ["Genetic stochasticity", "genetic_stochasticity"],
  ["Catastrophe", "catastrophe"],
  ["Simple intervention", "intervention"],
  ["Extinction vortex comparison", "extinction_vortex"]
]);

const canonicalSpecTemplates = {
  deterministic_baseline: {
    years: "25", reps: "1", K: "NA", K_sd: "0",
    demographic_stochasticity: "FALSE", env_sd: "0", genetics: "FALSE", n0: "31,12,7"
  },
  carrying_capacity: {
    years: "25", reps: "1", K: "30", K_sd: "0",
    demographic_stochasticity: "FALSE", env_sd: "0", genetics: "FALSE", n0: "31,12,7"
  },
  demographic_stochasticity: {
    years: "25", reps: "100", K: "30", K_sd: "0",
    demographic_stochasticity: "TRUE", env_sd: "0", genetics: "FALSE", n0: "31,12,7"
  },
  environmental_stochasticity: {
    years: "50", reps: "100", K: "15", K_sd: "5",
    demographic_stochasticity: "TRUE", env_sd: "0.35", genetics: "FALSE", n0: "31,12,7"
  },
  genetic_stochasticity: {
    years: "25", reps: "100", K: "30", K_sd: "5",
    demographic_stochasticity: "TRUE", env_sd: "0.3", genetics: "TRUE",
    F_init: "0.1", n0: "31,12,7"
  },
  catastrophe: {
    years: "25", reps: "100", K: "30", K_sd: "5",
    demographic_stochasticity: "TRUE", env_sd: "0.2", genetics: "FALSE",
    cat_freq: "0.05", cat_surv: "0.6", cat_repro: "0.7", n0: "31,12,7"
  },
  intervention: {
    years: "25", reps: "100", K: "60", K_sd: "5",
    demographic_stochasticity: "TRUE", env_sd: "0.2", genetics: "FALSE", n0: "31,12,7"
  },
  extinction_vortex: {
    years: "25", reps: "100", K: "20", K_sd: "5",
    demographic_stochasticity: "TRUE", env_sd: "0.3", genetics: "TRUE",
    cat_freq: "0.05", cat_surv: "0.7", cat_repro: "0.8", F_init: "0.1", n0: "12,5,3"
  }
};

function isCompleteExportValue(value) {
  return value !== undefined && value !== null && String(value).trim() !== "";
}

function sharedComparisonFieldsMatch(csvHeaders, csvData, markdownHeaders, markdownData) {
  const sharedFields = csvHeaders.filter((field) => markdownHeaders.includes(field));
  return requiredComparisonFields.every((field) => csvHeaders.includes(field) && markdownHeaders.includes(field)) &&
    sharedFields.length === csvHeaders.length &&
    markdownHeaders.length === csvHeaders.length &&
    csvData.length === markdownData.length &&
    sharedFields.every((field) => {
      const csvIndex = csvHeaders.indexOf(field);
      const markdownIndex = markdownHeaders.indexOf(field);
      return csvData.every((row, rowIndex) => (
        isCompleteExportValue(row[csvIndex]) &&
        isCompleteExportValue(markdownData[rowIndex]?.[markdownIndex]) &&
        row[csvIndex] === markdownData[rowIndex][markdownIndex]
      ));
    });
}

function exactRenderedStagesMatch(exportStages, renderedEvidence) {
  const expectedStages = renderedEvidence.map((evidence) => (
    renderedStageByLabel.get(evidence.historyLabel || evidence.label) || ""
  ));
  return expectedStages.every((stage) => stage !== "") && sameSequence(exportStages, expectedStages);
}

function renderedSettingControls(settingsLabel) {
  if (settingsLabel === "Reference settings") return [];
  if (!isCompleteExportValue(settingsLabel)) return null;
  return settingsLabel.split("; ").map((fragment) => {
    const separator = fragment.indexOf(" = ");
    if (separator < 1) return null;
    const setting = fragment.slice(0, separator);
    const value = fragment.slice(separator + 3);
    if (!isCompleteExportValue(setting) || !isCompleteExportValue(value)) return null;
    return { setting: `control_${setting}`, value };
  });
}

function canonicalExpectedSettings(renderedEvidence, specRowsByRun) {
  return renderedEvidence.flatMap((evidence) => {
    const stage = renderedStageByLabel.get(evidence.historyLabel || evidence.label);
    const controls = renderedSettingControls(evidence.settings);
    const specRows = specRowsByRun[String(evidence.runId)] || [];
    if (!stage || !controls || !specRows.length) return [];
    const metadata = { run_id: String(evidence.runId), stage, label: evidence.label };
    const controlRows = controls.map((row) => ({ ...metadata, ...row }));
    const canonicalSpecRows = specRows.map((row) => ({
      ...metadata,
      setting: row.setting,
      value: row.value
    }));
    return [...controlRows, ...canonicalSpecRows];
  });
}

function settingsRowsExactlyMatch(actualRows, expectedRows) {
  const fields = ["run_id", "stage", "label", "setting", "value"];
  const rowKey = (row) => fields.map((field) => row[field]).join("\u0000");
  const complete = (rows) => rows.every((row) => fields.every((field) => isCompleteExportValue(row[field])));
  const unique = (rows) => new Set(rows.map(rowKey)).size === rows.length;
  return complete(actualRows) && complete(expectedRows) &&
    unique(actualRows) && unique(expectedRows) &&
    actualRows.length === expectedRows.length &&
    actualRows.every((row, index) => fields.every((field) => row[field] === expectedRows[index][field]));
}

function canonicalSpecRowsForEvidence(renderedEvidence) {
  return Object.fromEntries(renderedEvidence.map((evidence) => {
    const label = evidence.historyLabel || evidence.label;
    const stage = renderedStageByLabel.get(label);
    const template = canonicalSpecTemplates[stage] || {};
    const controls = renderedSettingControls(evidence.settings) || [];
    const values = { ...template };
    const extraSpecValues = {};
    controls.forEach(({ setting, value }) => {
      const control = setting.replace(/^control_/, "");
      const field = control === "advanced_years" ? "years" :
        control === "advanced_reps" ? "reps" : control;
      if (Object.prototype.hasOwnProperty.call(values, field)) values[field] = value;
      if (control === "mortality_pct" || control === "fecundity_pct") extraSpecValues[field] = value;
    });
    const specRows = [
      ...(extraSpecValues.mortality_pct === undefined ? [] : [{ setting: "spec_mortality_pct", value: extraSpecValues.mortality_pct }]),
      ...(extraSpecValues.fecundity_pct === undefined ? [] : [{ setting: "spec_fecundity_pct", value: extraSpecValues.fecundity_pct }]),
      { setting: "spec_name", value: `teaching_${stage}` },
      { setting: "spec_years", value: values.years },
      { setting: "spec_reps", value: values.reps },
      ...Object.entries(values)
        .filter(([field]) => !["years", "reps"].includes(field))
        .map(([field, value]) => ({ setting: `spec_${field}`, value }))
    ];
    return [String(evidence.runId), specRows];
  }));
}

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
  const comparisonTable = parseMarkdownTable(notesText, "## Final selected comparison");
  const settingsTable = parseMarkdownTable(notesText, "## Settings and provenance appendix");
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
  const renderedEvidence = options.renderedEvidence || [];
  const renderedRunIds = renderedEvidence.map((evidence) => String(evidence.runId));
  const renderedLabels = renderedEvidence.map((evidence) => evidence.label);
  const renderedStages = renderedEvidence.map((evidence) => evidence.visibleStage);
  const stageMatchesVisibleCategory = (stage, category) => (
    (category === "Baseline" && stage === "deterministic_baseline") ||
    (category === "Risk mechanism" && allowedRiskStages.has(stage)) ||
    (category === "Intervention or vortex" && allowedActionStages.has(stage))
  );

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
  record(
    "rendered selected evidence exposes complete IDs, stages, labels, and settings",
    renderedEvidence.length === csvData.length && renderedEvidence.every((evidence) => (
      Number.isInteger(evidence.runId) &&
      evidence.visibleStage !== "" &&
      evidence.label !== "" &&
      evidence.settings !== "" &&
      renderedStageByLabel.has(evidence.historyLabel || evidence.label) &&
      evidence.historyLabel === evidence.label &&
      evidence.historySettings === evidence.settings
    )),
    JSON.stringify(renderedEvidence)
  );
  record(
    "CSV run IDs match rendered selected evidence",
    sameSequence(csvRunIds, renderedRunIds),
    JSON.stringify({ csv: csvRunIds, rendered: renderedRunIds })
  );
  record(
    "Markdown run IDs match rendered selected evidence",
    sameSequence(markdownRunIds, renderedRunIds),
    JSON.stringify({ markdown: markdownRunIds, rendered: renderedRunIds })
  );
  record(
    "CSV labels match rendered selected evidence",
    sameSequence(csvLabels, renderedLabels),
    JSON.stringify({ csv: csvLabels, rendered: renderedLabels })
  );
  record(
    "Markdown labels match rendered selected evidence",
    sameSequence(markdownLabels, renderedLabels),
    JSON.stringify({ markdown: markdownLabels, rendered: renderedLabels })
  );
  record(
    "CSV stages match rendered visible stage categories",
    exactRenderedStagesMatch(csvStages, renderedEvidence) &&
      csvStages.every((stage, index) => stageMatchesVisibleCategory(stage, renderedStages[index])),
    JSON.stringify({ csv: csvStages, rendered: renderedStages })
  );
  record(
    "Markdown stages match rendered visible stage categories",
    exactRenderedStagesMatch(markdownStages, renderedEvidence) &&
      markdownStages.every((stage, index) => stageMatchesVisibleCategory(stage, renderedStages[index])),
    JSON.stringify({ markdown: markdownStages, rendered: renderedStages })
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
  const sharedFieldsMatch = sharedComparisonFieldsMatch(
    csvHeaders,
    csvData,
    comparisonHeaders,
    comparisonData
  );
  record(
    "CSV and Markdown shared comparison fields match",
    sharedFieldsMatch,
    JSON.stringify({ csvHeaders, markdownHeaders: comparisonHeaders, sharedFields })
  );

  const settingsRunIds = columnValues(settingsData, settingsHeaders, "run_id");
  const settingsRecords = settingsData.map((row) => ({
    run_id: row[settingsHeaders.indexOf("run_id")],
    stage: row[settingsHeaders.indexOf("stage")],
    label: row[settingsHeaders.indexOf("label")],
    setting: row[settingsHeaders.indexOf("setting")],
    value: row[settingsHeaders.indexOf("value")]
  }));
  const settingsByRun = new Map();
  settingsRecords.forEach((row) => {
    if (!settingsByRun.has(row.run_id)) settingsByRun.set(row.run_id, []);
    settingsByRun.get(row.run_id).push(row);
  });
  record(
    "Markdown settings rows include every final selected run ID",
    csvRunIds.every((runId) => settingsRunIds.includes(runId)),
    JSON.stringify({ selected: csvRunIds, settings: [...new Set(settingsRunIds)] })
  );
  record(
    "Markdown settings has at least one row per selected run",
    csvRunIds.every((runId) => settingsRunIds.includes(runId)),
    JSON.stringify({ selected: csvRunIds, settings: [...new Set(settingsRunIds)] })
  );
  const renderedSettingsMatch = settingsRecords.every((row) => (
    ["run_id", "stage", "label", "setting", "value"].every((field) => isCompleteExportValue(row[field])) &&
    Number.isInteger(Number(row.run_id)) && Number(row.run_id) > 0
  )) && renderedEvidence.every((evidence) => {
    const stage = renderedStageByLabel.get(evidence.historyLabel || evidence.label);
    const records = settingsByRun.get(String(evidence.runId)) || [];
    return records.length > 0 && records.every((row) => (
      row.stage === stage && row.label === evidence.label
    ));
  });
  record(
    "Markdown settings and provenance substantively match rendered cards",
    renderedSettingsMatch,
    JSON.stringify({ rendered: renderedEvidence, settings: settingsRecords, settingsByRun: [...settingsByRun] })
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

async function assertConceptLabLayout(page, viewportLabel) {
  const layout = await page.evaluate(() => {
    const panelSelectors = [
      ".lab-grid > .panel-block:first-child",
      ".lab-grid > .output-region",
      ".plot-region"
    ];
    const lineEvidence = (element) => {
      const textNode = [...element.childNodes].find(
        (node) => node.nodeType === Node.TEXT_NODE && node.textContent.trim() !== ""
      );
      if (!textNode) return { lineCount: 0, maxCharactersOnLine: 0 };

      const lines = new Map();
      let offset = 0;
      for (const character of [...textNode.textContent]) {
        const end = offset + character.length;
        if (/\S/.test(character)) {
          const range = document.createRange();
          range.setStart(textNode, offset);
          range.setEnd(textNode, end);
          const rect = range.getBoundingClientRect();
          if (rect.width > 0 && rect.height > 0) {
            const y = Math.round(rect.y);
            lines.set(y, (lines.get(y) || 0) + 1);
          }
        }
        offset = end;
      }
      const counts = [...lines.values()];
      return {
        lineCount: counts.length,
        maxCharactersOnLine: counts.length ? Math.max(...counts) : 0
      };
    };

    const labels = [...document.querySelectorAll(".mission-step-label")].map((element) => {
      const rect = element.getBoundingClientRect();
      const status = element.closest(".mission-step").querySelector(".mission-step-status");
      const statusRect = status.getBoundingClientRect();
      return {
        text: element.textContent.trim(),
        width: rect.width,
        height: rect.height,
        right: rect.right,
        statusLeft: statusRect.left,
        statusWidth: statusRect.width,
        lineEvidence: lineEvidence(element)
      };
    });
    const panels = panelSelectors.map((selector) => {
      const rect = document.querySelector(selector).getBoundingClientRect();
      return { selector, width: rect.width, height: rect.height };
    });
    return { labels, panels };
  });
  const minimumLabelWidth = 150;
  record(
    `Concept Lab panel geometry is non-zero at ${viewportLabel}`,
    layout.panels.every((panel) => panel.width > 0 && panel.height > 0),
    JSON.stringify(layout.panels)
  );
  record(
    `mission labels have usable rendered width at ${viewportLabel}`,
    layout.labels.length > 0 && layout.labels.every((label) => label.width >= minimumLabelWidth),
    JSON.stringify({ minimumLabelWidth, labels: layout.labels })
  );
  record(
    `mission labels preserve ordinary words at ${viewportLabel}`,
    layout.labels.length > 0 && layout.labels.every((label) => label.lineEvidence.maxCharactersOnLine >= 4),
    JSON.stringify(layout.labels)
  );
  record(
    `mission statuses have usable rendered geometry at ${viewportLabel}`,
    layout.labels.length > 0 && layout.labels.every((label) => label.statusWidth > 0 && label.right <= label.statusLeft + 1),
    JSON.stringify(layout.labels)
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
  return (await renderedSelectedEvidence(page)).map((evidence) => evidence.runId);
}

async function renderedSelectedEvidence(page) {
  return page.locator(".evidence-matrix-desktop thead th").evaluateAll((headers) => headers.slice(1).map((header) => {
    const kicker = header.querySelector("strong")?.textContent.trim() || "";
    const idMatch = kicker.match(/^Run\s+(\d+)$/);
    const runId = idMatch ? Number(idMatch[1]) : NaN;
    const historyRow = [...document.querySelectorAll(".session-run-row")].find((row) => {
      const runMatch = row.querySelector(".run-number")?.textContent.trim().match(/^Run\s+(\d+)$/);
      return runMatch && Number(runMatch[1]) === runId;
    });
    const role = header.querySelector(".evidence-matrix-role")?.textContent.trim() || "";
    const spans = [...header.querySelectorAll("span")];
    return {
      runId,
      label: spans.at(-1)?.textContent.trim() || "",
      settings: historyRow?.querySelector(".run-settings")?.textContent.trim() || "",
      visibleStage: role,
      historyLabel: historyRow?.querySelector("strong")?.textContent.trim() || "",
      historySettings: historyRow?.querySelector(".run-settings")?.textContent.trim() || ""
    };
  }));
}

async function assertEvidenceMatrixFits(page, viewportLabel) {
  const matrixState = await page.evaluate(() => {
    const candidates = [
      document.querySelector(".evidence-matrix-desktop"),
      document.querySelector(".evidence-matrix-mobile")
    ].filter(Boolean);
    const visible = candidates.filter((element) => {
      const style = getComputedStyle(element);
      const rect = element.getBoundingClientRect();
      return style.display !== "none" && rect.width > 0 && rect.height > 0;
    });
    return {
      visibleCount: visible.length,
      matrices: visible.map((element) => ({
        className: element.className,
        clientWidth: element.clientWidth,
        scrollWidth: element.scrollWidth
      }))
    };
  });
  record(
    `evidence matrix does not require horizontal scrolling at ${viewportLabel}`,
    matrixState.visibleCount === 1 && matrixState.matrices.every((matrix) => (
      matrix.scrollWidth <= matrix.clientWidth + 1
    )),
    JSON.stringify(matrixState)
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

async function chooseEvidenceRun(page, inputId, runId) {
  const input = page.locator(`#${inputId}`);
  await input.waitFor({ state: "attached" });
  await input.evaluate((element, value) => {
    if (element.selectize) {
      element.selectize.setValue(String(value));
      return;
    }
    element.value = String(value);
    element.dispatchEvent(new Event("input", { bubbles: true }));
    element.dispatchEvent(new Event("change", { bubbles: true }));
  }, runId);
  await page.waitForFunction(
    ({ id, value }) => document.querySelector(`#${id}`)?.value === String(value),
    { id: inputId, value: runId }
  );
  await page.waitForTimeout(250);
}

async function addNotebookObservation(page, note, observationId) {
  await page.locator("#observation_draft").fill(note);
  await page.getByRole("button", { name: "Add to notebook" }).click();
  await page.locator(".observation-entry").filter({ hasText: `Observation ${observationId}` }).waitFor();
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
  await activePane(page).getByText("This browser session is temporary.", { exact: false }).waitFor();
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
  const pvaDialog = page.getByRole("dialog", { name: "What is PVA?" });
  await pvaDialog.waitFor();
  record("Start tab exposes the active page to assistive technology", await tabLink(page, "Start").getAttribute("aria-current") === "page");
  record("context help exposes dialog semantics", await pvaDialog.getAttribute("aria-modal") === "true");
  markVisited("Explore PVA");
  await page.keyboard.press("Escape");
  try {
    await page.locator("#shiny-modal").waitFor({ state: "detached", timeout: 3000 });
  } catch (error) {
    await closeModal(page);
    await page.locator("#shiny-modal").waitFor({ state: "detached" });
  }
  await page.waitForFunction(() => document.activeElement?.id === "open_pva_deep_dive");
  record("closing context help returns focus to its trigger", await explorePva.evaluate((element) => document.activeElement === element));
  for (const action of [
    { name: accessibleNames.exploreMission, label: "Explore mission" },
    { name: accessibleNames.exploreEvidence, label: "Explore evidence" }
  ]) {
    await page.getByRole("button", { name: action.name }).click();
    markVisited(action.label);
    await closeModal(page);
  }

  await tabLink(page, "Compare").click();
  await activePane(page).getByText("This browser session is temporary.", { exact: false }).waitFor();
  record("context help does not create runs", await page.locator(".session-run-row").count() === 0);
  record("CSV is gated before evidence is ready", await page.getByRole("link", { name: "Comparison CSV" }).count() === 0);
  record("notebook is gated before evidence is ready", await page.getByRole("link", { name: "Evidence notebook" }).count() === 0);

  await tabLink(page, "Start").click();
  await page.getByRole("button", { name: "Create baseline run" }).click();
  await page.locator("#stage_text").getByText("Core 1: Baseline compass", { exact: false }).waitFor();
  markVisited("Core 1: Baseline compass");
  const rerunBaselineAction = page.getByRole("button", { name: "Rerun baseline" });
  await rerunBaselineAction.waitFor();
  await page.waitForFunction(() => {
    const action = document.querySelector("#run_stage");
    return action && !action.disabled;
  });
  record(
    "baseline rerun action is visible and enabled",
    await rerunBaselineAction.isVisible() && await rerunBaselineAction.isEnabled()
  );
  await rerunBaselineAction.click();
  const unchangedBaselineMessage = page.getByText(
    "A deterministic run repeats the same population trajectory",
    { exact: false }
  );
  await unchangedBaselineMessage.waitFor();
  record("unchanged baseline rerun explains deterministic behaviour", await unchangedBaselineMessage.isVisible());
  record(
    "unchanged baseline rerun remains in the Concept Lab",
    await tabLink(page, "Concept Lab").evaluate((element) => element.parentElement?.classList.contains("active"))
  );
  await page.screenshot({ path: artifactPath("concept-lab-baseline-unchanged-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("concept-lab-baseline-unchanged-1366x768.png"), "screenshot");

  await missionLink(page, "Core 3: Individual chance").click();
  await page.locator("#reps").waitFor({ state: "attached" });
  const coreThreeFutures = await page.locator("#reps").evaluate((element) => (
    element.selectize ? Object.keys(element.selectize.options) : [...element.options].map((option) => option.value)
  ));
  record(
    "Core 3 exposes the full simulation-futures presets",
    sameSequence(coreThreeFutures, ["10", "100", "500", "1000"]),
    JSON.stringify(coreThreeFutures)
  );

  await missionLink(page, "Core 4: Environmental variability").click();
  await page.locator("#env_sd").waitFor({ state: "attached" });
  const environmentalControl = await page.locator("#env_sd").evaluate((element) => ({
    value: element.value,
    maximum: element.dataset.max,
    label: document.querySelector("#env_sd-label")?.textContent.trim()
  }));
  record(
    "Core 4 uses the revised environmental-variation range",
    environmentalControl.value === "0.35" && environmentalControl.maximum === "0.4" && environmentalControl.label === "Environmental variation",
    JSON.stringify(environmentalControl)
  );

  for (const mission of [
    "Core 2: Island ceiling",
    "Core 3: Individual chance",
    "Core 4: Environmental variability",
    "Core 5: Rescue attempt"
  ]) {
    await runMission(page, mission);
  }

  for (const action of [
    {
      name: accessibleNames.coreExploreHelp,
      label: "Core and Explore",
      expectedText: ["Baseline compass", "Rescue attempt", "Vortex comparison", "latest successful Core settings"]
    },
    {
      name: accessibleNames.controlHelp,
      label: "Control help",
      expectedText: ["breeding and territory-holding stages", "bonanza and bust years"]
    },
    {
      name: accessibleNames.outputHelp,
      label: "Read outputs",
      expectedText: ["fixed deterministic projection", "Settings record"]
    },
    {
      name: accessibleNames.diagnosticHelp,
      label: "Read diagnostics",
      expectedText: ["does not prove", "No observed extinctions"]
    },
    {
      name: accessibleNames.plotHelp,
      label: "Read plots",
      expectedText: ["Extinction risk through time", "extinction-time histogram", "Quasi-extinction risk"]
    }
  ]) {
    await page.getByRole("button", { name: action.name }).click();
    markVisited(action.label);
    if (action.tab) {
      await tabLink(page, action.tab).click();
    } else {
      const modalText = await page.locator("#shiny-modal").innerText();
      record(
        `${action.label} reflects the current teaching interface`,
        action.expectedText.every((text) => modalText.includes(text)),
        modalText
      );
      await closeModal(page);
    }
  }

  await page.locator(".mission-rail").waitFor();
  await page.getByRole("button", { name: "Run mission" }).waitFor();
  record("Concept Lab mission rail is usable at 1366x768", await page.locator(".mission-rail").isVisible());
  record("Concept Lab Run mission is usable at 1366x768", await page.getByRole("button", { name: "Run mission" }).isEnabled());
  await assertConceptLabLayout(page, "1366x768");
  await page.screenshot({ path: artifactPath("concept-lab-1366x768.png"), fullPage: true });
  recordArtifact(artifactPath("concept-lab-1366x768.png"), "screenshot");
  await assertNoOverlap(page, [
    ".lab-grid > .panel-block:first-child",
    ".lab-grid > .output-region",
    ".plot-region"
  ], "Concept Lab 1366x768");
  await assertNoHorizontalOverflow(page, "Concept Lab 1366x768");

  await page.setViewportSize({ width: 1440, height: 900 });
  record(
    "Concept Lab mission controls are visible and enabled at 1440x900",
    await page.locator(".mission-rail").isVisible() &&
      await page.getByRole("button", { name: "Run mission" }).isVisible() &&
      await page.getByRole("button", { name: "Run mission" }).isEnabled()
  );
  await assertConceptLabLayout(page, "1440x900");
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
  await page.locator(".session-run-row").nth(4).waitFor({ state: "attached" });
  record("Core route keeps five successful session runs", await page.locator(".session-run-row").count() === 5);
  const historyDisclosure = page.locator("details.session-history-disclosure");
  record("full session history starts collapsed", !(await historyDisclosure.getAttribute("open")));
  record(
    "collapsed history reports all five runs",
    (await historyDisclosure.locator("summary").innerText()).includes("Review all 5 session runs")
  );
  await page.locator(".evidence-slot").nth(2).waitFor();
  await page.locator(".evidence-matrix-desktop").waitFor();
  record("selected evidence shows exactly three roles", await page.locator(".evidence-slot").count() === 3);

  for (const help of [
    {
      name: accessibleNames.selectionHelp,
      label: "Selection help",
      expectedText: ["baseline, risk mechanism, and intervention or vortex", "does not rewrite observations"]
    },
    {
      name: accessibleNames.outcomesHelp,
      label: "Read outcomes",
      expectedText: ["Extinction probability", "95% interval", "zero observed extinction probability"]
    },
    {
      name: accessibleNames.notebookHelp,
      label: "Notebook help",
      expectedText: ["final synthesis", "Saved observations keep their original run numbers"]
    }
  ]) {
    await page.getByRole("button", { name: help.name }).click();
    const modalText = await page.locator("#shiny-modal").innerText();
    record(`${help.label} explains the redesigned evidence workflow`, help.expectedText.every((text) => modalText.includes(text)), modalText);
    markVisited(help.label);
    await closeModal(page);
  }

  const observationOne = "Environmental variability widened the range of futures and increased risk relative to the deterministic baseline; the finite simulation set remains a caveat.";
  await addNotebookObservation(page, observationOne, 1);
  await chooseEvidenceRun(page, "selected_risk_run_id", 2);
  const observationTwo = "The island ceiling reduced median final abundance relative to baseline, showing that breeding-territory limits can constrain recovery even without observed extinction.";
  await addNotebookObservation(page, observationTwo, 2);
  const initialSynthesis = "Across the first comparisons, both environmental variation and a breeding-adult ceiling weakened viability evidence. The rescue action improved abundance, but conclusions still depend on the chosen horizon and simulated futures.";
  await page.locator("#final_synthesis").fill(initialSynthesis);
  await page.getByText("Evidence pack ready", { exact: false }).waitFor();

  await page.setViewportSize({ width: 1440, height: 900 });
  await page.screenshot({ path: artifactPath("compare-notebook-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("compare-notebook-1440x900.png"), "screenshot");
  await assertEvidenceMatrixFits(page, "Compare 1440x900");
  await assertNoHorizontalOverflow(page, "Compare 1440x900");

  await page.getByRole("button", { name: "Review evidence pack" }).click();
  await activePane(page).getByText("This browser session is temporary.", { exact: false }).waitFor();
  await page.getByText("Not downloaded", { exact: true }).first().waitFor();
  record("Transfer starts incomplete before downloads", await page.getByText("Evidence pack needs a fresh download", { exact: false }).count() > 0);
  await page.getByRole("button", { name: accessibleNames.transferHelp }).click();
  const transferHelpText = await page.locator("#shiny-modal").innerText();
  record(
    "Evidence pack help explains temporary sessions and stale files",
    ["temporary browser session", "Current", "stale"].every((text) => transferHelpText.includes(text)),
    transferHelpText
  );
  markVisited("Evidence pack help");
  await closeModal(page);
  await page.screenshot({ path: artifactPath("transfer-incomplete-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("transfer-incomplete-1440x900.png"), "screenshot");

  const initialCsvPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Comparison CSV" }).click();
  const initialCsvPath = await saveDownload(await initialCsvPromise, "initial CSV", "initial-comparison.csv");
  const initialNotesPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Evidence notebook" }).click();
  const initialNotesPath = await saveDownload(await initialNotesPromise, "initial Markdown", "initial-evidence-notebook.md");
  await page.getByText("Evidence pack complete", { exact: false }).waitFor();
  record("initial Transfer completes after both current downloads", true);

  const initialCsvRows = parseCsv(fs.readFileSync(initialCsvPath, "utf8"));
  const initialNotesText = fs.readFileSync(initialNotesPath, "utf8");
  record("selected CSV has header plus three rows", initialCsvRows.length === 4, `rows=${initialCsvRows.length - 1}`);
  record("initial notebook includes both observations", initialNotesText.includes("### Observation 1") && initialNotesText.includes("### Observation 2"));
  record("initial notebook retains final synthesis", initialNotesText.includes(initialSynthesis));
  await tabLink(page, "Compare").click();
  const initialRenderedEvidence = await renderedSelectedEvidence(page);
  assertExportConsistency(initialCsvRows, initialNotesText, {
    sessionRunCount: 5,
    renderedEvidence: initialRenderedEvidence
  });
  markVisited("Comparison CSV");
  markVisited("Evidence notebook");

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
  await assertConceptLabLayout(page, "390x844");
  await page.screenshot({ path: artifactPath("concept-lab-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("concept-lab-390x844.png"), "screenshot");
  await assertNoOverlap(page, [
    ".lab-grid > .panel-block:first-child",
    ".lab-grid > .output-region",
    ".plot-region"
  ], "Concept Lab 390x844");
  await assertNoHorizontalOverflow(page, "Concept Lab 390x844");

  await tabLink(page, "Compare").click();
  record(
    "Compare notebook controls are visible at 390x844",
    await page.locator("#observation_draft").isVisible() &&
      await page.getByRole("button", { name: "Add to notebook" }).isVisible() &&
      await page.locator("#final_synthesis").isVisible()
  );
  await page.screenshot({ path: artifactPath("compare-notebook-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("compare-notebook-390x844.png"), "screenshot");
  await assertEvidenceMatrixFits(page, "Compare 390x844");
  await assertNoHorizontalOverflow(page, "Compare 390x844");

  await page.setViewportSize({ width: 1366, height: 768 });
  await tabLink(page, "Concept Lab").click();
  await missionLink(page, "Explore: Small-population pressure").click();
  await page.getByLabel("Show advanced risk controls").check();
  await runMission(page, "Explore: Small-population pressure");
  await runMission(page, "Explore: Rare bad years");
  await runMission(page, "Explore: Rare bad years");
  await runMission(page, "Explore: Vortex comparison");

  const extinctionPlotPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Extinction risk PNG" }).click();
  await saveDownload(await extinctionPlotPromise, "extinction-risk PNG");
  markVisited("Extinction risk PNG");

  const quasiExtinctionPlotPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Quasi-extinction PNG" }).click();
  await saveDownload(await quasiExtinctionPlotPromise, "quasi-extinction PNG");
  markVisited("Quasi-extinction PNG");

  await tabLink(page, "Compare").click();
  await page.locator(".session-run-row").nth(8).waitFor({ state: "attached" });
  record("extension route keeps duplicate attempts", await page.locator(".session-run-row").count() === 9);
  const finalRenderedRunNumbers = await renderedRunNumbers(page);
  assertRenderedRunNumbers(finalRenderedRunNumbers, 9);
  await chooseEvidenceRun(page, "selected_risk_run_id", 8);
  await chooseEvidenceRun(page, "selected_action_run_id", 9);
  const observationThree = "Rare bad years and the extinction-vortex comparison produced the strongest warning signal in this session; their combined assumptions should be tested rather than treated as a forecast.";
  await addNotebookObservation(page, observationThree, 3);
  const finalSynthesis = "Across the selected evidence, compounding environmental, catastrophic, and small-population pressures produced the clearest viability concern. Management should test actions against several plausible assumptions because these teaching simulations describe conditional futures, not a single prediction.";
  await page.locator("#final_synthesis").fill(finalSynthesis);
  await page.getByText("Evidence pack ready", { exact: false }).waitFor();
  const finalRenderedEvidence = await renderedSelectedEvidence(page);
  const finalSelectedRunNumbers = await renderedSelectedRunNumbers(page);
  record(
    "final selected evidence is rendered as runs 1, 8, and 9",
    sameSequence(finalSelectedRunNumbers, [1, 8, 9]),
    JSON.stringify(finalSelectedRunNumbers)
  );
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.screenshot({ path: artifactPath("compare-final-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("compare-final-1440x900.png"), "screenshot");
  await assertEvidenceMatrixFits(page, "Compare final 1440x900");

  await page.getByRole("button", { name: "Review evidence pack" }).click();
  await activePane(page).getByText("Stale - download again", { exact: true }).first().waitFor();
  record(
    "extension selection invalidates the old CSV request",
    await activePane(page).getByText("Stale - download again", { exact: true }).count() === 2
  );
  record(
    "Transfer remains incomplete until final downloads",
    await page.getByText("Evidence pack needs a fresh download", { exact: false }).count() > 0
  );
  await page.screenshot({ path: artifactPath("transfer-stale-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("transfer-stale-1440x900.png"), "screenshot");

  const finalCsvPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Comparison CSV" }).click();
  const finalCsvPath = await saveDownload(await finalCsvPromise, "final CSV", "final-comparison.csv");
  await activePane(page).getByText("Current", { exact: true }).waitFor();
  record(
    "Transfer remains incomplete after only the fresh final CSV",
    await activePane(page).getByText("Current", { exact: true }).count() === 1 &&
      await activePane(page).getByText("Stale - download again", { exact: true }).count() === 1 &&
      await page.getByText("Evidence pack needs a fresh download", { exact: false }).count() > 0
  );

  const finalNotesPromise = page.waitForEvent("download");
  await page.getByRole("link", { name: "Evidence notebook" }).click();
  const finalNotesPath = await saveDownload(await finalNotesPromise, "final Markdown", "final-evidence-notebook.md");
  await page.getByText("Evidence pack complete", { exact: false }).waitFor();
  const finalCsvRows = parseCsv(fs.readFileSync(finalCsvPath, "utf8"));
  const finalNotesText = fs.readFileSync(finalNotesPath, "utf8");
  const finalExpectedStages = ["deterministic_baseline", "catastrophe", "extinction_vortex"];
  const finalEvidenceSummary = "Selected evidence: 3 runs from 9 successful session runs";
  record(
    "final notes assert the exact live-history summary",
    finalRenderedRunNumbers.length === 9 && finalNotesText.includes(finalEvidenceSummary),
    finalEvidenceSummary
  );
  record(
    "final notebook retains all chronological observations",
    finalNotesText.includes("### Observation 1") &&
      finalNotesText.includes("### Observation 2") &&
      finalNotesText.includes("### Observation 3") &&
      finalNotesText.includes(observationOne) &&
      finalNotesText.includes(observationTwo) &&
      finalNotesText.includes(observationThree)
  );
  record("final notebook retains final synthesis", finalNotesText.includes("## Final synthesis") && finalNotesText.includes(finalSynthesis));
  assertExportConsistency(finalCsvRows, finalNotesText, {
    expectedRunIds: [1, 8, 9],
    expectedStages: finalExpectedStages,
    sessionRunCount: 9,
    renderedEvidence: finalRenderedEvidence
  });
  markVisited("Comparison CSV");
  markVisited("Evidence notebook");

  record(
    "Transfer completes only after both fresh final downloads",
    await activePane(page).getByText("Current", { exact: true }).count() === 2 &&
      await page.getByText("Evidence pack complete", { exact: false }).count() > 0
  );
  await page.screenshot({ path: artifactPath("transfer-complete-1440x900.png"), fullPage: true });
  recordArtifact(artifactPath("transfer-complete-1440x900.png"), "screenshot");
  await assertNoHorizontalOverflow(page, "Transfer 1440x900");

  await page.setViewportSize({ width: 390, height: 844 });
  await page.screenshot({ path: artifactPath("transfer-complete-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("transfer-complete-390x844.png"), "screenshot");
  await assertNoHorizontalOverflow(page, "Transfer 390x844");

  await tabLink(page, "Start").click();
  await page.screenshot({ path: artifactPath("start-390x844.png"), fullPage: true });
  recordArtifact(artifactPath("start-390x844.png"), "screenshot");
  const mobileNavHeight = await page.locator(".navbar").evaluate((element) => element.getBoundingClientRect().height);
  record("Start mobile navigation is compact", mobileNavHeight <= 150, `${mobileNavHeight}px`);
  await assertNoOverlap(page, [".landing-copy", ".landing-hero-visual", ".landing-card-grid"], "390x844");
  await assertNoHorizontalOverflow(page, "Start 390x844");

  await tabLink(page, "Compare").click();
  await page.getByRole("button", { name: "Reset comparison" }).click();
  await page.getByText("Run history, evidence selection, notebook observations, synthesis", { exact: false }).waitFor();
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
  prepareEvidenceDirectory,
  requiredComparisonFields,
  sharedComparisonFieldsMatch,
  exactRenderedStagesMatch,
  canonicalExpectedSettings,
  canonicalSpecRowsForEvidence,
  settingsRowsExactlyMatch
};
