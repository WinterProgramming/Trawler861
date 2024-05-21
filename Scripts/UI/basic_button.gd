extends Button

@onready var hover_audio = AudioStreamPlayer.new()
@onready var pressed_audio = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hover_audio.stream = load("res://Audio/ui_hover.ogg")
	pressed_audio.stream = load("res://Audio/ui_pressed.ogg")
	add_child(hover_audio)
	add_child(pressed_audio)
	mouse_entered.connect(on_hover)
	pressed.connect(on_pressed)


func on_hover():
	hover_audio.play()
	
func on_pressed():
	pressed_audio.play()
