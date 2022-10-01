module player;

import raylib;
import std.stdio;

import game;
import world;

public class Player {

    private Game game;

    private Entity entity;

    private immutable float eyeHeight = 0.25;

    this(Game game) {
        this.game = game;

        this.entity = new Entity(Vector3(50,20,50), Vector3(0.5,1,0.5),Vector3(0,0,0));

        game.world.addEntity(this.entity);
    }

    void update() {
        Vector3 direction = game.camera3d.getForward();

        writeln(direction);

        Vector3 position = this.entity.getPosition();

        position.y += this.eyeHeight;

        game.camera3d.setPosition(position);

    }
}