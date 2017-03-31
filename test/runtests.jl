using Mocking

opts = Base.JLOptions()
use_compilecache = isdefined(opts, :use_compilecache) && Bool(opts.use_compilecache)
if use_compilecache
    warn("Julia not started with `--compilecache=no`. Disabling tests that require Mocking")
else
    Mocking.enable()
end

using Base.Test
using TimeZones
import TimeZones: PKG_DIR, ARCHIVE_DIR
import TimeZones.TZData: ZoneDict, RuleDict, tzparse, resolve, build
import Compat: @compat

const TZDATA_VERSION = "2016j"
const TZ_SOURCE_DIR = get(ENV, "TZ_SOURCE_DIR", joinpath(PKG_DIR, "test", "tzsource"))
const TZFILE_DIR = joinpath(PKG_DIR, "test", "tzfile")
const TEST_REGIONS = ("asia", "australasia", "europe", "northamerica")

isdir(ARCHIVE_DIR) || mkdir(ARCHIVE_DIR)
isdir(TZ_SOURCE_DIR) || mkdir(TZ_SOURCE_DIR)

# By default use a specific version of the tz database so we just testing for TimeZones.jl
# changes and not changes to the tzdata.
build(TZDATA_VERSION, TEST_REGIONS, ARCHIVE_DIR, TZ_SOURCE_DIR)

# For testing we'll reparse the tzdata every time to instead of using the serialized data.
# This should make the development/testing cycle simplier since you won't be forced to
# re-build the cache every time you make a change.
#
# Note: resolving only the time zones we want is much faster than running compile which
# recompiles all the time zones.
tzdata = Dict{AbstractString,Tuple{ZoneDict,RuleDict}}()
for name in TEST_REGIONS
    tzdata[name] = tzparse(joinpath(TZ_SOURCE_DIR, name))
end

include("utils.jl")
include("timeoffset.jl")
include("compile.jl")
include("TZData.jl")
include("utcoffset.jl")
include("types.jl")
include("interpret.jl")
include("accessors.jl")
include("arithmetic.jl")
include("io.jl")
include("tzfile.jl")
include("adjusters.jl")
include("conversions.jl")
include("ranges.jl")
include("local.jl")
!use_compilecache && include("local_mocking.jl")
include("discovery.jl")
VERSION >= v"0.5.0-dev+5244" && include("rounding.jl")
include("TimeZones.jl")
