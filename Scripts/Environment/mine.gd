extends RigidBody2D
class_name Mine

const COUNT_TIME = 1.0

@export var visual: Node2D
@export var player_detection: Area2D
@export var count_audio: AudioStreamPlayer2D 
@export var explode_audio: AudioStreamPlayer2D
@export var particles: CPUParticles2D
@export var counters: Array[Sprite2D]
@export var scannable: Scannable

var count_timer: float
var counting: bool
var count: int
var player: PlayerShip
var exploded: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if exploded:
		return
	
	if counting:
		visual.rotation_degrees += (count + 1) * 90.0 * delta
	else:
		visual.rotation_degrees += 10.0 * delta
	
	if player && !counting:
		if player.linear_velocity.length() >= 400.0:
			counting = true

	if counting:
		count_timer -= delta
		if count_timer <= 0.0:
			count_timer = COUNT_TIME
			
			if count < counters.size():
				counters[count].set_visible(false)
				count += 1
				count_audio.play()
			else:
				explode()

func _physics_process(delta: float) -> void:
	if counting && player && !exploded:
		var dir = global_position.direction_to(player.global_position)
		apply_force(dir * (200.0 * (count + 1)))


func explode():
	linear_velocity = Vector2.ZERO
	visual.set_visible(false)
	particles.emitting = true
	explode_audio.play()
	scannable.set_active(false)
	counting = false
	exploded = true
	if player:
		player.apply_impulse(global_position.direction_to(player.global_position) * 1000.0)
		player.apply_torque_impulse(40000.0)
		player.apply_damage(global_position, 40.0)
	await get_tree().create_timer(3.0).timeout
	queue_free()


func _on_player_detection_body_entered(body: Node2D) -> void:
	var p = body as PlayerShip
	if p:
		player = p


func _on_player_detection_body_exited(body: Node2D) -> void:
	var p = body as PlayerShip
	if p:
		player = null
