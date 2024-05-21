extends Control
class_name LoseUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func display():
	get_tree().paused = true
	set_visible(true)

func _on_respawn_button_pressed() -> void:
	get_tree().paused = false
	GameManager.instance.respawn_player()
	set_visible(false)

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
