class Radio {
    private boolean isOn = true;
    private GlobalRadioNetwork globalNetwork;
    private Tank tank;
    private int cooldown = 0;

    public Radio(Tank tank) {
        this.tank = tank;
        this.globalNetwork = GlobalRadioNetwork.getInstance();
    }

    void reportRadio(PVector reportedPosition, ObstacleType obstacleType, int stepsFromLastGpsReading, Team team) {
        if (!isOn) return;
        if (cooldown > 0) return; // Still in cooldown period, ignore report
        cooldown = 50; // Set cooldown period
        int roughnessFactor = Math.min(stepsFromLastGpsReading / 3, 200);
        float roughX = reportedPosition.x + random(-roughnessFactor, roughnessFactor);
        float roughY = reportedPosition.y + random(-roughnessFactor, roughnessFactor);
        PVector roughReportedPos = new PVector(roughX, roughY);
        globalNetwork.sendRadio(team, tank.position, roughReportedPos, obstacleType);
    }

    void receiveRadio(PVector position, ObstacleType obstacleType, Team team) {
        if (!isOn) return;
        tank.map.addToMap(position.x, position.y, ObstacleType.toReportedType(obstacleType), tank.diameter / 2);
        if (obstacleType == ObstacleType.ENEMY_TANK) {
            if (tank.inCombatSince > 0) return; // Don't change target if already in combat
            tank.beginGoToPositionAStar(position);
        }
    }
}