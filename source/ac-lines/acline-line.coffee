Make ["ACLine:line"], (rawPairs) ->

    # HELPERS

    EPSILON = 0.01

    close = (a, b) ->
        dx = a.x - b.x
        dy = a.y - b.y
        dx * dx + dy * dy < EPSILON

    wrap = (data) ->
        process: (fn) -> wrap fn data
        result: data


    # PROCESSING STEPS
    #
    # Point data comes from an external source and isn't guaranteed to be a
    # single clean tip-to-tail polyline: it can contain small dead-end stubs
    # (e.g. arrowhead-marker glyphs) grafted onto the real path at a shared
    # point, or even wholly disconnected fragments. Rather than requiring
    # every caller to pre-clean their points, treat the pairs as a weighted
    # graph and automatically walk its longest path, which routes around
    # short dead-end branches and ignores any smaller disconnected pieces.

    buildGraph = (rawPairs) ->
        nodes = []

        nodeIndex = (p) ->
            for n, i in nodes
                return i if close n, p
            nodes.push p
            nodes.length - 1

        edges = []
        nPairs = rawPairs.length / 2
        for i in [0...nPairs]
            pa = rawPairs[i * 2]
            pb = rawPairs[i * 2 + 1]
            ia = nodeIndex pa
            ib = nodeIndex pb
            continue if ia is ib          # drop degenerate (zero-length) segments
            dx = pb.x - pa.x
            dy = pb.y - pa.y
            edges.push a: ia, b: ib, len: Math.sqrt(dx * dx + dy * dy)

        adj = ([] for n in nodes)
        for edge, ei in edges
            adj[edge.a].push to: edge.b, edge: ei
            adj[edge.b].push to: edge.a, edge: ei

        {nodes, edges, adj}

    # Isolate the richest connected component (by total edge length), in
    # case the point data describes more than one disconnected piece.
    largestComponent = ({nodes, edges, adj}) ->
        compId = (-1 for n in nodes)
        members = []

        for start in [0...nodes.length]
            continue unless compId[start] is -1
            id = members.length
            stack = [start]
            compId[start] = id
            group = [start]
            while stack.length
                node = stack.pop()
                for {to} in adj[node]
                    if compId[to] is -1
                        compId[to] = id
                        group.push to
                        stack.push to
            members.push group

        return [] if members.length is 0

        lengths = (0 for m in members)
        for edge in edges
            lengths[compId[edge.a]] += edge.len

        best = 0
        for l, i in lengths
            best = i if l > lengths[best]

        members[best]

    # Walk from an arbitrary node to its farthest point, then from there to
    # *its* farthest point — the standard tree-diameter technique. Any short
    # dead-end branch off the main path (a stub) simply isn't the farthest
    # point from either end, so it's naturally excluded from the result.
    farthestFrom = (start, adj, edges) ->
        dist = {}
        prevNode = {}
        prevEdge = {}
        visited = {}
        dist[start] = 0
        visited[start] = true
        stack = [start]
        farthest = start

        while stack.length
            node = stack.pop()
            farthest = node if dist[node] > dist[farthest]
            for {to, edge} in adj[node]
                continue if visited[to]
                visited[to] = true
                dist[to] = dist[node] + edges[edge].len
                prevNode[to] = node
                prevEdge[to] = edge
                stack.push to

        {farthest, prevNode}

    longestChain = (graph) ->
        component = largestComponent graph
        return [] if component.length is 0
        return [graph.nodes[component[0]]] if component.length is 1

        {farthest: a} = farthestFrom component[0], graph.adj, graph.edges
        {farthest: b, prevNode} = farthestFrom a, graph.adj, graph.edges

        path = [b]
        cur = b
        while cur isnt a
            cur = prevNode[cur]
            path.unshift cur

        (graph.nodes[i] for i in path)

    precompute = (chain) ->
        n = chain.length - 1

        segDX     = new Float64Array n
        segDY     = new Float64Array n
        segInvLen = new Float64Array n
        cumLen    = new Float64Array n + 1
        startPts  = new Float64Array n * 2

        for i in [0...n]
            p0 = chain[i]
            p1 = chain[i + 1]
            dx = p1.x - p0.x
            dy = p1.y - p0.y
            len = Math.sqrt dx * dx + dy * dy

            segDX[i]      = dx
            segDY[i]      = dy
            segInvLen[i]  = if len > 0 then 1 / len else 0
            cumLen[i + 1] = cumLen[i] + len
            startPts[i * 2]     = p0.x
            startPts[i * 2 + 1] = p0.y

        {n, segDX, segDY, segInvLen, cumLen, startPts, totalLength: cumLen[n]}

    buildResult = ({n, segDX, segDY, segInvLen, cumLen, startPts, totalLength}) ->
        totalLength: totalLength

        offsetToPos: (offset, wrap = false) ->
            if wrap
                offset = offset % totalLength
                offset += totalLength if offset < 0
            else
                offset = Math.max 0, Math.min offset, totalLength

            lo = 0
            hi = n - 1
            while lo < hi
                mid = (lo + hi) >> 1
                if cumLen[mid + 1] < offset then lo = mid + 1 else hi = mid

            lo++ while lo < n - 1 and segInvLen[lo] is 0

            t  = Math.min 1, (offset - cumLen[lo]) * segInvLen[lo]
            i2 = lo * 2

            x: startPts[i2]     + t * segDX[lo]
            y: startPts[i2 + 1] + t * segDY[lo]


    # MAIN ########################################################################################

    wrap rawPairs
    .process buildGraph      # dedupe points into nodes, build a weighted edge graph
    .process longestChain    # pick the richest component, walk its longest path
    .process precompute      # build typed arrays for O(log n) offset lookups
    .process buildResult     # expose totalLength and offsetToPos
    .result