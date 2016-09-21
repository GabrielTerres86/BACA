/* ..........................................................................

   Programa: Fontes/crps121.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/95.                        Ultima atualizacao: 28/10/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 63
               Listar os relatorios de saldos apos o processo.

   Alteracoes: 15/01/97 - Alterado para tratar CPMF (Deborah).

               05/11/97 - Alterado para mostrar o saldo de saque p/FOLHA
                          (Deborah).

               10/11/97 - Alterado para tratar saque da folha atraves da rotina
                          sldfol.p (Odair)

               16/02/98 - Alterar a data final do CPMF (Odair)

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               26/06/98 - Alterado para NAO Tratar historico 289 (Edson).

               01/06/1999 - Tratar CPMF (Deborah). 

               08/01/2001 - Nao gerar pedido de impressao (Deborah).

               19/08/2002 - Incluir geracao de relatorio somente com
                            saldos negativos (Margarete).

               15/07/2003 - Inserido o codigo para verificar, apartir do tipo de
                            registro do cadastro de tabelas, com qual numero de
                            conta que se esta trabalhando. O numero sera 
                            armazenado na variavel aux_lsconta3 (Julio).
 
               22/10/2004 - Tratar conta de integracao (Margarete).

               10/11/2005 - Tratar campo cdcooper na leitura da talela
                            crapcor (Edson).

               09/12/2005 - Cheque salario nao existe mais (Magui).
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).
               
               24/06/2008 - Equivaler o relatorio crrl278 ao crrl007;
                          - Leitura da craphis com cdcooper (Evandro).
                          
               31/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               15/12/2008 - Copiar rel.278 para o diretorio /rlnsv (Gabriel).
               
               08/01/2010 - Alterado historico 311 para historico 313 (Elton). 
               
               16/01/2010 - Inclusao cheques CECRED no campo OBS referente
                            ao saldo devedor (Sandro-GATI)
                            
               13/05/2011 - Alterado layout do crrl278 (Gabriel).  
               
               26/05/2011 - Ajuste na listagem do crrl278 (Gabriel).
               
               06/12/2011 - Sustação provisória (André R./Supero).
               
               01/08/2013 - Alterado para pegar o telefone da tabela 
                            craptfc ao invés da crapass (James).
                            
               28/10/2013 - Alterado totalizador de 99 para 999. (Reinert)
                            
............................................................................. */

DEF STREAM str_1.  /*  Para relatorio geral de saldos  */
DEF STREAM str_2.  /*  Para relatorio com saldos negativos */

DEF        VAR rel_dsagenci     AS CHAR    FORMAT "x(21)"            NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nrseqage     AS INT     FORMAT "z9"               NO-UNDO.
DEF        VAR rel_dsdacstp     AS CHAR                              NO-UNDO.
DEF        VAR rel_nmprimtl     AS CHAR                              NO-UNDO.
DEF        VAR rel_vlsddisp     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlsdbloq     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlsdblpr     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlsdblfp     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlsdchsl     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlsdfolh     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_qtcompbb     AS INTEGER   FORMAT "zz9"            NO-UNDO.
DEF        VAR rel_vlcompbb     AS DECIMAL   FORMAT "zz,zz9.99"      NO-UNDO.
DEF        VAR rel_qtcmpbcb     AS INTEGER   FORMAT "zz9"            NO-UNDO.
DEF        VAR rel_vlcmpbcb     AS DECIMAL   FORMAT "zz,zz9.99"      NO-UNDO.
DEF        VAR rel_qtcmpctl     AS INTEGER   FORMAT "zz9"            NO-UNDO.
DEF        VAR rel_vlcmpctl     AS DECIMAL   FORMAT "zz,zz9.99"      NO-UNDO.
DEF        VAR rel_vlsaqmax     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlsdbltl     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_vlstotal     AS DECIMAL                           NO-UNDO.
DEF        VAR rel_dtmvtolt     AS DATE                              NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tot_nmresage AS CHAR    INIT "TOTAIS ==>"             NO-UNDO.
DEF        VAR tot_agpsdmax AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agpsddis AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agpvllim AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agpsdbtl AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agpsdchs AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agpsdstl AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_qtcstdct AS INTEGER EXTENT 999                    NO-UNDO.
DEF        VAR tot_vlcstdct AS DECIMAL EXTENT 999                    NO-UNDO.


DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgmensa AS LOGICAL     INIT TRUE                 NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR      FORMAT "x(18)"              NO-UNDO.
DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF        VAR aux_nrdofone AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgespec AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgimprm AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgnegat AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmarqneg AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmresage AS CHAR    EXTENT 999                    NO-UNDO.
DEF        VAR aux_flgnegcb AS LOGICAL                               NO-UNDO.
DEF        VAR rel_vlestour AS DECIMAL                               NO-UNDO.

DEF        VAR tot_agnsddis AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agnvllim AS DECIMAL EXTENT 999                    NO-UNDO.
DEF        VAR tot_agnsdbtl AS DECIMAL EXTENT 999                    NO-UNDO.

DEF        VAR ger_agnsddis AS DECIMAL                               NO-UNDO.
DEF        VAR ger_agnvllim AS DECIMAL                               NO-UNDO.
DEF        VAR ger_agnsdbtl AS DECIMAL                               NO-UNDO.
DEF        VAR ger_qtcstdct AS INTEGER                               NO-UNDO.
DEF        VAR ger_vlcstdct AS DECIMAL                               NO-UNDO.

DEF        VAR jur_agnsddis AS DECIMAL                               NO-UNDO.
DEF        VAR jur_agnvllim AS DECIMAL                               NO-UNDO.
DEF        VAR jur_agnsdbtl AS DECIMAL                               NO-UNDO.
DEF        VAR jur_agnsdstl AS DECIMAL                               NO-UNDO.

DEF        VAR adm_agnsddis AS DECIMAL                               NO-UNDO.
DEF        VAR adm_agnvllim AS DECIMAL                               NO-UNDO.
DEF        VAR adm_agnsdbtl AS DECIMAL                               NO-UNDO.
DEF        VAR adm_agnsdstl AS DECIMAL                               NO-UNDO.

DEF        VAR crl_agnsddis AS DECIMAL                               NO-UNDO.
DEF        VAR crl_agnvllim AS DECIMAL                               NO-UNDO.
DEF        VAR crl_agnsdbtl AS DECIMAL                               NO-UNDO.
DEF        VAR crl_agnsdstl AS DECIMAL                               NO-UNDO.

