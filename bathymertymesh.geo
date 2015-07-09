/*******************************************************
Maillage d'un canal avec une batymertie en tole ondulee

PINIER Benoit
Universite de Rennes 1
Copyright (C) 2015  PINIER Benoit

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
********************************************************/ 


/*************
  PARAMETRES *
*************/
// TAILLE DU MAILLAGE

Xmaxl = 2000;
Xmax = 1024.;
Ymax = 512.;
Zmax = 256.;


coarse = 1 ;
nbpts = 65;
period = 2;

resolutionX = 64./coarse;
resolutionY = 64./coarse;
resolutionZ = 64.0/coarse;

Amplitudeosc = 4;


zlimpts = 2;
lc = 100;
lcc = 50;

extension = 1;

/*****************
  FIN PARAMETRES *
*****************/

/**************************
// REALISATION DU MAILLAGE
***************************/

dx = Xmax / resolutionX;
dy = Ymax / resolutionY;
dz = Zmax / resolutionZ;

pts_fond = 0;

// Forme  du fond oscillant
 
For i In {0:resolutionX}
	For j In {0:resolutionY}
		Point(pts_fond) = {i*dx,j*dy,Amplitudeosc*Sin(2.*Pi*i*dx*period/Xmax)*Sin(2.*Pi*j*dy*period/Ymax),lc};
		pts_fond++;
		EndFor
EndFor

 

// Topography


// Spline entre les points

vertical_line = 0;  // ligne verticales 

For i In {0:resolutionX}
	For j In {0:resolutionY-1}
		Line(vertical_line) = {i*(resolutionY+1)+j,i*(resolutionY+1)+j+1};
		Transfinite Line{vertical_line} = 2;
		vertical_line++;
	EndFor
EndFor

Printf("%lf",vertical_line);

 
horizontal_line = vertical_line;
 
 

For i In {0:resolutionX-1}
	For j In {0:resolutionY}
		Line(horizontal_line) = {i*(resolutionY+1)+j,(i+1)*(resolutionY+1)+j};
		Transfinite Line{horizontal_line} = 2;
		horizontal_line++;
	EndFor
EndFor
 

// Line Loop et Surface


count_loop = 1;

For i In {0:resolutionX-1}
	For j In {0:resolutionY-1}
		k = i*resolutionY+j;
		Line Loop(k) = {k,vertical_line+i*(resolutionY+1)+j+1,-(k+resolutionY),-(vertical_line+i*(resolutionY+1)+j)};
		Plane Surface(k) = {k};
	EndFor
EndFor
 //--------------
// Cote Entree
 //--------------

/* Pour la premiere extrusion, il faut definir les deux points sommet
  supportant la surface */

Point(pts_fond+1) = {0,0,Zmax};
Line(horizontal_line+1) ={pts_fond+1,0};
Transfinite Line{horizontal_line+1} = nbpts;

entree_surf = k+1;
entree_pts = pts_fond+2;
entree_line = horizontal_line+2;

 
For i In {0:resolutionY-1}
	Point(entree_pts) = {0,(i+1)*dy,Zmax};
	Line(horizontal_line+2+2*i) = {pts_fond+1+i,pts_fond+2+i};
	Line(horizontal_line+3+2*i) = {pts_fond+2+i,i+1};

	Transfinite Line{horizontal_line+2+2*i} = 2;
	Transfinite Line{horizontal_line+3+2*i} = nbpts;

	
	Line Loop(entree_surf) = {i,-(horizontal_line+3+2*i),-(horizontal_line+2+2*i),(horizontal_line+1+2*i)};

	Plane Surface(entree_surf) = {entree_surf};
	If(i > 0)
	Transfinite Surface(entree_surf) = {i,i+1,pts_fond+1+i,pts_fond+2+i}; 
	EndIf
	entree_surf++;
	entree_pts++;
	entree_line = entree_line + 2;
EndFor
	//Transfinite Surface(k+1) = {0,1,pts_fond+1,pts_fond+2}; 


 //--------------
//Cote Ymin
 //--------------
ymin_pts = entree_pts;
ymin_surf = entree_surf;
ymin_line = entree_line;


// Cqs particulier du premier cas 

Point(ymin_pts) = {dx,0,Zmax};
Line(entree_line+1) = {resolutionY+1,ymin_pts};
Line(entree_line+2) = {ymin_pts,pts_fond+1};

Transfinite Line{entree_line+2} = 2;
Transfinite Line{entree_line+1} = nbpts;

Line Loop(ymin_surf) = {vertical_line,entree_line+1,entree_line+2,horizontal_line+1};

