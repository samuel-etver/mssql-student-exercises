
DROP TABLE IF EXISTS #A, tDealRelation
GO


CREATE TABLE #A (
	DealID NUMERIC(15,0),
	ParentCnt INT DEFAULT 0,
	ChildCnt INT DEFAULT 0
)
GO


CREATE TABLE tDealRelation (
  DealRelationID NUMERIC(15,0),
  RelType TINYINT,
  ParentID NUMERIC(15,0),
  ChildID NUMERIC(15,0)
)
GO


CREATE INDEX XIE2tDealRelation ON tDealRelation (RelType, ChildID)
CREATE INDEX XIE3DealRelation ON tDealRelation (ParentID, ChildID)
CREATE INDEX XIE4tDealRelation ON tDealRelation (ChildID, RelType, ParentID)
CREATE UNIQUE INDEX XPKtDealRelation ON tDealRelation (RelType, ParentID, ChildID)
GO


INSERT INTO #A (DealID) VALUES
  (106), (107), (108), (109)
GO


INSERT INTO tDealRelation (DealRelationID, RelType, ParentID, ChildID) VALUES
  (1001, 2, 101, 103),
  (1002, 2, 102, 105),
  (1003, 2, 103, 106),
  (1004, 2, 104, 107),
  (1005, 2, 105, 108),
  (1006, 2, 106, 110),
  (1007, 2, 107, 111),
  (1008, 2, 111, 112)
GO


CREATE OR ALTER FUNCTION CalcParentCnt(@DealID NUMERIC(15,0))
RETURNS INT
AS
BEGIN
  DECLARE @Result int;

  WITH CalcCnt(Cnt, Id) AS (
    SELECT 1 AS Cnt, ParentID AS Id
	FROM tDealRelation AS t WITH (INDEX = XIE2tDealRelation)
	WHERE t.RelType = 2 AND t.ChildID = @DealID

	UNION ALL

	SELECT f.Cnt + 1, ParentID 
	FROM CalcCnt f, tDealRelation AS t WITH (INDEX = XIE2tDealRelation)
	WHERE t.RelType = 2 AND f.Id = t.ChildID
  )
  SELECT @Result = Cnt FROM CalcCnt

  RETURN ISNULL(@Result, 0)
END
GO


CREATE OR ALTER FUNCTION CalcChildCnt(@DealID NUMERIC(15,0))
RETURNS INT
AS
BEGIN
  DECLARE @Result int;

  WITH CalcCnt(Cnt, Id) AS (
    SELECT 1 AS Cnt, ChildID AS Id
	FROM tDealRelation AS t WITH (INDEX = XIE3DealRelation)
	WHERE t.RelType = 2 AND t.ParentID = @DealID

	UNION ALL

	SELECT f.Cnt + 1, ChildID 
	FROM CalcCnt f, tDealRelation AS t WITH (INDEX = XIE3DealRelation)
	WHERE t.RelType = 2 AND f.Id = t.ParentID
  )
  SELECT @Result = Cnt FROM CalcCnt

  RETURN ISNULL(@Result, 0)
END
GO


UPDATE o
SET o.ParentCnt = dbo.CalcParentCnt(o.DealID), o.ChildCnt = dbo.CalcChildCnt(o.DealID)
FROM #A o


SELECT * FROM #A
