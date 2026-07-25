# QR-CONVERTER-PA-AZ

A QR Code scanner + thermal-label printer for PostalAnnex+ employees to process Amazon
returns and print labels at the counter without emailing anything.

The whole app is one self-contained file, **`app.html`** — it opens in Microsoft Edge
(app mode) and needs no internet to run. `install.bat` just downloads that file and makes
the desktop shortcuts.

Disclaimer: Almost all of this is vibe-coded by Claude, I didn't feel like giving this band-aid solution much effort.

---

## How installation works (the important part)

Install.bat will pull the latest version of app.html from this repo (at the following link), then add a start menu shortcut.

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

No administrator rights are needed. Internet is required only while installing/updating,
once installed the app runs fully offline.

## Update a counter PC

Just run `install.bat` again (double-click). It re-downloads the latest `app.html` and
overwrites the local copy. **If the app was already open, close and reopen it** so Edge
reloads the new version. Confirm the version number in the app's footer changed.

