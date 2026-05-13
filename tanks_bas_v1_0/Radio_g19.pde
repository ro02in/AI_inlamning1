// Robin Karim, Oliwer Carpman, Rafal Galinski
// A single radio unit for each tank, can send and receive radio signals through GlobalRadioNetwork.
class Radio {
    private boolean isOn = true;
    private GlobalRadioNetwork globalNetwork;
    private Tank tank;
    int cooldown = 0; // Cooldown timer to prevent spamming reports

    public Radio(Tank tank) {
        this.tank = tank;
        this.globalNetwork = GlobalRadioNetwork.getInstance();
    }

    // Send a report through the radio unit
    void reportRadio(PVector reportedPosition, ObstacleType obstacleType, int stepsFromLastGpsReading, Team team) {
        if (!isOn) return;
        if (cooldown > 0) return; // Still in cooldown period, ignore report
        cooldown = 20; // Set cooldown period
        int roughnessFactor = Math.min(stepsFromLastGpsReading / 3, 200);
        float roughX = reportedPosition.x + random(-roughnessFactor, roughnessFactor);
        float roughY = reportedPosition.y + random(-roughnessFactor, roughnessFactor);
        PVector roughReportedPos = new PVector(roughX, roughY);
        globalNetwork.sendRadio(team, tank.position, roughReportedPos, obstacleType);
    }

    // Receive a radio signal, and add the reported position to the map. If the reported obstacle is an enemy tank, begin moving towards the position.
    void receiveRadio(PVector position, ObstacleType obstacleType, Team team) {
        if (!isOn) return;
        tank.map.addToMap(position.x, position.y, ObstacleType.toReportedType(obstacleType), tank.diameter / 2);
        if (obstacleType == ObstacleType.ENEMY_TANK) {
            if (tank.inCombatSince > 0) return; // Don't change target if already in combat
            tank.beginGoToPositionAStar(position);
        }
    }
}