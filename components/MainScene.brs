sub init()
    m.appView = m.top.findNode("appView")
    m.menu = m.top.findNode("menu")
    m.rows = m.top.findNode("rows")
    m.grid = m.top.findNode("grid")
    m.kb = m.top.findNode("kb")
    m.kbGroup = m.top.findNode("kbGroup")
    m.query = m.top.findNode("query")
    m.kbText = ""
    m.kbLang = "ru"
    m.kbBar = m.top.findNode("kbBar")
    m.kbLayer = "letters"
    m.barNodes = [m.top.findNode("barLang"), m.top.findNode("barSym"), m.top.findNode("barSpace"), m.top.findNode("barDel")]
    m.barIdx = 0
    m.barNodes[0].setFields({ width: 120, height: 60 })
    m.barNodes[1].setFields({ width: 120, height: 60 })
    m.barNodes[2].setFields({ width: 232, height: 60 })
    m.barNodes[3].setFields({ width: 100, height: 60 })
    m.barNodes[2].itemContent = barContent("", "pkg:/images/space_light.png", "pkg:/images/space_dark.png")
    m.barNodes[3].itemContent = barContent("", "pkg:/images/back_light.png", "pkg:/images/back_dark.png")
    m.sectionTitle = m.top.findNode("sectionTitle")
    m.hint = m.top.findNode("hint")
    m.empty = m.top.findNode("empty")
    m.loadingLabel = m.top.findNode("loading")
    m.auth = m.top.findNode("auth")
    m.detail = m.top.findNode("detail")
    m.video = m.top.findNode("video")
    m.searchTimer = m.top.findNode("searchTimer")
    m.progressTimer = m.top.findNode("progressTimer")
    m.trackPanel = m.top.findNode("trackPanel")
    m.audioList = m.top.findNode("audioList")
    m.subList = m.top.findNode("subList")
    m.trackHint = m.top.findNode("trackHint")
    m.hintTimer = m.top.findNode("hintTimer")
    m.statsPanel = m.top.findNode("statsPanel")
    m.apiDot = m.top.findNode("apiDot")
    m.apiText = m.top.findNode("apiText")
    m.nextHint = m.top.findNode("nextHint")
    m.nextTimer = m.top.findNode("nextTimer")
    m.nextTimer.observeField("fire", "onNextTick")
    m.global.observeField("apiStatus", "onApiStatus")
    m.global.observeField("apiNote", "onApiStatus")
    m.skipBtn = m.top.findNode("skipBtn")
    m.skipText = m.top.findNode("skipText")
    m.skipHolder = m.top.findNode("skipHolder")
    m.skipSegs = []
    m.skipGen = 0
    m.skipCur = -1
    m.skipDismissed = {}
    m.skipClock = CreateObject("roTimespan")
    m.isTrailer = false
    m.fGenre = ""
    m.fGenreName = "Все"
    m.fCountry = ""
    m.fCountryName = "Все"
    m.fYear = ""
    m.fYearName = "Все"
    m.refGenres = []
    m.refCountries = []
    m.pickMode = ""
    m.pickKeys = []
    m.pickReturn = invalid
    m.statsText = m.top.findNode("statsText")
    m.statsTimer = m.top.findNode("statsTimer")
    m.statsTimer.observeField("fire", "updateStats")
    m.streamMeta = { kind: "", w: 0, h: 0, codec: "" }
    m.audioTracks = []
    m.subTracks = []
    m.setList = m.top.findNode("setList")
    m.pickPanel = m.top.findNode("pickPanel")
    m.pickTitle = m.top.findNode("pickTitle")
    m.pickList = m.top.findNode("pickList")
    m.devId = ""
    m.devSet = invalid
    m.setDefs = []
    m.pickDef = invalid
    m.pickOptions = []

    m.sections = [
        { id: "search", title: "", heading: "Поиск", ctype: "" }
        { id: "home", title: "Главная", ctype: "" }
        { id: "watching", title: "Я смотрю", ctype: "" }
        { id: "movies", title: "Фильмы", ctype: "movie" }
        { id: "serials", title: "Сериалы", ctype: "serial" }
        { id: "k4", title: "4K", ctype: "" }
        { id: "collections", title: "Подборки", ctype: "" }
        { id: "bookmarks", title: "Закладки", ctype: "" }
        { id: "settings", title: "Настройки", ctype: "" }
    ]
    m.sorts = [
        { key: "created-", title: "Новые" }
        { key: "updated-", title: "Обновлённые" }
        { key: "views-", title: "Популярные" }
        { key: "imdb_rating-", title: "Рейтинг IMDb" }
        { key: "year-", title: "Год выхода" }
    ]
    m.sortIdx = 0
    m.secIdx = 0
    m.gen = 0
    m.page = 0
    m.total = 1
    m.loading = false
    m.pendingFocus = false
    m.dirty = false
    m.gridKind = ""
    m.collId = ""
    m.dedupe = false
    m.gridNodes = invalid
    m.returnTo = invalid
    m.play = invalid
    m.rowDefs = []
    m.rowItems = []
    m.rowPending = 0
    m.enrichGen = -1
    m.enrichQueue = []
    m.enrichInflight = 0
    m.enrichMap = {}

    root = CreateObject("roSGNode", "ContentNode")
    for each s in m.sections
        n = root.createChild("ContentNode")
        n.title = s.title
        if s.id = "search"
            n.HDPosterUrl = "pkg:/images/search_dim.png"
            n.ShortDescriptionLine1 = "pkg:/images/search_dark.png"
        end if
    end for
    m.menu.content = root

    m.menu.observeField("itemSelected", "onMenuSelected")
    m.rows.observeField("rowItemSelected", "onRowItem")
    m.grid.observeField("itemSelected", "onGridItem")
    m.grid.observeField("itemFocused", "onGridFocus")
    m.kb.observeField("itemSelected", "onKeySelected")
    m.searchTimer.observeField("fire", "onSearchTimer")
    m.progressTimer.observeField("fire", "onProgressTick")
    m.auth.observeField("done", "onAuthDone")
    m.detail.observeField("closed", "onDetailClosed")
    m.detail.observeField("playRequest", "onPlayRequest")
    m.detail.observeField("trailerRequest", "onTrailerRequest")
    m.detail.observeField("authFailed", "onAuthFailed")
    m.video.observeField("state", "onVideoState")
    m.audioList.observeField("itemSelected", "onAudioSelected")
    m.setList.observeField("itemSelected", "onSettingSelected")
    m.pickList.observeField("itemSelected", "onPickSelected")
    m.subList.observeField("itemSelected", "onSubSelected")
    m.hintTimer.observeField("fire", "onHintTimer")

    if regRead("access_token") = ""
        showAuth()
    else
        showApp()
    end if
end sub

' ============ вход / выход ============
sub showAuth()
    m.appView.visible = false
    m.detail.visible = false
    m.video.visible = false
    m.auth.visible = true
    m.auth.setFocus(true)
end sub

sub onAuthDone()
    m.auth.visible = false
    showApp()
end sub

sub showApp()
    di = CreateObject("roDeviceInfo")
    kpFetch("/v1/device/notify", {}, "onMarkResult", "", "POST", "api", { title: di.GetModelDisplayName(), hardware: di.GetModel(), software: "Roku OS" })
    m.appView.visible = true
    m.menu.setFocus(true)
    m.pendingFocus = true
    showSection(1)
end sub

sub doLogout()
    regDelete("access_token")
    regDelete("refresh_token")
    m.gen = m.gen + 1
    m.video.control = "stop"
    m.progressTimer.control = "stop"
    showAuth()
end sub

sub onAuthFailed()
    doLogout()
end sub

function checkAuth(res as Object) as Boolean
    if res.code = 401
        doLogout()
        return true
    end if
    return false
end function

sub showMessage(title as String, text as String)
    dlg = CreateObject("roSGNode", "StandardMessageDialog")
    dlg.title = title
    dlg.message = [text]
    dlg.buttons = ["OK"]
    dlg.observeFieldScoped("buttonSelected", "onMessageClosed")
    m.top.dialog = dlg
end sub

sub onMessageClosed()
    m.top.dialog.close = true
