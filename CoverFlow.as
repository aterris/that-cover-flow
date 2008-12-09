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
		private var container:Sprite;
		private var loader:URLLoader;
		private var currentImage:uint;
		private var theImages:Array;
		private var currentTween:Tween;
		private var Tweening:Boolean;	
		var isClicking:Boolean = false;
		var clickLength:uint = 0;
		
		//Constants - Prepare for dynamic creation by using constants
		public const windowWidth:Number = stage.width;
		public const windowHeight:Number = stage.height;
		public const imageWidth:Number = 500;
		public const imageHeight:Number = 334;
		
		//Constructor
		public function CoverFlow()
		{
			init();
			loadXML();
		}
		
		//init
		private function init():void
		{
			container = new Sprite();
			container.x = 350;
			container.y = 250;
			container.z = 400;
			addChild(container);
			
			//cover.addEventListener(MouseEvent.CLICK, stageClick);
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
				var imc:imCon = new imCon();
				imc.buttonMode = true;
				imc.addEventListener(MouseEvent.CLICK, onClick);
				
				var l:Loader = new Loader();
				l.x = -250;
				l.y = -167;
				l.load(new URLRequest(list[i].@src));
				imc.addChild(l);
				
				trace(imc.width);
				imc.scaleX = imc.scaleY = .8;
				currentImage = 0;
				imc.imageNum = i;
				
				theImages[i] = imc;
				
				if(i==0)
				{
					imc.scaleX = 1;
					imc.scaleY = 1;
					imc.x = 0;
				}
				else
				{
					imc.rotationY = 90;
					imc.x = i*75+200;
				}
				
				imc.z = i*10;
				container.addChild(imc);
			}
		}
		
		//changeCurrentImage
		private function changeCurrentImage(theNewImage:Object)
		{
			if(!Tweening)
			{
				Tweening = true;
				//Move To New Location
				if(theNewImage.imageNum > currentImage)
				{
					//new Tween(container,"x", Strong.easeOut, container.x, (container.x - (150)*(theNewImage.imageNum - currentImage)) , 3, true);
				
					currentImage = theNewImage.imageNum;
				}
				else if(theNewImage.imageNum < currentImage)
				{
					//new Tween(container,"x", Strong.easeOut, container.x, (container.x + (150)*(currentImage - theNewImage.imageNum)) , 3, true);
				
					currentImage = theNewImage.imageNum;
				}
					
				//Adjust Other Images
				for(var i:int=currentImage-1; i>=0; i--)
				{
					if(theImages[i].rotationY !=-90)
						new Tween(theImages[i],"rotationY", Strong.easeOut, theImages[i].rotationY, -90 , .5, true);
					
					theImages[i].scaleX = .8;
					theImages[i].scaleY = .8;
					new Tween(theImages[i],"x", Strong.easeOut, theImages[i].x, (-(currentImage - i)*75-200) , 1, true);
					theImages[i].z = (currentImage - i);
				}
					
				for(var j:int=currentImage+1; j<theImages.length; j++)
				{
					if(theImages[j].rotationY !=90)
						new Tween(theImages[j],"rotationY", Strong.easeOut, theImages[j].rotationY, 90 , .5, true);
					
					theImages[j].scaleX = .8;
					theImages[j].scaleY = .8;
					new Tween(theImages[j],"x", Strong.easeOut, theImages[j].x, (j-currentImage)*75+200 , 1, true);
					theImages[j].z = j;
				}
				
				new Tween(theNewImage,"x", Strong.easeOut, theNewImage.x, 0 , 1, true);
					
				
				//Turn And Scale New Center Image
				currentTween = new Tween(theNewImage,"rotationY", Strong.easeOut, theNewImage.rotationY, 0, 1, true);
				currentTween.addEventListener(TweenEvent.MOTION_FINISH, onTweenFinish);
				theNewImage.scaleX = 1;
				theNewImage.scaleY = 1;
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
			SimpleZSorter.sortClips(container);
		}
	}
}