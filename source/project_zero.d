module project_zero;

import game.game;
import raylib;

void main() {

    {
        Game game = new Game();
        game.run();
        game.cleanUp();
    }

    // Game cleans itself up
}
