sub refresh()
    w = m.top.width
    h = m.top.height
    bg = m.top.findNode("bg")
    lt = m.top.findNode("title")
    ls = m.top.findNode("status")
    bg.width = w
    bg.height = h
    lt.translation = [20, 0]
    lt.width = w - 260
    lt.height = h
    ls.translation = [w - 240, 0]
    ls.width = 220
    ls.height = h
    c = m.top.itemContent
    if c <> invalid
        lt.text = c.title
        ls.text = c.ShortDescriptionLine1
    end if
    if m.top.itemHasFocus
        bg.opacity = 1
        lt.color = "#2B0B4F"
        ls.color = "#2B0B4F"
    else
        bg.opacity = 0
        lt.color = "#F6F0FF"
        ls.color = "#A99BC4"
    end if
end sub
