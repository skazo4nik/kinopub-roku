sub init()
    m.code = m.top.findNode("code")
    m.status = m.top.findNode("status")
    m.steps = m.top.findNode("steps")
    m.poll = m.top.findNode("poll")
    m.poll.observeField("fire", "onPoll")
    m.top.observeField("visible", "onVisible")
    m.deviceCode = ""
    m.expiresAt = 0
    m.clock = CreateObject("roTimespan")
end sub

sub onVisible()
    if m.top.visible
        startFlow()
    else
        m.poll.control = "stop"
    end if
end sub

sub startFlow()
    m.poll.control = "stop"
    m.deviceCode = ""
    m.code.text = ""
    m.status.text = "Получаем код…"
    cfg = kpConfig()
    kpFetch("/oauth2/device", { grant_type: "device_code", client_id: cfg.clientId, client_secret: cfg.clientSecret }, "onCode", "", "POST", "oauth")
end sub

sub onCode(event as Object)
    res = event.getData()
    ok = false
    if res.json <> invalid
        if res.json.code <> invalid and res.json.user_code <> invalid then ok = true
    end if
    if not ok
        m.status.text = "Не удалось получить код (проверьте интернет). Нажмите OK, чтобы повторить."
        return
    end if
    m.deviceCode = res.json.code
    uri = "kino.pub/device"
    if res.json.verification_uri <> invalid then uri = res.json.verification_uri
    uri = uri.Replace("https://", "").Replace("http://", "")
    m.steps.text = "1. Откройте " + uri + " на телефоне или компьютере" + Chr(10) + "2. Войдите в аккаунт и введите этот код:"
    m.code.text = res.json.user_code
    interval = 5
    if res.json.interval <> invalid then interval = res.json.interval
    expires = 300
    if res.json.expires_in <> invalid then expires = res.json.expires_in
    m.clock.Mark()
    m.expiresAt = expires
    m.status.text = "Ждём подтверждения… Код действует " + (expires \ 60).ToStr() + " мин."
    m.poll.duration = interval
    m.poll.control = "start"
end sub

sub onPoll()
    if m.deviceCode = "" then return
    if m.clock.TotalSeconds() > m.expiresAt
        startFlow()
        return
    end if
    cfg = kpConfig()
    kpFetch("/oauth2/device", { grant_type: "device_token", client_id: cfg.clientId, client_secret: cfg.clientSecret, code: m.deviceCode }, "onToken", "", "POST", "oauth")
end sub

sub onToken(event as Object)
    res = event.getData()
    if m.deviceCode = "" then return
    if res.json = invalid then return
    if res.json.access_token <> invalid
        m.poll.control = "stop"
        m.deviceCode = ""
        regWrite("access_token", res.json.access_token)
        if res.json.refresh_token <> invalid then regWrite("refresh_token", res.json.refresh_token)
        di = CreateObject("roDeviceInfo")
        kpFetch("/v1/device/notify", {}, "onNotify", "", "POST", "api", { title: di.GetModelDisplayName(), hardware: di.GetModel(), software: "Roku OS" })
        m.top.done = true
        return
    end if
    err = ""
    if res.json.error <> invalid then err = res.json.error
    if err = "authorization_pending" or err = "slow_down" then return
    if res.code = 400 or res.code = 401
        startFlow()
    end if
end sub

sub onNotify(event as Object)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if press and key = "OK"
        startFlow()
        return true
    end if
    return false
end function
