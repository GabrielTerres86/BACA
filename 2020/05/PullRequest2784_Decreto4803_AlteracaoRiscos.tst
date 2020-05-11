PL/SQL Developer Test script 3.0
36
/* Alteração de Risco Rating e Inclusão nas tabelas:
SELECT inrisco_inclusao, inrisco_rating                  FROM tbrisco_central_ocr; -- ??
SELECT dsnivris, dsnivori                                FROM crawepr;             -- ??
SELECT inrisco_inclusao, inrisco_rating, inorigem_rating FROM tbrisco_operacoes;   -- ??
SELECT innivris,inespecie FROM crapris;                                            -- ??
*/
DECLARE
  CURSOR cr_crapris IS
    SELECT r.cdcooper
           r.nrdconta
           r.nrctremp
      FROM crapris r
     WHERE r.dtrefere = '29/02/2020'
       AND r.cdmodali IN (299,499)
       AND EXIST (SELECT 1
                    FROM crapris ratr
                   WHERE ratr.dtrefere = '29/02/2020'
                     AND ratr.cdcooper = r.cdcooper
                     AND ratr.nrdconta = r.nrdconta
                     AND ratr.nrctremp = r.nrctremp
                     AND ratr.cdmodali IN (299,499)
                   GROUP BY ratr.cdcooper, ratr.nrdconta, ratr.nrctremp HAVING MAX(ratr.qtdiaatr) <= 14);
  rw_crapris cr_crapris%ROWTYPE;

  CURSOR cr_crapepr( IS
    SELECT e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
      FROM crapepr e
     WHERE e.dtmvtolt BETWENN '01/03/2020' AND '30/09/2020'
       AND e.inliquid = 0;

BEGIN
  NULL;
  
END;
0
0