Plane Surface(ymin_surf) = {ymin_surf};
Transfinite Surface(ymin_surf) = {resolutionY+1,ymin_pts,pts_fond+1,0};
ymin_surf++;
ymin_pts++;
ymin_line = ymin_line + 2;

 

For i In {1:resolutionX-1}
	Point(ymin_pts) = {(i+1)*dx,0,Zmax};
	Line(entree_line+1+2*i) = {(i+1)*(resolutionY+1),ymin_pts};
	Line(entree_line+2+2*i) = {ymin_pts,ymin_pts-1};

	Transfinite Line{entree_line+2+2*i} = 2;
	Transfinite Line{entree_line+1+2*i} = nbpts;

	
	Line Loop(ymin_surf) = {vertical_line+(i)*(resolutionY+1),(entree_line+1+2*i),(entree_line+2+2*i),-(entree_line+2*i-1)};


	Plane Surface(ymin_surf) = {ymin_surf};

	Transfinite Surface(ymin_surf) = {(i+1)*(resolutionY+1),ymin_pts,ymin_pts-1,(i)*(resolutionY+1)}; 
	ymin_surf++;
	ymin_pts++;
	ymin_line = ymin_line + 2;
EndFor


 //--------------
//Cote Ymax
 //--------------
ymax_pts = ymin_pts;
ymax_surf = ymin_surf;
ymax_line = ymin_line;


// Cqs particulier du premier cas 

Point(ymax_pts) = {dx,Ymax,Zmax};
Line(ymin_line+1) = {2*resolutionY+1,ymax_pts};
Line(ymin_line+2) = {entree_pts-1,ymax_pts};
	
Transfinite Line{ymin_line+2} = 2;
Transfinite Line{ymin_line+1} = nbpts;

Line Loop(ymax_surf) = {vertical_line+resolutionY,ymin_line+1,-(ymin_line+2),entree_line-1};

Plane Surface(ymax_surf) = {ymax_surf};

Transfinite Surface(ymax_surf) = {2*resolutionY+1,resolutionY,ymin_pts,entree_pts-1}; 

ymax_surf++;
ymax_pts++;
ymax_line = ymin_line + 2;

Printf("%lf",ymax_surf);



For i In {1:resolutionX-1}
	Point(ymax_pts) = {(i+1)*dx,Ymax,Zmax};
	Line(ymin_line+1+2*i) = {(i+2)*(resolutionY+1)-1,ymax_pts};
	Line(ymin_line+2+2*i) = {ymax_pts-1,ymax_pts};
	
	Transfinite Line{ymin_line+2+2*i} = 2;
	Transfinite Line{ymin_line+1+2*i} = nbpts;

	Line Loop(ymax_surf) = {vertical_line+i+(i+1)*(resolutionY),(ymin_line+1+2*i),-(ymin_line+2+2*i),-(ymin_line+2*i-1)};
	Plane Surface(ymax_surf) = {ymax_surf};
	Transfinite Surface(ymax_surf) = {(i+2)*(resolutionY+1)-1,ymax_pts,ymax_pts-1,(i+1)*(resolutionY+1)-1}; 

 
	ymax_surf++;
	ymax_pts++;
	ymax_line = ymax_line + 2;
EndFor

  //--------------
  // Sortie
   //--------------


Printf(" yminline %lf ymaxline %lf entreeline %lf horizontal_line %lf countpts %lf",ymin_line,ymax_line,entree_line,horizontal_line,pts_fond);

sortie_line = ymax_line+1;
sortie_surf = ymax_surf;

Line(sortie_line) = {ymin_pts-1,ymax_pts-1}; 

Transfinite Line{sortie_line} = resolutionY+1;

If ( extension == 0 ) 

	Line Loop(sortie_surf) = {-sortie_line,-(ymin_line-1),vertical_line-resolutionY:vertical_line-1,ymax_line-1};
	Plane Surface(sortie_surf) = {sortie_surf};
	Transfinite Surface(sortie_surf) = {ymin_pts-1,ymax_pts-1,pts_fond-1,pts_fond-resolutionY-1};

EndIf


//--------------
// Surface
//--------------

surface_surf = sortie_surf+1;
Line Loop(surface_surf) = {horizontal_line+2:entree_line-2:2,ymin_line+2:ymax_line:2,-sortie_line,ymin_line:entree_line+2:-2};
Plane Surface(surface_surf) = {surface_surf};

Transfinite Surface(surface_surf) = {pts_fond+1,entree_pts-1,ymin_pts-1,ymax_pts-1};
 

