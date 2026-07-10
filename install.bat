@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "IEX (Get-Content '%~f0' | Select-Object -Skip 3 | Out-String)"
exit /b

# ====================================================
#        AMAZON QR CODE SCANNER AUTO-INSTALLER          
# ====================================================
Write-Host "====================================================" -ForegroundColor Green
Write-Host "       AMAZON QR CODE SCANNER AUTO-INSTALLER        " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# 1. Create the dedicated system directory cleanly
Write-Host "Creating application path..."
$installPath = "C:\PostalAnnex-Scanner"
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# 2. Extract the embedded application code into the file path
Write-Host "Unpacking application assets natively..."
$htmlContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PostalAnnex+ Amazon QR Code Scanner</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    
    <style>
        /* Screen Layout Styles */
        body {
            font-family: system-ui, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f2f5;
        }
        .card {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            text-align: center;
            position: relative;
            width: 380px;
        }

        /* CUSTOM BRANDING LOGO */
        .brand-logo {
            font-size: 28px;
            font-weight: 800;
            font-style: italic;
            letter-spacing: -1px;
            margin-bottom: 5px;
            user-select: none;
        }
        .brand-red { color: #d11226; }
        .brand-blue { color: #002f6c; }
        
        .brand-subtext {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: #6c757d;
            margin-bottom: 25px;
            border-top: 2px solid #002f6c;
            padding-top: 4px;
            display: inline-block;
            width: 100%;
        }

        /* Input Frame */
        .input-container {
            position: relative;
            width: 100%;
            box-sizing: border-box;
        }

        input {
            width: 100%;
            box-sizing: border-box;
            padding: 14px 40px 14px 14px;
            font-size: 18px;
            border: 2px solid #ced4da;
            border-radius: 6px;
            outline: none;
            text-align: center;
            transition: all 0.15s ease;
        }
        input:focus { border-color: #002f6c; }

        /* Highlight state for stray keystrokes */
        .input-error {
            border-color: #dc3545 !important;
            background-color: #fff5f5;
        }

        /* Clear Button */
        #clearBtn {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: #e9ecef;
            border: 1px solid #ced4da;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: none; 
            align-items: center;
            justify-content: center;
            font-size: 11px;
            cursor: pointer;
            color: #495057;
            font-weight: bold;
            user-select: none;
        }
        #clearBtn:hover {
            background-color: #dee2e6;
            color: #212529;
        }

        /* Warnings & Badges */
        #typingWarning {
            display: none;
            margin-top: 8px;
            color: #dc3545;
            font-size: 13px;
            font-weight: bold;
            background-color: #fff5f5;
            border: 1px solid #f5c6cb;
            padding: 10px;
            border-radius: 6px;
            text-align: center;
        }
        
        #alertBadge {
            display: none;
            margin-top: 15px;
            padding: 10px 20px;
            background-color: #28a745;
            color: white;
            font-weight: bold;
            border-radius: 20px;
            font-size: 14px;
        }

        #errorMessageContainer {
            display: none;
            margin-top: 15px;
            padding: 20px;
            font-weight: bold;
            border-radius: 8px;
            font-size: 15px;
            line-height: 1.5;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
        #errorMessageContainer span {
            font-size: 18px;
            display: inline-block;
            margin-bottom: 4px;
            animation: blink 1.2s infinite;
        }

        /* Prompts */
        .prompt-container {
            display: none;
            margin-top: 15px;
            padding: 20px;
            background-color: #f8f9fa;
            border: 2px solid #002f6c;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.05);
        }
        .prompt-title {
            font-weight: bold;
            color: #002f6c;
            margin-bottom: 15px;
            font-size: 14px;
            line-height: 1.4;
        }
        .prompt-btn-group {
            display: flex;
            gap: 12px;
            justify-content: center;
        }
        .btn-action {
            padding: 12px 24px;
            font-size: 14px;
            font-weight: bold;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            flex: 1;
            transition: opacity 0.15s ease;
        }
        .btn-action:hover { opacity: 0.9; }
        .btn-no { background-color: #dc3545; }   
        .btn-yes { background-color: #28a745; }  

        @keyframes blink {
            0%, 50% { opacity: 1; }
            51%, 100% { opacity: 0; }
        }

        /* Print Layout Zone */
        #printZone {
            margin-top: 25px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        #printHeader {
            display: none; 
            font-size: 22px;
            font-weight: 800;
            color: #212529;
            margin-bottom: 15px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Data Wrapper */
        #dataDisplayWrapper {
            position: relative;
            width: 100%;
            margin-top: 15px;
            display: none; 
        }

        #scannedTextDisplay {
            font-size: 12px;
            color: #495057;
            word-break: break-all;
            text-align: left;
            font-family: monospace;
            background-color: #e9ecef;
            padding: 12px;
            padding-right: 78px; 
            border-radius: 6px;
            border: 1px solid #ced4da;
            max-height: 80px;
            overflow-y: auto;
            width: 100%;
            box-sizing: border-box;
            margin: 0;
        }

        #copyRawBtn {
            position: absolute;
            right: 8px;
            top: 8px;
            padding: 5px 8px;
            font-size: 11px;
            font-weight: bold;
            color: #495057;
            background-color: #ffffff;
            border: 1px solid #ced4da;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.15s ease;
            user-select: none;
        }
        #copyRawBtn:hover {
            background-color: #dee2e6;
            color: #212529;
        }

        /* Buttons & Footer */
        .button-group {
            display: flex;
            flex-direction: column;
            align-items: center;
            width: 100%;
        }

        #reprintBtn {
            display: none; 
            margin-top: 20px;
            padding: 10px 24px;
            font-size: 14px;
            font-weight: 600;
            color: #495057;
            background-color: #e9ecef;
            border: 1px solid #ced4da;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s ease;
            width: 100%;
        }
        #reprintBtn:hover {
            background-color: #dee2e6;
            color: #212529;
        }

        #overrideBtn {
            display: none; 
            margin-top: 15px;
            padding: 12px 28px;
            font-size: 14px;
            font-weight: bold;
            color: #fff;
            background-color: #ffc107; 
            border: 1px solid #e0a800;
            border-radius: 6px;
            cursor: pointer;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            transition: background-color 0.2s ease;
            width: 100%;
        }
        #overrideBtn:hover { background-color: #e0a800; }

        #instructions {
            font-size: 12px;
            color: #495057;
            text-align: left;
            margin-top: 30px;
            line-height: 1.6;
            border-top: 1px dashed #ced4da;
            padding-top: 15px;
            width: 100%;
            box-sizing: border-box;
        }
        .instruction-title {
            font-weight: bold;
            color: #6c757d;
            text-transform: uppercase;
            font-size: 10px;
            letter-spacing: 1px;
            margin-bottom: 6px;
        }

        #versionFooter {
            font-size: 10px;
            color: #adb5bd;
            margin-top: 15px;
            text-align: center;
            width: 100%;
            user-select: none;
        }

        /* AIR-TIGHT THERMAL PRINTER FIXES */
        @media print {
            html, body {
                margin: 0 !important;
                padding: 0 !important;
                height: 100% !important;
                overflow: hidden !important;
                background-color: #ffffff !important;
            }
            .card {
                box-shadow: none !important;
                padding: 0 !important;
                margin: 0 !important;
            }
            body * { visibility: hidden; }
            
            #printZone, #printZone * { visibility: visible; }
            
            #printZone {
                position: absolute;
                top: 0;
                left: 0;
                width: 100% !important;
                height: 100% !important;
                margin: 0 !important;
                padding: 0 !important;
                display: flex !important;
                flex-direction: column !important;
                align-items: center !important;
                justify-content: center !important;
            }

            #printHeader {
                display: block !important;
                font-size: 26px !important;
                font-weight: bold !important;
                color: #000000 !important;
                margin-bottom: 20px !important;
                text-align: center !important;
                font-family: system-ui, sans-serif !important;
            }

            @page {
                size: 4in 6in;
                margin: 0 !important;
            }
        }
    </style>
