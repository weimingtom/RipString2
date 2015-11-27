-module(chat).
-export([start/0,manage_clients/1,stop/0,find/1]).
-record(player, {id,socket,time=none}).

start() -> 
	chat_server:start(?MODULE,manage_clients).

stop()->
	chat_server:stop(?MODULE),
	timer:sleep(2000),						%%�ȴ��������ӶϿ�
	manage_clients!{exit}.

manage_clients(Players) ->
	receive
	    {connect, Socket} ->
		Player = #player{
			id="guest_"++integer_to_list(random:uniform(100000)), 
			socket=Socket,
			time=time()
			},	%%������¼ 
		io:fwrite("Socket connected: ~w~n", [Socket]),
		NewPlayers =  [Player|Players];				%%�ۼӵ��б�

	    {disconnect, Socket} ->
		io:fwrite("Socket disconnected: ~w~n", [Socket]),
		Player = find_Socket(Socket, Players),			%%����socket��Ӧ�ļ�¼
		NewPlayers = lists:delete(Player, Players);		%%ɾ����¼

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





%%�Կͻ��˽��й㲥
send_data(Players, Data) ->
  SendData = fun(Player) ->
    gen_tcp:send(Player#player.socket, Data)			 
  end,
  lists:foreach(SendData, Players).

%%����ָ����¼
find_Socket(Socket, Players) ->
    {value, Player} = lists:keysearch(Socket, #player.socket, Players),
    Player.

find_player(Uname, Players) ->
    case lists:keysearch(Uname, #player.id, Players) of
    {value, Player}->
	io:fwrite("Find a player: ~w~n", [Player]);
    _->io:fwrite("No found.~n")
    end.


%%�����û�
find(Uname)->
	client_manager ! {list,Uname}.