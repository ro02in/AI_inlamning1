/**
 * Robin Karim, Oliwer Carpman, Rafal Galinski
 * Network to handle radio signals and distribute to nearby tanks in the same team and in the home base.
 */
static class GlobalRadioNetwork {
    private static GlobalRadioNetwork instance;

    private GlobalRadioNetwork() {}

    public static GlobalRadioNetwork getInstance() {
        if (instance == null) {
            instance = new GlobalRadioNetwork();
        }
        return instance;
    }

    public void sendRadio(Team team, PVector tankPosition, PVector reportedPosition, ObstacleType obstacleType) {
        for (Tank tank : allTanks) {
            if (tank.team.equals(team) && tank.isHomeBase()) {
                tank.radio.receiveRadio(reportedPosition, obstacleType, team); // Mottas av alla tanks i eget lag i hembas
            } else if (tank.team.equals(team) && tank.position.dist(tankPosition) < 75) {
                tank.radio.receiveRadio(reportedPosition, obstacleType, team); //Mottas av alla tanks i eget lag som är inom 75 pixlar från den som rapporterar
            } else if (!tank.team.equals(team) && tank.isEnemyBase()) {
                //tank.radio.receiveRadio(reportedPosition, obstacleType, team); Mottas av alla tanks i motståndarlaget i deras hembas, spionage, senare
            }
        }
    }
}