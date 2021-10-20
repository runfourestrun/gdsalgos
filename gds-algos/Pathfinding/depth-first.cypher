//Depth-First Search
// This algorithm can be preferred over Breath First Search for example 
//if one wants to find a target node at a large distance and exploring a random path has decent probability of success


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
:param target_nodes => ['Amsterdam','Den Haag']
:param graph_name => 'transportation_dij';

MATCH (src:Place{id:$src})
WITH id(src) as startNode
CALL gds.alpha.dfs.stream(
    $graph_name,
    {
        startNodeId:startNode,
        targetNodes:target_nodes
    }
)
YIELD path
UNWIND [ n in nodes(path) | n.tag ] AS tags
RETURN tags
ORDER BY tags