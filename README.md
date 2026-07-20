# DOC WIZARD

A small terminal tool for the outbound document workflow: it renames the PDFs that come
out of Business Central, stamps and prints them, moves them into the right folders and
builds the Excel files that go with a pump pick.

Everything runs from one window, keyboard only. Windows, PowerShell and Excel is all
it needs.

![Main menu](docs/01-main-menu.png)

Five entries, arrow keys and Enter. That is the whole interface.

---

## Renaming and creating documents

![Rename and groupage](docs/02-rename-groupage.png)

Downloaded PDFs still have names like `Custom Picking List (1).pdf`. The tool reads each
file and renames it to the numbers it finds inside: pick number, customer, order number.

If two or more pick lists belong to the same customer, that is a groupage. The tool asks
before it does anything, stamps the PDFs and creates the groupage sheet from the template
with customer and pick numbers already filled in.

---

## Pump picks

![Pump list](docs/03-pump-list.png)

When a pick list contains COMPAT Ella pumps, the tool offers to build the two Excel files
for it. Both come straight out of the PDF, so no line list has to be downloaded:

- **Pumpen.xlsx** - every serial number grouped by bin, with counts and a total.
  Rows that are already in the PICKING bin are left out.
- **Control.xlsx** - the scan sheet for the warehouse. Serial numbers on the left,
  pallet columns on the right. A scanned number turns green, anything still red was
  missed.

---

## Printing

![Print](docs/04-print.png)

Delivery documents and warehouse picks in one list. PWS and PAC belonging together are
printed as a pair, delivery documents twice and picks once. Everything already sent is
marked, so nothing gets printed twice by accident.

---

## Moving to folders

![Move](docs/05-move.png)

Each entry moves the whole bundle: the pick list together with its pump list, a groupage
together with its sheet. Control files have their own section and go to the pump control
folder, since they are not for printing.

Delivery documents take a different route - the tool reads customer, country and date out
of the PDF and suggests the matching month folder in the outbound structure.

---

## Settings

![Settings](docs/06-settings.png)

Folders and printer are asked once on the first start and stored next to the program.
Green means set. `reset.bat` clears all of it, which is what you run before handing the
folder to someone else.

---

## Updates

![Update](docs/07-update.png)

On every start the tool checks this repository for a newer version. If there is one it
shows what changed and asks. Nothing is downloaded without that answer, and personal
settings are never touched. No internet, no message - it just starts.

---

## Install

1. `Code` -> `Download ZIP`
2. Unpack the folder anywhere
3. Start `DOC WIZARD.bat`
4. Answer the setup questions once

## Files

| File | Purpose |
| --- | --- |
| `DOC WIZARD.bat` | starts the tool |
| `_doc_wizard.ps1` | the program |
| `pumplist_template.xlsx` | template for the pump list |
| `pump_control_template.xlsx` | template for the scan control file |
| `groupage_template.xlsx` | template for the groupage sheet |
| `reset.bat` | removes all personal settings |
| `update.txt` | version and file list used by the updater |

`_doc_wizard_settings.txt`, `_doc_wizard_pairs.txt` and `_doc_wizard_printed.txt` are
created at runtime and stay on the machine.

*Customer names and numbers in the screenshots are made up.*
