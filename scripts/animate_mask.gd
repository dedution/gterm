extends Control

@export var reveal_height: float = 400
@export var reveal_time: float = 0.3

var hidden_height: float = 0
var is_open: bool = false
var current_tween: Tween = null

func _ready():
	clip_contents = true
	# Start fully collapsed
	size.y = hidden_height

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		toggle_menu()

func toggle_menu():
	# Kill the current tween if one exists
	if current_tween and current_tween.is_valid():
		current_tween.kill()
	
	# Create a new tween
	current_tween = create_tween()
	
	if is_open:
		current_tween.tween_property(self, "size:y", hidden_height, reveal_time)
		current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		is_open = false
	else:
		current_tween.tween_property(self, "size:y", reveal_height, reveal_time)
		current_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		is_open = true