DEF        VAR aux_lsconta3 AS CHAR                                  NO-UNDO.
/**** Variavies do proc_conta_integracao ****/
DEF VAR aux_ctpsqitg LIKE craplcm.nrdctabb                           NO-UNDO.
DEF VAR aux_nrdctitg LIKE crapass.nrdctitg                           NO-UNDO.
DEF VAR aux_nrdigitg AS CHAR FORMAT "x(01)"                          NO-UNDO.
DEF VAR aux_nrctaass AS INTE FORMAT "zzzz,zzz,9"                     NO-UNDO.
DEF VAR aux_nrmaxpas AS INTE                                         NO-UNDO.
DEF BUFFER crabass5 FOR crapass.

{ includes/var_batch.i }
{ includes/var_atenda.i "new" }
{ includes/var_cpmf.i } 
{ includes/proc_conta_integracao.i }

FOR LAST crapage FIELDS (cdagenci)
                 WHERE crapage.cdcooper = glb_cdcooper
                 NO-LOCK
                 BY crapage.cdagenci:

    ASSIGN aux_nrmaxpas = crapage.cdagenci.

END.

DEFINE TEMP-TABLE crat007 NO-UNDO
       FIELD cdagenci  AS INTE
       FIELD nmresage  AS CHAR
       FIELD nrdconta  AS INTE
       FIELD nrdofone  AS CHAR
       FIELD qtddsdev  AS INTE
       FIELD vlsddisp  AS DECI
       FIELD vllimcre  AS DECI
       FIELD vlestour  AS DECI
       FIELD nmprimtl  AS CHAR
       FIELD vlsdbltl  AS DECI
       FIELD qtcmptot  AS INTE FORMAT "zzz9"
       FIELD vlcmptot  AS DECI FORMAT "zzz,zz9.99"
       FIELD qtcstdct  AS INTE 
       FIELD vlcstdct  AS DECI
       FIELD obsdisp2  AS CHAR INIT "_______________" 
       INDEX crat007_1 AS PRIMARY cdagenci nrdconta.

FIND FIRST crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.


FORM SKIP(1) WITH NO-BOX NO-ATTR-SPACE WIDTH 80 FRAME f_linha.

FORM rel_dsagenci AT 1 FORMAT "x(21)" LABEL "AGENCIA"
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE SIDE-LABELS WIDTH 132 FRAME f_agencia.

FORM SKIP(1)
     "SAQUE MAXIMO      DISPONIVEL     LIMITE"          AT 21
     "BLOQUEADO  SAQUE DA FOLHA      SALDO TOTAL"       AT 91
     "-------------------------------------------"      AT 17
     "------------------------------------------------" AT 85
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_descri.

FORM crapsld.nrdconta  AT   1 FORMAT "zzzz,zzz,9"        LABEL "CONTA/DV"
     rel_dsdacstp      AT  12 FORMAT "x(4)"              LABEL "CST "
     rel_vlsaqmax      AT  17 FORMAT "zzzz,zzz,zz9.99-"  LABEL "SAQUE MAXIMO"
     rel_vlsddisp      AT  33 FORMAT "zzzz,zzz,zz9.99-"  LABEL "DISPONIVEL"
     crapass.vllimcre  AT  49 FORMAT "zzz,zzz,zz9"       LABEL "LIMITE"
     rel_nmprimtl      AT  61 FORMAT "x(23)"             LABEL "TITULAR"
     rel_vlsdbltl      AT  85 FORMAT "zzz,zzz,zz9.99-"   LABEL "BLOQUEADO"
     rel_vlsdfolh      AT 100 FORMAT "zzzz,zzz,zz9.99-"  LABEL "SAQUE DA FOLHA"
     rel_vlstotal      AT 116 FORMAT "zzzzz,zzz,zz9.99-" LABEL "SALDO TOTAL"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_saldopos.

FORM tot_nmresage               AT   1 FORMAT "x(15)"
     tot_agpsdmax[aux_cdagenci] AT  17 FORMAT "zzzz,zzz,zz9.99-"
     tot_agpsddis[aux_cdagenci] AT  33 FORMAT "zzzz,zzz,zz9.99-"
     tot_agpvllim[aux_cdagenci] AT  49 FORMAT "zzzzzzz,zz9"
     tot_agpsdbtl[aux_cdagenci] AT  85 FORMAT "zzz,zzz,zz9.99-"
     tot_agpsdchs[aux_cdagenci] AT 100 FORMAT "zzzz,zzz,zz9.99-"
     tot_agpsdstl[aux_cdagenci] AT 116 FORMAT "zzzzz,zzz,zz9.99-"
     WITH NO-BOX NO-ATTR-SPACE DOWN NO-LABEL WIDTH 132 FRAME f_totalpos.

FORM SKIP(1)
       "* ADIANTAMENTO A DEPOSITANTES - CHEQUES *" AT 45
       SKIP(1)
       "CHEQUES" AT 100
       "-------------------------------" AT 89
       WITH NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_crrl278_cabec_cheques.

FORM crat007.nrdconta FORMAT "zzzz,zzz,9"    COLUMN-LABEL "CONTA/DV"
     crat007.nmprimtl FORMAT "x(20)"         COLUMN-LABEL "TITULAR"
     crat007.qtddsdev FORMAT "zzz9"          COLUMN-LABEL "DD"
     crat007.vlsddisp FORMAT "zzzzz,zz9.99-" COLUMN-LABEL "DISPONIVEL"
     crat007.vllimcre FORMAT "zzzzz,zz9"     COLUMN-LABEL "LIMITE"
     crat007.vlsdbltl FORMAT "zzzzz,zz9.99-" COLUMN-LABEL "BLOQUEADO"
     crat007.vlestour FORMAT "zzzzz,zz9.99"  COLUMN-LABEL "ADIANT."
     crat007.qtcmptot FORMAT "zzz9"          COLUMN-LABEL "QT"      
     crat007.vlcmptot FORMAT "zzz,zz9.99"    COLUMN-LABEL "COMP"
     crat007.qtcstdct FORMAT "zzz9"          COLUMN-LABEL "QT"
     crat007.vlcstdct FORMAT "zzz,zz9.99"    COLUMN-LABEL "CST/DCT/CX"
     crat007.obsdisp2 FORMAT "x(11)"         COLUMN-LABEL "OBSERVACOES"      
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_crrl278_cheques.

