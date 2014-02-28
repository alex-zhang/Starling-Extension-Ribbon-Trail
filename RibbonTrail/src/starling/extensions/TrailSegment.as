package starling.extensions
{
	import starling.utils.Color;

	public class TrailSegment
	{
		public var ribbonTrail:RibbonTrail;
		
		public var x0:Number = 0.0;
		public var y0:Number = 0.0;
		
		public var x1:Number = 0.0;
		public var y1:Number = 0.0;
		
		public var color:uint = 0xFFFFFF;
		public var alpha:Number = 1.0;
		
		public function TrailSegment()
		{
			super();
		}
		
		public function tweenTo(preTrailSegment:TrailSegment, passedTime:Number):void
		{
			var movingRatio:Number = ribbonTrail.movingRatio;
			
			//near the target.
			x0 = x0 + (preTrailSegment.x0 - x0) * movingRatio;
			y0 = y0 + (preTrailSegment.y0 - y0) * movingRatio;

			x1 = x1 + (preTrailSegment.x1 - x1) * movingRatio;
			y1 = y1 + (preTrailSegment.y1 - y1) * movingRatio;
			
			//percent of pre alpha.
			alpha = preTrailSegment.alpha * ribbonTrail.alphaRatio;
			
			//just percent of pre color.
			color = preTrailSegment.color * ribbonTrail.colorRatio;
			
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
							  alpha:Number = 1.0,
							  color:uint = 0xFFFFFF):void
		{
			this.x0 = x0;
			this.y0 = y0;
			
			this.x1 = x1;
			this.y1 = y1;
			
			this.alpha = alpha;
			this.color = color;
		}
		
		public function copyFrom(trailSegment:TrailSegment):void
		{
			x0 = trailSegment.x0;
			y0 = trailSegment.y0;
			
			x1 = trailSegment.x1;
			y1 = trailSegment.y0;
			
			alpha = trailSegment.alpha;
			
			color = trailSegment.color;
		}
		
		public function toString():String
		{
			var results:String = "[TrailSegment \n" +
				"x0= " + x0 + ", " +
				"y0= " + y0 + ", " +
				"x1= " + x1 + ", " +
				"y1= " + y1 + ", " +
				"alpha= " + alpha + "," +
				"color= " + color.toString(16) + "]";
			
			return results;
		}
		
		
//		protected function updatevertexData():void
//		{
//			var shareRatio:Number = 1 / mNumTrailSegments;
//			var ratio:Number = 0;
//			
//			//alpha
//			var deltaAlpha:Number = mEndAlpha - mStarAlpha;
//			var resultAlpha:Number = 0;
//			
//			//color
//			var deltaColor:int = mEndColor - mStarColor;
//			var resultColor:uint = 0;
//			
//			var vertexId:int = 0;
//			var trailSegmentIndex:int = 0;
//			
//			while(trailSegmentIndex < mNumTrailSegments)
//			{
//				vertexId = trailSegmentIndex * 2;
//				
//				ratio = trailSegmentIndex * shareRatio;
//				
//				//lerp alpha.
//				resultAlpha = mStarAlpha + deltaAlpha * ratio;
//				//lerp color.
//				resultColor = mStarColor + deltaColor * ratio;
//				
//				mVertexData.setColorAndAlpha(vertexId, resultColor, resultAlpha);
//				mVertexData.setColorAndAlpha(int(vertexId + 1), resultColor, resultAlpha);
//				
//				//uv.
//				if(mRepeat)
//				{
//					sMapTexCoords[0] = trailSegmentIndex;
//					sMapTexCoords[1] = 0;
//					sMapTexCoords[2] = trailSegmentIndex;
//					sMapTexCoords[3] = 1;
//				}
//				else
//				{
//					sMapTexCoords[0] = ratio;
//					sMapTexCoords[1] = 0;
//					sMapTexCoords[2] = ratio;
//					sMapTexCoords[3] = 1;
//				}
//				
//				mTexture.adjustTexCoords(sMapTexCoords, 0, 0, 2);
//				
//				mVertexData.setTexCoords(vertexId, sMapTexCoords[0] , sMapTexCoords[1]);
//				mVertexData.setTexCoords(int(vertexId + 1), sMapTexCoords[2] , sMapTexCoords[3]);
//				
//				trailSegmentIndex++;
//			}
//		}
	}
}