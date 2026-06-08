import math
from PIL import Image, ImageDraw

PATH_TO_SCRIPT: str = "dev_sandbox/just_auto_attack"


def create_blank_atlas() -> Image.Image:
    return Image.new("RGBA", (256, 256), (0))


def get_texture(filename: str, default_color: tuple) -> Image.Image:
    """Loads texture or returns a solid-color placeholder."""
    try:
        return Image.open(filename).convert("RGBA").resize((128, 128))
    except FileNotFoundError:
        return Image.new("RGBA", (128, 128), default_color)  # type: ignore


def create_cube_atlas() -> None:
    cube_atlas = create_blank_atlas()
    top = get_texture("top.png", (255, 0, 0, 255))
    side = get_texture("side.png", (0, 0, 255, 255))
    bottom = get_texture("bottom.png", (0, 255, 0, 255))

    cube_atlas.paste(top, (0, 0))  # Top(R)
    cube_atlas.paste(side, (128, 0))  # Side(B)
    cube_atlas.paste(bottom, (0, 128))  # Bottom(G)

    cube_atlas.save(f"{PATH_TO_SCRIPT}/rgb_atlas.png")
    print("Generated: rgb_atlas.png")


def create_hexagon_atlas() -> None:
    atlas = Image.new("RGBA", (512, 512), (0))
    draw = ImageDraw.Draw(atlas)

    # Square centered at 256, 256 (64x64)
    draw.rectangle([224, 224, 288, 288], fill=(0, 255, 0, 255))

    R = 64
    apo = R * math.sqrt(3) / 2
    cx, cy = 256, 256

    # 1. Top Hex (Centered above the square)
    # Relative center: (256, 256 - 64 - apo)
    t_cy = 256 - 32 - apo
    top_hex = [
        (cx - R, t_cy),
        (cx - R / 2, t_cy - apo),
        (cx + R / 2, t_cy - apo),
        (cx + R, t_cy),
        (cx + R / 2, t_cy + apo),
        (cx - R / 2, t_cy + apo),
    ]
    draw.polygon(top_hex, fill=(255, 0, 0, 255))

    # 2. Bottom Hex (Centered below the square)
    # Relative center: (256, 256 + 64 + apo)
    b_cy = 256 + 32 + apo
    bottom_hex = [
        (cx - R, b_cy),
        (cx - R / 2, b_cy - apo),
        (cx + R / 2, b_cy - apo),
        (cx + R, b_cy),
        (cx + R / 2, b_cy + apo),
        (cx - R / 2, b_cy + apo),
    ]
    draw.polygon(bottom_hex, fill=(0, 0, 255, 255))

    atlas.save(f"{PATH_TO_SCRIPT}/hex.png")
    print("Generated: hex.png")


if __name__ == "__main__":
    create_cube_atlas()
    create_hexagon_atlas()
