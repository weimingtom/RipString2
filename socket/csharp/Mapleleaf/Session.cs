/*
 * Created by SharpDevelop.
 * User: Administrator
 * Date: 2011/11/12
 * Time: 15:00
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
	/// Description of Session.
	/// See http://code.google.com/p/chronicle-emulator/
	/// </summary>
	public class Session
	{
        private const int MAX_RECEIVE_BUFFER = 16384;

        private Socket mSocket = null;
        private string mHost = null;
        private int mDisconnected = 0;

        private byte[] mReceiveBuffer = null;
        private int mReceiveStart = 0;
        private int mReceiveLength = 0;
        private ushort mReceivingPacketLength = 0;
        private DateTime mReceiveLast = DateTime.Now;
		
        private Crypto mReceiveCrypto = new Crypto();
        
		public Session(Socket pSocket)
		{
            mSocket = pSocket;
            mReceiveBuffer = new byte[MAX_RECEIVE_BUFFER];
            mHost = ((IPEndPoint)mSocket.RemoteEndPoint).Address.ToString();
            Log.Instance.WriteLine(LogLevel.Debug, "[{0}] Connected", mHost);
            BeginReceive();
		}
		
        public void Disconnect()
        {
            if (Interlocked.CompareExchange(ref mDisconnected, 1, 0) == 0)
            {
                mSocket.Shutdown(SocketShutdown.Both);
                mSocket.Close();
                Log.Instance.WriteLine(LogLevel.Debug, 
                    "[{0}] Disconnected", mHost);
            }
        }
        
        private void BeginReceive()
        {
            if (mDisconnected != 0) return;
            SocketAsyncEventArgs args = new SocketAsyncEventArgs();
            args.Completed += (s, a) => EndReceive(a);
            args.SetBuffer(mReceiveBuffer, mReceiveStart, mReceiveBuffer.Length - (mReceiveStart + mReceiveLength));
            try 
            {
                if (!mSocket.ReceiveAsync(args))
                {
                    EndReceive(args);
                }
            }
            catch (ObjectDisposedException) 
            {
 
            }
        }

        private void EndReceive(SocketAsyncEventArgs pArguments)
        {
            if (mDisconnected != 0)
            {
                return;
            }
            if (pArguments.BytesTransferred <= 0)
            {
                if (pArguments.SocketError != SocketError.Success &&
                    pArguments.SocketError != SocketError.ConnectionReset)
                {
                    Log.Instance.WriteLine(LogLevel.Error,
                        "[{0}] Receive Error: {1}", mHost, pArguments.SocketError);
                }
                Disconnect();
                return;
            }
            mReceiveLength += pArguments.BytesTransferred;
            Log.Instance.WriteLine(LogLevel.Debug,
                "Receive!", mHost);
            while (mReceiveLength > 6)
            {
                if (mReceivingPacketLength == 0)
                {
                    if (!mReceiveCrypto.ConfirmHeader(mReceiveBuffer, mReceiveStart))
                    {
                        Log.Instance.WriteLine(LogLevel.Error,
                    	                       "[{0}] Invalid Packet Header : 0x{1}, 0x{2}", 
                    	                       mHost,
                    	                       mReceiveBuffer[mReceiveStart].ToString("X2"),
                    	                       mReceiveBuffer[mReceiveStart + 1].ToString("X2"));
                        Disconnect();
                        return;
                    }
                    mReceivingPacketLength = mReceiveCrypto.GetHeaderLength(mReceiveBuffer, mReceiveStart);
                    Log.Instance.WriteLine(LogLevel.Debug, 
                        "Header Length is {0} Bytes", mReceivingPacketLength);
                }
                if (mReceivingPacketLength > 0 && mReceiveLength >= mReceivingPacketLength + 6)
                {
                    mReceiveCrypto.Decrypt(mReceiveBuffer, mReceiveStart + 6, mReceivingPacketLength);
                    Packet packet = new Packet(mReceiveBuffer, mReceiveStart + 6, mReceivingPacketLength);
                    //TODO:
                    Log.Instance.WriteLine(LogLevel.Debug, 
                        "[{0}] Receiving 0x{1}, {2} Bytes", mHost, ((ushort)packet.Opcode).ToString("X4"), packet.Length);
                    packet.Dump();
                    mReceiveStart += mReceivingPacketLength + 6;
                    mReceiveLength -= mReceivingPacketLength + 6;
                    mReceivingPacketLength = 0;
                    mReceiveLast = DateTime.Now;
                }
            }
            if (mReceiveLength == 0)
            {
                mReceiveStart = 0;
            }
            else if (mReceiveStart > 0 && (mReceiveStart + mReceiveLength) >= mReceiveBuffer.Length)
            {
                Buffer.BlockCopy(mReceiveBuffer, mReceiveStart, mReceiveBuffer, 0, mReceiveLength);
                mReceiveStart = 0;
            }
            if (mReceiveLength == mReceiveBuffer.Length)
            {
                Log.Instance.WriteLine(LogLevel.Error,
                    "[{0}] Receive Overflow", mHost);
                Disconnect();
            }
            else
            {
                BeginReceive();
            }
        }
	}
}
