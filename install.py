#!/usr/bin/env python3

"""Minimal dotbot replacement.

Reads the `clean:` and `link:` sections of install.conf.yaml and does the
equivalent of `mkdir -p` + `ln -sf`. Supports only what install.conf.yaml
actually uses: a flat list of `target: source` pairs under `link:`, and
`clean: ['~']`. No recursive clean, no create/shell directives, no YAML
nesting beyond that -- parsed by hand so this has no dependencies beyond
the standard library.
"""

import argparse
import os
import sys
from pathlib import Path

BASEDIR = Path(__file__).resolve().parent
CONFIG = BASEDIR / "install.conf.yaml"


def parse_links(config_path: Path) -> list[tuple[str, str]]:
    links = []
    in_link_section = False
    for raw_line in config_path.read_text().splitlines():
        line = raw_line.strip()
        if raw_line.rstrip() == "- link:":
            in_link_section = True
            continue
        if in_link_section and raw_line.startswith("- ") and raw_line[2:3].isalpha():
            break
        if not in_link_section or not line or line.startswith("#"):
            continue
        target, _, source = line.partition(":")
        target, source = target.strip(), source.strip()
        if target and source:
            links.append((target, source))
    return links


def clean(home: Path) -> None:
    print(f"-- cleaning dangling symlinks in {home} --")
    for entry in home.iterdir():
        if not entry.is_symlink():
            continue
        link_target = Path(os.readlink(entry))
        if BASEDIR not in link_target.parents and link_target != BASEDIR:
            continue
        if entry.exists():  # still resolves to something real
            continue
        print(f"removing dangling symlink: {entry} -> {link_target}")
        entry.unlink()


def link(links: list[tuple[str, str]], force: bool) -> bool:
    print("-- linking --")
    ok = True
    for target_str, source_str in links:
        target = Path(target_str).expanduser()
        abs_source = BASEDIR / source_str

        if not abs_source.exists():
            print(f"skip (missing source): {source_str}", file=sys.stderr)
            ok = False
            continue

        if target.is_symlink() and Path(os.readlink(target)) == abs_source:
            continue

        if target.is_symlink() or target.exists():
            if force:
                if target.is_dir() and not target.is_symlink():
                    import shutil

                    shutil.rmtree(target)
                else:
                    target.unlink()
            else:
                print(f"skip (exists, use --force to overwrite): {target}", file=sys.stderr)
                ok = False
                continue

        target.parent.mkdir(parents=True, exist_ok=True)
        target.symlink_to(abs_source)
        print(f"linked: {target} -> {source_str}")
    return ok


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true", help="overwrite existing files/symlinks")
    args = parser.parse_args()

    clean(Path.home())
    ok = link(parse_links(CONFIG), args.force)
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