// Partie Allongee


If ( extension > 0 ) 
	allong_line = sortie_line+1;

	countpts = ymax_pts;
	countloop = surface_surf;

	Point(countpts+9) = {Xmaxl,0,0,lcc};
	Point(countpts+10) = {Xmaxl,Ymax,0,lcc};
	Point(countpts+11) = {Xmaxl,0,Zmax,lcc};
	Point(countpts+12) = {Xmaxl,Ymax,Zmax,lcc};


	Line(allong_line) = {countpts+9,pts_fond-resolutionY-1};
	Line(allong_line+1) = {countpts+10,pts_fond-1};
	Line(allong_line+2) = {countpts+11,ymin_pts-1};
	Line(allong_line+3) = {countpts+12,ymax_pts-1};
	Line(allong_line+4) = {countpts+10,countpts+12};
	Line(allong_line+5) = {countpts+9,countpts+11};
	Line(allong_line+6) = {countpts+11,countpts+12};
	Line(allong_line+7) = {countpts+9,countpts+10};

	 
	Transfinite Line {allong_line+6} = 2;
	Transfinite Line {allong_line+7} = 2;
	Transfinite Line {allong_line+4} = 2;
	Transfinite Line {allong_line+5} = 2;
	/* Transfinite Line {allong_line+1} = nbpts;
	Transfinite Line {allong_line+2} = nbpts;
	Transfinite Line {allong_line+3} = nbpts;
	 */
	 
	 
	Line Loop(countloop+11) = {-(ymin_line-1),-(allong_line),allong_line+5,allong_line+2};  // Lateral Ymin
	Line Loop(countloop+12) = {allong_line+6,-(allong_line+4),-(allong_line+7),allong_line+5};  // Sortie
	Line Loop(countloop+13) = {-(ymax_line-1),-(allong_line+1),allong_line+4,allong_line+3};  // Lateral Ymax
	Line Loop(countloop+14) = {sortie_line,-(allong_line+3),-(allong_line+6),allong_line+2};  //Dessus
	Line Loop(countloop+15) = {-(allong_line+1),vertical_line-resolutionY:vertical_line-1,allong_line,-(allong_line+7)};  //Dessous


	Plane Surface (countloop+11) = {countloop+11};
	Plane Surface (countloop+12) = {countloop+12};
	Plane Surface (countloop+13) = {countloop+13};
	Plane Surface (countloop+14) = {countloop+14};
	Plane Surface (countloop+15) = {countloop+15};

	 
	 
	 
	Physical Surface(211) = {0:k,countloop+15};    // Fond 
	Physical Surface(205) = {ymin_surf:ymax_surf-1,countloop+13};  // Lateral Ymax
	Physical Surface(206) = {countloop+12};  // Sortie
	Physical Surface(208) = {entree_surf:ymin_surf-1,countloop+11};  // Lateral Ymin
	Physical Surface(209) = {k+1:entree_surf-1};//Entree
	Physical Surface(210) = {surface_surf,countloop+14};    // Dessus

	cs = surface_surf+1;
	 

	Compound Surface(cs+1) = {0:k};
	Transfinite Surface(cs+1) = {0,resolutionY,pts_fond-1,pts_fond-1-resolutionY};

	Surface Loop(1) = {cs+1,k+1: ymax_surf-1,surface_surf,countloop+11:countloop+15 };

EndIf
 
If ( extension == 0 ) 
	Physical Surface(211) = {0:k };    // Fond 
	Physical Surface(205) = {ymin_surf:ymax_surf-1 };  // Lateral Ymax
	Physical Surface(206) = {sortie_surf};  // Sortie
	Physical Surface(208) = {entree_surf:ymin_surf-1 };  // Lateral Ymin
	Physical Surface(209) = {k+1:entree_surf-1};//Entree
	Physical Surface(210) = {surface_surf };    // Dessus


	cs = surface_surf+1;
	 

	Compound Surface(cs+1) = {0:k};
	Transfinite Surface(cs+1) = {0,resolutionY,pts_fond-1,pts_fond-1-resolutionY};
	/*Compound Surface(cs+2) = {k+1:entree_surf-1};
	Compound Surface(cs+3) = {entree_surf:ymin_surf-1};
	Compound Surface(cs+4) = {ymin_surf:ymax_surf-1};
	 */
	Surface Loop(1) = {cs+1,k+1: ymax_surf-1,surface_surf,sortie_surf};


EndIf
 

Volume(10) = {1};
 


 
Mesh.RecombineAll = 1;
 
Coherence;
