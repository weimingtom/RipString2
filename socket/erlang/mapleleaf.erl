%% Author: 
%% Created: 
%% Description: 
-module(mapleleaf).
-author('weimingtom').
% -mode(compile).

%%------------------------------------------------------------------------------
%% �ο�����
%%------------------------------------------------------------------------------

%% see 
%% 1. flashbomber
%%    http://code.google.com/p/flashbomber/
%% 2. 
%%    http://www.coolchevy.org.ua/2011/07/25/flash-socket-policy-file-request-in-erlang/
%% 3. 
%%    http://www.simoncobb.co.uk/2008/10/flash-socket-policy-file-in-erlang.html
%% 4. 
%%    http://unbe.cn/erlang_flash_socket_test_02/
%% 5.
%%    http://erlang.group.iteye.com/group/wiki/1456-erlang-a-generic-web-server
%% 6. Programming Erlang: Software for a Concurrent World
%%    http://pragprog.com/book/jaerlang/programming-erlang
%%

% Windows TCP�˿���5000����
% http://support.microsoft.com/default.aspx?scid=kb;en-us;196271

% erlang���˿���
% http://www.erlang.org/doc/man/erlang.html
% Ĭ��1024
% �����ɹ���os:putenv("ERL_MAX_PORTS", "5000"),��
% Windows������
% erl.exe -env ERL_MAX_PORTS 5000
% ����
% set ERL_MAX_PORTS=5000

%%------------------------------------------------------------------------------
%% ��ʽ�ĵ�
%% TCP message format
%%------------------------------------------------------------------------------

%% TODO:
%% 1. ��һ�ֿ����̷�����spawn����Pid
%% spawn(?MODULE, policy_file_server, []),
%% 2. ��һ��listen����
%% {ok, LSock} = gen_tcp:listen(843, [binary, {packet, 0}, {active, false}]),
%% 3. accept�Ĵ�����
%%    case gen_tcp:accept(LSock) of
%%        {ok, Sock} ->
%%            spawn(?MODULE, policy_file_server_proc, [Sock]),
%%            policy_file_server_accept(LSock);
%%        {error, Reason} ->
%%            io:format("policy file server exit: ~s~n", [Reason]),
%%            exit(Reason)
%%    end.
%% 4. ���ַ���д��
%%            gen_tcp:send(Sock, <<
%%                "<?xml version=\"1.0\"?>"
%%                "<cross-domain-policy>",
%%                "<allow-access-from domain=\"*\" to-ports=\"*\" />",
%%                "</cross-domain-policy>",0
%%            >>);
%% 5. ��д�ļ�
%%    {ok, Fd} = file:open("log_file_"++integer_to_list(Count), write),
%%    file:write(Fd, Binary),
%%    file:close(Fd).
%% 6. �ֶη���
%% send(Socket, <<Chunk:100/binary, Rest/binary>>) ->
%%     gen_tcp:send(Socket, Chunk),
%%     send(Socket, Rest);
%% send(Socket, Rest) ->
%%     gen_tcp:send(Socket, Rest).
%% 7. gen_tcp:recv�ĵ�������ָ��timeout
%%

%%------------------------------------------------------------------------------
%% Include files
%% �����ļ��ͺ�
%%------------------------------------------------------------------------------
-define(TCP_OPTIONS,[list, {packet, 0}, {active, false}, {reuseaddr, true}]).
%-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]).

%%------------------------------------------------------------------------------
%% Exported Functions
%% ��������
%%------------------------------------------------------------------------------
%-compile(export_all).
-export([listen/1, start/0, fp_start/0, main/1]).
-export([usage/0]).
%-import(lists, [reverse/1]).
-record(game, {id = "", maxplayers = 4, players = [], actions = []}).

%%------------------------------------------------------------------------------
%% API Functions
%% ������API����
%%------------------------------------------------------------------------------

%%%
%% Ĭ���������˿�5555
start() ->
    listen(5555).

%%%    
%% ������ָ���˿ں�
listen(Port) ->
    % Pid = spawn(fun() -> manage_clients([]) end),
    % register(client_manager, Pid),
    register(client_manager, spawn(fun() -> manage_clients([]) end)),
    register(game_manager, spawn(fun() -> manage_games([]) end)),
    {ok, LSocket} = gen_tcp:listen(Port, ?TCP_OPTIONS),
    do_accept(LSocket).

%%%
%% ����Flash�����ļ�������
fp_start() ->
    {ok, Listen} = gen_tcp:listen(843, [binary,{reuseaddr, true}, {active, true}]),
    % {ok, Listen} = gen_tcp:listen(843, [list,  {reuseaddr, true}, {active, true}]),
    spawn(fun()-> fp_connect(Listen) end).

%%%
%% escriptר�����
%main([]) ->
%    usage();
main(_)->
	fp_start(),
	start(),
	ok.


