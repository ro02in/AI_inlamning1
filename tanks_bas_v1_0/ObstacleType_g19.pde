// Robin Karim, Oliwer Carpman, Rafal Galinski
enum ObstacleType {
    TREE(3),
    NEAR_TREE(2),
    FRIENDLY_TANK(1),
    ENEMY_TANK(1),
    NEAR_TANK(1),
    REPORTED_FRIENDLY_TANK(1),
    REPORTED_ENEMY_TANK(1),
    NONE(1),
    REPORTED_TREE(0);

    private final int priority;

    ObstacleType(int priority) {
        this.priority = priority;
    }

    public int getPriority() {
        return priority;
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