-------------------------------------------------
-------------------------------------------------
--
-- SpawnEquipment
--
-- stuck1a
--
-------------------------------------------------
-------------------------------------------------
local SpawnEquipmentData;  -- Reference object to the storage file
local sItemMappings;       -- The actual storage content
local SpawnEquipmentCommands = {};


-- Loads or creates the INI file which stores the player-item mappings
local function OnInitGlobalModData(isNewGame)
  SpawnEquipmentData = ModData.getOrCreate("SpawnEquipmentData");
  local oFileReader = getFileReader("SpawnEquipmentData.ini", true);
  local aLines = {};
  local sLine = oFileReader:readLine(); -- FIXME: Ist readLine hier wirklich sinnvoll? Ich habe Subtables, besser wäre eigentlich sowas wie readAll()
  while sLine do
    table.insert(aLines, sLine);
    sLine = oFileReader:readLine();  -- TODO: Test, if this is really required
  end
  oFileReader:close();
  sItemMappings = loadstring(table.concat(aLines))() or {["Bad configuration"] = {}};  -- FIXME: Concat ???
end


-- Checks, if the user already has a safehouse (own/shared)
local function hasSafehouseAccess(sUsername)
  local aSafehouses = SafeHouse.getSafehouseList();
  for i = 0, aSafehouses:size() - 1, 1 do
    local aPlayers = aSafehouses:get(i):getPlayers();
    for j = 0, aPlayers:size() - 1, 1 do
      if aPlayers:get(j) == sUsername then
        return true;
      end
    end
  end
  return false;
end


-- Stores the item instances of created start equipment
local function updateItemMapping(oPlayer, aItemInstances)
  SpawnEquipmentData[oPlayer:getUsername()] = aItemInstances;
end


-- Attempts to load the user-item mappings by creating a reference to the data on sItemMappings
-- TODO: Check, if this is actually required
function SpawnEquipmentCommands.load(sModule, sCommand, oPlayer, aArgs)
  sendServerCommand(oPlayer, sModule, sCommand, sItemMappings);
end


-- Removes any still existing start equipment of the player
local function removeStartEquipment(oPlayer)

end



-- Adds the configured start equipment to the inventory
local function addStartEquipment(oPlayer)
  local oInventory = oPlayer:getInventory();
  local aItemNames = luautils.split(SandboxVars.SpawnEquipmentNoFool.itemList, "|");
  local aItemInstances = {};
  for i = 0, aItemNames:size() - 1, 1 do
    table.insert(aItemInstances, oInventory:AddItem(aItemNames:get(i)));
  end
  updateItemMapping(oPlayer, aItemInstances);
end


-- OnCreatePlayer handler - checks, if the player will receive the equipment or not
local function init(iPlayerIndex, oPlayer)
  if SandboxVars.SpawnEquipmentNoFool.activateMod then
    if hasSafehouseAccess(oPlayer:getName()) == false then
      addStartEquipment(oPlayer);
    end
  end
end


-------------------------------------------------
-------------------------------------------------
-- TODO: Check, if this is actually required
Events.OnClientCommand.Add(function(sModule, sCommand, oPlayer, aArgs)
  if sModule == "SpawnEquipment" and SpawnEquipmentCommands[sCommand] then
    SpawnEquipmentCommands[sCommand](sModule, sCommand, oPlayer, aArgs);
  end
end)

Events.OnInitGlobalModData.Add(OnInitGlobalModData);
Events.OnCreatePlayer.Add(init);
Events.OnPlayerDeath.Add(removeStartEquipment);
return SpawnEquipmentCommands;
-------------------------------------------------
-------------------------------------------------




