//*************************//
// Project: That Cover Flow
// File: CoverFlow.as
// Created By: Andrew Terris
// Created For: IM 336
//*************************//

package 
{
	//Imports
	//import com.leebrimelow.utils.Math2;
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
		public const windowWidth:Number = 700;//why does stage.width and height give bigger numbers than in document properties
		public const windowHeight:Number = 500;
		public const imageWidth:Number = 500;
		public const imageHeight:Number = 334;
		public const imageScaleX:Number = .5;
		public const imageScaleY:Number = .5;
		public const imageRotationY:Number = 85;
		public const flowMiddle:Number = windowWidth/2;
		
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
			
			trace(flowMiddle);
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
				
				var l:Loader = new Loader();
				l.x = -imageWidth/2;
				l.y = -imageHeight/2;
				l.load(new URLRequest(list[i].@src));
				coverImage.addChild(l);
				
				coverImage.scaleX = coverImage.scaleY = imageScaleX;
				currentImage = 0;
				coverImage.imageNum = i;
				
				theImages[i] = coverImage;
				
				if(i==0)
				{
					coverImage.scaleX = imageScaleX;
					coverImage.scaleY = imageScaleY;
					coverImage.x = flowMiddle; 
				
					coverImage.z = 0;
				}
				else
				{
					coverImage.rotationY = imageRotationY;
					coverImage.x = i*50+ flowMiddle + 100;
					coverImage.z = i*10+100;
				}
				coverImage.y=250;
				
				coverImage.scaleX = imageScaleX;
				
				coverImage.scaleY = imageScaleY;
				
				
				coverContainer.addChild(coverImage);
				
			}
		}
		
		//changeCurrentImage
		private function changeCurrentImage(theNewImage:Object)
		{
			if(!Tweening)
			{
				trace("test here");
				Tweening = true;
				//Move To New Location
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
					
					theImages[i].scaleX = imageScaleX;
					theImages[i].scaleY = imageScaleY;
					new Tween(theImages[i],"x", Strong.easeOut, theImages[i].x, (flowMiddle)-((currentImage - i)*50+100) , 1, true);
					theImages[i].z = (currentImage - i)*10+100;
					
					//trace((flowMiddle)-((currentImage - i)*75-200));
				}
					
				for(var j:int=currentImage+1; j<theImages.length; j++)
				{
					if(theImages[j].rotationY !=imageRotationY)
						new Tween(theImages[j],"rotationY", Strong.easeOut, theImages[j].rotationY, imageRotationY , .5, true);
					
					theImages[j].scaleX = imageScaleX;
					theImages[j].scaleY = imageScaleY;
					new Tween(theImages[j],"x", Strong.easeOut, theImages[j].x, (j-currentImage)*50+ flowMiddle + 100 , 1, true);
					theImages[j].z = j*10+100;
					//trace("z level" + theImages[j].z);
				}
				
				new Tween(theNewImage,"x", Strong.easeOut, theNewImage.x, flowMiddle , 1, true);
					
				
				//Turn And Scale New Center Image
				currentTween = new Tween(theNewImage,"rotationY", Strong.easeOut, theNewImage.rotationY, 0, 1, true);
				currentTween.addEventListener(TweenEvent.MOTION_FINISH, onTweenFinish);
				theNewImage.scaleX = imageScaleX;
				theNewImage.scaleY = imageScaleY;
				theNewImage.z = 0;
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