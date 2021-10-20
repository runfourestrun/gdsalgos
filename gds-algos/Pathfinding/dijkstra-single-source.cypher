//Dijkstra Shortest Path algo computes shortest path between nodes
//This particular algo computes the shortest path from a source node to all other nodes



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

:param src => 'London';

MATCH (p:Place{id:$src})
CALL gds.allShortestPaths.dijkstram.stream(
    $graph_name,
    {
        sourceNode: p,
        relationshipWeightProperty: 'distance'
    }
)
YIELD 
index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN 
index,
gds.util.asNode(sourceNode).name as sourceNodeName,
gds.util.asNode(targetNode).name as targetNodeName,
totalCost,
[nodeId IN nodeIds | gds.util.asNode(nodeId).name] AS nodeNames,
nodes(path) as path




