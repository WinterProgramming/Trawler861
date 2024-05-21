class_name ShieldSystem
extends Node2D


@export var forward_shield: Shield
@export var aft_shield: Shield

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func apply_damage(pos: Vector2, damage: float) -> bool:
	var shield = get_shield(pos)
	if shield.state != Shield.State.ACTIVE:
		return false
		
	shield.apply_damage(damage)
	return true

func get_shield(pos: Vector2) -> Shield:
	var dir = global_position.direction_to(pos)
	if global_transform.x.dot(dir) > 0.0:
		return forward_shield
	else:
		return aft_shield