FORM crat007.nrdconta FORMAT "zzzz,zzz,9"    COLUMN-LABEL "CONTA/DV"
     crat007.nmprimtl FORMAT "x(28)"         COLUMN-LABEL "TITULAR"
     crat007.nrdofone FORMAT "x(20)"         COLUMN-LABEL "TELEFONE"
     crat007.qtddsdev FORMAT "zzz9"          COLUMN-LABEL "DD"
     crat007.vlsddisp FORMAT "zzzzz,zz9.99-" COLUMN-LABEL "DISPONIVEL"
     crat007.vllimcre FORMAT "zzzzz,zz9"     COLUMN-LABEL "LIMITE"
     crat007.vlsdbltl FORMAT "zzzzz,zz9.99-" COLUMN-LABEL "BLOQUEADO"
     crat007.vlestour FORMAT "zzzzz,zz9.99"  COLUMN-LABEL "ADIANT."
     crat007.obsdisp2 FORMAT "x(11)"         COLUMN-LABEL "OBSERVACOES"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_crrl278_diversos.

FORM SKIP(1)
       "* ADIANTAMENTO A DEPOSITANTES - DIVERSOS *" AT 45 
       SKIP(1)
       WITH NO-BOX NO-ATTR-SPACE WIDTH 132 FRAME f_crrl278_cabec_diversos.

FORM tot_nmresage                   AT  1 FORMAT "x(15)"
     tot_agnsddis[crapage.cdagenci] AT 65 FORMAT "zzz,zzz,zz9.99-"
     tot_agnvllim[crapage.cdagenci] AT 81 FORMAT "z,zzz,zz9"
     tot_agnsdbtl[crapage.cdagenci] AT 91 FORMAT "zzzzz,zz9.99-"
     SKIP(1)
     "TOTAIS (Custodia/Desconto/CX) ==> "
     tot_qtcstdct[crapage.cdagenci] AT 35 FORMAT "z,zzz,zz9"      LABEL "QTD."
     tot_vlcstdct[crapage.cdagenci] AT 51 FORMAT "zzz,zzz,zz9.99" LABEL "VLR."
     WITH NO-LABEL NO-BOX NO-ATTR-SPACE DOWN SIDE-LABELS WIDTH 132 FRAME f_totalpac_278.
FORM SKIP(1) 
     "DD        : Dias consecutivos de adiantamento a depositante."
     SKIP       
     "COMP.     : Cheques compensados em outras IFs."
     SKIP
     "CST/DCT/CX: Cheques em custodia, desconto ou trocado na boca do caixa da Cooperativa."
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABEL WIDTH 132 FRAME f_detalhes_278.

FORM tot_nmresage                FORMAT "x(20)"           COLUMN-LABEL "DESCRICAO"
     tot_agnsddis[aux_cdagenci]  FORMAT "zzz,zzz,zz9.99-" COLUMN-LABEL "DISPONIVEL"              
     tot_agnvllim[aux_cdagenci]  FORMAT "zzz,zzz,zz9.99"  COLUMN-LABEL "LIMITE"
     tot_agnsdbtl[aux_cdagenci]  FORMAT "zzz,zzz,zz9.99-" COLUMN-LABEL "BLOQUEADO"
     tot_qtcstdct[aux_cdagenci]  FORMAT "zzz,zzz,zz9"     COLUMN-LABEL "QTD."                           
     tot_vlcstdct[aux_cdagenci]  FORMAT "zzz,zzz,zz9.99"  COLUMN-LABEL "CST/DCT/CX"
     WITH NO-BOX NO-ATTR-SPACE DOWN WIDTH 132 FRAME f_totalger_278.


FUNCTION concatena_fones RETURN CHAR ():

    DEF VAR aux_nrdofone AS CHAR                                    NO-UNDO.
    DEF VAR aux_tptelefo AS INTE                                    NO-UNDO.

    ASSIGN aux_tptelefo = IF  crapass.inpessoa = 1  THEN
                              1
                          ELSE
                              3.

    FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper     AND
                             craptfc.nrdconta = crapass.nrdconta AND
                             craptfc.tptelefo = aux_tptelefo                
                             NO-LOCK NO-ERROR.

    IF AVAILABLE craptfc  THEN  
       ASSIGN aux_nrdofone = STRING(craptfc.nrdddtfc) + 
                             STRING(craptfc.nrtelefo).

    FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper     AND
                             craptfc.nrdconta = crapass.nrdconta AND
                             craptfc.tptelefo = 2  
                             NO-LOCK NO-ERROR.

    IF AVAILABLE craptfc  THEN
       DO:
           IF aux_nrdofone <> "" THEN
              ASSIGN aux_nrdofone = aux_nrdofone + "/".
           ELSE 
              ASSIGN aux_nrdofone = STRING(craptfc.nrdddtfc).

           ASSIGN aux_nrdofone = aux_nrdofone + STRING(craptfc.nrtelefo).
       END.

    IF  aux_nrdofone = ""  THEN
        DO:
            ASSIGN aux_tptelefo = IF  crapass.inpessoa = 1  THEN
                                      3
                                  ELSE
                                      1.

            FIND FIRST craptfc WHERE craptfc.cdcooper = glb_cdcooper     AND
                                     craptfc.nrdconta = crapass.nrdconta AND
                                     craptfc.tptelefo = aux_tptelefo   
                                     NO-LOCK NO-ERROR.

            IF  AVAILABLE craptfc  THEN  
                aux_nrdofone = STRING(craptfc.nrdddtfc) +
                               STRING(craptfc.nrtelefo).
            ELSE
                aux_nrdofone = "".
        END.

    RETURN aux_nrdofone.

END FUNCTION.

ASSIGN glb_cdprogra = "crps121"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.

{ includes/cabrel132_1.i }
{ includes/cabrel132_2.i }

ASSIGN aux_insaqmax = IF glb_dtmvtopr > 01/22/1997 AND glb_dtmvtopr < 01/24/1999
                         THEN glb_cfrvipmf
                         ELSE 1
       aux_dtmvtolt = IF glb_inproces > 1  
                         THEN glb_dtmvtopr
                         ELSE glb_dtmvtolt.

{ includes/cpmf.i } 

ASSIGN tab_txcpmfcc = IF glb_dtmvtopr >= tab_dtinipmf AND
                         glb_dtmvtopr <= tab_dtfimpmf 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,23,13))
                         ELSE 0
       tab_txrdcpmf = IF glb_dtmvtopr >= tab_dtinipmf AND
                         glb_dtmvtopr <= tab_dtfimpmf 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,38,13))
                         ELSE 1.

IF   glb_cdcritic > 0 THEN
     RETURN.

/*  Leitura da tabela de parametros para indentificar o Nro. da conta  */
RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).

FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:

    ASSIGN aux_flgfirst = TRUE
           rel_dsagenci = STRING(crapage.cdagenci,"zz9") + " - " +
                          crapage.nmresage
           aux_cdagenci = crapage.cdagenci
           aux_nmresage[crapage.cdagenci] = crapage.nmresage.
    
    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper     AND
                           crapass.cdagenci = crapage.cdagenci
                           USE-INDEX crapass2 NO-LOCK:
        
        IF   crapass.inpessoa = 1   THEN 
             DO:
                 FIND crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND
                                    crapttl.nrdconta = crapass.nrdconta   AND
                                    crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
        
                 IF   AVAIL crapttl  THEN
                      ASSIGN aux_cdempres = crapttl.cdempres.
             END.
        ELSE
             DO:
                 FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                    crapjur.nrdconta = crapass.nrdconta
                                    NO-LOCK NO-ERROR.
        
                 IF   AVAIL crapjur  THEN
                      ASSIGN aux_cdempres = crapjur.cdempres.
             END.
                
        IF   glb_dsparame = "999" OR
             CAN-DO(glb_dsparame,STRING(aux_cdempres)) THEN
             .
        ELSE
             NEXT.           
                  
        FIND crapsld WHERE crapsld.cdcooper = glb_cdcooper     AND
                           crapsld.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapsld   THEN
             NEXT.
        
        ASSIGN rel_vlsddisp = crapsld.vlsddisp
               rel_vlsdbloq = crapsld.vlsdbloq
               rel_vlsdblpr = crapsld.vlsdblpr
               rel_vlsdblfp = crapsld.vlsdblfp
               rel_vlsdchsl = crapsld.vlsdchsl
               aux_vlipmfap = crapsld.vlipmfap
               aux_flgerros = FALSE
               aux_flgnegat = FALSE
               aux_flgimprm = FALSE
               rel_qtcompbb = 0
               rel_vlcompbb = 0
               rel_qtcmpbcb = 0
               rel_vlcmpbcb = 0
               rel_qtcmpctl = 0
               rel_vlcmpctl = 0.
        
        /*  Leitura dos lancamentos do dia  */
        FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper       AND
                               craplcm.nrdconta = crapsld.nrdconta   AND
                               craplcm.dtmvtolt = aux_dtmvtolt       AND
                               craplcm.cdhistor <> 289 
                               USE-INDEX craplcm2 NO-LOCK:
            
            FIND craphis WHERE craphis.cdcooper = craplcm.cdcooper   AND
                               craphis.cdhistor = craplcm.cdhistor 
                               NO-LOCK NO-ERROR.
                               
            IF   NOT AVAILABLE craphis   THEN
                 DO:
                     glb_cdcritic = 80.
                     aux_flgerros = TRUE.
                     LEAVE.
                 END.
            ELSE
                 aux_txdoipmf = tab_txcpmfcc.            

            IF   craphis.inhistor = 1   THEN
                 rel_vlsddisp = rel_vlsddisp + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 2   THEN
                 rel_vlsdchsl = rel_vlsdchsl + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 3   THEN
                 rel_vlsdbloq = rel_vlsdbloq + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 4   THEN
                 rel_vlsdblpr = rel_vlsdblpr + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 5   THEN
                 rel_vlsdblfp = rel_vlsdblfp + craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 11   THEN
                 rel_vlsddisp = rel_vlsddisp - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 12   THEN
                 rel_vlsdchsl = rel_vlsdchsl - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 13   THEN
                 rel_vlsdbloq = rel_vlsdbloq - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 14   THEN
                 rel_vlsdblpr = rel_vlsdblpr - craplcm.vllanmto.
            ELSE
            IF   craphis.inhistor = 15   THEN
                 rel_vlsdblfp = rel_vlsdblfp - craplcm.vllanmto.
            ELSE
                 DO:
                     glb_cdcritic = 83.
                     aux_flgerros = TRUE.
                     LEAVE.          
                 END.
            
            /*  Calcula CPMF para os lancamentos  */
            IF   craphis.indoipmf > 1   THEN
                 IF   tab_txcpmfcc > 0   THEN
                      IF   craphis.indebcre = "D"   THEN
                           aux_vlipmfap = aux_vlipmfap +
                          (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                      ELSE
                      IF   craphis.indebcre = "C"   THEN
                           aux_vlipmfap = aux_vlipmfap -
                          (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                      ELSE .
                 ELSE .
            ELSE
            IF   craphis.inhistor = 12 THEN
                 DO:
                     /*** Magui substituindo cheque salario ***/
                     IF   craplcm.cdhistor <> 43 THEN
                          ASSIGN rel_vlsdchsl = rel_vlsdchsl -
                                   (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2))
                                                 rel_vlsddisp = rel_vlsddisp +
                                   (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2))
                                                aux_vlipmfap = aux_vlipmfap +
                                  (TRUNCATE(craplcm.vllanmto * tab_txcpmfcc,2)).
                 END.

            IF   craplcm.cdhistor = 50   OR
                 craplcm.cdhistor = 59   THEN
                 ASSIGN rel_qtcompbb = rel_qtcompbb + 1
                        rel_vlcompbb = rel_vlcompbb + craplcm.vllanmto.
            ELSE
            IF   craplcm.cdhistor = 313   OR
                 craplcm.cdhistor = 340   THEN
                 ASSIGN rel_qtcmpbcb = rel_qtcmpbcb + 1
                        rel_vlcmpbcb = rel_vlcmpbcb + craplcm.vllanmto.

            ELSE
            IF   craplcm.cdhistor = 524   OR
                 craplcm.cdhistor = 572   THEN
                 ASSIGN rel_qtcmpctl = rel_qtcmpctl + 1
                        rel_vlcmpctl = rel_vlcmpctl + craplcm.vllanmto.
                                           
        END.  /*  Fim do FOR EACH -- Leitura dos lancamentos do dia  */

        IF   aux_flgerros   THEN
             DO:
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                   glb_cdprogra + "' --> '" + glb_dscritic +
                                   "CONTA = " + STRING(crapass.nrdconta) +
                                   " >> log/proc_batch.log").
                 RETURN.
             END.

        IF   rel_vlsddisp = 0 AND
             rel_vlsdchsl = 0 AND
             rel_vlsdbloq = 0 AND
             rel_vlsdblpr = 0 AND
             rel_vlsdblfp = 0 AND
             rel_vlsdchsl = 0   THEN
             NEXT.
        
        IF   aux_flgfirst   THEN
             DO:
                  ASSIGN aux_nmarqimp = "rl/crrl100_" +
                                          STRING(crapass.cdagenci,"999") + ".lst"
                           aux_flgfirst = FALSE.
                  
                  OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

                  VIEW STREAM str_1 FRAME f_cabrel132_1.

                  DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.

             END.
                   ASSIGN rel_dsdacstp = IF CAN-FIND(LAST crapcor WHERE
                                         crapcor.cdcooper = glb_cdcooper     AND
                                         crapcor.nrdconta = crapass.nrdconta AND
                                         crapcor.flgativo = TRUE)
                                 THEN "*" + STRING(crapass.cdsitdct,"9") +
                                            STRING(crapass.cdtipcta,"99")
                                 ELSE " " + STRING(crapass.cdsitdct,"9") +
                                            STRING(crapass.cdtipcta,"99")

               rel_nmprimtl = crapass.nmprimtl

               rel_vlsdbltl = rel_vlsdbloq + rel_vlsdblpr + rel_vlsdblfp

               rel_vlstotal = rel_vlsddisp + rel_vlsdbltl + rel_vlsdchsl

               rel_vlsaqmax = rel_vlsddisp - crapsld.vlipmfpg - aux_vlipmfap

               rel_vlsdfolh = IF  rel_vlsaqmax <= 0  THEN
                                  TRUNC(rel_vlsaqmax / tab_txrdcpmf,2)
                              ELSE
                                  TRUNCATE(rel_vlsaqmax * tab_txrdcpmf,2)

               aux_vldfolha = 0

               tel_nrdconta = crapass.nrdconta.
        
        RUN fontes/sldfol.p (INPUT FALSE).
        
        IF   glb_cdcritic > 0   THEN
             DO:
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE("echo " +
                      STRING(TIME,"HH:MM:SS") + " - " +
                      glb_cdprogra + "' --> '" + glb_dscritic +
                      "CONTA = " + STRING(tel_nrdconta) +
                      " >> log/proc_batch.log").
                 glb_cdcritic = 0.
                 RETURN.
             END.
        
        ASSIGN rel_vlsaqmax = IF rel_vlsaqmax <= 0
                                 THEN 0
                                 ELSE TRUNCATE(rel_vlsaqmax * tab_txrdcpmf,2)

               rel_vlsdfolh = rel_vlsdfolh + aux_vldfolha

               tot_agpsdmax[crapass.cdagenci] = tot_agpsdmax[crapass.cdagenci] +
                                                rel_vlsaqmax
               tot_agpsddis[crapass.cdagenci] = tot_agpsddis[crapass.cdagenci] +
                                                rel_vlsddisp
               tot_agpvllim[crapass.cdagenci] = tot_agpvllim[crapass.cdagenci] +
                                                crapass.vllimcre

               tot_agpsdbtl[crapass.cdagenci] = tot_agpsdbtl[crapass.cdagenci] +
                                                rel_vlsdbltl

               tot_agpsdchs[crapass.cdagenci] = tot_agpsdchs[crapass.cdagenci] +
                                                rel_vlsdfolh

               tot_agpsdstl[crapass.cdagenci] = tot_agpsdstl[crapass.cdagenci] +
                                                rel_vlstotal

               tot_agpsdmax[999] = tot_agpsdmax[999] + rel_vlsaqmax
               tot_agpsddis[999] = tot_agpsddis[999] + rel_vlsddisp
               tot_agpvllim[999] = tot_agpvllim[999] + crapass.vllimcre
               tot_agpsdbtl[999] = tot_agpsdbtl[999] + rel_vlsdbltl
               tot_agpsdchs[999] = tot_agpsdchs[999] + rel_vlsdfolh
               tot_agpsdstl[999] = tot_agpsdstl[999] + rel_vlstotal.
        
        DISPLAY STREAM str_1
                crapsld.nrdconta       rel_dsdacstp
                rel_vlsaqmax      WHEN rel_vlsaqmax > 0
                rel_vlsddisp           crapass.vllimcre   rel_nmprimtl
                rel_vlsdbltl           rel_vlsdfolh       rel_vlstotal
                WITH FRAME f_saldopos.

        DOWN STREAM str_1 WITH FRAME f_saldopos.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.

                 DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.
             END.

        /**** Magui impressao do relatorio de saldos negativos ***/
        IF   rel_vlsdbloq < 0   OR
             rel_vlsdblpr < 0   OR
             rel_vlsdblfp < 0   OR
             rel_vlsdchsl < 0   OR
             rel_vlsddisp < 0   THEN
             DO:
                 ASSIGN aux_flgnegat = TRUE
                        aux_flgimprm = TRUE
                        aux_flgespec = IF  CAN-DO("2,4,9,11,13,15",
                                                     STRING(crapass.cdtipcta))
                                       THEN TRUE
                                       ELSE FALSE.

                 IF   aux_flgespec THEN
                      DO:
                          IF  (rel_vlsddisp * -1) > crapass.vllimcre   THEN
                               aux_flgimprm = TRUE.
                          ELSE
                               aux_flgimprm = FALSE.
                          
                          IF  (rel_vlstotal * -1) > crapass.vllimcre   THEN
                              DO:
                                  ASSIGN tot_agnvllim[crapass.cdagenci] =
                                                tot_agnvllim[crapass.cdagenci] +
                                                crapass.vllimcre.

                                  IF   crapsld.dtdsdclq <> ?   THEN
                                       crl_agnvllim = crl_agnvllim +
                                                          crapass.vllimcre.
                                  ELSE
                                  IF   crapass.inpessoa = 2   THEN
                                      jur_agnvllim = jur_agnvllim +
                                                          crapass.vllimcre.
                                  ELSE
                                  IF   crapass.inpessoa = 3   THEN
                                       adm_agnvllim = adm_agnvllim +
                                                          crapass.vllimcre.
                              END.                     
                      
                      END.
                      
                 IF   rel_vlstotal < 0  THEN
                      IF  (rel_vlstotal * -1) > crapass.vllimcre   THEN
                          DO:
                              IF   crapsld.dtdsdclq <> ?   THEN
                                   crl_agnsdstl = crl_agnsdstl + rel_vlstotal.
                              ELSE
                              IF   crapass.inpessoa = 2   THEN
                                   jur_agnsdstl = jur_agnsdstl + rel_vlstotal.
                              ELSE
                              IF   crapass.inpessoa = 3   THEN
                                   adm_agnsdstl = adm_agnsdstl + rel_vlstotal.
                          END.
                           
                 IF   aux_flgimprm   THEN
                      DO:
                          ASSIGN tot_agnsddis[crapass.cdagenci] =
                                     IF   rel_vlsddisp < 0
                                          THEN tot_agnsddis[crapass.cdagenci] +
                                                            rel_vlsddisp
                                          ELSE tot_agnsddis[crapass.cdagenci]

                                 tot_agnsdbtl[crapass.cdagenci] =
                                     IF   rel_vlsdbloq < 0   OR
                                          rel_vlsdblpr < 0   OR
                                          rel_vlsdblfp < 0
                                          THEN tot_agnsdbtl[crapass.cdagenci] +
                                                            rel_vlsdbltl
                                          ELSE tot_agnsdbtl[crapass.cdagenci].

                          IF   crapsld.dtdsdclq <> ?   THEN
                               ASSIGN crl_agnsddis = IF   rel_vlsddisp < 0
                                            THEN crl_agnsddis + rel_vlsddisp
                                            ELSE crl_agnsddis

                                   crl_agnsdbtl = IF   rel_vlsdbloq < 0   OR
                                                       rel_vlsdblpr < 0   OR
                                                       rel_vlsdblfp < 0
                                              THEN crl_agnsdbtl + rel_vlsdbltl
                                              ELSE crl_agnsdbtl.
                          ELSE
                          IF   crapass.inpessoa = 2   THEN
                               ASSIGN jur_agnsddis = IF   rel_vlsddisp < 0
                                           THEN jur_agnsddis + rel_vlsddisp
                                           ELSE jur_agnsddis

                                      jur_agnsdbtl = IF rel_vlsdbloq < 0 OR
                                                        rel_vlsdblpr < 0 OR
                                                        rel_vlsdblfp < 0
                                               THEN jur_agnsdbtl + rel_vlsdbltl
                                               ELSE jur_agnsdbtl.

                          ELSE
                          IF   crapass.inpessoa = 3   THEN
                               ASSIGN adm_agnsddis = IF   rel_vlsddisp < 0
                                           THEN adm_agnsddis + rel_vlsddisp
                                           ELSE adm_agnsddis

                                      adm_agnsdbtl = IF rel_vlsdbloq < 0 OR
                                                        rel_vlsdblpr < 0 OR
                                                        rel_vlsdblfp < 0
                                               THEN adm_agnsdbtl + rel_vlsdbltl
                                               ELSE adm_agnsdbtl.
                      END.
             END.
        
        IF   aux_flgnegat   AND
             aux_flgimprm   THEN
             DO:
            
                 ASSIGN aux_nrdofone = concatena_fones().
                 
                 IF   crapsld.dtdsdclq <> ?   THEN
                      ASSIGN rel_nmprimtl = "CL - " + rel_nmprimtl.
 
                 IF   rel_vlstotal < 0   THEN
                      IF   crapass.vllimcre > 0   THEN
                           IF   crapass.vllimcre < (rel_vlstotal * -1)   THEN
                                rel_vlestour = 
                                    (rel_vlstotal + crapass.vllimcre) * -1.
                           ELSE
                                rel_vlestour = 0.
                      ELSE
                           rel_vlestour = rel_vlstotal * -1.
                 ELSE
                      rel_vlestour = 0.

                 /* Para relatorio de saldos negativos */
                 CREATE crat007.
                 ASSIGN crat007.nrdconta = crapsld.nrdconta
                        crat007.cdagenci = crapage.cdagenci
                        crat007.nmresage = crapage.nmresage
                        crat007.nrdofone = aux_nrdofone
                        crat007.qtddsdev = crapsld.qtddsdev
                        crat007.vlsddisp = rel_vlsddisp
                        crat007.vllimcre = crapass.vllimcre
                        crat007.vlestour = rel_vlestour
                        crat007.nmprimtl = rel_nmprimtl
                        crat007.vlsdbltl = rel_vlsdbltl
                        crat007.qtcmptot = rel_qtcompbb + rel_qtcmpbcb + 
                                           rel_qtcmpctl
                        crat007.vlcmptot = rel_vlcompbb + rel_vlcmpbcb + 
                                           rel_vlcmpctl.

                 ASSIGN aux_nrdigitg = crapass.nrdctitg.
                 
                 /* Alimentar a variavel aux_ctpsqitg */
                 RUN conta_itg_digito_zero.

                 /* Custodia de cheques */ 
                 FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper   AND
                                        crapcst.dtlibera  = aux_dtmvtolt   AND
                             
                        /* Cecred e Bancoob */
                       (((crapcst.cdbanchq = 85 OR crapcst.cdbanchq = 756) AND 
                          crapcst.nrctachq = crapass.nrdconta ) OR  
                        /* Banco do Brasil => Conta Integracao */
                    (crapcst.cdbanchq = 1 AND crapcst.nrctachq = aux_ctpsqitg))   
                                       
                                       AND
                                       crapcst.insitchq  = 2              AND
                                       crapcst.dtdevolu  = ?              AND
                                       crapcst.inchqcop  = 1                  
                                       NO-LOCK USE-INDEX crapcst3:
                
                    ASSIGN crat007.qtcstdct = crat007.qtcstdct + 1
                           crat007.vlcstdct = crat007.vlcstdct + 
                                              crapcst.vlcheque.                   
                 END.

                 /* Cheque / Cheque Salario - Nao quebrar o indice por historico */
                 FOR EACH craplcm WHERE
                         (craplcm.cdcooper = glb_cdcooper       AND
                          craplcm.nrdconta = crapass.nrdconta   AND
                          craplcm.dtmvtolt = aux_dtmvtolt       AND
                          craplcm.cdhistor = 521)               OR

                         (craplcm.cdcooper = glb_cdcooper       AND
                          craplcm.nrdconta = crapass.nrdconta   AND
                          craplcm.dtmvtolt = aux_dtmvtolt       AND
                          craplcm.cdhistor = 621)               OR       

                         (craplcm.cdcooper = glb_cdcooper       AND
                          craplcm.nrdconta = crapass.nrdconta   AND
                          craplcm.dtmvtolt = aux_dtmvtolt       AND
                          craplcm.cdhistor = 21)                OR
                         
                         (craplcm.cdcooper = glb_cdcooper       AND
                          craplcm.nrdconta = crapass.nrdconta   AND
                          craplcm.dtmvtolt = aux_dtmvtolt       AND
                          craplcm.cdhistor = 26)                NO-LOCK:
                 
                     ASSIGN crat007.qtcstdct = crat007.qtcstdct + 1
                            crat007.vlcstdct = crat007.vlcstdct + 
                                               craplcm.vllanmto. 
                 
                 END.

                 /* Totaliza */
                 ASSIGN tot_qtcstdct[crapage.cdagenci] =
                            tot_qtcstdct[crapage.cdagenci] + crat007.qtcstdct
                             
                        tot_vlcstdct[crapage.cdagenci] =
                            tot_vlcstdct[crapage.cdagenci] + crat007.vlcstdct.
             END.
   
     END.  /*  Fim do FOR EACH  --  Leitura dos associados  */
     
     IF  NOT aux_flgfirst   THEN /* Verifica se entrou no FOR EACH crapass */
         DO:
             /*  Imprime total da agencia  */
             IF   LINE-COUNTER(str_1) >= (PAGE-SIZE(str_1) - 1)   THEN
                  DO:
                      PAGE STREAM str_1.

                      DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.
                  END.
             ELSE
                  VIEW STREAM str_1 FRAME f_linha.

             DISPLAY STREAM str_1
                     tot_nmresage
                     tot_agpsdmax[aux_cdagenci] tot_agpsddis[aux_cdagenci]
                     tot_agpvllim[aux_cdagenci] tot_agpsdbtl[aux_cdagenci]
                     tot_agpsdchs[aux_cdagenci] tot_agpsdstl[aux_cdagenci]
                     WITH FRAME f_totalpos.

             DOWN STREAM str_1 WITH FRAME f_totalpos.

             OUTPUT STREAM str_1 CLOSE.
         END.
             
    IF   aux_flgmensa  THEN
         DO:
             UNIX SILENT script/avcons.msg.
             aux_flgmensa = FALSE.
         END.
    
    ASSIGN glb_nmformul = "urgente"
           glb_nrcopias = 1
           glb_nmarqimp = aux_nmarqimp.