</head>
<body>

<div class="card">
    <div class="brand-logo">
        <span class="brand-blue">Postal</span><span class="brand-red">Annex</span><span class="brand-blue">+</span>
    </div>
    <div class="brand-subtext">Amazon QR Code Scanner</div>

    <div class="input-container">
        <input type="text" id="textInput" placeholder="Scan QR Code" autofocus>
        <div id="clearBtn">X</div>
    </div>
    
    <div id="typingWarning">Warning: text box is not clear, please clear it before scanning a QR code</div>
    
    <div id="alertBadge">Amazon QR Code Detected!</div>
    <div id="errorMessageContainer"></div>
    
    <div id="packingQuestionContainer" class="prompt-container">
        <div class="packing-title">This item is marked as customer packed. Has it been properly packed yet?</div>
        <div class="packing-btn-group">
            <button id="packingNoBtn" class="btn-action btn-no">No</button>
            <button id="packingYesBtn" class="btn-action btn-yes">Yes</button>
        </div>
    </div>

    <div id="happyReturnQuestionContainer" class="prompt-container">
        <div class="prompt-title">This appears to be a happy return, have you already tried accepting through PostalMate?</div>
        <div class="prompt-btn-group">
            <button id="happyReturnNoBtn" class="btn-action btn-no">No</button>
            <button id="happyReturnYesBtn" class="btn-action btn-yes">Yes</button>
        </div>
    </div>

    <div id="printZone">
        <div id="printHeader"></div>
        <div id="qrcode"></div>
    </div>
    
    <div id="dataDisplayWrapper">
        <div id="scannedTextDisplay"></div>
        <button id="copyRawBtn">Copy All</button>
    </div>
    
    <div class="button-group">
        <button id="reprintBtn">Reprint Last Label</button>
        <button id="overrideBtn">⚠️ Force Print (Override)</button>
    </div>

    <div id="instructions">
        <div class="instruction-title">Counter Instructions</div>
        1. Scan QR code, ensure textbox is clear first<br>
        2. Print QR label, place on item<br>
        3. Press CTRL + V in PostalMate to automatically paste RMA number
    </div>

    <div id="versionFooter">Amazon Scanner v1.1</div>
