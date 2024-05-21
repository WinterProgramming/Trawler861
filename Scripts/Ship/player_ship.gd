class_name PlayerShip
extends RigidBody2D

enum State {
	IDLE,
	DOCKING,
	DOCKED,
	UNDOCKING,
	CUTSCENE,
	TUNNELING,
	DEAD,
}

enum Location {
	HOME,
	VOID,
}

signal on_scan_enter(scannable: Scannable)
signal on_scan_exit(scannable: Scannable)
signal docking_finished
signal undocking_finished
signal on_tow_holding_loot
signal loot_sold
signal health_updated(health: float, health_norm: float)
signal currency_updated(credits: int, scrap: int)
signal player_dead

const FORWARD_SPEED = 200.0
const BACKWARD_SPEED = FORWARD_SPEED * 0.8
const BRAKE_SPEED = 150.0
const TURN_SPEED = 30000.0
const MAX_SPEED = 900.0
const DODGE_SPEED = 1000.0

@export var visual: Node2D
@export var shield_system: ShieldSystem
@export var tow_lines: Array[TowLine]
@export var scan_area: Area2D
@export var scan_shape: CollisionShape2D
@export var space_tunnel: SpaceTunnel
@export var engine_particles: CPUParticles2D
@export var engine_audio: AudioStreamPlayer
@export var crash_audio: AudioStreamPlayer
@export var crash_streams: Array[AudioStream]
@export var spark_audio: AudioStreamPlayer
@export var spark_streams: Array[AudioStream]
@export var spark_particles: Array[CPUParticles2D]

static var instance: PlayerShip
var state: State
var dodge_cooldown: float
var interaction: Interaction
var hull_health: float = 100.0
var docking_node: Node2D
var move_input: Vector2
var wants_brake: bool
var wants_dodge: bool
var wants_boost: bool
var wait_for_interaction_release: bool
var location: Location = Location.HOME
var engine_rev: float
var spark_timer: float
var spark_wait: float
var boost_timer: float

var collisions: Dictionary = {}

# Resources
var scrap: int
var credits: int

