extends Control
class_name DeliverPage

@export var label: Label
@export var no_loot_label: Label
@export var sell_button: Button

var credits_earned: int
var scrap_value: int

func _ready():
	sell_button.pressed.connect(on_sell_button_pressed)

func display():
	no_loot_label.set_visible(false)
	label.text = ""
	var lines = PlayerShip.instance.tow_lines
	var scrap_count = 0
	var common_count = 0
	var rare_count = 0
	var unique_count = 0
	credits_earned = 0
	scrap_value = 0

	for l in lines:
		if l.loot != null:
			scrap_count += 1
			scrap_value += l.loot.get_value()
			match l.loot.quality:
				Loot.Quality.COMMON:
					common_count += 1
				Loot.Quality.RARE:
					rare_count += 1
				Loot.Quality.UNIQUE:
					unique_count += 1

	sell_button.disabled = scrap_count == 0

	if scrap_count == 0:
		no_loot_label.set_visible(true)
		return
	
	credits_earned = int(scrap_value * 0.2)
	label.text = "Common: x%s\nRare: x%s\nUnique: x%s\nTotal Scrap: %s\nTotal Credits Earned: %s" % [common_count, rare_count, unique_count, scrap_value, credits_earned]

func on_sell_button_pressed():
	label.text = ""
	no_loot_label.set_visible(true)
	PlayerShip.instance.credits += credits_earned
	PlayerShip.instance.scrap += scrap_value
	PlayerShip.instance.currency_updated.emit(PlayerShip.instance.credits, PlayerShip.instance.scrap)
	credits_earned = 0
	scrap_value = 0
	sell_button.disabled = true
	
	PlayerShip.instance.sell_loot()


