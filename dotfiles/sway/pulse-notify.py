#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "pulsectl-asyncio",
#   "pygobject",
# ]
# ///

import asyncio
import signal
from contextlib import suppress

import gi
import pulsectl_asyncio

gi.require_version("Notify", "0.7")
from gi.repository import GLib, Notify


async def main():
    # Run listen() coroutine in task to allow cancelling it
    listen_task = asyncio.create_task(listen())

    # register signal handlers to cancel listener when program is asked to terminate
    for sig in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        asyncio.get_event_loop().add_signal_handler(sig, listen_task.cancel)

    with suppress(asyncio.CancelledError):
        await listen_task


async def listen():
    async with pulsectl_asyncio.PulseAsync("pulse-notify") as pulse:
        async for event in pulse.subscribe_events("sink", "source"):
            await handle_event(pulse, event)


async def handle_event(pulse, event):
    match event.facility:
        case "sink":
            sink = await pulse.sink_info(event.index)
            send_pulse_notification(sink, "audio-volume", SINK_NOTIFICATION)
        case "source":
            source = await pulse.source_info(event.index)
            send_pulse_notification(
                source, "microphone-sensitivity", SOURCE_NOTIFICATION
            )
        case facility:
            send_facility_notification(facility)


def send_pulse_notification(info, icon_prefix, notification):
    volume = None if info.mute == 1 else round(info.volume.values[0] * 100)
    match volume:
        case None:
            icon = f"{icon_prefix}-muted"
        case v if v < 33:
            icon = f"{icon_prefix}-low"
        case v if v < 66:
            icon = f"{icon_prefix}-medium"
        case _:
            icon = f"{icon_prefix}-high"

    if volume is None:
        notification.set_hint("value", None)
        summary = f"{info.description}: [muted]"
    else:
        notification.set_hint("value", GLib.Variant("i", volume))
        summary = f"{info.description}: {volume}%"
    notification.update(summary, None, icon)
    try:
        notification.show()
    except GLib.GError as e:
        print(f"Unable to show pulse notification: {e}")


def send_facility_notification(facility):
    n = Notify.Notification.new(
        f"Unknown pulse facility: {facility}", None, "dialog-warning"
    )
    n.set_timeout(10000)
    n.show()


Notify.init("pulse-notify")

SINK_NOTIFICATION = Notify.Notification.new("pulse-notify-sink", None, None)
SINK_NOTIFICATION.set_timeout(2000)
SINK_NOTIFICATION.set_hint("transient", GLib.Variant("b", True))
SINK_NOTIFICATION.set_hint("synchronous", GLib.Variant("s", "volume-change-sink"))

SOURCE_NOTIFICATION = Notify.Notification.new("pulse-notify-source", None, None)
SOURCE_NOTIFICATION.set_timeout(2000)
SOURCE_NOTIFICATION.set_hint("transient", GLib.Variant("b", True))
SOURCE_NOTIFICATION.set_hint("synchronous", GLib.Variant("s", "volume-change-source"))

asyncio.run(main())
