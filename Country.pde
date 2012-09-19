class Country {
  String name;
  float[] data;
  
  Country(String name){
    this.name = name;
  }
  
  
  
  void displayDataCurve(){
    
  }
  
  boolean validData(int col) {
    return !Float.isNaN(data[col]);
  }
  
  String getName(){
    return name;
  }
  
  void setData(float[] data){
    this.data = data;
  }
  
  float[] getData(){
    return data;
  }
}