END.  /*  Fim do FOR EACH  --  Ordem das agencias  */

/*  Emite resumo geral */

ASSIGN tot_nmresage = "TOTAL GERAL ==>"
       aux_cdagenci = 999
       glb_nmformul = "urgente"
       glb_nrcopias = 1
       glb_nmarqimp = "rl/crrl100_999.lst"
       rel_dsagenci = "RESUMO".

OUTPUT STREAM str_1 TO VALUE(glb_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

DISPLAY STREAM str_1 rel_dsagenci WITH FRAME f_agencia.

VIEW STREAM str_1 FRAME f_linha.

VIEW STREAM str_1 FRAME f_descri.

DISPLAY STREAM str_1 tot_nmresage
               tot_agpsdmax[aux_cdagenci]  tot_agpsddis[aux_cdagenci]
               tot_agpvllim[aux_cdagenci]  tot_agpsdbtl[aux_cdagenci]
               tot_agpsdchs[aux_cdagenci]  tot_agpsdstl[aux_cdagenci]
               WITH FRAME f_totalpos.

OUTPUT STREAM str_1 CLOSE.


/* Saldo devedores dos associados */
FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:

    ASSIGN aux_flgnegcb = FALSE.

    /* Motivo Cheque */
    FOR EACH crat007 WHERE crat007.cdagenci = crapage.cdagenci   AND
                          (crat007.qtcmptot <> 0                 OR
                           crat007.qtcstdct <> 0)                NO-LOCK
                           BREAK BY crat007.cdagenci
                                    BY crat007.nrdconta:

        IF   FIRST-OF(crat007.cdagenci)   THEN
             DO:
                 ASSIGN aux_nmarqneg = 
                     "rl/crrl278_" + STRING(crat007.cdagenci,"999") + ".lst"
                     
                        rel_dsagenci =
                     STRING(crat007.cdagenci,"zz9") + " - " + crat007.nmresage
                     
                        aux_flgnegcb = TRUE.
             
                 OUTPUT STREAM str_2 TO VALUE(aux_nmarqneg) PAGED PAGE-SIZE 80.
                 
                 VIEW STREAM str_2 FRAME f_cabrel132_2.
                                  
                 DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_agencia. 

                 VIEW STREAM str_2 FRAME f_crrl278_cabec_cheques.
             END.

        DISPLAY STREAM str_2 crat007.nrdconta     crat007.nmprimtl 
                             crat007.qtddsdev     crat007.vlsddisp 
                             crat007.vllimcre     crat007.vlsdbltl 
                             crat007.vlestour     crat007.qtcmptot 
                             crat007.vlcmptot     crat007.qtcstdct 
                             crat007.vlcstdct     crat007.obsdisp2 
                             WITH FRAME f_crrl278_cheques.

        DOWN WITH FRAME f_crrl278_cheques.

        IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2)  THEN
             DO:
                 PAGE STREAM str_2.
                 CLEAR FRAME f_agencia NO-PAUSE.
                 DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_agencia.
             END.

    END. /* Fim Diversos */

    /* Motivo Diversos */
    FOR EACH crat007 NO-LOCK WHERE crat007.cdagenci = crapage.cdagenci   AND 
                                   crat007.qtcmptot = 0                  AND
                                   crat007.qtcstdct = 0 
                                   BREAK BY crat007.cdagenci
                                            BY crat007.qtddsdev DESC
                                               BY crat007.nrdconta:

        IF   NOT aux_flgnegcb             AND  /* Se arquivo nao aberto */ 
             FIRST-OF(crat007.cdagenci)   THEN
             DO:
                 ASSIGN aux_nmarqneg = 
                     "rl/crrl278_" + STRING(crat007.cdagenci,"999") + ".lst"
                     
                        rel_dsagenci =
                     STRING(crat007.cdagenci,"zz9") + " - " + crat007.nmresage
                     
                        aux_flgnegcb  = TRUE.
                           
                 OUTPUT STREAM str_2 TO VALUE(aux_nmarqneg) PAGED PAGE-SIZE 80.
                 VIEW STREAM str_2 FRAME f_cabrel132_2.
                 DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_agencia.  
             END.

        IF   FIRST-OF(crat007.cdagenci)  THEN
             VIEW STREAM str_2 FRAME f_crrl278_cabec_diversos.

        DISPLAY STREAM str_2 crat007.nrdconta crat007.nmprimtl
                             crat007.nrdofone crat007.qtddsdev
                             crat007.vlsddisp crat007.vllimcre
                             crat007.vlsdbltl crat007.vlestour
                             crat007.obsdisp2 WITH FRAME f_crrl278_diversos.

        DOWN WITH FRAME f_crrl278_diversos.

        IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2)  THEN
             DO:
                 PAGE STREAM str_2.
                 CLEAR FRAME f_agencia NO-PAUSE.
                 DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_agencia.
             END.

    END. /* Fim diversos */

    /* Totaliza PAC */
    IF   aux_flgnegcb                          AND /* Se tem informacao do PAC*/
        (tot_agnsddis[crapage.cdagenci] <> 0   OR 
         tot_agnvllim[crapage.cdagenci] <> 0   OR
         tot_agnsdbtl[crapage.cdagenci] <> 0   OR 
         tot_qtcstdct[crapage.cdagenci] <> 0   OR
         tot_vlcstdct[crapage.cdagenci] <> 0)   THEN
         DO:
             IF   LINE-COUNTER(str_2) >= (PAGE-SIZE(str_2) - 1)   THEN
                  DO:
                      PAGE STREAM str_2.
                      CLEAR FRAME f_agencia NO-PAUSE.
                      DISPLAY STREAM str_2 rel_dsagenci WITH FRAME f_agencia.
                  END.
             ELSE
                  VIEW STREAM str_2 FRAME f_linha.
             
             DISPLAY STREAM str_2 tot_nmresage
                                  tot_agnsddis[crapage.cdagenci] 
                                  tot_agnvllim[crapage.cdagenci]
                                  tot_agnsdbtl[crapage.cdagenci]  
                                  tot_qtcstdct[crapage.cdagenci]                 
                                  tot_vlcstdct[crapage.cdagenci]
                                  WITH FRAME f_totalpac_278.
             
             DOWN STREAM str_2 WITH FRAME f_totalpac_278.

             VIEW STREAM str_2 FRAME f_detalhes_278.
             
             OUTPUT STREAM str_2 CLOSE.     
         END. 

