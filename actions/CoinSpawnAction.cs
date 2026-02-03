using Godot;
using RailRush.actions.dtos;
using System;

public partial class CoinSpawnAction : Action
{
	public CoinSpawnAction(int coinValue)
	{
		Data = new CoinSpawnActionData() 
		{ 
			CoinValue = coinValue
		};
	}

	public CoinSpawnAction(CoinSpawnActionData coinData)
	{
		Data = coinData;
	}

	public override void Invoke()
	{
		Console.WriteLine("Coin spawn invoked");
	}
	
	public override string ToString()
	{
		return nameof(CoinSpawnAction);
	}
}
