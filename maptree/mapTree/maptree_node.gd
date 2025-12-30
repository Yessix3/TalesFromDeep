class_name MapTreeNode
extends Node

var id: int
var layer: int
var num_in_layer: int
enum NodeType {START, FIGHT, EVENT, SHOP, BOSS}
enum NodeStatus {CURRENT, LOCKED, AVAILABLE, COMPLETED}
var next_ids: Array[int]
var prev_ids: Array[int]

