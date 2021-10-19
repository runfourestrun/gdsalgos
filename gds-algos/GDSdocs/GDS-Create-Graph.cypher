// Cypher to generate a Graph


CREATE
  (florentin:Person { name: 'Florentin', age: 16 }),
  (adam:Person { name: 'Adam', age: 18 }),
  (veselin:Person { name: 'Veselin', age: 20, ratings: [5.0] }),
  (hobbit:Book { name: 'The Hobbit', isbn: 1234, numberOfPages: 310, ratings: [1.0, 2.0, 3.0, 4.5] }),
  (frankenstein:Book { name: 'Frankenstein', isbn: 4242, price: 19.99 }),

  (florentin)-[:KNOWS { since: 2010 }]->(adam),
  (florentin)-[:KNOWS { since: 2018 }]->(veselin),
  (florentin)-[:READ { numberOfPages: 4 }]->(hobbit),
  (florentin)-[:READ { numberOfPages: 42 }]->(hobbit),
  (adam)-[:READ { numberOfPages: 30 }]->(hobbit),
  (veselin)-[:READ]->(frankenstein)



//2.1
// gds.create.graph to create a simple (monopartite), in-memory project
// to run this you need to enable property dbms.security.procedures.unrestricted 
//1 == 'name of the graph'
//2 == 'Nodes to be projected'
//3  == 'Relationship to be projected'

  CALL gds.graph.create(
      'persons', //1
      'Person', //2
      'KNOWS' //3
  )
  YIELD 
  graphName as graph,
  nodeProjection,
  nodeCount as nodes,
  relationshipProjection,
  relationshipCount as rels


//2.2
// Multigraph 
// A graph with multiple labels and nodes


CALL gds.graph.create(
    'peoplebooks',
    ['Person','Book'],
    ['KNOWS','READ']
)
YIELD 
graphName as graph,
nodeProjection,
nodeCount as nodes,
relationshipProjection,
relationshipCount as relationships


//2.3
//Relationship Orientation
// By default relationships are loaded in the same orientation as stored in the Neo4j db. In GDS we call this the NATURAL orientation. Additionally, we provide 
// functionality to load the relationships in REVERSED or even UNDIRECTED


CALL gds.graph.create(
    'orientation-people',
    'Person',
    'KNOWS': {orientation:'UNDIRECTED'}
)
YIELD 
graphName as graph,
relationshipProject as relationshipProjection,
nodeCount as nodes



// to project node properties we have two options
// nodeProperties parameter
// extend an individual nodeProjection for a specified label

CALL gds.graph.create(
    'graphWithProoperties, // Graph Name
    {
        Person: {properties: 'age'}, // use the expanded node syntax 
        Book: {properties: {price: {defaultValue: 5.0}}}
        },
        ['KNOWS','READ'],
        {nodeProperties:'ratings'}
    })
    YIELD graphName,nodeProjection,nodeCount as nodes, relationshipCount as rels

RETURN graphName, nodeProjection.Book AS bookProjection, nodes, rels
