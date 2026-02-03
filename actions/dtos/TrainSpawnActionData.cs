namespace RailRush.actions.dtos
{
	public class TrainSpawnActionData : ActionData
	{
		public override Action ToAction()
		{
			return new TrainSpawnAction(this);
		}
		
		public override string ToString()
		{
			return "TEST DATA!";//#nameof(TrainSpawnActionData);
		}
	}
}
