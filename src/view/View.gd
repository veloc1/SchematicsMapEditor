extends Node2D

# View handles all view logic (animations, adding/removing child views etc)

const CellView = preload("res://src/view/objects/CellView.tscn")

var grid

func _ready():
	if ScaleManager.connect("scale_changed", self, "on_scale_changed") != OK:
		push_error("Can't connect")

func setup_grid(grid_model: GridModel):
	grid = []

	for x in grid_model.width:
		var column = []
		grid.append(column)
		for y in grid_model.height:
			column.append(null)

			update_cell(Vector2(x, y), grid_model.get_cell(Vector2(x, y)))

func update_cell(pos: Vector2, cell: CellModel):
	var cell_view = _get_cell_view(pos)

	if not cell_view:
		# There is no cell view. Lazily construct one
		cell_view = CellView.instance()

		add_child(cell_view)
		cell_view.position = Utils.grid_to_pix(pos)

		_set_cell_view(pos, cell_view)

	if cell_view.room and not cell.room:
		# if no room in data, but there is view - remove view
		cell_view.remove_room()

	if cell.room and not cell_view.has_room(cell.room):
		# if room in data, but not in view or have different room in view - construct new one
		cell_view.create_room(cell.room)

	cell_view.update_passes(cell)

func _get_cell_view(pos):
	return grid[pos.x][pos.y]

func _set_cell_view(pos, cell):
	grid[pos.x][pos.y] = cell

# move cells to new positions according to scale
func on_scale_changed():
	for x in len(grid):
		for y in len(grid[x]):
			var pos = Vector2(x, y)
			var cell_view = _get_cell_view(pos)
			if cell_view:
				cell_view.position = Utils.grid_to_pix(pos)
