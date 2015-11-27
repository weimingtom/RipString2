-module(chat).
-export([start/0,manage_clients/1,stop/0,find/1]).
-record(player, {id,socket,time=none}).

start() -> 
	chat_server:start(?MODULE,manage_clients).

stop()->
	chat_server:stop(?MODULE),
	timer:sleep(2000),						%%等待所有连接断开
	manage_clients!{exit}.

manage_clients(Players) ->
	receive
	    {connect, Socket} ->
		Player = #player{
			id="guest_"++integer_to_list(random:uniform(100000)), 
			socket=Socket,
			time=time()
			},	%%新增记录 
		io:fwrite("Socket connected: ~w~n", [Socket]),
		NewPlayers =  [Player|Players];				%%累加到列表

	    {disconnect, Socket} ->
		io:fwrite("Socket disconnected: ~w~n", [Socket]),
		Player = find_Socket(Socket, Players),			%%查找socket对应的记录
		NewPlayers = lists:delete(Player, Players);		%%删除记录

	    {chat,Data} ->
		send_data(Players, Data),
		NewPlayers=Players;

	    {list,Uname}->
		find_player(Uname,Players),
		NewPlayers = Players;

	    {exit}->
		NewPlayers="",
		exit({stop, exit})					
	end,
	manage_clients(NewPlayers).





%%对客户端进行广播
send_data(Players, Data) ->
  SendData = fun(Player) ->
    gen_tcp:send(Player#player.socket, Data)			 
  end,
  lists:foreach(SendData, Players).

%%查找指定记录
find_Socket(Socket, Players) ->
    {value, Player} = lists:keysearch(Socket, #player.socket, Players),
    Player.

find_player(Uname, Players) ->
    case lists:keysearch(Uname, #player.id, Players) of
    {value, Player}->
	io:fwrite("Find a player: ~w~n", [Player]);
    _->io:fwrite("No found.~n")
    end.


%%查找用户
find(Uname)->
	client_manager ! {list,Uname}.