class_name Shield
extends Sprite2D

enum ShieldPosition {
	FORWARD,
	AFT
}

enum State {
	ACTIVE,
	RECHARGING,
}

signal on_health_updated(position: ShieldPosition, health: float, health_norm: float)

const MAX_ALPHA = 0.2
const FLASH_TIME = 0.5
const MAX_SHIELD = 50.0

@export var shield_position: ShieldPosition
@export var shield_break_audio: AudioStreamPlayer
@export var shield_recharge_audio: AudioStreamPlayer

var state: State = State.ACTIVE
var health: float = 50.0
var health_timer: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_out(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == State.ACTIVE && health <= MAX_SHIELD:
		health_timer -= delta
		if health_timer <= 0.0:
			health_timer = 2.0
			health = clampf(health + 5.0, 0.0, MAX_SHIELD) 
			on_health_updated.emit(shield_position, health, health / MAX_SHIELD)

func apply_damage(damage: float):
	health -= damage
	health = clamp(health, 0.0, 100.0)
	on_health_updated.emit(shield_position, health, health / MAX_SHIELD)
	if health <= 0.0:
		state = State.RECHARGING
		get_tree().create_timer(30.0).timeout.connect(restore_shield)
		shield_break_audio.play()
	else:
		flash()

func flash():
	set_visible(true)
	await get_tree().create_timer(1.0).timeout
	fade_out(true)

func fade_out(instant: bool = false):
	if instant:
		set_visible(false)

func restore_shield():
	shield_recharge_audio.play()
	state = State.ACTIVE
	health = MAX_SHIELD
	on_health_updated.emit(shield_position, health, health / MAX_SHIELD)
