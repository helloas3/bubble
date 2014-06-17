package
{
	import flash.display.Sprite;

	public class Ball extends Sprite
	{
		private var kind:int;
		private var color:int;
		private var r:int;
		private var colors:Array = [0x0000ff,0x00ff00,0xff0000,0x00ffff,0xff00ff,0xffff00];
		
		public function Ball(_kind:int, _r:Number = 15)
		{
			this.kind = _kind;
			this.r = _r;
			init();
		}
		
		public function init():void
		{
			this.graphics.beginFill(colors[kind],0.7);
			this.graphics.drawCircle(0,0,r);
			this.graphics.endFill();
		}
		
		public function getKind():int
		{
			return this.kind;
		}
	}
}