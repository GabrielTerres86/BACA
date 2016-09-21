/* .............................................................................

   Programa: Includes/var_faixas_ir.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Dezembro/2004.                  Ultima atualizacao:08/05/2007 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Definicao das variaveis utilizadas na rotina 
               fontes/saldo_rdca_resgate.p

   Alteracoes: 24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               08/05/2007 - Variaveis para o Rdc Pre (Magui)
............................................................................. */

DEF {1} SHARED VAR aux_dtrefajt     AS DATE FORMAT "99/99/9999"       NO-UNDO.

DEF {1} SHARED VAR aux_vlregpaj     AS DEC  DECIMALS 8                NO-UNDO.
        /* valor resgatado para ajuste */
DEF {1} SHARED VAR aux_vlrgtper     AS DEC  DECIMALS 8                NO-UNDO.
                   /* resgates realizados no periodo */
DEF {1} SHARED VAR aux_renrgper     AS DEC  DECIMALS 8                NO-UNDO.
                   /* rendimentos resgatados no periodo */
DEF {1} SHARED VAR aux_vlslajir     AS DEC  DECIMALS 8                NO-UNDO.
                   /* saldo utilizado para calculo do ajuste */
DEF {1} SHARED VAR aux_vlrenacu     AS DEC  DECIMALS 8                NO-UNDO.
                   /* rendimento acumulado para calculo do ajuste */ 
DEF {1} SHARED VAR aux_ttajtlct     AS DEC  DECIMALS 8                NO-UNDO.
                   /* total de ajuste apurados durante o periodo */
DEF {1} SHARED VAR aux_ttpercrg     AS DEC                            NO-UNDO.
                   /* total do percentual resgatado */
DEF {1} SHARED VAR aux_trergtaj     AS DEC  DECIMALS 8                NO-UNDO.
                   /* total do rendimento resgatado */
DEF {1} SHARED VAR aux_sldrgttt     AS DEC  DECIMALS 8                NO-UNDO.
                   /* saldo do resgate total */
        
DEF {1} SHARED VAR aux_sldpresg     AS DEC  DECIMALS 8                NO-UNDO.
DEF {1} SHARED VAR aux_vlrenper     AS DEC  DECIMALS 8                NO-UNDO.
DEF {1} SHARED VAR aux_nrctaapl     LIKE craprda.nrdconta             NO-UNDO.
DEF {1} SHARED VAR aux_nraplres     LIKE craprda.nraplica             NO-UNDO.
DEF {1} SHARED VAR aux_dtregapl     AS DATE FORMAT "99/99/9999"       NO-UNDO.    
DEF {1} SHARED VAR aux_vlsldapl     AS DEC  DECIMALS 8                NO-UNDO.
DEF {1} SHARED VAR aux_qtdfaxir     AS INT  FORMAT "z9"               NO-UNDO.
DEF {1} SHARED VAR aux_qtmestab     AS INTE EXTENT 99                 NO-UNDO. 
DEF {1} SHARED VAR aux_perirtab     AS DEC  EXTENT 99                 NO-UNDO.
DEF {1} SHARED VAR aux_cartaxas     AS INTE                           NO-UNDO.
DEF {1} SHARED VAR aux_vllidtab     AS CHAR                           NO-UNDO.

DEF {1} SHARED VAR aux_pcajsren     AS DEC                            NO-UNDO.
                   /* percentual do resgate sobre o rendimento acumulado */
DEF {1} SHARED VAR aux_vlrenreg     AS DEC  DECIMALS 8                NO-UNDO.
                   /* valor para calculo do ajuste*/
DEF {1} SHARED VAR aux_vldajtir     AS DEC  DECIMALS 8                NO-UNDO.
                   /* valor do ajuste do ir */
DEF {1} SHARED VAR aux_vlrdirrf     LIKE craplap.vllanmto             NO-UNDO.
                   /* valor do irrf sobre o rendimento */
                   
DEF {1} SHARED VAR aux_nrmeses      AS INTE                           NO-UNDO.
DEF {1} SHARED VAR aux_nrdias       AS INTE                           NO-UNDO.
DEF {1} SHARED VAR aux_dtiniapl     AS DATE FORMAT "99/99/9999"       NO-UNDO.
DEF {1} SHARED VAR aux_cdhisren     LIKE craplap.cdhistor             NO-UNDO.
DEF {1} SHARED VAR aux_cdhisajt     LIKE craplap.cdhistor             NO-UNDO.
DEF {1} SHARED VAR aux_perirapl     AS DEC                            NO-UNDO.
DEF {1} SHARED VAR aux_vlr_abono_ir AS DEC                            NO-UNDO.

DEF {1} SHARED VAR aux_doctoajt     LIKE craplap.nrdocmto             NO-UNDO.

ASSIGN aux_vllidtab = ""
       aux_qtdfaxir = 0
       aux_qtmestab = 0
       aux_perirtab = 0.
       
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND   
                   craptab.cdempres = 0             AND
                   craptab.tptabela = "CONFIG"      AND   
                   craptab.cdacesso = "PERCIRRDCA"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.
                       
DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
   ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
          aux_qtdfaxir = aux_qtdfaxir + 1
          aux_qtmestab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
          aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
END.                 

/* ..........................................................................*/

