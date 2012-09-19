import controlP5.*;
import processing.net.*;
import omicronAPI.*;

ControlP5 cp5;
DropdownList d1;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int colCount;

PFont plotFont;


///////////////////////////////

ArrayList selectedCountries = new ArrayList();
ArrayList selectedRegions = new ArrayList();
ArrayList selectedDatasets = new ArrayList();

HashMap allDatasets = new HashMap();

ArrayList colorList = new ArrayList();

void setup() {
  size(1366, 768);

  loadDatasets();
  
  
  
  // Corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;

  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  cp5 = new ControlP5(this);
  d1 = cp5.addDropdownList("Country").setPosition(plotX1 + 50, plotY2 + 50);

  smooth();
}

void draw() {
  background(224);

  // Show the plot area as a white box  
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);

  strokeWeight(1);
  stroke(#5679C1);
  noFill();

  Iterator iter = selectedDatasets.iterator();
  while (iter.hasNext ()) {
    Dataset d = (Dataset)iter.next();
    displayGraph(d);
  }
}

void displayGraph(Dataset dataset) {
  drawTitle(dataset);
  drawAxisLabels(dataset);
  drawYearLabels(dataset);
  drawVolumeLabels(dataset);

  //if more than one dataset, see if 2 graphs have same yLabel -> if yes, show them both on one yaxis and a 3rd one, if available.
  //                                                           -> if no, show (any/first) 2. No support for more than 2.
  //if only 1, then display it!

  Dataset firstDataset = (Dataset)selectedDatasets.get(0);
  drawPoints(dataset);
  drawCurve(dataset);

  Dataset secondDataset = null;
  Dataset thirdDataset = null;

  if (selectedDatasets.size() > 1) {
    for (int i = 1; i < selectedDatasets.size(); i++) { //start from 2nd as 1st one is already displayed
      if (secondDataset == null || thirdDataset == null) { //look for more datasets only if 2nd and 3rd has not been found.
        if (firstDataset.getYLabel() == ((Dataset)selectedDatasets.get(i)).getYLabel()) {
          secondDataset = (Dataset)selectedDatasets.get(i);
        } 
        else {
          thirdDataset = (Dataset)selectedDatasets.get(i);
        }
      }
    }
//  } else if (selectedDatasets.size() == 1) {
//    drawPoints(firstDataset);
  } else if (selectedDatasets.size() < 1) {
    //please select a dataset!
  }//nothing to do if selectedDatasets.length == 1
  
  
  if(firstDataset != null && secondDataset != null){
    drawPointsOnSameAxis(firstDataset, secondDataset);
  } else if(firstDataset != null && thirdDataset != null){
    drawPointsOnDiffAxis(firstDataset, thirdDataset);
  }
  
}
void drawPointsOnSameAxis(Dataset firstDataset, Dataset secondDataset){
  
}
void drawPointsOnDiffAxis(Dataset firstDataset, Dataset thirdDataset){
  
}
void drawPoints(Dataset dataset){
  float[] dataRow;
  strokeWeight(4);
  
  for(int i = 0; i < selectedCountries.size(); i++){
    Country c = (Country)selectedCountries.get(i);
    dataRow = ((Country)dataset.getCountries().get(c.name)).getData();
    for (int col = 0; col < dataRow.length; col++) {
      if (!Float.isNaN(dataRow[col])) {
        float x = map(dataset.years[col], dataset.yearMin, dataset.yearMax, plotX1, plotX2);
        float y = map(dataRow[col], dataset.dataMin, dataset.dataMax, plotY2, plotY1);
        point(x, y);
      }
    }
  }
}
void drawCurve(Dataset dataset){
  noFill();
  strokeWeight(1);
  
  float firstCol = -1;
  float[] dataRow;
  
  int step = 0;
  
  for(int i = 0; i < selectedCountries.size(); i++){
    Country c = (Country)selectedCountries.get(i);
    dataRow = ((Country)dataset.getCountries().get(c.name)).getData();
    
    beginShape();
    
    for (int col = 0; col < dataRow.length; col++) {
      if (!Float.isNaN(dataRow[col])) {
        if(firstCol == -1){
          firstCol = col;
        }
        float x = map(dataset.years[col], dataset.yearMin, dataset.yearMax, plotX1, plotX2);
        float y = map(dataRow[col], dataset.dataMin, dataset.dataMax, plotY2, plotY1);
        
        curveVertex(x, y);
        // double the curve points for the start and stop
        if ((col == 0) || (col == firstCol) || (col == dataRow.length - 1)) {
          curveVertex(x, y);
        }
      }
    }
    endShape();
    
    //print country/region name
    textSize(15);
    textAlign(LEFT);
    text(c.name, plotX1 + 30, plotY1 + 30 + step);
    step += 20;
  }
}

void drawTitle(Dataset dataset) {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = dataset.getTitle();
  text(title, plotX1, plotY1 - 10);
}

void drawYearLabels(Dataset dataset) {
  fill(0);
  textSize(10);
  textAlign(CENTER, TOP);

  // Use thin, gray lines to draw the grid
  stroke(224);
  strokeWeight(1);

  colCount = dataset.colCount;
  
  for (int col = 0; col < colCount; col++) {
    if (dataset.years[col] % dataset.yearInterval == 0 || col == 0 || col == colCount-1) {
      float x = map(dataset.years[col], dataset.yearMin, dataset.yearMax, plotX1, plotX2);
      text(dataset.years[col], x, plotY2 + 5);
      line(x, plotY1, x, plotY2);
    }
  }
}

