extends CanvasLayer
class_name GameUI

@export var interaction_label: Label
@export var skelter_ui: SkelterUI
@export var report_ui: ReportUI
@export var pause_ui: PauseUI
@export var lose_ui: LoseUI
@export var game_over_ui: GameOverUI
@export var win_ui: WinUI
@export var credits_label: Label
@export var quota_label: Label
@export var tick_audio: AudioStreamPlayer

static var instance: GameUI
var interaction: Interaction
var credits: float
var scrap: float
var tick_timer: float

func _init():
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_interaction()
	update_credits(0)
	update_quota(0, 0)
	GameManager.instance.quota_updated.connect(on_quota_updated)
	PlayerShip.instance.currency_updated.connect(currency_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var play_tick = false
	if credits != PlayerShip.instance.credits:
		play_tick = true
		credits = move_toward(credits, PlayerShip.instance.credits, 1000.0 * delta)
		update_credits(credits)
	if scrap != PlayerShip.instance.scrap:
		play_tick = true
		scrap = move_toward(scrap, PlayerShip.instance.scrap, 2000.0 * delta)
		update_quota(scrap, GameManager.instance.scrap_quota)

	tick_timer -= delta
	if play_tick && tick_timer <= 0.0:
		tick_timer = 0.1
		tick_audio.play()

func set_interaction(i: Interaction):
	interaction = i 
	interaction_label.text = interaction.label
	interaction_label.set_visible(true)

func clear_interaction():
	interaction_label.text = ""
	interaction_label.set_visible(false)
	interaction = null

func open_skelter_ui():
	skelter_ui.set_active(true)

func open_lose_ui():
	lose_ui.display()

func open_game_over_ui():
	game_over_ui.display()

func open_win_ui():
	win_ui.display()

func currency_updated(c: int, scrap: int):
	if c == 0:
		credits = 0
	if scrap == 0:
		scrap = 0

func on_quota_updated(quota: int):
	update_quota(PlayerShip.instance.scrap, quota)

func update_credits(c: int):
	credits_label.text = "Credits: %s" % c

func update_quota(collected: int, quota: int):
	quota_label.text = "Quota: %s/%s" % [collected, quota]

func block_input() -> bool:
	return skelter_ui.is_visible() || report_ui.is_visible() || lose_ui.is_visible() || game_over_ui.is_visible() || win_ui.is_visible()
