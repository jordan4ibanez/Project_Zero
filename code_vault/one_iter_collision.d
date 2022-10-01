module code_vault.one_iter_collision;

void main () {
    /* This ends up making entities climb onto each other unfortunately, corner snap. Great in your OS, not in your physics
                foreach (Entity otherEntity; this.entities) {

                    BoundingBox thisBox = thisEntity.getBoundingBox();

                    /// This is a series of optimizations
                    if (thisEntity != otherEntity) {

                        if (Vector3Distance(thisEntity.position, otherEntity.position) < 3) {

                            BoundingBox otherBox = otherEntity.getBoundingBox();

                            if (CheckCollisionBoxes(thisBox, otherBox)) {
                                /// End optimizations

                                float diffX = thisEntity.position.x - otherEntity.position.x;
                                float diffY = thisEntity.position.y - otherEntity.position.y;
                                float diffZ = thisEntity.position.z - otherEntity.position.z;

                                float absDiffX = abs(diffX);
                                float absDiffY = abs(diffY);
                                float absDiffZ = abs(diffZ);

                                if (absDiffX >= absDiffY && absDiffX > absDiffZ) {
                                    // x collision
                                    writeln("X collision");
                                    float diff = (thisEntity.size.x + otherEntity.size.x + 0.001) * signum(diffX);
                                    thisEntity.position.x = otherEntity.position.x + diff;
                                    thisEntity.velocity.x = 0;
                                } else if (absDiffZ >= absDiffX && absDiffZ >= absDiffY) {
                                    // z collision
                                    writeln("Z collision");
                                    float diff = (thisEntity.size.z + otherEntity.size.z + 0.001) * signum(diffZ);
                                    thisEntity.position.z = otherEntity.position.z + diff;
                                    thisEntity.velocity.z = 0;

                                } else {
                                    // y collision
                                    writeln("Y collision");

                                    float diff = (thisEntity.size.y + otherEntity.size.y + 0.001) * signum(diffY);
                                    thisEntity.position.y = otherEntity.position.y + diff;
                                    thisEntity.velocity.y = 0;
                                }
                            }
                        }
                    }
                }
                */

}