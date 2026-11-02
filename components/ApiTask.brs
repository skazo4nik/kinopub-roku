sub init()
    m.top.functionName = "execute"
end sub

function cacheTtl(path as String) as Integer
    if path = "/v1/items" or path = "/v1/items/fresh" or path = "/v1/items/popular" or path = "/v1/items/hot" then return 900
    if path = "/v1/collections" or path = "/v1/collections/view" then return 900
    if path = "/v1/genres" or path = "/v1/countries" or path = "/v1/types" then return 86400
    return 0
end function

function cacheFile(url as String) as String
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(url)
    d = CreateObject("roEVPDigest")
    d.Setup("md5")
    return "cachefs:/kp_" + d.Process(ba) + ".json"
end function

sub setStatus(code as Integer, ms as Integer)
    st = "ok"
    note = ""
    if code = -1
        st = "error"
        note = "нет ответа от сервера"
    else if code >= 500
        st = "error"
        note = "ошибка сервера " + code.ToStr()
    else if code = 429
        st = "error"
        note = "слишком много запросов"
    else if ms > 7000
        st = "slow"
        note = "ответ " + (ms \ 1000).ToStr() + " с"
    end if
    if m.global.apiStatus <> st then m.global.apiStatus = st
    if m.global.apiNote <> note then m.global.apiNote = note
end sub

sub execute()
    cfg = kpConfig()
    params = {}
    src = m.top.params
    if src <> invalid
        for each k in src
            params[k] = src[k]
        end for
    end if
    body = m.top.body
    if m.top.bodyParams <> invalid
        if m.top.bodyParams.Count() > 0 then body = buildQuery(m.top.bodyParams)
    end if
    isApi = (m.top.kind = "api")
    isExt = (m.top.kind = "ext")
    url = cfg.api + m.top.path
    if isExt then url = m.top.path
    plain = buildQuery(params)
    if isApi then params.access_token = regRead("access_token")
    query = buildQuery(params)

    ' --- кэш списков ---
    ttl = 0
    if isApi and m.top.method = "GET" then ttl = cacheTtl(m.top.path)
    if isExt
        ttl = 43200
        if Instr(1, url, "arm.haglund") > 0 then ttl = 604800
    end if
    cpath = ""
    if ttl > 0
        if isExt
            cpath = cacheFile(url)
        else
            cpath = cacheFile(url + "?" + plain)
        end if
        raw = ReadAsciiFile(cpath)
        if raw <> ""
            nl = Instr(1, raw, Chr(10))
            if nl > 1
                ts = Val(Left(raw, nl - 1))
                if CreateObject("roDateTime").AsSeconds() - ts < ttl
                    cj = ParseJson(Mid(raw, nl + 1))
                    if cj <> invalid
                        m.top.result = { code: 200, json: cj, tag: m.top.tag, cached: true }
                        return
                    end if
                end if
            end if
        end if
    end if

    clock = CreateObject("roTimespan")
    fullUrl = url + "?" + query
    if isExt then fullUrl = url
    res = httpRequest(fullUrl, m.top.method, body)
    if isApi and res.code = 401
        if refreshTokens(cfg)
            params.access_token = regRead("access_token")
            res = httpRequest(url + "?" + buildQuery(params), m.top.method, body)
        end if
    end if
    ms = clock.TotalMilliseconds()
    if not isExt and res.code <> 401 and res.code <> 400 and res.code <> 404 then setStatus(res.code, ms)
    if res.code = 200 and cpath <> "" and res.body <> ""
        WriteAsciiFile(cpath, CreateObject("roDateTime").AsSeconds().ToStr() + Chr(10) + res.body)
    end if
    print "KP "; m.top.path; " -> "; res.code; " "; ms; "ms bytes="; Len(res.body)
    if m.top.tag = "probe"
        j = ParseJson(res.body)
        if j <> invalid
            if j.item = invalid then print "KPRAW "; m.top.path; " "; Left(res.body, 2500)
            if j.item <> invalid and Instr(1, m.top.path, "/v1/watching") > 0
                dump = ""
                if j.item.seasons <> invalid
                    for each sn in j.item.seasons
                        for each ep in sn.episodes
                            dump = dump + "S" + sn.number.ToStr() + "E" + ep.number.ToStr() + ":" + ep.status.ToStr() + "/" + ep.time.ToStr() + " "
                        end for
                    end for
                end if
                print "KPWATCH "; dump
            end if
            if j.item <> invalid
                line = ""
                for each k in j.item
                    v = j.item[k]
                    tv = Type(v)
                    if tv = "roString" or tv = "String" or tv = "Integer" or tv = "roInt" or tv = "Float" or tv = "roFloat" or tv = "Double" or tv = "roBoolean" or tv = "Boolean"
                        sv = v.ToStr()
                        if Len(sv) > 40 then sv = Left(sv, 40)
                        line = line + k + "=" + sv + "; "
                    end if
                end for
                print "KPSCALARS "; line
                if j.item.seasons <> invalid
                    e = j.item.seasons[0].episodes[0]
                    e.Delete("files")
                    print "KPEP "; Left(FormatJson(e), 1500)
                else if j.item.videos <> invalid
                    e = j.item.videos[0]
                    e.Delete("files")
                    print "KPEP "; Left(FormatJson(e), 1500)
                end if
            end if
        end if
    end if
    json = invalid
    if res.body <> "" then json = ParseJson(res.body)
    m.top.result = { code: res.code, json: json, tag: m.top.tag }
end sub
