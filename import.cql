CREATE CONSTRAINT ON (n:Country) ASSERT n.ioc_code IS UNIQUE;
CREATE CONSTRAINT ON (n:Country) ASSERT n.iso_code IS UNIQUE;

CREATE CONSTRAINT ON (n:Games) ASSERT n.year IS UNIQUE;

CREATE CONSTRAINT ON (n:Sport) ASSERT n.name IS UNIQUE;
CREATE CONSTRAINT ON (n:Discipline) ASSERT n.name IS UNIQUE;
CREATE INDEX ON :Event(name);

CREATE CONSTRAINT ON (n:Athlete) ASSERT n.name IS UNIQUE;

CREATE INDEX ON :City(name);

MATCH (n) OPTIONAL MATCH n-[r]-() DELETE n, r;

// Country,Int Olympic Committee code,ISO code,Country
// Afghanistan,AFG,AF,Afghanistan

LOAD CSV WITH HEADERS FROM 'country_codes.csv' AS line
CREATE (country:Country {
    name: line.`Country`,
    ioc_code: line.`Int Olympic Committee code`,
    iso_code: line.`ISO code`
  });


// City,Edition,Sport,Discipline,Athlete,NOC,Gender,Event,Event_gender,Medal
// Athens,1896,Aquatics,Swimming,"HAJOS, Alfred",HUN,Men,100m freestyle,M,Gold



LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MERGE (games:Games {year: toInt(line.`Edition`), city: line.`City`});


LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MERGE (event:Event {name: line.`Event`, gender: line.`Gender`});

LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MERGE (sport:Sport {name: line.`Sport`});

LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MATCH (sport:Sport {name: line.`Sport`})
MERGE sport-[:HAS_DISCIPLINE]->(discipline:Discipline {name: line.`Discipline`});

LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MATCH (sport:Sport {name: line.`Sport`})-[:HAS_DISCIPLINE]->(discipline:Discipline {name: line.`Discipline`})
MERGE discipline-[:HAS_EVENT]->(event:Event {name: line.`Event`, gender: line.`Gender`})
;

LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MERGE (athlete:Athlete {name: line.`Athlete`});


LOAD CSV WITH HEADERS FROM 'medals.csv' AS line
MATCH (games:Games {year: toInt(line.`Edition`), city: line.`City`})
MATCH (sport:Sport {name: line.`Sport`})-[:HAS_DISCIPLINE]->(discipline:Discipline {name: line.`Discipline`})-[:HAS_EVENT]->(event:Event {name: line.`Event`, gender: line.`Gender`})
MATCH (athlete:Athlete {name: line.`Athlete`})

MERGE athlete-[:WON]->(medal:Medal {type: line.`Medal`})-[:FOR_EVENT]->event
MERGE medal-[:FOR_GAMES]->games
;

