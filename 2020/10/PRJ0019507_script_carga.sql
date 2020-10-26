INSERT INTO credito.TBCRED_RECIPROCIDADE
(cdcooper
,tpproduto
,cdcatego
,inpessoa
,cdoperad
,dtmvtolt)
SELECT 
  b.cdcooper
 ,0 -- tpproduto
 ,0 --cdcatego
 ,1 -- inpessoa fisica
 ,'1' --cdoperad
 ,TRUNC(SYSDATE)
FROM crapcop b
WHERE b.flgativo = 1;   

INSERT INTO credito.TBCRED_RECIPROCIDADE
(cdcooper
,tpproduto
,cdcatego
,inpessoa
,cdoperad
,dtmvtolt)
SELECT 
  b.cdcooper
 ,0 -- tpproduto
 ,0 --cdcatego
 ,2 -- inpessoa juridica
 ,'1' --cdoperad
 ,TRUNC(SYSDATE)
FROM crapcop b
WHERE b.flgativo = 1;   
			   
commit;
