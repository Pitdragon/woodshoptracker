extends PanelContainer

# scenes
@onready var material_row = preload("res://Scenes/materials_row.tscn")

# scene nodes
@onready var addrow: Button = $MaterialFormVBox/HBoxContainer3/AddMaterialLine
@onready var list: VBoxContainer = $MaterialFormVBox/ScrollContainer/MaterialsFormList
@onready var save_button: Button = $MaterialFormVBox/HBoxContainer/SaveMaterials
@onready var close_button:Button = $MaterialFormVBox/HBoxContainer/CloseMaterials
@onready var id_label: Label = $MaterialFormVBox/HBoxContainer3/ProjectID
# signals
signal save_materials_pressed

# variables
var project_id: int
var project_name:String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()



func connect_signals():
	addrow.pressed.connect(add_material_pressed)
	save_button.pressed.connect(save_button_pressed)
	close_button.pressed.connect(_on_close_pressed)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			queue_free()

func add_material_pressed():
	var row = material_row.instantiate()
	list.add_child(row)
	row.grab_focus()
	row.new_change.connect(update_save_button)

func update_save_button():
	save_button.disabled = not check_is_row_valid()

func save_button_pressed():
	var data: Array = []
	for child in list.get_children():
		data.append(child.get_material_data())
	save_materials_pressed.emit(project_id, data)
	queue_free()

func _on_close_pressed():
	queue_free()

func check_is_row_valid() -> bool:
	var is_valid: bool = true
	for row in list.get_children():
		var check = row.is_row_valid()
		if check == false:
			is_valid = false
	return is_valid

func setup_form(material_data: Array):

	for data in material_data:
		var row = material_row.instantiate()
		list.add_child(row)
		row.setup_row(data)
	if list.get_children().size() < 1:
		add_material_pressed()

	id_label.text = "Project ID: %s | %s" % [project_id, project_name]
	save_button.disabled = true
