class_name Interaction
extends Area2D

@export var label: String

var in_use: bool
var disabled: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)


func _can_interact() -> bool:
	return !in_use && !disabled

func _interact():
	in_use = true
	pass

func set_active(value: bool):
	monitorable = value
	monitoring = value

func reset_interaction():
	in_use = false

func on_body_entered(body: Node2D):
	var player = body as PlayerShip
	if !player:
		return
	
	PlayerShip.instance.set_interaction(self)

func on_body_exited(body: Node2D):
	var player = body as PlayerShip
	if !player:
		return
	
	PlayerShip.instance.clear_interaction(self)
