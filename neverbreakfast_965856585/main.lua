local nobreak = RegisterMod("Never Breakfast!",1.0);

function nobreak:StopBreakfasting()
  local player = Isaac.GetPlayer(0);
  if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BREAKFAST) == 1 then
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_COLLECTIBLE and entities[i].SubType == CollectibleType.COLLECTIBLE_BREAKFAST then
        entities[i]:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, math.random(1,550), true)
      end
    end
  end
  if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BREAKFAST) > 1 then
    Isaac.ConsoleOutput(player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BREAKFAST))
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
    player.MaxHitPoints = player.MaxHitPoints - 1;
    player:AddCollectible(math.random(1,550), 12, true);
  end
end

nobreak:AddCallback(ModCallbacks.MC_POST_UPDATE, nobreak.StopBreakfasting);