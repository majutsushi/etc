from typing import TYPE_CHECKING, Optional

from kitty.fast_data_types import Screen, get_boss
from kitty.rgb import alpha_blend
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb, draw_title
from kitty.utils import color_as_int
from kitty.window import Window

if TYPE_CHECKING:
    from kitty.boss import Boss

# Separators and status icons
LEFT_SEP = ""
RIGHT_SEP = ""
SOFT_SEP = "│"
PADDING = " "
SSH_ICON = "󰌘  "


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    default_bg = as_rgb(color_as_int(draw_data.default_bg))
    if tab.is_active:
        text_fg = as_rgb(color_as_int(draw_data.active_fg))
        text_bg = as_rgb(color_as_int(draw_data.active_bg))
        icon = as_rgb(color_as_int(draw_data.active_bg))
    else:
        text_fg = as_rgb(color_as_int(draw_data.inactive_fg))
        text_bg = as_rgb(color_as_int(draw_data.inactive_bg))
        icon = as_rgb(color_as_int(draw_data.inactive_bg))

    soft_sep = None
    if not is_last:
        both_inactive = not tab.is_active and not extra_data.next_tab.is_active
        soft_sep = SOFT_SEP if both_inactive else PADDING

    boss: Boss = get_boss()
    tab_window = boss.tab_for_id(tab.tab_id).active_window
    is_ssh = child_is_remote(tab_window) or bool(tab_window.ssh_kitten_cmdline())

    def draw_element(element: Optional[str], fg: int, bg: int) -> None:
        screen.cursor.fg = fg
        screen.cursor.bg = bg
        if element is not None:
            screen.draw(element)
        else:
            soft_sep_len = len(soft_sep) if soft_sep else 0
            ssh_len = len(SSH_ICON) if is_ssh else 0
            draw_title(
                draw_data,
                screen,
                tab,
                index,
                max_tab_length - 2 - soft_sep_len - ssh_len,
            )
            max_cursor_x = before + max_tab_length - len(LEFT_SEP)
            if screen.cursor.x > max_cursor_x:
                screen.cursor.x = max_cursor_x - 1
                screen.draw("…")

    draw_element(LEFT_SEP, icon, default_bg)
    if is_ssh:
        draw_element(SSH_ICON, text_fg, text_bg)
    draw_element(None, text_fg, text_bg)
    draw_element(RIGHT_SEP, icon, default_bg)
    if soft_sep:
        soft_sep_color = alpha_blend(draw_data.inactive_fg, draw_data.default_bg, 0.25)
        draw_element(soft_sep, as_rgb(color_as_int(soft_sep_color)), default_bg)

    # Element ends before soft separator
    end: int = screen.cursor.x - (len(soft_sep) if soft_sep else 0)
    return end


# Slightly changed from
# https://github.com/kovidgoyal/kitty/blob/33ab1d9019b91e9ed4ddbb647cacca9ad3a5973c/kitty/window.py#L1683
def child_is_remote(window: Window) -> bool:
    for p in window.child.foreground_processes:
        q = list(p["cmdline"] or ())
        if q and q[0].lower() in ("ssh", "mosh", "mosh-client"):
            return True
    return False
