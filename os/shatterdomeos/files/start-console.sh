#!/bin/bash
xset s off 2>/dev/null || true
xset -dpms 2>/dev/null || true
xset s noblank 2>/dev/null || true
exec /opt/shatterdome/bin/Shatterdome
