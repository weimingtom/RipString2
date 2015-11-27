/*
 * Created by SharpDevelop.
 * User: Administrator
 * Date: 2011/11/12
 * Time: 15:03
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;

namespace Mapleleaf
{
	/// <summary>
	/// Description of Crypto.
	/// See http://code.google.com/p/chronicle-emulator/
	/// </summary>
	public class Crypto
	{
		public Crypto()
		{
		}
		
        public bool ConfirmHeader(byte[] pBuffer, int pStart)
        {
        	return pBuffer[pStart] == 'C' && pBuffer[pStart + 1] == 'T';
        }

        public ushort GetHeaderLength(byte[] pBuffer, int pStart)
        {
            int length = (int)(pBuffer[pStart + 2] << 24) |
                         (int)(pBuffer[pStart + 3] << 16) |
                         (int)(pBuffer[pStart + 4] << 8) |
                         (int)(pBuffer[pStart + 5]);
            return (ushort)length;
        }
        
        public void Decrypt(byte[] pBuffer, int pStart, int pLength)
        {

        }
	}
}
