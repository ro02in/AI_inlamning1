//inspo from source https://www.geeksforgeeks.org/dsa/a-search-algorithm/


import java.util.*;

class AStar {

  ArrayList<Node> findPath(Node start, Node goal) {

    ArrayList<Node> openSet = new ArrayList<Node>();
    ArrayList<Node> closedSet = new ArrayList<Node>();

    start.g = 0;
    start.h = heuristic(start, goal);
    start.f = start.g + start.h;

    openSet.add(start);

    while (!openSet.isEmpty()) {

      Node current = openSet.get(0);

      for (Node n : openSet) {
        if (n.f < current.f) {
          current = n;
        }
      }

      if (current.x == goal.x && current.y == goal.y) {

        ArrayList<Node> path = new ArrayList<Node>();
        Node temp = current;

        while (temp != null) {
          path.add(temp);
          temp = temp.parent;
        }

        Collections.reverse(path);
        return path;
      }

      openSet.remove(current);
      closedSet.add(current);

      int[][] directions = {
        {1,0},{-1,0},{0,1},{0,-1}
      };

      for (int[] dir : directions) {

        int nx = current.x + dir[0];
        int ny = current.y + dir[1];

        // prevent searching outside grid
        int cols = width / 20;
        int rows = height / 20;

        if (nx < 0 || ny < 0 || nx >= cols || ny >= rows) {
          continue;
        }

        Node neighbor = new Node(nx, ny);

        boolean skip = false;

        for (Node n : closedSet) {
          if (n.x == neighbor.x && n.y == neighbor.y) {
            skip = true;
            break;
          }
        }

        if (skip) continue;

        float tentativeG = current.g + 1;

        boolean inOpen = false;

        for (Node n : openSet) {
          if (n.x == neighbor.x && n.y == neighbor.y) {
            neighbor = n;
            inOpen = true;
            break;
          }
        }

        if (!inOpen || tentativeG < neighbor.g) {

          neighbor.parent = current;
          neighbor.g = tentativeG;
          neighbor.h = heuristic(neighbor, goal);
          neighbor.f = neighbor.g + neighbor.h;

          if (!inOpen) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return null;
  }

  float heuristic(Node a, Node b) {
    return abs(a.x - b.x) + abs(a.y - b.y);
  }
}