:param src => 'London';
:param dest => 'Rotterdam';


//execution mode = Stream
//variant = anonymous graph 


MATCH (src:Place {id:$src}), (dest:Place {id:$dest})
CALL gds.shortestPath.dijkstra.stream(







)