sub init()
    m.backdrop = m.top.findNode("backdrop")
    m.poster = m.top.findNode("poster")
    m.title = m.top.findNode("title")
    m.orig = m.top.findNode("orig")
    m.meta = m.top.findNode("meta")
    m.plot = m.top.findNode("plot")
    m.people = m.top.findNode("people")
    m.descFrame = m.top.findNode("descFrame")
    m.descHint = m.top.findNode("descHint")
    m.playBtn = m.top.findNode("playBtn")
    m.watchBtn = m.top.findNode("watchBtn")
    m.watchLabel = m.top.findNode("watchLabel")
    m.seasons = m.top.findNode("seasons")
    m.episodes = m.top.findNode("episodes")
    m.loading = m.top.findNode("loading")
    m.rImdb = m.top.findNode("rImdb")
    m.rKp = m.top.findNode("rKp")
    m.rKino = m.top.findNode("rKino")
    m.infoPanel = m.top.findNode("infoPanel")
    m.infoTitle = m.top.findNode("infoTitle")
    m.infoText = m.top.findNode("infoText")
    m.markHint = m.top.findNode("markHint")
    m.focusHolder = m.top.findNode("focusHolder")
    m.trailerBtn = m.top.findNode("trailerBtn")
    m.trailerBtn.setFields({ width: 72, height: 72 })
    m.playBtn.setFields({ width: 560, height: 72 })
    m.watchBtn.setFields({ width: 72, height: 72 })
    m.seasons.observeField("itemFocused", "onSeasonFocused")
    m.episodes.observeField("itemSelected", "onEpisode")
    m.item = invalid
    m.reqId = 0
    m.curSeason = -1
    m.target = invalid
    m.area = "play"
    m.topFocus = true
    m.togglePending = 0
    m.epOpts = []
end sub

sub onItemId()
    m.item = invalid
    m.curSeason = -1
    m.infoPanel.visible = false
    m.rImdb.text = ""
    m.rKp.text = ""
    m.rKino.text = ""
    m.title.text = ""
    m.orig.text = ""
    m.meta.text = ""
    m.plot.text = ""
    m.people.text = ""
    m.poster.uri = ""
    m.backdrop.uri = ""
    m.markHint.visible = false
    m.playBtn.visible = false
    m.watchBtn.visible = false
    m.trailerBtn.visible = false
    m.watchLabel.text = ""
    m.seasons.visible = false
    m.episodes.visible = false
    m.loading.text = "Загрузка…"
    m.loading.visible = true
    load()
end sub

sub load()
    m.reqId = m.reqId + 1
    kpFetch("/v1/items/" + m.top.itemId, {}, "onItem", m.reqId.ToStr())
end sub

sub onRefresh()
    if m.item <> invalid then load()
end sub

sub onFocusNow()
    focusTop("play")
end sub

' ---------- фокус ----------
sub applyTopFocus()
    on = m.topFocus
    m.descFrame.visible = (on and m.area = "desc")
    m.descHint.visible = (on and m.area = "desc")
    m.playBtn.itemHasFocus = (on and m.area = "play")
    m.watchBtn.itemHasFocus = (on and m.area = "watch")
    m.trailerBtn.itemHasFocus = (on and m.area = "trailer")
    if on and m.area = "desc"
        m.plot.color = "#FFFFFF"
    else
        m.plot.color = "#E4DCF2"
    end if
end sub

sub focusTop(area as String)
    m.topFocus = true
    m.area = area
    m.focusHolder.setFocus(true)
    applyTopFocus()
end sub

sub focusLists(node as Object)
    m.topFocus = false
    applyTopFocus()
    node.setFocus(true)
end sub

sub onItem(event as Object)
    res = event.getData()
    if res.tag <> m.reqId.ToStr() then return
    if res.code = 401
        m.top.authFailed = true
        return
    end if
    ok = false
    if res.json <> invalid
        if Type(res.json) = "roAssociativeArray"
            if res.json.item <> invalid then ok = true
        end if
    end if
    if not ok
        if m.item = invalid then m.loading.text = "Не удалось загрузить. Нажмите Назад."
        return
    end if
    firstLoad = (m.item = invalid)
    m.item = res.json.item
    render()
    if firstLoad then focusTop("play")
