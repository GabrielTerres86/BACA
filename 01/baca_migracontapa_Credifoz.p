DEFINE TEMP-TABLE tt-contas NO-UNDO 
    FIELD nrdconta LIKE crapass.nrdconta.

{ sistema/generico/includes/var_internet.i}

DEF VAR par_cdcooper AS INTE                           NO-UNDO.
DEF VAR par_cdagenci AS INTE                           NO-UNDO.
DEF VAR par_nrdcaixa AS INTE                           NO-UNDO.
DEF VAR par_cdoperad AS CHAR                           NO-UNDO.
DEF VAR par_nmdatela AS CHAR                           NO-UNDO.
DEF VAR par_idorigem AS INTE                           NO-UNDO.
DEF VAR par_nrdconta AS INTE                           NO-UNDO.
DEF VAR par_idseqttl AS INTE                           NO-UNDO.
DEF VAR par_flgerlog AS LOG                            NO-UNDO.
DEF VAR par_nrdrowid AS ROWID                          NO-UNDO.
DEF VAR par_dtmvtolt AS DATE                           NO-UNDO.
DEF VAR par_cddopcao AS CHAR                           NO-UNDO.
DEF VAR par_tpevento AS CHAR                           NO-UNDO.
DEF VAR par_flgcreca AS LOG                            NO-UNDO.
DEF VAR par_cdtipcta AS INTE                           NO-UNDO.
DEF VAR par_cdsitdct AS INTE                           NO-UNDO.
DEF VAR par_cdsecext AS INTE                           NO-UNDO.
DEF VAR par_tpextcta AS INTE                           NO-UNDO.
DEF VAR par_cdagepac AS INTE                           NO-UNDO.
DEF VAR par_cdbcochq AS INTE                           NO-UNDO.
DEF VAR par_flgiddep AS LOG                            NO-UNDO.
DEF VAR par_tpavsdeb AS INTE                           NO-UNDO.
DEF VAR par_dtcnsscr AS DATE                           NO-UNDO.
DEF VAR par_dtcnsspc AS DATE                           NO-UNDO.
DEF VAR par_dtdsdspc AS DATE                           NO-UNDO.
DEF VAR par_inadimpl AS INTE                           NO-UNDO.
DEF VAR par_inlbacen AS INTE                           NO-UNDO.
DEF VAR par_flgexclu AS LOG                            NO-UNDO.
DEF VAR par_flgrestr AS LOG                            NO-UNDO.
DEF VAR par_indserma AS LOG                            NO-UNDO.
DEF VAR par_idastcjt AS INTE                           NO-UNDO.
DEF VAR par_cdcatego AS INTE                           NO-UNDO.

DEF VAR log_tpatlcad AS INTE                           NO-UNDO.
DEF VAR log_msgatcad AS CHAR                           NO-UNDO.
DEF VAR log_chavealt AS CHAR                           NO-UNDO.

DEF VAR h-b1wgen0074 AS HANDLE                         NO-UNDO.

RUN cria-temp-table.

IF  NOT VALID-HANDLE(h-b1wgen0074) THEN
    RUN /usr/coop/sistema/generico/procedures/b1wgen0074.p
        PERSISTENT SET h-b1wgen0074.

