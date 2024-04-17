module FullTest
using Toolips
using Toolips.Components
using ToolipsSession
import Toolips: AbstractConnection

session = Session(["/"])
# extensions
logger = Toolips.Logger()
main = route("/") do c::Toolips.AbstractConnection
    mainbod = body("mainbody")
    style!(mainbod, "transition" => 10s)
    rects = div("rects")
    rpc_rect = div("rpctest", text = "test `rpc!`", trigger = false)
    call_rect = div("calltest", text = "test call (all)")
    call2_rect = div("calltest2", text = "test call (client)")
    common = ("padding" => 15px, "color" => "white", "font-size" => 15pt, 
    "transition" => 2s)
    style!(rpc_rect, "background-color" => "darkred", common ...)
    style!(call_rect, "background-color" => "#333333", common ...)
    style!(call2_rect, "background-color" => "purple", common ...)
    on(click_rpc_rect, c, rpc_rect, "click")
    on(click_call_rect, c, call_rect, "click")
    on(click_call2_rect, c, call2_rect, "click")
    if ~(:peer in keys(c.data))
        push!(c.data, :peer => get_ip(c))
        push!(c.data, :peers => [get_ip(c)])
        open_rpc!(c, tickrate = 30)
    else
        if :peer == get_ip(c)
            ToolipsSession.reconnect_rpc!(c, tirckrate = 30)
        else
            join_rpc!(c, c[:peer], tickrate = 30)
            push!(c.data[:peers], get_ip(c))
        end
    end
    push!(rects, rpc_rect, call_rect, call2_rect)
    push!(mainbod, rects)
    write!(c, mainbod)
end

function click_rpc_rect(c::AbstractConnection, cm::ComponentModifier)
    if cm["rpctest"]["trigger"] == "false"
        style!(cm, "rpctest", "background-color" => "blue")
        cm["rpctest"] = "trigger" => "true"
        rpc!(c, cm)
        return
    end
    cm["rpctest"] = "trigger" => "false"
    style!(cm, "rpctest", "background-color" => "darkred")
    rpc!(c, cm)
end

function click_call_rect(c::AbstractConnection, cm::ComponentModifier)
    alert!(cm, "one of the other peers has called you.")
    call!(c, cm)
end

function click_call2_rect(c::AbstractConnection, cm::ComponentModifier)
    buttonbox = div("buttonbox")
    set_children!(buttonbox, [begin
        but = button("b", text = client)
        on(c, but, "click") do cm::ComponentModifier
            style!(cm, "mainbody", "background-color" => "darkred")
            call!(c, cm, client)
            remove!(cm, buttonbox)
        end
        but
    end for client in c[:peers]])
    append!(cm, "rects", buttonbox)
end

mobile = route("/") do c::Toolips.MobileConnection
    write!(c, "hello mobile device!")
end

# multiroute (will call `mobile` if it is a `MobileConnection`)
home = route(main, mobile)

# make sure to export!
export home, default_404, session
export logger
end # - module FullTest <3