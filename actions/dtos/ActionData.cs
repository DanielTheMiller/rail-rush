using System;
using System.Text.Json.Serialization;

namespace RailRush.actions.dtos
{
   	[JsonPolymorphic(TypeDiscriminatorPropertyName = "$type")]
	[JsonDerivedType(typeof(CoinSpawnActionData), typeDiscriminator: "coinSpawn")]
	[JsonDerivedType(typeof(TrainSpawnActionData), typeDiscriminator: "trainSpawn")]
	[JsonDerivedType(typeof(WaitActionData), typeDiscriminator: "wait")]
	public abstract class ActionData
	{
		// Convert this DTO into it's corresponding action type
		public abstract Action ToAction();
	}
}
