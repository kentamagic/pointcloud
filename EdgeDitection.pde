//basic edge ditection algorithm for each frame 

//as the edge detection can be really rough for my project, 
//set the differencebetweeen the center vector and the surrounding vector very high
float[][] k = {{-5, -5, -5},
               {-5, 10, -5},
               {=-5, -5, -5}}

PImage image;

void setup(){
  size(2000, 1080);
  image = loadImage("screenshot.jpg");
  noLoop()//as this is a one time operation, we don't set the loop
}

void draw(){

  //load image from the starting location, which in this case is (0,0)
  image(image, 0, 0);
  
  //load all the pixels of the image 
  image.loadPixels();
  
  //create a transparant image to be filled in 
  PImage result = createImage(image.width, img.height, RGB);
  
  //go over every single pixel except the edges of the original image to recreate the
  //egde we need (which means we can skip the 0s on both x and y on the
  //following for loops).
  for(int y = 1; y < (image.height - 1); y++){
    //now go through the width part...
    for(int x = 1; x < (image.width - 1); x++){
      
      float total = 0; //initialize total before going in the kx, ky loop 
      
      //reloop with in each image for the kernel values 
      for(int ky = -1; ky <= 1; ky++){
        for(int kx = -1; kx <= 1; kx++){
          
          int current = (y + ky)*(image.width) + (x + kx);
          float pixValue = red(image.pixels[current]); //convert to gren scale, in case it's not. 
          
          //now use the kernel array to accentuate the edge
          total = k[ky+1][kx+1]*pixValue;
        }
      } 
      
      //update the pixel value for each pixel
      result.pixels[y*(image.width) + x] = color(total, total, total); 
    } 
  }//completed operation for each pixel, now time to update the entire image
 
  result.updatePixels();
  image(result, 0, 0);//display
}

//done!
