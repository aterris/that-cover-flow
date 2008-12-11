//*************************//
// Project: That Cover Flow
// File: CoverFlow.as
// Created By: Andrew Terris
// Created For: IM 336
//*************************//

package 
{
	//Imports
	//clean these up eventually, prolly some overlap etc
	import com.theflashblog.fp10.SimpleZSorter;
	import fl.motion.easing.Exponential;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.*;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
 	import fl.transitions.Tween;
 	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.geom.Point;

	public class CoverFlow extends Sprite
	{
		//Variables
		private var coverContainer:Sprite;
		private var loader:URLLoader;
		private var currentImage:uint;
		private var theImages:Array;
		private var currentTween:Tween;
		private var Tweening:Boolean;	
		var isClicking:Boolean = false;
		var clickLength:uint = 0;
		
		//Constants - Prepare for dynamic creation by using constants
		public const windowWidth:uint = 700;//why does stage.width and height give bigger numbers than in document properties
		public const windowHeight:uint = 500;
		public const imageWidth:uint = 500;
		public const imageHeight:uint = 334;
		
		public const imageScaleX:Number = .5;
		public const imageScaleY:Number = .5;
		public const imageRotationY:int = 85;
		public const innerXPadding:uint = 300;
		public const outerXPadding:uint = 75;
		public const innerZPadding:uint = 300;
		public const outerZPadding:uint = 10;
		public const flowYPadding:uint = 100;
		
		public const flowMiddleX:Number = windowWidth/2;
		public const flowMiddleY:Number = windowHeight/2;
		
		//Constructor
		public function CoverFlow()
		{
			init();
			loadXML();
		}
		
		//init
		private function init():void
		{
			coverContainer = new Sprite();
			coverContainer.x = 0;
			coverContainer.y = 0;
			coverContainer.z = 0;
			addChild(coverContainer);
			
			//move the "camera"  -is centered on the image correct (or should it change to closer to the bottom etc)
			root.transform.perspectiveProjection.projectionCenter = new Point(flowMiddleX, flowYPadding+imageHeight*imageScaleX/2); 
			
			this.addEventListener(Event.ENTER_FRAME, loop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownImage);
		}
		
		//loadXML
		private function loadXML():void
		{
			loader = new URLLoader(new URLRequest("images.xml"));
			loader.addEventListener(Event.COMPLETE, createFlow);
		}
		
		//createFlow
		private function createFlow(e:Event):void
		{
			var xml:XML = new XML(e.target.data);
			var list:XMLList = xml.image;
			
			theImages = new Array();
			Tweening = false;
			
			for(var i:int=0; i<list.length(); i++)
			{
				var coverImage:imCon = new imCon();
				coverImage.buttonMode = true;
				coverImage.addEventListener(MouseEvent.CLICK, onClick);
				
				coverImage.scaleX = imageScaleX;
				coverImage.scaleY = imageScaleY;
				
				var l:Loader = new Loader();
				l.x = -imageWidth*scaleX/2;
				l.y = -imageHeight*scaleY/2;
				l.load(new URLRequest(list[i].@src));
				coverImage.addChild(l);
				
				currentImage = 0;
				coverImage.imageNum = i;
				
				theImages[i] = coverImage;
				
				if(i==0)
				{
					coverImage.x = flowMiddleX; 
					coverImage.z = 0;
				}
				else
				{
					coverImage.rotationY = imageRotationY;
					coverImage.x = (i-1)*outerXPadding+ flowMiddleX + innerXPadding;
					coverImage.z = i*outerZPadding+innerZPadding;
				}
				coverImage.y=flowYPadding+imageHeight*imageScaleY/2;
				
				coverContainer.addChild(coverImage);
				
			}
		}
		
		//changeCurrentImage
		private function changeCurrentImage(theNewImage:Object)
		{
			
			if(!Tweening)
			{
				theNewImage.scaleX = imageScaleX;
				theNewImage.scaleY = imageScaleY;
				
				
				Tweening = true;
				//Move To New Location  -This code needs to be redone, doesnt really do anything right now
				if(theNewImage.imageNum > currentImage)
				{
					//new Tween(coverContainer,"x", Strong.easeOut, coverContainer.x, (coverContainer.x - (150)*(theNewImage.imageNum - currentImage)) , 3, true);
					currentImage = theNewImage.imageNum;
				}
				else if(theNewImage.imageNum < currentImage)
				{
					//new Tween(coverContainer,"x", Strong.easeOut, coverContainer.x, (coverContainer.x + (150)*(currentImage - theNewImage.imageNum)) , 3, true);
					currentImage = theNewImage.imageNum;
				}
				
				
				//Adjust Other Images
				for(var i:int=currentImage-1; i>=0; i--)
				{
					if(theImages[i].rotationY !=-imageRotationY)
						new Tween(theImages[i],"rotationY", Strong.easeOut, theImages[i].rotationY, -imageRotationY , .5, true);
					
					new Tween(theImages[i],"x", Strong.easeOut, theImages[i].x, (flowMiddleX)-((currentImage - i-1)*outerXPadding+innerXPadding) , 1, true);
					//dont want back one to tween, but would be nice if old centered image would since its goign form 0 to 100+
					//new Tween(theImages[i],"z", Strong.easeOut, theImages[i].z, (currentImage - i)*outerZPadding+innerZPadding, 1, true);
					theImages[i].z = (currentImage - i)*outerZPadding+innerZPadding;
				}
				
				
				for(var j:int=currentImage+1; j<theImages.length; j++)
				{
					
					if(theImages[j].rotationY !=imageRotationY)
						new Tween(theImages[j],"rotationY", Strong.easeOut, theImages[j].rotationY, imageRotationY , .5, true);
					
					new Tween(theImages[j],"x", Strong.easeOut, theImages[j].x, (j-currentImage-1)*outerXPadding+ flowMiddleX + innerXPadding , 1, true);
					//new Tween(theImages[j],"z", Strong.easeOut, theImages[j].z, (j-currentImage)*outerZPadding+innerZPadding , 1, true);
					theImages[j].z = (j-currentImage)*outerZPadding+innerZPadding;					
				}
				
				new Tween(theNewImage,"x", Strong.easeOut, theNewImage.x, flowMiddleX , 1, true);
				new Tween(theNewImage,"z", Strong.easeOut, theNewImage.z, 0 , 1, true);
				//Turn And Scale New Center Image
				theNewImage.rotationY = 0;
				//Tweening = false;
				//somehow the bellow tween messes up the scaling and creates a situation where it does not scale in the x
				currentTween = new Tween(theNewImage,"rotationY", Strong.easeOut, theNewImage.rotationY, 0, 1, true);
				currentTween.addEventListener(TweenEvent.MOTION_FINISH, onTweenFinish);
				
				//why does this need to be done?  should already be .5  where does it change?
				theNewImage.scaleX = imageScaleX;
			}
		}		
		
		
		//onCLick
		private function onClick(e:MouseEvent):void
		{
			changeCurrentImage(e.currentTarget);
		}
		
		//onTweenFinish
		private function onTweenFinish(e:Event)
		{
			Tweening = false;
		}
		
		//onKeyDownImage
		private function onKeyDownImage(e:KeyboardEvent)
		{
			var keyPressed:uint = e.keyCode;
			switch(keyPressed)
			{
				//Left
				case 37:
					if(currentImage!=0)
						changeCurrentImage(theImages[currentImage-1]);
					break;
				
				//Right
				case 39:
					if(currentImage!=theImages.length-1)
						changeCurrentImage(theImages[currentImage+1]);
					break;
			}
		}
		
		//loop
		private function loop(e:Event):void
		{
			//Z Order Sorting
			SimpleZSorter.sortClips(coverContainer);
		}
	}
}