extends Control
class_name PauseUI

@export var resume_button: Button
@export var quit_button: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resume_button.pressed.connect(on_resume_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)

func _process(delta: float) -> void:
	if GameUI.instance.block_input():
		return
		
	if Input.is_action_just_pressed("toggle_pause"):
		if is_visible():
			close()
		else:
			open()

func open():
	set_visible(true)
	get_tree().paused = true
	
func close():
	set_visible(false)
	get_tree().paused = false

func on_resume_button_pressed():
	close()
	
func on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