FOR EACH tt-contas NO-LOCK:

  /* Obtem os dados da conta para gerar a chamada da alteração de dados*/
  FIND FIRST crapass WHERE crapass.cdcooper = 11
                       AND crapass.nrdconta = tt-contas.nrdconta NO-LOCK NO-ERROR.

  /*Preenchimento dos parametros*/
  ASSIGN par_cdcooper = 11 /*contas CREDIFOZ*/
         par_cdagenci = 0
         par_nrdcaixa = 0
         par_cdoperad = '1'
         par_nmdatela = 'CONTAS'
         par_idorigem = 5
         par_nrdconta = tt-contas.nrdconta
         par_idseqttl = 1
         par_flgerlog = TRUE
         par_nrdrowid = ?
         par_dtmvtolt = TODAY
         par_cddopcao = 'A'
         par_tpevento = 'A'
         par_flgcreca = FALSE  
         par_cdtipcta = crapass.cdtipcta /* tipo da conta*/
         par_cdsitdct = crapass.cdsitdct
         par_cdsecext = crapass.cdsecext
         par_tpextcta = crapass.tpextcta
         par_cdagepac = 10 /* destino */
         par_cdbcochq = crapass.cdbcochq
         par_flgiddep = crapass.flgiddep
         par_tpavsdeb = crapass.tpavsdeb
         par_dtcnsscr = crapass.dtcnsscr
         par_dtcnsspc = crapass.dtcnsspc
         par_dtdsdspc = crapass.dtdsdspc
         par_inadimpl = crapass.inadimpl
         par_inlbacen = crapass.inlbacen
         par_flgexclu = FALSE  
         par_flgrestr = crapass.flgrestr
         par_indserma = crapass.indserma
         par_idastcjt = crapass.idastcjt
         par_cdcatego = crapass.cdcatego.

  RUN Grava_Dados 
   IN h-b1wgen0074 (INPUT par_cdcooper, 
                    INPUT par_cdagenci, 
                    INPUT par_nrdcaixa, 
                    INPUT par_cdoperad, 
                    INPUT par_nmdatela, 
                    INPUT par_idorigem, 
                    INPUT par_nrdconta, 
                    INPUT par_idseqttl, 
                    INPUT par_flgerlog, 
                    INPUT par_nrdrowid, 
                    INPUT par_dtmvtolt, 
                    INPUT par_cddopcao, 
                    INPUT par_tpevento, 
                    INPUT par_flgcreca, 
                    INPUT par_cdtipcta, 
                    INPUT par_cdsitdct, 
                    INPUT par_cdsecext, 
                    INPUT par_tpextcta, 
                    INPUT par_cdagepac, 
                    INPUT par_cdbcochq, 
                    INPUT par_flgiddep, 
                    INPUT par_tpavsdeb, 
                    INPUT par_dtcnsscr, 
                    INPUT par_dtcnsspc, 
                    INPUT par_dtdsdspc, 
                    INPUT par_inadimpl, 
                    INPUT par_inlbacen, 
                    INPUT par_flgexclu, 
                    INPUT par_flgrestr, 
                    INPUT par_indserma, 
                    INPUT par_idastcjt, 
                    INPUT par_cdcatego, 

                    OUTPUT log_tpatlcad,
                    OUTPUT log_msgatcad,
                    OUTPUT log_chavealt,
                    OUTPUT TABLE tt-erro).
      
END.    

IF  VALID-HANDLE(h-b1wgen0074) THEN
    DELETE OBJECT h-b1wgen0074.
    
