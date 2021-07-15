/*..............................................................................

    Programa: baca_adesaomassaddacredcrea.p
    Sistema : Internet - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jose Dill - Mouts
    Data    : Junho/2021
  
    Objetivo  : Adesão em massa de DDA - RITM0143031   
							
..............................................................................*/

CREATE WIDGET-POOL.    

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/b1wgen0078tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i  }


DEFINE TEMP-TABLE tt-contas NO-UNDO 
    FIELD nrdconta LIKE crapass.nrdconta.

DEF  VAR aux_cdcooper AS INTE                           NO-UNDO.
DEF  VAR aux_cdagenci AS INTE                           NO-UNDO.
DEF  VAR aux_nrdcaixa AS INTE                           NO-UNDO.
DEF  VAR aux_cdoperad AS CHAR                           NO-UNDO.
DEF  VAR aux_nmdatela AS CHAR                           NO-UNDO.
DEF  VAR aux_idorigem AS INTE                           NO-UNDO.
DEF  VAR aux_nrdconta AS INTE                           NO-UNDO.
DEF  VAR aux_idseqttl AS INTE                           NO-UNDO.
DEF  VAR aux_dtmvtolt AS DATE                           NO-UNDO.
DEF  VAR aux_flgerlog AS LOGI                           NO-UNDO.
DEF  VAR aux_flmobile AS INTE                           NO-UNDO.

DEF VAR h-b1wgen0078 AS HANDLE                          NO-UNDO.

DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                           NO-UNDO.

PROCEDURE executa-adesao-dda:

   EMPTY TEMP-TABLE tt-erro.
   
   FOR EACH tt-contas NO-LOCK:						  
  
    ASSIGN aux_nrdconta = tt-contas.nrdconta.
    ASSIGN aux_dtmvtolt = TODAY.

	RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

	IF  NOT VALID-HANDLE(h-b1wgen0078)  THEN
		DO:
			ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0078.".
					
			RETURN "NOK".
		END.

	RUN aderir-sacado IN h-b1wgen0078 (INPUT 7,          /*aux_cdcooper,*/
									   INPUT 90,         /*aux_cdagenci*/
									   INPUT 900,        /*aux_nrdcaixa*/
									   INPUT "996",      /*aux_cdoperad*/
									   INPUT "INTERNETBANK", /*aux_nmdatela,*/
									   INPUT 3,          /*aux_idorigem,*/
									   INPUT aux_nrdconta,
									   INPUT 1,          /*aux_idseqttl,*/
									   INPUT aux_dtmvtolt,
									   INPUT TRUE,
									   INPUT 0,          /*aux_flmobile,*/
									  OUTPUT TABLE tt-erro).
	DELETE PROCEDURE h-b1wgen0078.

	EMPTY TEMP-TABLE tt-erro.	

   END.   
   RETURN "OK".
END PROCEDURE.

PROCEDURE cria-temp-table:

CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100625.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100838.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 100986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101052.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101842.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 101982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 102997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 103993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 104990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106879.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107506.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107948.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 109991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110876.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 111988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113506.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116041.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116114.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116831.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 116998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117625.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 117994.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118028.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 118990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 119989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122025.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122289.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123757.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123838.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123994.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124028.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124397.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126128.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126861.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 126993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130028.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130842.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131385.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132136.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133353.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13528.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136484.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139289.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139556.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139963.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 140961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141275.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141666.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141879.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 141984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142948.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 143952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145963.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146528.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 149934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 150991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151114.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151289.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151556.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 151947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152757.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152935.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 152978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153362.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 154970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163651.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163864.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1651.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165948.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 166960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168041.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168181.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 168955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169463.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169935.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 169951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 170810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 172928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 173991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174777.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 174998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 175986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176052.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179876.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 182419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 182451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 182494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185353.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1864.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187666.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 187968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 188999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 189979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190128.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190764.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19275.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193275.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193879.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 196169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19666.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198463.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198838.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199826.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20028.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200484.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20087.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 200999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 201804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 202991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203734.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203777.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 203980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 204870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 205958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210528.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210757.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210838.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212385.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 216992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217506.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 217980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 220990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22136.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2220059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2220067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2220105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 222941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223115.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 223964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 224987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2267.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 227994.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228397.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228737.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 228990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 229970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 230960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 231924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232181.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232831.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 232963.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233463.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 233986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234362.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 234990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236861.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240362.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242128.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242764.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244414.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244864.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 245801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 247987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 248983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 249980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252506.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252557.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255114.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255831.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257761.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257826.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261041.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261963.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263028.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263737.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26948.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269484.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271764.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271861.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272353.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272876.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281506.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284181.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284734.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286087.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28681.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286826.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29734.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298557.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303879.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30414.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304484.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310948.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315737.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315761.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315826.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318353.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319325.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 31968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321397.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325414.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 32913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331651.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331864.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332275.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333387.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333484.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333557.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336025.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336181.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336289.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336556.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336963.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337935.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338362.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338842.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 33979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341126.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345385.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34681.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346861.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 34983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350303.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350397.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35041.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355666.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35602.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361186.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362867.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365025.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365734.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36625.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366463.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37052.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370681.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37737.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378666.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379557.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38407.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384879.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393703.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394025.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40649.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40657.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 40983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41831.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 42919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43338.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43826.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43842.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44385.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 44997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45136.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 45985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46876.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47651.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47759.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4855.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48666.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49484.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49557.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50466.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51136.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 516830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 516880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51764.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52353.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52876.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53473.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53996.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54151.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54275.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56391.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5690.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57215.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5746.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57606.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58289.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58319.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58556.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58777.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 5908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59625.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60496.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60577.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60879.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61506.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61603.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61697.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62073.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63584.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64025.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64777.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 65994.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66761.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 66982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67148.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67253.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67385.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6831.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6963.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69949.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69965.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70289.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7072.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70904.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70939.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71404.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71625.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71684.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71773.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71811.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71935.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72087.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72362.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72478.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72486.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72575.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72591.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72788.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72923.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72931.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73059.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74128.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7501.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75132.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7579.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76414.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76651.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77038.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77046.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77208.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77275.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77305.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77399.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77437.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77445.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77488.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77658.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77704.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77798.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78417.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78638.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78735.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79006.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79456.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80004.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80128.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80136.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80268.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80497.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80632.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80977.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 80985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81191.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81337.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81442.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81876.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82627.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8281.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82945.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83143.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83526.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83615.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83623.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83682.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83852.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83887.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 83992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84093.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84115.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8419.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84409.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84816.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84859.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84905.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 84972.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85103.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85154.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85375.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85529.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85936.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86002.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86029.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86444.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8702.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87041.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87157.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8737.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87394.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87416.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87521.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8761.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87831.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87874.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87947.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87955.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88013.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88099.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88137.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8818.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88323.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8842.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88498.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88528.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88617.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88757.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89044.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89052.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89125.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89362.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89370.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89656.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89834.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89893.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9008.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90115.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90174.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90190.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90352.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90395.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90492.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90611.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90646.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90948.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90999.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91111.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91162.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91367.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 914.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91464.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91596.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91758.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91928.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92142.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92185.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92282.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9229.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9237.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92452.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92487.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92525.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92592.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92924.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92932.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92983.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93033.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93122.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93181.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93203.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93220.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93424.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93459.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93556.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93564.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93637.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93645.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9377.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93858.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94048.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94153.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94196.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94234.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94277.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94285.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94315.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94358.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94366.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94471.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94625.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94641.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94765.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94781.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94919.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94935.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95087.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95095.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95133.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95273.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95311.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95354.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95427.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95516.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95524.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95583.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95621.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95672.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9571.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95710.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95729.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95737.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95745.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95761.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95826.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95842.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95966.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95974.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95982.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96032.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96075.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96091.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96156.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9628.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96288.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96334.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96423.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96555.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96652.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96741.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96873.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97136.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97152.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9717.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97292.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97306.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97560.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97616.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97667.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97748.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97764.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97772.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97845.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97861.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97896.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97942.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98051.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98078.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98167.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98493.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98590.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98655.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98787.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98809.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98957.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98981.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99007.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99066.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99171.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99309.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99406.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99503.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9954.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99651.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9989.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99902.

VALIDATE tt-contas.
END PROCEDURE.

RUN cria-temp-table.

RUN executa-adesao-dda.

RETURN "OK".

/*............................................................................*/


