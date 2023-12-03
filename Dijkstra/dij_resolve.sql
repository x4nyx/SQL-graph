DROP PROCEDURE IF EXISTS dijResolve;
DELIMITER |
CREATE PROCEDURE dijResolve( pFromNodeName VARCHAR(20), pToNodeName VARCHAR(20) )
BEGIN
  DECLARE vFromNodeID, vToNodeID, vNodeID, vCost, vPathID INT;
  DECLARE vFromNodeName, vToNodeName VARCHAR(20);
  UPDATE dijnodes SET PathID = NULL,Cost = NULL,Calculated = 0;
  SET vFromNodeID = ( SELECT NodeID FROM dijnodes WHERE NodeName = pFromNodeName );
  IF vFromNodeID IS NULL THEN
    SELECT CONCAT('From node name ', pFromNodeName, ' not found.' ); 
  ELSE
    BEGIN
      SET vNodeID = vFromNodeID;
      SET vToNodeID = ( SELECT NodeID FROM dijnodes WHERE NodeName = pToNodeName );
      IF vToNodeID IS NULL THEN
        SELECT CONCAT('From node name ', pToNodeName, ' not found.' );
      ELSE
        BEGIN
          UPDATE dijnodes SET Cost=0 WHERE NodeID = vFromNodeID;
          WHILE vNodeID IS NOT NULL DO
            BEGIN
              UPDATE 
                dijnodes AS src
                JOIN dijpaths AS paths ON paths.FromNodeID = src.NodeID
                JOIN dijnodes AS dest ON dest.NodeID = Paths.ToNodeID
              SET dest.Cost = CASE
                                WHEN dest.Cost IS NULL THEN src.Cost + Paths.Cost
                                WHEN src.Cost + Paths.Cost < dest.Cost THEN src.Cost + Paths.Cost
                                ELSE dest.Cost
                              END,
                  dest.PathID = Paths.PathID
              WHERE 
                src.NodeID = vNodeID
                AND (dest.Cost IS NULL OR src.Cost + Paths.Cost < dest.Cost)
                AND dest.Calculated = 0;
       
              UPDATE dijnodes SET Calculated = 1 WHERE NodeID = vNodeID;

              SET vNodeID = ( SELECT nodeID FROM dijnodes
                              WHERE Calculated = 0 AND Cost IS NOT NULL
                              ORDER BY Cost LIMIT 1
                            );
            END;
          END WHILE;
        END;
      END IF;
    END;
  END IF;
  IF EXISTS( SELECT 1 FROM dijnodes WHERE NodeID = vToNodeID AND Cost IS NULL ) THEN
    SELECT CONCAT( 'Node ',vNodeID, ' missed.' );
  ELSE
    BEGIN
      DROP TEMPORARY TABLE IF EXISTS map;
      CREATE TEMPORARY TABLE map (
        RowID INT PRIMARY KEY AUTO_INCREMENT,
        FromNodeName VARCHAR(20),
        ToNodeName VARCHAR(20),
        Cost INT
      ) ENGINE=MEMORY;
      WHILE vFromNodeID <> vToNodeID DO
        BEGIN
          SELECT 
            src.NodeName,dest.NodeName,dest.Cost,dest.PathID
            INTO vFromNodeName, vToNodeName, vCost, vPathID
          FROM 
            dijnodes AS dest
            JOIN dijpaths AS Paths ON Paths.PathID = dest.PathID
            JOIN dijnodes AS src ON src.NodeID = Paths.FromNodeID
          WHERE dest.NodeID = vToNodeID;
          
          INSERT INTO Map(FromNodeName,ToNodeName,Cost) VALUES(vFromNodeName,vToNodeName,vCost);
          
          SET vToNodeID = (SELECT FromNodeID FROM dijPaths WHERE PathID = vPathID);
        END;
      END WHILE;
      SELECT FromNodeName,ToNodeName,Cost FROM Map ORDER BY RowID DESC;
      DROP TEMPORARY TABLE Map;
    END;
  END IF;
END;
|
DELIMITER ;
