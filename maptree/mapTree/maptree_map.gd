extends Resource
class_name MapTreeMap

const Maptreenode = preload("res://maptree/mapTree/maptree_node.gd")

var nodes: Dictionary[int, Maptreenode] = {}
var start_id: int
var boss_id: int
var number_nodes: int
var number_layer: int