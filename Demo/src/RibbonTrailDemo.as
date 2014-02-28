package
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	
	[SWF(width="750", height="550", frameRate="60", backgroundColor="#FFFFFF")]
	public class RibbonTrailDemo extends Sprite
	{
		private var mStarling:Starling;
		
		public function RibbonTrailDemo()
		{
			mStarling = new Starling(RibbonTrailDemoRoot, stage, new Rectangle(0, 0, 750, 550));
			mStarling.start();
			mStarling.showStats = true;
		}
	}
}