end sub

sub confirmLogout()
    dlg = CreateObject("roSGNode", "StandardMessageDialog")
    dlg.title = "Выход"
    dlg.message = ["Выйти из аккаунта kino.pub на этом Roku?"]
    dlg.buttons = ["Выйти", "Отмена"]
    dlg.observeFieldScoped("buttonSelected", "onLogoutButton")
    m.top.dialog = dlg
end sub

sub onLogoutButton(event as Object)
    idx = event.getData()
    m.top.dialog.close = true
    if idx = 0 then doLogout()
end sub

' ============ разделы ============
sub onMenuSelected(event as Object)
    m.pendingFocus = true
    showSection(event.getData())
end sub

sub setLoading(on as Boolean)
    m.loadingLabel.visible = on
    if on then m.empty.visible = false
end sub

sub showEmpty(text as String)
    setLoading(false)
    m.empty.text = text
    m.empty.visible = true
end sub

sub showSection(idx as Integer)
    sec = m.sections[idx]
    m.secIdx = idx
    m.gridKind = ""
    m.dedupe = false
    clearFilters()
    m.gen = m.gen + 1
    m.loading = false
    m.rows.visible = false
    m.setList.visible = false
    m.grid.visible = false
    m.kbGroup.visible = false
    m.empty.visible = false
    m.grid.translation = [0, 150]
    m.grid.numColumns = 6
    m.empty.translation = [0, 300]
    m.loadingLabel.translation = [0, 300]
    heading = sec.title
    if sec.heading <> invalid then heading = sec.heading
    m.sectionTitle.text = heading
    m.hint.text = ""
    if m.menu.itemFocused <> idx then m.menu.jumpToItem = idx
    setLoading(true)

    if sec.id = "home"
        loadHome()
    else if sec.id = "settings"
        loadSettings()
    else if sec.id = "watching"
        loadWatching()
    else if sec.id = "bookmarks"
        m.gridKind = "bookmarks"
        m.gridNodes = invalid
        loadBookmarks()
    else if sec.id = "search"
        showSearch()
    else if sec.id = "collections"
        m.gridKind = "collections"
        loadGrid(true)
    else
        m.gridKind = "items"
        m.sortIdx = 0
        loadGrid(true)
    end if
end sub

sub focusContent()
    sec = m.sections[m.secIdx].id
    if sec = "settings"
        if m.setList.visible then m.setList.setFocus(true)
    else if sec = "home" or sec = "watching"
        if m.rows.visible then m.rows.setFocus(true)
    else if sec = "search"
        if m.grid.visible and not m.kb.isInFocusChain() and m.pendingFocus
            m.grid.setFocus(true)
        else
            m.kb.setFocus(true)
        end if
    else
        if m.grid.visible then m.grid.setFocus(true)
    end if
end sub

' ---------- ряды: главная и закладки ----------
sub loadHome()
    m.rowDefs = [
        { title: "Я смотрю", path: "/v1/watching/serials", params: { subscribed: 1 } }
        { title: "Недосмотренные фильмы", path: "/v1/watching/movies", params: {} }
        { title: "Новые фильмы", path: "/v1/items/fresh", params: { type: "movie" } }
        { title: "Новые сериалы", path: "/v1/items/fresh", params: { type: "serial" } }
        { title: "Популярные фильмы", path: "/v1/items/popular", params: { type: "movie" } }
        { title: "Популярные сериалы", path: "/v1/items/popular", params: { type: "serial" } }
        { title: "Горячие фильмы", path: "/v1/items/hot", params: { type: "movie" } }
        { title: "Горячие сериалы", path: "/v1/items/hot", params: { type: "serial" } }
    ]
    m.rowItems = []
    m.rowPending = m.rowDefs.Count()
    for i = 0 to m.rowDefs.Count() - 1
        m.rowItems.Push([])
        d = m.rowDefs[i]
        kpFetch(d.path, d.params, "onRowResult", "r" + m.gen.ToStr() + ":" + i.ToStr())
    end for
end sub

sub loadWatching()
    m.dedupe = true
    m.rowDefs = [
        { title: "Сериалы, которые я смотрю", path: "/v1/watching/serials", params: { subscribed: 1 } }
        { title: "Недосмотренные сериалы", path: "/v1/watching/serials", params: {} }
        { title: "Недосмотренные фильмы", path: "/v1/watching/movies", params: {} }
    ]
    m.rowItems = []
    m.rowPending = m.rowDefs.Count()
    for i = 0 to m.rowDefs.Count() - 1
        m.rowItems.Push([])
        d = m.rowDefs[i]
        kpFetch(d.path, d.params, "onRowResult", "r" + m.gen.ToStr() + ":" + i.ToStr())
    end for
end sub

sub loadBookmarks()
    kpFetch("/v1/bookmarks", {}, "onBookmarkFolders", "b" + m.gen.ToStr())
end sub

sub onBookmarkFolders(event as Object)
    res = event.getData()
    if res.tag <> "b" + m.gen.ToStr() then return
    if checkAuth(res) then return
    folders = extractItems(res)
    if folders.Count() = 0
        showEmpty("Закладок пока нет")
        return
    end if
    m.bmItems = []
    m.bmPending = folders.Count()
    names = []
    for each f in folders
        if f.title <> invalid then names.Push(f.title)
        kpFetch("/v1/bookmarks/" + f.id.ToStr(), { page: 1 }, "onBookmarkItems", "bk" + m.gen.ToStr() + ":" + f.id.ToStr() + ":1")
    end for
    m.hint.text = "Папки: " + names.Join(", ")
end sub

sub onBookmarkItems(event as Object)
    res = event.getData()
    parts = res.tag.Split(":")
    if Val(Mid(parts[0], 3)) <> m.gen then return
    if checkAuth(res) then return
    for each it in extractItems(res)
        m.bmItems.Push(it)
    end for
    page = Int(Val(parts[2]))
    if page = 1 and res.json <> invalid
        if Type(res.json) = "roAssociativeArray"
            if res.json.pagination <> invalid
                if res.json.pagination.total <> invalid
                    total = res.json.pagination.total
                    if total > 10 then total = 10
                    for pg = 2 to total
                        m.bmPending = m.bmPending + 1
                        kpFetch("/v1/bookmarks/" + parts[1], { page: pg }, "onBookmarkItems", "bk" + m.gen.ToStr() + ":" + parts[1] + ":" + pg.ToStr())
                    end for
                end if
            end if
        end if
    end if
    m.bmPending = m.bmPending - 1
    if m.bmPending = 0 then buildBookmarkGrid()
end sub

sub buildBookmarkGrid()
    seen = {}
    uniq = []
    for each it in m.bmItems
        key = "k" + it.id.ToStr()
        if not seen.DoesExist(key)
            seen[key] = true
            uniq.Push(it)
        end if
    end for
    if uniq.Count() = 0
        showEmpty("Закладок пока нет")
        return
    end if
    m.gridNodes = CreateObject("roSGNode", "ContentNode")
    m.gridNodes.appendChildren(nodesFromItems(uniq))
    m.grid.content = m.gridNodes
    setLoading(false)
    m.grid.visible = true
    if m.pendingFocus then focusContent()
end sub

sub onRowResult(event as Object)
    res = event.getData()
    parts = res.tag.Split(":")
    if Val(Mid(parts[0], 2)) <> m.gen then return
    if checkAuth(res) then return
    i = Int(Val(parts[1]))
    m.rowItems[i] = extractItems(res)
    m.rowPending = m.rowPending - 1
    if m.rowPending = 0 then buildRows()
end sub

sub buildRows()
    if m.enrichGen <> m.gen
        m.enrichGen = m.gen
        if startEnrich() then return
    end if
    root = CreateObject("roSGNode", "ContentNode")
    count = 0
    seen = {}
    for i = 0 to m.rowDefs.Count() - 1
        items = m.rowItems[i]
        if m.dedupe
            fresh = []
            for each it in items
                key = "k" + it.id.ToStr()
                if not seen.DoesExist(key)
                    seen[key] = true
                    fresh.Push(it)
                end if
            end for
            items = fresh
        end if
        if items.Count() > 0
            row = CreateObject("roSGNode", "ContentNode")
            row.title = m.rowDefs[i].title
            row.appendChildren(nodesFromItems(items))
            root.appendChild(row)
            count = count + 1
        end if
    end for
    if count = 0
        showEmpty("Ничего не найдено")
        return
    end if
    setLoading(false)
    m.rows.content = root
    m.rows.visible = true
    if m.pendingFocus then focusContent()
