sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    m.global = screen.getGlobalNode()
    m.global.addFields({ apiStatus: "ok", apiNote: "" })
    scene = screen.CreateScene("MainScene")
    screen.Show()
    scene.setFocus(true)
    if args <> invalid then scene.launchArgs = args
    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub
