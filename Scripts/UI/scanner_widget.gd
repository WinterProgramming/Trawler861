class_name ScannerWidget
extends Control

@export var name_label: Label
@export var description_label: Label
@export var texture: TextureRect

var scannable: Scannable
var default_size: Vector2

func _ready():
	set_active(false)
	default_size = size

func _process(delta: float) -> void:
	if !scannable:
		return
	
	update_position()

func set_data(scan: Scannable):
	if scan.size_reference:
		size = scan.size_reference.texture.get_size() * scan.size_reference.scale
	else:
		size = default_size
	
	set_active(true)
	scannable = scan
	name_label.text = scannable.label
	description_label.text = scannable.description
	update_position()
	
func clear():
	scannable = null
	set_active(false)

func update_position():
	var half_size = size / 2.0
	global_position = scannable.global_position - half_size

func set_active(active: bool):
	set_visible(active)
	set_process(active)
