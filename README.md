GTERM – Godot Terminal
=======================================

GTERM is a custom in-game console for Godot designed for debugging, testing, and developer tools. 
It allows developers to register and run commands making it perfect for games or projects that need a flexible terminal interface.

Features
--------

- Command registration system: Add commands dynamically using `register_command`.
- Command parsing: Input strings are parsed with arguments and executed automatically.
- Colored logs: Supports BBCode-style coloring (`[color=green]`, `[color=red]`, etc.) in logs.
- Developer-friendly: Includes helper functions for logging, updating the display, and clearing logs.

Installation
------------

1. Copy the GTERM plugin folder into your Godot project, for example:

   res://addons/gterm/

2. Create the singleton in Godot:

   Console → //gterm/scripts/console.gd
