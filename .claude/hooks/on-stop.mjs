/**
 * on-stop.mjs — Stop hook
 *
 * Runs when Claude Code finishes a response. Writes a session summary
 * to the audit log and checks for any in-flight agent tasks that may
 * need to be resumed.
 */

import { readFileSync, appendFileSync, existsSync, readdirSync, mkdirSync } from 'node:fs';

const AUDIT_DIR = '.agent/audit';
const STATE_DIR = '.agent/state';
const today = new Date().toISOString().split('T')[0];
const auditFile = `${AUDIT_DIR}/${today}-sessions.jsonl`;

if (!existsSync(AUDIT_DIR)) {
  mkdirSync(AUDIT_DIR, { recursive: true });
}

// Check for in-flight tasks that need attention
const inFlightTasks = [];
if (existsSync(STATE_DIR)) {
  for (const file of readdirSync(STATE_DIR)) {
    if (!file.endsWith('.json') || file.startsWith('groom-')) continue;
    try {
      const state = JSON.parse(readFileSync(`${STATE_DIR}/${file}`, 'utf8'));
      if (state.status === 'in_progress' || state.status === 'awaiting_human') {
        inFlightTasks.push({ taskId: state.taskId, phase: state.phase, status: state.status });
      }
    } catch {
      // skip malformed state files
    }
  }
}

// Check for kill switch
const killSwitchExists = existsSync('.agent/STOP');

// Write session end entry
const entry = {
  timestamp: new Date().toISOString(),
  hook: 'Stop',
  inFlightTaskCount: inFlightTasks.length,
  inFlightTasks,
  killSwitchActive: killSwitchExists,
};
appendFileSync(auditFile, JSON.stringify(entry) + '\n');

// Warn about in-flight tasks
if (inFlightTasks.length > 0) {
  process.stderr.write(
    `[on-stop] ℹ️  ${inFlightTasks.length} agent task(s) still in flight:\n` +
    inFlightTasks.map(t => `  • ${t.taskId} (${t.phase} / ${t.status})`).join('\n') +
    `\n  Resume with: /loop resume <task-id>\n`
  );
}

if (killSwitchExists) {
  process.stderr.write(
    `[on-stop] ⚠️  KILL SWITCH ACTIVE (.agent/STOP exists). Agent is paused.\n` +
    `  Remove the file to re-enable: rm .agent/STOP\n`
  );
}
