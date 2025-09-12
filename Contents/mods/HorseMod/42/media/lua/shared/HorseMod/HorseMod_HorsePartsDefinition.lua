AnimalPartsDefinitions = AnimalPartsDefinitions or {}
AnimalPartsDefinitions.animals = AnimalPartsDefinitions.animals or {}

-----------------------
----- ALL FILLIES -----
-----------------------
local fillyparts = {};
local fillybones = {};
local fillyxp = 10;

table.insert(fillyparts, {item = "Base.Steak", minNb = 10, maxNb = 18})
table.insert(fillyparts, {item = "Base.Beef", minNb = 10, maxNb = 18})
table.insert(fillyparts, {item = "Base.AnimalSinew", minNb = 3, maxNb = 7})

table.insert(fillybones, {item = "Base.AnimalBone", minNb = 10, maxNb = 18})

-----------------------
----- ALL HORSES ------
-----------------------
local horseparts = {};
local horsebones = {};
local horsexp = 15;

table.insert(horseparts, {item = "Base.Steak", minNb = 10, maxNb = 18})
table.insert(horseparts, {item = "Base.Beef", minNb = 10, maxNb = 18})
table.insert(horseparts, {item = "Base.AnimalSinew", minNb = 3, maxNb = 7})

table.insert(horsebones, {item = "Base.LargeAnimalBone", minNb = 10, maxNb = 18})


-----------------------------
----- AMERICAN QUARTER ------
-----------------------------

---- FILLY
local fillyamerican_quarter = AnimalPartsDefinitions.animals["fillyamerican_quarter"] or {};
fillyamerican_quarter.parts = fillyamerican_quarter.parts or horseparts;
fillyamerican_quarter.bones = fillyamerican_quarter.bones or fillybones;
fillyamerican_quarter.xpPerItem = fillyamerican_quarter.xpPerItem or fillyxp
AnimalPartsDefinitions.animals["fillyamerican_quarter"] = fillyamerican_quarter

---- MARE
local mareamerican_quarter = AnimalPartsDefinitions.animals["mareamerican_quarter"] or {};
mareamerican_quarter.parts = mareamerican_quarter.parts or horseparts;
mareamerican_quarter.bones = mareamerican_quarter.bones or horsebones;
mareamerican_quarter.xpPerItem = mareamerican_quarter.xpPerItem or horsexp
AnimalPartsDefinitions.animals["mareamerican_quarter"] = mareamerican_quarter

---- STALLION
local stallionamerican_quarter = AnimalPartsDefinitions.animals["stallionamerican_quarter"] or {};
stallionamerican_quarter.parts = stallionamerican_quarter.parts or horseparts;
stallionamerican_quarter.bones = stallionamerican_quarter.bones or horsebones;
stallionamerican_quarter.xpPerItem = stallionamerican_quarter.xpPerItem or horsexp
AnimalPartsDefinitions.animals["stallionamerican_quarter"] = stallionamerican_quarter

-----------------------------
----- AMERICAN QUARTER ------
-----------------------------

---- FILLY
local fillyamerican_paint = AnimalPartsDefinitions.animals["fillyamerican_paint"] or {};
fillyamerican_paint.parts = fillyamerican_paint.parts or horseparts;
fillyamerican_paint.bones = fillyamerican_paint.bones or fillybones;
fillyamerican_paint.xpPerItem = fillyamerican_paint.xpPerItem or fillyxp
AnimalPartsDefinitions.animals["fillyamerican_paint"] = fillyamerican_paint

---- MARE
local mareamerican_paint = AnimalPartsDefinitions.animals["mareamerican_paint"] or {};
mareamerican_paint.parts = mareamerican_paint.parts or horseparts;
mareamerican_paint.bones = mareamerican_paint.bones or horsebones;
mareamerican_paint.xpPerItem = mareamerican_paint.xpPerItem or horsexp
AnimalPartsDefinitions.animals["mareamerican_paint"] = mareamerican_paint

---- STALLION
local stallionamerican_paint = AnimalPartsDefinitions.animals["stallionamerican_paint"] or {};
stallionamerican_paint.parts = stallionamerican_paint.parts or horseparts;
stallionamerican_paint.bones = stallionamerican_paint.bones or horsebones;
stallionamerican_paint.xpPerItem = stallionamerican_paint.xpPerItem or horsexp
AnimalPartsDefinitions.animals["stallionamerican_paint"] = stallionamerican_paint

-----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- FILLY
local fillyappaloosa = AnimalPartsDefinitions.animals["fillyappaloosa"] or {};
fillyappaloosa.parts = fillyappaloosa.parts or horseparts;
fillyappaloosa.bones = fillyappaloosa.bones or fillybones;
fillyappaloosa.xpPerItem = fillyappaloosa.xpPerItem or fillyxp
AnimalPartsDefinitions.animals["fillyappaloosa"] = fillyappaloosa


-- MARE
local mareappaloosa = AnimalPartsDefinitions.animals["mareappaloosa"] or {};
mareappaloosa.parts = mareappaloosa.parts or horseparts;
mareappaloosa.bones = mareappaloosa.bones or horsebones;
mareappaloosa.xpPerItem = mareappaloosa.xpPerItem or horsexp
AnimalPartsDefinitions.animals["mareappaloosa"] = mareappaloosa

-- STALLION
local stallionappaloosa = AnimalPartsDefinitions.animals["stallionappaloosa"] or {};
stallionappaloosa.parts = stallionappaloosa.parts or horseparts;
stallionappaloosa.bones = stallionappaloosa.bones or horsebones;
stallionappaloosa.xpPerItem = stallionappaloosa.xpPerItem or horsexp
AnimalPartsDefinitions.animals["stallionappaloosa"] = stallionappaloosa

-----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
-- FILLY
local fillysteve_the_horse = AnimalPartsDefinitions.animals["fillysteve_the_horse"] or {};
fillysteve_the_horse.parts = fillysteve_the_horse.parts or horseparts;
fillysteve_the_horse.bones = fillysteve_the_horse.bones or fillybones;
fillysteve_the_horse.xpPerItem = fillysteve_the_horse.xpPerItem or fillyxp
AnimalPartsDefinitions.animals["fillysteve_the_horse"] = fillysteve_the_horse

-- MARE
local maresteve_the_horse = AnimalPartsDefinitions.animals["maresteve_the_horse"] or {};
maresteve_the_horse.parts = maresteve_the_horse.parts or horseparts;
maresteve_the_horse.bones = maresteve_the_horse.bones or horsebones;
maresteve_the_horse.xpPerItem = maresteve_the_horse.xpPerItem or horsexp
AnimalPartsDefinitions.animals["maresteve_the_horse"] = maresteve_the_horse
-- STALLION
local stallionsteve_the_horse = AnimalPartsDefinitions.animals["stallionsteve_the_horse"] or {};
stallionsteve_the_horse.parts = stallionsteve_the_horse.parts or horseparts;
stallionsteve_the_horse.bones = stallionsteve_the_horse.bones or horsebones;
stallionsteve_the_horse.xpPerItem = stallionsteve_the_horse.xpPerItem or horsexp
AnimalPartsDefinitions.animals["stallionsteve_the_horse"] = stallionsteve_the_horse