end sub

' --- рейтинги для списков, где API их не отдаёт (например «Я смотрю») ---
function hasRating(it as Object) as Boolean
    if it.imdb_rating <> invalid then return true
    if it.kinopoisk_rating <> invalid then return true
    return false
end function

function startEnrich() as Boolean
    cache = {}
    raw = regRead("ratings2")
    if raw <> ""
        j = ParseJson(raw)
        if j <> invalid then cache = j
    end if
    m.enrichMap = cache
    m.enrichQueue = []
    seen = {}
    for each items in m.rowItems
        for each it in items
            if not hasRating(it) and it.id <> invalid
                key = it.id.ToStr()
                if cache[key] = invalid and not seen.DoesExist(key)
                    seen[key] = true
                    m.enrichQueue.Push(key)
                end if
            end if
        end for
    end for
    m.enrichInflight = 0
    if m.enrichQueue.Count() = 0
        applyRatings()
        return false
    end if
    for i = 1 to 6
        enrichNext()
    end for
    return true
end function

sub enrichNext()
    if m.enrichQueue.Count() = 0 then return
    key = m.enrichQueue.Shift()
    m.enrichInflight = m.enrichInflight + 1
    kpFetch("/v1/items/" + key, { nolinks: 1 }, "onEnrich", "e" + m.gen.ToStr() + ":" + key)
end sub

sub onEnrich(event as Object)
    res = event.getData()
    parts = res.tag.Split(":")
    if Val(Mid(parts[0], 2)) <> m.gen then return
    m.enrichInflight = m.enrichInflight - 1
    if res.code = 200 and res.json <> invalid
        r = "-"
        if Type(res.json) = "roAssociativeArray"
            if res.json.item <> invalid
                x = fmtRating(res.json.item.imdb_rating)
                if x = "" then x = fmtRating(res.json.item.kinopoisk_rating)
                if x <> "" then r = x
            end if
        end if
        m.enrichMap[parts[1]] = r
    end if
    enrichNext()
    if m.enrichInflight = 0 and m.enrichQueue.Count() = 0
        if m.enrichMap.Count() < 400
            regWrite("ratings2", FormatJson(m.enrichMap))
        else
            regDelete("ratings2")
        end if
        applyRatings()
        buildRows()
    end if
end sub

sub applyRatings()
    for each items in m.rowItems
        for each it in items
            if not hasRating(it) and it.id <> invalid
                v = m.enrichMap[it.id.ToStr()]
                if v <> invalid
                    if v <> "" and v <> "-" then it.imdb_rating = v
                end if
            end if
        end for
    end for
end sub

sub onRowItem(event as Object)
    idx = event.getData()
    row = m.rows.content.getChild(idx[0])
    if row = invalid then return
    node = row.getChild(idx[1])
    if node <> invalid then openDetail(node.id)
end sub

' ---------- сетка: фильмы / сериалы / 4K ----------
sub loadGrid(reset as Boolean)
    sec = m.sections[m.secIdx]
    if reset
        m.page = 0
        m.total = 1
        m.loading = false
        m.gen = m.gen + 1
        m.gridNodes = invalid
        m.grid.visible = false
        m.empty.visible = false
        setLoading(true)
        if m.gridKind = "items" then m.hint.text = gridHint()
        if m.gridKind = "collection" then m.hint.text = "Назад — к списку подборок"
    end if
    if m.loading then return
    m.loading = true
    nextPage = m.page + 1
    params = { page: nextPage }
    path = "/v1/items"
    if m.gridKind = "items"
        if sec.ctype <> "" then params.type = sec.ctype
        if sec.id = "k4" then params.quality = "4k"
        params.sort = m.sorts[m.sortIdx].key
        if m.fGenre <> "" then params.genre = m.fGenre
        if m.fCountry <> "" then params.country = m.fCountry
        if m.fYear <> "" then params.year = m.fYear
    else if m.gridKind = "collections"
        path = "/v1/collections"
    else if m.gridKind = "collection"
        path = "/v1/collections/view"
        params.id = m.collId
    end if
    kpFetch(path, params, "onGridResult", "g" + m.gen.ToStr())
end sub

sub onGridResult(event as Object)
    res = event.getData()
    if res.tag <> "g" + m.gen.ToStr() then return
    if checkAuth(res) then return
    m.loading = false
    items = extractItems(res)
    m.page = m.page + 1
    m.total = m.page
    if res.json <> invalid
        if res.json.pagination <> invalid
            if res.json.pagination.total <> invalid then m.total = res.json.pagination.total
        end if
    end if
    nodes = nodesFromItems(items)
    if m.gridNodes = invalid
        if nodes.Count() = 0
            showEmpty("Ничего не найдено")
            return
        end if
        m.gridNodes = CreateObject("roSGNode", "ContentNode")
        m.gridNodes.appendChildren(nodes)
        m.grid.content = m.gridNodes
        setLoading(false)
        m.grid.visible = true
        if m.pendingFocus then focusContent()
    else
        m.gridNodes.appendChildren(nodes)
    end if
end sub

sub onGridFocus(event as Object)
    if m.gridKind <> "items" and m.gridKind <> "collections" then return
    if m.loading or m.gridNodes = invalid then return
    if m.page >= m.total then return
    idx = event.getData()
    if idx >= m.gridNodes.getChildCount() - 12 then loadGrid(false)
end sub

sub onGridItem(event as Object)
    if m.gridNodes = invalid then return
    node = m.grid.content.getChild(event.getData())
    if node = invalid then return
    if m.gridKind = "collections"
        m.gridKind = "collection"
        m.collId = node.id
        m.sectionTitle.text = "Подборка: " + node.title
        m.pendingFocus = true
        loadGrid(true)
    else
        openDetail(node.id)
    end if
end sub

function gridHint() as String
    h = "Сортировка: " + m.sorts[m.sortIdx].title
    if m.fGenre <> "" then h = h + "  ·  Жанр: " + m.fGenreName
    if m.fCountry <> "" then h = h + "  ·  Страна: " + m.fCountryName
    if m.fYear <> "" then h = h + "  ·  Год: " + m.fYearName
    return h + "      * — фильтры"
end function

sub clearFilters()
    m.fGenre = ""
    m.fGenreName = "Все"
    m.fCountry = ""
    m.fCountryName = "Все"
    m.fYear = ""
    m.fYearName = "Все"
end sub

sub reloadGrid()
    m.pendingFocus = true
    loadGrid(true)
end sub

sub openFilterMenu()
    labels = [
        "Сортировка: " + m.sorts[m.sortIdx].title
        "Жанр: " + m.fGenreName
        "Страна: " + m.fCountryName
        "Год: " + m.fYearName
        "Сбросить фильтры"
    ]
    openPicker("Фильтры", labels, 0, "fmenu", m.grid)
end sub

function filterType() as String
    sec = m.sections[m.secIdx]
    if sec.ctype <> "" then return sec.ctype
    return "movie"
end function

sub onRefGenres(event as Object)
    res = event.getData()
    m.refGenres = extractItems(res)
    labels = ["Все"]
    for each g in m.refGenres
        labels.Push(g.title)
    end for
    openPicker("Жанр", labels, 0, "fgenre", m.grid)
end sub

sub onRefCountries(event as Object)
    res = event.getData()
    m.refCountries = extractItems(res)
    labels = ["Все"]
    for each c in m.refCountries
        labels.Push(c.title)
    end for
    openPicker("Страна", labels, 0, "fcountry", m.grid)
end sub

sub openPicker(title as String, labels as Object, cur as Integer, mode as String, ret as Object)
    pr = CreateObject("roSGNode", "ContentNode")
    for each lb in labels
        n = pr.createChild("ContentNode")
        n.title = lb
    end for
    m.pickMode = mode
    m.pickReturn = ret
    m.pickTitle.text = title
    m.pickList.content = pr
    m.pickList.jumpToItem = cur
    m.pickPanel.visible = true
    m.pickList.setFocus(true)
