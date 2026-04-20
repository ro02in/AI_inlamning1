// Robin Karim, Oliwer Carpman, Rafal Galinski
// Representation of a map with seen spaces on the map marked with obstacles
class Map {
    int cols, rows;
    int cellSize;
    Cell[][] grid;

    Map(int cellSize) {
        this.cellSize = cellSize;
        this.cols = width / cellSize;
        this.rows = height / cellSize;
        grid = new Cell[cols][rows];
    }

    /**
    * Marks a position to the map with the current observed obstacletype (which includes empty spaces).
    * Returns null if x and y is outside the map, otherwise true if a new obstacle is added, false if not
    */
    Boolean addToMap(float x, float y, ObstacleType obstacleType, float tankRadius) {
        int xCell = int(x / cellSize);
        int yCell = int(y / cellSize);
        if (xCell < 0 || xCell >= cols || yCell < 0 || yCell >= rows) {
            return null;
        }
        boolean changed = false;
        Cell existingCell = grid[xCell][yCell];
        if (existingCell != null) {
            ObstacleType prioritized = ObstacleType.highestPriority(obstacleType, existingCell.obstacleType);
            if (existingCell.obstacleType != prioritized) {
                existingCell.obstacleType = prioritized;
                changed = true;
            }
        } else {
            grid[xCell][yCell] = new Cell(obstacleType);
            changed = true;
        }

        if (changed) {
            if (obstacleType == ObstacleType.TREE) {
                addNearObstacle(xCell, yCell, tankRadius, ObstacleType.NEAR_TREE);
            }
            if (obstacleType == ObstacleType.TANK) {
                addNearObstacle(xCell, yCell, tankRadius, ObstacleType.NEAR_TANK);
            }
        }
        return changed;
    }

    // Adds a space near an obstacle within the tanks radius, marking it obstructed for A star algorithm since moving into it will cause collision.
    void addNearObstacle(int xCell, int yCell, float tankRadius, ObstacleType obstacleType) {
        float rCells = tankRadius / cellSize;
        int range = floor(rCells);
        for (int dx = -range; dx <= range; dx++) {
            for (int dy = -range; dy <= range; dy++) {
                if (dx == 0 && dy == 0) continue;
                if (sqrt(dx * dx + dy * dy) > rCells) continue;
                int nx = xCell + dx;
                int ny = yCell + dy;
                if (nx < 0 || nx >= cols || ny < 0 || ny >= rows) continue;
                Cell neighbor = grid[nx][ny];
                if (neighbor != null) {
                    neighbor.obstacleType = ObstacleType.highestPriority(neighbor.obstacleType, obstacleType);
                } else {
                    grid[nx][ny] = new Cell(obstacleType);
                }
            }
        }
    }

    void display() {
        pushStyle();
        noStroke();
        for (int x = 0; x < cols; x++) {
            for (int y = 0; y < rows; y++) {

                Cell c = grid[x][y];
                if (c == null) continue;

                float drawX = x * cellSize;
                float drawY = y * cellSize;

                if (c.obstacleType == ObstacleType.TREE) {
                    fill(255, 0, 0, 100); // Red
                    rect(drawX, drawY, cellSize, cellSize);
                }
                else if (c.obstacleType == ObstacleType.NEAR_TREE) {
                    fill(128, 0, 0, 50); // Light red
                    rect(drawX, drawY, cellSize, cellSize);
                }
                else if (c.obstacleType == ObstacleType.TANK) {
                    fill(255, 255, 0, 100); // Yellow
                    rect(drawX, drawY, cellSize, cellSize);
                }
                else if (c.obstacleType == ObstacleType.NEAR_TANK) {
                    fill(128, 255, 0, 50); // Light yellow
                    rect(drawX, drawY, cellSize, cellSize);
                }
                else if (c.obstacleType == ObstacleType.NONE) {
                    fill(0, 255, 0, 30); // Green
                    rect(drawX, drawY, cellSize, cellSize);
                }
            }
        }
        popStyle();
    }
}

// Cell could have been replaced with just obstacletype, but this provides a structure for adding costs etc. to cells.
class Cell {
    ObstacleType obstacleType;

    Cell(ObstacleType obstacleType) {
        this.obstacleType = obstacleType;
    }
}
