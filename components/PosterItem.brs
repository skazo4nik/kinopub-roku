sub refresh()
    w = m.top.width
    if w <= 0 then return
    ph = w * 1.5
    poster = m.top.findNode("poster")
    frame = m.top.findNode("frame")
    poster.width = w
    poster.height = ph
    frame.translation = [-6, -6]
    frame.width = w + 12
    frame.height = ph + 12
    lt = m.top.findNode("title")
    lt.translation = [0, ph + 10]
    lt.width = w
    lt.height = 34
    ls = m.top.findNode("sub")
    ls.translation = [0, ph + 42]
    ls.width = w
    ls.height = 30
    c = m.top.itemContent
    if c <> invalid
        poster.uri = c.HDPosterUrl
        lt.text = c.title
        ls.text = c.ShortDescriptionLine2
        badge = m.top.findNode("badge")
        badge.text = c.ShortDescriptionLine1
        cb = m.top.findNode("cntBg")
        cl = m.top.findNode("cnt")
        cb.translation = [w - 56, 8]
        cl.translation = [w - 56, 8]
        hasCnt = (c.NumEpisodes > 0)
        cb.visible = hasCnt
        cl.visible = hasCnt
        if hasCnt then cl.text = c.NumEpisodes.ToStr()
        visible = (c.ShortDescriptionLine1 <> "")
        badge.visible = visible
        m.top.findNode("badgeBg").visible = visible
    end if
    hasFocus = m.top.itemHasFocus and (m.top.rowListHasFocus or m.top.gridHasFocus)
    frame.visible = hasFocus
    if hasFocus
        lt.color = "#E9D5FF"
    else
        lt.color = "#F6F0FF"
    end if
end sub