end sub

function isSerial() as Boolean
    if m.item = invalid then return false
    if m.item.seasons = invalid then return false
    return (m.item.seasons.Count() > 0)
end function

function computeTarget() as Object
    it = m.item
    t = { season: -1, epIdx: 0, time: 0, tag: "" }
    if isSerial()
        t.season = 0
        found = false
        for si = 0 to it.seasons.Count() - 1
            eps = it.seasons[si].episodes
            if eps <> invalid
                for ei = 0 to eps.Count() - 1
                    w = getWatch(eps[ei])
                    if w.status <> 1
                        t.season = si
                        t.epIdx = ei
                        if w.time > 30 then t.time = w.time
                        found = true
                        exit for
                    end if
                end for
            end if
            if found then exit for
        end for
        sn = it.seasons[t.season].number
        en = 0
        eps = it.seasons[t.season].episodes
        if eps <> invalid
            if eps.Count() > t.epIdx then en = eps[t.epIdx].number
        end if
        if sn <> invalid and en <> invalid then t.tag = " S" + sn.ToStr() + "E" + en.ToStr()
    else
        if it.videos <> invalid
            if it.videos.Count() > 0
                w = getWatch(it.videos[0])
                if w.status <> 1 and w.time > 30 then t.time = w.time
            end if
        end if
    end if
    return t
end function

function iconNode(title as String, icon as String, iconFocus as String) as Object
    n = CreateObject("roSGNode", "ContentNode")
    n.title = title
    n.HDPosterUrl = icon
    n.ShortDescriptionLine1 = iconFocus
    return n
end function

sub render()
    it = m.item
    m.loading.visible = false
    tt = splitTitle(it.title)
    m.title.text = tt.main
    m.orig.text = tt.orig
    if it.posters <> invalid
        big = ""
        if it.posters.big <> invalid then big = it.posters.big
        if big = "" and it.posters.medium <> invalid then big = it.posters.medium
        m.poster.uri = big
        wide = big
        if it.posters.wide <> invalid then wide = it.posters.wide
        m.backdrop.uri = wide
    end if

    parts = []
    if it.year <> invalid then parts.Push(it.year.ToStr())
    if it.genres <> invalid
        g = []
        for each x in it.genres
            if x.title <> invalid then g.Push(x.title)
        end for
        if g.Count() > 0 then parts.Push(g.Join(", "))
    end if
    setRatings(it)
    if it.duration <> invalid
        if Type(it.duration) = "roAssociativeArray"
            if it.duration.average <> invalid
                if it.duration.average > 0 then parts.Push(Int(it.duration.average / 60).ToStr() + " мин")
            end if
        end if
    end if
    m.meta.text = parts.Join("   ·   ")
    if it.plot <> invalid then m.plot.text = it.plot else m.plot.text = ""

    people = []
    if it.director <> invalid
        if it.director <> "" then people.Push("Режиссёр: " + it.director)
    end if
    if it.cast <> invalid
        if it.cast <> "" then people.Push("В ролях: " + it.cast)
    end if
    m.people.text = people.Join(Chr(10))

    m.target = computeTarget()
    t = m.target
    if t.time > 0
        m.playBtn.itemContent = iconNode("Продолжить" + t.tag + "  ·  " + fmtTime(t.time), "", "")
    else
        m.playBtn.itemContent = iconNode("Смотреть" + t.tag, "", "")
    end if
    m.playBtn.visible = true

    on = false
    label = "Буду смотреть"
    if isSerial()
        label = "Я смотрю"
        if it.subscribed = true then on = true
    else
        if it.in_watchlist = true then on = true
    end if
    if on
        m.watchBtn.itemContent = iconNode("", "pkg:/images/eye_on_light.png", "pkg:/images/eye_on_dark.png")
        m.watchLabel.text = "В списке «" + label + "»"
        m.watchLabel.color = "#B388FF"
    else
        m.watchBtn.itemContent = iconNode("", "pkg:/images/eye_off_light.png", "pkg:/images/eye_off_dark.png")
        m.watchLabel.text = "Добавить в «" + label + "»"
        m.watchLabel.color = "#8E80AD"
    end if
    m.watchBtn.visible = true
    m.trailerBtn.visible = (trailerInfo() <> invalid)
    if m.trailerBtn.visible then m.trailerBtn.itemContent = iconNode("", "pkg:/images/trailer_light.png", "pkg:/images/trailer_dark.png")
    applyTopFocus()

    if isSerial()
        m.seasons.visible = true
        m.episodes.visible = true
        m.markHint.visible = true
        sroot = CreateObject("roSGNode", "ContentNode")
        for each s in it.seasons
            sn = sroot.createChild("ContentNode")
            num = ""
            if s.number <> invalid then num = s.number.ToStr()
            sn.title = "Сезон " + num
        end for
        m.seasons.content = sroot
        m.seasons.jumpToItem = t.season
        fillEpisodes(t.season, true)
        m.episodes.jumpToItem = t.epIdx
    end if
