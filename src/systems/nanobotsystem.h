#pragma once

#include <engine.h>

class NanobotSystem : public sp::ecs::System
{
public:
    virtual void update(float delta) override;
};
