import oldgtk3/[gtk, glib, gobject]
import gtk3genui/gtk3genui

proc destroy(widget: Widget, data: Gpointer) {.cdecl.} = mainQuit()

proc clicked(widget: Widget, data: Gpointer) {.cdecl.} =
  echo "Button clicked"

gtk.initWithArgv()

genui:
  Window{( @r.title = "Radio Buttons"; @r.borderWidth = 10; @r.showAll() )} -> ("destroy": example.destroy):
    Box(Orientation.VERTICAL, 0):
      RadioButton("RadioButton _1")[expand = false, fill = true, padding = 0] { var r4 = @r }
      RadioButton(r4, "RadioButton _2")[false, true, 0]
      RadioButton(r4, "RadioButton _3")[false, true, 0]
      Button("Hello world") -> ("clicked": example.clicked)

gtk.main()

