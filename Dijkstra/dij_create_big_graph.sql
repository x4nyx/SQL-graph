DROP PROCEDURE IF EXISTS FillGraph;
DELIMITER |
CREATE PROCEDURE FillGraph (IN VergesCount INT, IN NodesCount INT, IN MaxWeight INT)
BEGIN
  DECLARE p1 INT;
  DECLARE p2 INT;
  DECLARE w INT;

  WHILE VergesCount > 0 DO
    SET p1 = CEILING(NodesCount * RAND());
    SET p2 = CEILING(NodesCount * RAND());
    SET w = CEILING(MaxWeight * RAND());

    CALL dijAddPath(p1, p2, w);
    SET VergesCount = VergesCount - 1;
  END WHILE;
END;
|
DELIMITER ;
