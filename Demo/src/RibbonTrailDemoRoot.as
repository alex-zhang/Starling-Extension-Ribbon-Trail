package
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.text.engine.BreakOpportunity;
	import flash.ui.Keyboard;
	import flash.utils.describeType;
	
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
				"press key 'F' to switch allowFloowing state \n" +
				"press key 'H' to increase thickness and 'ctrl' + 'H' to decrease \n" +
				"press key 'D' to increase decayRatio and 'ctrl' + 'D' to decrease \n");
			
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
			ribbonTrail = new RibbonTrail(textures[0], 50, 50);
			ribbonTrail.isPlaying = true;
			ribbonTrail.setStarToEndAlpha(1.0, 0);
//			ribbonTrail.setStarToEndColor(0xFFFFFF, 0);
			addChild(ribbonTrail);
			
			Starling.current.juggler.add(this);
			Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_UP, stageKeyUpHandler);
		}
		
		public function advanceTime(passedTime:Number):void
		{
			var flashStage:Stage = Starling.current.nativeStage;
			
			ribbonTrail.floowingX = flashStage.mouseX;
			ribbonTrail.floowingY = flashStage.mouseY;
			
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
					ribbonTrail.allowFloowing = !ribbonTrail.allowFloowing;
					break;

				case Keyboard.H:
					if(event.ctrlKey)
					{
						ribbonTrail.thickness = ribbonTrail.thickness * 0.8;
					}
					else
					{
						ribbonTrail.thickness = ribbonTrail.thickness * 1.2;
					}
					break;
				
				case Keyboard.D:
					if(event.ctrlKey)
					{
						ribbonTrail.decayRatio = ribbonTrail.decayRatio * 0.8;
					}
					else
					{
						ribbonTrail.decayRatio = ribbonTrail.decayRatio * 1.2;
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