from PIL import Image, ImageDraw, ImageFont
import base64, os

FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf', 17)
BOLD = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf', 17)
CW = FONT.getlength('M')
LH = 20
BG = '#0C0C0C'

_ICON_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'promedia_copilot.ico')
ICON = Image.open(_ICON_PATH).convert('RGBA').resize((20, 20), Image.LANCZOS) if os.path.exists(_ICON_PATH) else None
C = {
    'Gray': '#CCCCCC', 'DarkGray': '#767676', 'Cyan': '#61D6D6', 'DarkCyan': '#3A96DD',
    'Yellow': '#F9F1A5', 'DarkYellow': '#C19C00', 'Red': '#E74856', 'Green': '#16C60C',
    'DarkGreen': '#13A10E', 'Magenta': '#B4009E', 'White': '#F2F2F2', 'Black': '#0C0C0C',
    'Blue': '#3B78FF', 'DarkBlue': '#0037DA', 'DarkRed': '#C50F1F', 'DarkMagenta': '#881798',
}

SHADOW_D = 'IF9fX18gIF9fX18gICBfX18gIF9fICBfXyBfX19fXyBfX19fIF9fXyAgICBfICAgIAp8ICBfIFx8ICBfIFwgLyBfIFx8ICBcLyAgfCBfX19ffCAgXyBcXyBffCAgLyBcICAgCnwgfF8pIHwgfF8pIHwgfCB8IHwgfFwvfCB8ICBffCB8IHwgfCB8IHwgIC8gXyBcICAKfCAgX18vfCAgXyA8fCB8X3wgfCB8ICB8IHwgfF9fX3wgfF98IHwgfCAvIF9fXyBcIAp8X3wgICB8X3wgXF9cXF9fXy98X3wgIHxffF9fX19ffF9fX18vX19fL18vICAgXF9c'
SHADOW_W = 'ICBfX19fIF9fXyAgX19fXyBfX18gXyAgICAgX19fIF9fX19fIAogLyBfX18vIF8gXHwgIF8gXF8gX3wgfCAgIC8gXyBcXyAgIF98CnwgfCAgfCB8IHwgfCB8XykgfCB8fCB8ICB8IHwgfCB8fCB8ICAKfCB8X198IHxffCB8ICBfXy98IHx8IHxfX3wgfF98IHx8IHwgIAogXF9fX19cX19fL3xffCAgfF9fX3xfX19fX1xfX18vIHxffCAg'

def banner():
    d = base64.b64decode(SHADOW_D).decode('utf-8').split('\n')
    w = base64.b64decode(SHADOW_W).decode('utf-8').split('\n')
    return [[('  ' + d[i], 'White'), ('   ' + w[i], 'White')] for i in range(len(d))]

BAR = '  ' + '═' * 118
LIGHT = '  ' + '─' * 68

def header(version='1.0.0'):
    rows = [[('', 'Gray')], [(BAR, 'Red')], [('', 'Gray')]]
    rows += banner()
    rows += [[('', 'Gray')],
             [('         Version %s  |  by Engin Sarak' % version, 'Blue')],
             [(BAR, 'Red')]]
    return rows

def render(rows, path, width=None, title='PROMEDIA COPILOT'):
    cols = max(sum(len(seg[0]) for seg in r) for r in rows) if rows else 40
    cols = max(cols, width or 0, 76) + 4
    W = int(cols * CW) + 24
    TB = 38
    H = TB + int(len(rows) * LH) + 26
    img = Image.new('RGB', (W, H), BG)
    dr = ImageDraw.Draw(img)
    dr.rectangle([0, 0, W, TB], fill='#2B2B2B')
    dr.rectangle([8, 6, 8 + int(CW * 16), TB - 4], fill='#0C0C0C')
    text_x = 20
    if ICON:
        img.paste(ICON, (14, (TB - ICON.height) // 2), ICON)
        text_x = 14 + ICON.width + 8
    dr.text((text_x, 11), title, font=FONT, fill='#DDDDDD')
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
