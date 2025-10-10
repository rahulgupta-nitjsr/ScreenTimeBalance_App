#!/usr/bin/env python3
from PIL import Image, ImageFilter
import os
import sys

SRC_DIR = os.path.join('Public', 'screenshots', 'Android')
FILES = None

OUT_NAME = 'ZenScreen-User-flow.gif'
OUT_PATH = os.path.join(SRC_DIR, OUT_NAME)

# Transition settings
ENABLE_TRANSITIONS = True  # Set to False to disable transitions
TRANSITION_FRAMES = 20  # Number of frames for each transition (more = smoother)
HOLD_DURATION = 2000  # ms to display each static image (2 seconds)
TRANSITION_FRAME_DURATION = 40  # ms per transition frame (800ms total = 20 frames * 40ms)
USE_BLUR_PADDING = False  # Use adaptive blur background for size inconsistencies

def create_blur_padded_image(img, target_width, target_height):
    """
    Create a padded image with blurred background when image is smaller than target.
    If image is larger, it will be resized to fit within target dimensions.
    """
    img_w, img_h = img.size
    
    # If image is already the target size, return as-is
    if img_w == target_width and img_h == target_height:
        return img
    
    # Calculate scaling to fit within target dimensions while maintaining aspect ratio
    scale = min(target_width / img_w, target_height / img_h)
    
    # If image is larger, scale it down
    if scale < 1:
        new_w = int(img_w * scale)
        new_h = int(img_h * scale)
        img = img.resize((new_w, new_h), Image.LANCZOS)
        img_w, img_h = new_w, new_h
    
    # Create blurred background
    # Scale image to fill the target canvas (may crop)
    bg_scale = max(target_width / img_w, target_height / img_h)
    bg_w = int(img_w * bg_scale)
    bg_h = int(img_h * bg_scale)
    background = img.resize((bg_w, bg_h), Image.LANCZOS)
    
    # Crop to target size (center crop)
    left = (bg_w - target_width) // 2
    top = (bg_h - target_height) // 2
    background = background.crop((left, top, left + target_width, top + target_height))
    
    # Apply heavy blur and slight darkening for aesthetic
    background = background.filter(ImageFilter.GaussianBlur(radius=30))
    # Darken the background slightly
    background = Image.blend(background, Image.new('RGBA', background.size, (0, 0, 0, 100)), 0.3)
    
    # Center the original image on the blurred background
    x = (target_width - img_w) // 2
    y = (target_height - img_h) // 2
    background.paste(img, (x, y), img if img.mode == 'RGBA' else None)
    
    return background

def ease_in_out(t):
    """
    Easing function for smoother transitions.
    Uses smoothstep interpolation for natural acceleration/deceleration.
    """
    return t * t * (3 - 2 * t)

def create_transition_frames(img1, img2, num_frames):
    """Create smooth crossfade transition frames between two images with easing."""
    transition_frames = []
    for i in range(1, num_frames + 1):
        # Calculate blend ratio (0.0 = full img1, 1.0 = full img2)
        linear_alpha = i / (num_frames + 1)
        # Apply easing for smoother, more natural transitions
        alpha = ease_in_out(linear_alpha)
        # Blend the two images
        blended = Image.blend(img1, img2, alpha)
        transition_frames.append(blended)
    return transition_frames

def main():
    if not os.path.isdir(SRC_DIR):
        print('Source folder not found:', SRC_DIR)
        sys.exit(1)

    # If FILES is None, auto-discover PNG/JPG files and sort by numeric prefix
    if FILES is None:
        entries = [f for f in os.listdir(SRC_DIR) if f.lower().endswith(('.png', '.jpg', '.jpeg', '.webp'))]

        def sort_key(name):
            # extract leading numbers like '3.1' or '5' -> tuple (3,1) for correct ordering
            base = name.split('.')[0]
            parts = base.split('-')[0]  # get leading numeric prefix before hyphen
            nums = []
            for token in parts.replace('_', '.').split('.'):
                try:
                    nums.append(int(token))
                except Exception:
                    nums.append(0)
            return nums, name

        entries.sort(key=sort_key)
        files_to_use = entries
    else:
        files_to_use = FILES

    imgs = []
    for f in files_to_use:
        p = os.path.join(SRC_DIR, f)
        if not os.path.exists(p):
            print('Missing file:', p)
            sys.exit(1)
        imgs.append(Image.open(p).convert('RGBA'))

    # Normalize image sizes
    if USE_BLUR_PADDING:
        # Use largest dimensions and pad smaller images with blur
        max_w = max(i.width for i in imgs)
        max_h = max(i.height for i in imgs)
        print(f'Normalizing to {max_w}x{max_h} with blur padding...')
        imgs_resized = [create_blur_padded_image(i, max_w, max_h) for i in imgs]
    else:
        # Use smallest dimensions and resize all images
        min_w = min(i.width for i in imgs)
        min_h = min(i.height for i in imgs)
        print(f'Resizing all images to {min_w}x{min_h}...')
        imgs_resized = [i.resize((min_w, min_h), Image.LANCZOS) for i in imgs]

    # Build final frame sequence with or without transitions
    if ENABLE_TRANSITIONS and len(imgs_resized) > 1:
        final_frames = []
        durations = []
        
        for i in range(len(imgs_resized)):
            # Add the static image
            final_frames.append(imgs_resized[i])
            durations.append(HOLD_DURATION)
            
            # Add transition frames (except after the last image)
            if i < len(imgs_resized) - 1:
                transition_frames = create_transition_frames(
                    imgs_resized[i], 
                    imgs_resized[i + 1], 
                    TRANSITION_FRAMES
                )
                final_frames.extend(transition_frames)
                durations.extend([TRANSITION_FRAME_DURATION] * len(transition_frames))
        
        print(f'Creating GIF with {len(final_frames)} frames (including {TRANSITION_FRAMES} transition frames between each screen)...')
    else:
        final_frames = imgs_resized
        durations = [HOLD_DURATION] * len(imgs_resized)
        print(f'Creating GIF with {len(final_frames)} frames (no transitions)...')
    
    # Save the GIF
    final_frames[0].save(
        OUT_PATH, 
        save_all=True, 
        append_images=final_frames[1:], 
        optimize=False, 
        duration=durations, 
        loop=0,
        disposal=2  # Clear frame before next one
    )
    print(f'GIF written to {OUT_PATH}')

if __name__ == '__main__':
    main()