end sub

' ---------- поиск ----------
sub showSearch()
    setLoading(false)
    m.grid.translation = [650, 150]
    m.grid.numColumns = 3
    m.empty.translation = [650, 300]
    m.kbGroup.visible = true
    m.gridKind = "search"
    m.pendingFocus = false
    m.gridNodes = invalid
    m.kbText = ""
    m.kbLayer = "letters"
    buildKeys()
    updateQuery()
    m.hint.text = "Введите название фильма или сериала"
    m.kb.setFocus(true)
end sub

sub buildKeys()
    if m.kbLayer = "symbols"
        keys = "1234567890-.,:;!?'" + Chr(34) + "()&+/@#%_=*"
        symTitle = "ABC"
        if m.kbLang = "ru" then symTitle = "АБВ"
    else if m.kbLang = "ru"
        keys = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
        symTitle = "123"
    else
        keys = "abcdefghijklmnopqrstuvwxyz"
        symTitle = "123"
    end if
    root = CreateObject("roSGNode", "ContentNode")
    for i = 1 to Len(keys)
        n = root.createChild("ContentNode")
        n.title = Mid(keys, i, 1)
    end for
    langTitle = "EN"
    if m.kbLang = "en" then langTitle = "RU"
    m.barNodes[0].itemContent = barContent(langTitle, "", "")
    m.barNodes[1].itemContent = barContent(symTitle, "", "")
    m.kb.numRows = (root.getChildCount() + 6) \ 7
    m.kb.content = root
end sub

sub updateQuery()
    if m.kbText = ""
        m.query.text = "Введите название…"
        m.query.color = "#6C5C8F"
    else
        m.query.text = m.kbText + "_"
        m.query.color = "#FFFFFF"
    end if
end sub

function barContent(title as String, icon as String, iconFocus as String) as Object
    n = CreateObject("roSGNode", "ContentNode")
    n.title = title
    n.HDPosterUrl = icon
    n.ShortDescriptionLine1 = iconFocus
    return n
end function

sub onKeySelected(event as Object)
    node = m.kb.content.getChild(event.getData())
    if node = invalid then return
    m.kbText = m.kbText + node.title
    typed()
end sub

sub typed()
    updateQuery()
    m.searchTimer.control = "stop"
    m.searchTimer.control = "start"
end sub

sub setBarFocus(on as Boolean)
    for i = 0 to 3
        m.barNodes[i].itemHasFocus = (on and i = m.barIdx)
    end for
end sub

sub barAction()
    if m.barIdx = 0
        if m.kbLang = "ru" then m.kbLang = "en" else m.kbLang = "ru"
        m.kbLayer = "letters"
        buildKeys()
        return
    else if m.barIdx = 1
        if m.kbLayer = "letters" then m.kbLayer = "symbols" else m.kbLayer = "letters"
        buildKeys()
        return
    else if m.barIdx = 2
        if Len(m.kbText) > 0 then m.kbText = m.kbText + " "
    else
        if Len(m.kbText) > 0 then m.kbText = Left(m.kbText, Len(m.kbText) - 1)
    end if
    typed()
end sub

sub focusKb()
    setBarFocus(false)
    m.kb.setFocus(true)
end sub

sub focusBar()
    m.kbBar.setFocus(true)
    setBarFocus(true)
end sub

sub onSearchTimer()
    if m.sections[m.secIdx].id <> "search" then return
    q = m.kbText.Trim()
    m.gen = m.gen + 1
    if Len(q) < 2
        m.grid.visible = false
        m.empty.visible = false
        m.gridNodes = invalid
        return
    end if
    kpFetch("/v1/items/search", { q: q }, "onSearchResult", "s" + m.gen.ToStr())
end sub

sub onSearchResult(event as Object)
    res = event.getData()
    if res.tag <> "s" + m.gen.ToStr() then return
    if checkAuth(res) then return
    nodes = nodesFromItems(extractItems(res))
    if nodes.Count() = 0
        m.grid.visible = false
        m.gridNodes = invalid
        showEmpty("Ничего не найдено")
        return
    end if
    m.empty.visible = false
    m.gridNodes = CreateObject("roSGNode", "ContentNode")
    m.gridNodes.appendChildren(nodes)
    m.grid.content = m.gridNodes
    m.grid.visible = true
end sub

' ============ карточка ============
sub openDetail(id as String)
    m.pendingFocus = false
    m.returnTo = invalid
    if m.rows.isInFocusChain() then m.returnTo = m.rows
    if m.grid.isInFocusChain() then m.returnTo = m.grid
    m.appView.visible = false
    m.detail.visible = true
    m.detail.itemId = id
    m.detail.setFocus(true)
end sub

sub onDetailClosed()
    m.detail.visible = false
    m.appView.visible = true
    if m.dirty and m.sections[m.secIdx].id = "home"
        m.dirty = false
        m.pendingFocus = true
        showSection(m.secIdx)
        return
    end if
    m.dirty = false
    if m.returnTo <> invalid
        m.returnTo.setFocus(true)
    else
        m.menu.setFocus(true)
    end if
end sub

' ============ настройки ============
sub loadSettings()
    kpFetch("/v1/device/info", {}, "onDeviceInfo", "d" + m.gen.ToStr())
end sub

sub onDeviceInfo(event as Object)
    res = event.getData()
    if res.tag <> "d" + m.gen.ToStr() and res.tag <> "save" then return
    if checkAuth(res) then return
    ok = false
    if res.json <> invalid
        if Type(res.json) = "roAssociativeArray"
            if res.json.device <> invalid then ok = true
        end if
    end if
    if not ok
        showEmpty("Не удалось загрузить настройки")
        return
    end if
    m.devId = res.json.device.id.ToStr()
    m.devSet = res.json.device.settings
    buildSettings()
end sub

function selectedLabel(st as Object) as String
    if st.value = invalid then return ""
    for each o in st.value
        if o.selected = 1 then return o.label
    end for
    return ""
end function

function boolText(st as Object) as String
    if st.value = 1 then return "Вкл"
    return "Выкл"
end function

sub buildSettings()
    m.setDefs = [
        { key: "streamingType", title: "Тип потока", kind: "list" }
        { key: "serverLocation", title: "Сервер (страна)", kind: "list" }
        { key: "support4k", title: "Поддержка 4K", kind: "bool" }
        { key: "supportHevc", title: "Поддержка HEVC (H.265)", kind: "bool" }
        { key: "supportHdr", title: "Поддержка HDR", kind: "bool" }
        { key: "supportSsl", title: "Защищённое соединение (SSL)", kind: "bool" }
        { key: "mixedPlaylist", title: "Смешанный плейлист", kind: "bool" }
        { key: "skip", title: "Кнопка «Пропустить заставку» (AniSkip)", kind: "local" }
        { key: "", title: "Рекомендуемые настройки (HLS4, HEVC, 4K)", kind: "recommended" }
        { key: "", title: "Выйти из аккаунта", kind: "logout" }
    ]
    root = CreateObject("roSGNode", "ContentNode")
    for each d in m.setDefs
        n = root.createChild("ContentNode")
        n.title = d.title
        n.ShortDescriptionLine1 = ""
        if d.kind = "local"
            n.ShortDescriptionLine1 = "Вкл"
            if regRead("skip_off") = "1" then n.ShortDescriptionLine1 = "Выкл"
        else if d.key <> ""
            st = m.devSet[d.key]
            if st <> invalid
                if d.kind = "list" then n.ShortDescriptionLine1 = selectedLabel(st)
                if d.kind = "bool" then n.ShortDescriptionLine1 = boolText(st)
            end if
        end if
    end for
    idx = m.setList.itemFocused
    m.setList.content = root
    if idx > 0 then m.setList.jumpToItem = idx
    setLoading(false)
    m.hint.text = "Изменения применяются к следующему запуску видео"
    m.setList.visible = true
    if m.pendingFocus then focusContent()
end sub

