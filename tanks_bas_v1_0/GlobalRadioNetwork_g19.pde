static class GlobalRadioNetwork {
    private static GlobalRadioNetwork instance;

    private GlobalRadioNetwork() {}

    public static GlobalRadioNetwork getInstance() {
        if (instance == null) {
            instance = new GlobalRadioNetwork();
        }
        return instance;
    }

    public void sendRadio(Team team, PVector position, ObstacleType obstacleType) {
        for (Tank tank : allTanks) {
            if (tank.team.equals(team) && tank.isHomeBase()) {
                tank.radio.receiveRadio(position, obstacleType, team); // Mottas av alla tanks i eget lag i hembas
            } else if (!tank.team.equals(team) && tank.isEnemyBase()) {
                //tank.radio.receiveRadio(position, obstacleType, team); Mottas av alla tanks i motståndarlaget i deras hembas, spionage, senare
            }
        }
    }
}