extends RefCounted

class_name ProjectClass

var id:int
var project_name:String
var customers_name:String
var date_created:int

var materials:Dictionary = {}

func _init(project_id:int ,projects_name:String, customer_name:String, created:int) -> void:
	id = project_id
	project_name = projects_name
	customers_name = customer_name
	date_created = created

func material_costs()-> float:
	var price:Array = []
	var materials_cost:float
	for key in materials:
		price.append(materials[key])
	for i in price:
		materials_cost = materials_cost + i
	return materials_cost

# create database tables for projects and materials
# rewrite material_costs() to look up prices from the database
