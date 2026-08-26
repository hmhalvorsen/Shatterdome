#include "components/nanobots.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/shields.h"
#include <algorithm>

float nanobotTotalLevel(sp::ecs::Entity entity)
{
    float total = 0.0f;
    for (int n = 0; n < ShipSystem::COUNT; n++)
    {
        if (auto sys = ShipSystem::get(entity, ShipSystem::Type(n)))
            total += sys->nanobot_level;
    }
    return total;
}

float nanobotTotalRequest(sp::ecs::Entity entity)
{
    float total = 0.0f;
    for (int n = 0; n < ShipSystem::COUNT; n++)
    {
        if (auto sys = ShipSystem::get(entity, ShipSystem::Type(n)))
            total += sys->nanobot_request;
    }
    return total;
}

void applyNanobotRequest(sp::ecs::Entity entity, ShipSystem::Type system, float new_request)
{
    auto nanobots = entity.getComponent<Nanobots>();
    if (!nanobots) return;

    auto sys = ShipSystem::get(entity, system);
    if (!sys) return;

    new_request = std::clamp(new_request, 0.0f, nanobots->max_per_system);
    const float old_request = sys->nanobot_request;
    const float delta = new_request - old_request;

    if (delta > 0.0f)
    {
        const float other_requests = nanobotTotalRequest(entity) - old_request;
        const float max_add = nanobots->max - other_requests - old_request;
        const float add = std::min({delta, nanobots->pool, max_add});
        sys->nanobot_request = old_request + add;
        nanobots->pool -= add;
    }
    else if (delta < 0.0f)
    {
        sys->nanobot_request = new_request;
        if (sys->nanobot_level > new_request)
        {
            nanobots->pool += sys->nanobot_level - new_request;
            sys->nanobot_level = new_request;
        }
        nanobots->pool = std::min(nanobots->pool, nanobots->max - nanobotTotalLevel(entity));
    }
}
