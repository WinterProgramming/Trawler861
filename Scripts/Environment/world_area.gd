extends Area2D



func _on_body_entered(body: Node2D) -> void:
	var player = body as PlayerShip
	if !player:
		return
		
	
