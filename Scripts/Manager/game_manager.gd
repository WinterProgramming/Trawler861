class_name GameManager
extends Node

enum Month {
	MAY,
	JUNE,
	JULY,
	AUGUST,
	SEPTEMBER
}

enum StationStability  {
	LOSE,
	DANGER,
	LOW,
	MEDIUM,
	HIGH,
	GREAT,
}

var month_names = {
	Month.MAY: "May",
	Month.JUNE: "June",
	Month.JULY: "July",
	Month.AUGUST: "August",
	Month.SEPTEMBER: "September",
}

var stability_namers = {
	StationStability.LOSE: "Game Over",
	StationStability.DANGER: "Danger",
	StationStability.LOW: "Low",
	StationStability.MEDIUM: "Medium",
	StationStability.HIGH: "High",
	StationStability.GREAT: "Great",
}

signal void_trips_updated(trips: int)
signal month_updated(month: Month)
signal quota_updated(quota: int)

const VOID_TRIPS_PER_MONTH = 2

@export var void_tunnel: WarpTunnel
@export var respawn_point: Node2D

static var instance: GameManager
var void_trips: int
var scrap_quota: int
var month: Month
var station_stability: StationStability = StationStability.LOW
var station_stability_change: int

func _init():
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerShip.instance.undocking_finished.connect(on_player_undocking_finished)
	scrap_quota = 12000
	quota_updated.emit(scrap_quota)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_player_undocking_finished():
	if !PlayerShip.instance.has_loot() && !void_tunnel.active:
		progress_time()

func progress_time():
	if can_open_void():
		void_tunnel.set_active(true)
		RadioUI.instance.add_text("[Skelter]: A Void tunnel has opened nearby... Good luck Trawler.")
	else:
		show_month_end_report()

func add_void_trip():
	void_trips += 1
	void_trips_updated.emit(void_trips)

func show_month_end_report():
	var collected = PlayerShip.instance.scrap
	if collected >= scrap_quota:
		station_stability += 1
		station_stability_change = 1
	else:
		station_stability -= 1
		station_stability_change = 0
	ReportUI.instance.display()

func next_month():
	if station_stability == StationStability.LOSE:
		GameUI.instance.open_game_over_ui()
		return
	elif month == Month.JULY:
		GameUI.instance.open_win_ui()
		return
	
	month += 1
	void_trips = 0
	void_trips_updated.emit(void_trips)
	month_updated.emit(month)
	scrap_quota = get_next_quota(PlayerShip.instance.scrap)
	PlayerShip.instance.scrap = 0
	quota_updated.emit(scrap_quota)
	progress_time()

func can_open_void():
	return void_trips < VOID_TRIPS_PER_MONTH

func get_next_quota(collected: int):
	return maxf(scrap_quota * 2.0, collected * 1.5)

func respawn_player():
	PlayerShip.instance.global_position = respawn_point.global_position
	PlayerShip.instance.respawn()
	VoidManager.instance.exit_void()
	void_trips -= 1
	void_trips_updated.emit(void_trips)
	void_tunnel.set_active(true)
	RadioUI.instance.add_text("[Skelter]: A Void tunnel has opened nearby... Good luck Trawler.")
