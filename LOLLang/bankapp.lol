-- ============================================================
--  BANKAPP.LOL  --  Terminal Banking Menu Demo
--  Shows: menus, input, arrays, maps, string ops, math, time
-- ============================================================

-- ── Data ─────────────────────────────────────────────────────
let accounts   = map()   -- accountId → "name|balance|pin"
let txLog      = arr()   -- transaction log entries
let loggedIn   = ""      -- current account id
let sessionStart = 0.0

-- Seed accounts
mapSet(accounts, "1001", "Alice|2500.00|1234")
mapSet(accounts, "1002", "Bob|840.50|5678")
mapSet(accounts, "1003", "Charlie|12000.00|9999")

-- ── Helpers ──────────────────────────────────────────────────
func hr()
    print("  " + repeat("-", 44))
end

func hdr(title)
    print("")
    print("  " + repeat("=", 44))
    print("  " + title)
    print("  " + repeat("=", 44))
end

func padLeft(s, n)
    let p = n - len(s)
    if p < 0 then p = 0 end
    return repeat(" ", p) + s
end

func fmtMoney(n)
    -- format number as $X.XX
    let whole = floor(abs(n))
    let cents = floor((abs(n) - whole) * 100 + 0.5)
    let cs = tostr(cents)
    if cents < 10 then cs = "0" + cs end
    let sign = ""
    if n < 0 then sign = "-" end
    return sign + "$" + tostr(whole) + "." + cs
end

func getAccField(id, field)
    -- field: 0=name 1=balance 2=pin
    let raw = mapGet(accounts, id)
    return splitGet(split(raw, "|"), field)
end

func setBalance(id, newBal)
    let raw  = mapGet(accounts, id)
    let parts = split(raw, "|")
    let nm   = splitGet(parts, 0)
    let pin  = splitGet(parts, 2)
    mapSet(accounts, id, nm + "|" + tostr(newBal) + "|" + pin)
end

func logTx(acctId, desc, amount)
    let ts   = tostr(floor(time()))
    let name = getAccField(acctId, 0)
    let entry = ts + "|" + acctId + "|" + name + "|" + desc + "|" + tostr(amount)
    arrPush(txLog, entry)
end

func pressEnter()
    print("")
    print("  Press ENTER to continue...")
    input(dummy)
end

-- ── Screens ──────────────────────────────────────────────────
func screenLogin()
    hdr("  LOLANG BANK  --  Login")
    print("")
    print("  Account number: ")
    input(acctId)
    let id = trim(acctId)

    if mapHas(accounts, id) == 0 then
        print("  Account not found.")
        pressEnter()
        return
    end

    print("  PIN: ")
    input(pinIn)
    let pin = trim(pinIn)
    let realPin = getAccField(id, 2)

    if pin ~= realPin then
        print("  Incorrect PIN.")
        pressEnter()
        return
    end

    loggedIn     = id
    sessionStart = time()
    let name     = getAccField(id, 0)
    print("")
    print("  Welcome back, " + name + "!")
    pressEnter()
end

func screenLogout()
    let dur = floor(time() - sessionStart)
    print("")
    print("  Session duration: " + tostr(dur) + "s")
    print("  Goodbye, " + getAccField(loggedIn, 0) + "!")
    loggedIn = ""
    pressEnter()
end

func screenBalance()
    hdr("  Account Balance")
    print("")
    let name = getAccField(loggedIn, 0)
    let bal  = tonum(getAccField(loggedIn, 1))
    print("  Account:  " + loggedIn)
    print("  Holder:   " + name)
    print("  Balance:  " + fmtMoney(bal))
    print("")
    -- simple tier indicator
    if bal >= 10000 then
        print("  Status:   PLATINUM")
    elseif bal >= 1000 then
        print("  Status:   GOLD")
    else
        print("  Status:   STANDARD")
    end
    pressEnter()
end

func screenDeposit()
    hdr("  Deposit")
    print("")
    print("  Amount to deposit: $")
    input(amtStr)
    let amt = tonum(trim(amtStr))

    if amt <= 0 then
        print("  Invalid amount.")
        pressEnter()
        return
    end

    let bal = tonum(getAccField(loggedIn, 1))
    let newBal = bal + amt
    setBalance(loggedIn, newBal)
    logTx(loggedIn, "DEPOSIT", amt)

    print("")
    print("  Deposited:  " + fmtMoney(amt))
    print("  New balance:" + fmtMoney(newBal))
    pressEnter()
