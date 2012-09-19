class Region{
  String name;
  float[] data;
  float[][] countryData;
  ArrayList countries;
  
  Region(String name){
    this.name = name;
  }
  
  void drawDataPoints(){
    
  }
  
  void drawDataCurve(){
    
  }
  
  String getName(){
    return name;
  }
  
  float[] getData(){
    return data;
  }
  
  float[][] getCountryData(){
    return countryData;
  }
  
  void setData(float[] data){
    this.data = data;
  }
  
  void setCountryData(float[][] data){
    countryData = data;
  }
}
