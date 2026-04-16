enum ObstacleType {
    TREE(5),
    NEAR_TREE(4),
    TANK(3),
    NEAR_TANK(2),
    NONE(1);

    private final int priority;

    ObstacleType(int priority) {
        this.priority = priority;
    }

    public int getPriority() {
        return priority;
    }

    public static ObstacleType highestPriority(ObstacleType type1, ObstacleType type2) {
        if (type1.getPriority() > type2.getPriority()) {
            return type1;
        } else {
            return type2;
        }
    }
}