END. /* Fim crapage */

ASSIGN aux_nmarqneg = "rl/crrl278_999.lst".

OUTPUT STREAM str_2 TO VALUE(aux_nmarqneg) PAGED PAGE-SIZE 80.

VIEW STREAM str_2 FRAME f_cabrel132_2.
              
DO aux_cdagenci = 1 TO aux_nrmaxpas:

   IF   tot_agnsddis[aux_cdagenci] = 0   AND
        tot_agnvllim[aux_cdagenci] = 0   AND
        tot_agnsdbtl[aux_cdagenci] = 0   AND
        tot_qtcstdct[aux_cdagenci] = 0   AND
        tot_vlcstdct[aux_cdagenci] = 0   THEN
        NEXT.

   ASSIGN ger_agnsddis = ger_agnsddis + tot_agnsddis[aux_cdagenci]
          ger_agnvllim = ger_agnvllim + tot_agnvllim[aux_cdagenci]
          ger_agnsdbtl = ger_agnsdbtl + tot_agnsdbtl[aux_cdagenci]
          ger_qtcstdct = ger_qtcstdct + tot_qtcstdct[aux_cdagenci]
          ger_vlcstdct = ger_vlcstdct + tot_vlcstdct[aux_cdagenci].

          tot_nmresage = aux_nmresage[aux_cdagenci].

   DISPLAY STREAM str_2
           tot_nmresage
           tot_agnsddis[aux_cdagenci]
           tot_agnvllim[aux_cdagenci]
           tot_agnsdbtl[aux_cdagenci]
           tot_qtcstdct[aux_cdagenci]
           tot_vlcstdct[aux_cdagenci]
           WITH FRAME f_totalger_278.

   DOWN STREAM str_2 WITH FRAME f_totalger_278.

