--Carga dos rows antigos

UPDATE crapbdt SET crapbdt.nrseqtdb = (SELECT COUNT(1) FROM craptdb WHERE crapbdt.nrborder=craptdb.nrborder AND crapbdt.cdcooper=craptdb.cdcooper AND crapbdt.nrdconta=craptdb.nrdconta);

MERGE
INTO    craptdb u
USING   (
SELECT  rowid AS rid,
ROW_NUMBER() OVER (PARTITION BY nrdconta,nrborder,cdcooper ORDER BY nrdconta,nrborder,cdcooper) AS rn
FROM    craptdb
)
ON      (u.rowid = rid)
WHEN MATCHED THEN
UPDATE
SET     nrtitulo = rn



-- Create/Recreate indexes 
create unique index CECRED.CRAPTDB##CRAPTDB8 on CECRED.CRAPTDB (CDCOOPER, NRBORDER, NRTITULO);

--exemplo de uso do index
SELECT 
  * 
FROM 
  tbdsct_lancamento_bordero t 
  INNER JOIN craptdb ON craptdb.cdcooper=t.cdcooper AND craptdb.nrborder=t.nrborder AND craptdb.nrtitulo=t.nrtitulo
  ;


