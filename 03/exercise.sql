
DROP TABLE IF EXISTS #Country
GO


CREATE TABLE #Country (
  CountryID NUMERIC(15,0),
  Name VARCHAR(160),
  CodeISO VARCHAR(10)
)
GO


INSERT INTO #Country (CountryID, Name, CodeISO) VALUES
  (3364, 'COSTA RICA', '188'),
  (3362, 'ANTIGUA AND BARBUDA', '028'),
  (3255, 'LATVIA', '428'),
  (3235, 'MOLDOVA, REPUBLIC OF', '498'),
  (3232, 'REUNION', '638'),
  (3237, 'GUATEMALA', '320')
GO


CREATE OR ALTER PROCEDURE Country_Change (@CountryID NUMERIC(15,0), 
                                          @Name VARCHAR(160), 
										  @CodeISO VARCHAR(10), 
										  @RetVal INT OUTPUT)
AS
BEGIN
  BEGIN TRY
    UPDATE o 
	SET o.Name = @Name, o.CodeISO = @CodeISO
	FROM #Country o
	WHERE o.CountryID = @CountryID

    SET @RetVal = 0
  END TRY

  BEGIN CATCH
    SET @RetVal = 1
  END CATCH
END
GO


CREATE OR ALTER PROCEDURE Log_Add (@CountryID NUMERIC(15,0),
                                   @RetVal INT OUTPUT)
AS
BEGIN  
  DECLARE @Msg VARCHAR(2048)
  SET @Msg = CONCAT('Update record for CountryID = ', CAST(@CountryID as VARCHAR(2048)))
  EXECUTE @RetVal = xp_logevent 60000, @Msg
END
GO


CREATE OR ALTER PROCEDURE Country_Edit(@RetVal INT OUTPUT)
AS
BEGIN
  SET @RetVal = 0

  DECLARE @CountryID NUMERIC(15,0)
  DECLARE CountryTableCursor CURSOR FOR
  SELECT CountryID
  FROM #Country c
  
  OPEN CountryTableCursor

  FETCH NEXT FROM CountryTableCursor INTO @CountryID
  WHILE @@FETCH_STATUS = 0 
  BEGIN
    EXECUTE Log_Add @CountryID, @RetVal OUTPUT
    if @RetVal <> 0 BREAK

    EXECUTE Country_Change @CountryID, 'Dreamland', '036', @RetVal OUTPUT
    IF @RetVal <> 0 BREAK

    FETCH NEXT FROM CountryTableCursor INTO @CountryID
  END

  CLOSE CountryTableCursor
  DEALLOCATE CountryTableCursor
END
GO


DECLARE @RetVal INT
EXECUTE Country_Edit @RetVal OUTPUT
GO


SELECT * FROM #Country
GO
