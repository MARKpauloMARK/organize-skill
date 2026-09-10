---
name: organize
description: Safely organize a user-specified folder by inspecting its context, proposing low-risk file movements, detecting verified duplicates and conflicts, and executing only after approval. Use for requests to organize, structure, clean up, or reorganize a folder or project directory.
---

# Organize Folder

Organize a folder conservatively, with a read-only diagnosis before any mutation.

## Authorization boundary

- Require the exact target path; never infer it from the current directory.
- Inspection and planning are read-only. Present the plan before creating directories or moving files.
- Treat approval to move files separately from approval to discard files.
- Never permanently delete. Send explicitly confirmed discard items to the Windows Recycle Bin. If that cannot be verified, offer `.trash-organize/` as a recoverable fallback and explain that it remains inside the target.
- Do not reveal the contents of secrets such as `.env`, credentials, keys, tokens, cookies, or certificates.

## Protected areas

Do not scan inside, move, rename, write into, or propose content from these directories: `frontend`, `backend`, `remotion`, `.claude`, `.codex`, `.git`, `node_modules`, `Untitled`, `.venv`, `dist`, `build`, `__pycache__`, and `.trash-organize`.

Do not follow symbolic links, junctions, shortcuts, or other reparse points. Report them as retained and outside the organization scope.

## Read-only diagnosis

Use `scripts/inspect-organize.ps1` when PowerShell is available. It inventories the target without reading file contents, detects project markers, excludes protected areas, identifies destination conflicts, and verifies possible duplicates with SHA-256. Review its JSON output before proposing changes.

If the helper cannot run, perform equivalent read-only checks manually and state that limitation.

Classify only loose files at the target root whose role is clear:

- `docs/`: `.md`, `.txt`, `.pdf`, `.docx`, `.xlsx`, `.pptx`, READMEs, and specs.
- `assets/`: `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.webp`, and `.ico`.
- `media/`: `.mp4`, `.mov`, `.avi`, `.mp3`, `.wav`, `.m4a`, and `.webm`.
- `scripts/`: standalone `.py`, `.js`, `.ts`, `.sh`, `.bat`, and `.ps1` files, only when they are not part of the project structure.
- `config/`: standalone `.env`, `.json`, `.yaml`, `.yml`, `.toml`, and `.ini` files, only when their configuration role is unambiguous. Never print their contents.
- `arquivo/`: clearly historical items whose names contain an old date or begin with `old-`, `bkp-`, or `backup-`.

Keep project manifests, essential configuration, protected areas, links, and ambiguous files in place. When project markers such as `.git`, `package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, or `composer.json` are present, apply extra caution and do not move source or configuration merely because its extension matches a category.

## Plan and confirmation

Present separate sections:

1. **Organization proposed**: each source, destination, and confidence. State that this stage discards nothing.
2. **Conflicts and retained items**: destination collisions, links, protected areas, and ambiguous files. Never overwrite an existing destination; stop and request a decision.
3. **Discard candidates**: reason, size, risk, and consequence. Include only empty files, temporary/backup files, OS metadata, tool caches, or logs older than 90 days. Recognizable project/client/operation files and non-empty images, media, and documents are never automatic candidates.

An exact duplicate requires matching size and SHA-256 hash. Even verified duplicates require explicit discard approval.

## Execution

After approval, create only the destination directories that will receive files. Maintain an operation journal containing source, destination, action, and status. Do not record file contents or secrets.

Move one item at a time with errors treated as terminating. Before each move:

- confirm the source still exists and has not changed since inspection;
- confirm the destination is still free;
- confirm neither path enters a protected directory or traverses a reparse point.

Stop at the first failure. Report completed and pending operations; do not silently roll back or continue. Offer reversal using the journal, but perform it only with user approval.

For confirmed discards, verify that each item left its original path. If the Recycle Bin operation cannot be verified, do not count it as discarded.

## Validation and report

Verify every moved file exists at its destination and no longer exists at its source. Recount files while excluding protected areas consistently with the initial inventory.

- Recycle Bin: expected in-scope final count is initial count minus verified discarded items.
- `.trash-organize/` fallback: expected total target count is unchanged because files were relocated, not removed.

Report moved, retained, conflicted, discarded, fallback-relocated, failed, and pending counts; directories created; and validation status. If validation fails, lead with the exact discrepancy.

