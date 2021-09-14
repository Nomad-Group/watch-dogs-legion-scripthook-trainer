local script = Script()

local entitiesSpawned = false

local function ProcessSpawnedEntity(ent)
    ScriptHook.SetEntityIsStatic(ent, true)
    ScriptHook.SetEntityIsPersistent(ent, true)
    ScriptHook.SetEntityPoolClearOnUnused(ent, true)
    ScriptHook.SetEntityIsPoolable(ent, true)
end

function script:OnWorldReadyCb()
    if entitiesSpawned then
        return
    end

    entitiesSpawned = true

    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 61.041107, 100.676811, 97.037544, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 59.283062, 100.735558, 97.037544, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 56.923973, 101.037971, 97.037544, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 54.909866, 101.099167, 97.037544, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 54.713245, 104.142189, 96.740112, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 54.873856, 106.920937, 96.740120, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 61.769840, 102.993286, 96.731827, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 61.880478, 105.561432, 96.730667, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 61.986755, 108.175316, 96.729485, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 55.075459, 109.015091, 96.740112, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 56.867367, 108.158875, 96.680130, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{2DC40874-9153-4576-9FFA-389C66F22F0F}", 59.753159, 107.971680, 96.680130, 0, 0, 0))

    ProcessSpawnedEntity(SpawnEntityFromArchetype("{7EF7747E-474F-49C5-9150-27D54DFF5E57}", 60.280064, 100.371002, 98.407829, 0, 0, 0))
    ProcessSpawnedEntity(SpawnEntityFromArchetype("{7EF7747E-474F-49C5-9150-27D54DFF5E57}", 55.855598, 100.699455, 98.513229, 0, 0, 0))
end