func _init():
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scan_area.area_entered.connect(on_scan_entered)
	scan_area.area_exited.connect(on_scan_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	check_sparks(delta)
	
	if dodge_cooldown >= 0.0:
		dodge_cooldown -= delta

	var max_pitch = 1.2
	if wants_boost:
		max_pitch = 2.0

	var desired_speed = lerp(1.0, 500.0, engine_rev)
	var desired_pitch = lerp(0.5, max_pitch, engine_rev)
	var desired_scale = lerp(1.0, 5.0, engine_rev)
	engine_particles.initial_velocity_min  = move_toward(engine_particles.initial_velocity_min, desired_speed, 80.0 * delta)
	engine_particles.initial_velocity_max = engine_particles.initial_velocity_min * 1.1
	engine_particles.scale_amount_min = move_toward(engine_particles.scale_amount_min, desired_scale, 4.0 * delta)
	engine_particles.scale_amount_max = engine_particles.scale_amount_min * 1.5
	engine_audio.pitch_scale = move_toward(engine_audio.pitch_scale, desired_pitch, 1.0 * delta)

	match state:
		State.IDLE:
			process_idle(delta)
			
	if move_input.y > 0.0:
		engine_rev = move_toward(engine_rev, 1.0, 0.5 * delta)
	else:
		engine_rev = move_toward(engine_rev, 0.0, 0.5 * delta)

func _physics_process(delta: float) -> void:
	if move_input.y > 0.0:
		var speed = FORWARD_SPEED
		if wants_boost:
			speed = FORWARD_SPEED * 2.0
		apply_force(transform.x * (move_input.y * speed))
	elif move_input.y < 0.0:
		apply_force(transform.x * (move_input.y * BACKWARD_SPEED))

	if move_input.x != 0.0:
		apply_torque(TURN_SPEED * move_input.x)
	
	if wants_brake:
		if linear_velocity.length() < 2.0:
			linear_velocity = Vector2.ZERO
		else:
			apply_force(-linear_velocity.normalized() * BRAKE_SPEED)

	if wants_dodge && can_dodge():
		dodge_cooldown = 5.0
		linear_velocity = Vector2.ZERO
		var mouse_position = get_global_mouse_position()
		var dir = global_position.direction_to(mouse_position)
		apply_impulse(dir * DODGE_SPEED)
	
	var max_vel = MAX_SPEED
	if wants_boost:
		max_vel = MAX_SPEED * 2.0
	if linear_velocity.length() >= max_vel:
		linear_velocity = linear_velocity.normalized() * max_vel

	check_collisions(delta)

func check_collisions(delta: float):
	var collision = move_and_collide(linear_velocity * delta, true)
	if collision != null:
		var obj = collision.get_collider()
		if collisions.has(obj):
			return
		
		collisions[obj] = true
		var wall = obj as HazardWall
		if wall:
			var pos = collision.get_position()
			if linear_velocity.length() < 80.0:
				return
			var damage = lerp(5.0, wall.MAX_DAMAGE, linear_velocity.length() / MAX_SPEED)
			apply_damage(pos, wall.MAX_DAMAGE)
			crash_audio.stream = crash_streams.pick_random()
			crash_audio.play()

func check_sparks(delta: float):
	if hull_health >= 100.0:
		return
	
	spark_timer -= delta
	if spark_timer <= 0.0:
		spark_timer = randf_range(spark_wait, spark_wait * 1.5)
		spark_audio.stream = spark_streams.pick_random()
		spark_audio.play()
		spark_particles.pick_random().emitting = true

	if hull_health >= 75.0:
		spark_wait = 4.0
	elif hull_health >= 50.0:
		spark_wait = 3.0
	elif hull_health >= 25.0:
		spark_wait = 2.0
	else:
		spark_wait = 1.0

func process_idle(delta: float):
	if GameUI.instance.block_input():
		return
	
	move_input.x = Input.get_axis("left", "right")
	move_input.y = Input.get_axis("backward", "forward")
	
	if Input.is_action_just_pressed("fire_line"):
		fire_line()
	
	wants_dodge = Input.is_action_just_pressed("dodge")
	wants_boost = Input.is_action_pressed("boost")
	if wants_boost:
		move_input.y = 1.0
	
	wants_brake = Input.is_action_pressed("brake")
	if wants_brake && !wait_for_interaction_release && interaction && interaction._can_interact() && linear_velocity.length() == 0.0:
		interaction._interact()
		wait_for_interaction_release = true

	if wait_for_interaction_release && !Input.is_action_pressed("brake"):
		wait_for_interaction_release = false

func get_speed() -> float:
	return linear_velocity.length()

func get_scan_range() -> float:
	var circle = scan_shape.shape as CircleShape2D
	return circle.radius

func can_dodge() -> bool:
	return dodge_cooldown <= 0.0

func has_loot() -> bool:
	for l in tow_lines:
		if l.loot != null:
			return true
	return false

func sell_loot():
	for l in tow_lines:
		if l.loot != null:
			l.sell_loot()
	loot_sold.emit()

func fire_line():
	var mouse_position = get_global_mouse_position()
	var dir = global_position.direction_to(mouse_position)
	for l in tow_lines:
		if l.can_fire():
			l.fire(dir)
			break

func set_interaction(i: Interaction):
	interaction = i
	GameUI.instance.set_interaction(interaction)

func clear_interaction(i: Interaction):
	if interaction != i:
		return
	
	GameUI.instance.clear_interaction()
	interaction = null

func dock(dock: Node2D):
	state = State.DOCKING
	docking_node = dock
	stop_ship()
	
	for l in tow_lines:
		l.dock()
	
	var dist = global_position.distance_to(dock.global_position)
	var time = (dist / 500.0) * 0.5
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", docking_node.global_position, time).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "global_rotation", docking_node.global_rotation, time).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	state = State.DOCKED
	docking_finished.emit()

func undock():
	state = State.UNDOCKING
	var tween = create_tween()
	tween.tween_property(self, "global_position", docking_node.global_position + (Vector2.DOWN * 200.0), 1.0).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "global_rotation", 0.0, 1.0).set_ease(Tween.EASE_IN)
	await tween.finished

	for l in tow_lines:
		l.undock()

	state = State.IDLE
	docking_node = null
	undocking_finished.emit()

func stop_ship():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	move_input = Vector2.ZERO

func apply_damage(pos: Vector2, damage: float):
	if shield_system.apply_damage(pos, damage):
		return
	
	hull_health -= damage
	hull_health = clampf(hull_health, 0.0, 100.0)
	health_updated.emit(hull_health, hull_health / 100.0)
	
	if hull_health <= 0.0:
		state = State.DEAD
		player_dead.emit()
		# show UI
		await get_tree().create_timer(2.0).timeout
		stop_ship()
		GameUI.instance.open_lose_ui()

func open_tunnel():
	state = State.TUNNELING
	space_tunnel.open()

func close_tunnel():
	space_tunnel.close()
	state = State.IDLE

func on_scan_entered(area: Area2D) -> void:
	var scan = area as Scannable
	if scan:
		on_scan_enter.emit(scan)

func on_scan_exited(area: Area2D) -> void:
	var scan = area as Scannable
	if scan:
		on_scan_exit.emit(scan)


func _on_body_exited(body: Node) -> void:
	collisions.erase(body)

func respawn():
	location == PlayerShip.Location.HOME
	hull_health = 100
	health_updated.emit(100.0, 1.0)
	shield_system.forward_shield.health = Shield.MAX_SHIELD
	shield_system.forward_shield.on_health_updated.emit(Shield.ShieldPosition.FORWARD, Shield.MAX_SHIELD, 1.0)
	shield_system.aft_shield.health = Shield.MAX_SHIELD
	shield_system.aft_shield.on_health_updated.emit(Shield.ShieldPosition.AFT, Shield.MAX_SHIELD, 1.0)
	state = State.IDLE
	for t in tow_lines:
		t.sell_loot()
