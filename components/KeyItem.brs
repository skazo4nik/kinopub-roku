sub refresh()
    w = m.top.width
    h = m.top.height
    bg = m.top.findNode("bg")
    lbl = m.top.findNode("label")
    bg.width = w
    bg.height = h
    lbl.width = w
    lbl.height = h
    icon = m.top.findNode("icon")
    icon.translation = [(w - 36) / 2, (h - 36) / 2]
    c = m.top.itemContent
    hasIcon = false
    if c <> invalid
        lbl.text = c.title
        if c.HDPosterUrl <> "" then hasIcon = true
    end if
    icon.visible = hasIcon
    if m.top.itemHasFocus
        bg.color = "#F3E8FF"
        lbl.color = "#2B0B4F"
        if hasIcon then icon.uri = c.ShortDescriptionLine1
    else
        bg.color = "#2E1858"
        lbl.color = "#F6F0FF"
        if hasIcon then icon.uri = c.HDPosterUrl
    end if
end sub
