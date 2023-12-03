DROP TABLE IF EXISTS dijnodes,dijpaths;
CREATE TABLE dijnodes (
  nodeID int PRIMARY KEY AUTO_INCREMENT NOT NULL,
  nodename varchar (20) NOT NULL,
  cost int NULL,
  pathID int NULL,
  calculated tinyint NOT NULL 
);

CREATE TABLE dijpaths (
  pathID int PRIMARY KEY AUTO_INCREMENT,
  fromNodeID int NOT NULL ,
  toNodeID int NOT NULL ,
  cost int NOT NULL
);

DROP PROCEDURE IF EXISTS dijAddPath;
DELIMITER |
CREATE PROCEDURE dijAddPath( 
  pFromNodeName VARCHAR(20), pToNodeName VARCHAR(20), pCost INT 
)
BEGIN
  DECLARE vFromNodeID, vToNodeID, vPathID INT;
  SET vFromNodeID = ( SELECT NodeID FROM dijnodes WHERE NodeName = pFromNodeName );
  IF vFromNodeID IS NULL THEN
    BEGIN
      INSERT INTO dijnodes (NodeName,Calculated) VALUES (pFromNodeName,0);
      SET vFromNodeID = LAST_INSERT_ID();
    END;
  END IF;
  SET vToNodeID = ( SELECT NodeID FROM dijnodes WHERE NodeName = pToNodeName );
  IF vToNodeID IS NULL THEN
    BEGIN
      INSERT INTO dijnodes(NodeName, Calculated) 
      VALUES(pToNodeName,0);
      SET vToNodeID = LAST_INSERT_ID();
    END;
  END IF;
  SET vPathID = ( SELECT PathID FROM dijpaths 
                  WHERE FromNodeID = vFromNodeID AND ToNodeID = vToNodeID 
                );
  IF vPathID IS NULL THEN
    INSERT INTO dijpaths(FromNodeID,ToNodeID,Cost) 
    VALUES(vFromNodeID,vToNodeID,pCost);
  ELSE
    UPDATE dijpaths SET Cost = pCost  
    WHERE FromNodeID = vFromNodeID AND ToNodeID = vToNodeID;
  END IF;
END; 
|
DELIMITER ;
