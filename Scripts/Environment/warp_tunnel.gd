extends Node2D
class_name WarpTunnel

@export var sprite: Sprite2D
@export var interaction: Interaction
@export var scannable: Scannable

var active: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite.rotation_degrees += 10.0 * delta

func set_active(value: bool):
	active = value
	sprite.set_visible(active)
	interaction.disabled = !active
	scannable.set_active(active)
