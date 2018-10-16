import Sockets.connect

server = "chat.freenode.net"
port = 6667

c = connect(server, port)
write(c, "USER juliabot julialangbot julialangbot :This is a fun bot!\r\n")
write(c, "NICK juliabot\r\n")
write(c, "PRIVMSG nickserv :iNOOPE\r\n")
#write(c, "PRIVMSG nickserv :identify blabla\r\n")

sleep(5)

channels = ["#whatever"]

for chan in channels
    write(c, "JOIN $chan\r\n")
end

oo = stdout


while true
    msg = readline(c)
    redirect_stdout(oo)
    println(msg)

    if findfirst("PING", msg) == 1:4
        r = split(msg)[2]
        pong = "PONG $r\r\n"
        write(c, pong)
    elseif occursin(" PRIVMSG", msg)
        who = match(r"^:(.*)!", msg)
        cmd = match(r" :<(.*)", msg)
        channel = match(r"^.*?PRIVMSG (#.*) ", msg)
        if who != nothing && cmd != nothing && channel != nothing
            who = who[1]
            cmd = cmd[1]
            println(cmd)
            channel = channel[1]
            try 
                (or, ow) = redirect_stdout()
                output = eval(Meta.parse(cmd))
                if output != nothing
                    data = output
                else
                    ra = readavailable(or)
                    data = strip(String(ra))
                end
                ret = "PRIVMSG $channel :$data\r\n"
                write(c, ret)
            catch e
                ret = "PRIVMSG $channel :$e\r\n"
                write(c, ret)
            end
        end
    end
end
