#pragma once

#include "ecs/entity.h"
#include "components/shipsystem.h"

// Nanobot repair pool — engineers allocate bots from the main reserve to ship systems (sectors).
class Nanobots
{
public:
    float max = 10.0f;
    float max_per_system = 10.0f;
    float pool = 10.0f;
    float recharge_rate_per_second = 0.8f;
    float deploy_rate_per_second = 3.0f;
    float repair_health_per_second = 0.06f;
    float consume_rate_per_second = 2.5f;
    float unhack_per_second = 0.007f;
};

float nanobotTotalLevel(sp::ecs::Entity entity);
float nanobotTotalRequest(sp::ecs::Entity entity);
void applyNanobotRequest(sp::ecs::Entity entity, ShipSystem::Type system, float new_request);
