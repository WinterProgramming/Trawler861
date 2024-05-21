extends Node2D

@export var galaxy: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var col = galaxy.modulate
	var tween = create_tween()
	tween.tween_property(galaxy, "modulate", Color(col, 0.5), 1.0)
	tween.tween_property(galaxy, "modulate", Color(col, 0.8), 1.0)
	tween.tween_property(galaxy, "modulate", Color(col, 0.2), 1.0)
	tween.set_loops(-1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	galaxy.rotation_degrees += 1.0 * delta


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/home_space.tscn")
