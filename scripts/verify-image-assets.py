#!/usr/bin/env python3
"""Check the quiz bitmap assets before shipping.

Source catalog only:
    python3 scripts/verify-image-assets.py

Source and an unthinned Release/archive catalog (all three scales required):
    python3 scripts/verify-image-assets.py "/path/to/Qui es tu.app/Assets.car"

Source and a device-thinned catalog (repeat --scale if needed):
    python3 scripts/verify-image-assets.py /path/to/Assets.car --scale 3

Uses only Python's standard library; compiled catalogs also require Xcode's
`xcrun assetutil`. An explicit scale is required for each source bitmap slot.
This guards our packaging contract, not an assumption that thinning always
removes images when a requested scale is absent.
"""

import argparse
import json
from pathlib import Path
import subprocess
import sys
import unicodedata


REPOSITORY = Path(__file__).resolve().parents[1]
CATALOG = REPOSITORY / "Qui es tu/Supporting Files/Assets.xcassets"
BITMAP_EXTENSIONS = {".png", ".jpg", ".jpeg", ".heic", ".heif", ".tif", ".tiff"}
SCALES = {"1x", "2x", "3x"}


def canonical_name(name):
    return unicodedata.normalize("NFC", name)


def read_json(path, errors):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as error:
        errors.append(f"{path.relative_to(REPOSITORY)}: {error}")
        return None


def asset_name(image_set, errors):
    components = [image_set.stem]
    for parent in image_set.parents:
        if parent == CATALOG:
            break
        metadata_path = parent / "Contents.json"
        if metadata_path.exists():
            metadata = read_json(metadata_path, errors)
            if isinstance(metadata, dict) and metadata.get("properties", {}).get("provides-namespace"):
                components.insert(0, parent.name)
    return canonical_name("/".join(components))


def verify_source(errors):
    expected_names = set()
    image_sets = sorted(CATALOG.rglob("*.imageset"))
    if not image_sets:
        errors.append(f"No image sets found in {CATALOG}")
        return expected_names

    for image_set in image_sets:
        label = str(image_set.relative_to(REPOSITORY))
        metadata = read_json(image_set / "Contents.json", errors)
        if not isinstance(metadata, dict) or not isinstance(metadata.get("images"), list):
            errors.append(f"{label}: expected an images array")
            continue

        bitmap_entries = []
        for entry in metadata["images"]:
            if not isinstance(entry, dict):
                errors.append(f"{label}: image entry must be an object")
                continue
            filename = entry.get("filename")
            if not filename:
                continue
            if not isinstance(filename, str):
                errors.append(f"{label}: filename must be a string")
                continue
            if not (image_set / filename).is_file():
                errors.append(f"{label}: missing referenced file {filename!r}")
            if Path(filename).suffix.lower() in BITMAP_EXTENSIONS:
                bitmap_entries.append(entry)

        if not bitmap_entries:
            continue

        name = asset_name(image_set, errors)
        if name in expected_names:
            errors.append(f"Duplicate asset name: {name!r}")
        expected_names.add(name)
        provided_scales = set()
        for entry in bitmap_entries:
            scale = entry.get("scale")
            if scale not in SCALES:
                errors.append(f"{label}: {entry['filename']!r} has no valid explicit scale")
            else:
                provided_scales.add(scale)
        missing_scales = SCALES - provided_scales
        if missing_scales:
            errors.append(f"{label}: missing populated bitmap scales {', '.join(sorted(missing_scales))}")

    if not expected_names:
        errors.append("No bitmap image assets found")
    return expected_names


def verify_compiled(path, scales, expected_names, errors):
    try:
        result = subprocess.run(
            ["xcrun", "assetutil", "--info", str(path)],
            check=True, capture_output=True, text=True,
        )
        renditions = json.loads(result.stdout)
        if not isinstance(renditions, list):
            raise ValueError("assetutil output is not an array")
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        detail = error.stderr.strip() if isinstance(error, subprocess.CalledProcessError) else str(error)
        errors.append(f"Cannot inspect {path}: {detail}")
        return

    present = set()
    for rendition in renditions:
        name = rendition.get("Name")
        scale = rendition.get("Scale")
        if isinstance(name, str) and isinstance(scale, (int, float)):
            present.add((canonical_name(name), scale))

    for scale in sorted(scales):
        missing = sorted(name for name in expected_names if (name, scale) not in present)
        if missing:
            errors.append(f"{path}: missing {scale}x renditions: {', '.join(missing)}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("compiled_catalog", nargs="?", type=Path, help="Optional compiled Assets.car")
    parser.add_argument("--scale", action="append", type=int, choices=(1, 2, 3),
                        help="Required compiled rendition scale; repeat as needed (default: 1, 2, 3)")
    arguments = parser.parse_args()
    if arguments.scale and not arguments.compiled_catalog:
        parser.error("--scale requires a compiled catalog path")

    errors = []
    names = verify_source(errors)
    scales = set(arguments.scale or (1, 2, 3))
    if arguments.compiled_catalog:
        verify_compiled(arguments.compiled_catalog, scales, names, errors)

    if errors:
        print("Image asset verification failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(f"Verified {len(names)} source bitmap assets with populated 1x, 2x, and 3x slots.")
    if arguments.compiled_catalog:
        print(f"Verified all {len(names)} compiled assets at scales: {', '.join(str(scale) + 'x' for scale in sorted(scales))}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
