"""Click-through black overlay drawn above the wallpaper and below windows.

usage: dim-overlay.py <opacity 0-1>

Covers every monitor with a layer-shell surface on the "bottom" layer, so the
wallpaper must be on the "background" layer underneath it. Must be started
with libgtk4-layer-shell.so in LD_PRELOAD (the wallpaper script does this).
"""
import sys

import cairo
import gi

gi.require_version('Gtk', '4.0')
gi.require_version('Gtk4LayerShell', '1.0')
from gi.repository import Gdk, Gtk, Gtk4LayerShell as LayerShell  # noqa: E402

opacity = max(0.0, min(1.0, float(sys.argv[1])))


def make_overlay(app, monitor):
    win = Gtk.Window(application=app)
    LayerShell.init_for_window(win)
    LayerShell.set_namespace(win, 'wallpaper-dim')
    LayerShell.set_layer(win, LayerShell.Layer.BOTTOM)
    LayerShell.set_monitor(win, monitor)
    LayerShell.set_exclusive_zone(win, -1)
    LayerShell.set_keyboard_mode(win, LayerShell.KeyboardMode.NONE)
    for edge in (LayerShell.Edge.TOP, LayerShell.Edge.BOTTOM, LayerShell.Edge.LEFT, LayerShell.Edge.RIGHT):
        LayerShell.set_anchor(win, edge, True)
    win.add_css_class('dim')
    # Empty input region so clicks pass through to whatever is below
    win.connect('realize', lambda w: w.get_surface().set_input_region(cairo.Region()))
    win.present()


def on_activate(app):
    css = Gtk.CssProvider()
    css.load_from_string(f'window.dim {{ background: rgba(0, 0, 0, {opacity}); }}')
    Gtk.StyleContext.add_provider_for_display(
        Gdk.Display.get_default(), css, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
    monitors = Gdk.Display.get_default().get_monitors()
    for i in range(monitors.get_n_items()):
        make_overlay(app, monitors.get_item(i))
    app.hold()


app = Gtk.Application(application_id=None)
app.connect('activate', on_activate)
app.run([])
