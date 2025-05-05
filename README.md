# Fishing 99

## Sources:
### Sprites
- Fishest Gup - SeeroftheNight
- menubg.png - Mooseadee https://gitlab.com/RachelWilShaSingh 

Ideas:
- Instead of my inital plan of moving everything on the screen up and down, when the cast is made, the hook can be sent to the bottom of the screen which would transition the player to the fishing screen.
- Is adding the ability to go deeper into the water a good idea? It could be too complicated to track the position of the hook and fish.
- The Fishing Contest takes place in the water cooling system of a data center. The fish are all made of corrupteddata.


-- Current State --

### Step 4.1 – Define Fish Data

* Create `data/FishTypes.lua`: define species, value, depth, sprite.
* Use a few test entries (e.g., bass, tuna, boot).

### Step 4.2 – Add Fish Sprites

* Implement `FishManager.lua`.
* At spawn depth, activate fish with horizontal swim pattern (sinusoidal or linear).
* Pool fish sprites using `SpritePool.lua`.
