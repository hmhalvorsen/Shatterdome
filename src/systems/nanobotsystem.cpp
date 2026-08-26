#include "nanobotsystem.h"
#include "ecs/query.h"
#include "multiplayer_server.h"
#include "components/nanobots.h"
#include "components/reactor.h"
#include "components/beamweapon.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/impulse.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/shields.h"

static void updateNanobotsForSystem(Nanobots& nanobots, ShipSystem& system, float delta)
{
    if (system.nanobot_level < system.nanobot_request && nanobots.pool > 0.0f)
    {
        const float transfer = std::min({
            nanobots.deploy_rate_per_second * delta,
            system.nanobot_request - system.nanobot_level,
            nanobots.pool
        });
        system.nanobot_level += transfer;
        nanobots.pool -= transfer;
    }

    if (system.nanobot_level > 0.0f)
    {
        if (system.health < system.health_max)
        {
            const float repair = nanobots.repair_health_per_second * delta;
            system.health = std::min(system.health_max, system.health + repair);
        }
        if (system.hacked_level > 0.0f)
        {
            system.hacked_level -= nanobots.unhack_per_second * delta;
            if (system.hacked_level < 0.0f)
                system.hacked_level = 0.0f;
        }
        if (system.health < system.health_max || system.hacked_level > 0.0f)
        {
            system.nanobot_level -= nanobots.consume_rate_per_second * delta;
            if (system.nanobot_level < 0.0f)
                system.nanobot_level = 0.0f;
        }
    }
}

void NanobotSystem::update(float delta)
{
    if (!game_server) return;

    for (auto [entity, nanobots] : sp::ecs::Query<Nanobots>())
    {
        for (int n = 0; n < ShipSystem::COUNT; n++)
        {
            if (auto sys = ShipSystem::get(entity, ShipSystem::Type(n)))
                updateNanobotsForSystem(nanobots, *sys, delta);
        }

        // Recharge main pool for every nanobot consumed in sectors (1 exhausted -> 1 can refill).
        const float total_level = nanobotTotalLevel(entity);
        const float total_present = nanobots.pool + total_level;
        if (total_present < nanobots.max)
        {
            nanobots.pool += nanobots.recharge_rate_per_second * delta;
            const float pool_cap = nanobots.max - total_level;
            if (nanobots.pool > pool_cap)
                nanobots.pool = pool_cap;
        }

        nanobots.pool = std::clamp(nanobots.pool, 0.0f, nanobots.max - total_level);
    }
}
