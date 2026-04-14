class Graph {
    HashSet<PVector> nodes;
    HashSet<Edge> edges;

    Graph() {
        nodes = new HashSet<>();
        edges = new HashSet<>();
    }

    public List<Edge> findPathAStar(PVector from, PVector goal) {
        List<Edge> path = new ArrayList<Edge>();
        if (from == null || goal == null) return path;

        // Bygg adjacency matrix
        HashMap<PVector, ArrayList<Edge>> adj = new HashMap<PVector, ArrayList<Edge>>();
        for (Edge e : edges) {
            if (!adj.containsKey(e.from)) adj.put(e.from, new ArrayList<Edge>());
            adj.get(e.from).add(e);

            if (!adj.containsKey(e.toPos)) adj.put(e.toPos, new ArrayList<Edge>());
            adj.get(e.toPos).add(new Edge(e.toPos, e.from, e.cost));
        }

        PVector start = resolveNodeRef(from);
        PVector end = resolveNodeRef(goal);
        if (start == null || end == null) return path;

        ArrayList<PVector> openSet = new ArrayList<PVector>();
        HashSet<PVector> closedSet = new HashSet<PVector>();

        HashMap<PVector, Float> gScore = new HashMap<PVector, Float>();
        HashMap<PVector, Float> fScore = new HashMap<PVector, Float>();
        HashMap<PVector, Edge> cameFromEdge = new HashMap<PVector, Edge>();

        openSet.add(start);
        gScore.put(start, 0f);
        fScore.put(start, heuristic(start, end));

        while (!openSet.isEmpty()) {
            PVector current = openSet.get(0);
            float bestF = getOrInfinity(fScore, current);
            for (PVector n : openSet) {
                float fn = getOrInfinity(fScore, n);
                if (fn < bestF) {
                    bestF = fn;
                    current = n;
                }
            }

            if (samePos(current, end)) {
                // Rekonstruera kanter (end -> start) och vänd sedan
                PVector cursor = current;
                while (!samePos(cursor, start)) {
                    Edge e = cameFromEdge.get(cursor);
                    if (e == null) break;
                    path.add(e);
                    cursor = e.from;
                }
                Collections.reverse(path);
                return path;
            }

            openSet.remove(current);
            closedSet.add(current);

            ArrayList<Edge> out = adj.get(current);
            if (out == null) continue;

            for (Edge e : out) {
                PVector neighbor = e.toPos;
                if (closedSet.contains(neighbor)) continue;

                float tentativeG = getOrInfinity(gScore, current) + e.cost;
                if (!openSet.contains(neighbor)) {
                    openSet.add(neighbor);
                } else if (tentativeG >= getOrInfinity(gScore, neighbor)) {
                    continue;
                }

                cameFromEdge.put(neighbor, e);
                gScore.put(neighbor, tentativeG);
                fScore.put(neighbor, tentativeG + heuristic(neighbor, end));
            }
        }

        // Ingen väg hittad
        return path;
    }

    PVector resolveNodeRef(PVector p) {
        if (nodes.contains(p)) return p;
        for (PVector n : nodes) {
            if (samePos(n, p)) return n;
        }
        return null;
    }

    boolean samePos(PVector a, PVector b) {
        if (a == b) return true;
        if (a == null || b == null) return false;
        return abs(a.x - b.x) < 0.0001f && abs(a.y - b.y) < 0.0001f;
    }

    float heuristic(PVector a, PVector b) {
        return PVector.dist(a, b);
    }

    float getOrInfinity(HashMap<PVector, Float> map, PVector key) {
        Float v = map.get(key);
        return (v == null) ? Float.POSITIVE_INFINITY : v.floatValue();
    }
}

class Node {
    PVector position;
    float g, h, f;
    Node parent;

    Node(PVector position, PVector goal) {
        this.position = position;
        this.g = 0;
        this.h = heuristic(position, goal);
        this.f = 0;
        this.parent = null;
    }

    float heuristic(PVector a, PVector b) {
        float xDistance = a.x - b.x;
        float yDistance = a.y - b.y;
        float distancePythagoras = (float)Math.sqrt((xDistance * xDistance) + (yDistance * yDistance));
        return distancePythagoras;
    }
}

class Edge {
    PVector from;
    PVector toPos;
    float cost;
    PVector center; // Null om inte en cirkel
    float radius; // Null om inte en cirkel

    Edge(PVector from, PVector toPos) {
        this.from = from;
        this.toPos = toPos;
        this.cost = PVector.dist(from, toPos);
    }

    Edge(PVector from, PVector toPos, float cost) {
        this.from = from;
        this.toPos = toPos;
        this.cost = cost;
    }

    Edge(PVector from, PVector toPos, float cost, PVector center, float radius) {
        this.from = from;
        this.toPos = toPos;
        this.cost = cost;
        this.center = center;
        this.radius = radius;
    }
}