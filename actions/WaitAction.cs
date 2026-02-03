using Godot;
using RailRush.actions.dtos;
using System;

public partial class WaitAction : Action
{
	public WaitAction()
	{
		Data = new WaitActionData();
	}

	public WaitAction(WaitActionData waitData)
	{
		Data = waitData;
	}

	public override void Invoke()
	{
		Console.WriteLine("Wait invoked");
	}
	
	public static void Howdy()
	{
		Console.WriteLine("HOWDY!!!");
	}
}
