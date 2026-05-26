extends PanelContainer

@onready var project_name:Label = $VBoxContainer/NameLabel
@onready var customers_name:Label = $VBoxContainer/Row1/CustomersName
@onready var costs:Label = $"VBoxContainer/Row2/Materials Cost"
@onready var created:Label = $VBoxContainer/Row3/DateCreated

var project_id: int

func card_setup(project:ProjectClass):
	project_id = project.id
	project_name.text = project.name
	customers_name.text = project.customers.name
	costs.text = str(project.material_costs())
	created.text = str(project.date_created)
