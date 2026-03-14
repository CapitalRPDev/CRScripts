---@param source number
---@param paymentMethod string
---@param entryFee number
---@return boolean
function CanPayEntryFee(source, paymentMethod, entryFee)
    if paymentMethod == "bank" then
        if GetMoney(source) >= entryFee then
            return true
        end

        NotifyPlayer(
            source,
            L("NOTIFICATIONS.FAILED_JOIN_RACE.NO_MONEY"),
            "error",
            L("NOTIFICATIONS.FAILED_JOIN_RACE.TITLE")
        )

        return false
    end

    infoprint("warning", "Payment method: " .. paymentMethod .. " hasn't been implemented in server/custom/functions/payment.lua - CanPayEntryFee")

    return true
end

---@param source number
---@param raceId number
---@param paymentMethod string
---@param entryFee number
---@param raceName string
---@return boolean
function PayEntryFee(source, raceId, paymentMethod, entryFee, raceName)
    local identifier = GetIdentifier(source)

    if paymentMethod == "bank" then
        if not RemoveMoney(source, entryFee) then
            NotifyPlayer(
                source,
                L("NOTIFICATIONS.FAILED_JOIN_RACE.NO_MONEY"),
                "error",
                L("NOTIFICATIONS.FAILED_JOIN_RACE.TITLE")
            )

            return false
        end

        if identifier then
            LogTransaction(identifier, -entryFee, L("NOTIFICATIONS.ENTRY_FEE_TRANSACTION", { raceName = raceName }))
        end

        return true
    end

    infoprint("warning", "Payment method: " .. paymentMethod .. " hasn't been implemented in server/custom/functions/payment.lua - PayEntryFee")

    return true
end

---@param source? number
---@param identifier string
---@param paymentMethod string
---@param prizePool number
---@param raceName string
---@return boolean
function PayPrizePool(source, identifier, paymentMethod, prizePool, raceName)
    source = source or GetSourceFromIdentifier(identifier)

    if paymentMethod == "bank" then
        if source and not RemoveMoney(source, prizePool) then
            return false
        elseif not source and not RemoveMoneyOffline(identifier, prizePool) then
            return false
        end

        LogTransaction(identifier, -prizePool, L("NOTIFICATIONS.PRIZE_POOL_TRANSACTION", { raceName = raceName }))

        return true
    end

    infoprint("warning", "Payment method: " .. paymentMethod .. " hasn't been implemented in server/custom/functions/payment.lua - PayPrizePool")

    return true
end

---@param source? number
---@param identifier string
---@param raceId number
---@param amount number
---@param paymentMethod string
---@param reason "commission" | "winnings" | "entry_refund" | "canceled" | "refund"
---@param raceName string
function PayUser(source, identifier, raceId, amount, paymentMethod, reason, raceName)
    source = source or GetSourceFromIdentifier(identifier)

    if paymentMethod == "bank" then
        if source then
            AddMoney(source, amount)
        else
            AddMoneyOffline(identifier, amount)
        end

        if reason == "commission" then
            LogTransaction(identifier, amount, L("NOTIFICATIONS.COMMISSION_TRANSACTION", { raceName = raceName }))
        elseif reason == "winnings" then
            LogTransaction(identifier, amount, L("NOTIFICATIONS.WINNINGS_TRANSACTION", { raceName = raceName }))
        elseif reason == "entry_refund" then
            LogTransaction(identifier, amount, L("NOTIFICATIONS.ENTRY_REFUND_TRANSACTION", { raceName = raceName }))
        elseif reason == "refund" then
            LogTransaction(identifier, amount, L("NOTIFICATIONS.REFUND_TRANSACTION", { raceName = raceName }))
        elseif reason == "canceled" then
            LogTransaction(identifier, amount, L("NOTIFICATIONS.RACE_CANCELED.TRANSACTION", { raceName = raceName }))

            SendNotification(
                identifier,
                L("NOTIFICATIONS.RACE_CANCELED.TITLE"),
                L("NOTIFICATIONS.RACE_CANCELED.DESCRIPTION", {
                    raceName = raceName,
                    entryRefund = L("NOTIFICATIONS.RACE_CANCELED.REFUND", { entryFee = amount })
                })
            )
        end

        return
    end

    infoprint("warning", "Payment method: " .. paymentMethod .. " hasn't been implemented in server/custom/functions/payment.lua - PayCommission")
end
