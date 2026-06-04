extends PanelContainer


@onready var materials_list: VBoxContainer = $DetailsVbox/ScrollContainer/MaterialsList
@onready var project_name: Label = $DetailsVbox/Details_project_name
@onready var customers_name: Label = $DetailsVbox/Details_customers_name
@onready var date_created: Label = $DetailsVbox/Date_Created
@onready var total_costs: Label = $DetailsVbox/HBoxContainer/TotalCosts
@onready var edit_button: Button = $DetailsVbox/HBoxContainer2/EditButton
@onready var add_materials:Button = $DetailsVbox/HBoxContainer2/AddMaterials
@onready var close_button:Button = $DetailsVbox/CloseButton
var project_id: int = 0
var card_clicked: bool = false

signal add_clicked
signal edit_clicked


func _ready() -> void:
	add_materials.pressed.connect(_on_add_materials_pressed)
	edit_button.pressed.connect(_on_edit_button_clicked)
	close_button.pressed.connect(queue_free)


func display_project_details(project_data: Dictionary):
	card_clicked = true
	project_id = project_data["id"]
	project_name.text = "Project: \n    " +  project_data["project_name"]
	customers_name.text= "Customer: \n    " + project_data["customers_name"]
	date_created.text = "Created: \n    " + get_date_from_unixtime(project_data["date_created"])


func display_materials(materials_data:Array, price_total: float):
	for item in materials_data:
		var label = Label.new()
		label.text = "*    %s | %s | $%s" % [item.quantity, item.material_name, item.price]
		materials_list.add_child(label)
		total_costs.text = "Total: $" + "%.2f" % price_total


func get_date_from_unixtime(unixtime:int):
	var date = Time.get_date_string_from_unix_time(unixtime)
	return date


func _on_add_materials_pressed():
	if card_clicked:
		add_clicked.emit(project_id)

func _on_edit_button_clicked():
	if card_clicked:
		edit_clicked.emit(project_id)
