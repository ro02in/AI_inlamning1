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

    void addToMap(float x, float y, ObstacleType obstacleType) {
        int xCell = int(x / cellSize);
        int yCell = int(y / cellSize);
        if (xCell < 0 || xCell >= cols || yCell < 0 || yCell >= rows) return;
        grid[xCell][yCell] = new Cell(obstacleType);
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
                else if (c.obstacleType == ObstacleType.TANK) {
                    fill(255, 255, 0, 100); // Yellow
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

class Cell {
    ObstacleType obstacleType;

    Cell(ObstacleType obstacleType) {
        this.obstacleType = obstacleType;
    }
}
