extends Control

var db_manager: DatabaseManager
# scenes
@onready var project_card: = preload("res://Scenes/project_card.tscn")
@onready var materials_form = preload("res://Scenes/new_materials_form.tscn")
@onready var details_panel = preload("res://Scenes/details_panel.tscn")
@onready var edit_form = preload("res://Scenes/edit_form.tscn")

# Main App nodes
@onready var add_project:Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/AddProjectButton
@onready var Project_grid:GridContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/ScrollContainer/ProjectGrid
@onready var new_projects_panel: PanelContainer = $NewProjectPanel
@onready var exit: Button = $MarginContainer/PanelContainer/VBoxContainer/PanelContainer/ExitButton
@onready var content_hbox:HBoxContainer = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer

var current_details_panel: Node = null
var current_form_open: Node = null

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
	projects_name.text_submitted.connect(_on_enter_pressed)
	customers_name.text_submitted.connect(_on_enter_pressed)

func add_new_project():
	if current_details_panel != null:
		current_details_panel.queue_free()
		current_details_panel = null
	new_projects_panel.show()
	projects_name.grab_focus()

func save_new_project():
	if projects_name.text.strip_edges() == "":
		projects_name.placeholder_text = "Project can not be blank"
		projects_name.grab_focus()
		return
	if customers_name.text.strip_edges() == "":
		customers_name.placeholder_text = "Customers name can not be blank"
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
	if current_details_panel != null:
		current_details_panel.queue_free()
		current_details_panel = null

	var project_data = db_manager.request_by_id(project_id)
	var materials_array = db_manager.get_materials_for_project(project_id)
	var price_total = db_manager.calculate_material_total_cost(project_id)

	var details = details_panel.instantiate()
	current_details_panel = details
	details.add_clicked.connect(_on_add_materials_pressed)
	details.edit_clicked.connect(on_edit_project_pressed)
	content_hbox.add_child(details)

	details.display_project_details(project_data)
	details.display_materials(materials_array, price_total)


func get_date_from_unixtime(unixtime:int):
	var date = Time.get_date_string_from_unix_time(unixtime)
	return date

func delete_project_clicked(project_id: int):
	db_manager.delete_project_from_db(project_id)
	show_active_cards()
	if current_details_panel != null:
		current_details_panel.queue_free()
		current_details_panel = null


func _on_add_materials_pressed(project_id):
	var form = materials_form.instantiate()
	form.save_materials_pressed.connect(_save_materials_pressed)
	form.project_id = project_id
	add_child(form)
	form.setup_form()


func _on_enter_pressed(_text: String):
	save_new_project()

func _save_materials_pressed(project_id: int, data: Array):
	db_manager.add_materials(project_id, data)
	show_active_cards()
	_on_card_clicked(project_id)
	print("save materials pressed for project_id: %s" % project_id)
	on_edit_project_pressed(project_id)

func on_edit_project_pressed(project_id):
	if current_form_open !=null:
		current_form_open.queue_free()
		current_form_open = null
	var project_dict = db_manager.request_by_id(project_id)
	var materials_array = db_manager.get_materials_for_project(project_id)
	print(materials_array)
	var edit = edit_form.instantiate()
	add_child(edit)
	edit.setup_form(project_dict, materials_array)
	edit.add_materials_pressed.connect(_on_add_materials_pressed)
	edit.update_pressed.connect(update_project_changes)
	edit.delete_row.connect(delete_material_row)
	current_form_open = edit

func update_project_changes(project_id, project_data, materials_data):
	db_manager.update_project(project_id, project_data)
	db_manager.update_materials(project_id, materials_data)
	_on_card_clicked(project_id)
	show_active_cards()

func delete_material_row(material_id, project_id):
	db_manager.delete_material_from_db(material_id, project_id)
	on_edit_project_pressed(project_id)
	_on_card_clicked(project_id)
	show_active_cards()
