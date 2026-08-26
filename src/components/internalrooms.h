#pragma once

#include "components/shipsystem.h"
#include <vector>

// Internal composition of a ship (room layout for templates; repair crew removed).
class InternalRooms
{
public:
    struct Room {
        glm::ivec2 position;
        glm::ivec2 size;
        ShipSystem::Type system = ShipSystem::Type::None;
    };
    struct Door {
        glm::ivec2 position;
        bool horizontal;
    };

    std::vector<Room> rooms;
    bool rooms_dirty = true;
    std::vector<Door> doors;
    bool doors_dirty = true;

    glm::ivec2 roomMin();
    glm::ivec2 roomMax();
    ShipSystem::Type getSystemAtRoom(glm::ivec2 pos);
};
