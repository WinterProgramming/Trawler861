extends Control

@export var speed_label: Label
@export var shield_forward: TextureRect
@export var shield_aft: TextureRect
@export var hull: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerShip.instance.shield_system.forward_shield.on_health_updated.connect(on_shield_health_updated)
	PlayerShip.instance.shield_system.aft_shield.on_health_updated.connect(on_shield_health_updated)
	PlayerShip.instance.health_updated.connect(on_hull_health_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed_label.text = "Speed: %.0fm/s" % PlayerShip.instance.get_speed()

func on_hull_health_updated(health: float, health_norm: float):
	hull.modulate = get_color(health, health_norm)

func on_shield_health_updated(shield_position: Shield.ShieldPosition, health: float, health_norm: float):
	var shield: TextureRect
	if shield_position == Shield.ShieldPosition.FORWARD:
		shield = shield_forward
	else:
		shield = shield_aft

	var col = get_color(health, health_norm)
	col.a = clampf(col.a, 0.0, 0.4)
	shield.modulate = col

func get_color(value: float, norm: float) -> Color:
	if value <= 0.0:
		return Color.DIM_GRAY
	else:
		if norm >= 0.5:
			var mapped = remap(norm, 0.5, 1.0, 0.0, 1.0)
			return lerp(Color.ORANGE, Color.GREEN, mapped)
		elif norm >= 0.25:
			var mapped = remap(norm, 0.25, 0.5, 0.0, 1.0)
			return lerp(Color.RED, Color.ORANGE, mapped)
		else:
			var mapped = remap(norm, 0.25, 0.5, 0.0, 1.0)
			return lerp(Color.RED, Color(Color.RED, 0.0), mapped)
