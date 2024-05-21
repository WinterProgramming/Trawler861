extends Node2D
class_name SpaceTunnel

@export var tunnel_sprite: Sprite2D

signal open_finished

func _process(delta: float) -> void:
	rotation_degrees += 40.0 * delta

func open():
	var tween = create_tween()
	tween.tween_property(tunnel_sprite, "scale", Vector2(4.0, 4.0), 0.5).set_ease(Tween.EASE_IN)
	await tween.finished
	open_finished.emit()
	
func close():
	var tween = create_tween()
	tween.tween_property(tunnel_sprite, "scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN)
