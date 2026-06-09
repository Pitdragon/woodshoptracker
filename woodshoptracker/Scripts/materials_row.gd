extends HBoxContainer
@onready var number:LineEdit = $NumberOfMaterials
@onready var material_description: LineEdit = $ProjectsName
@onready var cost: LineEdit = $Cost
@onready var total: Label = $TotalCostLabel
signal new_change
var project_id: int
var material_id: int



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals()

func connect_signals():
	cost.text_submitted.connect(calculate_total)
	cost.focus_exited.connect(calculate_total)
	cost.focus_entered.connect(func(): if cost.text != "": return)
	cost.text_changed.connect(any_text_changed)
	number.text_submitted.connect(calculate_total)
	number.focus_exited.connect(calculate_total)
	number.focus_entered.connect(func(): if number.text != "": return)
	number.text_changed.connect(any_text_changed)
	material_description.text_changed.connect(any_text_changed)

func calculate_total(_text= ""):

	var totalcost: float
	var price := cost.text
	if number.text == "":
		number.text = "1"
	if price.strip_edges() == "":
		return
	if price.is_valid_float() == false:
		cost.text = "0.00"
		return
	totalcost = number.text.to_float() * price.to_float()
	total.text = "Total: $" + "%.2f" % totalcost

func get_material_data() -> Dictionary:
	if is_row_valid() == true:
		var data = {
			"number": number.text.to_int(),
			"material_description": material_description.text,
			"price": cost.text.to_float()
		}
		return data
	else:
		return {}

func  has_valid_quantity() -> bool:
	return number.text.strip_edges() != "" and number.text.is_valid_int()

func has_valid_mareial_type() -> bool:
	return material_description.text.strip_edges() != ""

func has_valid_price() -> bool:
	return cost.text.strip_edges() != "" and cost.text.is_valid_float()

func is_row_valid() -> bool:
	return has_valid_quantity() and has_valid_mareial_type() and has_valid_price()

func any_text_changed(_text:String) -> void:
	new_change.emit()

func setup_row(row_data:Dictionary):
	number.text = str(row_data["quantity"])
	material_description.text = row_data["material_description"]
	cost.text = str(row_data["price"])
	calculate_total()
	project_id = row_data.get("project_id")
	material_id = row_data.get("id")
