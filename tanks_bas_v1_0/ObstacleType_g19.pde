enum ObstacleType {
    TREE(3),
    NEAR_TREE(2),
    TANK(1),
    NEAR_TANK(1),
    NONE(1);

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
}