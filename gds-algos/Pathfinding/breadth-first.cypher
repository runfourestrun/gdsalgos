//Breadth-first search algo is given a starting node and visits nodes in order of increasing distance
//Useful for searching when liklihood of finding the node searched for decreases with distance. There are multiple termination conditions supported for this traversal.
//1. Reaching one of several target nodes
//2.Reaching a max depth
//3. Exhausing budget of traversed relationship cost
//4. Traversing the whole graph




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

:param source => 'London'
:param target_nodes => ['Amsterdam','Den Haag']

MATCH (src:Place{id:$source})
CALL gds.alpha.bfs.stream(
    $graph_name,
    {
        startNodeId: $src
        targetNodes: $target_nodes
        maxDepth= 4
    }
)
YIELD path
UNWIND [ n in nodes(path) | n.tag ] AS tags
RETURN tags
ORDER BY tags