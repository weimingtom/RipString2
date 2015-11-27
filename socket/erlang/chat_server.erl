-module(chat_server).
-behaviour(gen_server).
-export([start/2,stop/1]).

%% gen_server回调
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
        terminate/2,code_change/3]).
-compile(export_all).

-define(TCP_OPTIONS, [list, {packet, 0}, {active, false}, {reuseaddr, true},{nodelay, false},{delay_send, true}]).  
%%状态表
-record(state, {name,loop,socket}).

%%回调gen_server创建服务
start(Name,Loop) -> 
	State=#state{name=Name,loop=Loop},				%%定为记录
	gen_server:start_link({local,Name},?MODULE,State,[]).			


%%start() -> 
%%	gen_server:start_link({local,?MODULE},?MODULE,[],[]).		


%%停止服务
stop(Name)  -> 
	gen_server:call(Name,stop).


init(State) -> 
	%%维护队列
	register(State#state.loop, spawn(fun() -> (State#state.name):(State#state.loop)([]) end)),
	{Tag, LSocket}=gen_tcp:listen(8080, ?TCP_OPTIONS),			%%默认8080
	case Tag of								%%创建监听
		ok	->	spawn(fun() -> do_accept(State#state{socket=LSocket}) end);	%%统一接收
		error	->	exit({stop, exit})				%%出错，退出连接
	end,
				
	%%与flash通信的安全策略文件传送监听接口
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
%% -------------私有函数--------------
%% -----------------------------------



%%新建连接,只有新连接时才调用
do_accept(State) ->
	case gen_tcp:accept(State#state.socket) of
		{ok, Socket}-> 
			%%创建进程处理响应
			spawn(fun() -> handle_client(State,Socket) end),
			%%创建新连接,持久化
			State#state.loop ! {connect, Socket},
			do_accept(State);
		_->
			ok
	end.	



%%处理flash安全策略文件的发送服务
do_accept2(LSocket) ->
	case gen_tcp:accept(LSocket) of
		{ok, Socket}-> 
			spawn(fun() -> put_file(Socket) end),
			do_accept2(LSocket);
		_->ok
	end.

%%短连接策略，连接完关闭
put_file(Socket)->
	  case gen_tcp:recv(Socket, 0) of
		{ok, _} ->
			%%判断数据返回策略文件
			gen_tcp:send(Socket, "<?xml version=\"1.0\"?>
		<cross-domain-policy>
		<allow-access-from domain=\"*\" to-ports=\"*\"/>  
		</cross-domain-policy>\0");
		{error, closed} ->ok
	  end,
	  gen_tcp:close(Socket).					%%关闭连接




%%持续、长连接的响应
handle_client(State,Socket) ->
	  case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			State#state.loop ! {chat, Data},
			handle_client(State,Socket);
		{error, closed} ->
			State#state.loop ! {disconnect, Socket}		%%这里退出时会出错
	  end.