END.  /*  Fim do DO .. TO  */

ASSIGN tot_nmresage = "TOTAL GERAL ==>"
       aux_cdagenci = aux_nrmaxpas.

VIEW STREAM str_2 FRAME f_linha.

DISPLAY STREAM str_2
        tot_nmresage
        ger_agnsddis  @  tot_agnsddis[aux_cdagenci]
        ger_agnvllim  @  tot_agnvllim[aux_cdagenci]
        ger_agnsdbtl  @  tot_agnsdbtl[aux_cdagenci]
        ger_qtcstdct  @  tot_qtcstdct[aux_cdagenci]
        ger_vlcstdct  @  tot_vlcstdct[aux_cdagenci]    
        WITH FRAME f_totalger_278.

ASSIGN tot_nmresage = "P. FISICA   ==>"
       tot_agnsddis[aux_cdagenci] = ger_agnsddis - jur_agnsddis -
                                    crl_agnsddis - adm_agnsddis
       tot_agnvllim[aux_cdagenci] = ger_agnvllim - jur_agnvllim -
                                    crl_agnvllim - adm_agnsddis
       tot_agnsdbtl[aux_cdagenci] = ger_agnsdbtl - jur_agnsdbtl -
                                    crl_agnsdbtl - adm_agnsdbtl.
      
