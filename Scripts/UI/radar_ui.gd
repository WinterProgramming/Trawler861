extends Control
class_name RadarUI

@export var radar_background: TextureRect
@export var pips: Array[TextureRect]

const DRAW_SECONDS = 0.2

static var instance: RadarUI
var scannables: Array[Scannable]
var persistent_scannables: Array[Scannable]
var pip_lookup: Dictionary
var pip_pool: Array[TextureRect]
var draw_timer: float

func _init():
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for p in pips:
		add_to_pool(p)
	
	PlayerShip.instance.on_scan_enter.connect(on_scan_enter)
	PlayerShip.instance.on_scan_exit.connect(on_scan_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	draw_pips()

func draw_pips():
	for s in scannables:
		var pip = get_pip(s)
		if pip:
			pip.position = get_radar_position(s, pip)

	for s in persistent_scannables:
		if s._can_draw():
			var pip = get_pip(s)
			if pip:
				pip.position = get_radar_position(s, pip)
		else:
			return_pip(s)

func get_radar_position(scan: Scannable, pip: TextureRect):
	var obj_dist = PlayerShip.instance.global_position.distance_to(scan.global_position)
	var scan_range = PlayerShip.instance.get_scan_range()
	var norm_dist = clampf(obj_dist / scan_range, 0.0, 1.0)
	var obj_dir = PlayerShip.instance.global_position.direction_to(scan.global_position)
	
	var radar_half = radar_background.size / 2.0
	var radar_dist = ((radar_half * norm_dist) -  (pip.size / 2.0)).length()
	radar_dist = clampf(radar_dist, 0.0, radar_half.x - pip.size.x)
	return radar_half + (obj_dir * radar_dist)

func get_pip(scan: Scannable) -> TextureRect:
	var id = scan.get_instance_id()
	# Exists already
	if pip_lookup.has(id):
		return pip_lookup[id]
	
	# Pool empty!
	if pip_pool.size() == 0:
		printerr("Pip pool empty!")
		return null
		
	# Get from pool
	var pip = pip_pool.pop_back()
	pip.set_visible(true)
	pip_lookup[id] = pip
	pip.modulate = scan.color
	
	if scan.pip_size == Scannable.PipSize.NORMAL:
		pip.size = Vector2(10, 10)
	elif scan.pip_size == Scannable.PipSize.LARGE:
		pip.size = Vector2(14, 14)
	
	pip.pivot_offset = pip.size / 2.0
	return pip

func return_pip(scan: Scannable):
	var id = scan.get_instance_id()
	if !pip_lookup.has(id):
		return
		
	var pip = pip_lookup[id]
	pip_lookup.erase(id)
	add_to_pool(pip)

func add_to_pool(pip: TextureRect):
	pip.set_visible(false)
	pip_pool.append(pip)

func on_scan_enter(scan: Scannable):
	if scan.radar_persistent:
		return
	
	scannables.append(scan)
	
func on_scan_exit(scan: Scannable):
	if scan.radar_persistent:
		return
		
	return_pip(scan)
	scannables.erase(scan)

func add_persistent(scan: Scannable):
	persistent_scannables.append(scan)
	
func remove_persistent(scan: Scannable):
	return_pip(scan)
	persistent_scannables.erase(scan)