</div>

<script>
    const input = document.getElementById('textInput');
    const qrContainer = document.getElementById('qrcode');
    const printHeader = document.getElementById('printHeader');
    const alertBadge = document.getElementById('alertBadge');
    const reprintBtn = document.getElementById('reprintBtn');
    const errorMessageContainer = document.getElementById('errorMessageContainer');
    const overrideBtn = document.getElementById('overrideBtn');
    
    const clearBtn = document.getElementById('clearBtn');
    const typingWarning = document.getElementById('typingWarning');

    const packingQuestionContainer = document.getElementById('packingQuestionContainer');
    const packingNoBtn = document.getElementById('packingNoBtn');
    const packingYesBtn = document.getElementById('packingYesBtn');

    const happyReturnQuestionContainer = document.getElementById('happyReturnQuestionContainer');
    const happyReturnNoBtn = document.getElementById('happyReturnNoBtn');
    const happyReturnYesBtn = document.getElementById('happyReturnYesBtn');

    const dataDisplayWrapper = document.getElementById('dataDisplayWrapper');
    const scannedTextDisplay = document.getElementById('scannedTextDisplay');
    const copyRawBtn = document.getElementById('copyRawBtn');

    /* NEW: Pattern-Based Case Inversion 
      This flips the text casing unconditionally, handling both upper/lower mistakes.
    */
    function flipCase(str) {
        return str.split('').map(char => {
            if (char === char.toUpperCase()) {
                return char.toLowerCase();
            } else {
                return char.toUpperCase();
            }
        }).join('');
    }

    input.addEventListener('input', function() {
        if (input.value.length > 0) {
            input.classList.add('input-error');
            typingWarning.style.display = 'block';
            clearBtn.style.display = 'flex';
        } else {
            input.classList.remove('input-error');
            typingWarning.style.display = 'none';
            clearBtn.style.display = 'none';
        }
    });

    clearBtn.addEventListener('click', function() {
        input.value = '';
        input.classList.remove('input-error');
        typingWarning.style.display = 'none';
        clearBtn.style.display = 'none';
        input.focus();
    });

    input.addEventListener('keydown', function(event) {
        if (event.key === 'Enter') {
            let text = input.value;

            if (text.trim() === '') return;

            /* NEW CAPS LOCK PARSING ENGINE:
              Checks the explicit string content instead of hardware states.
              If the known prefixes are scanned as lowercase (e.g., 'afnlf', 'hr'), 
              the text is immediately flipped back to uppercase.
            */
            const lowerCaseText = text.toLowerCase();
            if (lowerCaseText.startsWith('afnlf') || lowerCaseText.startsWith('hr')) {
                // If it starts with a lowercase version of our known headers, caps lock is inverted.
                if (text.startsWith('a') || text.startsWith('h')) {
                    text = flipCase(text);
                    input.value = text;
                }
            }

            // Flush UI
            qrContainer.innerHTML = '';
            printHeader.textContent = '';
            printHeader.style.display = 'none';
            alertBadge.style.display = 'none';
            reprintBtn.style.display = 'none';
            errorMessageContainer.style.display = 'none'; 
            overrideBtn.style.display = 'none'; 
            packingQuestionContainer.style.display = 'none';
            happyReturnQuestionContainer.style.display = 'none';
            dataDisplayWrapper.style.display = 'none';
            scannedTextDisplay.textContent = '';

            input.classList.remove('input-error');
            typingWarning.style.display = 'none';
            clearBtn.style.display = 'none';

            const sections = text.split('|');
            const firstSection = sections[0];

            /* ROUTING ENGINE
            */
            if (text.startsWith('HR')) {
                window.pendingText = text;
                window.pendingRma = sections[1] || '';
                happyReturnQuestionContainer.style.display = 'block';
                input.value = ''; 

            } else if (firstSection.startsWith('AFNLFBF')) {
                const rmaNumber = sections[1]; 
                
                if (rmaNumber) {
                    alertBadge.style.display = 'block';
                    alertBadge.textContent = `Amazon QR Detected! RMA Copied: ${rmaNumber}`;
                    navigator.clipboard.writeText(rmaNumber).catch(err => {});
                }

                printHeader.textContent = "No Box No Label";
                printHeader.style.display = "block";

                new QRCode(qrContainer, {
                    text: text,
                    width: 300,
                    height: 300,
                    correctLevel: QRCode.CorrectLevel.H
                });

                scannedTextDisplay.textContent = text;
                dataDisplayWrapper.style.display = 'block';
                reprintBtn.style.display = 'inline-block';

                setTimeout(() => {
                    window.print();
                    input.value = ''; 
                    input.focus();    
                }, 250);

            } else if (firstSection.startsWith('AFNLF')) {
                window.pendingText = text;
                window.pendingRma = sections[1] || '';
                packingQuestionContainer.style.display = 'block';
                input.value = ''; 

            } else {
                errorMessageContainer.style.backgroundColor = '#fff3cd'; 
                errorMessageContainer.style.border = '2px solid #ffc107'; 
                errorMessageContainer.style.color = '#856404';
                errorMessageContainer.innerHTML = '<span style="color: #b58100;">WARNING!</span><br>Please check the return location of this QR code before accepting it.';
                errorMessageContainer.style.display = 'block'; 
                overrideBtn.style.display = 'block';

                window.lastRejectedText = text; 
                input.value = ''; 
                input.focus();
            }
        }
    });

    happyReturnYesBtn.addEventListener('click', function() {
        const text = window.pendingText;
        const rmaNumber = window.pendingRma;
        if (!text) return;

        happyReturnQuestionContainer.style.display = 'none';

        if (rmaNumber) {
            alertBadge.style.display = 'block';
            alertBadge.textContent = `Happy Return Detected! RMA Copied: ${rmaNumber}`;
            navigator.clipboard.writeText(rmaNumber).catch(err => {});
        }

        printHeader.textContent = "Happy Return";
        printHeader.style.display = "block";

        new QRCode(qrContainer, {
            text: text,
            width: 300,
            height: 300,
            correctLevel: QRCode.CorrectLevel.H
        });

        scannedTextDisplay.textContent = text;
        dataDisplayWrapper.style.display = 'block';
        reprintBtn.style.display = 'inline-block';

        setTimeout(() => {
            window.print();
            input.focus();    
        }, 250);

        delete window.pendingText;
        delete window.pendingRma;
    });

    happyReturnNoBtn.addEventListener('click', function() {
        happyReturnQuestionContainer.style.display = 'none';
        delete window.pendingText;
        delete window.pendingRma;
        input.focus();
    });

    packingYesBtn.addEventListener('click', function() {
        const text = window.pendingText;
        const rmaNumber = window.pendingRma;
        if (!text) return;

        packingQuestionContainer.style.display = 'none';

        if (rmaNumber) {
            alertBadge.style.display = 'block';
            alertBadge.textContent = `Amazon QR Detected! RMA Copied: ${rmaNumber}`;
            navigator.clipboard.writeText(rmaNumber).catch(err => {});
        }

        printHeader.textContent = "Customer Packed";
        printHeader.style.display = "block";

        new QRCode(qrContainer, {
            text: text,
            width: 300,
            height: 300,
            correctLevel: QRCode.CorrectLevel.H
        });

        scannedTextDisplay.textContent = text;
        dataDisplayWrapper.style.display = 'block';
        reprintBtn.style.display = 'inline-block';

        setTimeout(() => {
            window.print();
            input.focus();    
        }, 250);

        delete window.pendingText;
        delete window.pendingRma;
    });

    packingNoBtn.addEventListener('click', function() {
        packingQuestionContainer.style.display = 'none';
        errorMessageContainer.style.backgroundColor = '#f8d7da'; 
        errorMessageContainer.style.border = '2px solid #f5c6cb'; 
        errorMessageContainer.style.color = '#721c24';
        errorMessageContainer.innerHTML = '<span style="color: #dc3545;">NOTICE</span><br>Please charge customer for appropriate packing materials.';
        errorMessageContainer.style.display = 'block';

        delete window.pendingText;
        delete window.pendingRma;
        input.focus();
    });

    reprintBtn.addEventListener('click', function() {
        window.print();
        input.focus();
    });

    overrideBtn.addEventListener('click', function() {
        const textToPrint = window.lastRejectedText;
        if (!textToPrint) return;

        qrContainer.innerHTML = '';
        printHeader.textContent = '';
        printHeader.style.display = 'none';

        new QRCode(qrContainer, {
            text: textToPrint,
            width: 300,
            height: 300,
            correctLevel: QRCode.CorrectLevel.H
        });

        scannedTextDisplay.textContent = textToPrint;
        dataDisplayWrapper.style.display = 'block';

        errorMessageContainer.style.display = 'none';
        overrideBtn.style.display = 'none';
        reprintBtn.style.display = 'inline-block';

        setTimeout(() => {
            window.print();
            input.focus(); 
        }, 250);

        delete window.lastRejectedText;
    });

    copyRawBtn.addEventListener('click', function() {
        const textToCopy = scannedTextDisplay.textContent;
        if (!textToCopy) return;

        navigator.clipboard.writeText(textToCopy).then(() => {
            const originalText = copyRawBtn.textContent;
            copyRawBtn.textContent = 'Copied!';
            copyRawBtn.style.backgroundColor = '#28a745';
            copyRawBtn.style.color = '#ffffff';
            copyRawBtn.style.borderColor = '#28a745';

            setTimeout(() => {
                copyRawBtn.textContent = originalText;
                copyRawBtn.style.backgroundColor = '#ffffff';
                copyRawBtn.style.color = '#495057';
                copyRawBtn.style.borderColor = '#ced4da';
            }, 1200);
        }).catch(err => {
            console.error('Manual fallback backup extraction loop failed: ', err);
        });
    });
</script>

</body>
</html>
'@

Set-Content -Path "$installPath\app.html" -Value $htmlContent -Encoding UTF8

# 3. Generate the application shortcut on the Windows desktop programmatically
Write-Host "Injecting desktop application shortcut..."
$desktopPath = [Environment]::GetFolderPath("Desktop")
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$desktopPath\Amazon QR Code Scanner.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Shortcut.Arguments = "--app=file:///C:/PostalAnnex-Scanner/app.html"
$Shortcut.IconLocation = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,0"
$Shortcut.Save()

# 4. Generate the application shortcut inside the Windows Start Menu Programs folder
Write-Host "Injecting Start Menu search shortcut..."
$startMenuPath = [Environment]::GetFolderPath("Programs")
$ShortcutSM = $WshShell.CreateShortcut("$startMenuPath\Amazon QR Code Scanner.lnk")
$ShortcutSM.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$ShortcutSM.Arguments = "--app=file:///C:/PostalAnnex-Scanner/app.html"
$ShortcutSM.IconLocation = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe,0"
$ShortcutSM.Save()

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "SUCCESS: Installation Complete! " -ForegroundColor Green
Write-Host "App available on Desktop and searchable as 'Amazon QR Code Scanner'." -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit..."