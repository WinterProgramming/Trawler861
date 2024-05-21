class_name Scannable
extends Area2D

enum PipSize {
	NORMAL,
	LARGE
}

@export var label: String
@export var description: String
@export var size_reference: Sprite2D
@export var radar_persistent: bool
@export var show_in_void: bool
@export var show_in_home: bool
@export var color: Color = Color.WHITE
@export var pip_size: PipSize

var active: bool = true

func _ready():
	if radar_persistent:
		update_persistent()

func set_active(value: bool):
	active = value
	monitorable = active
	monitoring = active
	update_persistent()

func _can_draw() -> bool:
	var can = true
	if show_in_home:
		can = PlayerShip.instance.location == PlayerShip.Location.HOME
	if show_in_void:
		can = PlayerShip.instance.location == PlayerShip.Location.VOID
	return can

func update_persistent():
	if active:
		RadarUI.instance.add_persistent(self)
	else:
		RadarUI.instance.remove_persistent(self)
