extends Node2D

@export var cutscene_player: AnimationPlayer
@export var skelter_interaction: Interaction

const LOST_CARGO_COUNT = 3
var lost_cargo_towed: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(0.5).timeout
	#test_game()
	play_intro_cutscene()

func test_game():
	GameManager.instance.progress_time()

func play_intro_cutscene():
	skelter_interaction.set_active(false)
	PlayerShip.instance.state = PlayerShip.State.CUTSCENE
	cutscene_player.play("IntroCutscene")
	await cutscene_player.animation_finished
	
	await get_tree().create_timer(0.5).timeout
	RadioUI.instance.add_text("[Skelter]: Skelter here, welcome home Trawler 861.")
	await RadioUI.instance.on_label_read_finished
	await get_tree().create_timer(1.0).timeout
	RadioUI.instance.add_text("[Skelter]: We've had a bit of an issue here on the station.")
	await RadioUI.instance.on_label_read_finished
	await get_tree().create_timer(1.0).timeout
	RadioUI.instance.add_text("[Skelter]: 3 cargo containers have drifted into nearby space.")
	await RadioUI.instance.on_label_read_finished
	await get_tree().create_timer(1.0).timeout
	RadioUI.instance.add_text("[Skelter]: Find and tow the cargo to the station and you can keep the credits.")
	
	PlayerShip.instance.state = PlayerShip.State.IDLE
	PlayerShip.instance.on_tow_holding_loot.connect(on_tow_holding_loot)
	
	await RadioUI.instance.on_label_read_finished
	await get_tree().create_timer(3.0).timeout
	RadioUI.instance.add_text("[Skelter]: Oh and \"follow the dust\"... isn't that what you Trawlers say? That should help you find cargo outside of radar range.")

func on_tow_holding_loot():
	lost_cargo_towed += 1
	if lost_cargo_towed < LOST_CARGO_COUNT:
		return
		
	PlayerShip.instance.on_tow_holding_loot.disconnect(on_tow_holding_loot)
	docking_tutorial()

func docking_tutorial():
	skelter_interaction.set_active(true)
	RadioUI.instance.add_text("[Skelter]: Great work! Dock with the station and get it sold.")
	RadioUI.instance.add_text("[Skelter]: We should be a big blue dot on your radar.")
	PlayerShip.instance.loot_sold.connect(quota_tutorial)

func quota_tutorial():
	PlayerShip.instance.loot_sold.disconnect(quota_tutorial)
	RadioUI.instance.add_text("[Skelter]: Easy money I'd say.")
	RadioUI.instance.add_text("[Skelter]: You've got about 2 more runs to the Void before month end.")
	RadioUI.instance.add_text("[Skelter]: Keep that quota met so we don't drift out of this nebula.")
	RadioUI.instance.add_text("[Skelter]: Look for the large pink dot on your radar. That wormhole will take you to Void space.")
	
func void_tutorial():
	pass
