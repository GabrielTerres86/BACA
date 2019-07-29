/*
INC006010 - N�o est� apresentado a quantidade de dias no Cyber - BACA VOLTA
Algumas contas n�o baixadas, est�o com dtdpagto = null, por conta de uma libera��o do projeto de desconto de t�tulos
Foram ajustadas as contas em 2018, por�m faltaram algumas
Ana - 24/07/2019

--validando uma das contas ap�s atualiza��o -> dtdpagto deve ter informa��o
select cdcooper, a.nrdconta, a.nrctremp, dtmvtolt, dtdpagto, a.dtdbaixa, dtatufin
from crapcyb a where dtdbaixa IS NULL and cdorigem = 1 and dtprejuz is null and nrdconta = 141488 and cdcooper = 5

*/

BEGIN

  UPDATE CRAPCYB SET dtdpagto = NULL 
  WHERE  progress_recid in (1131291,995041,1153776,1085839,1211570,1129434,1191440,1209059,1217695,1169825,1170493,1190163,1170880);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
               
