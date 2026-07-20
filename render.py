from PIL import Image, ImageDraw, ImageFont
import base64, os

FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf', 17)
BOLD = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf', 17)
CW = FONT.getlength('M')
LH = 20
BG = '#0C0C0C'
C = {
    'Gray': '#CCCCCC', 'DarkGray': '#767676', 'Cyan': '#61D6D6', 'DarkCyan': '#3A96DD',
    'Yellow': '#F9F1A5', 'DarkYellow': '#C19C00', 'Red': '#E74856', 'Green': '#16C60C',
    'DarkGreen': '#13A10E', 'Magenta': '#B4009E', 'White': '#F2F2F2', 'Black': '#0C0C0C',
}

SHADOW_D = '4paI4paI4paI4paI4paI4paI4pWXICDilojilojilojilojilojilojilZcgIOKWiOKWiOKWiOKWiOKWiOKWiOKVlwrilojilojilZTilZDilZDilojilojilZfilojilojilZTilZDilZDilZDilojilojilZfilojilojilZTilZDilZDilZDilZDilZ0K4paI4paI4pWRICDilojilojilZHilojilojilZEgICDilojilojilZHilojilojilZEgICAgIArilojilojilZEgIOKWiOKWiOKVkeKWiOKWiOKVkSAgIOKWiOKWiOKVkeKWiOKWiOKVkSAgICAgCuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKVmuKWiOKWiOKWiOKWiOKWiOKWiOKVlwrilZrilZDilZDilZDilZDilZDilZ0gIOKVmuKVkOKVkOKVkOKVkOKVkOKVnSAg4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWd'
SHADOW_W = '4paI4paI4pWXICAgIOKWiOKWiOKVl+KWiOKWiOKVl+KWiOKWiOKWiOKWiOKWiOKWiOKWiOKVlyDilojilojilojilojilojilZcg4paI4paI4paI4paI4paI4paI4pWXIOKWiOKWiOKWiOKWiOKWiOKWiOKVlyAK4paI4paI4pWRICAgIOKWiOKWiOKVkeKWiOKWiOKVkeKVmuKVkOKVkOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVlOKVkOKVkOKWiOKWiOKVlwrilojilojilZEg4paI4pWXIOKWiOKWiOKVkeKWiOKWiOKVkSAg4paI4paI4paI4pWU4pWdIOKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkSAg4paI4paI4pWRCuKWiOKWiOKVkeKWiOKWiOKWiOKVl+KWiOKWiOKVkeKWiOKWiOKVkSDilojilojilojilZTilZ0gIOKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVkeKWiOKWiOKVlOKVkOKVkOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWRCuKVmuKWiOKWiOKWiOKVlOKWiOKWiOKWiOKVlOKVneKWiOKWiOKVkeKWiOKWiOKWiOKWiOKWiOKWiOKWiOKVl+KWiOKWiOKVkSAg4paI4paI4pWR4paI4paI4pWRICDilojilojilZHilojilojilojilojilojilojilZTilZ0KIOKVmuKVkOKVkOKVneKVmuKVkOKVkOKVnSDilZrilZDilZ3ilZrilZDilZDilZDilZDilZDilZDilZ3ilZrilZDilZ0gIOKVmuKVkOKVneKVmuKVkOKVnSAg4pWa4pWQ4pWd4pWa4pWQ4pWQ4pWQ4pWQ4pWQ4pWdIA=='

def banner():
    d = base64.b64decode(SHADOW_D).decode('utf-8').split('\n')
    w = base64.b64decode(SHADOW_W).decode('utf-8').split('\n')
    return [[('  ' + d[i], 'Cyan'), (' ' + w[i], 'Yellow')] for i in range(len(d))]

BAR = '  ' + '═' * 68
LIGHT = '  ' + '─' * 68

def header(version='1.0.0'):
    rows = [[('', 'Gray')], [(BAR, 'Magenta')], [('', 'Gray')]]
    rows += banner()
    rows += [[('', 'Gray')],
             [('         Version %s  |  by Engin Sarak' % version, 'Red')],
             [(BAR, 'Magenta')]]
    return rows

def render(rows, path, width=None, title='DOC WIZARD'):
    cols = max(sum(len(seg[0]) for seg in r) for r in rows) if rows else 40
    cols = max(cols, width or 0, 76) + 4
    W = int(cols * CW) + 24
    TB = 38
    H = TB + int(len(rows) * LH) + 26
    img = Image.new('RGB', (W, H), BG)
    dr = ImageDraw.Draw(img)
    dr.rectangle([0, 0, W, TB], fill='#2B2B2B')
    dr.rectangle([8, 6, 8 + int(CW * 16), TB - 4], fill='#0C0C0C')
    dr.text((20, 11), title, font=FONT, fill='#DDDDDD')
    y = TB + 10
    for row in rows:
        x = 12
        for seg in row:
            text, col = seg[0], seg[1]
            bg = seg[2] if len(seg) > 2 else None
            w = FONT.getlength(text)
            if bg:
                dr.rectangle([x - 1, y - 3, x + w + 1, y + LH - 5], fill=C[bg])
            dr.text((x, y), text, font=FONT, fill=C[col])
            x += w
        y += LH
    img.save(path)
    print('->', path, img.size)
