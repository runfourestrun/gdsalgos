
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

//execution mode = Stream
//variant = named graph
// using named graph created in creating-graphs.cypher


:param src => 'London';
:param dest => 'Rotterdam';
:param graph_name => 'transportation_dij';


MATCH (src:Place {id:$src}), (dest:Place {id:$dest})
CALL gds.shortestPath.dijkstra.stream($graph_name,{
sourceNode: src,
targetNode: dest,
relationshipWeightProperty: 'distance'
}
)
YIELD index, sourceNode, targetNode, totalCost, nodeIds, costs, path
RETURN 
index,
gds.util.asNode(sourceNode).name AS sourceNodeName,
gds.util.asNode(targetNode).name AS targetNodeName,
totalCost,
[nodeId in nodeIds | gds.util.asNode(nodeId).name] as nodeNames,
costs,
nodes(path) as path
ORDER BY index
