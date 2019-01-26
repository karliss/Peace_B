<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.2" tiledversion="1.2.1" name="common" tilewidth="32" tileheight="32" tilecount="64" columns="8">
 <image source="../images/tileset.png" width="256" height="256"/>
 <tile id="0" type="grass"/>
 <tile id="1" type="box"/>
 <tile id="2" type="wall"/>
 <tile id="3" type="floor"/>
 <tile id="4" type="carpet">
  <properties>
   <property name="carpet" type="bool" value="true"/>
   <property name="carpet_type" value="NORMAL"/>
  </properties>
 </tile>
 <tile id="5" type="main_carpet">
  <properties>
   <property name="carpet" type="bool" value="true"/>
   <property name="carpet_type" value="MAIN"/>
  </properties>
 </tile>
 <tile id="6" type="special_carpet">
  <properties>
   <property name="carpet" type="bool" value="true"/>
   <property name="carpet_type" value="SPECIAL"/>
  </properties>
 </tile>
 <tile id="12" type="carpet_folded">
  <properties>
   <property name="carpet_type" value="MAIN"/>
   <property name="folded_carpet" type="bool" value="true"/>
   <property name="unfolded_carpet" value="carpet"/>
  </properties>
 </tile>
 <tile id="13" type="main_carpet_folded">
  <properties>
   <property name="carpet_type" value="MAIN"/>
   <property name="folded_carpet" type="bool" value="true"/>
   <property name="unfolded_carpet" value="main_carpet"/>
  </properties>
 </tile>
 <tile id="14" type="special_carpet_folded">
  <properties>
   <property name="carpet_type" value="SPECIAL"/>
   <property name="folded_carpet" type="bool" value="true"/>
   <property name="unfolded_carpet" value="special_carpet"/>
  </properties>
 </tile>
</tileset>
