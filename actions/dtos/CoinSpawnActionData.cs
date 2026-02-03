namespace RailRush.actions.dtos
{
    public class CoinSpawnActionData : ActionData
    {
        public int CoinValue { get; set; }

        public override Action ToAction()
        {
            return new CoinSpawnAction(this);
        }
    }
}
