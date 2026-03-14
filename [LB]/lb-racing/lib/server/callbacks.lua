---@type { [string]: true }
local registeredCallbacs = {}

---@type { [number]: { [string]: boolean } }
local triggeredCallbacks = {}

---@param event string
---@param source number
local function TriggerSafeClientEvent(event, source, ...)
    local payload = msgpack.pack_args(...)
    local length = #payload

    if length > 64000 then
        debugprint("Using latent event for " .. event .. " due to payload size: " .. length)

        ---@diagnostic disable-next-line: param-type-mismatch
        TriggerLatentClientEventInternal(event, source, payload, length, 10^6)
    else
        ---@diagnostic disable-next-line: param-type-mismatch
        TriggerClientEventInternal(event, source, payload, length)
    end
end

---@param event string
---@param handler fun(source: number, ...) : ...any
---@param antiSpam? boolean
---@param defaultReturn? any
function RegisterCallback(event, handler, antiSpam, defaultReturn)
    assert(type(event) == "string", "event must be a string")
    assert(registeredCallbacs[event] == nil, ("event '%s' is already registered"):format(event))

    if antiSpam == nil then
        antiSpam = true
    end

    RegisterNetEvent("lb-racing:cb:" .. event, function(requestId, ...)
        local src = source

        if antiSpam then
            if not triggeredCallbacks[src] then
                triggeredCallbacks[src] = {}
            end

            if triggeredCallbacks[src][event] then
                debugprint("Callback", event, "is busy by", src)
                TriggerClientEvent("lb-racing:cb:response", src, requestId, defaultReturn)

                return
            end

            triggeredCallbacks[src][event] = true
        end

        local params = { ... }
        local startTime = os.nanotime()

        if not triggeredCallbacks[src] then
            triggeredCallbacks[src] = {}
        end

        local success, errorMessage = pcall(function()
            TriggerSafeClientEvent("lb-racing:cb:response", src, requestId, handler(src, table.unpack(params)))

            local finishTime = os.nanotime()
            local ms = (finishTime - startTime) / 1e6

            debugprint(("Callback ^5%s^7 took %.4fms"):format(event, ms))
        end)

        if not success then
            local stackTrace = Citizen.InvokeNative(`FORMAT_STACK_TRACE` & 0xFFFFFFFF, nil, 0, Citizen.ResultAsString())

            print(("^1SCRIPT ERROR: Callback '%s' failed: %s^7\n%s"):format(event, errorMessage or "", stackTrace or ""))
            TriggerClientEvent("lb-racing:cb:response", src, requestId, defaultReturn)
        end

        if triggeredCallbacks[src] then
            triggeredCallbacks[src][event] = nil
        end
    end)
end

---@param event string
---@param callback fun(source: number, account: Account, ...) : ...
---@param antiSpam? boolean
---@param defaultReturn? any
function BaseCallback(event, callback, antiSpam, defaultReturn)
    RegisterCallback(event, function(source, ...)
        local account = GetAccount(source, true)

        if not account then
            debugprint(("^1%s^7: no account found for %s | %s"):format(event, GetPlayerName(source), source))
            return defaultReturn
        end

        return callback(source, account, ...)
    end, antiSpam, defaultReturn)
end

AddEventHandler("playerDropped", function()
    local src = source

    triggeredCallbacks[src] = nil
end)

local CALLBACK_TIMEOUT <const> = 15

---@type { [number]: { cb: fun(...), event: string } }
local waitingCallbacks = {}

---@param requestId number
---@param ... any
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

local function GenerateRequestId()
    local requestId = math.random(999999999)

    while waitingCallbacks[requestId] do
        requestId = math.random(999999999)
    end

    return requestId
end

---@param event string
---@param source number
---@param cb fun(...)
function TriggerClientCallback(event, source, cb, ...)
    local requestId = GenerateRequestId()

    waitingCallbacks[requestId] = { cb = cb, event = event }

    SetTimeout(CALLBACK_TIMEOUT * 1000, function()
        if waitingCallbacks[requestId] then
            infoprint("error", ("Client callback ^1%s^7 timed out after %is. Triggered on %i"):format(event, CALLBACK_TIMEOUT, source))

            waitingCallbacks[requestId].cb(nil)
            waitingCallbacks[requestId] = nil
        end
    end)

    TriggerSafeClientEvent("lb-racing:cb:" .. event, source, requestId, ...)
end

---@param event string
---@param source number
---@param ... any
function AwaitClientCallback(event, source, ...)
    local responsePromise = promise.new()

    TriggerClientCallback(event, source, function(...)
        responsePromise:resolve({ ... })
    end, ...)

    local result = Citizen.Await(responsePromise)

    return table.unpack(result)
end
