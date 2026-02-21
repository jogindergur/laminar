import re, sys

svg_path = "M130.6,51.3c-1-0.2-6-1-11.9-1s-10.9,0.8-11.9,1c-0.6,0.1-0.8-0.5-0.4-0.8s12.3-9.4,12.3-9.4s11.9,9.1,12.3,9.4C131.4,50.8,131.2,51.4,130.6,51.3 M110,110.1c0,0-0.6,0.2-0.8,0.8c2.5,1.9,4.2,6.3,9.4,6.3s6.9-4.4,9.4-6.3c-0.2-0.6-0.8-0.8-0.8-0.8s-3.3,0.8-8.6,0.8S110,110.1,110,110.1 M118.6,102.8c-1.4,0-1.8-0.5-2.7-0.5s-2.8,0.8-3.2,1.4c0,0.3,0.2,0.6,0.4,0.9c2.1,0.3,3.1,1.5,5.5,1.5s3.4-1.2,5.5-1.5c0.3-0.3,0.4-0.6,0.4-0.9c-0.4-0.7-2.2-1.4-3.2-1.4C120.4,102.2,120.1,102.8,118.6,102.8"

# Fix token parsing: separate numbers properly
d = svg_path.strip().replace(',', ' ')
# Separate implicit minus-sign tokens
d = re.sub(r'([0-9])-', r'\1 -', d)
# Tokenise
tokens = re.findall(r'[MmCcSsLlZzHhVvAa]|[-+]?(?:\d+\.?\d*|\.\d+)', d)

VBW, VBH = 237.4, 240.3

def sc(v, isy=False):
    return round(v / (VBH if isy else VBW), 6)

lines = []
cx, cy = 0.0, 0.0
lcp2x, lcp2y = 0.0, 0.0
cmd = 'M'
i = 0

def num(j): return float(tokens[j])

MAX = 5000  # guard
iters = 0
while i < len(tokens) and iters < MAX:
    iters += 1
    t = tokens[i]
    if t[0].isalpha():
        cmd = t; i += 1; continue

    if cmd == 'M':
        cx, cy = num(i), num(i+1); i += 2
        lines.append(f"p.moveTo({sc(cx)}, {sc(cy,True)});")
        cmd = 'L'
    elif cmd == 'm':
        cx += num(i); cy += num(i+1); i += 2
        lines.append(f"p.moveTo({sc(cx)}, {sc(cy,True)});")
        cmd = 'l'
    elif cmd == 'L':
        cx, cy = num(i), num(i+1); i += 2
        lines.append(f"p.lineTo({sc(cx)}, {sc(cy,True)});")
    elif cmd == 'l':
        cx += num(i); cy += num(i+1); i += 2
        lines.append(f"p.lineTo({sc(cx)}, {sc(cy,True)});")
    elif cmd == 'C':
        x1,y1 = num(i),num(i+1); x2,y2 = num(i+2),num(i+3)
        cx,cy = num(i+4),num(i+5); i += 6; lcp2x,lcp2y = x2,y2
        lines.append(f"p.cubicTo({sc(x1)},{sc(y1,True)},{sc(x2)},{sc(y2,True)},{sc(cx)},{sc(cy,True)});")
    elif cmd == 'c':
        x1,y1 = cx+num(i),cy+num(i+1); x2,y2 = cx+num(i+2),cy+num(i+3)
        ex,ey = cx+num(i+4),cy+num(i+5); i += 6
        lcp2x,lcp2y = x2,y2; cx,cy = ex,ey
        lines.append(f"p.cubicTo({sc(x1)},{sc(y1,True)},{sc(x2)},{sc(y2,True)},{sc(cx)},{sc(cy,True)});")
    elif cmd == 'S':
        rx1,ry1 = 2*cx-lcp2x,2*cy-lcp2y
        x2,y2 = num(i),num(i+1); cx,cy = num(i+2),num(i+3); i += 4; lcp2x,lcp2y = x2,y2
        lines.append(f"p.cubicTo({sc(rx1)},{sc(ry1,True)},{sc(x2)},{sc(y2,True)},{sc(cx)},{sc(cy,True)});")
    elif cmd == 's':
        rx1,ry1 = 2*cx-lcp2x,2*cy-lcp2y
        x2,y2 = cx+num(i),cy+num(i+1); ex,ey = cx+num(i+2),cy+num(i+3); i += 4
        lcp2x,lcp2y = x2,y2; cx,cy = ex,ey
        lines.append(f"p.cubicTo({sc(rx1)},{sc(ry1,True)},{sc(x2)},{sc(y2,True)},{sc(cx)},{sc(cy,True)});")
    elif cmd in ('Z','z'):
        lines.append("p.close();")
        # don't advance i — the outer loop already moved past the Z token
        i += 0
        # peek: if next is not a letter, that means implicit lineTo after Z,
        # which is unusual; just continue
    else:
        i += 1

print('\n'.join(lines))
print(f"\n// Total ops: {len(lines)}", file=sys.stderr)
