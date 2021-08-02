extends Node2D

const Room = preload("res://src/view/objects/Room.tscn")

var room

func create_room(room_model: RoomModel):
	if room:
		room.queue_free()

	room = Room.instance()

	room.set_base_room_size(ScaleManager.get_room_width(), ScaleManager.get_room_height())
	room.set_room_size(room_model.size.x, room_model.size.y )
	room.color = room_model.color
	add_child(room)

	room.play_create_animation()


func remove_room():
	if room:
		room.play_destroy_animation()

	room = null

func has_room(room_model: RoomModel):
	if not room:
		return false

	return room.color == room_model.color # TODO also check size

func update_passes(cell):
	if room:
		room.update_passes(cell.passes)
