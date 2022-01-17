package;

import Sys.sleep;

#if discord_rpc
import discord_rpc.DiscordRpc;
#end

import flixel.FlxG;

using StringTools;

class DiscordRPC
{
	#if discord_rpc
	public static var started:Bool = false;

	public static var active:Bool = false;

	public function new()
	{
		startClient();
	}

	public static function startClient()
	{
		trace("Discord RPC starting...");
		DiscordRpc.start({
			clientID: "931112967049740338",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord RPC started.");

		active = true;

		while (active)
		{
			DiscordRpc.process();
			sleep(2);
		}

		if(active)
			DiscordRpc.shutdown();

		active = false;
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();

		active = false;
	}
	
	static function onReady()
	{
		DiscordRpc.presence({
			details: "In Title Screen",
			state: null,
			largeImageKey: 'logo',
			largeImageText: Util.engineName
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordRPC();
		});

		started = true;
		trace("Discord RPC initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'logo',
			largeImageText: Util.engineName,
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});
	}
	#end
}