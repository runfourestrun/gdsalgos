// A* (A start) shortest path algo computes the shortes path between two nodes
// It is an informed algo as it uses a heuristic function to guide the graph traversal
// supports weighted graphs with positive relationship weights. 

// How is it different from Dijkstras shortest path algo? 

// Next node to search is not solely picked on the already computed distance
// Instead the algo combines the already computed distance with the result of the heuristic function (the functon is the difference here)
// The function takes an input and returns the value that cooresponds t the cost to reach the target node from that node
// In GDS the heusttric function is haversine distance
// Basically this is an algo specialized for lat,long (geospatial coordinates)




//##################################################
// Build Initial Graph
//##################################################


:use system;
create database transportation;
:use transportation;

WITH 'https://github.com/neo4j-graph-analytics/book/raw/master/data/' AS base
WITH base + 'transport-nodes.csv' AS uri
LOAD CSV WITH HEADERS FROM uri  AS row
MERGE (place:Place {id:row.id})
SET place.latitude = toFloat(row.latitude),
    place.longitude = toFloat(row.longitude),
    place.population = toInteger(row.population);



WITH 'https://github.com/neo4j-graph-analytics/book/raw/master/data/' AS base
WITH base + 'transport-relationships.csv' AS uri
LOAD CSV WITH HEADERS FROM uri AS row
MATCH (origin:Place {id: row.src})
MATCH (destination:Place {id: row.dst})
MERGE (origin)-[:EROAD {distance: toInteger(row.cost)}]->(destination);





//##################################################
// Build Graph Projection
//##################################################
:param graph_name => 'transportation_dij'
 CALL gds.graph.create(
      $graph_name, 
      {
          Place: {properties:['population','latitude','longitude']}
      }, 
      {
          EROAD: {properties:'distance'}
      }
            )

    YIELD
  graphName AS graph,
  relationshipProjection AS readProjection,
  nodeCount AS nodes,
  relationshipCount AS rels




//##################################################
// Execute Algo
//##################################################

:param src => 'London';
:param dest => 'Malmo';

MATCH (src:Place{id:$src}), (dest:Place{id:$dest})
CALL gds.shortestPath.astar.stream(
    $graph_name,
    {
        sourceNode: src,
        targetNode: dest,
        latitudeProperty: 'latitude',
        longitudeProperty: 'longitude',
        relationshipWeightProperty: 'distance'





    }
)
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN
    index,
    gds.util.asNode(sourceNode).name AS sourceNodeName,
    gds.util.asNode(targetNode).name AS targetNodeName,
    totalCost,
    [nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS nodeNames,
    costs,
    nodes(path) as path
ORDER BY index
