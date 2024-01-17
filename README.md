# Smart Room Case Study

**Things**
- Every device is controlled by a separate WoT thing, featuring its own TD
- Lamp Thing
    - an example is provided on the repo – Activity-02
- Presence Detection Sensor Thing
- Luminosity Level Sensor Thing

**Smart-Room Agent**

implementing the smart behaviour in Activity #01:
- the lamp should be automatically turned on and off depending on the presence of
users in the room and the luminosity level
- if no one is in the room, the light should be off
- if someone is in the room, the light should be automatically turned on, if
the luminosity level is < T


## First step -- Smart Room with agents

- Designing and implementing the smart room agent as a Jason agent in a JaCaMo MAS
- using artifacts to implement proxies to interact with thing services

## Second step –- Extending the view -- Smart Building with DT
- Designing and implementing a smart building as a JaCaMo MAS
    - using different workspaces to distribute the MAS
        - a workspace for each room
        - multiple smart room agents each running on a different workspace
- Adding a semantic layer – ref. Prof. Ciortea's seminar / lecture
- Exploiting MAS organisations to model agents playing different roles & different missions