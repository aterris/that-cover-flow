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
	import caurina.transitions.*
	import com.pixelfumes.reflect.*;
	import fl.motion.easing.Exponential;
  	import flash.display.MovieClip;
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
	import flash.utils.Timer;
	
	public class CoverFlow extends Sprite
	{
		//Variables
		private var flowContainer:MovieClip;
		private var loader:URLLoader;
		private var currentImage:uint;
		private var theImages:Array;
		private var currentTween:Tween;
		private var Tweening:Boolean;	
		var isClicking:Boolean = false;
		var clickLength:uint = 0;
		var slideShowTimer:Timer;
		
		//Constants - Prepare for dynamic creation by using constants
		public const windowWidth:uint = 700;//why does stage.width and height give bigger numbers than in document properties
		public const windowHeight:uint = 500;
		public const imageWidth:uint = 500;
		public const imageHeight:uint = 334;
		
		public const imageScaleX:Number = .8;
		public const imageScaleY:Number = .8;
		public const imageRotationY:int = 0;
		public const imageRotationZero:int = 0;
		public const innerXPadding:uint = 200;
		public const outerXPadding:uint = 200;
		public const innerYPadding:uint = 100;
		public const outerYPadding:uint = 100;
		public const innerZPadding:uint = 100;
		public const outerZPadding:uint = 100;
		public const flowYPadding:uint = 100;
		public const flowXPadding:uint = 20;
		public const flowStyle:String = "xbox";
		public const flowSlideShow:Boolean = false;
		public const slideShowChangeTimer:uint = 2000;
		
		public var flowFocusX:Number = windowWidth/2;
		public var flowFocusY:Number = windowHeight/2;
		
		//**** Initalization ****//
		//** Constructor  **//
		public function CoverFlow()
		{
			init();
			loadXML();
		}
		
		//** init **//
		private function init():void
		{
			//Create Flow Container
			flowContainer = new MovieClip();
			flowContainer.x = 0;
			flowContainer.y = 0;
			flowContainer.z = 0;
			//flowContainer.width = 50;
			//flowContainer.height = 30;
			addChild(flowContainer);
			
			//var r1 = new Reflect({mc:flowContainer, alpha:50, ratio:50, distance:0, updateTime:0, reflectionDropoff:0});
			
			//Set flowFocus
			if(flowStyle=="xbox")
				flowFocusX =flowXPadding + imageWidth*imageScaleX/2;
			
			//Set Timer For Slideshow
			if(flowSlideShow)
			{
				slideShowTimer = new Timer(slideShowChangeTimer,0);
				slideShowTimer.addEventListener (TimerEvent.TIMER, changeSlideShow);
				slideShowTimer.start ();
			}
			
			//Adjust the Camera
			root.transform.perspectiveProjection.projectionCenter = new Point(flowFocusX, flowYPadding+imageHeight*imageScaleX/2); 
			
			this.addEventListener(Event.ENTER_FRAME, loop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownImage);
		}
		
		//** loadXML **/
		private function loadXML():void
		{
			loader = new URLLoader(new URLRequest("images.xml"));

			loader.addEventListener(Event.COMPLETE, createFlow);
		}
		
		
		//**** Create Flows ****//
		//** createFlow **//
		private function createFlow(e:Event):void
		{
			if(flowStyle=="itunes")
				createItunesFlow(e);
			else if(flowStyle=="xbox")
			{
				flowFocusX =flowXPadding + imageWidth*imageScaleX/2;
				createItunesFlow(e);
			}
		}
		
		//** createItunesFlow **//
		private function createItunesFlow(e:Event):void
		{
			var xml:XML = new XML(e.target.data);
			var list:XMLList = xml.image;
			
			theImages = new Array();
			
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
					coverImage.x = flowFocusX; 
					coverImage.z = 0;
				}
				else
				{
					coverImage.rotationY = imageRotationY;
					coverImage.x = (i-1)*outerXPadding+ flowFocusX + innerXPadding;
					coverImage.z = i*outerZPadding+innerZPadding;
				}
				coverImage.y=flowYPadding+imageHeight*imageScaleY/2;
				
				flowContainer.addChild(coverImage);
			}
		}
		
		
		//**** Change Flows ****//
		//** changeFlow **//
		private function changeFlow(theNewImage:Object)
		{
			//Reset Timer
			if(flowSlideShow)
			{
				slideShowTimer.reset();
				slideShowTimer.start();
			}
			
			//Change Flow
			if(flowStyle=="itunes")
				changeItunesFlow(theNewImage);
			else if(flowStyle=="xbox")
				changeXboxFlow(theNewImage);
		}
		
		//** changeItunesFlow **//
		private function changeItunesFlow(theNewImage:Object)
		{
			currentImage = theNewImage.imageNum;
		
			//Adjust Left Image
			for(var i:int=currentImage-1; i>=0; i--)
			{
				if(theImages[i].rotationY !=-imageRotationY)
					Tweener.addTween(theImages[i], {rotationY: -imageRotationY, time:1, transition:"linear"});
					
				Tweener.addTween(theImages[i],{z:(currentImage - i)*outerZPadding+innerZPadding, x:(flowFocusX)-((currentImage - i-1)*outerXPadding+innerXPadding), time:1, transition:"linear"});
			}
			
			//Adjust Center Image
			Tweener.addTween(theNewImage,{x: flowFocusX, z:0,/*rotationY:0,*/ time:1, transition:"linear"});
			//Tweener.addTween(theNewImage, {rotationY:0, time:5, delay:1, transition:"linear"});
			theNewImage.rotationY = 0;
			
			//Adjust Right Images
			for(var j:int=currentImage+1; j<theImages.length; j++)
			{
				if(theImages[j].rotationY !=imageRotationY)
					Tweener.addTween(theImages[j], {rotationY: imageRotationY, time:1, transition:"linear"});

				Tweener.addTween(theImages[j],{z:(j-currentImage)*outerZPadding+innerZPadding, x:(j-currentImage-1)*outerXPadding+ flowFocusX + innerXPadding, time:1, transition:"linear"});
			}
			
			//why does this need to be done?  should already be .5  where does it change?
			theNewImage.scaleX = imageScaleX;
			theNewImage.scaleY = imageScaleY;
			
		}
		
		//** changeXboxFlow **//
		//transpareceny tween->0 only works on first tween
		private function changeXboxFlow(theNewImage:Object)
		{
			//Set New Current Image
			currentImage = theNewImage.imageNum;
			
			//Adjust Left Images
			for(var i:int=currentImage-1; i>=0; i--)
			{
				Tweener.addTween(theImages[i], {alpha:0, x:(flowFocusX)-((currentImage - i-1)*outerXPadding+innerXPadding), z:-1*((currentImage - i)*outerZPadding+innerZPadding), time:1, transition:"linear"});
			}
			
			//Adjust New Current Image
			Tweener.addTween(theNewImage,{x:flowFocusX, z:0, time:1, transition:"linear"});
			theNewImage.alpha=1;
			
			//Adjust Right Images
			for(var j:int=currentImage+1; j<theImages.length; j++)
			{
				Tweener.addTween(theImages[j], {x:(j-currentImage-1)*outerXPadding+ flowFocusX + innerXPadding, z:(j-currentImage)*outerZPadding+innerZPadding, alpha:1, time:1, transition:"linear"});
			}
		}
		
		
		//**** User Input ****//
		//onCLick
		private function onClick(e:MouseEvent):void
		{
			changeFlow(e.currentTarget);
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
						changeFlow(theImages[currentImage-1]);
					break;
				
				//Right
				case 39:
					if(currentImage!=theImages.length-1)
						changeFlow(theImages[currentImage+1]);
					break;
			}
		}
		
		
		//**** Helper Functions ****//
		//** onTweenFinish **//
		private function onTweenFinish(e:Event)
		{
			Tweening = false;
			trace(currentImage);
		}
		
		//** loop **//
		private function loop(e:Event):void
		{
			//Z Order Sorting
			SimpleZSorter.sortClips(flowContainer);
		}
		
		//** changeSlideShow  **//
		private function changeSlideShow(e:Event)
		{
			//Move To Next Image [0 if at the end]
			if(currentImage!=theImages.length-1)
				changeFlow(theImages[currentImage+1]);
			else
				changeFlow(theImages[0]);
		}
	}
}