sub saveSetting(body as String)
    kpFetch("/v1/device/" + m.devId + "/settings", {}, "onSettingSaved", "save", "POST", "api", body)
end sub

sub onSettingSaved(event as Object)
    kpFetch("/v1/device/info", {}, "onDeviceInfo", "save")
end sub

sub onSettingSelected(event as Object)
    d = m.setDefs[event.getData()]
    if d.kind = "local"
        if regRead("skip_off") = "1" then regDelete("skip_off") else regWrite("skip_off", "1")
        buildSettings()
        return
    end if
    if d.kind = "bool"
        cur = 0
        st = m.devSet[d.key]
        if st <> invalid
            if st.value = 1 then cur = 1
        end if
        saveSetting(d.key + "=" + (1 - cur).ToStr())
    else if d.kind = "list"
        st = m.devSet[d.key]
        if st = invalid then return
        m.pickDef = d
        m.pickOptions = st.value
        labels = []
        cur = 0
        for i = 0 to m.pickOptions.Count() - 1
            o = m.pickOptions[i]
            lb = o.label
            if o.selected = 1
                lb = o.label + "  (текущий)"
                cur = i
            end if
            labels.Push(lb)
        end for
        openPicker(d.title, labels, cur, "setting", m.setList)
    else if d.kind = "recommended"
        di = CreateObject("roDeviceInfo")
        hevc = "0"
        if di.CanDecodeVideo({ Codec: "hevc" }).result then hevc = "1"
        k4 = "0"
        if Instr(1, di.GetVideoMode(), "2160") > 0 then k4 = "1"
        saveSetting("streamingType=4&supportHevc=" + hevc + "&support4k=" + k4)
    else if d.kind = "logout"
        confirmLogout()
    end if
end sub

sub onPickSelected(event as Object)
    idx = event.getData()
    mode = m.pickMode
    closePicker()
    if mode = "setting"
        if m.pickDef <> invalid and idx < m.pickOptions.Count()
            saveSetting(m.pickDef.key + "=" + m.pickOptions[idx].id.ToStr())
        end if
    else if mode = "fmenu"
        if idx = 0
            labels = []
            for each so in m.sorts
                labels.Push(so.title)
            end for
            openPicker("Сортировка", labels, m.sortIdx, "fsort", m.grid)
        else if idx = 1
            kpFetch("/v1/genres", { type: filterType() }, "onRefGenres", "g")
        else if idx = 2
            kpFetch("/v1/countries", {}, "onRefCountries", "c")
        else if idx = 3
            m.yearVals = ["", "2026", "2025", "2024", "2023", "2022", "2020-2021", "2010-2019", "2000-2009", "1990-1999", "1900-1989"]
            m.yearNames = ["Все", "2026", "2025", "2024", "2023", "2022", "2020–2021", "2010–2019", "2000–2009", "1990–1999", "до 1990"]
            openPicker("Год выхода", m.yearNames, 0, "fyear", m.grid)
        else
            clearFilters()
            m.sortIdx = 0
            reloadGrid()
        end if
    else if mode = "fsort"
        m.sortIdx = idx
        reloadGrid()
    else if mode = "fgenre"
        if idx = 0
            m.fGenre = ""
            m.fGenreName = "Все"
        else
            m.fGenre = m.refGenres[idx - 1].id.ToStr()
            m.fGenreName = m.refGenres[idx - 1].title
        end if
        reloadGrid()
    else if mode = "fcountry"
        if idx = 0
            m.fCountry = ""
            m.fCountryName = "Все"
        else
            m.fCountry = m.refCountries[idx - 1].id.ToStr()
            m.fCountryName = m.refCountries[idx - 1].title
        end if
        reloadGrid()
    else if mode = "fyear"
        m.fYear = m.yearVals[idx]
        m.fYearName = m.yearNames[idx]
        reloadGrid()
    end if
end sub

sub closePicker()
    m.pickPanel.visible = false
    if m.pickReturn <> invalid
        m.pickReturn.setFocus(true)
    else
        m.setList.setFocus(true)
    end if
end sub

' ============ плеер ============
sub onPlayRequest(event as Object)
    startPlayback(event.getData())
end sub

function currentEpisode() as Object
    p = m.play
    if p.season >= 0 then return p.item.seasons[p.season].episodes[p.epIdx]
    return p.item.videos[p.epIdx]
end function

function currentSeasonNumber() as Integer
    p = m.play
    if p.season >= 0
        n = p.item.seasons[p.season].number
        if n <> invalid then return n
    end if
    return 0
end function

sub startPlayback(req as Object)
    m.play = req
    ep = currentEpisode()
    stream = pickStream(ep.files)
    if stream.url = ""
        showMessage("Нет потока", "Для этого видео нет доступных ссылок. Проверьте подписку и настройки устройства на kino.pub (HLS4, HEVC, 4K).")
        return
    end if
    heading = splitTitle(req.item.title).main
    if req.season >= 0
        en = ""
        if ep.number <> invalid then en = ep.number.ToStr()
        heading = heading + " — S" + currentSeasonNumber().ToStr() + "E" + en
    end if
    m.streamMeta = stream
    c = CreateObject("roSGNode", "ContentNode")
    c.url = stream.url
    c.streamFormat = stream.fmt
    c.title = heading
    c.PlayStart = Int(req.start)
    m.video.content = c
    m.appView.visible = false
    m.detail.visible = false
    m.video.visible = true
    m.video.setFocus(true)
    m.video.control = "play"
    startSkipLookup(req)
    m.progressTimer.control = "start"
    m.isTrailer = false
    m.nextTimer.control = "start"
    m.trackHint.visible = true
    m.hintTimer.control = "stop"
    m.hintTimer.control = "start"
end sub

' --- диагностика потока ---
sub toggleStats()
    if m.statsPanel.visible
        m.statsPanel.visible = false
        m.statsTimer.control = "stop"
    else
        m.statsPanel.visible = true
        updateStats()
        m.statsTimer.control = "start"
    end if
end sub

function fld(aa as Dynamic, key as String) as Dynamic
    if aa = invalid then return invalid
    if Type(aa) <> "roAssociativeArray" then return invalid
    return aa[key]
end function

function nstr(x as Dynamic) as String
    if x = invalid then return ""
    return x.ToStr()
end function

function mbps(bps as Dynamic) as String
    if bps = invalid then return "—"
    v = Val(bps.ToStr())
    if v <= 0 then return "—"
    return (Int(v / 100000) / 10).ToStr() + " Мбит/с"
end function

sub updateStats()
    if not m.statsPanel.visible then return
    v = m.video
    lines = []
    ttl = ""
    if v.content <> invalid then ttl = v.content.title
    lines.Push(ttl)
    dur = v.duration
    pct = ""
    if dur > 0 then pct = "  (" + Int(v.position * 100 / dur).ToStr() + "%)"
    lines.Push("Время: " + fmtTime(v.position) + " / " + fmtTime(dur) + pct + "  ·  " + nstr(v.state))

    seg = fld(v, "downloadedSegment")
    if seg = invalid then seg = fld(v, "streamingSegment")
    w = fld(seg, "width")
    h = fld(seg, "height")
    res = ""
    if w <> invalid and h <> invalid
        if w > 0 then res = w.ToStr() + "×" + h.ToStr()
    end if
    if res = "" and m.streamMeta.w > 0 then res = m.streamMeta.w.ToStr() + "×" + m.streamMeta.h.ToStr() + " (файл)"
    segBps = fld(seg, "segBitrateBps")
    codec = m.streamMeta.codec
    if codec = "" then codec = UCase(nstr(v.videoFormat))
    lines.Push("Видео: " + res + "  ·  " + codec + "  ·  " + mbps(segBps))

    si = v.streamInfo
    lines.Push("Поток: " + m.streamMeta.kind + "  ·  заявлено " + mbps(fld(si, "streamBitrate")) + "  ·  скорость сети " + mbps(fld(si, "measuredBitrate")))

    audio = ""
    cur = nstr(v.currentAudioTrack)
    if v.availableAudioTracks <> invalid
        for each t in v.availableAudioTracks
            if nstr(t.Track) = cur and t.Name <> invalid and audio = "" then audio = cleanAudioName(t.Name)
        end for
    end if
    if audio = "" then audio = "—"
    lines.Push("Звук: " + audio + "  ·  " + nstr(v.audioFormat))

    subs = "выключены"
    if nstr(v.globalCaptionMode) = "On"
        subs = "включены"
        cs = nstr(v.currentSubtitleTrack)
        if v.availableSubtitleTracks <> invalid
            for each t in v.availableSubtitleTracks
                if nstr(t.TrackName) = cs and t.Language <> invalid then subs = langName(t.Language)
            end for
        end if
    end if
    lines.Push("Субтитры: " + subs)

    di = CreateObject("roDeviceInfo")
    lines.Push("Экран: " + di.GetVideoMode() + "  ·  Roku " + di.GetModel())
    m.statsText.text = lines.Join(Chr(10))
