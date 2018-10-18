# Package

version       = "0.2.0"
author        = "Peter Munch-Ellingsen"
description   = "Genui is a DSL macro for creating graphical user interfaces. This version is for the Gtk3 toolkit."
license       = "MIT"
srcDir        = "gtk3genui"

# Dependencies

requires      "nim >= 0.19.0"
requires      "oldgtk3 >= 0.1.0"

# Skip examples from nimble installation

skipFiles     = @["example.nim"]

