module player;

import raylib;
import std.stdio;

import game;

public class Player {

    private Game game;

    this(Game game) {
        this.game = game;
    }
}