end sub

sub onHintTimer()
    m.trackHint.visible = false
end sub

sub onLaunch()
    a = m.top.launchArgs
    if a = invalid then return
    if regRead("access_token") = "" then return
    if a.section <> invalid
        for i = 0 to m.sections.Count() - 1
            if m.sections[i].id = a.section
                m.pendingFocus = true
                showSection(i)
            end if
        end for
    end if
    if a.contentId <> invalid then openDetail(a.contentId)
    if a.autoplay <> invalid
        m.autoPanel = (a.panel <> invalid)
        m.autoSeason = 1
        m.autoEp = 1
        if a.season <> invalid then m.autoSeason = Int(Val(a.season))
        if a.ep <> invalid then m.autoEp = Int(Val(a.ep))
        kpFetch("/v1/items/" + a.autoplay, {}, "onAutoItem", "auto")
    end if
    if a.probe <> invalid
        q = a.probe.Split("?")
        pr = {}
        if q.Count() > 1
            for each kv in q[1].Split("&")
                p = kv.Split("=")
                if p.Count() = 2 then pr[p[0]] = p[1]
            end for
        end if
        kpFetch(q[0], pr, "onMarkResult", "probe")
    end if
end sub

' ---------- озвучка и субтитры ----------
function langName(code as String) as String
    c = LCase(code)
    cut = Instr(1, c, "-")
    if cut > 0 then c = Left(c, cut - 1)
    cut = Instr(1, c, "_")
    if cut > 0 then c = Left(c, cut - 1)
    names = {
        rus: "Русский", ru: "Русский", eng: "Английский", en: "Английский", ukr: "Украинский", uk: "Украинский"
        bel: "Белорусский", be: "Белорусский", ger: "Немецкий", deu: "Немецкий", de: "Немецкий"
        fre: "Французский", fra: "Французский", fr: "Французский", spa: "Испанский", es: "Испанский"
        ita: "Итальянский", it: "Итальянский", jpn: "Японский", ja: "Японский", kor: "Корейский", ko: "Корейский"
        chi: "Китайский", zho: "Китайский", zh: "Китайский", cmn: "Китайский", yue: "Китайский (кантонский)"
        pol: "Польский", pl: "Польский", tur: "Турецкий", tr: "Турецкий", por: "Португальский", pt: "Португальский"
        cze: "Чешский", ces: "Чешский", cs: "Чешский", hun: "Венгерский", hu: "Венгерский", lat: "Латинский", la: "Латинский"
        heb: "Иврит", he: "Иврит", ara: "Арабский", ar: "Арабский", bul: "Болгарский", bg: "Болгарский"
        srp: "Сербский", sr: "Сербский", hrv: "Хорватский", hr: "Хорватский", cat: "Каталанский", ca: "Каталанский"
        dan: "Датский", da: "Датский", dut: "Нидерландский", nld: "Нидерландский", nl: "Нидерландский"
        fin: "Финский", fi: "Финский", gre: "Греческий", ell: "Греческий", el: "Греческий", hin: "Хинди", hi: "Хинди"
        ind: "Индонезийский", id: "Индонезийский", nor: "Норвежский", nob: "Норвежский", no: "Норвежский"
        rum: "Румынский", ron: "Румынский", ro: "Румынский", swe: "Шведский", sv: "Шведский", tha: "Тайский", th: "Тайский"
        vie: "Вьетнамский", vi: "Вьетнамский", lit: "Литовский", lt: "Литовский", lav: "Латышский", lv: "Латышский"
        est: "Эстонский", et: "Эстонский", slo: "Словацкий", slk: "Словацкий", sk: "Словацкий", slv: "Словенский", sl: "Словенский"
        mac: "Македонский", mkd: "Македонский", mk: "Македонский", per: "Персидский", fas: "Персидский", fa: "Персидский"
        geo: "Грузинский", kat: "Грузинский", ka: "Грузинский", arm: "Армянский", hye: "Армянский", hy: "Армянский"
        aze: "Азербайджанский", az: "Азербайджанский", kaz: "Казахский", kk: "Казахский", uzb: "Узбекский", uz: "Узбекский"
        fil: "Филиппинский", tgl: "Филиппинский", may: "Малайский", msa: "Малайский", ms: "Малайский"
        ben: "Бенгальский", bn: "Бенгальский", tam: "Тамильский", ta: "Тамильский", tel: "Телугу", te: "Телугу", urd: "Урду", ur: "Урду"
        ice: "Исландский", isl: "Исландский", is: "Исландский", alb: "Албанский", sqi: "Албанский", sq: "Албанский"
        bos: "Боснийский", bs: "Боснийский", glg: "Галисийский", gl: "Галисийский", baq: "Баскский", eus: "Баскский", eu: "Баскский"
        und: "Не указан", mul: "Несколько языков", zxx: "Без речи"
    }
    if names[c] <> invalid then return names[c]
    return UCase(code)
end function

function chanText(n as Dynamic) as String
    if n = invalid then return ""
    v = Int(Val(n.ToStr()))
    if v = 1 then return "1.0"
    if v = 2 then return "2.0"
    if v = 6 then return "5.1"
    if v = 8 then return "7.1"
    if v > 0 then return v.ToStr() + ".0"
    return ""
end function

function audioLabel(t as Object, i as Integer, meta as Dynamic) as String
    lang = ""
    if t.Language <> invalid then lang = t.Language
    typ = ""
    author = ""
    tech = ""
    if meta <> invalid
        if meta.Count() > i
            mt = meta[i]
            if mt.type <> invalid
                if mt.type.title <> invalid then typ = mt.type.title
            end if
            if mt.author <> invalid
                if mt.author.title <> invalid then author = mt.author.title
            end if
            if mt.lang <> invalid then lang = mt.lang
            codec = ""
            if mt.codec <> invalid then codec = UCase(mt.codec)
            tech = (codec + " " + chanText(mt.channels)).Trim()
        end if
    end if
    parts = []
    ln = ""
    if lang <> "" then ln = langName(lang)
    if ln <> "" and (LCase(lang) <> "rus" or typ = "") then parts.Push(ln)
    if typ <> "" then parts.Push(typ)
    if author <> "" then parts.Push(author)
    if tech <> "" then parts.Push(tech)
    if parts.Count() = 0
        if t.Name <> invalid then parts.Push(t.Name)
    end if
    if parts.Count() = 0 then return "Дорожка " + (i + 1).ToStr()
    return parts.Join(" · ")
end function

function subRank(label as String) as String
    if label = "Русский" then return "0"
    if label = "Английский" then return "1"
    return "2" + label
end function

function cleanAudioName(nm as String) as String
    rx = CreateObject("roRegex", "^[0-9]+\.\s*", "")
    out = rx.Replace(nm, "")
    out = out.Replace(". ", " · ")
    return out
end function

