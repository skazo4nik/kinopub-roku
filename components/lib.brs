' Общие функции. Подключаются в каждый компонент через <script>.

function kpConfig() as Object
    ' Публичные данные клиента (как у xbmc-плагина). Можно заменить своими от support@kino.pub
    return {
        api: "https://api.service-kp.com"
        clientId: "xbmc"
        clientSecret: "cgg3gtifu46urtfp2zp1nqtba0k2ezxh"
    }
end function

' ---------- реестр (токены) ----------
function regRead(key as String) as String
    sec = CreateObject("roRegistrySection", "kinopub")
    if sec.Exists(key) then return sec.Read(key)
    return ""
end function

sub regWrite(key as String, value as String)
    sec = CreateObject("roRegistrySection", "kinopub")
    sec.Write(key, value)
    sec.Flush()
end sub

sub regDelete(key as String)
    sec = CreateObject("roRegistrySection", "kinopub")
    sec.Delete(key)
    sec.Flush()
end sub

' ---------- HTTP ----------
function buildQuery(params as Object) as String
    xf = CreateObject("roUrlTransfer")
    parts = []
    for each k in params
        v = params[k]
        if v <> invalid
            parts.Push(k + "=" + xf.Escape(v.ToStr()))
        end if
    end for
    return parts.Join("&")
end function

function httpRequest(url as String, method as String, body = "" as String) as Object
    req = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    req.SetMessagePort(port)
    req.SetUrl(url)
    req.SetCertificatesFile("common:/certs/ca-bundle.crt")
    req.AddHeader("X-Roku-Reserved-Dev-Id", "")
    req.InitClientCertificates()
    req.EnableEncodings(true)
    started = false
    if method = "POST"
        req.SetRequest("POST")
        if body <> "" then req.AddHeader("Content-Type", "application/x-www-form-urlencoded")
        started = req.AsyncPostFromString(body)
    else
        started = req.AsyncGetToString()
    end if
    if not started then return { code: -1, body: "" }
    msg = wait(20000, port)
    if type(msg) = "roUrlEvent"
        return { code: msg.GetResponseCode(), body: msg.GetString() }
    end if
    req.AsyncCancel()
    return { code: -1, body: "" }
end function

function refreshTokens(cfg as Object) as Boolean
    rt = regRead("refresh_token")
    if rt = "" then return false
    q = buildQuery({ grant_type: "refresh_token", refresh_token: rt, client_id: cfg.clientId, client_secret: cfg.clientSecret })
    res = httpRequest(cfg.api + "/oauth2/token?" + q, "POST")
    if res.code <> 200 then return false
    j = ParseJson(res.body)
    if j = invalid then return false
    if j.access_token = invalid then return false
    regWrite("access_token", j.access_token)
    if j.refresh_token <> invalid then regWrite("refresh_token", j.refresh_token)
    return true
end function

' Асинхронный запрос к API. callback — имя функции вызывающего компонента.
function kpFetch(path as String, params as Object, callback as String, tag = "" as String, method = "GET" as String, kind = "api" as String, body = "" as Dynamic) as Object
    t = CreateObject("roSGNode", "ApiTask")
    t.path = path
    t.params = params
    t.method = method
    t.kind = kind
    t.tag = tag
    if Type(body) = "roAssociativeArray"
        t.bodyParams = body
    else
        t.body = body
    end if
    t.observeField("result", callback)
    if m.kpTasks = invalid then m.kpTasks = []
    m.kpTasks.Push(t)
    while m.kpTasks.Count() > 40
        m.kpTasks.Shift()
    end while
    t.control = "RUN"
    return t
end function

' ---------- форматирование ----------
function pad2(n as Integer) as String
    if n < 10 then return "0" + n.ToStr()
    return n.ToStr()
end function

function fmtTime(sec as Dynamic) as String
    if sec = invalid then return "0:00"
    s = Int(sec)
    h = s \ 3600
    mnt = (s mod 3600) \ 60
    ss = s mod 60
    if h > 0 then return h.ToStr() + ":" + pad2(mnt) + ":" + pad2(ss)
    return mnt.ToStr() + ":" + pad2(ss)
end function

