// SSSP came into prominence at the same time as the shortest path algo and dijkstrsa algo can act as implementation for both problems. 
// Used as a routing protocol for IP networks
// Delta stepping does not support negative weights. 




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
// Problems: sourceNodeNames, targetNodeNames and nodeNames all return as Null... Maybe I can't use parameters? I don't see why not though. 
//##################################################

MATCH (src:Place{id:$src})
CALL gds.alpha.shortestPath.deltaStepping.stream(
    $graph_name,
    {
        startNode:src
        delta: 3.0
        relationshipWeightProperty:'distance'
    }
)