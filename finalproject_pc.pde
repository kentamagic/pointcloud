import org.openkinect.*;
import org.openkinect.processing.tests.*;
import org.openkinect.processing.*;

//Set up kinect object 
//Kinect image resolution is 640 x 480
Kinect k;
int kw = 640; //kinect width
int kh = 480; //kinect height 
int angle = 20;

//for each kinect depth value, we calculate the value in meters 
//and store it in an array 
float[] conversionTable = new float[2048];

//set resolution of point cloud 
int res = 4;

//set Rotation value 
float a = 0;

void setup(){
  
  size(1280,800,P3D);
  
  //start kinect
  k = new Kinect(this);
  k.start();
  k.enableDepth(true);
  k.processDepthImage(false);
  
  //enable tilt control 
  k.tilt(angle);
  
  //set windowsize 
  size(displayWidth, displayHeight, P3D);
  
  //set conversionTable 
  //each values from 0 to 2047 corresponds to a meter value 
  for(int i=0; i<2048; i++){
    conversionTable[i] = calculateMeter(i);
  } 
  
}

//ideas
//1. gradually, the point-cloud starts building 
//2. the rotation axis changes 
//3. color changes 
//4. study translation!!!


void draw(){
  
  background(0);

  int[] rawDepthArray = k.getRawDepth();
  
  //traslation and rotation should happen here
  //translate();
  translate(width/2,height/2,-1000);
  rotateY(a);
  
  for(int x=0; x<kw; x=x+res){
    for(int y=0; y<kh; y=y+res){
      int index;
      index = x + y*kw;
      int rawDepth = rawDepthArray[index];
      float meterDepth = conversionTable[rawDepth];
      
      if(meterDepth <= 1.0){
      
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
  
    
  //display kinect tilt
  fill(255);
  text("Kinect Angle: " + angle, 20, 20);
  
  
  //Rotate
  a += 0.02f;
}

//get keyboard input to adjust kinect angle
void keyPressed(){
  if(key == CODED){
    if(key == UP){
      angle++;
    }else if(key == DOWN){
      angle--;
    }
    //make sure kinect angle doesn't go beyond border 
    angle = constrain(angle, 0, 30);
    k.tilt(angle);
  }
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

void stop() {
  k.quit();
  super.stop();
}