function fmtRating(r as Dynamic) as String
    if r = invalid then return ""
    n = Val(r.ToStr())
    if n <= 0 then return ""
    t = Int(n * 10 + 0.5)
    return (t \ 10).ToStr() + "." + (t mod 10).ToStr()
end function

function splitTitle(t as Dynamic) as Object
    if t = invalid then t = ""
    p = Instr(1, t, " / ")
    if p > 0 then return { main: Left(t, p - 1), orig: Mid(t, p + 3) }
    return { main: t, orig: "" }
end function

' ---------- контент ----------
function makeItemNode(it as Object) as Object
    n = CreateObject("roSGNode", "ContentNode")
    if it.id <> invalid then n.id = it.id.ToStr()
    tt = splitTitle(it.title)
    n.title = tt.main
    poster = ""
    if it.posters <> invalid
        if it.posters.medium <> invalid
            poster = it.posters.medium
        else if it.posters.small <> invalid
            poster = it.posters.small
        end if
    end if
    n.HDPosterUrl = poster
    r = fmtRating(it.imdb_rating)
    if r = "" then r = fmtRating(it.kinopoisk_rating)
    n.ShortDescriptionLine1 = r
    if it.year <> invalid then n.ShortDescriptionLine2 = it.year.ToStr()
    if it.total <> invalid and it.watched <> invalid
        n.ShortDescriptionLine2 = it.watched.ToStr() + " из " + it.total.ToStr()
        left = it.total - it.watched
        if it.new <> invalid
            if it.new > 0 then left = it.new
        end if
        if left > 0 then n.NumEpisodes = left
    end if
    return n
end function

function nodesFromItems(items as Object) as Object
    out = []
    for each it in items
        if Type(it) = "roAssociativeArray" then out.Push(makeItemNode(it))
    end for
    return out
end function

function extractItems(res as Object) as Object
    if res.json <> invalid
        if Type(res.json) = "roAssociativeArray"
            if res.json.items <> invalid then return res.json.items
        end if
    end if
    return []
end function

function getWatch(ep as Object) as Object
    r = { status: -1, time: 0 }
    if ep.watching <> invalid
        if Type(ep.watching) = "roAssociativeArray"
            if ep.watching.status <> invalid then r.status = ep.watching.status
            if ep.watching.time <> invalid then r.time = ep.watching.time
        end if
    end if
    return r
end function

' Выбор потока: лучший по разрешению из поддерживаемых устройством
function pickStream(files as Dynamic) as Object
    none = { url: "", fmt: "hls" }
    if files = invalid then return none
    if files.Count() = 0 then return none
    di = CreateObject("roDeviceInfo")
    maxH = 1080
    if Instr(1, di.GetVideoMode(), "2160") > 0 then maxH = 2160
    best = invalid
    bestH = -1
    for each f in files
        h = 0
        if f.h <> invalid then h = f.h
        codec = ""
        if f.codec <> invalid then codec = LCase(f.codec)
        ok = true
        if codec = "h265" or codec = "hevc"
            ok = di.CanDecodeVideo({ Codec: "hevc" }).result
        end if
        if ok and h <= maxH and h > bestH
            best = f
            bestH = h
        end if
    end for
    if best = invalid then best = files[0]
    u = best.url
    if u = invalid then return none
    res = { url: "", fmt: "hls", kind: "", w: 0, h: 0, codec: "", alts: [] }
    if best.w <> invalid then res.w = best.w
    if best.h <> invalid then res.h = best.h
    if best.codec <> invalid then res.codec = UCase(best.codec)
    if u.hls4 <> invalid then res.alts.Push({ url: u.hls4, fmt: "hls", kind: "HLS4" })
    if u.hls2 <> invalid then res.alts.Push({ url: u.hls2, fmt: "hls", kind: "HLS2" })
    if u.hls <> invalid then res.alts.Push({ url: u.hls, fmt: "hls", kind: "HLS" })
    if u.http <> invalid then res.alts.Push({ url: u.http, fmt: "mp4", kind: "HTTP" })
    if res.alts.Count() > 0
        res.url = res.alts[0].url
        res.fmt = res.alts[0].fmt
        res.kind = res.alts[0].kind
    end if
    return res
end function
