

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
          TableRow r = table.addRow();

          r.setInt("id", index);
          r.setInt("venueSize", venueCap);
          r.setFloat("xcoord", longitude);
          r.setFloat("ycoord", latitude);
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

//sort table by date
//create a hour

