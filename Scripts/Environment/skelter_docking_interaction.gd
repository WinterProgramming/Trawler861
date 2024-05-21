extends Interaction

@export var docking_node: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


func _interact():
	super._interact()
	PlayerShip.instance.dock(docking_node)
	await PlayerShip.instance.docking_finished
	GameUI.instance.open_skelter_ui()
	reset_interaction()
