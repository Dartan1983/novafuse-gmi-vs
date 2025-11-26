# GMI‑VS Legal, Safety, and Integrity Statements

## Legal Disclaimer

This verification suite is provided “AS IS” without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, non‑infringement, or security. In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.

## Test Mode Warning

NON‑PRODUCTION USE ONLY. GMI‑VS validates runtime barriers, adversarial containment, guardrail durability, and policy coherency. Do not connect to customer‑facing endpoints. Extended adversarial loops may temporarily increase CPU load.

## System Impact Statement

GMI‑VS does not modify OS/kernel, registry/config files, model weights, or network stack. It does not deploy agents, establish shells, or run arbitrary external code. GMI‑VS never elevates privileges beyond the user session and does not require Administrator rights for verification operations. All write‑operations are restricted to repository canonical paths.

## Regulatory‑Friendly Release Note

GMI‑VS provides safety validation via contextual metrics and triadic checks. Certificates undergo strict JSON schema validation and include SHA‑256 evidence chain digests for reproducibility and tamper‑evident auditability.

## Threat Model (Negative Capabilities)

- Does not scan network beyond local telemetry endpoints
- Does not enumerate users, AD objects, or system secrets
- Does not open ports or create listeners
- Does not execute arbitrary code from untrusted paths
- Does not modify model weights, policies, prompts, or AI runtime logic

## Integrity Model

Interaction‑bound integrity: consumes system signals, never assumes control over processes, resources, or model execution.

## Security Review Note

PowerShell scripts validated for path traversal protections and restricted to canonical repository paths.
