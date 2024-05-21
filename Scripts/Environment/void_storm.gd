extends Node2D
class_name VoidStorm

@export var thunder_audio: AudioStreamPlayer2D
@export var thunder_streams: Array[AudioStream]
@export var thunder_light: Light2D

var closing: bool
var thunder_timer: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thunder_timer = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if thunder_timer > 0.0:
		thunder_timer -= delta
		if thunder_timer <= 0.0:
			play_thunder()
	
	if closing:
		var dir = get_dir()
		position += dir * 100.0 * delta


func play_thunder():
	thunder_audio.stream = thunder_streams.pick_random()
	thunder_audio.play()
	var tween = create_tween()
	tween.tween_property(thunder_light, "energy", 3.0, 0.2)
	tween.tween_property(thunder_light, "energy", 4.0, 0.1)
	tween.tween_property(thunder_light, "energy", 0.0, 0.5)
	await tween.finished
	thunder_timer = randf_range(6.0, 12.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var player = body as PlayerShip
	if player:
		var dir = get_dir()
		player.linear_velocity = Vector2(0.0, 0.0)
		player.apply_impulse(dir * 600.0)
		player.apply_damage(global_position, 20.0)

func get_dir() -> Vector2:
	return -position.normalized()
