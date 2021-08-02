extends CanvasLayer

signal color_changed(color)
signal mode_changed(mode)
signal room_width_changed(new_width)
signal room_height_changed(new_height)

onready var color_picker = $PanelContainer/VBoxContainer/ColorPicker
onready var doors_button = $PanelContainer/VBoxContainer/RoomDoorSelector/DoorButton
onready var pass_button = $PanelContainer/VBoxContainer/RoomDoorSelector/PassButton
onready var rooms_button = $PanelContainer/VBoxContainer/RoomDoorSelector/RoomButton
onready var room_width_text = $"PanelContainer/VBoxContainer/Size Controls/Rows"
onready var room_height_text = $"PanelContainer/VBoxContainer/Size Controls/Columns"

func _ready():
	color_picker.connect("color_changed", self, "color_changed")
	doors_button.connect("button_up", self, "change_mode", ["doors"])
	rooms_button.connect("button_up", self, "change_mode", ["rooms"])
	pass_button.connect("button_up", self, "change_mode", ["pass"])

	room_width_text.connect("text_changed", self, "room_width_text_changed")
	room_height_text.connect("text_changed", self, "room_height_text_changed")

func color_changed(color):
	emit_signal("color_changed", color)

func change_mode(mode):
	emit_signal("mode_changed", mode)

func room_width_text_changed(new_text):
	var number = _clear_int(new_text)

	if room_width_text.text != number:
		room_width_text.text = number

	emit_signal("room_width_changed", number.to_int())

func room_height_text_changed(new_text):
	var number = _clear_int(new_text)

	if room_height_text.text != number:
		room_height_text.text = number

	emit_signal("room_height_changed", number.to_int())

func color_was_used(color):
	color_picker.add_preset(color)

func _clear_int(text):
	var number = ""
	for c in text:
		if c > "0" and c < "9":
			number += c
	if len(number) == 0 or number == "0":
		number = "1"
	return number
