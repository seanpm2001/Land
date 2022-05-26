#######################################################################################################################################################################################################
#
# Changes to this type
# General
#     2022-Mat-24: add abstract type for steady state mode
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Hierarchy of AbstractSteadyStateMode:
"""
abstract type AbstractSteadyStateMode end


#######################################################################################################################################################################################################
#
# Changes to this struct
# General
#     2022-May-24: add steady state mode
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Empty structure for steady state mode.

---
# Examples
```julia
mode = SteadyStateMode();
```
"""
struct SteadyStateMode <: AbstractSteadyStateMode end


#######################################################################################################################################################################################################
#
# Changes to this struct
# General
#     2022-May-24: add non-steady state mode
#
#######################################################################################################################################################################################################
"""

$(TYPEDEF)

Empty structure for non-steady state mode.

---
# Examples
```julia
mode = NonSteadyStateMode();
```
"""
struct NonSteadyStateMode <: AbstractSteadyStateMode end
