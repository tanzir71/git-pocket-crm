# 00 Open the repository

## Goal

The repository is public, holds this handover on `main`, and is safe to be public. This is milestone M0.

## Facts

- Remote: `https://github.com/tanzir71/git-pocket-crm.git`, default branch `main`.
- On 26 November 2026 the three existing commits were scanned for keys, tokens, passwords and private-key blocks, and for tracked keystores, `key.properties`, `.env` and `local.properties` files. Nothing was found. Repeat the scan, because the tree may have changed.

## Steps

1. Confirm you are on `main` with a clean tree apart from `AGENTS.md`, `GEMINI.md` and `handover/`. Run `git pull --ff-only`.
2. **Scan before publishing.** Search the full history (`git log --all -p`) and the working tree for: `api_key`, `apikey`, `secret`, `password`, `token`, `BEGIN PRIVATE KEY`, `BEGIN RSA`, `AKIA`, `ghp_`, `AIza`, and for phone numbers and e-mail addresses that are not obviously invented. Check `git ls-files` for `*.jks`, `*.keystore`, `key.properties`, `.env*`, `local.properties`, `google-services.json`. If anything real turns up, stop this spec, describe it in `handover/BLOCKED.md` without repeating the secret, and do not make the repository public.
3. Add to `.gitignore` if missing: `*.jks`, `*.keystore`, `key.properties`, `.env*`, `local.properties`.
4. Commit the handover: `git add AGENTS.md GEMINI.md handover/ .gitignore`, commit as `spec 00: add v2 handover`, push.
5. **Make the repository public.**

```sh
gh repo edit tanzir71/git-pocket-crm --visibility public --accept-visibility-change-consequences
gh repo view tanzir71/git-pocket-crm --json visibility --jq .visibility   # expect PUBLIC
```

   If `gh` is not installed, install it with the system package manager (`winget install GitHub.cli` on Windows). If `gh auth status` shows no login, do not ask the owner to sign in. Use the token git already holds for pushing: read it with `git credential fill` for `host=github.com`, pass it as `GH_TOKEN` to the commands in this spec, and never print it, write it to a file, or commit it. If that also fails, record it in `handover/BLOCKED.md`, continue with spec 01, and try this step again at the start of every milestone. Everything except the landing page works on a private repository.
6. **Describe it.**

```sh
gh repo edit tanzir71/git-pocket-crm \
  --description "A private, on-device relationship app for Android: call and SMS history per person, notes, follow-ups, and scheduled SMS. No account, no server." \
  --homepage "https://tanzir71.github.io/git-pocket-crm/" \
  --add-topic android --add-topic flutter --add-topic personal-crm --add-topic local-first --add-topic sms
```

7. **Switch GitHub Actions off** for the repository so nothing can run there: `gh api -X PUT repos/tanzir71/git-pocket-crm/actions/permissions -F enabled=false`. The landing page is published from a branch with a `.nojekyll` file, which GitHub serves without Actions (see `04-research-notes.md`).
8. Create `handover/PROGRESS.md`, `handover/DECISIONS.md`, `handover/TEST-RESULTS.md`, `handover/UNVERIFIED.md` and `handover/BLOCKED.md`, each with a one-line purpose. Put the four permanent entries from `AGENTS.md` into `UNVERIFIED.md`. Write the M0 entry in `PROGRESS.md`.
9. Commit as `spec 00: repository public`, push, tag `m0`, push the tag.

## Acceptance criteria

- `gh repo view --json visibility` reports `PUBLIC`, or `BLOCKED.md` explains exactly what was tried.
- `git ls-remote origin main` matches local `HEAD`, and tag `m0` exists on the remote.
- No file under `.github/workflows/` exists.

## Out of scope

A licence file. Enabling GitHub Pages (spec 15, once `docs/` exists).
