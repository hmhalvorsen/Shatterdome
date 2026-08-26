#include "multiplayer/nanobots.h"
#include "multiplayer.h"


BASIC_REPLICATION_IMPL(NanobotsReplication, Nanobots)
    BASIC_REPLICATION_FIELD(max);
    BASIC_REPLICATION_FIELD(max_per_system);
    BASIC_REPLICATION_FIELD(pool);
    BASIC_REPLICATION_FIELD(recharge_rate_per_second);
    BASIC_REPLICATION_FIELD(deploy_rate_per_second);
    BASIC_REPLICATION_FIELD(repair_health_per_second);
    BASIC_REPLICATION_FIELD(consume_rate_per_second);
    BASIC_REPLICATION_FIELD(unhack_per_second);
}
