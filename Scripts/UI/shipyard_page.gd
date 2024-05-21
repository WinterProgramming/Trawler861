extends Control
class_name ShipyardPage

const REPAIR_COST = 300

@export var repair_button: Button


func _ready():
	repair_button.pressed.connect(on_repair_button_pressed)

func display():
	update_buttons()
	

func update_buttons():
	repair_button.disabled = PlayerShip.instance.hull_health == 100.0 || !can_afford(REPAIR_COST)

func on_repair_button_pressed():
	PlayerShip.instance.hull_health = 100.0
	PlayerShip.instance.health_updated.emit(PlayerShip.instance.hull_health, PlayerShip.instance.hull_health / 100.0)
	buy(REPAIR_COST)


func can_afford(cost: int):
	return PlayerShip.instance.credits >= cost 

func buy(cost: int):
	PlayerShip.instance.credits -= cost
	PlayerShip.instance.currency_updated.emit(PlayerShip.instance.credits, PlayerShip.instance.scrap)
	update_buttons()
