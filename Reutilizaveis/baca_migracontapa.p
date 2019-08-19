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
         par_dtmvtolt = DATE('27/09/2018')
         par_cddopcao = 'A'
         par_tpevento = 'A'
         par_flgcreca = FALSE
         par_cdtipcta = 11
         par_cdsitdct = 1
         par_cdsecext = 999
         par_tpextcta = 0
         par_cdagepac = 8
         par_cdbcochq = 85
         par_flgiddep = FALSE
         par_tpavsdeb = 0
         par_dtcnsscr = ?
         par_dtcnsspc = ?
         par_dtdsdspc = ?
         par_inadimpl = 0
         par_inlbacen = 0
         par_flgexclu = FALSE
         par_flgrestr = FALSE
         par_indserma = FALSE
         par_idastcjt = 0
         par_cdcatego = 2.

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
  ASSIGN tt-contas.nrdconta = 1171.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2674.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 4944.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6106.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6289.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 6319.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 7196.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11142.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11240.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11444.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11479.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11517.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11835.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12122.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 12599.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13560.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13838.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 13870.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14010.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14427.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 14907.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15075.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15660.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15679.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 15989.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 16071.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 17647.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 18821.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20575.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20729.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20753.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 20982.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21377.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21385.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21407.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 21539.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22136.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22152.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22179.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22225.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22284.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22330.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22535.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22640.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22713.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22810.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22829.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22950.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 22977.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23124.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 23388.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24325.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24422.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 24864.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 25186.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 30112.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 36510.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37273.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37443.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37540.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37710.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 37729.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38610.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 38733.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39284.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 39900.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41319.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 41327.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 53422.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57061.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57282.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57410.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57789.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57843.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57878.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 57924.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58050.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 58610.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59188.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59390.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59404.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59862.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 59986.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 60640.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61310.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61344.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 61360.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 63282.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71650.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 71854.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72095.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72214.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72397.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72435.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72494.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72605.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72613.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72885.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 72931.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73083.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 73091.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 75841.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 76929.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77801.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77810.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 77828.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78093.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78590.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78697.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 78743.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79286.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 79294.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87513.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87580.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 87785.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88102.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88200.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88382.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88676.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88757.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88811.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 88994.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89028.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89257.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89281.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 89303.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 90891.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 91626.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92169.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92215.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92363.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92657.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92932.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92940.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92959.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 92975.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93009.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93025.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93050.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93157.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93459.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93513.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93530.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93793.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 93920.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94102.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94188.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94226.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94234.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 94390.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 95575.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97128.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 97349.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 98507.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105112.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105457.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 105694.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106194.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106291.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 106852.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107069.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107344.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107352.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107638.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107689.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107697.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107867.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107913.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 107930.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108014.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108030.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 108073.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110051.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110434.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110540.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110574.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110604.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110710.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110760.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110779.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110795.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 110957.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120219.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120286.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120324.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120499.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120596.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120618.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120685.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120715.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120782.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 120855.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121010.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121118.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121231.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121533.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 121908.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122092.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122610.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 122912.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123064.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123420.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123447.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123560.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123641.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123781.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123790.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123870.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 123960.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124028.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124036.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124087.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124141.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124257.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124281.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124362.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124486.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 124516.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125261.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 125318.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127108.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127248.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 127345.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128295.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128309.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128376.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128449.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128457.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 128503.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130052.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130184.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130320.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130630.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130907.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130915.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130940.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 130990.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131296.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 131741.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 132519.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135046.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135062.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 135160.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 142395.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144070.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144100.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144150.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144223.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144290.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144304.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144371.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144410.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144428.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144452.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144460.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144487.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144509.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144517.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144568.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144614.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144649.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144665.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 144703.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145351.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145483.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145629.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145718.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 145980.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146102.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146234.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146404.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146528.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146625.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146714.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146722.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 146773.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147290.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147753.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 147761.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148261.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148296.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148393.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 148466.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 153338.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156035.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156116.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156132.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156175.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156248.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156361.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156370.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156574.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 156884.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 157058.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158755.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158798.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 158879.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159271.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159409.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 159441.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160032.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160113.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160148.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160164.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160393.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160504.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160539.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160610.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 160792.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161241.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161365.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161381.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161438.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161527.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161535.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161551.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161837.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161918.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 161993.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162035.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162051.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162086.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162248.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162256.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162329.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162370.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162396.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162728.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162892.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162922.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 162930.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163031.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163139.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163244.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163295.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163317.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163449.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163465.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163597.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163716.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163759.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163775.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163872.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163902.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 163961.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171603.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171697.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 171980.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176150.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176508.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176532.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176664.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176753.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176761.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176818.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 176850.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177075.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177520.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177784.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 177830.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178047.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178110.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178152.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178160.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178276.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178284.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178292.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178640.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178730.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 178756.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179043.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179108.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179140.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179213.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179221.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179426.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179493.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179531.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179809.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 179965.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180157.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180327.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180351.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180394.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180637.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180645.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180726.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180742.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180750.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180882.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180904.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180920.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180955.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 180971.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 182656.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183571.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183580.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183644.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183806.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 183962.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 184047.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 185965.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191078.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191574.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191620.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 191639.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192627.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192732.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 192759.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194441.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194468.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 194670.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198030.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198110.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198366.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198382.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 198412.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199257.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199362.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 199370.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206083.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 206164.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207306.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207390.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 207993.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210048.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210234.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210269.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210617.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210765.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210773.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 210943.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211010.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211036.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211141.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211168.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211249.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211257.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211290.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211389.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211397.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 211605.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 225061.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235180.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235288.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235679.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235792.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235806.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 235822.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236365.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236373.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236390.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236462.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236500.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236896.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236918.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 236969.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237264.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237345.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237396.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237884.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 237922.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238163.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238309.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238422.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238619.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238678.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238767.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 238856.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239216.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239267.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239542.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239763.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239828.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239852.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 239887.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240540.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 240974.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241261.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241725.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241814.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 241989.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242071.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242187.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242195.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242381.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242454.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242489.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242551.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242632.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242675.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242713.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242756.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 242888.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243000.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243019.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243094.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243256.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243337.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243485.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243540.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243590.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243671.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 243710.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246220.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246387.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246425.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246530.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246590.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246735.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246751.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246778.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 246824.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252212.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252387.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252590.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252689.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252727.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 252778.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 254312.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255033.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255289.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255360.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255378.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255386.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255700.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255742.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255882.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255890.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 255912.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256080.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256510.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256528.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256587.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256781.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 256951.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257036.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257079.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257230.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257257.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257460.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257591.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257664.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257672.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257745.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 257990.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258202.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 258881.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259020.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259667.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259772.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 259853.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260118.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260169.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260185.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260266.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260282.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260290.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260312.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260380.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260452.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260584.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260606.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260657.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260690.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260770.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260797.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260878.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 260967.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261017.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261025.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261254.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261572.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261653.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261726.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261815.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 261980.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262102.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262137.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262170.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262331.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 262960.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263117.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 263532.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264792.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 264911.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 265535.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267252.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 267449.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 268275.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270679.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 270954.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 271748.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272264.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272523.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272710.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 272930.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273015.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 273732.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 274569.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275310.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 275409.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277355.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277681.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 277738.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278041.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278238.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278386.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278432.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 278734.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279340.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279404.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 279617.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280372.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 280992.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 281140.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282111.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282286.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 282421.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283436.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283460.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 283690.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284858.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 284904.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 285820.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286044.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 286320.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287466.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 287652.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288810.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 288977.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 290530.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291390.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 291900.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 292036.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293040.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293539.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 293911.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294020.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 294403.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295507.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 295728.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296112.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296244.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296414.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 296651.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297160.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 297216.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298328.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298379.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 298735.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299332.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 299456.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300047.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300543.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 300632.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301035.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 301531.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302228.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302546.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 302813.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303445.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 303666.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304247.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 304646.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305057.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305421.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 305804.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306010.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306142.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306320.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306525.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306711.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306738.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306746.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 306843.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307440.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307637.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 307971.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308455.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308501.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 308595.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309206.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309419.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309966.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 309990.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310026.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 310387.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 311529.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312215.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312509.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 312592.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313092.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 313491.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314080.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314358.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 314587.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315150.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315427.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315524.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315699.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 315877.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 316679.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317489.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 317845.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318230.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318450.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 318949.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319260.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319627.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319848.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 319929.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 320137.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 322342.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323071.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 323470.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324094.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324272.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324884.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 324922.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325155.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325171.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325210.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 325473.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326437.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 326852.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 327182.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 328901.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329061.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329070.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329096.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 329150.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 330043.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331228.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331236.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331392.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 331430.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332232.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 332917.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333395.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333484.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333778.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333875.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 333891.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334154.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334413.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334502.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 334740.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335320.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335584.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 335649.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 336645.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337161.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 337838.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338389.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 338486.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339091.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339547.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 339792.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340430.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340804.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 340910.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341592.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341770.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341843.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341860.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 341940.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342467.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 342823.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343064.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 343366.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344443.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344486.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 344796.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346209.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 346233.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347078.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347256.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347272.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347400.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 347493.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348007.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348066.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 348155.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349356.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349577.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 349879.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 350460.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 351865.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352020.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352560.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352640.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352721.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 352942.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 353752.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 354210.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355119.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355666.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 355860.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 356662.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357022.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 357715.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358029.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358096.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358290.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358568.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 358797.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 359360.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360040.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360090.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360155.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360163.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 360333.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361330.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 361810.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362263.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362425.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 362620.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363812.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 363960.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364142.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364274.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364479.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364495.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364509.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 364525.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365025.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365106.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365416.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365467.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 365831.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366188.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 366668.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 367001.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368008.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368032.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 368440.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 369845.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370045.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 370193.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371394.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371572.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 371874.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 372765.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374334.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 374342.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 375276.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 376736.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377031.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377074.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377473.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377511.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377520.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377546.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377597.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 377791.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 378445.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380105.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 380326.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381489.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 381870.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382051.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 382280.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383651.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 383708.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384062.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 384445.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385310.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 385689.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 386790.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 388092.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 389455.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 391140.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392812.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 392936.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 395501.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 399221.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 401137.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 401960.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 402656.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 403920.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 405710.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 405760.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 407305.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 409960.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410055.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410110.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 410411.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 414140.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 415413.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 415502.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 415618.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 416924.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417610.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 417831.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418714.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 418919.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 419427.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 419656.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 420484.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422185.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422312.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 422320.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 426105.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 427586.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 428760.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 428833.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 430072.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 431141.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 431656.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 434841.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 435589.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 435597.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 435937.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 436208.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 436380.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 437468.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 438430.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 441368.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 441520.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 445134.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 446521.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 446629.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 449644.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 453579.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 454133.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 454320.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 455210.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 457426.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 457582.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 459275.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 459682.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 460915.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 461466.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 1250027.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 2091062.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 11111127.
  CREATE tt-contas.
  ASSIGN tt-contas.nrdconta = 28000013.        

  VALIDATE tt-contas.

END PROCEDURE.