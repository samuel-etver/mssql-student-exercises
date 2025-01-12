
DROP TABLE IF EXISTS #OperPart
GO


CREATE TABLE #OperPart (
	OperationID NUMERIC(15,0),
	CharType INT,
	OperDate DATETIME,
	Qty NUMERIC(28,10),
	indatetime DATETIME,
	Rest NUMERIC(28,10)
)
GO


INSERT INTO #OperPart(OperationID, CharType, OperDate, Qty, indatetime, Rest)
VALUES (33581974000,  1, '20210820', 1000011.00, '20210820 13:10:25.700', 0),
       (33582024800, -1, '20210820', 1000011.11, '20210820 13:51:08.903', 0),
	   (33582208700,  1, '20210820', 825000.15,  '20210820 15:33:38.776', 0),
	   (33582407110, -1, '20210820', 825000.00,  '20210820 16:29:39.980', 0),
	   (33582408610,  1, '20210820', 1000011.00, '20210820 16:34:53.183', 0),
	   (33582419620, -1, '20210820', 1000011.00, '20210820 17:09:24.250', 0),
	   (33582519290,  1, '20210820', 15000.00,   '20210820 19:57:20.546', 0)
GO


DECLARE @Rest NUMERIC(28,10);
SET @Rest = 1000868.31;
DECLARE @FromDate DATETIME;
SET @FromDate = '20210820';

WITH Cte AS (SELECT OperationID, Qty,
  (SELECT @Rest + sum(CASE WHEN CharType =  1 THEN Qty
                           WHEN CharType = -1 THEN -Qty
				           ELSE 0 END)
   FROM #OperPart T2 where (T2.indatetime <= T1.indatetime)) AS sum1
FROM #OperPart T1)

UPDATE o
SET Rest = c.sum1
FROM #OperPart o
JOIN Cte c ON o.OperationID = c.OperationID
WHERE o.indatetime >= @FromDate
GO


SELECT * From #OperPart ORDER BY indatetime
  
