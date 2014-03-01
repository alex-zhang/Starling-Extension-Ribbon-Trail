package starling.extensions
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import starling.utils.MatrixUtil;

	public class RibbonSegment
	{
		private static var sHelperMatrix:Matrix  = new Matrix();
		private static var sHelperPoint:Point = new Point();
		
		public var ribbonTrail:RibbonTrail;
		
		public var x0:Number = 0.0;
		public var y0:Number = 0.0;
		
		public var x1:Number = 0.0;
		public var y1:Number = 0.0;
		
		public var alpha:Number = 1.0;
		
		public function RibbonSegment()
		{
			super();
		}
		
		public function tweenTo(preTrailSegment:RibbonSegment):void
		{
			var movingRatio:Number = ribbonTrail.movingRatio;
			
			//near the target.
			x0 = x0 + (preTrailSegment.x0 - x0) * movingRatio;
			y0 = y0 + (preTrailSegment.y0 - y0) * movingRatio;

			x1 = x1 + (preTrailSegment.x1 - x1) * movingRatio;
			y1 = y1 + (preTrailSegment.y1 - y1) * movingRatio;
			
			//percent of pre alpha.
			alpha = preTrailSegment.alpha * ribbonTrail.alphaRatio;
			
			//!remove color it's not necessary.
			//just percent of pre color.
//			color = preTrailSegment.color * ribbonTrail.colorRatio;
			//useless of color change below.
			//expansive for color caculate.
//			var colorRatio:Number = ribbonTrail.colorRatio;
//			if(colorRatio != 1)
//			{
				//percent of pre color.
//				var r:uint = Color.getRed(preTrailSegment.color);
//				var g:uint = Color.getGreen(preTrailSegment.color);
//				var b:uint = Color.getBlue(preTrailSegment.color);
//				r = r * colorRatio;
//				g = g * colorRatio;
//				b = b * colorRatio;
//				color = Color.rgb(r, g, b);
//			}
		}
		
		public function setTo(x0:Number, y0:Number, x1:Number, y1:Number,
							  alpha:Number = 1.0):void
		{
			this.x0 = x0;
			this.y0 = y0;
			
			this.x1 = x1;
			this.y1 = y1;
			
			this.alpha = alpha;
//			this.color = color;
		}
		
		public function setTo2(centerX:Number, centerY:Number, 
							   radius:Number, rotation:Number, 
							   alpha:Number = 1.0):void
		{
			// optimization: no ratation
			if(rotation == 0)
			{
				this.x0 = centerX;
				this.y0 = centerY - radius;
				
				this.x1 = centerX;
				this.y1 = centerY + radius;
			}
			else
			{
				sHelperMatrix.identity();
				sHelperMatrix.rotate(rotation);

				//pos0
				MatrixUtil.transformCoords(sHelperMatrix, 0, -radius, sHelperPoint);
				this.x0 = centerX + sHelperPoint.x;
				this.y0 = centerY + sHelperPoint.y;
				
				//pos1
				MatrixUtil.transformCoords(sHelperMatrix, 0, radius, sHelperPoint);
				this.x1 = centerX + sHelperPoint.x;
				this.y1 = centerY + sHelperPoint.y;
			}
			
			this.alpha = alpha;
		}
		
		public function copyFrom(trailSegment:RibbonSegment):void
		{
			x0 = trailSegment.x0;
			y0 = trailSegment.y0;
			
			x1 = trailSegment.x1;
			y1 = trailSegment.y1;
			
			alpha = trailSegment.alpha;
//			color = trailSegment.color;
		}
		
		public function toString():String
		{
			var results:String = "[TrailSegment \n" +
				"x0= " + x0 + ", " +
				"y0= " + y0 + ", " +
				"x1= " + x1 + ", " +
				"y1= " + y1 + ", " +
				"alpha= " + alpha +
//				"color= " + color.toString(16) + 
				"]";
			
			return results;
		}
	}
}