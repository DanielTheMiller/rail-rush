using Godot;
using RailRush.actions.dtos;
using System;

public partial class TrainSpawnAction : Action
{
	public TrainSpawnAction()
	{
		Data = new TrainSpawnActionData();
	}

	public TrainSpawnAction(TrainSpawnActionData spawnData)
	{
		Data = spawnData;
	}

	public override void Invoke()
	{
		Console.WriteLine("Train Spawn Invoked");
	}
	
	public override string ToString()
	{
		return "TEST ACTION!";//#nameof(TrainSpawnActionData);
	}
}
