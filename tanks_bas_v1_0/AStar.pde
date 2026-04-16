//inspo from source https://www.geeksforgeeks.org/dsa/a-search-algorithm/

import java.util.*;

class AStar {
  Map map;
  int gridSize;

  class PathNode {
    int x, y;
    float g, h, f;
    PathNode parent;

    PathNode(int x, int y) {
      this.x = x;
      this.y = y;
    }
  }

  AStar(Map map, int gridSize) {
    this.map = map;
    this.gridSize = gridSize;
  }

  boolean isObstacle(int gx, int gy, boolean allowUnseen) {

    if (gx < 0 || gy < 0 || gx >= map.cols || gy >= map.rows)
      return true;

    Cell c = map.grid[gx][gy];

    if (c == null) return !allowUnseen;

    return c.obstacleType != ObstacleType.NONE;
  }

  PathNode getNode(ArrayList<PathNode> list, int x, int y) {
    for (PathNode n : list) {
      if (n.x == x && n.y == y) return n;
    }
    return null;
  }

  ArrayList<Node> findPath(Node start, Node goal, boolean allowUnseen) {

    ArrayList<PathNode> openSet   = new ArrayList<PathNode>();
    ArrayList<PathNode> closedSet = new ArrayList<PathNode>();

    PathNode startN = new PathNode(start.x, start.y);
    PathNode goalN  = new PathNode(goal.x,  goal.y);

    startN.g = 0;
    startN.h = heuristic(startN, goalN);
    startN.f = startN.g + startN.h;

    openSet.add(startN);

    while (!openSet.isEmpty()) {

      PathNode current = openSet.get(0);
      for (PathNode n : openSet) {
        if (n.f < current.f) current = n;
      }

      if (current.x == goalN.x && current.y == goalN.y) {
        ArrayList<Node> path = new ArrayList<Node>();
        PathNode temp = current;
        while (temp != null) {
          path.add(new Node(temp.x, temp.y));
          temp = temp.parent;
        }
        Collections.reverse(path);
        return path;
      }

      openSet.remove(current);
      closedSet.add(current);

      int[][] directions = {
        {1,0},{-1,0},{0,1},{0,-1},
        {1,1},{-1,1},{1,-1},{-1,-1}
      };

      for (int[] dir : directions) {
        int nx = current.x + dir[0];
        int ny = current.y + dir[1];

        if (isObstacle(nx, ny, allowUnseen)) continue;
        if (getNode(closedSet, nx, ny) != null) continue;

        float moveCost = (dir[0] != 0 && dir[1] != 0) ? 1.414 : 1.0;
        float tentativeG = current.g + moveCost;

        PathNode neighbor = getNode(openSet, nx, ny);

        if (neighbor == null) {
          neighbor       = new PathNode(nx, ny);
          neighbor.g     = tentativeG;
          neighbor.h     = heuristic(neighbor, goalN);
          neighbor.f     = neighbor.g + neighbor.h;
          neighbor.parent = current;
          openSet.add(neighbor);
        } else if (tentativeG < neighbor.g) {
          neighbor.parent = current;
          neighbor.g      = tentativeG;
          neighbor.f      = neighbor.g + neighbor.h;
        }
      }
    }

    return null;
  }

  float heuristic(PathNode a, PathNode b) {
    float dx = abs(a.x - b.x);
    float dy = abs(a.y - b.y);
    return max(dx, dy) + (1.414 - 1) * min(dx, dy);
  }
}
