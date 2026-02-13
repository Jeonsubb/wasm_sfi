#pragma once

// Disable assertions for freestanding build to avoid pulling in __assert_fail/abort.
#define assert(x) ((void)0)
