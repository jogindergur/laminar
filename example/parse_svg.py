import re

svg_path = "M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76.5 0-103.7 40.8-165.9 40.8s-105.6-57-155.5-127C46.7 790.7 0 663 0 541.8c0-194.4 126.4-297.5 250.8-297.5 66.1 0 121.2 43.4 162.7 43.4 39.5 0 101.1-46 176.3-46 28.5 0 130.9 2.6 198.3 99.2zm-234-181.5c31.1-36.9 53.1-88.1 53.1-139.3 0-7.1-.6-14.3-1.9-20.1-50.6 1.9-110.8 33.7-147.1 75.8-28.5 32.4-55.1 83.6-55.1 135.5 0 7.8 1.3 15.6 1.9 18.1 3.2.6 8.4 1.3 13.6 1.3 45.4 0 102.5-30.4 135.5-71.3z"

# Fix implicit spaces before minus signs and decimal points where necessary
svg_path = re.sub(r'([0-9])-', r'\1 -', svg_path)
svg_path = re.sub(r'\.([0-9]*)\.', r'.\1 .', svg_path)

tokens = re.findall(r'[A-Za-z]|[-+]?[0-9]*\.?[0-9]+', svg_path)

print("Path path = Path();")
x, y = 0.0, 0.0
last_cmd = ''
last_ctrl_x, last_ctrl_y = 0.0, 0.0

i = 0
min_x = 1000000; min_y = 1000000; max_x = -1000000; max_y = -1000000
while i < len(tokens):
    cmd = tokens[i]
    if ord(cmd[0].upper()) >= ord('A'):
        i += 1
    else:
        cmd = last_cmd

    if cmd == 'M':
        x = float(tokens[i])
        y = float(tokens[i+1])
        print(f"path.moveTo({x:.2f}, {y:.2f});")
        i += 2
        last_ctrl_x, last_ctrl_y = x, y
    elif cmd == 'm':
        x += float(tokens[i])
        y += float(tokens[i+1])
        print(f"path.moveTo({x:.2f}, {y:.2f});")
        i += 2
        last_ctrl_x, last_ctrl_y = x, y
        cmd = 'l'
        # Follow-up bounds are l
    elif cmd == 'C':
        x1, y1 = float(tokens[i]), float(tokens[i+1])
        x2, y2 = float(tokens[i+2]), float(tokens[i+3])
        x, y = float(tokens[i+4]), float(tokens[i+5])
        print(f"path.cubicTo({x1:.2f}, {y1:.2f}, {x2:.2f}, {y2:.2f}, {x:.2f}, {y:.2f});")
        i += 6
        last_ctrl_x, last_ctrl_y = x2, y2
    elif cmd == 'c':
        x1, y1 = x + float(tokens[i]), y + float(tokens[i+1])
        x2, y2 = x + float(tokens[i+2]), y + float(tokens[i+3])
        x, y = x + float(tokens[i+4]), y + float(tokens[i+5])
        print(f"path.cubicTo({x1:.2f}, {y1:.2f}, {x2:.2f}, {y2:.2f}, {x:.2f}, {y:.2f});")
        i += 6
        last_ctrl_x, last_ctrl_y = x2, y2
    elif cmd == 'S':
        x1 = x + (x - last_ctrl_x)
        y1 = y + (y - last_ctrl_y)
        x2, y2 = float(tokens[i]), float(tokens[i+1])
        x, y = float(tokens[i+2]), float(tokens[i+3])
        print(f"path.cubicTo({x1:.2f}, {y1:.2f}, {x2:.2f}, {y2:.2f}, {x:.2f}, {y:.2f});")
        i += 4
        last_ctrl_x, last_ctrl_y = x2, y2
    elif cmd == 's':
        x1 = x + (x - last_ctrl_x)
        y1 = y + (y - last_ctrl_y)
        x2, y2 = x + float(tokens[i]), y + float(tokens[i+1])
        x, y = x + float(tokens[i+2]), y + float(tokens[i+3])
        print(f"path.cubicTo({x1:.2f}, {y1:.2f}, {x2:.2f}, {y2:.2f}, {x:.2f}, {y:.2f});")
        i += 4
        last_ctrl_x, last_ctrl_y = x2, y2
    elif cmd == 'Z' or cmd == 'z':
        print(f"path.close();")
    
    last_cmd = cmd