end sub

sub fillEpisodes(si as Integer, force as Boolean)
    if not force and si = m.curSeason then return
    m.curSeason = si
    root = CreateObject("roSGNode", "ContentNode")
    eps = m.item.seasons[si].episodes
    if eps <> invalid
        for each ep in eps
            n = root.createChild("ContentNode")
            num = ""
            if ep.number <> invalid then num = ep.number.ToStr()
            ttl = ""
            if ep.title <> invalid then ttl = ep.title
            n.title = num + ". " + ttl
            w = getWatch(ep)
            if w.status = 1
                n.ShortDescriptionLine1 = "Просмотрено"
            else if w.time > 30
                n.ShortDescriptionLine1 = fmtTime(w.time)
            else
                n.ShortDescriptionLine1 = ""
            end if
        end for
    end if
    m.episodes.content = root
end sub

sub onSeasonFocused(event as Object)
    if m.item = invalid then return
    si = event.getData()
    if si < 0 then return
    fillEpisodes(si, false)
end sub

' ---------- действия ----------
sub doPlay()
    if m.target = invalid then return
    t = m.target
    m.top.playRequest = { item: m.item, season: t.season, epIdx: t.epIdx, start: t.time }
end sub

function trailerInfo() as Dynamic
    if m.item = invalid then return invalid
    tr = m.item.trailer
    if tr = invalid then return invalid
    if Type(tr) <> "roAssociativeArray" then return invalid
    u = tr.url
    if u = invalid then return invalid
    if Instr(1, LCase(u), "youtube") > 0 or Instr(1, LCase(u), "youtu.be") > 0 then return invalid
    fmt = "mp4"
    if Instr(1, LCase(u), ".m3u8") > 0 then fmt = "hls"
    return { url: u, fmt: fmt, title: splitTitle(m.item.title).main }
end function

sub playTrailer()
    ti = trailerInfo()
    if ti <> invalid then m.top.trailerRequest = ti
end sub

sub toggleWatchlist()
    if m.item = invalid then return
    kpFetch("/v1/watching/togglewatchlist", { id: m.item.id }, "onToggled", "toggle")
end sub

sub onToggled(event as Object)
    load()
end sub

sub onEpisode(event as Object)
    if m.item = invalid then return
    ei = event.getData()
    eps = m.item.seasons[m.curSeason].episodes
    if eps = invalid then return
    w = getWatch(eps[ei])
    start = 0
    if w.status <> 1 and w.time > 30 then start = w.time
    m.top.playRequest = { item: m.item, season: m.curSeason, epIdx: ei, start: start }
end sub

' --- отметка серии ---
sub askWatchedMark()
    if m.item = invalid then return
    ei = m.episodes.itemFocused
    if ei < 0 then return
    eps = m.item.seasons[m.curSeason].episodes
    if eps = invalid then return
    if ei >= eps.Count() then return
    m.markIdx = ei
    w = getWatch(eps[ei])
    btns = []
    m.epOpts = []
    dlg = CreateObject("roSGNode", "StandardMessageDialog")
    dlg.title = "Серия " + eps[ei].number.ToStr()
    if w.status = 1
        dlg.message = ["Серия отмечена как просмотренная."]
        btns.Push("Отметить непросмотренной")
    else
        dlg.message = ["Серия ещё не отмечена как просмотренная."]
        btns.Push("Отметить просмотренной")
    end if
    m.epOpts.Push("toggle")
    if w.status <> 1 and w.time > 30
        btns.Push("Смотреть с начала")
        m.epOpts.Push("restart")
    end if
    btns.Push("Отмена")
    m.epOpts.Push("cancel")
    dlg.buttons = btns
    dlg.observeFieldScoped("buttonSelected", "onMarkDialog")
    m.top.getScene().dialog = dlg
