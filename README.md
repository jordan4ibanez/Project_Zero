# Project Zero
 An open source post apocalyptic first person survival game written in D with Raylib.

### **Note:** Recommend utilizing LDC to compile this game!

### **Please note:** I am a programmer, not an artist. The base game will be an absolute bodge of assets for now.

I'm also practicing pure OOP for this. So it might look strange!

## Project goals:
0. Fun
1. Clean code
2. Easy to understand
3. Built on mods (But what language for modding, I don't know)
4. Map editor, somehow
5. Optimizated

## Project libraries:

- **Rendering & input**: Raylib
- **Physics**: bindbc-newton
- **Audio**: bindbc-openal

Some notes:
### AI/Physics Hybrid
Entities (Zombies, players, etc) exist as an object which holds a pointer to data in the physics engine. This is mutually shared. The physics engine will never delete this entity unless the entity's destructor is called. Now this will be a bit complex.

Let's say this happens when a zombie dies:

1. Zombie shell entity (AI) is at health 0.
2. Data container scans it, finds it to be dead.
3. Data container finds it's death animation to be complete.
4. Zombie's entity (Physics Engine) is put to sleep, no more collision.
5. Every so often the data container will see if there is a player within...50 meters of it.
6. No player is found within this!
7. Data container deletes the zombie. This calls the destructor for it.
8. Destructor tells the physics engine to remove the entity.
9. Zombie is poofed into GC collection positive scan. Adios.

Players will be handled slightly differently. Connect/disconnect is their primary physics engine container mutation.