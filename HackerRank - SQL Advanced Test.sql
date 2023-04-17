--Crypto Market Algorithm Report
SET NOCOUNT ON;

WITH Q1 AS (
    SELECT
        C.ALGORITHM
        , SUM(TR.VOLUME) AS VOLUMEN
    FROM 
        TRANSACTIONS TR
        JOIN COINS C ON TR.COIN_CODE = C.CODE
    WHERE 
        TR.DT >= '2020-01-01' AND TR.DT < '2020-04-01'
    GROUP BY 
        C.ALGORITHM
), 
Q2 AS (
    SELECT
        C.ALGORITHM
        , SUM(TR.VOLUME) AS VOLUMEN
    FROM 
        TRANSACTIONS TR
        JOIN COINS C ON TR.COIN_CODE = C.CODE
    WHERE
        TR.DT >= '2020-04-01' AND TR.DT < '2020-07-01'
    GROUP BY
        C.ALGORITHM
    
), 
Q3 AS (
    SELECT
        C.ALGORITHM
        , SUM(TR.VOLUME) AS VOLUMEN
    FROM 
        TRANSACTIONS TR
        JOIN COINS C ON TR.COIN_CODE = C.CODE
    WHERE 
        TR.DT >= '2020-07-01' AND TR.DT < '2020-10-01'
    GROUP BY
        C.ALGORITHM
),
Q4 AS (
    SELECT
        C.ALGORITHM
        , SUM(TR.VOLUME) AS VOLUMEN
    FROM 
        TRANSACTIONS TR
        JOIN COINS C ON TR.COIN_CODE = C.CODE
    WHERE 
        TR.DT >= '2020-10-01' AND TR.DT < '2021-01-01'
    GROUP BY
        C.ALGORITHM
)
SELECT
    Q1.ALGORITHM
    , SUM(Q1.VOLUMEN)
    , SUM(Q2.VOLUMEN)
    , SUM(Q3.VOLUMEN)
    , SUM(Q4.VOLUMEN)
FROM
    Q1
    JOIN Q2 ON Q1.ALGORITHM = Q2.ALGORITHM
    JOIN Q3 ON Q1.ALGORITHM = Q3.ALGORITHM
    JOIN Q4 ON Q1.ALGORITHM = Q4.ALGORITHM
GROUP BY 
    Q1.ALGORITHM

--Winners Chart
SET NOCOUNT ON;

WITH parcial AS (
    SELECT 
        event_id
        , participant_name
        , MAX(score) AS maximo
        , DENSE_RANK() OVER(PARTITION BY event_id ORDER BY MAX(score) DESC) AS Rango
    FROM scoretable
    GROUP BY 
        event_id
        , participant_name)
SELECT
    event_id
    , STRING_AGG(CASE WHEN Rango = 1 THEN participant_name END, ',') WITHIN GROUP (ORDER BY participant_name ASC) AS first
    , STRING_AGG(CASE WHEN Rango = 2 THEN participant_name END, ',') WITHIN GROUP (ORDER BY participant_name ASC) AS second
    , STRING_AGG(CASE WHEN Rango = 3 THEN participant_name END, ',') WITHIN GROUP (ORDER BY participant_name ASC) AS third
FROM parcial
GROUP BY 
    event_id

go