end sub

sub onMarkDialog(event as Object)
    idx = event.getData()
    m.top.getScene().dialog.close = true
    act = "cancel"
    if idx < m.epOpts.Count() then act = m.epOpts[idx]
    s = m.item.seasons[m.curSeason]
    if act = "toggle"
        ep = s.episodes[m.markIdx]
        params = { id: m.item.id, video: ep.number }
        if s.number <> invalid then params.season = s.number
        kpFetch("/v1/watching/toggle", params, "onToggled", "toggle")
    else if act = "restart"
        m.top.playRequest = { item: m.item, season: m.curSeason, epIdx: m.markIdx, start: 0 }
    end if
end sub

' --- отметка сезона ---
sub askSeasonMark()
    if m.item = invalid then return
    si = m.seasons.itemFocused
    if si < 0 then return
    s = m.item.seasons[si]
    eps = s.episodes
    if eps = invalid then return
    if eps.Count() = 0 then return
    done = 0
    for each ep in eps
        if getWatch(ep).status = 1 then done = done + 1
    end for
    m.seasonIdx = si
    m.seasonAll = (done = eps.Count())
    num = ""
    if s.number <> invalid then num = s.number.ToStr()
    dlg = CreateObject("roSGNode", "StandardMessageDialog")
    dlg.title = "Сезон " + num
    dlg.message = ["Просмотрено серий: " + done.ToStr() + " из " + eps.Count().ToStr()]
    if m.seasonAll
        dlg.buttons = ["Отметить весь сезон непросмотренным", "Отмена"]
    else
        dlg.buttons = ["Отметить весь сезон просмотренным", "Отмена"]
    end if
    dlg.observeFieldScoped("buttonSelected", "onSeasonDialog")
    m.top.getScene().dialog = dlg
end sub

sub onSeasonDialog(event as Object)
    idx = event.getData()
    m.top.getScene().dialog.close = true
    if idx <> 0 then return
    s = m.item.seasons[m.seasonIdx]
    count = 0
    for each ep in s.episodes
        w = getWatch(ep)
        need = false
        if m.seasonAll and w.status = 1 then need = true
        if not m.seasonAll and w.status <> 1 then need = true
        if need
            params = { id: m.item.id, video: ep.number }
            if s.number <> invalid then params.season = s.number
            kpFetch("/v1/watching/toggle", params, "onSeasonToggled", "season")
            count = count + 1
        end if
    end for
    m.togglePending = count
end sub

sub onSeasonToggled(event as Object)
    m.togglePending = m.togglePending - 1
    if m.togglePending <= 0 then load()
end sub

function yesNo(v as Boolean) as String
    if v then return "да"
    return "нет"
end function

function votesText(n as Dynamic) as String
    if n = invalid then return ""
    v = Int(Val(n.ToStr()))
    if v >= 1000000 then return (Int(v / 100000) / 10).ToStr() + " млн"
    if v >= 1000 then return (v \ 1000).ToStr() + " тыс."
    if v > 0 then return v.ToStr()
    return ""
end function

sub setRatings(it as Object)
    r = fmtRating(it.imdb_rating)
    m.rImdb.text = ""
    if r <> "" then m.rImdb.text = "IMDb  " + r
    r = fmtRating(it.kinopoisk_rating)
    m.rKp.text = ""
    if r <> "" then m.rKp.text = "Кинопоиск  " + r
    m.rKino.text = ""
    if it.rating_percentage <> invalid
        if it.rating_percentage > 0
            vt = votesText(it.rating_votes)
            m.rKino.text = "Kino.pub  " + it.rating_percentage.ToStr() + "%"
            if vt <> "" then m.rKino.text = m.rKino.text + "  (" + vt + ")"
        end if
    end if
end sub

