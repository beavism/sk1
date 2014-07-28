
import com.reades.mapthing.*;
import net.divbyzero.gpx.*;
import net.divbyzero.gpx.parser.*;
import java.util.*;
ArrayList<artistHistory> gigography;
//int venueCap;
//String apikey = "IwmU9loDtmISJyc5";
//String artistID = "118093";
String[] artists = {"Kasabian", "ArcticMonkeys", "TheLibertines"};
float[] reds = {175, 255,255};
float[] greens = {238,160,255};
float[] blues = {238,122,224};
int startYear = 2003;
int startMonth = 8;
int startDay = 1;
int endYear = 2006;
int endMonth = 10;
int endDay = 30;
GregorianCalendar calendar = new GregorianCalendar();
GregorianCalendar endDate = new GregorianCalendar();
int modifier = 45;
int scaler = 1;
long timeDiff = 0;
float tIncrement = 0;
long timeLapse = 14400000;//ms of calendar time per frame 2 hour per frame )   
int numArtists = 2;
BoundingBox box = new BoundingBox(62 ,  2, 49,  -11) ;
Polygons basemap;
//PShape mapBox;


void setup()
{
  size(10*modifier, 12*modifier);
   //size(640*scaler,480*scaler);
          //mapBox = createShape(RECT, 160, 0, 480, height);
  basemap  = new Polygons(box, dataPath("uk.shp"));
 basemap.setLocalSimplificationThreshold(0.01d);
 

   calendar.set(startYear, startMonth-1, startDay,0,0,0);
  endDate.set(endYear, endMonth-1, endDay,0,0,0);
  gigography = loadPastGigs(artists);
  //frameRate(100);
  background(0, 0,0);

  //image(backgroundMap, 0, 0, width, height);

}
 
void draw(){
 // fill(255,255,255,50);
  //println(frameRate);
  noFill();
  stroke(255,255,255,50);
  strokeWeight(.25);
   basemap.project(this);
        noStroke();
        fill(0,0, 0, 3);
      //  shape(mapBox,400,240);
        rect(160,0,width,height); //fading rectangle
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
        float x1 = (9 + currentE.xcoord)*modifier;
        float y1 = (61 - currentE.ycoord)*modifier;
        float x2 = (9 + nextE.xcoord)*modifier;
        float y2 = (61 - nextE.ycoord)*modifier;
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
         e.xcoord = r.getFloat("xcoord");
         e.ycoord = r.getFloat("ycoord");
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

  
 
   


