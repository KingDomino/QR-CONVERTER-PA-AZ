# QR-CONVERTER-PA-AZ

A QR Code scanner + thermal-label printer for PostalAnnex+ employees to process Amazon
returns and print labels at the counter without emailing anything.

The whole app is one self-contained file, **`app.html`** — it opens in Microsoft Edge
(app mode) and needs no internet to run. `install.bat` just downloads that file and makes
the desktop shortcuts.

---

## How distribution works (the important part)

**`app.html` in this repo is the single source of truth.** There is no second copy to keep
in sync. `install.bat` contains **no** app code — when run, it downloads the latest
`app.html` straight from GitHub:

```
https://raw.githubusercontent.com/KingDomino/QR-CONVERTER-PA-AZ/main/app.html
```

So updating the app is just editing `app.html` and pushing. Installing/updating a counter PC
is just (re-)running `install.bat`.

---

## Install on a counter PC (for employees)

1. Download **`install.bat`** from this repo (open the file on GitHub → **Download raw file**).
   Don't email it to yourself — mail filters block `.bat` files.
2. Windows marks files from the web as blocked. Either:
   - Right-click `install.bat` → **Properties** → check **Unblock** → **OK**, **or**
   - Just double-click it and, on the blue "Windows protected your PC" prompt, click
     **More info** → **Run anyway**.
3. It downloads the app to `%LOCALAPPDATA%\PostalAnnex-Scanner\app.html` and creates an
   **"Amazon QR Code Scanner"** shortcut on the Desktop and in the Start Menu.
4. Open it from the Desktop/Start Menu and scan.

No administrator rights are needed. Internet is required only while installing/updating —
once installed the app runs fully offline.

## Update a counter PC

Just run `install.bat` again (double-click). It re-downloads the latest `app.html` and
overwrites the local copy. **If the app was already open, close and reopen it** so Edge
reloads the new version. Confirm the version number in the app's footer changed.

---

## Ship an update (for the maintainer)

1. Edit **`app.html`** — it is the only file you touch for app changes. Never edit
   `install.bat` to change the app.
2. Bump the version string in the footer (`<div id="versionFooter">Amazon Scanner vX.Y</div>`)
   so the on-screen footer shows what shipped.
3. Test locally: double-click `app.html`, do a test scan, confirm the QR renders and a 4×6
   label print-previews. (Works offline — the QR library is bundled into `app.html`.)
4. Push:
   ```
   git add app.html && git commit -m "describe change" && git push origin main
   ```
5. Wait ~5 minutes for GitHub's raw CDN cache to refresh before testing on a PC.
6. Re-run `install.bat` on each counter PC to roll it out. New installs get the latest
   automatically.

**Rolling back a bad release:** `git revert <commit> && git push origin main`, then re-run
`install.bat` on affected PCs. PCs you haven't re-run keep their previous working copy — a
bad push never reaches a counter until someone deliberately re-runs the installer there.

### One-time check before the first rollout to a new/locked-down PC

The installer runs PowerShell. On a heavily locked-down machine (Constrained Language Mode
or a machine-wide AllSigned policy) that can be blocked. To check a PC, run in PowerShell:

```
$ExecutionContext.SessionState.LanguageMode   # want: FullLanguage
Get-ExecutionPolicy -List                     # no machine-scope AllSigned
```

(If the current installer already works on your PCs, they're fine — this is just a safety
check for new hardware.)
