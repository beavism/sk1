

String apikey = "IwmU9loDtmISJyc5";
String artistID = "175029";
String artistName = "Kasabian";
JSONObject resultsPage;
JSONArray events;
int venueCap;
String date;
String time;
String billing;
String headlineArtist;

String countryName = null;
Table table;
Table supportArtists;

void setup() {

  table = new Table();

  table.addColumn("id");
  table.addColumn("xcoord");
  table.addColumn("ycoord");
  table.addColumn("bng_N");
  table.addColumn("bng_E");
  table.addColumn("venueSize");
  table.addColumn("gigName");
  table.addColumn("locationName");
  table.addColumn("billing");
  table.addColumn("headlineArtist");
  table.addColumn("date");
  table.addColumn("year");
  table.addColumn("month");
  table.addColumn("day");
  table.addColumn("time");
  


  addData();


  saveTable(table, "data/" +artistName + ".csv");
}

void addData() {

  String url = "http://api.songkick.com/api/3.0/artists/" + artistID + "/gigography.json?apikey=" + apikey; 
  int pagenum = 1;
  int index = 0;

  boolean looping = true;
  resultsPage = loadJSONObject(url);
  int totalEntries = resultsPage.getJSONObject("resultsPage").getInt("totalEntries");

  while (looping) {    //loop running through all gig entries by page
    url+="&page="+pagenum;
    resultsPage = loadJSONObject(url);
    pagenum++;

    events = resultsPage.getJSONObject("resultsPage").getJSONObject("results").getJSONArray("event"); 


    for (int i = 0; i < events.size (); i++) { //runs through gigs on each page    
      int year = -1 ;
      int month = -1;
      int day = -1;
      if (!events.getJSONObject(i).getJSONObject("venue").isNull("id")) {
        int venueID = events.getJSONObject(i).getJSONObject("venue").getInt("id");
        JSONObject venue = loadJSONObject("http://api.songkick.com/api/3.0/venues/"+venueID+".json?apikey=" +apikey);
        if (!venue.getJSONObject("resultsPage").getJSONObject("results").getJSONObject("venue").isNull("capacity")) {
          venueCap = venue.getJSONObject("resultsPage").getJSONObject("results").getJSONObject("venue").getInt("capacity");
        } else {
          venueCap = -1;
        }
      }
      if (!events.getJSONObject(i).isNull("performance")) {
        boolean searchbilling= true;
        JSONArray performances = events.getJSONObject(i).getJSONArray("performance");
        int m = 0;
        while (searchbilling) {
          if (performances.getJSONObject(m).getString("billing").equals("headline")) {
            headlineArtist = performances.getJSONObject(m).getJSONObject("artist").getString("displayName");
          }
          if (performances.getJSONObject(m).getJSONObject("artist").getInt("id")==int(artistID)) {
            billing = performances.getJSONObject(m).getString("billing");
            if (billing.equals("headline")) {
              headlineArtist = null;
            }
          }

          if (performances.isNull(m+1)) {
            searchbilling = false;
            m = 0;
          }
          m++;
        }
      } else { 
        billing = null;
      }







      if (events.getJSONObject(i).getJSONObject("start").isNull("date")) {
        date = "null";
      } else {
        date= events.getJSONObject(i).getJSONObject("start").getString("date");
        String[] list = split(date, '-');
        year = int(list[0]); 
        month =int(list[1]); 
        day = int(list[2]);
      }
      if (events.getJSONObject(i).getJSONObject("start").isNull("time")) {  
        time = "null";
      } else {
        time= events.getJSONObject(i).getJSONObject("start").getString("time");
      }


      Boolean noLat = events.getJSONObject(i).getJSONObject("venue").isNull("lat"); //check to see if lat long are listed in entry
      Boolean noLng = events.getJSONObject(i).getJSONObject("venue").isNull("lng");
      Boolean noLocLat= events.getJSONObject(i).getJSONObject("location").isNull("lat");
      Boolean noLocLng= events.getJSONObject(i).getJSONObject("location").isNull("lng");
      float latitude=0;
      float longitude=0;

      if ((noLat == false && noLng == false)) {
        latitude = events.getJSONObject(i).getJSONObject("venue").getFloat("lat");
        longitude = events.getJSONObject(i).getJSONObject("venue").getFloat("lng");
      }
      if (noLat == true && noLocLat==false) {
        latitude = events.getJSONObject(i).getJSONObject("location").getFloat("lat");
        longitude = events.getJSONObject(i).getJSONObject("location").getFloat("lng");
        noLat = false;
        noLng = false;
      }

      Boolean noCountry = events.getJSONObject(i).getJSONObject("venue").getJSONObject("metroArea").getJSONObject("country").isNull("displayName");
      if (noCountry == false && (noLat == false && noLng == false)) { 
        String countryName = events.getJSONObject(i).getJSONObject("venue").getJSONObject("metroArea").getJSONObject("country").getString("displayName");
        Boolean noGigName = events.getJSONObject(i).isNull("displayName");
        Boolean noLocationName =  events.getJSONObject(i).getJSONObject("location").isNull("city");
        if (countryName.equals("UK")) {
          bngCoordinates bngc = lltobng(longitude, latitude);
          
          TableRow r = table.addRow();
      
          r.setInt("id", index);
          r.setInt("venueSize", venueCap);
          r.setFloat("xcoord", longitude);
          r.setFloat("ycoord", latitude);
          r.setFloat("bng_N", bngc.northing);
          r.setFloat("bng_E", bngc.easting);
          r.setString("date", date);
          r.setString("time", time);
          r.setInt("year", year);
          r.setInt("month", month);
          r.setInt("day", day);
          r.setString("gigName", "none");
          r.setString("locationName", "none");
          if (noGigName==false) { 
            r.setString("gigName", events.getJSONObject(i).getString("displayName"));
          } 
          if (noLocationName ==false) {
            r.setString("locationName", events.getJSONObject(i).getJSONObject("location").getString("city"));
          }

          index++;
          println(index + "," + venueCap + "," +events.getJSONObject(i).getString("displayName"));
        }
      }
    }
    if ((pagenum-1)*50 >= totalEntries) {
      looping = false;
    }
  }
}
bngCoordinates lltobng(float lam, float phi){ //lamda longitude, phi latitude
  
  lam= radians(lam);
  phi=radians(phi);
  float a = 6377563.396;       // OSGB semi-major axis
    float b = 6356256.91;        // OSGB semi-minor axis
    float e0 = 400000;           // OSGB easting of false origin
    float n0 = -100000;          // OSGB northing of false origin
   float f0 = 0.9996012717;     // OSGB scale factor on central meridian
    float e2 = 0.0066705397616;  // OSGB eccentricity squared
   float lam0 = -0.034906585039886591;  // OSGB false east
   float phi0 = 0.85521133347722145;    // OSGB false north
   float af0 = a*f0;
   float bf0 = b*f0;
  //easting
  float slat2 = sin(phi) * sin(phi);
  float nu = af0 / (sqrt(1 - (e2 * (slat2))));
  float rho = (nu * (1 - e2)) / (1 - (e2 * slat2));
  float eta2 = (nu / rho) - 1;
  float p = lam - lam0;
  float IV = nu * cos(phi);
  float clat3 = pow(cos(phi),3);
  float tlat2 = tan(phi) * tan(phi);
  float V = (nu / 6) * clat3 * ((nu / rho) - tlat2);
  float clat5 = pow(cos(phi), 5);
  float tlat4 = pow(tan(phi), 4);
  float VI = (nu / 120) * clat5 * ((5 - (18 * tlat2)) + tlat4 + (14 * eta2) - (58 * tlat2 * eta2));
   float east = e0 + (p * IV) + (pow(p, 3) * V) + (pow(p, 5) * VI);
  
  //northing
   float n = (af0 - bf0) / (af0 + bf0);
   float m = marc(bf0, n, phi0, phi);
   float I = m + (n0);
   float II = (nu / 2) * sin(phi) * cos(phi);
   float III = ((nu / 24) * sin(phi) * pow(cos(phi), 3)) * (5 - pow(tan(phi), 2) + (9 * eta2));
   float IIIA = ((nu / 720) * sin(phi) * clat5) * (61 - (58 * tlat2) + tlat4);
    float north = I + ((p * p) * II) + (pow(p, 4) * III) + (pow(p, 6) * IIIA);
   // east = Math.round(east);       // round to whole number
   // north = Math.round(north);     // round to whole number
   // nstr = String(north);      // convert to string
    //estr = String(east);       // ditto
    bngCoordinates returnCoords = new bngCoordinates();
    returnCoords.northing = north;
    returnCoords.easting = east;
    return returnCoords;
}
class bngCoordinates{
  float northing, easting;
}

float marc(float bf0, float n, float phi0, float phi)
  {
    float mrc = bf0 * (((1 + n + ((5 / 4) * (n * n)) + ((5 / 4) * (n * n * n))) * (phi - phi0))
     - (((3 * n) + (3 * (n * n)) + ((21 / 8) * (n * n * n))) * (sin(phi - phi0)) * (cos(phi + phi0)))
     + ((((15 / 8) * (n * n)) + ((15 / 8) * (n * n * n))) * (sin(2 * (phi - phi0))) * (cos(2 * (phi + phi0))))
     - (((35 / 24) * (n * n * n)) * (sin(3 * (phi - phi0))) * (cos(3 * (phi + phi0)))));
    return mrc;
  }

//sort table by date
//create a hour

