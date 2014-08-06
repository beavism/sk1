
import com.reades.mapthing.*;
import net.divbyzero.gpx.*;
import net.divbyzero.gpx.parser.*;
import java.util.*;
ArrayList<artistHistory> gigography;
int northLimit = 1200000;
int southLimit = 0;
int eastLimit = 700000;
int westLimit = -200000;
String[] artists = {"Oasis", "Suede", "Blur"};
float[] reds = {175, 255,255};
float[] greens = {238,160,255};
float[] blues = {238,122,224};
int startYear = 1994;
int startMonth = 1;
int startDay = 8;
int endYear = 1995;
int endMonth = 1;
int endDay = 30;
GregorianCalendar calendar = new GregorianCalendar();
GregorianCalendar endDate = new GregorianCalendar();
int modifier = 45;
int scaler = 1;
long timeDiff = 0;
float tIncrement = 0;
long timeLapse = 14400000;//ms of calendar time per frame 2 hour per frame )   
int numArtists = 2;
BoundingBox box = new BoundingBox(northLimit, eastLimit, southLimit, westLimit);
Polygons basemap;
//PShape mapBox;
PGraphics ukmap;

void setup()
{
size((eastLimit-westLimit)/1000,(northLimit-southLimit)/1000);

  basemap  = new Polygons(box, dataPath("uk.shp"));
 basemap.setLocalSimplificationThreshold(0.5);
 

   calendar.set(startYear, startMonth-1, startDay,0,0,0);
  endDate.set(endYear, endMonth-1, endDay,0,0,0);
  gigography = loadPastGigs(artists);
  //frameRate(100);
  ukmap = createGraphics(width, height);
  
  background(80, 0,0);
  noFill();
  stroke(255,255,255,50);
  strokeWeight(.25);
    ukmap.beginDraw();
  ukmap.background(80,0,0);
  ukmap.stroke(255,255,255);
   basemap.project(this, ukmap);
  ukmap.endDraw();

  // basemap.project(this);
  //image(backgroundMap, 0, 0, width, height);

}
 
void draw(){
 // fill(255,255,255,50);
  //println(frameRate);
  //noFill();
  //stroke(255,255,255,50);
//  strokeWeight(.25);
 //basemap.project(ukmap);

 image(ukmap,width,height);
        noStroke();
        fill(0,0, 0, 3);
      //  shape(mapBox,400,240);
        rect(0,0,width,height); //fading rectangle
        fill(255, 255, 255); 
        rect(0,height-26, width, height);
        rect(0,10, width, 14);
  for(int z=0; z < gigography.size(); z++){
    
    artistHistory thisArtist = gigography.get(z);
    println(thisArtist.artistName);
    if (thisArtist.incrementer >= 1.0){
      thisArtist.incrementer = 0;
      thisArtist.index++;
    }
    if(thisArtist.index < thisArtist.pastGigs.size()-1){
      println(calendar.getTime());
      Event currentE = thisArtist.pastGigs.get(thisArtist.index);
      Event nextE = thisArtist.pastGigs.get(thisArtist.index+1);
      //ArrayList<Event> = currentE
      if(currentE.cal.getTimeInMillis()<=calendar.getTimeInMillis()){
        timeDiff = nextE.cal.getTimeInMillis() -currentE.cal.getTimeInMillis();
        float numInc = timeDiff/timeLapse;
        float x1 = (currentE.xcoord-westLimit)/1000;
        float y1 = (northLimit-currentE.ycoord)/1000;
        float x2 = (nextE.xcoord-westLimit)/1000;
        float y2 = (northLimit-nextE.ycoord)/1000;
        float xdiff = x2-x1;
        float ydiff = y2-y1;        
        strokeWeight(0.25);
        fill(thisArtist.r, thisArtist.g , thisArtist.b);      
      if((nextE.cal.getTimeInMillis()-currentE.cal.getTimeInMillis() <1296000000 )||(thisArtist.incrementer ==0)){//only draw if next gig is less than 15 days away or if incrementer=0 
        ellipse(x1+(thisArtist.incrementer*xdiff), y1+(thisArtist.incrementer*ydiff),   7,7);
      } 
         if (thisArtist.incrementer ==0){
           text(currentE.locationName, x1+(thisArtist.incrementer*xdiff), y1+(thisArtist.incrementer*ydiff));
              }        
      
        text(currentE.gigName + " " + currentE.locationName, 0, height-4);
            
        text(calendar.get(calendar.DAY_OF_MONTH)+ " - "+(calendar.get(calendar.MONTH)+1)+ " - "+calendar.get(calendar.YEAR)+ "   " + calendar.get(calendar.HOUR_OF_DAY)+ ":" + calendar.get(calendar.MINUTE) , 0, 20);
        thisArtist.incrementer = thisArtist.incrementer + (1/numInc);
            
        println(nextE.gigName + nextE.locationName + "          "+calendar.getTime());
      
      }
    }
  }
   saveFrame("imgfolder/" + "multipleArtists" + "/####.png");
   if(calendar.getTimeInMillis()>=endDate.getTimeInMillis()) {
         noLoop();
     }
       calendar.add(calendar.MILLISECOND, int(timeLapse));
}

 

class Event
{
    int id, venueSize, year, day, month;
    GregorianCalendar cal;
    float xcoord, ycoord ;
    String venueName, locationName, gigName;
    
}
  
  
class artistHistory
{
  String artistName;
  ArrayList<Event> pastGigs;
  float r,g,b;
  int index;
  float incrementer;//index keeps track of the which event currently displayed in the draw function; incrementer keeps track of movement between points
}


ArrayList loadPastGigs(String[] a){
    ArrayList gigArray = new ArrayList<artistHistory>();
    for(int i = 0; i < a.length; i++){ 
    artistHistory h = new artistHistory();
    h.artistName = a[i];
    h.index = 0;
    h.incrementer = 0;
   Table table = loadTable("tableinputsk/data/"+ a[i] + ".csv", "header");
    ArrayList g = new ArrayList<Event>();
      for(int j = 0; j < table.getRowCount(); j++) { 
        TableRow r = table.getRow(j);
        Event e = new Event();
         e.id = j;
         e.venueSize= r.getInt("venueSize");
         e.xcoord = r.getFloat("bng_E");
         e.ycoord = r.getFloat("bng_N");
         e.year = r.getInt("year");
         e.month = r.getInt("month"); 
         e.day = r.getInt("day");
         e.gigName = r.getString("gigName");
         e.locationName = r.getString("locationName");
         e.cal = new GregorianCalendar();
         e.cal.set(e.year, e.month-1,e.day,0,0,0);
         if(e.cal.getTimeInMillis()>=calendar.getTimeInMillis() && e.cal.getTimeInMillis()<=endDate.getTimeInMillis()){ //only add events between start date and end date
         g.add(e);
         }
      }
    h.pastGigs = g; //adds an arraylist of events to an artist history
    h.r = reds[i];
    h.g = greens[i];
    h.b = blues[i];
    gigArray.add(h); //adds an artisthistory to the total arraylist of artists' past gigs
    }

    return gigArray;
  }

  
 
   


