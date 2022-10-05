from typing import List

from kitty.boss import Boss

import kitty


def main(args: List[str]) -> str:
    return ""


def handle_result(
    args: List[str], result: str, target_window_id: int, boss: Boss
) -> None:
    lines = []
    for k, v in boss.keymap.items():
        repr = kitty.types.human_repr_of_single_key(k, 5)
        lines.append(f"{repr}: {v}")

    text = "\n".join(lines).strip()

    window = boss.window_id_map.get(target_window_id)
    if window is not None:
        boss.display_scrollback(window, text)
