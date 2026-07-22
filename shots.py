from render import *

O = 'shots/'

def menu_line(text, sel=False, color='Gray'):
    if sel:
        return [('   > ' + text.ljust(58), 'Black', 'Cyan')]
    return [('     ' + text, color)]

# 1 Hauptmenue
r = header()
r += [[('', 'Gray')], [('   MAIN MENU', 'Cyan')], [('', 'Gray')]]
r += [menu_line('Auto rename/create documents', True)]
r += [menu_line('Annotate WP documents')]
r += [menu_line('Print')]
r += [menu_line('Auto move to folders')]
r += [menu_line('Settings')]
r += [[('', 'Gray')]]
r += [menu_line('Quit')]
r += [[('', 'Gray')], [('   Up/Down = move     Enter = select     Esc / Backspace = back', 'DarkGray')]]
render(r, O + '01-main-menu.png')

# 2 Rename + Groupage
r = header()
r += [[('', 'Gray')],
      [('  Custom Picking List.pdf  ->  WP004486_CUSTOMER_A_SORD26-00384.pdf', 'Green')],
      [('  Custom Picking List (1).pdf  ->  WP004487_CUSTOMER_A_SORD26-00321.pdf', 'Green')],
      [('  PAC004221.pdf  ->  PAC004221_SORD26-00384.pdf', 'Green')],
      [('', 'Gray')],
      [(LIGHT, 'DarkCyan')],
      [('   GROUPAGE detected:  CUSTOMER A   (2 pick lists)', 'Yellow')],
      [('     WP004486_CUSTOMER_A_SORD26-00384.pdf', 'DarkGray')],
      [('     WP004487_CUSTOMER_A_SORD26-00321.pdf', 'DarkGray')],
      [('', 'Gray')],
      [('   Create groupage? (Y/N): ', 'Gray'), ('y', 'White')],
      [('     marked GROUPAGE: WP004486_CUSTOMER_A_SORD26-00384.pdf', 'Green')],
      [('     marked GROUPAGE: WP004487_CUSTOMER_A_SORD26-00321.pdf', 'Green')],
      [('     created        : 2026-07-20_Groupage_CUSTOMER_A.xlsx', 'Green')],
      [('     prefilled      : customer + 2 pick number(s)', 'Green')],
      [('     please fill in the remaining fields', 'Yellow')],
      [('', 'Gray')]]
render(r, O + '02-rename-groupage.png')

# 3 Pumpen
r = header()
r += [[('', 'Gray')],
      [(LIGHT, 'DarkCyan')],
      [('   PUMPS detected:  WP004486  CUSTOMER A   (75 Compat Ella pumps)', 'Yellow')],
      [('     WP004486_CUSTOMER_A_SORD26-00384.pdf', 'DarkGray')],
      [('', 'Gray')],
      [('   Create pump list? (Y/N): ', 'Gray'), ('y', 'White')],
      [('     created        : WP004486_CUSTOMER_A_Pumpen.xlsx   (75 pumps)', 'Green')],
      [('     created        : WP004486_CUSTOMER_A_Control.xlsx   (75 serials to scan)', 'Green')],
      [('', 'Gray')],
      [(LIGHT, 'DarkCyan')],
      [('   SUMMARY', 'Cyan')],
      [('     Renamed        : 3', 'Green')],
      [('     Already ok     : 0', 'DarkGray')],
      [('     Errors         : 0', 'DarkGray')],
      [('', 'Gray')]]
render(r, O + '03-pump-list.png')

# 4 Print
r = header()
r += [[('', 'Gray')], [('   PRINTER  ->  \\\\print-srv\\WAREHOUSE-SW', 'Cyan')], [('', 'Gray')],
      [('   Delivery documents   (2 copies)', 'Yellow')],
      menu_line('PWS004221 + PAC004221   (SORD26-00384)', True),
      menu_line('PWS004222 + PAC004222   (SORD26-00321)   [printed]', False, 'DarkGray'),
      [('', 'Gray')],
      [('   Warehouse picks   (1 copy)', 'Yellow')],
      menu_line('CUSTOMER A Groupage   (2 pick lists)'),
      menu_line('WP004488_CUSTOMER_B_SORD26-00390.pdf'),
      [('', 'Gray')],
      menu_line('Back'),
      [('', 'Gray')],
      [('   Up/Down = move     Enter = select     Esc / Backspace = back', 'DarkGray')]]
render(r, O + '04-print.png')

# 5 Move
r = header()
r += [[('', 'Gray')], [('   MOVE DOCUMENTS', 'Cyan')], [('', 'Gray')],
      [('   Delivery documents   (to customer folder)', 'Yellow')],
      menu_line('PWS004221 + PAC004221   (SORD26-00384)'),
      [('', 'Gray')],
      [('   Warehouse picks   (to pick list / noch zu drucken)', 'Yellow')],
      menu_line('CUSTOMER A Groupage   (2 pick lists)  + 2 pump list(s)', True),
      menu_line('WP004488_CUSTOMER_B_SORD26-00390.pdf   + pump list'),
      [('', 'Gray')],
      [('   Pump control files   (to pump control folder)', 'Yellow')],
      menu_line('WP004486_CUSTOMER_A_Control.xlsx'),
      menu_line('WP004488_CUSTOMER_B_Control.xlsx'),
      [('', 'Gray')],
      menu_line('Back'),
      [('', 'Gray')],
      [('   Up/Down = move     Enter = select     Esc / Backspace = back', 'DarkGray')]]
render(r, O + '05-move.png')

# 6 Settings
r = header()
r += [[('', 'Gray')], [('   SETTINGS', 'Cyan')], [('', 'Gray')],
      menu_line('Downloads folder        :  C:\\Users\\user\\Downloads   (auto)', True),
      [('', 'Gray')],
      menu_line('Default printer         :  \\\\print-srv\\WAREHOUSE-SW', False, 'DarkGreen'),
      menu_line('Outbound main folder    :  P:\\...\\Ship Docs_outbound', False, 'DarkGreen'),
      menu_line('Pick list folder        :  P:\\...\\Pick lists', False, 'DarkGreen'),
      menu_line("'Noch zu drucken' folder:  P:\\...\\noch zu drucken", False, 'DarkGreen'),
      menu_line('Pump control folder     :  P:\\...\\Pump control', False, 'DarkGreen'),
      menu_line('Banner style            :  Shadow', False, 'DarkGreen'),
      [('', 'Gray')],
      menu_line('Back'),
      [('', 'Gray')],
      [('   Up/Down = move     Enter = select     Esc / Backspace = back', 'DarkGray')]]
render(r, O + '06-settings.png')

# 7 Update
r = header()
r += [[('', 'Gray')],
      [(LIGHT, 'DarkCyan')],
      [('   UPDATE AVAILABLE:   1.0.0   ->   1.1.0', 'Yellow')],
      [('', 'Gray')],
      [('     Pump control file now lists the pallet number', 'Gray')],
      [('     Faster PDF reading', 'Gray')],
      [('', 'Gray')],
      [(LIGHT, 'DarkCyan')],
      [('', 'Gray')],
      [('   Install the update now? (Y/N): ', 'Gray'), ('y', 'White')],
      [('', 'Gray')],
      [('   downloaded : _doc_wizard.ps1', 'DarkGray')],
      [('   downloaded : pumplist_template.xlsx', 'DarkGray')],
      [('', 'Gray')],
      [('   updated    : _doc_wizard.ps1', 'Green')],
      [('   updated    : pumplist_template.xlsx', 'Green')],
      [('', 'Gray')]]
render(r, O + '07-update.png')