end

func screenWithdraw()
    hdr("  Withdraw")
    print("")
    let bal = tonum(getAccField(loggedIn, 1))
    print("  Available:  " + fmtMoney(bal))
    print("  Amount to withdraw: $")
    input(amtStr)
    let amt = tonum(trim(amtStr))

    if amt <= 0 then
        print("  Invalid amount.")
        pressEnter()
        return
    end

    if amt > bal then
        print("  Insufficient funds.")
        print("  Available: " + fmtMoney(bal))
        pressEnter()
        return
    end

    let newBal = bal - amt
    setBalance(loggedIn, newBal)
    logTx(loggedIn, "WITHDRAW", 0 - amt)

    print("")
    print("  Withdrawn:   " + fmtMoney(amt))
    print("  New balance: " + fmtMoney(newBal))
    pressEnter()
end

func screenTransfer()
    hdr("  Transfer")
    print("")
    let bal = tonum(getAccField(loggedIn, 1))
    print("  Your balance: " + fmtMoney(bal))
    print("  Destination account: ")
    input(destId)
    let dest = trim(destId)

    if dest == loggedIn then
        print("  Cannot transfer to yourself.")
        pressEnter()
        return
    end
    if mapHas(accounts, dest) == 0 then
        print("  Destination not found.")
        pressEnter()
        return
    end

    print("  Amount: $")
    input(amtStr)
    let amt = tonum(trim(amtStr))

    if amt <= 0 then print("  Invalid amount.") pressEnter() return end
    if amt > bal then print("  Insufficient funds.") pressEnter() return end

    let destBal = tonum(getAccField(dest, 1))
    setBalance(loggedIn, bal - amt)
    setBalance(dest, destBal + amt)
    logTx(loggedIn, "TRANSFER-OUT to " + dest, 0-amt)
    logTx(dest,     "TRANSFER-IN from " + loggedIn, amt)

    let destName = getAccField(dest, 0)
    print("")
    print("  Sent " + fmtMoney(amt) + " to " + destName)
    print("  Your new balance: " + fmtMoney(bal - amt))
    pressEnter()
end

func screenHistory()
    hdr("  Transaction History")
    print("")
    let count = arrLen(txLog)
    if count == 0 then
        print("  No transactions yet.")
        pressEnter()
        return
    end
    -- show last 8 transactions for this account
    let shown = 0
    let i = count - 1
    while i >= 0 and shown < 8 do
        let entry = arrGet(txLog, i)
        let parts = split(entry, "|")
        let acct  = splitGet(parts, 1)
        if acct == loggedIn then
            let ts   = splitGet(parts, 0)
            let desc = splitGet(parts, 3)
            let amt  = tonum(splitGet(parts, 4))
            let sign = "+"
            if amt < 0 then sign = "-" end
            print("  " + sign + fmtMoney(abs(amt)) + "  " + desc)
            shown = shown + 1
        end
        i = i - 1
    end
    if shown == 0 then print("  No transactions for this account.") end
    pressEnter()
end

-- ── Main menu ─────────────────────────────────────────────────
let running = 1

while running == 1 do
    if loggedIn == "" then
        -- Not logged in
        hdr("  LOLANG BANK")
        print("")
        print("  [L] Login")
        print("  [Q] Quit")
        print("")
        hr()
        print("  Choice: ")
        input(ch)
        let c = lower(trim(ch))
        if c == "l" then screenLogin() end
        if c == "q" then running = 0 end
    else
        -- Logged in
        let name = getAccField(loggedIn, 0)
        let bal  = tonum(getAccField(loggedIn, 1))
        hdr("  LOLANG BANK  --  " + name)
        print("")
        print("  Balance: " + fmtMoney(bal))
        print("")
        print("  [1] View Balance")
        print("  [2] Deposit")
        print("  [3] Withdraw")
        print("  [4] Transfer")
        print("  [5] History")
        print("  [L] Logout")
        print("  [Q] Quit")
        print("")
        hr()
        print("  Choice: ")
        input(ch)
        let c = lower(trim(ch))
        if c == "1" then screenBalance()  end
        if c == "2" then screenDeposit()  end
        if c == "3" then screenWithdraw() end
        if c == "4" then screenTransfer() end
        if c == "5" then screenHistory()  end
        if c == "l" then screenLogout()   end
        if c == "q" then running = 0      end
    end
end

print("")
print("  Thank you for banking with LOLang Bank.")
print("")
