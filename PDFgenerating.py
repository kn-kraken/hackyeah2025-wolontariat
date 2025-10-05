from reportlab.pdfgen import canvas
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import json
import sys
import os
# we know some glyphs are missing, suppress warnings
# import reportlab.rl_config
# reportlab.rl_config.warnOnMissingFontGlyphs = 0

if len(sys.argv) < 2:
    print("Użycie: python program.py dane.json")
    sys.exit(1)

json_file = sys.argv[1]


font = "DejaVuSans"
bold_font = "DejaVuSansBd"

pdfmetrics.registerFont(TTFont(bold_font, 'DejaVuSans-Bold.ttf'))
pdfmetrics.registerFont(TTFont(font, 'DejaVuSans.ttf'))

margin = inch
pagesize = (595.27,841.89)
title_font_size = 12
text_font_size = 11
line_height = 20
max_width = pagesize[0] - margin
line_separation = 20
indent = margin / 2

def create_certificate(c, volunteer, organiser, date, event, tasks):
    c.translate(0, pagesize[1])

    
    c.setFont(bold_font, text_font_size)
    c.drawString(max_width - c.stringWidth(date, font, text_font_size), -margin - indent, date)
    c.setFont(bold_font, title_font_size)
    c.drawString(1.5*margin, -2*margin, u"ZAŚWIADCZENIE O ODBYTYM WOLONTARIACIE")
    c.setFont(font, title_font_size)
    next_line_y = wrapped_text(c, u'Zaświadcza się, że  {} w dniu {} odbył(a) wolontariat na rzecz {} przy wydarzeniu "{}"".'.format(volunteer, date, organiser, event), margin, -2.5*inch, max_width, line_height)
    next_line_y = wrapped_text(c, "Wykonane zadania obejmowały: ", margin, next_line_y, max_width, line_height)
    for task in tasks:
        next_line_y = wrapped_text(c, f" • {task}", margin + indent, next_line_y, max_width, line_height )

def wrapped_text(c, text, x, y, max_width, line_height):
    words = text.split()
    lines = []
    current_line = "    "
    
    for word in words:
        test_line = current_line + word + " "
        if c.stringWidth(test_line, font, text_font_size) + x <= max_width:
            current_line = test_line
        else:
            lines.append(current_line)
            current_line = word + " "
    lines.append(current_line)

    
    for line in lines:
        c.drawString(x, y, line)
        y -= line_height 
    x += c.stringWidth(lines[-1], bold_font, text_font_size)
    y -= line_separation
    return y


if __name__ == "__main__":
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    id = 0
    while os.path.exists(f"./certificates/zaswiadczenie_{id}.pdf"):
        id += 1
    c = canvas.Canvas(f"./certificates/zaswiadczenie_{id}.pdf")
    create_certificates(c, data['volunteer'], data["organizer"], data["date"], data["event"], data["tasks"])
    c.save()