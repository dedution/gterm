<pre>
  ______     ______   ______     ______     __    __    
 /\  ___\   /\__  _\ /\  ___\   /\  == \   /\ "-./  \   
 \ \ \__ \  \/_/\ \/ \ \  __\   \ \  __<   \ \ \-./\ \  
  \ \_____\    \ \_\  \ \_____\  \ \_\ \_\  \ \_\ \ \_\ 
   \/_____/     \/_/   \/_____/   \/_/ /_/   \/_/  \/_/
</pre>


# GTERM – Godot Terminal
=======================================

GTERM is a custom in-game console for Godot designed for debugging, testing, and developer tools. 
It allows developers to register and run commands, making it perfect for games or projects that need a flexible terminal interface.

---

Features
--------

- Command registration system: Add commands dynamically using `register_command`.
- Command parsing: Input strings are parsed with arguments and executed automatically.
- Colored logs: Supports BBCode-style coloring ([color=green], [color=red], etc.) in logs.
- Internal commands: Comes with a set of built-in commands for testing, debugging, and basic control.
- Developer-friendly: Helper functions for logging, updating the display, and clearing logs.

---

Installation
------------

1. Copy the GTERM plugin folder into your Godot project:

   res://addons/gterm/

2. Enable the Console singleton in Godot:

   Console → //gterm/scripts/console.gd

---

Usage Example
-------------

Register a custom command:

    Console.register_command("/greet", [Argument.new("name", TYPE_STRING)], func(args: Dictionary) -> void:
        Console.log_info("console", "Hello, %s!" % args["name"])
    )

Log messages:

    Console.log_info("console", "Custom message here")
    Console.log_warn("console", "Custom message here")
    Console.log_error("console", "Custom message here")

---

Built-in Internal Commands
--------------------------

The following commands are registered automatically by GTERM:

- /wait [time: float]  
  Waits asynchronously for the given number of seconds and logs when done.

- /loadmod [file_name: string]  
  Logs that a mod file is being loaded.

- /help  
  Displays a list of available commands.

- /clear  
  Clears the console output.

- /pause [pause: bool]  
  Pauses or unpauses the game. If no argument is provided, defaults to true.

- /set [node_path: string] [property: string] [value: string]  
  Sets a property of a node dynamically.

- /version  
  Logs the current console version.

- /fps  
  Logs the current FPS.

- /network  
  Lists local IP addresses.

- /print [quote: string]  
  Logs a custom string to the console.

---

Notes
-----

- Arguments are typed using Argument.new(name, TYPE_X), allowing automatic parsing and validation.
- Commands can be asynchronous (like /wait) without freezing the game.
- Console logging is unified and color-coded using Console.log_info().

---

License
-------

MIT License — free to use and modify.
