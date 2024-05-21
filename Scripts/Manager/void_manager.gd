extends Node2D
class_name VoidManager

enum VoidLevel {
	GREEN,
	YELLOW,
	RED
}

signal void_entered
signal void_exited
signal void_level_updated

const YELLOW_LEVEL_TIME = 40.0
const RED_LEVEL_TIME = 80.0
const TICK_TIME = 3.0

@export var world_area: CollisionShape2D
@export var common_loot_scene: PackedScene
@export var rare_loot_scene: PackedScene
@export var unique_loot_scene: PackedScene
@export var small_rock_scene: PackedScene
@export var mine_scene: PackedScene
@export var exit_tunnel: WarpTunnel
@export var gen_parent: Node2D
@export var storm_parent: Node2D

static var instance: VoidManager
var void_storms: Array[VoidStorm]
var world_size: float
var level: VoidLevel
var active: bool
var active_timer: float
var tick_timer: float

var common_loot_spawn_chance: float
var common_loot_spawn_max: int
var rare_loot_spawn_chance: float
var rare_loot_spawn_max: int
var unique_loot_spawn_chance: float
var unique_loot_spawn_max: int

var common_loot_spawn_count: int
var rare_loot_spawn_count: int
var unique_loot_spawn_count: int

var mine_spawn_chance: float

func _init():
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var circle = world_area.shape as CircleShape2D
	world_size = circle.radius
	for c in storm_parent.get_children():
		var storm = c as VoidStorm
		if storm:
			void_storms.append(storm)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
	
	active_timer += delta
	check_level()
	
	tick_timer += delta
	if tick_timer >= TICK_TIME:
		tick_timer = 0.0
		tick_generate()

func generate(seed: int):
	exit_tunnel.position = rand_vector() * randf_range(world_size / 4.0, world_size / 2.0)
	exit_tunnel.set_active(false)
	get_tree().create_timer(randf_range(YELLOW_LEVEL_TIME, RED_LEVEL_TIME),).timeout.connect(open_exit_tunnel)
	reset_storm()

func check_level():
	var desired_level = VoidLevel.GREEN
	if active_timer >= RED_LEVEL_TIME:
		desired_level = VoidLevel.RED
	elif active_timer >= YELLOW_LEVEL_TIME:
		desired_level = VoidLevel.YELLOW
	
	if level != desired_level:
		update_void_level(desired_level)

func tick_generate():
	var rng = randf()
	if rng <= unique_loot_spawn_chance:
		if unique_loot_spawn_count < unique_loot_spawn_max:
			unique_loot_spawn_count += 1
			create_loot(unique_loot_scene, 500.0)
	elif rng <= rare_loot_spawn_chance:
		if rare_loot_spawn_count < rare_loot_spawn_max:
			rare_loot_spawn_count += 1
			create_loot(rare_loot_scene, world_size / 4.0)
	elif rng <= common_loot_spawn_chance:
		if common_loot_spawn_count < common_loot_spawn_max:
			common_loot_spawn_count += 1
			create_loot(common_loot_scene, world_size / 2.0)
	
	if rng <= mine_spawn_chance:
		create_mine()


func open_exit_tunnel():
	exit_tunnel.set_active(true)
	RadioUI.instance.add_text("[Void]: A warp tunnel home has opened in the void.")

func update_void_level(l: VoidLevel):
	level = l
	RadioUI.instance.add_text("[Void]: Warning void alert level %s" % get_void_level_name(level))
	
	if level == VoidLevel.RED:
		close_storm()
		RadioUI.instance.add_text("[Void]: Void storms incoming.")

	void_level_updated.emit(level)
	# TODO: Add new dangers based on level
	match level:
		VoidLevel.GREEN:
			common_loot_spawn_chance = 0.5
			common_loot_spawn_max = 4
			rare_loot_spawn_chance = 0.2
			rare_loot_spawn_max = 2
			unique_loot_spawn_chance = 0.0
			unique_loot_spawn_max = 0
			mine_spawn_chance = 0.05
		VoidLevel.YELLOW:
			common_loot_spawn_chance = 0.6
			common_loot_spawn_max = 4
			rare_loot_spawn_chance = 0.35
			rare_loot_spawn_max = 4
			unique_loot_spawn_chance = 0.05
			unique_loot_spawn_max = 1
			mine_spawn_chance = 0.18
		VoidLevel.RED:
			common_loot_spawn_chance = 0.7
			common_loot_spawn_max = 4
			rare_loot_spawn_chance = 0.4
			rare_loot_spawn_max = 6
			unique_loot_spawn_chance = 0.1
			unique_loot_spawn_max = 2
			mine_spawn_chance = 0.4
			pass

func get_void_level_name(l: VoidLevel) -> String:
	match l:
		VoidLevel.GREEN:
			return "Green"
		VoidLevel.YELLOW:
			return "Yellow"
		VoidLevel.RED:
			return "Red"
	return "Unknown"

func create_loot(scene: PackedScene, spawn_min: float):
	var loot = scene.instantiate() as Loot
	gen_parent.add_child(loot)
	loot.position = rand_vector() * randf_range(spawn_min, world_size)

func create_mine():
	var mine = mine_scene.instantiate() as Mine
	gen_parent.add_child(mine)
	mine.position = rand_vector() * randf_range(world_size / 2.0, world_size)

func rand_vector() -> Vector2:
	var v = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	return v.normalized()

func enter_void():
	update_void_level(VoidLevel.GREEN)
	
	active_timer = 0.0
	tick_timer = 0.0
	common_loot_spawn_count = 0
	rare_loot_spawn_count = 0
	unique_loot_spawn_count = 0
	active = true
	void_entered.emit()
	
func exit_void():
	active = false
	void_exited.emit()

func reset_storm():
	storm_parent.position = exit_tunnel.position
	var count = void_storms.size()
	for i in count:
		var angle = i * (360.0 / count)
		var dir = Vector2(1, 0)
		dir = dir.rotated(deg_to_rad(angle))
		void_storms[i].position = dir * world_size

func close_storm():
	for s in void_storms:
		s.closing = true

func cleanup_void():
	for c in gen_parent.get_children():
		c.queue_free()
		
	for s in void_storms:
		s.closing = false
