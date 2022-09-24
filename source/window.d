module window;

import raylib;
import std.string: toStringz;
import std.stdio;
import std.conv: to;
import camera;

/// Wrapper object for Raylib window
public class Window {

    private int width = 0;
    private int height = 0;

    private string title = "D Raylib Zombie Game 0.0.0";

    private bool fullScreen = false;

    private bool updateWithFPS = true;

    this(int width, int height) {

        this.width = width;
        this.height = height;

        SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);

        InitWindow(this.width,this.height, this.convertTitle());
    }

    ~this() {
        CloseWindow();
    }

    void toggleFullScreen(GameCamera camera) {
        if (fullScreen) {
            ToggleFullscreen();
            SetWindowSize(this.width, this.height);
        } else {
            int currentMonitor = GetCurrentMonitor();
            SetWindowSize(GetMonitorWidth(currentMonitor), GetMonitorWidth(currentMonitor));
            ToggleFullscreen();
        }
        fullScreen = !fullScreen;   
    }

    float getWidth() {
        return this.width;
    }

    float getHeight() {
        return this.height;
    }

    void update(GameCamera camera) {
        if (!fullScreen) {
            if (IsWindowResized()) {
                this.width = GetRenderWidth();
                this.height = GetRenderHeight();

                writeln("Window was resized to: ", this.width, ", ", this.height);
            }

            if (updateWithFPS) {
                SetWindowTitle(this.convertTitleWithFPS());
            }
        }

    }

    private const(char)* convertTitleWithFPS(){
        return toStringz(this.title ~ " | FPS: " ~ to!string(GetFPS()));
    }


    private const(char)* convertTitle(){
        return toStringz(this.title);
    }
}