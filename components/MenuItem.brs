sub refresh()
    w = m.top.width
    h = m.top.height
    bg = m.top.findNode("bg")
    lbl = m.top.findNode("label")
    bg.width = w
    bg.height = h
    lbl.translation = [24, 0]
    lbl.width = w - 48
    lbl.height = h
    icon = m.top.findNode("icon")
    icon.translation = [24, (h - 36) / 2]
    c = m.top.itemContent
    hasIcon = false
    if c <> invalid
        lbl.text = c.title
        if c.HDPosterUrl <> "" then hasIcon = true
    end if
    icon.visible = hasIcon
    if m.top.itemHasFocus
        bg.opacity = 1
        lbl.color = "#2B0B4F"
        if hasIcon then icon.uri = c.ShortDescriptionLine1
    else
        bg.opacity = 0
        lbl.color = "#C4B8DA"
        if hasIcon then icon.uri = c.HDPosterUrl
    end if
end sub
