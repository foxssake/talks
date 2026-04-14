extends Control

@onready var title_label := %"Title Label" as Label
@onready var fps_label := %"FPS Label" as Label
@onready var latency_label := %"Latency Label" as Label

@onready var perfect_connection_button := %"Perfect Connection Button" as Button
@onready var good_connection_button: Button = %"Good Connection Button"
@onready var decent_connection_button := %"Decent Connection Button" as Button
@onready var horrible_connection_button := %"Horrible Connection Button" as Button

@onready var cheat_button: Button = %"Cheat Button"

var _rtt := 0.
var _rtt_variance := 0.

func _ready() -> void:
	perfect_connection_button.pressed.connect(func(): _set_latency(0))
	good_connection_button.pressed.connect(func(): _set_latency(10))
	decent_connection_button.pressed.connect(func(): _set_latency(50))
	horrible_connection_button.pressed.connect(func(): _set_latency(250))

func _physics_process(_dt: float) -> void:
	_update_enet_stats()

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

func _set_latency(millis: int) -> void:
	NetworkSimulator.latency_ms = millis
