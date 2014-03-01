package starling.extensions
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Point;
	
	import starling.animation.IAnimatable;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.errors.MissingContextError;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.utils.VertexData;

	/**
	 * The ribbon's trangle is continuous, don't like quad in starling.
	 * 
	 * 0 - 2 - 4 - 8 - 9
	 * | / | / | / | / |
	 * 1 - 3 - 5 - 7 - 10
	 *  
	 * @author alex-zhang.
	 * 
	 */

	public class RibbonTrail extends DisplayObject implements IAnimatable
	{
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		private static var sMapTexCoords:Vector.<Number> = new <Number>[0.0, 0.0, 0.0, 0.0];
		
		protected var mProgram:Program3D;
		
		protected var mVertexData:VertexData;
		protected var mVertexBuffer:VertexBuffer3D;
		protected var mIndexData:Vector.<uint>;
		protected var mIndexBuffer:IndexBuffer3D;
		protected var mTexture:Texture;
		
		protected var mTrailSegments:Vector.<TrailSegment>;
		protected var mNumTrailSegments:int;

		protected var mFollowingEnable:Boolean = true;

		protected var mMovingRatio:Number = 0.5;
		protected var mAlphaRatio:Number = 0.95;
		
		//the fixed vertex props.
		protected var mRepeat:Boolean = false;
		
		protected var mIsPlaying:Boolean = false;
		
		//color alpha uv, only the position is dynamic.
		protected var mVertexFixedDataDirty:Boolean = false;
		
		public function RibbonTrail(texture:Texture, 
									trailSegments:int = 10)
		{
			super();
			
			if(!texture)
			{
				throw new ArgumentError("Texture cannot be null");
			}
			
			if(trailSegments < 2)
			{
				throw new ArgumentError("trailSegments count must big than 2");
			}

			mTexture = texture;

			mVertexData = new VertexData(0, true);
			mIndexData = new <uint>[];
			mTrailSegments = new <TrailSegment>[];

			raiseCapacity(trailSegments);
			createProgram();
			
			// handle a lost device context
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextCreatedHandler, false, 0, true);
		}
		
		//event handler
		protected function contextCreatedHandler(event:Object):void
		{
			createProgram();
			raiseCapacity(mNumTrailSegments);
		}
		
		public function get followingEnable():Boolean { return mFollowingEnable; }
		public function set followingEnable(value:Boolean):void { mFollowingEnable = value; }

		public function get isPlaying():Boolean { return mIsPlaying; }
		public function set isPlaying(value:Boolean):void { mIsPlaying = value; }
		
		public function get movingRatio():Number { return mMovingRatio; }
		public function set movingRatio(value:Number):void 
		{ 
			if(mMovingRatio != value)
			{
				mMovingRatio = value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value); 
			}
		}
		
		public function get alphaRatio():Number { return mAlphaRatio; }
		public function set alphaRatio(value:Number):void 
		{
			if(mAlphaRatio != value)
			{
				mAlphaRatio = value < 0.0 ? 0.0 : (value > 1.0 ? 1.0 : value); 
			}
		}
		
		public function get texture():Texture { return mTexture; }
		public function set texture(value:Texture):void 
		{
			if(!value)
			{
				throw new ArgumentError("Texture cannot be null");
			}
			
			if(mTexture != value)
			{
				mTexture = value;
				
				mVertexFixedDataDirty = true;
			}
		}
		
		public function get repeat():Boolean { return mRepeat; }
		public function set repeat(value:Boolean):void 
		{ 
			if(mRepeat != value)
			{
				mRepeat = value;

				mVertexFixedDataDirty = true;
			}
		}
		
		public function getTrailSegment(index:int):TrailSegment
		{
			return mTrailSegments[index]; 
		}
		
		public function followTo(x0:Number, y0:Number, x1:Number, y1:Number,
								alpha:Number = 1.0):void
		{
			if(mFollowingEnable)
			{
				mTrailSegments[0].setTo(x0, y0, x1, y1, alpha);
			}
		}
		
		//because of segments have the invalid pos so syc here.
		public function resetAllTo(x0:Number, y0:Number, x1:Number, y1:Number,
								   alpha:Number = 1.0):void
		{
			var trailSegment:TrailSegment;
			var trailSegmentIndex:int = 0;

			while(trailSegmentIndex < mNumTrailSegments)
			{
				trailSegment = mTrailSegments[trailSegmentIndex];
				trailSegment.setTo(x0, y0, x1, y1, alpha);

				trailSegmentIndex++;
			}
		}
		
		protected function updatevertexData():void
		{
			var shareRatio:Number = 1 / mNumTrailSegments;
			var ratio:Number = 0;

			var vertexId:int = 0;
			var trailSegmentIndex:int = 0;
			
			while(trailSegmentIndex < mNumTrailSegments)
			{
				vertexId = trailSegmentIndex * 2;
				
				ratio = trailSegmentIndex * shareRatio;
				
				//uv.
				if(mRepeat)
				{
					sMapTexCoords[0] = trailSegmentIndex;
					sMapTexCoords[1] = 0;
					sMapTexCoords[2] = trailSegmentIndex;
					sMapTexCoords[3] = 1;
				}
				else
				{
					sMapTexCoords[0] = ratio;
					sMapTexCoords[1] = 0;
					sMapTexCoords[2] = ratio;
					sMapTexCoords[3] = 1;
				}
				
				mTexture.adjustTexCoords(sMapTexCoords, 0, 0, 2);
				
				mVertexData.setTexCoords(vertexId, sMapTexCoords[0] , sMapTexCoords[1]);
				mVertexData.setTexCoords(int(vertexId + 1), sMapTexCoords[2] , sMapTexCoords[3]);
				
				trailSegmentIndex++;
			}
		}
		
		protected function createTrailSegment():TrailSegment
		{
			return new TrailSegment();
		}

		//we don't need hitTest return.
		override public function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
		{
			return null;
		}
		
		public function advanceTime(passedTime:Number):void
		{
			if(!mIsPlaying) return;
			
			var vertexId:int = 0;
			var trailSegment:TrailSegment;
			var preTrailSegment:TrailSegment;
			
			var trailSegmentIndex:int = 0;
			while(trailSegmentIndex < mNumTrailSegments)
			{
				vertexId = trailSegmentIndex * 2;
				
				trailSegment = mTrailSegments[trailSegmentIndex];
				
				if(trailSegmentIndex > 0)
				{
					preTrailSegment = mTrailSegments[trailSegmentIndex - 1];
					trailSegment.tweenTo(preTrailSegment, passedTime);
				}
				
				//syc the vertex data from trailSegment.
				mVertexData.setPosition(vertexId, 		   trailSegment.x0, trailSegment.y0);
				mVertexData.setAlpha(vertexId, trailSegment.alpha);

				mVertexData.setPosition(int(vertexId + 1), trailSegment.x1, trailSegment.y1);
				mVertexData.setAlpha(int(vertexId + 1), trailSegment.alpha);

				//increase the index.
				++trailSegmentIndex;
			}
		}
		
		protected function createProgram():void
		{
			var programName:String = "ext.RibbonTrail."
			mProgram = Starling.current.getProgram(programName);
			if(mProgram == null)
			{
				var vertexProgramCode:String = 
					"m44 op, va0, vc0 \n" + // 4x4 matrix transform to output clipspace
					"mul v0, va1, vc4 \n" + // multiply color with alpha and pass to fragment program
					"mov v1, va2 \n";      // pass texture coordinates to fragment program
				
				var fragmentProgramCode:String =
					"tex ft0, v1, fs0 <2d,linear,repeat> \n" + // sample texture 0
					"mul oc, ft0, v0";                        // multiply color with texel color
				
				var assembler:AGALMiniAssembler = new AGALMiniAssembler();
				
				mProgram = Starling.current.registerProgram(programName, 
					assembler.assemble(Context3DProgramType.VERTEX, vertexProgramCode),
					assembler.assemble(Context3DProgramType.FRAGMENT, fragmentProgramCode));
			}
		}
		
		public function raiseCapacity(byAmount:int):void
		{
			var oldNumTrailSegments:int = mNumTrailSegments;
			mNumTrailSegments = Math.min(8129, oldNumTrailSegments + byAmount);
			var context:Context3D = Starling.context;
			
			if (context == null) throw new MissingContextError();

			var baseVertexData:VertexData = new VertexData(2);
			baseVertexData.setUniformColor(0xFFFFFF);

			mTrailSegments.fixed = false;
			mIndexData.fixed = false;
			
			var trailSegment:TrailSegment;
			
			for(var trailSegmentIndex:int = oldNumTrailSegments; trailSegmentIndex < mNumTrailSegments; trailSegmentIndex++)  
			{
				trailSegment = createTrailSegment();
				trailSegment.ribbonTrail = this;
				mTrailSegments[trailSegmentIndex] = trailSegment;
				
				mVertexData.append(baseVertexData);
				
				//mIndexData
				if(trailSegmentIndex > 0)//add pre trangle.
				{
					var quadIndex:int = trailSegmentIndex - 1;
					var quadVertexId:int = trailSegmentIndex * 2 - 2;
					var trangleIndex:int = quadIndex * 6;

					//0-2-1
					mIndexData[    trangleIndex   ] = quadVertexId;
					mIndexData[int(trangleIndex + 1)] = quadVertexId + 2;
					mIndexData[int(trangleIndex + 2)] = quadVertexId + 1;

					//2-3-1
					mIndexData[int(trangleIndex + 3)] = quadVertexId + 2;
					mIndexData[int(trangleIndex + 4)] = quadVertexId + 3;
					mIndexData[int(trangleIndex + 5)] = quadVertexId + 1;
				}
			}
			
			mTrailSegments.fixed = true;
			mIndexData.fixed = true;
			
			// upload data to vertex and index buffers
			if(mNumTrailSegments > 1)
			{
				if (mVertexBuffer) mVertexBuffer.dispose();
				if (mIndexBuffer)  mIndexBuffer.dispose();
				
				mVertexBuffer = context.createVertexBuffer(mNumTrailSegments * 2, VertexData.ELEMENTS_PER_VERTEX);
				mIndexBuffer  = context.createIndexBuffer(mIndexData.length);

				mIndexBuffer.uploadFromVector(mIndexData, 0, mIndexData.length);
			}
			
			//will update later.
			mVertexFixedDataDirty = true;
		}
		
		public override function render(support:RenderSupport, alpha:Number):void
		{
			support.finishQuadBatch();
			support.raiseDrawCount();
			
			var context:Context3D = Starling.current.context;
			
			var pma:Boolean = mTexture.premultipliedAlpha;
			
			alpha *= this.alpha;
			
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = pma ? alpha : 1.0;
			sRenderAlpha[3] = alpha;
			
			//syc the vertex datas.
			if(mVertexFixedDataDirty)
			{
				updatevertexData();
				mVertexFixedDataDirty = false;
			}
			
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, mNumTrailSegments * 2);

			//set the state.
			context.setProgram(mProgram);
			RenderSupport.setBlendFactors(pma, support.blendMode ? support.blendMode : this.blendMode);
			context.setTextureAt(0, mTexture.base);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix3D, true);
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, sRenderAlpha, 1);

			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_2); 
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET,    Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);

			context.drawTriangles(mIndexBuffer);

			//reset the state.
			context.setProgram(null);
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, contextCreatedHandler);
			
			mVertexData = null;
			
			if(mVertexBuffer)
			{
				mVertexBuffer.dispose();
				mVertexBuffer = null;
			}

			mIndexData = null;
			if(mIndexBuffer)
			{
				mIndexBuffer.dispose();
				mIndexBuffer = null;
			}
			
			mVertexFixedDataDirty = false;
			
			mTexture = null;
			mTrailSegments = null;
			mIsPlaying = false;
		}
	}
}