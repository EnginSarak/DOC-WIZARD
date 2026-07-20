# DOC WIZARD - Projektkontext

Interner Kontext für Claude Code. **Diese Datei gehört nicht ins GitHub-Repo**
(steht in `.gitignore`).

## Was das ist

Ein einzelnes PowerShell-Skript mit Terminal-UI, das den Dokumenten-Workflow im
Versand abwickelt. Genutzt von Engin Sarak und Lagerkollegen bei PROMEDIA
(Standort Luna_Axium). Läuft auf Windows mit PowerShell 5.1 und Excel.

Kein Framework, keine Abhängigkeiten, kein Build. Alles steckt in `_doc_wizard.ps1`.

## Dateien

| Datei | Rolle |
| --- | --- |
| `_doc_wizard.ps1` | das gesamte Programm (~2600 Zeilen) |
| `DOC WIZARD.bat` | Starter, ruft das ps1 mit `-ExecutionPolicy Bypass` auf |
| `reset.bat` | löscht die persönlichen Einstellungsdateien, Bestätigung per Tippen von `RESET` |
| `pumplist_template.xlsx` | Vorlage Pumpenliste, Blätter `Pump Bins` + `Lines` |
| `pump_control_template.xlsx` | Vorlage Scan-Kontrolle, Blätter `Warehouse Pick`, `Calc`, `Scan`, `Customer` |
| `groupage_template.xlsx` | Vorlage Pickübersicht |
| `update.txt` | Version + Dateiliste für den Updater (liegt auch im Repo) |
| `_doc_wizard_update.txt` | Owner/Repo/Branch der Update-Quelle |
| `_doc_wizard_settings.txt` | lokale Einstellungen, **nie** ins Repo |
| `_doc_wizard_pairs.txt`, `_doc_wizard_printed.txt` | Laufzeitzustand, nie ins Repo |

## Harte Regeln

1. **Keine Kommentare im Code.** Ausdrücklicher Wunsch des Users, gilt überall.
2. **Datei bleibt reines ASCII.** Umlaute und Sonderzeichen nur über `[char]0x00E4`
   o.ä. erzeugen. PowerShell 5.1 liest die Datei ohne BOM, alles andere wird zu Müll.
3. **Menütexte auf Englisch**, Ausgaben ebenso. Der User schreibt auf Deutsch, die UI ist englisch.
4. **Keine KI-Floskeln in Ausgaben.** Kurz und sachlich, keine Aufzählungen von
   Beispielen in Hinweistexten.
5. Nach jeder Änderung Klammern-Balance prüfen (`{`/`}` und `(`/`)` nach Entfernen
   der Strings). Es gibt hier keine Möglichkeit, PowerShell zu testen.

## PowerShell-Fallen, die schon zugeschlagen haben

- `$arr[$i + 1, 0]` wird als `$arr[$i + (1,0)]` geparst → Fehler
  „op_Addition auf Object[]". Index immer vorher in eine Variable rechnen.
- Bei Methodenaufrufen (`$ws.Cells($r + 1, 2)`) ist die Arithmetik dagegen unkritisch.
- Excel-COM: immer `ReleaseComObject` im `finally`, sonst bleibt `EXCEL.EXE` hängen.
- Heruntergeladene Dateien vor dem Öffnen `Unblock-File`, sonst greift die
  geschützte Ansicht.

## Aufbau des Skripts (Reihenfolge im File)

1. Banner-Definitionen (`$BannerStyles`, base64-kodierte ASCII-Arts, plus `Plain`)
2. Rendering: `Show-Header`, `Get-HeaderRows`, `Render-Frame`, `Show-Menu`, `Show-DocMenu`
3. Ladeanimation: `Start-Spin` / `Stop-Spin` (eigener Runspace, schreibt per `[Console]::Write`)
4. PDF-Zugriff: `Inflate`, `Get-PdfText`, `Get-PdfTjTokens`, `Get-Kunde`, `Get-DeliveryInfo`
5. Updater: `Get-UpdateInfo`, `Install-Update`, `Invoke-UpdateCheck`
6. Groupage: `Get-ActiveGroupages`, `Invoke-GroupageCheck`, `Set-GroupageData`
7. Pumpen: `Get-PumpDataFromPdf`, `New-PumpWorkbook`, `New-ControlWorkbook`, `Invoke-PumpCheck`
8. Hauptfunktionen: `Invoke-Rename`, `Invoke-Annotate`, `Invoke-Print`, `Invoke-Move`, `Invoke-Settings`
9. Hauptschleife am Dateiende (`$mainItems` + `switch`)

