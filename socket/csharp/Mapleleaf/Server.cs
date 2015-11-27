/*
 * Created by SharpDevelop.
 * User: Administrator
 * Date: 2011/11/12
 * Time: 15:20
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace Mapleleaf
{
	/// <summary>
	/// Description of Server.
	/// See http://code.google.com/p/chronicle-emulator/
	/// </summary>
	public sealed class Server
	{
		private static Server instance = new Server();
		
        private const int CHANNEL_PORT = 8899;
        private const int CHANNEL_BACKLOG = 16;
        private Socket sChannelListener;
		
		public static Server Instance 
		{
			get 
			{
				return instance;
			}
		}
		
		private Server()
		{
			
		}

        public void start()
        {
            Log.Instance.WriteLine(LogLevel.Info,
                "[Server] Initialized Data");
            sChannelListener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            sChannelListener.Bind(new IPEndPoint(IPAddress.Any, Server.CHANNEL_PORT));
            sChannelListener.Listen(Server.CHANNEL_BACKLOG);
            Log.Instance.WriteLine(LogLevel.Info,
                "[Server] Initialized Channel Listener on port {0}", Server.CHANNEL_PORT);
            BeginChannelListenerAccept(null);
            while (true)
            {
                Thread.Sleep(1);
            }
        }

        private void BeginChannelListenerAccept(SocketAsyncEventArgs pArgs)
        {
            if (pArgs == null)
            {
                pArgs = new SocketAsyncEventArgs();
                pArgs.Completed += (s, a) => EndChannelListenerAccept(a);
            }
            pArgs.AcceptSocket = null;
            if (!sChannelListener.AcceptAsync(pArgs))
            {
                EndChannelListenerAccept(pArgs);
            }
        }

        private void EndChannelListenerAccept(SocketAsyncEventArgs pArguments)
        {
            try
            {
                if (pArguments.SocketError == SocketError.Success)
                {
                    Log.Instance.WriteLine(LogLevel.Info, 
                        "[Server] EndChannelListenerAccept");
                    Session session = new Session(pArguments.AcceptSocket);
                    BeginChannelListenerAccept(pArguments);
                }
                else if (pArguments.SocketError != SocketError.OperationAborted)
                {
                    Log.Instance.WriteLine(LogLevel.Error, 
                        "[Server] ChannelListener Error: {0}", pArguments.SocketError);
                }
            }
            catch (ObjectDisposedException) 
            {

            }
            catch (Exception exc) 
            { 
                Log.Instance.WriteLine(LogLevel.Exception, 
                    "[Server] ChannelListener Exception: {0}", exc.Message); 
            }
        }
	}
}
