/**
 * audit-log.mjs — PostToolUse hook for Bash tool
 *
 * Records every bash command the agent runs into the daily audit log.
 * Catches forbidden command attempts and writes a warning.
 */

import { readFileSync, appendFileSync, existsSync, mkdirSync } from 'node:fs';

const AUDIT_DIR = '.agent/audit';
const today = new Date().toISOString().split('T')[0];
const auditFile = `${AUDIT_DIR}/${today}-commands.jsonl`;

// Forbidden command patterns (mirror safety.forbidden_commands in agent.config.yaml)
const FORBIDDEN = [
  /rm\s+-rf\s+\//,
  /DROP\s+(TABLE|DATABASE)/i,
  /git\s+push\s+--force\s+(?:origin\s+)?main/,
];

let toolContext = {};
try {
  const raw = readFileSync('/dev/stdin', 'utf8').trim();
  if (raw) toolContext = JSON.parse(raw);
} catch {
  // proceed silently
}

const command = toolContext?.tool_input?.command ?? '';
const exitCode = toolContext?.tool_response?.exit_code ?? null;

if (!existsSync(AUDIT_DIR)) {
  mkdirSync(AUDIT_DIR, { recursive: true });
}

// Check for forbidden patterns
let forbidden = false;
for (const pattern of FORBIDDEN) {
  if (pattern.test(command)) {
    forbidden = true;
    process.stderr.write(
      `[audit-log] 🚨 FORBIDDEN COMMAND DETECTED: ${command}\n` +
      `  This command matches a safety exclusion in agent.config.yaml.\n` +
      `  The command was executed — review immediately and revert if unintentional.\n`
    );
    break;
  }
}

const entry = {
  timestamp: new Date().toISOString(),
  hook: 'PostToolUse:Bash',
  command: command.slice(0, 500), // truncate very long commands
  exitCode,
  forbidden,
};
appendFileSync(auditFile, JSON.stringify(entry) + '\n');
