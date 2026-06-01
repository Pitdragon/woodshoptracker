extends PanelContainer

# scenes
@onready var material_row = preload("res://Scenes/materials_row.tscn")

# scene nodes
@onready var addrow: Button = $MaterialFormVBox/AddMaterialLine
@onready var list: VBoxContainer = $MaterialFormVBox/ScrollContainer/MaterialsFormList
@onready var save_button: Button = $MaterialFormVBox/HBoxContainer/SaveMaterials

# signals
signal save_materials_pressed

# variables
var project_id: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()


func connect_signals():
	addrow.pressed.connect(add_material_pressed)
	save_button.pressed.connect(save_button_pressed)

func add_material_pressed():
	var row = material_row.instantiate()
	list.add_child(row)

func save_button_pressed():
	var data: Array = []
	for child in list.get_children():
		data.append(child.get_material_data())
	save_materials_pressed.emit(project_id, data)
