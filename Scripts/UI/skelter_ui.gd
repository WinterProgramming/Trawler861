extends Control
class_name SkelterUI

@export var news_button: Button
@export var shipyard_button: Button
@export var deliver_button: Button
@export var undock_button: Button

@export var news_page: Control
@export var shipyard_page: ShipyardPage
@export var deliver_page: DeliverPage

@export var ambient_audio: AudioStreamPlayer

var active_page: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	news_button.pressed.connect(on_news_pressed)
	shipyard_button.pressed.connect(on_shipyard_pressed)
	deliver_button.pressed.connect(on_deliver_pressed)
	undock_button.pressed.connect(on_undock_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_active(value: bool):
	set_visible(value)
	ambient_audio.playing = value
	if active_page:
		active_page.set_visible(false)
		active_page = null

func on_news_pressed():
	set_active_page(news_page)

func on_shipyard_pressed():
	set_active_page(shipyard_page)
	shipyard_page.display()

func on_deliver_pressed():
	set_active_page(deliver_page)
	deliver_page.display()

func on_undock_pressed():
	PlayerShip.instance.undock()
	set_active(false)

func set_active_page(page: Control):
	if active_page:
		active_page.set_visible(false)
	active_page = page
	active_page.set_visible(true)