sub showTrackPanel()
    vid = m.video
    ' --- озвучка: Roku отдаёт одни и те же дорожки по разу на каждое качество, убираем повторы ---
    avail = []
    if vid.availableAudioTracks <> invalid then avail = vid.availableAudioTracks
    m.audioTracks = []
    labels = []
    seen = {}
    for i = 0 to avail.Count() - 1
        t = avail[i]
        nm = ""
        if t.Name <> invalid then nm = t.Name
        key = nm
        if key = "" then key = "lang:" + LCase(t.Language) + ":" + t.Track
        if not seen.DoesExist(key)
            seen[key] = true
            m.audioTracks.Push(t)
            if nm <> ""
                labels.Push(cleanAudioName(nm))
            else
                labels.Push(audioLabel(t, labels.Count(), invalid))
            end if
        end if
    end for
    ar = CreateObject("roSGNode", "ContentNode")
    for each lb in labels
        n = ar.createChild("ContentNode")
        n.title = lb
    end for
    if labels.Count() = 0
        n = ar.createChild("ContentNode")
        n.title = "Одна дорожка"
    end if
    m.audioList.content = ar

    ' --- субтитры: по одному на язык ---
    subAvail = []
    if vid.availableSubtitleTracks <> invalid then subAvail = vid.availableSubtitleTracks
    m.subTracks = []
    sl = []
    seenL = {}
    for each at in subAvail
        lg = "?"
        if at.Language <> invalid then lg = LCase(at.Language)
        nameKey = langName(lg)
        if not seenL.DoesExist(nameKey)
            seenL[nameKey] = true
            m.subTracks.Push(at)
            sl.Push(nameKey)
        end if
    end for
    ' сортировка: русский, английский, остальные по алфавиту
    for a1 = 1 to sl.Count() - 1
        for b1 = 0 to sl.Count() - 1 - a1
            if subRank(sl[b1]) > subRank(sl[b1 + 1])
                tl = sl[b1] : sl[b1] = sl[b1 + 1] : sl[b1 + 1] = tl
                tt = m.subTracks[b1] : m.subTracks[b1] = m.subTracks[b1 + 1] : m.subTracks[b1 + 1] = tt
            end if
        end for
    end for
    sr = CreateObject("roSGNode", "ContentNode")
    n = sr.createChild("ContentNode")
    n.title = "Выключены"
    for each lb in sl
        n = sr.createChild("ContentNode")
        n.title = lb
    end for
    m.subList.content = sr
    m.hintTimer.control = "stop"
    m.trackHint.visible = false
    m.video.control = "pause"
    m.trackPanel.visible = true
    m.audioList.setFocus(true)
end sub

sub closeTrackPanel()
    m.trackPanel.visible = false
    m.video.control = "resume"
    m.video.setFocus(true)
end sub

sub onAudioSelected(event as Object)
    idx = event.getData()
    if idx < m.audioTracks.Count()
        m.video.audioTrack = m.audioTracks[idx].Track
    end if
    closeTrackPanel()
end sub

sub onSubSelected(event as Object)
    idx = event.getData()
    if idx = 0
        m.video.globalCaptionMode = "Off"
    else if idx - 1 < m.subTracks.Count()
        m.video.globalCaptionMode = "On"
        m.video.subtitleTrack = m.subTracks[idx - 1].TrackName
    end if
    closeTrackPanel()
end sub

sub markProgress(secs as Integer, callback as String)
    if m.play = invalid then return
    ep = currentEpisode()
    num = 1
    if ep.number <> invalid then num = ep.number
    params = { id: m.play.item.id, video: num, time: secs }
    sn = currentSeasonNumber()
    if sn > 0 then params.season = sn
    kpFetch("/v1/watching/marktime", params, callback, "mark")
end sub

sub onMarkResult(event as Object)
end sub

' --- пропуск заставки (AniSkip) ---
function pad7(n as Dynamic) as String
    sd = n.ToStr()
    while Len(sd) < 7
        sd = "0" + sd
    end while
    return sd
end function

sub resetSkip()
    m.skipGen = m.skipGen + 1
    m.skipSegs = []
    m.skipDismissed = {}
    m.skipCur = -1
    if m.skipBtn.visible then hideSkip(false)
end sub

sub startSkipLookup(req as Object)
    resetSkip()
    if regRead("skip_off") = "1" then return
    it = req.item
    if it.imdb = invalid then return
    season = 0
    if req.season >= 0
        sn = it.seasons[req.season].number
        if sn <> invalid then season = sn
    end if
    ep = currentEpisode()
    epNum = 1
    if ep.number <> invalid then epNum = ep.number
    tag = "k" + m.skipGen.ToStr() + ":" + season.ToStr() + ":" + epNum.ToStr()
    kpFetch("https://arm.haglund.dev/api/v2/imdb?id=tt" + pad7(it.imdb), {}, "onSkipArm", tag, "GET", "ext")
end sub

sub onSkipArm(event as Object)
    res = event.getData()
    parts = res.tag.Split(":")
    if Val(Mid(parts[0], 2)) <> m.skipGen then return
    if res.code <> 200 or res.json = invalid then return
    if Type(res.json) <> "roArray" then return
    season = Int(Val(parts[1]))
    epNum = Int(Val(parts[2]))
    mal = invalid
    for each e in res.json
        if e.myanimelist <> invalid
            s1 = e["thetvdb-season"]
            if s1 = invalid then s1 = e["themoviedb-season"]
            if season = 0
                if mal = invalid then mal = e.myanimelist
            else if s1 <> invalid
                if s1 = season and mal = invalid then mal = e.myanimelist
            end if
        end if
    end for
    if mal = invalid and season = 1 and res.json.Count() > 0
        mal = res.json[0].myanimelist
    end if
    if mal = invalid then return
    url = "https://api.aniskip.com/v2/skip-times/" + mal.ToStr() + "/" + epNum.ToStr() + "?types=op&types=ed&types=mixed-op&types=mixed-ed&types=recap&episodeLength=0"
    kpFetch(url, {}, "onSkipTimes", parts[0], "GET", "ext")
end sub

sub onSkipTimes(event as Object)
    res = event.getData()
    if Val(Mid(res.tag, 2)) <> m.skipGen then return
    if res.code <> 200 or res.json = invalid then return
    if Type(res.json) <> "roAssociativeArray" then return
    if res.json.found = invalid then return
    if res.json.results = invalid then return
    if res.json.found = false then return
    segs = []
    for each r in res.json.results
        if r.interval <> invalid and r.skipType <> invalid
            segs.Push({ s: r.interval.startTime, e: r.interval.endTime, kind: r.skipType })
        end if
    end for
    m.skipSegs = segs
end sub

function skipLabel(kind as String) as String
    if kind = "ed" or kind = "mixed-ed" then return "Пропустить титры"
    if kind = "recap" then return "Пропустить пересказ"
    return "Пропустить заставку"
end function

sub checkSkip()
    if m.skipSegs.Count() = 0 then return
    if not m.video.visible or m.isTrailer or m.trackPanel.visible then return
    now = m.video.position
    cur = -1
    for i = 0 to m.skipSegs.Count() - 1
        sg = m.skipSegs[i]
        if now >= sg.s - 1 and now < sg.e - 2 then cur = i
    end for
    if cur = -1
        if m.skipBtn.visible then hideSkip(false)
        return
    end if
    if m.skipBtn.visible
        if m.skipClock.TotalSeconds() > 15 then hideSkip(true)
        return
    end if
    if m.skipDismissed.DoesExist("i" + cur.ToStr()) then return
    if m.video.state <> "playing" then return
    m.skipCur = cur
    m.skipText.text = skipLabel(m.skipSegs[cur].kind) + "   ·   OK"
    print "KPSKIP show "; m.skipSegs[cur].kind; " "; m.skipSegs[cur].s; "-"; m.skipSegs[cur].e; " pos="; now
    m.skipBtn.visible = true
    m.skipClock.Mark()
    m.skipHolder.setFocus(true)
end sub

sub hideSkip(dismiss as Boolean)
    if dismiss and m.skipCur >= 0 then m.skipDismissed["i" + m.skipCur.ToStr()] = true
    m.skipBtn.visible = false
    if m.video.visible then m.video.setFocus(true)
end sub

sub doSkip()
    if m.skipCur >= 0 and m.skipCur < m.skipSegs.Count()
        m.video.seek = m.skipSegs[m.skipCur].e
        print "KPSKIP seek "; m.skipSegs[m.skipCur].e
    end if
    hideSkip(true)
end sub

