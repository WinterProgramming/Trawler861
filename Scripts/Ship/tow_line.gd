class_name TowLine
extends Line2D

@export var bubble: Sprite2D
@export var fire_audio: AudioStreamPlayer2D
@export var holding_audio: AudioStreamPlayer2D

enum State {
	NONE,
	FIRING,
	HOLDING,
	RETRACTING,
	DOCKING,
}

const FIRE_SPEED = 1400.0
const RETRACT_SPEED = FIRE_SPEED * 3.0
const DOCKING_SPEED = FIRE_SPEED * 2.0
const LOOT_SETTLE_SPEED = 800.0
const MAX_LENGTH = 800.0

var state: State
var fire_dir: Vector2
var target_pos: Vector2
var loot: Loot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		State.FIRING:
			target_pos += fire_dir * FIRE_SPEED * delta
			update_line_end()
			if points[1].length() >= MAX_LENGTH:
				retract()
		State.RETRACTING:
			target_pos = target_pos.move_toward(global_position, RETRACT_SPEED * delta)
			update_line_end()

			if points[1] == Vector2.ZERO:
				state = State.NONE
		State.HOLDING:
			if loot == null:
				state = State.RETRACTING
				return
			
			loot.position = loot.position.move_toward(Vector2.ZERO, LOOT_SETTLE_SPEED * delta)
			if global_position.distance_to(target_pos) >= MAX_LENGTH:
				target_pos = global_position + global_position.direction_to(target_pos) * MAX_LENGTH
			update_line_end()
		State.DOCKING:
			target_pos = target_pos.move_toward(global_position, DOCKING_SPEED * delta)
			update_line_end()

	bubble.global_position = to_global(get_point_position(1))

func can_fire():
	return state == State.NONE && is_visible()

func update_line_end():
	set_point_position(1, to_local(target_pos))

func fire(dir: Vector2):
	fire_audio.play()
	points[1] = Vector2(0.0, 0.0)
	fire_dir = dir
	target_pos = global_position
	state = State.FIRING

func retract():
	state = State.RETRACTING

func dock():
	if state == State.NONE:
		return
		
	state = State.DOCKING

func undock():
	if loot != null:
		state = State.HOLDING
	else:
		state = State.NONE

func sell_loot():
	if !loot:
		return
	loot.queue_free()
	loot = null

func respawn():
	sell_loot()
	state = State.NONE
	target_pos = global_position
	update_line_end()
	bubble.global_position = to_global(get_point_position(1))

func _on_area_2d_area_entered(area: Area2D) -> void:
	if state == State.HOLDING || state == State.NONE:
		return
	
	PlayerShip.instance.on_tow_holding_loot.emit()
	holding_audio.play()
	state = State.HOLDING
	loot = area.get_parent() as Loot
	loot.pickup()
	loot.reparent(bubble)
