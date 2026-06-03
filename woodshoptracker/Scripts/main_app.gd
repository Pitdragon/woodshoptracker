extends Control

var db_manager: DatabaseManager
# scenes
@onready var project_card: = preload("res://Scenes/project_card.tscn")
@onready var materials_form = preload("res://Scenes/new_materials_form.tscn")
# Main App nodes
@onready var add_project:Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/AddProjectButton
@onready var Project_grid:GridContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/ScrollContainer/ProjectGrid
@onready var new_projects_panel: PanelContainer = $NewProjectPanel
@onready var exit: Button = $MarginContainer/PanelContainer/VBoxContainer/PanelContainer/ExitButton
@onready var clear_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/ClearButton
# Details panel nodes
@onready var materiasl_list: VBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/ScrollContainer/MaterialsList
@onready var details_project: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/Details_project_name
@onready var details_customer: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/Details_customers_name
@onready var date_created: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/Date_Created
@onready var total_costs: Label = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/HBoxContainer/TotalCosts
var card_id: int = 0
var card_clicked: bool = false
@onready var add_materials:Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/DetailsPanel/DetailsVbox/HBoxContainer2/AddMaterials
# new project panel nodes
@onready var projects_name:LineEdit = $NewProjectPanel/VBoxContainer/ProjectsName
@onready var customers_name: LineEdit = $NewProjectPanel/VBoxContainer/CustomersName
@onready var save_button: Button = $NewProjectPanel/VBoxContainer/HBoxContainer/SaveButton
@onready var close_button: Button = $NewProjectPanel/VBoxContainer/HBoxContainer/CloseButton

func _ready() -> void:
	db_manager = DatabaseManager.new()
	connect_signals()
	new_projects_panel.hide()
	show_active_cards()

func connect_signals():
	add_project.pressed.connect(add_new_project)
	exit.pressed.connect(exit_button_pressed)
	save_button.pressed.connect(save_new_project)
	close_button.pressed.connect(close_button_pressed)
	clear_button.pressed.connect(clear_button_pressed)
	projects_name.text_submitted.connect(_on_enter_pressed)
	customers_name.text_submitted.connect(_on_enter_pressed)
	add_materials.pressed.connect(_on_add_materials_pressed)

func add_new_project():
	new_projects_panel.show()
	projects_name.grab_focus()

func save_new_project():
	if projects_name.text.strip_edges() == "":
		projects_name.placeholder_text = "Name can not be blank"
		projects_name.grab_focus()
		return
	if customers_name.text.strip_edges() == "":
		customers_name.placeholder_text = "Customers can not be blank"
		customers_name.grab_focus()
		return
	var project = projects_name.text
	var customer = customers_name.text
	db_manager.add_new_project(project,customer)
	clear_project_form()
	new_projects_panel.hide()
	show_active_cards()

func close_button_pressed():
	clear_project_form()
	new_projects_panel.hide()

func clear_project_form():
	projects_name.clear()
	customers_name.clear()

func exit_button_pressed():
	get_tree().quit()

func show_active_cards():
	for child in Project_grid.get_children():
		child.queue_free()
	var results = db_manager.request_active_projects()

	for project in results:
		var card = project_card.instantiate()
		Project_grid.add_child(card)
		card.CardClicked.connect(_on_card_clicked)
		card.DeleteClicked.connect(delete_project_clicked)
		var total_cost = db_manager.calculate_material_total_cost(project["id"])
		card.card_setup(project, total_cost)


func _on_card_clicked(project_id:int):
	clear_details_panel()
	card_clicked = true
	var details: Dictionary
	var request = db_manager.request_by_id(project_id)
	for project in request:
		details = project
	details_project.text = details.project_name
	details_customer.text = "Customer: " +details.customers_name
	date_created.text = get_date_from_unixtime(details.date_created)
	show_materials_in_details(project_id)
	card_id = details.id

func clear_details_panel():
	card_clicked = false
	details_project.text = ""
	details_customer.text = ""
	date_created.text = ""
	total_costs.text = "0.00"
	for child in materiasl_list.get_children():
		child.queue_free()

func get_date_from_unixtime(unixtime:int):
	var date = Time.get_date_string_from_unix_time(unixtime)
	return date

func delete_project_clicked(project_id: int):
	db_manager.delete_project_from_db(project_id)
	show_active_cards()
	reset_details_panel()

func _on_add_materials_pressed():
	if card_clicked:
		var form = materials_form.instantiate()
		form.project_id = card_id
		form.project_name = details_project.text
		add_child(form)
		form.save_materials_pressed.connect(_save_materials_pressed)
		var m = db_manager.get_materials_for_project(card_id)
		form.setup_form(m)



func reset_details_panel():
	details_project.text = "No Project Seleted"
	details_customer.text = "Customers Name: "
	date_created.text = "Date Created"
	total_costs.text = "Total Costs"
	for child in materiasl_list.get_children():
		child.queue_free()
	var label = Label.new()
	materiasl_list.add_child(label)
	label.text = "- no Materials added"

func clear_button_pressed():
	reset_details_panel()
	card_clicked = false

func _on_enter_pressed(_text: String):
	save_new_project()

func _save_materials_pressed(project_id: int, data: Array):
	db_manager.add_materials(project_id, data)
	show_active_cards()

func show_materials_in_details(project_id):
	var m = db_manager.get_materials_for_project(project_id)
	for item in m:
		var label = Label.new()
		label.text = "- %s | %s | $%s" % [item.quantity, item.material_name, item.price]
		materiasl_list.add_child(label)
