//Represents the data in a given dataset.
//Same as the 'graph' shown at a time?

class Dataset {
  
  String title;
  String yLabel;
  float[][] allData;
  
  HashMap countries;
  HashMap regions;
  float[] worldData; //is this necessary?
  
  String[] regionNames = {"North America", "Central & South America", 
    "Europe", "Eurasia", "Middle East", "Asia & Oceania", "Africa", "World"};
  
  int rowCount = 0;
  int colCount = 0;
  int[] years;
  String[] rowNames;
  
  int yearMin, yearMax;
  float dataMin = 0, dataMax;
  
  int yearInterval = 5;
  int volumeInterval = 10;
  
  Dataset(String filename){
    String[] rows = loadStrings(filename);
    this.title = rows[0];
    String[] cols = split(rows[1], TAB);
    years = parseInt(subset(cols, 1)); // upper-left corner ignored

    colCount = years.length;
    rowNames = new String[rows.length-1];
    allData = new float[rows.length-1][];
    
    countries = new HashMap();
    regions = new HashMap();
    
    // start reading at row 2, because the first row has the title
    // and second has the column headers
    for (int i = 2; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }
      // split the row on the tabs
      String[] pieces = split(rows[i], TAB);
      scrubQuotes(pieces);
      
      for(int j = 0; j < regionNames.length; j++){
        if(pieces[0] == regionNames[j]){
          Region region = new Region(pieces[0]);
          region.data = parseFloat(subset(pieces, 1));
          
          regions.put(pieces[0], region);
        } else {
          Country country = new Country(pieces[0]);
          country.data = parseFloat(subset(pieces, 1));
          
          countries.put(pieces[0], country);
        }
        rowNames[rowCount] = pieces[0];
        allData[rowCount] = parseFloat(subset(pieces, 1));
      }
      
      rowCount++;
    }
    dataMin = getTableMin();
    dataMax = getTableMax();
    yearMin = years[0];
    yearMax = years[years.length-1];
  }
  
  float getTableMin() {
    float m = Float.MAX_VALUE;
    for (int row = 0; row < rowCount - 1; row++) { //skip entry for World
      for (int col = 0; col < colCount; col++) {
        if (isValid(row, col)) {
          if (allData[row][col] < m) {
            m = allData[row][col];
          }
        }
      }
    }
    return m;
  }
  float getTableMax() {
    float m = -Float.MAX_VALUE;
    for (int row = 0; row < rowCount - 1; row++) { //skip entry for World
      for (int col = 0; col < colCount; col++) {
        if (isValid(row, col)) {
          if (allData[row][col] > m) {
            m = allData[row][col];
          }
        }
      }
    }
    return m;
  }
  
  String getTitle(){
    return this.title;
  }
  void setYLabel(String yLabel){
    this.yLabel = yLabel;
  }
  String getYLabel(){
    return this.yLabel;
  }
  HashMap getCountries(){
    return this.countries;
  }
  HashMap getRegions(){
    return this.regions;
  }
  
  boolean isValid(int row, int col) {
    if (row < 0 || col < 0) return false;
    if (row >= rowCount) return false;
    if (col >= allData[row].length) return false;

    return !Float.isNaN(allData[row][col]);
  }
  
  void scrubQuotes(String[] array) {
    for (int i = 0; i < array.length; i++) {
      if (array[i].length() > 2) {
        // remove quotes at start and end, if present
        if (array[i].startsWith("\"") && array[i].endsWith("\"")) {
          array[i] = array[i].substring(1, array[i].length() - 1);
        }
      }
      // make double quotes into single quotes
      array[i] = array[i].replaceAll("\"\"", "\"");
    }
  }
}
