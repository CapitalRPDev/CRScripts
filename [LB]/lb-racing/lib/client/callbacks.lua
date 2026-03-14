local CALLBACK_TIMEOUT <const> = 120

---@type { [number]: { cb: fun(...), event: string } }
local waitingCallbacks = {}

local function GenerateRequestId()
    local requestId = math.random(999999999)

    while waitingCallbacks[requestId] do
        requestId = math.random(999999999)
    end

    return requestId
end

---@param event string
---@param cb fun(...)
function TriggerCallback(event, cb, ...)
    local requestId = GenerateRequestId()

    waitingCallbacks[requestId] = { cb = cb, event = event }

    SetTimeout(CALLBACK_TIMEOUT * 1000, function()
        if waitingCallbacks[requestId] then
            infoprint("error", ("Callback ^1%s^7 timed out after %is"):format(event, CALLBACK_TIMEOUT))
            waitingCallbacks[requestId].cb(nil)
            waitingCallbacks[requestId] = nil
        end
    end)

    local payload = msgpack.pack_args(requestId, ...)
    local length = #payload

    if length > 64000 then
        debugprint("Using latent event for " .. event .. " due to payload size: " .. length)

        TriggerLatentServerEventInternal("lb-racing:cb:" .. event, payload, length, 10^6)
    else
        TriggerServerEventInternal("lb-racing:cb:" .. event, payload, length)
    end
end

---@param event string
function AwaitCallback(event, ...)
    local responsePromise = promise.new()

    TriggerCallback(event, function(...)
        responsePromise:resolve({ ... })
    end, ...)

    local result = Citizen.Await(responsePromise)

    return table.unpack(result)
end

RegisterNetEvent("lb-racing:cb:response", function(requestId, ...)
    local callback = waitingCallbacks[requestId]

    if callback then
        local success, errorMessage = pcall(callback.cb, ...)

        if not success then
            local stackTrace = Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())

            print(("^1SCRIPT ERROR: Callback response '%s' failed: %s^7\n%s"):format(callback.event, errorMessage or "", stackTrace or ""))
        end

        waitingCallbacks[requestId] = nil
    end
end)

---@type { [string]: true }
local registeredCallbacs = {}

---@param event string
---@param handler fun(...) : ...any
function RegisterClientCallback(event, handler)
    assert(type(event) == "string", "event must be a string")
    assert(type(handler) == "function", "handler must be a function")
    assert(registeredCallbacs[event] == nil, ("event '%s' is already registered"):format(event))

    RegisterNetEvent("lb-racing:cb:" .. event, function(requestId, ...)
        local params = { ... }
        local startTime = GetGameTimer()

        local success, errorMessage = pcall(function()
            TriggerServerEvent("lb-racing:cb:response", requestId, handler(table.unpack(params)))

            local ms = GetGameTimer() - startTime

            debugprint(("Callback ^5%s^7 took %ims"):format(event, ms))
        end)

        if not success then
            local stackTrace = Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())

            print(("^1SCRIPT ERROR: Client callback '%s' failed: %s^7\n%s"):format(event, errorMessage or "", stackTrace or ""))
        end
    end)
end
