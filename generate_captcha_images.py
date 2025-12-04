from PIL import Image, ImageDraw
import math

def create_outer_circle():
    size = 600
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw outer circle with gradient-like effect
    for i in range(10):
        radius = size // 2 - i * 5
        alpha = 255 - i * 20
        draw.ellipse(
            [(size//2 - radius, size//2 - radius), 
             (size//2 + radius, size//2 + radius)],
            fill=(200, 200, 200, alpha)
        )
    
    # Draw pattern segments
    center = size // 2
    for angle in range(0, 360, 30):
        rad = math.radians(angle)
        x1 = center + int(center * 0.6 * math.cos(rad))
        y1 = center + int(center * 0.6 * math.sin(rad))
        x2 = center + int(center * 0.9 * math.cos(rad))
        y2 = center + int(center * 0.9 * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=(100, 100, 100, 200), width=3)
    
    # Draw a distinctive mark at 0 degrees
    mark_angle = 0
    rad = math.radians(mark_angle)
    x = center + int(center * 0.75 * math.cos(rad))
    y = center + int(center * 0.75 * math.sin(rad))
    draw.ellipse([(x-15, y-15), (x+15, y+15)], fill=(255, 100, 100, 255))
    
    img.save('assets/outer_circle.png')
    print('Created outer_circle.png')

def create_inner_circle():
    size = 600
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw inner circle
    radius = size // 3
    draw.ellipse(
        [(size//2 - radius, size//2 - radius), 
         (size//2 + radius, size//2 + radius)],
        fill=(150, 180, 220, 255)
    )
    
    # Draw pattern
    center = size // 2
    for angle in range(0, 360, 45):
        rad = math.radians(angle)
        x1 = center
        y1 = center
        x2 = center + int(radius * 0.8 * math.cos(rad))
        y2 = center + int(radius * 0.8 * math.sin(rad))
        draw.line([(x1, y1), (x2, y2)], fill=(80, 120, 180, 255), width=4)
    
    # Draw a distinctive mark at 0 degrees to match outer circle
    mark_angle = 0
    rad = math.radians(mark_angle)
    x = center + int(radius * 0.6 * math.cos(rad))
    y = center + int(radius * 0.6 * math.sin(rad))
    draw.ellipse([(x-12, y-12), (x+12, y+12)], fill=(255, 100, 100, 255))
    
    img.save('assets/inner_circle.png')
    print('Created inner_circle.png')

if __name__ == '__main__':
    import os
    os.makedirs('assets', exist_ok=True)
    create_outer_circle()
    create_inner_circle()
    print('Done! Images created in assets folder')