function joinTitles(arr as Dynamic) as String
    if arr = invalid then return ""
    out = []
    for each x in arr
        if x.title <> invalid then out.Push(x.title)
    end for
    return out.Join(", ")
end function

sub showInfo()
    it = m.item
    if it = invalid then return
    tt = splitTitle(it.title)
    m.infoTitle.text = tt.main
    nl = Chr(10)
    lines = []
    if tt.orig <> "" then lines.Push(tt.orig)
    meta = []
    if it.year <> invalid then meta.Push(it.year.ToStr())
    g = joinTitles(it.genres)
    if g <> "" then meta.Push(g)
    c = joinTitles(it.countries)
    if c <> "" then meta.Push(c)
    if meta.Count() > 0 then lines.Push(meta.Join("  ·  "))
    lines.Push("")
    rt = []
    r = fmtRating(it.imdb_rating)
    if r <> "" then
        s = "IMDb " + r
        vt = votesText(it.imdb_votes)
        if vt <> "" then s = s + " (" + vt + ")"
        rt.Push(s)
    end if
    r = fmtRating(it.kinopoisk_rating)
    if r <> "" then
        s = "Кинопоиск " + r
        vt = votesText(it.kinopoisk_votes)
        if vt <> "" then s = s + " (" + vt + ")"
        rt.Push(s)
    end if
    if it.rating_percentage <> invalid
        if it.rating_percentage > 0
            s = "Kino.pub " + it.rating_percentage.ToStr() + "%"
            vt = votesText(it.rating_votes)
            if vt <> "" then s = s + " (" + vt + ")"
            rt.Push(s)
        end if
    end if
    if rt.Count() > 0 then lines.Push("Рейтинги: " + rt.Join("   ·   "))
    if it.duration <> invalid
        if Type(it.duration) = "roAssociativeArray"
            if it.duration.average <> invalid
                if it.duration.average > 0 then lines.Push("Длительность: " + Int(it.duration.average / 60).ToStr() + " мин")
            end if
        end if
    end if
    if it.quality <> invalid then lines.Push("Качество: " + it.quality.ToStr() + "p")
    if it.director <> invalid
        if it.director <> "" then lines.Push("Режиссёр: " + it.director)
    end if
    if it.cast <> invalid
        if it.cast <> "" then lines.Push("В ролях: " + it.cast)
    end if
    lines.Push("")
    if it.plot <> invalid then lines.Push(it.plot)
    m.infoText.text = lines.Join(nl)
    m.infoPanel.visible = true
    m.topFocus = false
    applyTopFocus()
    m.infoText.setFocus(true)
end sub

' ---------- пульт ----------
function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.infoPanel.visible
        if key = "back"
            m.infoPanel.visible = false
            focusTop("desc")
            return true
        end if
        return false
    end if
    if key = "back"
        m.top.closed = true
        return true
    end if

    inSeasons = m.seasons.isInFocusChain()
    inEpisodes = m.episodes.isInFocusChain()
    if inSeasons or inEpisodes
        if key = "options"
            if inEpisodes then askWatchedMark() else askSeasonMark()
            return true
        else if key = "up"
            focusTop("play")
            return true
        else if key = "left"
            if inEpisodes
                focusLists(m.seasons)
            else
                focusTop("play")
            end if
            return true
        else if key = "right" and inSeasons
            focusLists(m.episodes)
            return true
        end if
        return false
    end if

    ' верхняя часть: описание / кнопки
    if key = "up"
        if m.area <> "desc" then focusTop("desc")
        return true
    else if key = "down"
        if m.area = "desc"
            focusTop("play")
        else if isSerial()
            focusLists(m.seasons)
        end if
        return true
    else if key = "left"
        if m.area = "watch" then focusTop("play")
        if m.area = "trailer" then focusTop("watch")
        return true
    else if key = "right"
        if m.area = "play"
            focusTop("watch")
        else if m.area = "watch" and m.trailerBtn.visible
            focusTop("trailer")
        end if
        return true
    else if key = "OK"
        if m.area = "desc"
            showInfo()
        else if m.area = "play"
            doPlay()
        else if m.area = "trailer"
            playTrailer()
        else
            toggleWatchlist()
        end if
        return true
    end if
    return false
end function
