extends Control

@export var _mode_text := ""

@export var _ver_icon_hollow: Texture2D = preload("res://shared/assets/triangle-hollow.svg")
@export var _ver_icon_full: Texture2D = preload("res://shared/assets/triangle-full.svg")
@export var _hor_icon_hollow: Texture2D = preload("res://shared/assets/triangle-hollow-hor.svg")
@export var _hor_icon_full: Texture2D = preload("res://shared/assets/triangle-full-hor.svg")

@onready var title_label := %"Title Label" as Label
@onready var mode_label: Label = %"Mode Label"
@onready var fps_label := %"FPS Label" as Label
@onready var latency_label := %"Latency Label" as Label

@onready var perfect_connection_button := %"Perfect Connection Button" as Button
@onready var good_connection_button: Button = %"Good Connection Button"
@onready var decent_connection_button := %"Decent Connection Button" as Button
@onready var horrible_connection_button := %"Horrible Connection Button" as Button

@onready var cheat_button: Button = %"Cheat Button"

@onready var up_icon := %"Up Icon" as TextureRect
@onready var left_icon := %"Left Icon" as TextureRect
@onready var right_icon := %"Right Icon" as TextureRect
@onready var down_icon := %"Down Icon" as TextureRect

var _rtt := 0.
var _rtt_variance := 0.

func _ready() -> void:
	mode_label.text = _mode_text

	perfect_connection_button.pressed.connect(func(): _set_latency(0))
	good_connection_button.pressed.connect(func(): _set_latency(10))
	decent_connection_button.pressed.connect(func(): _set_latency(50))
	horrible_connection_button.pressed.connect(func(): _set_latency(250))

	cheat_button.pressed.connect(func():
		Cheats.toggle()
		cheat_button.text = "Cheats Active!" if Cheats.is_active() else "Cheat!"
	)

func _physics_process(_dt: float) -> void:
	_update_enet_stats()
	_update_input_display()

	title_label.text = _get_multiplayer_title()
	fps_label.text = "FPS: ~%d" % [Engine.get_frames_per_second()]
	latency_label.text = "Latency: %.2fms +/- %.2fms" % [_rtt, _rtt_variance]

func _get_multiplayer_title() -> String:
	if not multiplayer.has_multiplayer_peer():
		return "disconnected"

	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.ConnectionStatus.CONNECTION_CONNECTED:
		return "disconnected"

	if multiplayer.is_server():
		return "server"

	return "client #%d" % multiplayer.get_unique_id()

func _update_enet_stats() -> void:
	if multiplayer.is_server():
		return

	if not multiplayer \
		or not multiplayer.has_multiplayer_peer() \
		or not multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		return

	var local_peer := multiplayer.multiplayer_peer as ENetMultiplayerPeer
	var host_peer := local_peer.get_peer(1)

	_rtt = host_peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	_rtt_variance = host_peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME_VARIANCE)

func _update_input_display() -> void:
	up_icon.texture = _ver_icon_full if Input.is_action_pressed("move_north") else _ver_icon_hollow
	down_icon.texture = _ver_icon_full if Input.is_action_pressed("move_south") else _ver_icon_hollow
	left_icon.texture = _hor_icon_full if Input.is_action_pressed("move_west") else _hor_icon_hollow
	right_icon.texture = _hor_icon_full if Input.is_action_pressed("move_east") else _hor_icon_hollow

func _set_latency(millis: int) -> void:
	NetworkSimulator.latency_ms = millis