PROCEDURE cria-temp-table:
 
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1813.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2631.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8648.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15997.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 35297.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36455.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47074.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49115.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49786.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 50911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 51519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52272.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55956.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58599.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70475.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81779.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81795.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81817.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92177.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92541.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94331.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95028.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95613.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95664.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95885.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95915.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96164.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112232.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113662.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114014.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114057.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114863.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115894.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129224.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 129844.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137286.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139866.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 155314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164097.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165727.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 165832.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167347.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167428.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167754.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167967.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167991.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 181897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190284.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191515.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192902.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193348.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193747.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 193933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194115.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195278.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195472.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 195995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212342.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213403.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213594.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 213985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214353.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 214833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215376.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215481.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215970.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 215988.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 218430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 219495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239429.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244147.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250139.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250449.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250538.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 250953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251127.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251356.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251518.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251534.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252875.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253022.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253774.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 253952.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254819.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254860.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 266922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267694.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 269573.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270547.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270695.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273546.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273767.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274917.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275433.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275557.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276197.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276421.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276537.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276545.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 276901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278556.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278661.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282766.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284726.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284998.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285854.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285943.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286699.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 289566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290114.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295922.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298166.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299502.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304522.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304689.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304794.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306258.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307165.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308439.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310182.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311812.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312916.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314706.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315494.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317055.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317381.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317950.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324582.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329339.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334634.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337978.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338559.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342750.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349283.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349984.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353477.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354163.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355933.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364630.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366803.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370401.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371025.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389986.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390089.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390291.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390674.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391891.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393517.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393614.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394483.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 396036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 399728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 402257.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 402508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 403369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 403598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 404900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 407178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 407569.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 411000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 411434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 411485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 413410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 413810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416878.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416908.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417246.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418412.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418587.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418927.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 419010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 419052.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 421383.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 421782.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 421901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422134.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422835.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423548.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 424102.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 428108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 429058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 430900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 431109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 431150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 431214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 431958.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 432067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 432245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 432806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 440892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 441643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 441678.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 443379.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 443425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 443476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 444790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 445886.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 447293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 448869.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 449261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 449296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 449601.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 450642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 453269.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 453374.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 453889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 454176.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 454206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 454222.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 454753.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 455431.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 455890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 456985.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 459330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 459720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 463361.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 464015.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 466514.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 892.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3077.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 3239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4405.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6785.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8001.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 8605.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9202.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 9946.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 10170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19895.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 19968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21776.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25593.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25607.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25925.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 26921.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27049.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27065.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27332.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27413.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27448.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27618.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27839.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 27995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28266.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28312.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28380.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28479.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28495.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28550.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28665.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28673.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28800.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28827.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29017.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29327.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29670.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29696.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 29793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36218.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36293.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36480.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39357.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 43400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 46698.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 47295.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 48992.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49085.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 49247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 52906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53864.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54321.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 54470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55344.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 55700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56138.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 56219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58823.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58912.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62235.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62359.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62588.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 62723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63193.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63231.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 64408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 67849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68144.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 68993.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69043.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 69884.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70254.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70386.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70440.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70467.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 70980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71226.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71242.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74179.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74209.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74411.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74837.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 74934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75060.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75418.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75485.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75728.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76058.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76244.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76252.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76368.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76686.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76953.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76961.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77119.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77216.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77372.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81523.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 81558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 82511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85510.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85561.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85669.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85847.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85898.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85979.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 85987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86088.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 86975.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87009.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87343.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95907.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96016.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96369.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 96792.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97586.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97691.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97756.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97780.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97888.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98388.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98604.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98868.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99180.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 99201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 112640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113026.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113271.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113310.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113336.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113883.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113913.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 113930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114081.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114090.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114723.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 114871.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115045.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115118.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115169.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115398.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115410.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 115622.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121290.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132039.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132217.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132373.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132730.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132853.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133019.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133299.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133396.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133426.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133671.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 133990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134023.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134392.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134511.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134848.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 134872.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135836.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135968.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136000.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136107.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136131.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136239.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136425.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 136824.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137227.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137251.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137499.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137650.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137707.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137715.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137731.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 137995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138207.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138304.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138355.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138711.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 138789.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139149.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139351.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139491.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139572.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139815.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139882.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 139980.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161020.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161071.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 164194.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 167096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183024.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183296.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183385.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183474.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183482.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183539.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183687.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183849.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184489.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184535.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184578.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184683.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185116.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185124.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185930.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185990.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186082.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186236.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186317.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186457.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 186724.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190128.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 190721.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207063.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207527.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207713.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207810.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207969.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208035.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208329.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208450.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208531.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208760.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 208850.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209198.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209279.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209350.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209384.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209430.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209589.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209600.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209635.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209708.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209716.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 209830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210145.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210846.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 212393.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 221422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 226610.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240079.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240117.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240389.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240435.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240532.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241644.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241679.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241768.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242926.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243086.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243833.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243906.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244104.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244201.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244333.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244422.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244490.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244570.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244732.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244830.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 244929.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 251763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254371.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254681.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255106.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255270.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255335.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255629.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255688.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255718.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256129.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256161.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256307.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256463.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256668.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256870.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257192.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257265.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257346.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257443.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258113.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258458.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258733.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258814.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258822.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258903.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259098.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259225.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259438.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259454.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261971.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265624.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268259.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270938.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271241.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271608.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271659.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271675.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272744.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273465.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273597.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273937.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274178.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274461.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274542.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275263.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277320.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278262.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279820.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280453.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280909.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281468.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281581.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282189.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282260.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282340.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283533.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283770.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286249.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286796.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286877.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287709.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287911.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288802.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291536.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293083.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293105.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295108.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295159.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295205.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295248.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297364.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297402.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299995.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300900.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301345.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304255.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304549.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304778.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305901.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305944.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307076.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307238.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308005.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308056.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308609.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309451.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310042.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311243.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311790.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311960.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313793.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315087.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316598.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316857.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316962.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318264.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318507.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319899.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320633.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320935.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321109.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321214.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 321567.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322261.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322512.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323349.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326828.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328685.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328740.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329940.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330027.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332801.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335436.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336092.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336769.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336777.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338168.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338460.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339865.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340219.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343447.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345210.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345415.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 345660.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347183.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347540.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347752.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349240.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349640.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349739.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349755.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351067.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351121.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351199.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351300.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351784.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352233.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352500.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353221.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353558.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353574.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356018.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356123.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356158.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356204.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357120.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358762.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359211.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360228.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360554.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361135.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362280.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362565.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363200.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363642.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368504.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370568.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371378.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371742.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372030.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372382.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372757.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373036.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373206.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 373761.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374172.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375160.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375314.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378054.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379212.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379751.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 379808.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380245.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381101.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381446.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381462.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381470.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381543.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381705.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381829.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382094.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382213.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382434.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382469.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382612.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382647.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382701.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383040.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383112.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383520.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383562.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383783.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384976.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385298.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387010.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387096.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387223.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387274.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387576.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387738.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 387959.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389170.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 390771.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391654.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392553.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392693.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 393509.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 394840.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395544.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395552.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395692.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395749.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395862.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 396230.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 397563.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 397806.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 398080.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 399175.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 400580.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 400807.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 401420.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 401889.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 403636.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 403725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 404330.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 404934.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 405302.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 405663.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 405680.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 405825.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 406155.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 406287.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 406619.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 406643.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 407313.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 408140.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 408328.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 408530.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 409146.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 409308.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 409987.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410012.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410047.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410195.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410551.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 411620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 411639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 411973.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 412031.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 412880.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 413003.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 413062.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 413763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414034.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414115.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414247.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414301.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414476.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414700.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414719.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414743.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 415294.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 415316.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 415677.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416100.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416797.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416851.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417130.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417173.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417513.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417653.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418188.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 419508.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 420069.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 421804.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422061.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423068.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423408.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423432.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 423505.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 424021.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 424064.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 424595.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 424714.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 424897.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 426318.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427110.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427276.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427322.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427365.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427519.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 428566.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 428736.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 428841.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 429791.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 429856.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 430250.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 430951.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 433799.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 434620.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 434639.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 435341.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 435910.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 436763.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 437360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 442941.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 443360.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 443441.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 443964.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 444324.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 446050.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 446084.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 447676.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 448141.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 448150.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 448184.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 449725.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 449890.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 450626.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 451037.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 451053.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 451363.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 451843.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 453390.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 453722.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 455326.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 455881.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 455920.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 456187.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 457256.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 457400.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 458775.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 458805.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 458821.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 459070.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 459585.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 462918.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 465011.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 465712.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 465720.
CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 465763.

  VALIDATE tt-contas.

END PROCEDURE.