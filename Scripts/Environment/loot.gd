extends Node2D
class_name Loot

enum Quality {
	COMMON,
	RARE,
	UNIQUE
}

const COMMON_COLOR = Color.GRAY
const RARE_COLOR = Color.BLUE
const UNIQUE_COLOR = Color.ORANGE

const COMMON_VALUE = 1000
const RARE_VALUE = 3500
const UNIQUE_VALUE = 12000

@export var area: Area2D
@export var scannable: Scannable
@export var particles: CPUParticles2D
@export var quality: Quality

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var col = get_color()
	particles.color = col

func get_color() -> Color:
	match quality:
		Quality.COMMON:
			return COMMON_COLOR
		Quality.RARE:
			return RARE_COLOR
		Quality.UNIQUE:
			return UNIQUE_COLOR
	return Color.WHITE

func get_value() -> int:
	match quality:
		Quality.COMMON:
			return COMMON_VALUE
		Quality.RARE:
			return RARE_VALUE
		Quality.UNIQUE:
			return UNIQUE_VALUE
	return 0

func pickup():
	# HACK: Workaround turning off collision during collision event.
	call_deferred("turn_off")

func turn_off():
	particles.emitting = false
	particles.lifetime = 1.0
	area.monitorable = false
	scannable.monitorable = false
	scannable.monitoring = false