usage() ->
    io:format("usage: mapple
	
This is ugame mapple socket server.
"),
    halt(1).
    
%%------------------------------------------------------------------------------
%% Local Functions
%% �ֲ�˽�к���
%%------------------------------------------------------------------------------

%%%
%% ��ʼ�����׽���
%% LSocket: �������׽���
do_accept(LSocket) ->
    {ok, Socket} = gen_tcp:accept(LSocket),
    spawn(fun() -> pack_handle_client(Socket) end),
    client_manager ! {connect, Socket},
    do_accept(LSocket).

%%%
%% �µĿͻ��˻Ự���̣��޷��
%% Socket: �ͻ����׽���
handle_client(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
			% io:format("Received: ~p~n", [Data]),
            client_manager ! {data, Data, Socket},
            handle_client(Socket);
        {error, closed} ->
			% exit(closed);
            client_manager ! {disconnect, Socket};
        %% TODO: ����
        {error, Reason} ->
            io:format("Error: ~s~n", Reason),
            exit(Reason)
    end.
    
%%%
%% �µĿͻ��˻Ự���̣�PACK�ṹ�ķ��
%% PACK�ṹ��2�ֽ�ͷħ����, 4�ֽڰ��峤��, ����
%% Socket: �ͻ����׽���
pack_handle_client(Socket) ->
    case gen_tcp:recv(Socket, 6) of
        {ok, Head} ->
			io:format("Recv:~p~n", [Head]),
			<<Head1:8/integer, Head2:8/integer, Size:4/integer-unit:8>> = list_to_binary(Head),
			io:format("Hede1: ~p, Head2: ~p, Size: ~p~n", [Head1, Head2, Size]),
			if 
			Size > 0 ->
				{ok, Packet} = gen_tcp:recv(Socket, Size),
				io:format("Pack Body:~p~n", [Packet]),
				% client_manager ! {data, Packet, Socket},
				pack_handle_client(Socket);
			true ->
				pack_handle_client(Socket)
			end;
        {error, closed} ->
            client_manager ! {disconnect, Socket};
        {error, Reason} ->
            io:format("Error: ~s~n", Reason),
            exit(Reason)
    end.

%%%
%% �����¼���Ӧ�����̣��������ӡ����ߡ����ݴ��䶯��
%% Sockets: ��ǰ���пͻ����׽��ֵĶ���
manage_clients(Sockets) ->
    receive
		{connect, Socket} ->
            io:fwrite("Socket connected ~w~n", [Socket]),
            NewSockets = [Socket | Sockets],
			manage_clients(NewSockets);
		{disconnect, Socket} ->
            io:fwrite("Socket disconnected ~w~n", [Socket]),
            NewSockets = lists:delete(Socket, Sockets),
			manage_clients(NewSockets);
		{data, Data, Socket} ->
			send_data2(Sockets, Data),   
            %%[Action | Rest] = string:tokens(Data, ":"),
            %%case Action of
            %%    "LIST" ->
            %%    	game_manager ! {list, Socket};
            %%    "CREATE" ->
            %%        game_manager ! {create, Socket, Rest};
            %%    "ACT" ->
            %% 		send_data2(Sockets, Data)        
			%%end,			                    
            NewSockets = Sockets,
			manage_clients(NewSockets)
	end.
	
%%%
%% �߼��¼���Ӧ��
%% Games: ��Ϸ״̬��
manage_games(Games) ->
    receive 
        {list, Socket} ->
            lists:foreach(fun(Game) -> gen_tcp:send(Socket, Game#game.id) end, Games),
            NewGames = Games;
        {create, Socket, Data} ->
            [Id, MaxPlayers] = Data,
            NewGames = [#game{id = Id, maxplayers = MaxPlayers, players = [Socket], actions = []} | Games],
            gen_tcp:send(Socket, "New game created."),
        	io:fwrite("Game created ~w~n", NewGames);
        {join, Socket, Data} ->
            [Id | _] = Data,
            Game = [G || G <- Games, G#game.id =:= Id],
			case lists:length(Game#game.players) =:= maxplayers of
				true ->
					gen_tcp:send(Socket, "ERROR:Game full");
				false ->
					gen_tcp:send(Socket, "OK")
			end,
			NewGame = Game#game{players = [Socket | Game#game.players]},
			NewGames = [[G || G <- Games, G#game.id =/= Id] | NewGame];
		{act, Data} ->
			[_Action | Id] = Data,
			Game = [G || G <- Games, G#game.id =:= Id],
			NewGame = Game#game{actions = [Game#game.actions | Data]},
			NewGames = [[G || G <- Games, G#game.id =/= Id] | NewGame];
		{send} ->
			send_data(Games),
			NewGames = clear_actions(Games, [])
	end,
    manage_games(NewGames).                     
    
%%%
%% ��������
%% []: ������
%% [Game | Rest]:
send_data([]) ->
	ok;    
send_data([Game | Rest]) ->
    SendData = fun(Socket) -> 
                    lists:foreach(fun(Action) -> gen_tcp:send(Socket, Action) end, Game#game.actions)
               end,
    lists:foreach(SendData, Game#game.players),
	send_data(Rest).

%%%
%% ��������
%% Sockets: �ͻ����׽����б�
%% Data: ���͵�����
send_data2(Sockets, Data) ->
	SendData = fun(Socket) ->  gen_tcp:send(Socket, Data) end,
    lists:foreach(SendData, Sockets).
	
%%%
%% ��Ϸ�������
%% 
clear_actions([], ClearedGames) ->
	ClearedGames;
clear_actions([Game | Rest], ClearedGames) ->
	NewGame = Game#game{actions = []},
	NewGames = [NewGame | ClearedGames],
	clear_actions(Rest, NewGames).


%%------------------------------------------------------------------------------
%% Flash Policy File Server
%%------------------------------------------------------------------------------

fp_connect(Listen)->
    {ok, Socket} = gen_tcp:accept(Listen),
    spawn(fun()-> fp_connect(Listen) end),
    fp_loop(Socket).

fp_loop(Socket)->
    receive
        % {tcp, Socket, <<"<policy-file-request/>", 0>>} ->
        %    Reply = <<"<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>", 0>>,
		{tcp, Socket, L}->
			io:format(L),
			Reply = "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"5222\" /></cross-domain-policy>\0",	
            gen_tcp:send(Socket, Reply),
            fp_loop(Socket);
        {tcp, closed, Socket}->
            io:format("server closed socket")
    end.

% fp_main(_)->
%	fp_start(),
%	timer:sleep(infinity),
%	ok.
	