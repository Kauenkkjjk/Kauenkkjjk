local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local remotes = ReplicatedStorage:WaitForChild("MatchRemotes")
local startCameraAnim = remotes:WaitForChild("StartCameraAnimation")

local animando = false

local function ordenarAttachments(attachments)
    local ordenados = {}
    local numeros = {}
    local endAtt = nil
    
    for _, att in ipairs(attachments) do
        local nome = att.Name
        if nome == "End" then
            endAtt = att
        else
            local num = tonumber(nome)
            if num then
                table.insert(numeros, {att = att, num = num})
            end
        end
    end
    
    table.sort(numeros, function(a, b)
        return a.num < b.num
    end)
    
    for _, item in ipairs(numeros) do
        table.insert(ordenados, item.att)
    end
    
    if endAtt then
        table.insert(ordenados, endAtt)
    end
    
    return ordenados
end

local function animarCamera(mapa)
    if animando then return end
    animando = true
    
    local cameraFolder = mapa:FindFirstChild("Camera")
    if not cameraFolder then
        animando = false
        return
    end
    
    local attachments = {}
    for _, child in ipairs(cameraFolder:GetChildren()) do
        if child:IsA("Attachment") then
            table.insert(attachments, child)
        end
    end
    
    if #attachments == 0 then
        animando = false
        return
    end
    
    local ordenados = ordenarAttachments(attachments)
    
    camera.CameraType = Enum.CameraType.Scriptable
    
    local duracaoPonto = 1
    
    for i = 1, #ordenados do
        local att = ordenados[i]
        local cframe = att.WorldCFrame
        
        if i == 1 then
            camera.CFrame = cframe
        else
            local attAnterior = ordenados[i - 1]
            local cframeAnterior = attAnterior.WorldCFrame
            
            local tempoInicio = tick()
            local tempoFim = tempoInicio + duracaoPonto
            
            while tick() < tempoFim do
                local progresso = (tick() - tempoInicio) / duracaoPonto
                
                camera.CFrame = cframeAnterior:Lerp(cframe, progresso)
                
                RunService.RenderStepped:Wait()
            end
            
            camera.CFrame = cframe
        end
        
        task.wait(0.3)
    end
    
    camera.CameraType = Enum.CameraType.Custom
    animando = false
end

startCameraAnim.OnClientEvent:Connect(function(mapa)
    animarCamera(mapa)
end)