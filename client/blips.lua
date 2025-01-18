-- Create blips
CreateThread(function()
  for k, v in pairs(Config.Hospitals) do
    local blip = AddBlipForCoord(v.Blip.coords)

    SetBlipSprite(blip, v.Blip.sprite)
    SetBlipScale(blip, v.Blip.scale)
    SetBlipColour(blip, v.Blip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(TranslateCap('blip_hospital'))
    EndTextCommandSetBlipName(blip)
  end
end)