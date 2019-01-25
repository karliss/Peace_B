<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.2" tiledversion="1.2.1" name="common" tilewidth="32" tileheight="32" tilecount="64" columns="8">
 <image source="../images/tileset.png" width="256" height="256"/>
 <tile id="0" type="grass">
  <properties>
   <property name="ground_layer" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="1" type="box">
  <properties>
   <property name="ground_level" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="2" type="wall">
  <properties>
   <property name="ground_level" type="bool" value="false"/>
  </properties>
 </tile>
 <tile id="3" type="floor">
  <properties>
   <property name="ground_level" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="4" type="carpet">
  <properties>
   <property name="ground_level" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="5" type="main_carpet">
  <properties>
   <property name="ground_level" type="bool" value="true"/>
  </properties>
 </tile>
 <tile id="6" type="special_carpet">
  <properties>
   <property name="ground_level" type="bool" value="true"/>
  </properties>
 </tile>
</tileset>
