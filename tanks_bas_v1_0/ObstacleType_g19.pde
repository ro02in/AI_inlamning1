// Robin Karim, Oliwer Carpman, Rafal Galinski
enum ObstacleType {
    TREE(6, true),
    DEAD_TANK(5, true),
    NEAR_TREE(4, true),
    NEAR_DEAD_TANK(3, true),
    FRIENDLY_TANK(2, true),
    REPORTED_DEAD_TANK(1, false),
    ENEMY_TANK(1, true),
    NEAR_TANK(1, true),
    REPORTED_FRIENDLY_TANK(1, false),
    REPORTED_ENEMY_TANK(1, false),
    NONE(1, false),
    REPORTED_TREE(0, false);

    private final int priority;
    private final boolean isObstacle;

    ObstacleType(int priority, boolean isObstacle) {
        this.priority = priority;
        this.isObstacle = isObstacle;
    }

    public int getPriority() {
        return priority;
    }

    public boolean isObstacle() {
        return isObstacle;
    }

    // Type 1 should be the most recently seen obstacle type
    public static ObstacleType highestPriority(ObstacleType type1, ObstacleType type2) {
        if (type1.getPriority() == type2.getPriority()) {
            return type1;
        }
        if (type1.getPriority() > type2.getPriority()) {
            return type1;
        } else {
            return type2;
        }
    }

    public static ObstacleType toReportedType(ObstacleType type) {
        switch (type) {
            case FRIENDLY_TANK:
                return REPORTED_FRIENDLY_TANK;
            case ENEMY_TANK:
                return REPORTED_ENEMY_TANK;
            case TREE:
                return REPORTED_TREE;
            default:
                return type;
        }
    }
}