void drawAxisLabels(Dataset dataset) {
  fill(0);
  textSize(13);
  textLeading(15);

  textAlign(CENTER, CENTER);
  text(dataset.getYLabel(), labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
}

void drawVolumeLabels(Dataset dataset) {
  fill(0);
  textSize(10);
  textAlign(RIGHT);

  stroke(128);
  strokeWeight(1);

  for (float v = dataset.dataMin; v <= dataset.dataMax; v += dataset.volumeInterval) {
    if (v % dataset.volumeInterval == 0 || v == dataset.dataMax) {        // If a major tick mark
      float y = map(v, dataset.dataMin, dataset.dataMax, plotY2, plotY1);
      float textOffset = textAscent()/2;  // Center vertically
      if (v == dataset.dataMin) {
        textOffset = 0;                   // Align by the bottom
      } 
      else if (v == dataset.dataMax) {
        textOffset = textAscent();        // Align by the top
      }
      text(floor(v), plotX1 - 10, y + textOffset);
      line(plotX1 - 4, y, plotX1, y);     // Draw major tick
    }
  }
}

void loadDatasets() {
  Dataset dataset;

  dataset = new Dataset("Total_Primary_Energy_Consumption.tsv");
  dataset.setYLabel("Quadrillion\nBtu");
  allDatasets.put("totalConsumptionData", dataset); //0 to 178
  //  println(dataset.dataMin + " " + dataset.dataMax);
  selectedDatasets.add(dataset);
  selectedCountries.add(new Country("India"));
  selectedCountries.add(new Country("China"));

  dataset = new Dataset("Per_Capita_Total_Primary_Energy_Consumption.tsv");
  dataset.setYLabel("Million\nBtu\nper\nPerson");
  allDatasets.put("perCapitaConsumptionData", dataset); //0 to 3429 //reduce

  dataset = new Dataset("Total_Primary_Energy_Production.tsv");
  dataset.setYLabel("Quadrillion\nBtu");
  allDatasets.put("totalProductionData", dataset); //0 to 140

  dataset = new Dataset("Total_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy.tsv");
  dataset.setYLabel("Million\nMetric\nTons");
  allDatasets.put("totalCO2Data", dataset); // 0 to 14000 //doesnt display

  dataset = new Dataset("Per_Capita_Carbon_Dioxide_Emissions_from_the_Consumption_of_Energy.tsv");
  dataset.setYLabel("Metric\nTons\nof\nCarbon\nDioxide\nper\nPerson");
  allDatasets.put("perCapitaCO2Data", dataset); //0 to 267 //doesnt display

  dataset = new Dataset("Total_Renewable_Electricity_Net_Generation.tsv");
  dataset.setYLabel("Billion\nKilowatthours");
  allDatasets.put("totalElectricityData", dataset); //0 to 1020 //reduce
}

//void keyPressed() {
//  if (key == '[') {
//    currentRow--;
//    if (currentRow < 0) {
//      currentRow = rowCount - 1;
//    }
//  } 
//  else if (key == ']') {
//    currentRow++;
//    if (currentRow == rowCount) {
//      currentRow = 0;
//    }
//  } 
//  else if (key == 'j') {
//    currentGraph--;
//    if (currentGraph < 0) {
//      currentGraph = graphCount - 1;
//    }
//  } 
//  else if (key == 'k') {
//    currentGraph++;
//    if (currentGraph == graphCount) {
//      currentGraph = 0;
//    }
//  } 
//  else if (key == 't') { //show tabular format
//    //    currentGraph++;
//    //    if (currentGraph < 0) {
//    //      currentGraph = 0;
//    //    }
//  } 
//  else if (key == 'g') { //show graph
//    //    currentGraph++;
//    //    if (currentGraph == graphCount) {
//    //      currentGraph = 0;
//    //    }
//  } 
//  else if (key == 'a') {
//    currentRegion--;
//    if (currentRegion < 0) {
//      currentRegion = regionCount - 1;
//    }
//  } 
//  else if (key == 's') {
//    currentRegion++;
//    if (currentRegion == regionCount) {
//      currentRegion = 0;
//    }
//  }
//}

//////////////////////// TOUCH SUPPORT ////////////////////////////////////
/*void touchDown(int ID, float xPos, float yPos, float xWidth, float yWidth){
 //  noFill();
 //  stroke(255,0,0);
 //  ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
 
 if (yPos > tabTop && yPos < tabBottom) {
 for (int col = 0; col < columnCount; col++) {
 if (xPos > tabLeft[col] && xPos < tabRight[col]) {
 setCurrent(col);
 }
 }
 }
 }
 void touchMove(int ID, float xPos, float yPos, float xWidth, float yWidth){
 noFill();
 stroke(0,255,0);
 ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
 }
 void touchUp(int ID, float xPos, float yPos, float xWidth, float yWidth){
 noFill();
 stroke(0,0,255);
 ellipse( xPos, yPos, xWidth * 2, yWidth * 2 );
 }*/
