// SENIOR PROJECT by KENTA KOGA
// YALE CLASS OF 2014, Spring 2014 
// CS490 


//import kinect library 
import org.openkinect.*;
import org.openkinect.processing.tests.*;
import org.openkinect.processing.*;

//Set up kinect object 
//Kinect image resolution is 640 x 480
Kinect k;
int kw = 640; //kinect width
int kh = 480; //kinect height 

//for each kinect depth value, we calculate the value in meters 
//and store it in an array 
float[] conversionTable = new float[2048];


//import fisica library 
import fisica.*;
import geomerative.*;
import org.apache.batik.svggen.font.table.*;
import org.apache.batik.svggen.font.*;

//Set up Fisica world
FWorld world;
float posX = 0; //this is the initial x-pos of the place letters fall 
RFont font;

//set resolution of point cloud 
int res = 5;
//set Rotation value 
float a = 0;

//timer set-up
//all in millisec
int startTime;
int clearTime = 50000;
//int fontTime = 50000;
//int captureTime = 50000;

int z = 1;


//font array
String[] fontArray = {"Times-RomanSC.ttf", "LiberationSerif-Bold.ttf", "Swiss721BT-LightItalic.ttf"};
int fontCount = 0;
int fontIndex;

//import SoundCipher
import arb.soundcipher.*;
//set up new SoundCipher 
SoundCiper sound = new SoundCipher(this);


void setup(){
  
  size(2000,1080,P3D);
  smooth();
  frameRate(30);
  
  //start timer 
  startTime = millis();
  
  //initialize fisica world
  Fisica.init(this);
  //scale meters to pixels
  //1 m == x pixel
  Fisica.setScale(5);
  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);
  
  world = new FWorld();
  world.setGravity(0, 800);
  world.setEdges(this, color(0));
  //not sure if I need this but...
  world.remove(world.top);
  
  fontIndex = fontCount % fontArray.length;
  String fontType = fontArray[fontIndex];
  font = RG.loadFont(fontType);
  
  
  //start kinect
  k = new Kinect(this);
  k.start();
  k.enableDepth(true);
  k.processDepthImage(false);
  
  //set windowsize 
  //size(displayWidth, displayHeight, P3D);
  
  //set conversionTable 
  //each values from 0 to 2047 corresponds to a meter value 
  for(int i=0; i<2048; i++){
    conversionTable[i] = calculateMeter(i);
  } 
  
}

void draw(){
  
  background(0);

  int[] rawDepthArray = k.getRawDepth();
  
    
  //print the letters
  fill(255);
  world.draw(this);
  
  
  //traslation and rotation should happen here
  //adjust the size of the virtual point cloud within the screen 
  translate(width/2,height/2,-50);
  //and rotate! 
  rotateY(a);

  //create a dot (or not) for each pixel 
  for(int x=0; x<kw; x=x+res){
    for(int y=0; y<kh; y=y+res){
      int index;
      index = x + y*kw;
      int rawDepth = rawDepthArray[index];
      float meterDepth = conversionTable[rawDepth];
      
      if(meterDepth <= 1.5){
        PVector v = mapDepth(x, y, rawDepth);
        pushMatrix();
        float scale = 800;
        translate(v.x*scale,v.y*scale,scale-v.z*scale);
        
        stroke(255);
        point(0,0);
        popMatrix(); 
      }
    }
  }  
  
  //Rotate
  a += 0.01f;
  //update
  world.step();
  
//  //TIMER ========================================================
//  //currently not working but it ocationally work when I'm not exhibiting my work 
//  // it is something to do with the "present" mode of processing that disables this feature on my code 
//  //check time, and clear letters/take screenshot if necessary 
//  int timePassed = millis() - startTime;
//  if((timePassed%clearTime) == 0){
//    //change font
//    //capture
//    try{
//      saveFrame("screenshot.png");
//    }catch(Exception e){
//    }
//    //clear
//    world.clear();
//    world.setEdges(this, color(255));
//    world.remove(world.top);
//  }  
//  //===============================================================
  
}


//based on: http://graphics.stanford.edu/~mdfisher/Kinect.html
//changed some numerical values for my personal project
float calculateMeter(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector mapDepth(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  conversionTable[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}
//=======================================================================
//get the character from keyboard input
void keyPressed() {  
  FChar chr = new FChar(key);
  
  //play sound upon detecting keyPressed 
  sound.playNote(key - 45, 100, 0.5);
  
  if (chr.isCreated()) {
    world.add(chr);
  }

  //space just moves the posX in the positive direction by 10px (also it clears the space)
  if (key == BACKSPACE) {
    world.clear();
    world.setEdges(this, color(0));
    world.remove(world.top);
  }
  
  //ENTER key changes fonts!
  if(key == ENTER){
    fontCount++;
    fontIndex = fontCount % fontArray.length;
    String fontType = fontArray[fontIndex];
    font = RG.loadFont(fontType);    
  }

  //CONTROL key takes a screenshot 
  try{
    if (keyCode==CONTROL) {
      saveFrame("screenshot"+ z + ".png");
      z++;
    }
  } 
  catch (Exception e) {
  }
  
}
//=========================================================================

//stop code 
void stop() {
  k.quit();
  super.stop();
}



