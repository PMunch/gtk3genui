import oldgtk3/gtk, oldgtk3/glib, oldgtk3/gobject
import gtk3genui

proc destroy(widget: Widget, data: Gpointer) {.cdecl.} = mainQuit()

gtk.initWithArgv()

genui:
  Window{( @r.title = "Radio Buttons"; @r.borderWidth = 10; @r.showAll() )} -> ("destroy": example.destroy):
    Box(Orientation.VERTICAL, 0):
      RadioButton("RadioButton _1")[expand = false, fill = true, padding = 0] { var r4 = @r }
      RadioButton(r4, "RadioButton _2")[false, true, 0]
      RadioButton(r4, "RadioButton _3")[false, true, 0]
      Button("Hello world")

gtk.main()

