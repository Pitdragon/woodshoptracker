extends PanelContainer

@onready var mat_row = preload("res://Scenes/materials_row.tscn")

@onready var project_name: LineEdit = $FormVBox/HBoxContainer/ProjectName
@onready var customer_name: LineEdit = $FormVBox/HBoxContainer2/CustomerName
@onready var materials_list: VBoxContainer = $FormVBox/ScrollContainer/MaterialsList
@onready var update_button: Button = $FormVBox/HBoxContainer3/UpdateButton
@onready var close_button: Button = $FormVBox/HBoxContainer3/CloseButton
@onready var add_materials: Button = $FormVBox/HBoxContainer4/AddMaterialsButton

signal update_pressed
signal add_materials_pressed
signal delete_row

var project_id: int


func _ready() -> void:
	connect_signals()


func connect_signals():
	update_button.pressed.connect(on_update_pressed)
	close_button.pressed.connect(queue_free)
	add_materials.pressed.connect(func(): add_materials_pressed.emit(project_id))


func setup_form(projects_dict, materials_array):
	project_id = projects_dict["id"]
	project_name.text = "%s" % [projects_dict.get("project_name")]
	customer_name.text = "%s" % [projects_dict.get("customers_name")]
	for mat in materials_array:
		var row = mat_row.instantiate()
		materials_list.add_child(row)
		row.setup_row(mat)
		row.material_id= mat.get("id")
		row.new_change.connect(update_update_button)
		row.DeleteClicked.connect(_delete_row_clicked)

func _delete_row_clicked(material_id):
	delete_row.emit(material_id, project_id)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if not get_global_rect().has_point(event.global_position):
			queue_free()


func on_update_pressed():
	var materials_data: Array = []
	var project_data: Dictionary = {"project_name": project_name.text, "customer_name": customer_name.text}

	for child in materials_list.get_children():
		materials_data.append(child.get_material_data())
	update_pressed.emit(project_id, project_data, materials_data)
	queue_free()


func check_is_row_valid() -> bool:
	var is_valid: bool = true
	for row in materials_list.get_children():
		var check = row.is_row_valid()
		if check == false:
			is_valid = false
	return is_valid

func update_update_button():
	update_button.disabled = not check_is_row_valid()
