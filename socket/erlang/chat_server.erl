-module(chat_server).
-behaviour(gen_server).
-export([start/2,stop/1]).

%% gen_server�ص�
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
        terminate/2,code_change/3]).
-compile(export_all).

-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true},{nodelay, false},{delay_send, true}]).  
%%״̬��
-record(state, {name,loop,socket}).

%%�ص�gen_server��������
start(Name,Loop) -> 
	State=#state{name=Name,loop=Loop},				%%��Ϊ��¼
	gen_server:start_link({local,Name},?MODULE,State,[]).			


%%start() -> 
%%	gen_server:start_link({local,?MODULE},?MODULE,[],[]).		


%%ֹͣ����
stop(Name)  -> 
	gen_server:call(Name,stop).


init(State) -> 
	%%ά������
	register(State#state.loop, spawn(fun() -> (State#state.name):(State#state.loop)([]) end)),
	{Tag, LSocket}=gen_tcp:listen(8080, ?TCP_OPTIONS),			%%Ĭ��8080
	case Tag of								%%��������
		ok	->	spawn(fun() -> do_accept(State#state{socket=LSocket}) end);	%%ͳһ����
		error	->	exit({stop, exit})				%%�����˳�����
	end,
				
	%%��flashͨ�ŵİ�ȫ�����ļ����ͼ����ӿ�
	{Req, AsSocket}=gen_tcp:listen(843, ?TCP_OPTIONS),
	case Req of								
		ok	->	spawn(fun() -> do_accept2(AsSocket) end);	
		error	->	exit({stop, exit})				
	end,
	{ok,LSocket}.

handle_call(stop,_From,Tab)	->
	{stop,normal,stopped,Tab}.


handle_cast(stop,State)		->{stop, normal, State};
handle_cast(_Msg,State)		->{noreply,State}.
handle_info(_Info,State)	->{noreply,State}.
terminate(_Reason,_State)	->ok.
code_change(_OldVsn,State,_)	->{ok,State}.







%% -----------------------------------
%% -------------˽�к���--------------
%% -----------------------------------



%%�½�����,ֻ��������ʱ�ŵ���
do_accept(State) ->
	case gen_tcp:accept(State#state.socket) of
		{ok, Socket}-> 
			%%�������̴�����Ӧ
			spawn(fun() -> handle_client(State,Socket) end),
			%%����������,�־û�
			State#state.loop ! {connect, Socket},
			do_accept(State);
		_->
			ok
	end.	



%%����flash��ȫ�����ļ��ķ��ͷ���
do_accept2(LSocket) ->
	case gen_tcp:accept(LSocket) of
		{ok, Socket}-> 
			spawn(fun() -> put_file(Socket) end),
			do_accept2(LSocket);
		_->ok
	end.

%%�����Ӳ��ԣ�������ر�
put_file(Socket)->
	  case gen_tcp:recv(Socket, 0) of
		{ok, _} ->
			%%�ж����ݷ��ز����ļ�
			gen_tcp:send(Socket, "<?xml version=\"1.0\"?>
		<cross-domain-policy>
		<allow-access-from domain=\"*\" to-ports=\"*\"/>  
		</cross-domain-policy>\0");
		{error, closed} ->ok
	  end,
	  gen_tcp:close(Socket).					%%�ر�����




%%�����������ӵ���Ӧ
handle_client(State,Socket) ->
	  case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			State#state.loop ! {chat, Data},
			handle_client(State,Socket);
		{error, closed} ->
			State#state.loop ! {disconnect, Socket}		%%�����˳�ʱ�����
	  end.


