extends Resource
class_name MapTreeGenerator

# var num_nodes:= 23 # (0...22)
# var num_layers := 8 # (0...7)
var max_out_branches := 2


func generate(num_node: int, num_layer: int) -> MapTreeMap:
    var id := 0
    var layer := 0
    var rng := RandomNumberGenerator.new()
    rng.randomize()

    var map := MapTreeMap.new()
    map.nodes = {}
    map.number_nodes = num_node
    map.number_layer = num_layer

    ## Layer 0: Start ##
    var start := MapTreeNode.new()
    start.id = id
    id += 1
    start.layer = layer
    layer += 1
    start.num_in_layer = 1
    start.node_type = MapTreeNode.NodeType.START
    start.status = MapTreeNode.NodeStatus.CURRENT
    map.nodes[start.id] = start
    map.start_id = start.id

    var num_nod_in_lay := 1

    while id <= num_node -2 and num_nod_in_lay >= 1:
      for l in range(layer, num_layer -1):

        if l <= (int((num_layer-1) / 2) +1):
            num_nod_in_lay += 1
        else: 
            num_nod_in_lay -= 1
        for n in range(1, num_nod_in_lay+1):
            if layer == 1:                  # in layer 1 only fight nodes
              var k := MapTreeNode.new()
              k.id = id
              k.layer = l
              k.num_in_layer = n
              k.node_type = MapTreeNode.NodeType.FIGHT
              k.status = MapTreeNode.NodeStatus.AVAILABLE
              map.nodes[k.id] = k
            elif layer == (num_layer -2):
              var k := MapTreeNode.new()
              k.id = id
              k.layer = l
              k.num_in_layer = n
              k.node_type = MapTreeNode.NodeType.SHOP
              k.status = MapTreeNode.NodeStatus.LOCKED
              map.nodes[k.id] = k
            else:
              var k := MapTreeNode.new()
              k.id = id
              k.layer = l
              k.num_in_layer = n
              var x := rng.randi_range(1,3)
              if x == 1:
                k.node_type = MapTreeNode.NodeType.EVENT
              else:
                k.node_type = MapTreeNode.NodeType.FIGHT
              k.status = MapTreeNode.NodeStatus.LOCKED
              map.nodes[k.id] = k
            id += 1
    
    layer = num_layer -2
    
    ## Layer 7: Boss
    var boss := MapTreeNode.new()
    boss.id = id
    boss.layer = layer
    boss.num_in_layer = 1
    boss.node_type = MapTreeNode.NodeType.BOSS
    boss.status = MapTreeNode.NodeStatus.LOCKED
    map.nodes[boss.id] = boss
    map.boss_id = boss.id






    return map
