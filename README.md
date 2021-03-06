# Genui
This module provides the genui macro for the Gtk3 toolkit. Genui is a way to specify graphical interfaces in a hierarchical way to more clearly show the structure of the interface as well as simplifying the code. Genui is currently implemented for Gtk3, Gtk2, wxWidgets, libui, and nigui. The format focuses on being a soft conversion meaning that there are few to no assumptions and most code can be seen as a 1:1 conversion. This makes it easy to look at existing examples for your framework of choice when creating interfaces in genui. Because of this the genui format differs a bit from framework to framework, but aims to bring many of the same features. What follows is the genui format as used with Gtk3, it is identical in syntax as Gtk2 but some widgets have different names.

## Creating widgets
The most basic operation is to create widgets and add them together in a hierarchy. Gtk3 uses a simple style of `newButton` to create a widget of type Button and `parent.add child` to add a child to a parent. In genui this translates to:

```
Window:
  Button
```

We don't have a box dictating the layout so the button will take up the entire window.

## Passing initialiser parameters
In order to pass parameters to an initialiser you simply enclose them in regular "()" brackets. Genui uses brackets to denote the various things you can do, and the order of the bracketed expressions doesn't matter. So to add some text to our button simply do:

```
Window:
  Button("Hello world")
```

But our other issue still persists, we don't have a box for out button so it simply takes up the entire window. In Gtk3 boxes require packing which takes additional arguments so simply adding a box as the parent of the button won't work.

## Sending arguments to `packStart`
In order to let genui know that we want to call `packStart` instead of `add` we can use "[]" brackets. When such a bracket is present genui will call `packStart` with the parent, the current widget, and the arguments contained in the brackets. So to add our button to a `Box` and add another button below it we can do:

```
Window:
  Box(Orientation.Vertical, spacing = 0):
    Button("Hello")[expand = false, fill = true, padding = 10]
    Button("World")[expand = false, fill = true, padding = 10]
```

Note that many of Gtks arguments are basic types and things can look confusing if you don't remember the mapping and all the relevant procedure signatures. It therefore might be a good idea to be a bit extra verbose and do like above and specify what argument you are passing. This is however not required.

Now our window shows up with two buttons one below the other. But now we're faced with a new challenge. Gtk3 requires us to call a `show` procedure on our window (or `showAll` if we want to show all the widgets in the window as well) and we might want to do something with our widgets after their creation, but the widgets aren't assigned to any variable we can use.
## Running code
By using the "{}" brackets arbitrary code can be executed. In these blocks the special symbol `@result` can be used, and will be replaced by the temporary variable name for the widget (a shorthand `@r` also exists as `@result` can get a bit terse). This means that anything from simple assignment to running the aforementioned `show_all` is possible. So for example running show on our window and storing one of our buttons to a variable would be:

```
Window{@r.show_all()}:
  Box(Orientation.Vertical, spacing = 10):
    {var ourButton = @r} Button("Hello")[expand = false, fill = true, padding = 10]
    Button("World")[expand = false, fill = true, padding = 10]
``` 

This is still a bit of a work in progress and not all code works, this has to do with how Nim parses curly brackets. There are two workarounds for this, the simplest is to add regular parenthesis around your code (which Nim silently ignores when converting to code). Or, should that not work either you can wrap code in a string. So converting the above code statements to these two workaround would look like this:

```
Window{"@r.show_all()"}:
  Box(Orientation.Vertical, spacing = 10):
    {(var ourButton = @r)} Button("Hello")[expand = false, fill = true, padding = 10]
    Button("World")[expand = false, fill = true, padding = 10]
```

But in order to be able to react to user input we also need to be able to listen to events, or signals as they are called in Gtk.

## Connecting to signals
In order to connect a signal for a widget to a procedure we can use a special "->()" notation. This notation has the limitation that it can't be in the beginning of a statement, otherwise you can put it wherever you see fit. Within the parenthesis you must supply string/procedure pairs. The procedure must of course be something which can be called by the signal handler but will be automatically converted for you by a "cast[GCallback]". So in order to connect a destroy procedure to our window and a click handling procedure to our button we can do:

```
proc destroyHandler(widget: Widget, data: Gpointer) {.cdecl.} =
  mainQuit()

proc clickHandler(widget: Widget, data: Gpointer) {.cdecl.} =
  echo "You clicked the button!"

Window -> ("destroy": destroyHandler) {@r.showAll()}:
  Box(Orientation.Vertical, spacing = 10):
    {var ourButton = @r} Button("Hello")[expand = false, fill = true, padding = 10]
    Button("World")[expand = false, fill = true, padding = 10] -> ("clicked": clickHandler)
```

Note that there currently is not way to set the data pointer with this notation, it will always be set to `nil`.

## A note on order
As mentioned in the section about initialisation parameters the order of the brackets doesn't matter. So if you want to place the "{}" brackets on the end of your line, or if you want to put the "()" before the Widget name doesn't matter. But as an "official" suggestion I typically use this order:

```
{var myButton = @r} Button("Hello World!")[expand = false, fill = true, padding = 10] -> ("clicked": clickHandler)
```

The exception to this would be for code snippets which can tend to push the widget name too far along the line for readability. In that case they go in the back after any signal connections.

## Adding elements to a widget
Sometimes you want to add widgets to a parent to indicate some change of state in your program. In order to facilitate this genui also comes with the procedure `addElements` which takes a container and genui formatted code like this:

```
myExistingWidget.addElements:
  Box(Orientation.Vertical, spacing = 10):
    Button[expand = false, fill = true, padding = 10]
    Button[expand = false, fill = true, padding = 10]
```

# Quick reference
Don't care about the details? Here is a quick reference to the genui format:

| Bracket | Function                  | Example                      | Generates                                               |
|---------|---------------------------|------------------------------|---------------------------------------------------------|
| `()`    | Initialisation parameters | `Button("Hello World")`      | `newButton("Hello World")`                              |
| `[]`    | Packing parameters        | `Button[true, true, 5]`      | `box.packStart(b, true, true, 5)`                       |
| `{}`    | Pure code insertion       | `{var b = @result} Button`   | `var b = newButton()`                                   |
| `->()`  | Signal connection         | `Button -> ("clicked": ch)`  | `b.gSignalConnect("clicked", cast[GCallback](ch), nil)` |

`genui` creates new code, addElements creates the same code but with `add` or `packStart` statements for top-level widgets. `{}` is still a work in progress, code that doesn't parse in it can be added as a string instead or wrapped in parenthesis.

