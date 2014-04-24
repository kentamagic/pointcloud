//This class FChar extends class FPoly in the fisica library 
//it takes in a char, converts it into a string, converts that string into a shape 
//and applies the physics simulation on it.

//inspiration and base code from
//https://github.com/7Ds7/AngryArtists/blob/master/Processing/angryartists/libraries/fisica/examples/Letters/FChar.pde
//modified in order to suit my project 

class FChar extends FPoly{
  
  float maxSize = 70;
  float minSize = 100;

  RShape shape; 
  RShape poly; 
  
  boolean created;
  
  FChar(char c){
     super();
    
    String s = "" + c;
    int fontSize = (int)random(maxSize, minSize);
    RG.textFont(font, fontSize);
    shape = RG.getText(s);
    
    poly = RG.polygonize(shape);
    
    //deal with when the space is pressed 
    if(poly.countChildren() < 1){
      return;
    }
    
    poly = poly.children[0];
    
    float maxL = 0.0;
    int maxIndex = -1; //this is supposed to change 
    for(int i = 0; i<poly.countPaths(); i++){
      float current = poly.paths[i].getCurveLength();
      if(current > maxL){
        maxL = current;
        maxIndex = i;
      } 
    }
    
    //it shouldnt happen but just in case 
    if(maxIndex == -1){
      return;
    }
    
    created = true;
    
    RPoint[] pointArray = poly.paths[maxIndex].getPoints(); 
    
    //create vertex for each point
    for(int i=0; i<pointArray.length; i++){
      this.vertex(pointArray[i].x, pointArray[i].y);
    }
    
    this.setFill(255, 255, 255); //color of the Font, white
    this.setStroke(255); //color of the outline, also white 
    this.setStrokeWeight(0); // weight of outline
    
    //set fisica elements 
    this.setDamping(0);
    this.setRestitution(0.6); //set how much it bounces
    this.setBullet(true); //enable more accurate modeling 
    this.setPosition(posX+10, height/5);
    posX = (posX + poly.getWidth()) % (width - 100);  
  }

  boolean isCreated(){
    return created;
  }  
    
  void draw(PGraphics applet){
    preDraw(applet);
    shape.draw(applet);
    postDraw(applet);
  }
  
  
}
