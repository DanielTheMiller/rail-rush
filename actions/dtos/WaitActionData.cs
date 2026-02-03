namespace RailRush.actions.dtos
{
	public class WaitActionData : ActionData
	{
		public override Action ToAction()
		{
			return new WaitAction(this);
		}
	}
}