## Fachliche Logik

**Umbenennen:** PAC/PWS/WP + SORD aus dem PDF-Text ziehen. Schema
`WP004445_KUNDE_SORD26-00369.pdf`. Kundenname = erste zwei Wörter des Feldes
`Destination`, ohne `&`/`und`, mit `_` verbunden. Nur für Dateinamen; in Excel-Zellen
mit Leerzeichen.

**Groupage:** Zwei oder mehr WP-PDFs mit gleichem Kundenteil im Namen. Werden gestempelt,
danach entsteht `JJJJ-MM-TT_Groupage_KUNDE.xlsx`. Vorgefüllt: Kunde (B3) und die
WP-Nummern in der Tabelle ab Zeile 15. Land bleibt leer, das ist aus dem Dokument nicht
ableitbar.

**Pumpen:** Seriennummern beginnen mit `N`. Aus der Pick-List-PDF werden die
Tj-Textoperatoren in Lesereihenfolge gelesen; der zuletzt gesehene Bin (Regex
`^(PICKING|[A-Z][A-Z0-9]{0,6}\d\.\d+)$`) gehört zur folgenden Seriennummer. Zeilen mit
Bin `PICKING` sind die Gegenbuchung und fliegen raus, Dubletten ebenso.

Daraus entstehen zwei Dateien:
- `WP..._KUNDE_Pumpen.xlsx` - Serial + Bin ins Blatt `Lines`, das Blatt `Pump Bins`
  rechnet per Formel eine Pivot-Optik (Bin fett mit Anzahl, Seriennummern darunter,
  Gesamtergebnis). Titel A1 = `WP004445 KUNDE Pumpen`.
- `WP..._KUNDE_Control.xlsx` - Seriennummern in die Spalte `Serial No.` des Blatts
  `Warehouse Pick`. `Calc` holt sie per HLOOKUP, `Scan` zeigt sie über `UNIQUE`.
  Bedingte Formatierung: doppelt = grün, einzeln = rot. Der Lagerarbeiter scannt in die
  Palettenspalten.

**Verschieben:** Pick-Listen und ihre Pumpenliste wandern gemeinsam in
`Pick list folder` oder `noch zu drucken`. Control-Dateien haben einen eigenen Abschnitt
und gehen in den `Pump control folder`. Lieferdokumente laufen über die Ordnererkennung
(Kunde, Land, Monat aus dem PDF).

## Wichtig zu den Vorlagen

Die Vorlagen sind Kopien echter Arbeitsdateien. In `pump_control_template.xlsx` steckte
noch die komplette `sharedStrings`-Tabelle mit 75 Seriennummern und einem Kundennamen,
obwohl die Zellen leer waren. Ist bereinigt. **Bei jedem Austausch einer Vorlage prüfen:**

```
unzip -p vorlage.xlsx xl/sharedStrings.xml | grep -o '<t[^>]*>[^<]*' | sort -u
unzip -p vorlage.xlsx docProps/core.xml
```

Das Repo ist öffentlich.

## Updates veröffentlichen

`update.txt` und `$script:AppVersion` müssen dieselbe Versionsnummer tragen. Neue Dateien
gehören zusätzlich als `FILE=` in `update.txt`, sonst kommen sie bei den Kollegen nicht an.
Upload läuft per Drag & Drop über die GitHub-Weboberfläche, Repo `EnginSarak/DOC-WIZARD`.

## Screenshots

`docs/*.png` sind gerenderte Nachbauten der Oberfläche, keine echten Screenshots
(Kundennamen dürfen im öffentlichen Repo nicht auftauchen, deshalb `CUSTOMER A/B`).
Erzeugt mit `render.py` / `shots.py`. Wenn die UI sich ändert, dort nachziehen.
