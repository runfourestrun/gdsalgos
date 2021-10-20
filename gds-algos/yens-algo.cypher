// Yen's Shortest Path algo computes the number of shortest paths between two nodes.
// Algo is often referred to as Yen's k-Shortest Path algo
// For K=1 the algo behaves exactly like dijkstra shortest path algo
// For K=2 the algo returns the shortest path and the second shortest path between the same source and target node.
// Basically K=N where N is the paths ordered by total cost
// Seems useful for alternative routing


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
// Executing with a NAMED graph projection. You can also use an anonymous graph projection 
// 
//##################################################

:param src => 'Ipswich' ;
:param dest => 'Gouda';




MATCH(a:Place{id:$src}),  (b:Place {id:$dest})
CALL gds.shortestPath.yens.stream (
    $graph_name,
    {
        sourceNode: a,
        targetNode: b,
        k: 2 ,
        relationshipWeightProperty: 'distance' 
    }
)
YIELD 
index,
sourceNode,
targetNode,
totalCost,
nodeIds,
costs,
path
RETURN 
index,
gds.util.asNode(a) as sourceNodeName,
gds.util.asNode(b) as targetNodeName,
totalCost,
[nodeId IN nodeIds | gds.util.asNode(nodeId).name] as node_names,
nodes(path) as path,
costs