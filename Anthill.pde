/**CONFIG**/
final int NUMBER_OF_SOURCES = 2;
final int DEF_RADIUS = 100;
final float DEF_W = 0.2;

// Let's define a node class
abstract class Node {
  float x;
  float y;
  public Node(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class Phermone extends Node {
  float weight; // -1 to 1
  public Phermone(float x, float y, float w) {
    super(x,y);
    this.weight = w;
  }
}

class Source extends Node {
  float amount; // 0 to 1000
  public Source(float x, float y, float a) {
    super(x,y);
    this.amount = a;
  }
}

class Ant {
  float x;
  float y;
  float hunger; // die on 0
  float range;
  boolean hungry;
  
  public Ant(float x, float y, float range) {
    this.x = x;
    this.y = y;
    this.hunger = 1;
    this.range = range;
    this.hungry = false;
  }
  
  void drawMe() {
    stroke(255);
    fill(255);
    ellipse(this.x, this.y, 6, 6);
  }
  
  Phermone move(ArrayList<Phermone> phermones, ArrayList<Source> sources) {
    float randomness_x = random(20);
    float randomness_y = random(20);
    
    // loop through phermones and find the direction of highest increase
    float vx = randomness_x - 10;
    float vy = randomness_y - 10;
    float max_weight = -100;
    for (Phermone p : phermones) {
      if(p.weight > max_weight) {
        float dx = p.x - this.x;
        float dy = p.y - this.y;
        
        float dsq = dx*dx + dy*dy;
        
        vx = dx/dsq;
        vy = dy/dsq; 
      }
    }
    
    for (Source s : sources) {
      float dx = s.x - this.x;
      float dy = s.y - this.y;
      float magsq = dx*dx + dy*dy;
      if(s.amount/1000 > max_weight && magsq < this.range*this.range) {
         max_weight = s.amount/1000;
         vx = dx/pow(magsq,0.5);
         vy = dy/pow(magsq,0.5);
      }
    }
    
    // move in that direction and create new phermone along path of movement
    Phermone p;
    
    // if i can find a source OR a phermone with very high weight (aka next to a source), create high weight phermone
    if(max_weight > 0.8) {
      p = new Phermone(this.x + vx, this.y + vy, 0.9 + random(0.2)-0.1);
    } else {
      p = new Phermone(this.x + vx, this.y + vy, DEF_W);
    }
    
    // 30% probability to not listen and go somewhere else
    if(random(1) < 0.7) {
        this.x += vx;
        this.y += vy;  
     } else {
        vx = randomness_x - 10;
        vy = randomness_y - 10;
        this.x += vx;
        this.y += vy;  
     }
   
    // for every movement, subtract from hunger
    this.hunger -= 0.01;
    
    // if hunger = 0, die
    
    // if hunger = 1.5, reproduce
    
    return p;
  }
  
  Ant reproduce() { // the ant reproduces
    return new Ant(this.x, this.y, this.range + random(1)-0.5);
  }
}

class Hill extends Node {
  ArrayList<Ant> ants;
  
  public Hill(float x, float y, int population) {
    super(x,y);
    this.ants = new ArrayList<Ant>();
    for(int i = 0; i < population; i ++) {
      this.ants.add(new Ant(x, y, DEF_RADIUS)); 
    }
  }
  
  ArrayList<Phermone> moveAllAnts(ArrayList<Phermone> phermones, ArrayList<Source> sources) {
    // draw the hill
    stroke(255, 0, 0);
    fill(255, 0, 0);
    ellipse(this.x, this.y, 25, 25);
    
    // draw ants
    for(Ant a : this.ants) {
      Phermone p = a.move(phermones, sources);
      phermones.add(p);
    }
    
    return phermones;
  }
}

Hill hill;
ArrayList<Source> sources;
ArrayList<Phermone> phermones;
void setup() {
 size(900,900);
 hill = new Hill(300,300,20);
 sources = new ArrayList<Source>();
 phermones = new ArrayList<Phermone>();
 
 // create some food sources
 for(int i = 0; i < NUMBER_OF_SOURCES; i ++) {
    sources.add(new Source(random(width-100) + 50, random(height-100) + 50, random(100) + 400));
 }
}

void draw() {
  background(0);
  
  phermones = hill.moveAllAnts(phermones, sources);
  for(Source n : sources) {
    stroke(0,0,255);
    fill(0,0,255);
    ellipse(n.x, n.y, sqrt(n.amount), sqrt(n.amount));
  }
  
  for(Phermone p : phermones) {
    if(p.weight > 0.75) {
      stroke(255, 180, 0);
    } else {
      stroke(map(p.weight,0,1,25,180),map(p.weight,0,1,80,255),map(p.weight,0,1,40,180));
    }
    
    noFill();
    ellipse(p.x, p.y, 1,1);
  }
  
  for(Ant a : hill.ants) {
    a.drawMe(); 
  }
}