' --- состояние сервера (слева внизу) ---
sub onApiStatus()
    st = m.global.apiStatus
    note = m.global.apiNote
    if st = "ok"
        m.apiDot.color = "#3DDC84"
        m.apiText.text = "Kino.pub: работает"
        m.apiText.color = "#A99BC4"
    else if st = "slow"
        m.apiDot.color = "#FFB020"
        m.apiText.text = "Kino.pub тормозит: " + note
        m.apiText.color = "#FFC857"
    else
        m.apiDot.color = "#FF5A5F"
        m.apiText.text = "Kino.pub: " + note + ". Попробуйте позже"
        m.apiText.color = "#FF8A8E"
    end if
end sub

' --- трейлер ---
sub onTrailerRequest(event as Object)
    req = event.getData()
    m.isTrailer = true
    m.play = invalid
    m.autoPanel = false
    m.streamMeta = { kind: "Трейлер", w: 0, h: 0, codec: "", fmt: req.fmt, url: req.url }
    c = CreateObject("roSGNode", "ContentNode")
    c.url = req.url
    c.streamFormat = req.fmt
    c.title = "Трейлер — " + req.title
    m.video.content = c
    m.appView.visible = false
    m.detail.visible = false
    m.video.visible = true
    m.video.setFocus(true)
    m.video.control = "play"
    m.nextTimer.control = "stop"
    m.nextHint.visible = false
end sub

' --- подсказка «следующая серия» ---
function nextEpisodePos() as Dynamic
    p = m.play
    if p = invalid then return invalid
    if p.season < 0 then return invalid
    eps = p.item.seasons[p.season].episodes
    if p.epIdx + 1 < eps.Count() then return { item: p.item, season: p.season, epIdx: p.epIdx + 1, start: 0 }
    if p.season + 1 < p.item.seasons.Count() then return { item: p.item, season: p.season + 1, epIdx: 0, start: 0 }
    return invalid
end function

sub onNextTick()
    checkSkip()
    if not m.video.visible or m.isTrailer
        m.nextHint.visible = false
        return
    end if
    dur = m.video.duration
    left = dur - m.video.position
    if dur > 120 and left <= 20 and left > 0 and nextEpisodePos() <> invalid and m.video.state = "playing"
        m.nextHint.text = "Следующая серия через " + Int(left).ToStr() + " с"
        m.nextHint.visible = true
    else
        m.nextHint.visible = false
    end if
end sub

sub onAutoItem(event as Object)
    res = event.getData()
    if res.json = invalid then return
    if res.json.item = invalid then return
    it = res.json.item
    si = -1
    ei = 0
    if it.seasons <> invalid
        si = m.autoSeason - 1
        ei = m.autoEp - 1
    end if
    startPlayback({ item: it, season: si, epIdx: ei, start: 0 })
end sub

sub onProgressTick()
    if m.video.state = "playing" then markProgress(Int(m.video.position), "onMarkResult")
end sub

sub onVideoState()
    st = m.video.state
    if st = "playing" and m.autoPanel = true
        m.autoPanel = false
        showTrackPanel()
    end if
    if st = "paused"
        markProgress(Int(m.video.position), "onMarkResult")
    else if st = "finished"
        onFinished()
    else if st = "error"
        msg = m.video.errorMsg
        stopPlayback(false)
        showMessage("Ошибка воспроизведения", msg)
    end if
end sub

sub onFinished()
    if m.isTrailer or m.play = invalid
        stopPlayback(false)
        return
    end if
    markProgress(Int(m.video.duration), "onMarkResult")
    p = m.play
    if p.season >= 0
        eps = p.item.seasons[p.season].episodes
        nxt = invalid
        if p.epIdx + 1 < eps.Count()
            nxt = { item: p.item, season: p.season, epIdx: p.epIdx + 1, start: 0 }
        else if p.season + 1 < p.item.seasons.Count()
            nxt = { item: p.item, season: p.season + 1, epIdx: 0, start: 0 }
        end if
        if nxt <> invalid
            m.video.control = "stop"
            startPlayback(nxt)
            return
        end if
    end if
    stopPlayback(false)
end sub

sub stopPlayback(save as Boolean)
    resetSkip()
    m.nextHint.visible = false
    m.nextTimer.control = "stop"
    m.statsPanel.visible = false
    m.statsTimer.control = "stop"
    m.progressTimer.control = "stop"
    secs = Int(m.video.position)
    m.video.control = "stop"
    m.video.visible = false
    m.dirty = true
    m.detail.visible = true
    m.detail.setFocus(true)
    if m.play <> invalid
        pid = m.play.item.id.ToStr()
        if m.detail.itemId <> pid then m.detail.itemId = pid
    end if
    if m.isTrailer
        m.isTrailer = false
        m.detail.focusNow = true
    else if save and secs > 5
        markProgress(secs, "onMarkStopped")
    else
        m.detail.refresh = true
        m.detail.focusNow = true
    end if
end sub

sub onMarkStopped(event as Object)
    m.detail.refresh = true
    m.detail.focusNow = true
end sub

' ============ пульт ============
function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.video.visible and m.skipBtn.visible
        if key = "OK"
            doSkip()
            return true
        else if key = "play"
            if m.video.state = "paused" then m.video.control = "resume" else m.video.control = "pause"
            return true
        else if key <> "back"
            hideSkip(true)
            return true
        end if
    end if
    if m.video.visible
        if m.trackPanel.visible
            if key = "back"
                closeTrackPanel()
            else if key = "right" and m.audioList.isInFocusChain()
                m.subList.setFocus(true)
            else if key = "left" and m.subList.isInFocusChain()
                m.audioList.setFocus(true)
            end if
            return true
        end if
        if key = "back"
            stopPlayback(true)
            return true
        else if key = "options" or key = "down"
            showTrackPanel()
            return true
        else if key = "up"
            toggleStats()
            return true
        end if
        return false
    end if
    if m.detail.visible or m.auth.visible then return false
    if m.pickPanel.visible
        if key = "back" then closePicker()
        return (key = "back")
    end if

    ' ввод с телефона (приложение Roku): символы приходят как отдельные клавиши
    if m.sections[m.secIdx].id = "search" and m.kbGroup.visible
        if key = "backspace"
            if Len(m.kbText) > 0 then m.kbText = Left(m.kbText, Len(m.kbText) - 1)
            typed()
            return true
        else if Len(key) = 1
            m.kbText = m.kbText + LCase(key)
            typed()
            return true
        end if
    end if

    if m.menu.isInFocusChain()
        if key = "right"
            idx = m.menu.itemFocused
            if idx >= 0
                m.pendingFocus = true
                showSection(idx)
                return true
            end if
        end if
        return false
    end if

    if m.kbBar.isInFocusChain()
        if key = "OK"
            barAction()
        else if key = "up"
            focusKb()
        else if key = "left"
            if m.barIdx > 0
                m.barIdx = m.barIdx - 1
                setBarFocus(true)
            else
                setBarFocus(false)
                m.pendingFocus = false
                m.menu.setFocus(true)
            end if
        else if key = "right"
            if m.barIdx < 3
                m.barIdx = m.barIdx + 1
                setBarFocus(true)
            else if m.grid.visible
                setBarFocus(false)
                m.pendingFocus = true
                m.grid.setFocus(true)
            end if
        else if key = "back"
            setBarFocus(false)
            m.pendingFocus = false
            m.menu.setFocus(true)
        end if
        return true
    end if

    if m.kb.isInFocusChain()
        if key = "down"
            focusBar()
            return true
        else if key = "left" or key = "back"
            m.pendingFocus = false
            m.menu.setFocus(true)
            return true
        else if key = "right" and m.grid.visible
            m.pendingFocus = true
            m.grid.setFocus(true)
            return true
        end if
        return false
    end if

    sec = m.sections[m.secIdx].id
    if key = "options" and m.grid.isInFocusChain()
        if m.gridKind = "items"
            openFilterMenu()
            return true
        end if
    end if
    if key = "back" and m.gridKind = "collection"
        m.pendingFocus = true
        showSection(m.secIdx)
        return true
    end if
    if key = "back" or key = "left"
        if sec = "search"
            focusKb()
        else
            m.pendingFocus = false
            m.menu.setFocus(true)
        end if
        return true
    end if
    return false
end function
