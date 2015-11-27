/*
http://d.hatena.ne.jp/h_sakurai/20100228
*/

import scala.actors.Actor;
import scala.actors.Actor._;
//import scala.collection.jcl.Conversions._;
import scala.collection.JavaConversions._
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.{ SelectionKey, Selector, ServerSocketChannel, SocketChannel }
import java.nio.charset.Charset;

object EchoActor extends Actor {
	sealed abstract class Message;
	case class Init(port:Int)           extends Message;
	case class Select()                 extends Message;
	case class Accept(key:SelectionKey) extends Message;
	case class Read(key:SelectionKey)   extends Message;

	def main(args:Array[String]) {
		//EchoActor.start();
		//EchoActor ! Init(8080);
		start();
		this ! Init(8080);
	}

	def act() {
		loop {
			react {
			case Init(port)  => init(port); this ! Select; //EchoActor ! Select;
			case Select      => select();   this ! Select; //EchoActor ! Select;
			case Accept(key) => accept(key);
			case Read(key)   => read(key);
			}
		}
	}

	val BUF_SIZE = 1024;
	val selector:Selector = Selector.open();
	val serverChannel:ServerSocketChannel = ServerSocketChannel.open();

	def init(port:Int) {
		serverChannel.configureBlocking(false);
		serverChannel.socket().bind(new InetSocketAddress(port));
		serverChannel.register(selector, SelectionKey.OP_ACCEPT);
		println("EchoServe start, port=" + port);
	}

	def select() {
		selector.select();
		selector.selectedKeys().foreach { key =>
			if (key.isAcceptable()) {
				//EchoActor ! Accept(key);
				this ! Accept(key);
			} else
			if (key.isReadable()) {
				//EchoActor ! Read(key);
				this ! Read(key);
			}
		}
	}

	def accept(key:SelectionKey) {
		val socket:ServerSocketChannel = key.channel().asInstanceOf[ServerSocketChannel];
		socket.accept() match {
		case null =>
		case channel:SocketChannel =>
			val remoteAddress:String = channel.socket().getRemoteSocketAddress().toString();
			println(remoteAddress + ":[connected]");
			channel.configureBlocking(false);
			channel.register(selector, SelectionKey.OP_READ);
		}
	}

	def read(key:SelectionKey) {
		val channel:SocketChannel = key.channel().asInstanceOf[SocketChannel];
		val remoteAddress = channel.socket().getRemoteSocketAddress().toString();
		val buf:ByteBuffer = ByteBuffer.allocate(BUF_SIZE);

		def close(remoteAddress:String, channel:SocketChannel) {
			channel.close();
			println(remoteAddress + ":[disconnected]");
		}

		channel.read(buf) match {
		case -1 => close(remoteAddress, channel);
		case 0 =>
		case x =>
			buf.flip();
			println(remoteAddress + ":" + Charset.forName("UTF-8").decode(buf).toString());
			buf.flip();
			channel.write(buf);
			close(remoteAddress, channel);
		}
	}
}


