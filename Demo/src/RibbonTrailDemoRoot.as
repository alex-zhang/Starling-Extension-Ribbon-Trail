package
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.RibbonTrail;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.utils.deg2rad;

	public class RibbonTrailDemoRoot extends Sprite implements IAnimatable
	{
		private var ribbonTrail:RibbonTrail;
		private var textures:Array = [];
		private var curentTexureIndex:int = 0;
		
		public function RibbonTrailDemoRoot()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, firstAddToStageHandler);
		}
		
		private function firstAddToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, firstAddToStageHandler);
			
			//init helper
			var helpText:TextField = new TextField(400, 300,
				"press key 'T' to switch texture \n" +
				"press key 'R' to switch repeat model \n" +
				"press key 'P' to switch resume and pause state \n" +
				"press key 'F' to switch floowingEnable state \n" +
				"press key 'M' to  increase moving ratio or 'ctrl' + 'M' decrease.\n" +
				"press key 'A' to  increase alpha ratio or 'ctrl' + 'A' decrease.\n" +
				""
			);
			
			helpText.hAlign = HAlign.LEFT;
			helpText.vAlign = VAlign.TOP;
			helpText.y = 50;
			addChild(helpText);
			
			//init textures.
			var texture:Texture
			[Embed(source="ribbonTrailTexture.png")]
			var ribbonTrailTextureCls:Class;
			texture = Texture.fromBitmap(new ribbonTrailTextureCls(), false);
			textures.push(texture);
			
			[Embed(source="laser.png")]
			var laserCls:Class;
			texture = Texture.fromBitmap(new laserCls(), false);
			textures.push(texture);
			
			[Embed(source="ribbonTrailTexture2.png")]
			var ribbonTrailTexture2Cls:Class;
			texture = Texture.fromBitmap(new ribbonTrailTexture2Cls(), false);
			textures.push(texture);
				
			//---
			
			[Embed(source="atlas.png")]
			var atlas0Cls:Class;
			texture = Texture.fromBitmap(new atlas0Cls(), false);
			
			[Embed(source="atlas.xml", mimeType="application/octet-stream")]
			var atlas0XMLCls:Class;	
			
			var textureAtlas0:TextureAtlas = new TextureAtlas(texture, new XML(new atlas0XMLCls));
			textures.push(textureAtlas0.getTexture("starling_rocket"));
			textures.push(textureAtlas0.getTexture("logo"));
			textures.push(textureAtlas0.getTexture("starling_front"));
			textures.push(textureAtlas0.getTexture("benchmark_object"));
			textures.push(textureAtlas0.getTexture("flight_00"));

			//init ribbonTrail
			ribbonTrail = new RibbonTrail(textures[0], 50);
			ribbonTrail.isPlaying = true;
			ribbonTrail.movingRatio = 0.4;
			ribbonTrail.alphaRatio = 0.95;
			addChild(ribbonTrail);
			
			Starling.current.juggler.add(this);
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler);
		}
		
		private var rotation:Number = 0.0; 
//		private var color:uint = 0xFFFFFF;
		
		public function advanceTime(passedTime:Number):void
		{
			var flashStage:Stage = Starling.current.nativeStage;
			
			var x:Number = flashStage.mouseX;
			var y:Number = flashStage.mouseY;
			
			var thcikness:Number = 100;
			
			rotation += deg2rad(90 * passedTime);
			
			var x0:Number = x + thcikness * Math.cos(rotation);
			var y0:Number = y - thcikness * Math.sin(rotation);

			var x1:Number = x - thcikness * Math.cos(rotation);
			var y1:Number = y + thcikness * Math.sin(rotation);
			
//			color -= 255;
			
			//the flow target color is real time change.
			ribbonTrail.followTo(x0, y0, x1, y1, alpha);
			
			ribbonTrail.advanceTime(passedTime);
		}
		
		private function stageKeyUpHandler(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.T:
					switchTexture();
					break;
				
				case Keyboard.R:
					ribbonTrail.repeat = !ribbonTrail.repeat;
					break;
				
				case Keyboard.P:
					ribbonTrail.isPlaying = !ribbonTrail.isPlaying;
					break;
				
				case Keyboard.F:
					ribbonTrail.followingEnable = !ribbonTrail.followingEnable;
					break;
				
				case Keyboard.M:
					if(event.ctrlKey)
					{
						ribbonTrail.movingRatio -= 0.1;
					}
					else
					{
						ribbonTrail.movingRatio += 0.1;
					}
					break;
				
				case Keyboard.A:
					if(event.ctrlKey)
					{
						ribbonTrail.alphaRatio -= 0.01;
					}
					else
					{
						ribbonTrail.alphaRatio += 0.01;
					}
					break;
			}
		}
		
		private function switchTexture():void
		{
			curentTexureIndex++;
			if(curentTexureIndex == textures.length)
			{
				curentTexureIndex = 0;
			}

			ribbonTrail.texture = textures[curentTexureIndex];
		}
	}
}