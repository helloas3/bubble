package 
{
	import flash.display.Sprite;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class BubbleGame extends Sprite
	{
		private var board:Sprite;

		private var balls:Array;

		private var bubbles:Array;

		private var visited:Array;

		private var num:int = 38;

		private var wid:int = 10;

		private var hig:int = 12;

		private var levels:int = 5;

		private var kinds:int = 6;

		private var r:Number = 15;

		private var shooter:Sprite;

		private var newBall:Ball;

		private var turn:int = 0;

		private var speed:Number = 8;

		private var curSpeed:Number = 5;

		private var curRo:Number;

		private var curAng:Number;

		private var ang:Number;

		private var ro:Number;

		private var edgeW:Number = 300;

		private var edgeH:Number = 400;

		private var checks:Array;

		public function BubbleGame()
		{
			init();
		}

		public function init():void
		{
			initBoard();
			initBalls();
			initShooter();
			checks = new Array();
			this.addEventListener(Event.ENTER_FRAME, onGaming);
			stage.addEventListener(MouseEvent.CLICK, onShoot);
		}

		public function onShoot(e:MouseEvent):void
		{
			turn = 1;
			curAng = ang;
			curRo = ro;
			curSpeed = speed;
		}

		public function toR(r:Number):Number
		{
			return r / Math.PI * 180;
		}

		public function tor(r:Number):Number
		{
			return r / 180 * Math.PI;
		}

		public function onGaming(e:Event):void
		{
			var dx:Number = board.mouseX - board.width / 2;
			var dy:Number = board.mouseY - (board.height - 20);
			ang = Math.atan2(dy,dx);
			ro = toR(ang);
			if (ro <-10 && ro > -170)
			{
				shooter.rotation = ro;
			}

			if (turn == 0)
			{
				if (! newBall)
				{
					newBall = new Ball(int(Math.random() * kinds));
					newBall.y = board.height - 20;
					newBall.x = board.width / 2;
					board.addChild(newBall);
				}
			}
			else if (turn == 1)
			{
				newBall.x +=  curSpeed * Math.cos(curAng);
				newBall.y +=  curSpeed * Math.sin(curAng);
				checkHit();
			}
		}

		public function checkHit():void
		{
			for (var i = hig - 1; i >= 0; --i)
			{
				for (var j = 0; j < wid - i%2; ++j)
				{
					if (bubbles[i][j] != null)
					{
						if ((newBall.x - bubbles[i][j].x)*(newBall.x - bubbles[i][j].x) + 
						   (newBall.y - bubbles[i][j].y)*(newBall.y - bubbles[i][j].y) <= 4*r*r)
						{
							var dr:Number = toR(Math.atan2(newBall.y - bubbles[i][j].y,newBall.x - bubbles[i][j].x));
							makePosition(dr,i,j);
							newBall = null;
							turn = 0;
							return;
						}

					}
				}
			}

			if ((newBall.x - r < 0) || (newBall.x + r > edgeW))
			{
				newBall.x -=  curSpeed * Math.cos(curAng);
				newBall.y -=  curSpeed * Math.sin(curAng);
				curRo = -180 - curRo;
				curAng = tor(curRo);
			}

			if (newBall.y - r < 0)
			{
				newBall.y +=  curSpeed * Math.sin(curAng);
				for (i = 0; i < wid; ++i)
				{
					if (Math.abs(r + i*2*r - newBall.x) <= r)
					{
						newBall.x = r + i * 2 * r;
						newBall.y = r;
						balls[0][i] = newBall.getKind();
						bubbles[0][i] = newBall;
						newBall = null;
						turn = 0;
						return;
					}
				}
			}
		}

		public function makePosition(nr:Number,i:int, j:int):void
		{
			var pi:int;
			var pj:int;
			if (nr <= 30 && nr > -30)
			{
				pi = i;
				pj = j + 1;

			}
			else if (nr > 30 && nr <= 90)
			{
				pi = i + 1;
				pj = j + i % 2;
			}
			else if (nr > 90 && nr <= 150)
			{
				pi = i + 1;
				pj = j - (i + 1) % 2;
			}
			else
			{
				pi = i;
				pj = j - 1;
			}

			balls[pi][pj] = newBall.getKind();
			bubbles[pi][pj] = newBall;
			newBall.y = r + pi * r * 2;
			newBall.x = (pi % 2) * r + r + pj * 2 * r;
			removeBubbles(pi,pj);
		}

		public function removeBubbles(i:int, j:int):void
		{
			var count:int = 0;
			checks.push(new Point(i,j));
			var k:int = balls[i][j];
			while (checks.length != 0)
			{
				trace("okkk");
				var p:Point = checks.shift();

				if (visited[p.x][p.y] != 0)
				{
					continue;
				}

				if (balls[p.x][p.y] != k)
				{
					visited[p.x][p.y] = 2;
					continue;
				}
				else
				{
					visited[p.x][p.y] = 1;
					count++;
				}

				if (p.y - 1 >= 0)
				{
					checks.push(new Point(p.x,p.y -1));
				}
				if (p.y + 1 <= wid - p.x % 2 - 1)
				{
					checks.push(new Point(p.x,p.y + 1));
				}
				if (p.x - 1 >= 0)
				{
					if (p.y - (p.x+1)%2 >= 0)
					{
						checks.push(new Point(p.x - 1, p.y - (p.x + 1)%2));
					}

					if (p.y +p.x%2 <= wid - (p.x - 1)%2 - 1)
					{
						checks.push(new Point(p.x - 1,p.y + p.x % 2));
					}
				}
				if (p.x + 1 <= hig - 1)
				{
					if (p.y - (p.x+1)%2 >= 0)
					{
						checks.push(new Point(p.x + 1, p.y - (p.x + 1)%2));
					}

					if (p.y +p.x%2 <= wid - (p.x - 1)%2 - 1)
					{
						checks.push(new Point(p.x + 1,p.y + p.x % 2));
					}
				}
			}

			if (count >= 3)
			{
				for (var i:int = 0; i < hig; ++i)
				{
					for (var j:int = 0; j < wid - i % 2; ++j)
					{
						if (visited[i][j] == 1)
						{
							balls[i][j] = -1;
							board.removeChild(bubbles[i][j]);
							bubbles[i][j] = null;

						}
					}
				}
			}

			clearVisit();
		}


		public function clearVisit():void
		{
			for (var i:int = 0; i < hig; ++i)
			{
				for (var j:int = 0; j < wid - i % 2; ++j)
				{
					visited[i][j] = 0;
				}
			}
		}
		public function initShooter():void
		{
			shooter = new Sprite();
			shooter.graphics.lineStyle(2);
			shooter.graphics.moveTo(0,0);
			shooter.graphics.lineTo(30,0);
			shooter.graphics.lineTo(25,-3);
			shooter.graphics.moveTo(30,0);
			shooter.graphics.lineTo(25,3);
			board.addChild(shooter);
			shooter.x = board.width / 2;
			shooter.y = board.height - 20;
		}

		public function initBoard():void
		{
			board = new Sprite();
			board.graphics.lineStyle(2);
			board.graphics.moveTo(0,0);
			board.graphics.lineTo(0,400);
			board.graphics.lineTo(300,400);
			board.graphics.lineTo(300,0);
			board.graphics.lineTo(0,0);
			this.addChild(board);
			board.x = stage.stageWidth / 2 - board.width / 2;
			board.y = stage.stageHeight / 2 - board.height / 2;
		}

		public function initBalls():void
		{
			balls = new Array();
			bubbles = new Array();
			visited = new Array();
			for (var i:int = 0; i < hig; ++i)
			{
				balls[i] = new Array();
				bubbles[i] = new Array();
				visited[i] = new Array();
				if ( i < levels )
				{
					for (var j:int = 0; j < wid - i % 2; ++j)
					{
						balls[i][j] = int(Math.random() * kinds);
						bubbles[i][j] = new Ball(balls[i][j]);
						bubbles[i][j].y = r + i * 2 * r;
						bubbles[i][j].x = (i % 2) * r + r + j * 2 * r;
						board.addChild(bubbles[i][j]);
					}
				}
			}
		}

	}
}