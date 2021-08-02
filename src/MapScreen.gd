extends Node2D

const View = preload("res://src/view/View.tscn")
const Presenter = preload("res://src/presenter/Presenter.gd")

onready var meta
onready var grid_model
onready var view
onready var presenter

func _ready():
	_init_model()
	_init_view()
	_init_ui()

func _init_model():
	meta = MetaModel.new()
	meta.scene_width = 30
	meta.scene_height = 30

	meta.room_width = 32
	meta.room_height = 18

	grid_model = GridModel.new(meta)

func _init_view():
	ScaleManager.set_initial_size(meta.room_width, meta.room_height)
	$GridDrawer.set_room_size(ScaleManager.get_room_width(), ScaleManager.get_room_height())

	view = View.instance()
	add_child(view)

	presenter = Presenter.new(view, grid_model)
	add_child(presenter)

func _init_ui():
	if $UI.connect("color_changed", presenter, "color_changed") != OK:
		push_error("Can't connect")
	if $UI.connect("mode_changed", presenter, "mode_changed") != OK:
		push_error("Can't connect")
	if $UI.connect("room_width_changed", presenter, "room_width_changed") != OK:
		push_error("Can't connect")
	if $UI.connect("room_height_changed", presenter, "room_height_changed") != OK:
		push_error("Can't connect")
	if presenter.connect("color_was_used", $UI, "color_was_used") != OK:
		push_error("Can't connect")
