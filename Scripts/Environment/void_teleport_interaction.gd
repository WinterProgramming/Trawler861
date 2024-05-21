extends Interaction

@export var tunnel: WarpTunnel
@export var teleport_node: Node2D
@export var teleport_home: bool

func _interact():
	if	teleport_home:
		home_teleport()
	else:
		void_teleport()

func void_teleport():
	var move_tween = create_tween()
	move_tween.tween_property(PlayerShip.instance, "global_position", global_position, 0.5)
	await move_tween.finished
	
	PlayerShip.instance.open_tunnel()
	await PlayerShip.instance.space_tunnel.open_finished
	
	var disappear_tween = create_tween()
	disappear_tween.tween_property(PlayerShip.instance.visual, "scale", Vector2(0.0, 0.0), 0.5)
	await disappear_tween.finished
	
	await get_tree().create_timer(1.0).timeout
	VoidManager.instance.generate(0)
	PlayerShip.instance.global_position = teleport_node.global_position
	
	var appear_tween = create_tween()
	appear_tween.tween_property(PlayerShip.instance.visual, "scale", Vector2(1.0, 1.0), 0.5)
	await appear_tween.finished
	
	PlayerShip.instance.close_tunnel()
	VoidManager.instance.enter_void()
	PlayerShip.instance.location = PlayerShip.Location.VOID
	tunnel.set_active(false)
	GameManager.instance.add_void_trip()
	
func home_teleport():
	VoidManager.instance.exit_void()
	
	var move_tween = create_tween()
	move_tween.tween_property(PlayerShip.instance, "global_position", global_position, 0.5)
	await move_tween.finished
	
	PlayerShip.instance.open_tunnel()
	await PlayerShip.instance.space_tunnel.open_finished
	
	var disappear_tween = create_tween()
	disappear_tween.tween_property(PlayerShip.instance.visual, "scale", Vector2(0.0, 0.0), 0.5)
	await disappear_tween.finished
	
	
	await get_tree().create_timer(1.0).timeout
	PlayerShip.instance.global_position = teleport_node.global_position
	
	var appear_tween = create_tween()
	appear_tween.tween_property(PlayerShip.instance.visual, "scale", Vector2(1.0, 1.0), 0.5)
	await appear_tween.finished
	
	VoidManager.instance.cleanup_void()
	PlayerShip.instance.close_tunnel()
	
	PlayerShip.instance.location = PlayerShip.Location.HOME