DOWN 3 STREAM str_2 WITH FRAME f_totalger_278.

DISPLAY STREAM str_2
        tot_nmresage
        tot_agnsddis[aux_cdagenci]
        tot_agnvllim[aux_cdagenci]
        tot_agnsdbtl[aux_cdagenci]
        WITH FRAME f_totalger_278.

tot_nmresage = "P. JURIDICA ==>".

DOWN 3 STREAM str_2 WITH FRAME f_totalger_278.

DISPLAY STREAM str_2
        tot_nmresage
        jur_agnsddis  @  tot_agnsddis[aux_cdagenci]
        jur_agnvllim  @  tot_agnvllim[aux_cdagenci]
        jur_agnsdbtl  @  tot_agnsdbtl[aux_cdagenci]
        WITH FRAME f_totalger_278.

tot_nmresage = "CHEQUE ADM. ==>".

DOWN 3 STREAM str_2 WITH FRAME f_totalger_278.

DISPLAY STREAM str_2
        tot_nmresage
        adm_agnsddis  @  tot_agnsddis[aux_cdagenci]
        adm_agnvllim  @  tot_agnvllim[aux_cdagenci]
        adm_agnsdbtl  @  tot_agnsdbtl[aux_cdagenci]
        WITH FRAME f_totalger_278.

tot_nmresage = "CRED. LIQ.  ==>".

DOWN 3 STREAM str_2 WITH FRAME f_totalger_278.

DISPLAY STREAM str_2
        tot_nmresage
        crl_agnsddis  @  tot_agnsddis[aux_cdagenci]
        crl_agnvllim  @  tot_agnvllim[aux_cdagenci]
        crl_agnsdbtl  @  tot_agnsdbtl[aux_cdagenci]
        WITH FRAME f_totalger_278.

OUTPUT STREAM str_2 CLOSE.

glb_infimsol = TRUE.

/* Copiar arquivos para /rlnsv */
UNIX SILENT VALUE("cp rl/crrl278* rlnsv").

RUN fontes/fimprg.p.

/* .......................................................................... */


