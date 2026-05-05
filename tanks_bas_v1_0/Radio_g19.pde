class Radio {
    private boolean isOn = true;
    private GlobalRadioNetwork globalNetwork;
    private Tank tank;

    public Radio(Tank tank) {
        this.tank = tank;
        this.globalNetwork = GlobalRadioNetwork.getInstance();
    }

    void reportRadio(PVector position, ObstacleType obstacleType, int stepsFromLastGpsReading, Team team) {
        if (!isOn) return;
        int roughnessFactor = Math.min(stepsFromLastGpsReading / 3, 200);
        float roughX = position.x + random(-roughnessFactor, roughnessFactor);
        float roughY = position.y + random(-roughnessFactor, roughnessFactor);
        PVector roughPos = new PVector(roughX, roughY);
        globalNetwork.sendRadio(team, roughPos, obstacleType);
    }

    void receiveRadio(PVector position, ObstacleType obstacleType, Team team) {
        if (!isOn) return;
        tank.map.addToMap(position.x, position.y, ObstacleType.toReportedType(obstacleType), tank.diameter / 2);
        if (obstacleType == ObstacleType.ENEMY_TANK) {
            tank.beginGoToPositionAStar(position);
        }
    }
}