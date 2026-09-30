class_name MainMenu
extends Control
## The first screen: type a server address and a nickname, then join someone's
## server or host one on this computer.

signal join_requested(address: String, port: int, nickname: String)
signal host_requested(port: int, nickname: String)

const DEFAULT_ADDRESS: String = "127.0.0.1"

@onready var _address_edit: LineEdit = %AddressEdit
@onready var _nickname_edit: LineEdit = %NicknameEdit
@onready var _join_button: Button = %JoinButton
@onready var _host_button: Button = %HostButton
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_join_button.pressed.connect(_on_join_pressed)
	_host_button.pressed.connect(_on_host_pressed)
	_address_edit.text_submitted.connect(_on_text_submitted)
	_nickname_edit.text_submitted.connect(_on_text_submitted)
	_nickname_edit.grab_focus()


func show_message(message: String) -> void:
	_status_label.text = message


## Shown while the connection is being set up; the menu closes once it's up.
func show_connecting(address: String) -> void:
	_status_label.text = tr("Connecting to %s…") % address
	_join_button.disabled = true
	_host_button.disabled = true


func _on_join_pressed() -> void:
	var address := _address_edit.text.strip_edges()
	var port := Net.DEFAULT_PORT
	# "host:port" picks a port. A bare IPv6 address has several colons and no port.
	if address.count(":") == 1:
		var port_text := address.get_slice(":", 1)
		if not port_text.is_valid_int():
			show_message(tr('The port after ":" has to be a number.'))
			return
		port = port_text.to_int()
		address = address.get_slice(":", 0)
	if address.is_empty():
		address = DEFAULT_ADDRESS
	join_requested.emit(address, port, _nickname_edit.text)


func _on_host_pressed() -> void:
	host_requested.emit(Net.DEFAULT_PORT, _nickname_edit.text)


func _on_text_submitted(_text: String) -> void:
	_on_join_pressed()
