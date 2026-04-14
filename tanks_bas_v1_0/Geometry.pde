class Geometry {

    List<Edge> edgesBetweenPointAndSprite(PVector point, Sprite sprite, float inflateRadius) {
        List<Edge> result = new ArrayList<>();

        float cx = sprite.position.x;
        float cy = sprite.position.y;
        float r = sprite.getDiameter() / 2f + inflateRadius;

        float dx = point.x - cx;
        float dy = point.y - cy;
        float d = (float)Math.sqrt(dx * dx + dy * dy);  

        // Ingen tangent om punkten är inne i eller på cirkeln
        if (d <= r) {
            return result;
        }

        float theta = (float)Math.atan2(dy, dx);
        float alpha = (float)Math.acos(r / d);

        float t1x = cx + r * (float)Math.cos(theta + alpha);
        float t1y = cy + r * (float)Math.sin(theta + alpha);
        float t2x = cx + r * (float)Math.cos(theta - alpha);
        float t2y = cy + r * (float)Math.sin(theta - alpha);

        result.add(new Edge(point, new PVector(t1x, t1y)));
        result.add(new Edge(point, new PVector(t2x, t2y)));

        return result;
    }

    List<Edge> tangentsBetweenSprites(Sprite s1, Sprite s2, float inflateRadius) {
        List<Edge> result = new ArrayList<>();

        float dx = s2.position.x - s1.position.x;
        float dy = s2.position.y - s1.position.y;
        float d2 = dx * dx + dy * dy;
        float d = (float)Math.sqrt(d2);

        // Om cirklarna ligger på samma punkt → hoppa
        if (d == 0) return result;

        float r1 = s1.getDiameter() / 2f + inflateRadius;
        float r2 = s2.getDiameter() / 2f + inflateRadius;

        for (int sign1 = -1; sign1 <= 1; sign1 += 2) { // yttre/inre
            float r = r1 - sign1 * r2;

            float h2 = d2 - r * r;
            if (h2 < 0) continue; // inga tangenter i detta fall

            float h = (float)Math.sqrt(h2);

            for (int sign2 = -1; sign2 <= 1; sign2 += 2) {
                float nx = (dx * r + sign2 * dy * h) / d2;
                float ny = (dy * r - sign2 * dx * h) / d2;

                // Punkt på cirkel 1
                float p1x = s1.position.x + r1 * nx;
                float p1y = s1.position.y + r1 * ny;

                // Punkt på cirkel 2
                float p2x = s2.position.x + sign1 * r2 * nx;
                float p2y = s2.position.y + sign1 * r2 * ny;

                result.add(new Edge(
                    new PVector(p1x, p1y),
                    new PVector(p2x, p2y)
                ));
            }
        }

        return result;
    }

    List<Edge> clockwiseArcEdgesOnSprite(Sprite sprite, List<PVector> pointsOnSprite, float inflateRadius) {
        List<Edge> result = new ArrayList<>();
    
        if (pointsOnSprite == null || pointsOnSprite.size() < 2) {
            return result;
        }
    
        PVector center = sprite.position;
        float radius = sprite.getDiameter() / 2f + inflateRadius;
    
        List<PVector> sorted = new ArrayList<>(pointsOnSprite);
    
        // Sortera i stigande vinkel = moturs ordning
        sorted.sort((a, b) -> {
            float angleA = atan2(a.y - center.y, a.x - center.x);
            float angleB = atan2(b.y - center.y, b.x - center.x);
    
            if (angleA < 0) angleA += TWO_PI;
            if (angleB < 0) angleB += TWO_PI;
    
            return Float.compare(angleA, angleB);
        });
    
        int n = sorted.size();
    
        for (int i = 0; i < n; i++) {
            PVector from = sorted.get(i);
    
            // Föregående i CCW-sorterad lista = nästa medurs
            PVector toPos = sorted.get((i - 1 + n) % n);
    
            float aFrom = atan2(from.y - center.y, from.x - center.x);
            float aTo   = atan2(toPos.y - center.y, toPos.x - center.x);
    
            if (aFrom < 0) aFrom += TWO_PI;
            if (aTo < 0) aTo += TWO_PI;
    
            // Medurs vinkel från from till to
            float clockwiseDelta = aFrom - aTo;
            if (clockwiseDelta < 0) clockwiseDelta += TWO_PI;
    
            float arcLength = radius * clockwiseDelta;
    
            result.add(new Edge(from, toPos, arcLength, sprite.position, radius));
        }
    
        return result;
    }
}