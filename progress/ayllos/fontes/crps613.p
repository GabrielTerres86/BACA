/* ............................................................................

   Programa: Fontes/crps613.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : André Santos - Supero
   Data    : OUTUBRO/2011                        Ultima atualizacao: 20/02/2019
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Relatorio - Movimento Protesto de Titulos.
               Emite relatorio 614
               
   Alteracoes: 18/11/2011 - Alterado busca de registros de titulos sustados.
                            (Rafael)
                            
               08/12/2011 - Retirado critica 190. Nao ha arquivos importados
                            a serem processados. (Rafael)
                          - Incluido nova ocorrencia (3 - INST AUTOM DE 
                            PROTESTO NAO PROCESSADA). (Rafael)
                            
               27/12/2011 - Nao considerar data do dia ao mostrar titulos
                            sem conf de inst de protesto. (Rafael)
                            
               18/05/2012 - Alterado for each da ocorrencia 4 pois o titulo
                            sem conf de inst de protesto aparecia varias
                            vezes no relatorio. (Rafael)
                            
               02/08/2012 - Ajuste do format no campo nmrescop (David Kruger).
               
               14/08/2013 - Inclusao de novo ítem no relatório: "10 - SEM 
                            CONFIRMACAO DE ENTRADA EM CARTORIO" (Carlos)
               
               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).        
                            
               02/01/2014 - Melhoria leitura tabela crapcob (Daniel).      
               
               27/02/2014 - Mudancas nos formats p/ comportar o aumento do nome 
                            resumido das cooperativas para 20 chars (Carlos)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
							
............................................................................ */

{ includes/var_batch.i "NEW" }  

/* chamado oracle - 20/02/2019 - Chamado REQ0039739 */
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.   /*  Para relatorio de criticas  */

DEF TEMP-TABLE tt-rel-analitico NO-UNDO
    FIELD cdcooper   AS INT
    FIELD nmrescop   AS CHAR
    FIELD dsocorre   AS CHAR
    FIELD cdagenci  LIKE craprej.cdagenci
    FIELD nrdconta  LIKE crapass.nrdconta
    FIELD nrdctabb  LIKE crapass.nrdconta
    FIELD nrnosnum  LIKE crapcob.nrnosnum
    FIELD nrdocmto  LIKE crapcob.dsdoccop
    FIELD dtvencto    AS DATE
    FIELD vllanmto  LIKE craplcm.vllanmto
    FIELD dtmvtolt    AS DATE
    FIELD cdocorre   AS INT.
    


/*** Campos novos ou utilizados ***/
DEF VAR aux_qtdregis AS INT                                      NO-UNDO.
DEF VAR aux_vltotreg AS DECI                                     NO-UNDO.

DEF VAR aux_cdcopini AS INTE                                     NO-UNDO.
DEF VAR aux_cdcopfim AS INTE                                     NO-UNDO.
DEF VAR aux_dtmvtopr AS DATE                                     NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                     NO-UNDO.

DEF VAR rel_qtdtotal AS INTE                                     NO-UNDO.
DEF VAR rel_vlrtotal AS DECI                                     NO-UNDO. 

/* Relatorios */
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(50)" EXTENT 5          NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                 NO-UNDO.

FORM aux_dtmvtopr       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     SKIP
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 150 FRAME f_cab.

FORM SKIP
     "OCORRENCIA:"             AT   1
     tt-rel-analitico.dsocorre AT  13 FORMAT "x(45)"
     SKIP(1)
     "COOP"                    AT   1
     "PA"                      AT  23 
     "CONTA/DV"                AT  29
     "CONTA BB"                AT  43
     "NOSSO NUMERO"            AT  59
     "N DOCTO"                 AT  76
     "DT VENCTO"               AT  94
     "VLR BOLETO"              AT  109
     "DT MOVTO"                AT  122
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_head_analitico_central.

FORM SKIP
     "OCORRENCIA:"             AT   1
     tt-rel-analitico.dsocorre AT  13 FORMAT "x(45)"
     SKIP(1)
     "PA"                      AT   2
     "CONTA/DV"                AT  10
     "CONTA BB"                AT  23
     "NOSSO NUMERO"            AT  33
     "N DOCTO"                 AT  55
     "DT VENCTO"               AT  72
     "VLR BOLETO"              AT  89
     "DT MOVTO"                AT 102
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_head_analitico_coop.


FORM tt-rel-analitico.nmrescop FORMAT "X(20)"              NO-LABEL AT   1
     tt-rel-analitico.cdagenci FORMAT "zz9"                NO-LABEL AT  22 
     tt-rel-analitico.nrdconta FORMAT "z,zzz,zzz,9"        NO-LABEL AT  26
     tt-rel-analitico.nrdctabb FORMAT "z,zzz,zzz,9"        NO-LABEL AT  40
     tt-rel-analitico.nrnosnum FORMAT "x(20)"              NO-LABEL AT  54
     tt-rel-analitico.nrdocmto FORMAT "x(15)"              NO-LABEL AT  76
     tt-rel-analitico.dtvencto FORMAT "99/99/99"           NO-LABEL AT  94
     tt-rel-analitico.vllanmto FORMAT "zzz,zzz,zz9.99"     NO-LABEL AT 105
     tt-rel-analitico.dtmvtolt FORMAT "99/99/99"           NO-LABEL AT 122
     WITH NO-BOX NO-LABELS DOWN COL 1 WIDTH 132 FRAME f_relat_analitico_central.

FORM tt-rel-analitico.cdagenci FORMAT "zz9"                NO-LABEL AT   1 
     tt-rel-analitico.nrdconta FORMAT "z,zzz,zzz,9"        NO-LABEL AT   7
     tt-rel-analitico.nrdctabb FORMAT "z,zzz,zzz,9"        NO-LABEL AT  20
     tt-rel-analitico.nrnosnum FORMAT "x(20)"              NO-LABEL AT  33
     tt-rel-analitico.nrdocmto FORMAT "x(15)"              NO-LABEL AT  55
     tt-rel-analitico.dtvencto FORMAT "99/99/99"           NO-LABEL AT  73
     tt-rel-analitico.vllanmto FORMAT "zzz,zzz,zz9.99"     NO-LABEL AT  85
     tt-rel-analitico.dtmvtolt FORMAT "99/99/99"           NO-LABEL AT 102
     WITH NO-BOX NO-LABELS DOWN COL 1 WIDTH 132 FRAME f_relat_analitico_coop.


FORM 
  tt-rel-analitico.dsocorre FORMAT "x(45)"              LABEL "OCORRENCIA" AT 1
  rel_qtdtotal              FORMAT "zzzz9"              LABEL "QTDE"       AT 47
  rel_vlrtotal              FORMAT "zzz,zzz,zzz,zz9.99" LABEL "VLR BOLETO" AT 54
  WITH NO-BOX NO-LABELS DOWN COL 1 WIDTH 132 FRAME f_relat_sintetico.

FORM SKIP(1)
     "TOTAIS"               AT   30
     aux_qtdregis           AT   47 FORMAT "zzzz9"
     aux_vltotreg           AT   58 FORMAT "zzz,zzz,zz9.99"
     SKIP(3)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_tot_sintetico.

FORM SKIP(1)
     "TOTAIS"               AT  65
     aux_qtdregis           AT  82  FORMAT "z,zzz,zz9"   
     aux_vltotreg           AT  101 FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP(2)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_tot_analitico_central.

FORM SKIP(1)
     "TOTAIS"               AT  44
     aux_qtdregis           AT  61 FORMAT "z,zzz,zz9"   
     aux_vltotreg           AT  81 FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP(2)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_tot_analitico_coop.          

/********************************* Inicio ***********************************/

ASSIGN glb_cdprogra = "crps613".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

IF   glb_cdcooper = 3 THEN
     ASSIGN aux_cdcopini = 1
            aux_cdcopfim = 999.
ELSE 
     ASSIGN aux_cdcopini = glb_cdcooper
            aux_cdcopfim = glb_cdcooper.

DO WHILE TRUE:

   FIND FIRST crapdat WHERE crapdat.cdcooper = glb_cdcooper
                            NO-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE crapdat   THEN
        IF   LOCKED crapdat   THEN
             DO:
                 PAUSE 1 NO-MESSAGE.
                 NEXT.
             END.
        ELSE
             glb_cdcritic = 1.
   ELSE
        ASSIGN glb_cdcritic = 0
               glb_dtmvtolt = crapdat.dtmvtolt
               aux_dtmvtopr = crapdat.dtmvtopr.

   LEAVE.

END.



/**** PROCESSAMENTO DOS DADOS ******/
RUN pi_processar_dados (INPUT aux_cdcopini,
                        INPUT aux_cdcopfim).


/**** GERACAO DO RELATORIO ******/         
IF glb_cdcooper <> 3 THEN
    RUN pi_gera_relatorio.

ELSE DO: /* quando for 3 **/
    FOR EACH crapcop WHERE crapcop.cdcooper <> 3 NO-LOCK:
        RUN pi_gera_relatorio.
    END.
END.

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS613.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS613.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }   

RUN fontes/fimprg.p.

/*...........................................................................*/

PROCEDURE pi_processar_dados:
    
    DEF INPUT PARAM par_cdcopini AS INT                                NO-UNDO.
    DEF INPUT PARAM par_cdcopfim AS INT                                NO-UNDO.
                                                                       
    DEF VAR aux_dtsement AS DATE                                       NO-UNDO.

    /* SOLICITAÇÃO DE REMESSA */
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= aux_cdcopfim NO-LOCK
          ,EACH crapcco
          WHERE crapcco.cdcooper = crapcop.cdcooper
            AND crapcco.cddbanco = 001
            AND crapcco.dsorgarq = "PROTESTO"
            NO-LOCK
          ,EACH craprem
          WHERE craprem.cdcooper = crapcco.cdcooper
            AND craprem.nrcnvcob = crapcco.nrconven
            AND craprem.cdocorre = 1
            AND craprem.dtaltera = aux_dtmvtopr
            NO-LOCK
          ,EACH crapcob
          WHERE crapcob.cdcooper = craprem.cdcooper
            AND crapcob.cdbandoc = crapcco.cddbanco
            AND crapcob.nrdctabb = crapcco.nrdctabb
            AND crapcob.nrcnvcob = craprem.nrcnvcob
            AND crapcob.nrdconta = craprem.nrdconta
            AND crapcob.nrdocmto = craprem.nrdocmto
            NO-LOCK
          ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:

        RUN pi_cria_tt (INPUT 1,
                        INPUT "SOLICITACAO DE REMESSA",
                        INPUT craprem.nrdconta,
                        INPUT craprem.dtaltera).

    END.

    /* ENTRADA */ 
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.dsorgarq = "PROTESTO"
         NO-LOCK 
       ,EACH crapcre
       WHERE crapcre.cdcooper = crapcco.cdcooper
         AND crapcre.nrcnvcob = crapcco.nrconven
         AND crapcre.dtmvtolt = glb_dtmvtolt
         AND crapcre.intipmvt = 2
         NO-LOCK
       ,EACH crapret
       WHERE crapret.cdcooper = crapcre.cdcooper
         AND crapret.nrcnvcob = crapcre.nrcnvcob
         AND crapret.nrremret = crapcre.nrremret
         AND crapret.cdocorre = 2
         NO-LOCK   
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapret.cdcooper
         AND crapcob.cdbandoc = crapcco.cddbanco
         AND crapcob.nrdctabb = crapcco.nrdctabb
         AND crapcob.nrcnvcob = crapret.nrcnvcob
         AND crapcob.nrdconta = crapret.nrdconta
         AND crapcob.nrdocmto = crapret.nrdocmto
         AND crapcob.incobran = 0
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:

        RUN pi_cria_tt (INPUT 2,
                        INPUT "ENTRADA",
                        INPUT crapret.nrdconta,
                        INPUT crapret.dtaltera).

    END.

    /* INSTR AUTOM DE PROTESTO NAO PROCESSADA */ 
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         AND crapcco.dsorgarq = "INTERNET"
         NO-LOCK   
       ,EACH crapceb
       where crapceb.cdcooper = crapcco.cdcooper
         AND crapceb.nrconven = crapcco.nrconven
         AND crapceb.insitceb = 1
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapceb.cdcooper
         AND crapcob.nrcnvcob = crapceb.nrconven
         AND crapcob.nrdconta = crapceb.nrdconta
         AND crapcob.incobran = 0
         AND crapcob.flgdprot = TRUE 
         AND (crapcob.dtvencto + crapcob.qtdiaprt) < glb_dtmvtolt
         AND crapcob.dtdocmto < glb_dtmvtolt
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
         AND crapass.nrdconta = crapcob.nrdconta:

       FIND FIRST crapret NO-LOCK 
            WHERE crapret.cdcooper = crapcob.cdcooper
              AND crapret.nrcnvcob = crapcob.nrcnvcob
              AND crapret.nrdconta = crapcob.nrdconta
              AND crapret.nrdocmto = crapcob.nrdocmto
              AND (crapret.cdocorre = 19 OR /* conf. inst protesto */
                   crapret.cdocorre = 23)   /* remessa a cartorio */
              NO-ERROR.
       
       IF NOT AVAIL crapret THEN 
          RUN pi_cria_tt (INPUT 3,
                          INPUT "INST AUTOM DE PROTESTO NAO PROCESSADA",
                          INPUT crapcob.nrdconta,
                          INPUT glb_dtmvtolt).
    
    END.

    /* SEM CONFIRMAÇÃO DE PROTESTO */ 
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         NO-LOCK   
       ,EACH crapceb
       WHERE crapceb.cdcooper = crapcco.cdcooper
         AND crapceb.nrconven = crapcco.nrconven
         AND crapceb.insitceb = 1
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapceb.cdcooper
         AND crapcob.nrcnvcob = crapceb.nrconven
         AND crapcob.nrdconta = crapceb.nrdconta
         AND crapcob.incobran = 0
         AND crapcob.flgdprot = TRUE 
         AND (crapcob.dtvencto + crapcob.qtdiaprt) < glb_dtmvtolt
         AND crapcob.dtdocmto < glb_dtmvtolt
         NO-LOCK 
       ,FIRST craprem
        WHERE craprem.cdcooper = crapcob.cdcooper
          AND craprem.nrcnvcob = crapcob.nrcnvcob
          AND craprem.nrdconta = crapcob.nrdconta
          AND craprem.nrdocmto = crapcob.nrdocmto
          AND craprem.cdocorre = 9
          AND craprem.dtaltera < glb_dtmvtolt
          NO-LOCK
       ,FIRST crapass 
        WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:

       FIND FIRST crapret NO-LOCK 
            WHERE crapret.cdcooper = crapcob.cdcooper
              AND crapret.nrcnvcob = crapcob.nrcnvcob
              AND crapret.nrdconta = crapcob.nrdconta
              AND crapret.nrdocmto = crapcob.nrdocmto
              AND crapret.cdocorre = 19 NO-ERROR.
       
       IF NOT AVAIL crapret THEN 
          
          RUN pi_cria_tt (INPUT 4,
                          INPUT "SEM CONFIRMACAO DE PROTESTO",
                          INPUT crapcob.nrdconta,
                          INPUT glb_dtmvtolt).
    
    END.

    /* SEM CONFIRMAÇÃO DE BAIXA */ 
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         NO-LOCK   
       ,EACH crapceb
       where crapceb.cdcooper = crapcco.cdcooper
         AND crapceb.nrconven = crapcco.nrconven
         AND crapceb.insitceb = 1
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapceb.cdcooper
         AND crapcob.cdbandoc = crapcco.cddbanco
         AND crapcob.nrdctabb = crapcco.nrdctabb
         AND crapcob.nrcnvcob = crapceb.nrconven
         AND crapcob.nrdconta = crapceb.nrdconta
         AND crapcob.incobran = 0
         /* insitcrt = 2 -> c/inst de sust 
            insitcrt = 3 -> em cartorio 
            insitcrt = 4 -> sustados */
         AND (crapcob.insitcrt = 2 OR 
              crapcob.insitcrt = 3 OR
              crapcob.insitcrt = 4)
         AND crapcob.dtsitcrt <= glb_dtmvtolt
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
         AND crapass.nrdconta = crapcob.nrdconta:

       FIND FIRST craprem NO-LOCK 
            WHERE craprem.cdcooper = crapcob.cdcooper
              AND craprem.nrcnvcob = crapcob.nrcnvcob
              AND craprem.nrdconta = crapcob.nrdconta
              AND craprem.nrdocmto = crapcob.nrdocmto
              AND (craprem.cdocorre = 2 OR
                   craprem.cdocorre = 10) NO-ERROR.
       
       IF AVAIL craprem THEN        
          RUN pi_cria_tt (INPUT 5,
                          INPUT "SEM CONFIRMACAO DE BAIXA",
                          INPUT crapcob.nrdconta,
                          INPUT glb_dtmvtolt).
    END.


    /* EM CARTORIO */
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         NO-LOCK 
        ,EACH crapcre
        WHERE crapcre.cdcooper = crapcco.cdcooper
          AND crapcre.nrcnvcob = crapcco.nrconven
          AND crapcre.dtmvtolt = glb_dtmvtolt
          AND crapcre.intipmvt = 2
          NO-LOCK
        ,EACH crapret
        WHERE crapret.cdcooper = crapcre.cdcooper
          AND crapret.nrcnvcob = crapcre.nrcnvcob
          AND crapret.nrremret = crapcre.nrremret
          AND crapret.cdocorre = 23
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapret.cdcooper
         AND crapcob.cdbandoc = crapcco.cddbanco
         AND crapcob.nrdctabb = crapcco.nrdctabb
         AND crapcob.nrcnvcob = crapret.nrcnvcob
         AND crapcob.nrdconta = crapret.nrdconta
         AND crapcob.nrdocmto = crapret.nrdocmto
         AND crapcob.incobran = 0
         AND crapcob.insitcrt = 3 /* em cartorio */
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:
       
        RUN pi_cria_tt (INPUT 6,
                        INPUT "EM CARTORIO",
                        INPUT crapcob.nrdconta,
                        INPUT crapret.dtaltera). 
    END.

    /* LIQUIDADO EM CARTORIO */
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         NO-LOCK   
        ,EACH crapcre
        WHERE crapcre.cdcooper = crapcco.cdcooper
          AND crapcre.nrcnvcob = crapcco.nrconven
          AND crapcre.dtmvtolt = glb_dtmvtolt
          AND crapcre.intipmvt = 2
          NO-LOCK
        ,EACH crapret
        WHERE crapret.cdcooper = crapcre.cdcooper
          AND crapret.nrcnvcob = crapcre.nrcnvcob
          AND crapret.nrremret = crapcre.nrremret
          AND crapret.cdocorre = 6
          AND crapret.cdmotivo = "08"
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapret.cdcooper
         AND crapcob.cdbandoc = crapcco.cddbanco
         AND crapcob.nrdctabb = crapcco.nrdctabb
         AND crapcob.nrcnvcob = crapret.nrcnvcob
         AND crapcob.nrdconta = crapret.nrdconta
         AND crapcob.nrdocmto = crapret.nrdocmto
         AND crapcob.incobran = 5
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:
       
        RUN pi_cria_tt (INPUT 7,
                        INPUT "LIQUIDADO EM CARTORIO",
                        INPUT crapcob.nrdconta,
                        INPUT crapret.dtaltera).
    END.

    /* SUSTADOS */
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini  
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         NO-LOCK 
       ,EACH crapcre
       WHERE crapcre.cdcooper = crapcco.cdcooper
         AND crapcre.nrcnvcob = crapcco.nrconven
         AND crapcre.dtmvtolt = glb_dtmvtolt
         AND crapcre.intipmvt = 2
         NO-LOCK
       ,EACH crapret
       WHERE crapret.cdcooper = crapcre.cdcooper
         AND crapret.nrcnvcob = crapcre.nrcnvcob
         AND crapret.nrremret = crapcre.nrremret
         AND crapret.cdocorre = 28
         AND crapret.cdmotivo = "09"
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapret.cdcooper
         AND crapcob.cdbandoc = crapcco.cddbanco
         AND crapcob.nrdctabb = crapcco.nrdctabb
         AND crapcob.nrcnvcob = crapret.nrcnvcob
         AND crapcob.nrdconta = crapret.nrdconta
         AND crapcob.nrdocmto = crapret.nrdocmto
         AND crapcob.incobran = 0
         AND crapcob.insitcrt = 4 /* sustado */
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:
       
        RUN pi_cria_tt (INPUT 8,
                        INPUT "SUSTADOS",
                        INPUT crapcob.nrdconta,
                        INPUT crapret.dtaltera).
    END.

    /* PROTESTADOS */
    FOR EACH crapcop
       WHERE crapcop.cdcooper >= par_cdcopini
         AND crapcop.cdcooper <= par_cdcopfim NO-LOCK 
       ,EACH crapcco
       WHERE crapcco.cdcooper = crapcop.cdcooper
         AND crapcco.cddbanco = 001
         AND crapcco.flgregis = TRUE
         NO-LOCK   
       ,EACH crapcre
       WHERE crapcre.cdcooper = crapcco.cdcooper
         AND crapcre.nrcnvcob = crapcco.nrconven
         AND crapcre.dtmvtolt = glb_dtmvtolt
         AND crapcre.intipmvt = 2
         NO-LOCK
       ,EACH crapret
       WHERE crapret.cdcooper = crapcre.cdcooper
         AND crapret.nrcnvcob = crapcre.nrcnvcob
         AND crapret.nrremret = crapcre.nrremret
         AND ((crapret.cdocorre = 09 AND crapret.cdmotivo = "14") OR
       (crapret.cdocorre = 25))
         NO-LOCK 
       ,EACH crapcob
       WHERE crapcob.cdcooper = crapret.cdcooper
         AND crapcob.cdbandoc = crapcco.cddbanco
         AND crapcob.nrdctabb = crapcco.nrdctabb
         AND crapcob.nrcnvcob = crapret.nrcnvcob
         AND crapcob.nrdconta = crapret.nrdconta
         AND crapcob.nrdocmto = crapret.nrdocmto
         AND crapcob.incobran = 3
         NO-LOCK 
       ,FIRST crapass WHERE crapass.cdcooper = crapcob.cdcooper
          AND crapass.nrdconta = crapcob.nrdconta:
       
        RUN pi_cria_tt (INPUT 9,
                        INPUT "PROTESTADOS",
                        INPUT crapcob.nrdconta ,
                        INPUT crapret.dtaltera).
    END.

    /* 10 - SEM CONFIRMACAO DE ENTRADA EM CARTORIO */
    FOR EACH crapcop
        WHERE crapcop.cdcooper >= par_cdcopini AND 
              crapcop.cdcooper <= par_cdcopfim NO-LOCK 
    ,EACH crapcco 
        WHERE crapcco.cdcooper = crapcop.cdcooper AND 
              crapcco.cddbanco = 001              AND 
              crapcco.flgregis = TRUE NO-LOCK   
    ,EACH crapceb 
        WHERE crapceb.cdcooper = crapcco.cdcooper AND 
              crapceb.nrconven = crapcco.nrconven AND 
              crapceb.insitceb = 1 NO-LOCK 
    ,EACH crapcob 
        WHERE crapcob.cdcooper = crapceb.cdcooper AND 
              crapcob.nrcnvcob = crapceb.nrconven AND 
              crapcob.nrdconta = crapceb.nrdconta AND 
              crapcob.incobran = 0                AND 
              crapcob.flgdprot = TRUE             AND 
             (crapcob.dtvencto + crapcob.qtdiaprt) < TODAY AND 
              crapcob.dtdocmto < TODAY NO-LOCK 
    ,FIRST craprem 
        WHERE craprem.cdcooper = crapcob.cdcooper AND 
              craprem.nrcnvcob = crapcob.nrcnvcob AND 
              craprem.nrdconta = crapcob.nrdconta AND 
              craprem.nrdocmto = crapcob.nrdocmto AND 
              craprem.cdocorre = 9                AND 
              craprem.dtaltera < TODAY NO-LOCK
    ,FIRST crapass 
        WHERE crapass.cdcooper = crapcob.cdcooper AND 
              crapass.nrdconta = crapcob.nrdconta:

        FIND FIRST crapret NO-LOCK 
            WHERE crapret.cdcooper = crapcob.cdcooper AND 
                  crapret.nrcnvcob = crapcob.nrcnvcob AND 
                  crapret.nrdconta = crapcob.nrdconta AND 
                  crapret.nrdocmto = crapcob.nrdocmto AND 
                  crapret.cdocorre = 19 NO-ERROR.
        
        IF AVAIL crapret THEN
            DO:
                IF crapret.dtocorre < TODAY - 7 THEN
                    DO:
                        
                        ASSIGN aux_dtsement = crapret.dtocorre.

                        FIND FIRST crapret NO-LOCK 
                            WHERE crapret.cdcooper = crapcob.cdcooper AND 
                                  crapret.nrcnvcob = crapcob.nrcnvcob AND 
                                  crapret.nrdconta = crapcob.nrdconta AND 
                                  crapret.nrdocmto = crapcob.nrdocmto AND 
                                  crapret.cdocorre = 23 NO-ERROR.

                        IF NOT AVAIL crapret THEN
                            RUN pi_cria_tt (INPUT 10,
                                            INPUT "SEM CONFIRMACAO DE ENTRADA EM CARTORIO",
                                            INPUT crapcob.nrdconta ,
                                            INPUT aux_dtsement).
                    END.
           END.
    END.

END PROCEDURE.

/*...........................................................................*/

PROCEDURE pi_cria_tt:

    DEF INPUT PARAM par_cdocorre AS INT                                NO-UNDO.
    DEF INPUT PARAM par_dsocorre AS CHAR                               NO-UNDO. 
    DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
                                                                               

    CREATE tt-rel-analitico.
    ASSIGN tt-rel-analitico.cdcooper = crapcob.cdcooper
           tt-rel-analitico.nmrescop = crapcop.nmrescop
           tt-rel-analitico.dsocorre = STRING(par_cdocorre, "z9") + " - " + 
                                       par_dsocorre
           tt-rel-analitico.cdagenci = crapass.cdagenci
           tt-rel-analitico.nrdconta = par_nrdconta
           tt-rel-analitico.nrdctabb = crapcco.nrdctabb
           tt-rel-analitico.nrnosnum = crapcob.nrnosnum
           tt-rel-analitico.nrdocmto = crapcob.dsdoccop
           tt-rel-analitico.dtvencto = crapcob.dtvencto
           tt-rel-analitico.vllanmto = crapcob.vltitulo
           tt-rel-analitico.dtmvtolt = par_dtmvtolt
           tt-rel-analitico.cdocorre = par_cdocorre.

   
END PROCEDURE.

/*............................................................................*/

PROCEDURE pi_gera_relatorio:
   
    ASSIGN glb_cdcritic = 0.

    

    ASSIGN glb_cdempres    = 11
           glb_cdrelato[1] = 614.
    
   { includes/cabrel132_1.i }

   ASSIGN aux_nmarqimp = "rl/crrl614.lst". 
   
   OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

   VIEW STREAM str_1 FRAME f_cabrel132_1.


   DISPLAY STREAM str_1  aux_dtmvtopr
           WITH FRAME f_cab.


   DISP STREAM str_1 SKIP(2).


   /*** Relatorio Sintetico ***/
   ASSIGN  aux_qtdregis = 0   rel_qtdtotal = 0
           aux_vltotreg = 0   rel_vlrtotal = 0.


   FOR EACH tt-rel-analitico NO-LOCK
        BREAK BY tt-rel-analitico.cdocorre:

       IF   LINE-COUNTER(str_1) > 84 THEN
            PAGE STREAM str_1.

       IF FIRST-OF(tt-rel-analitico.cdocorre) THEN
           ASSIGN rel_qtdtotal = 0 
                  rel_vlrtotal = 0.

       ASSIGN  rel_qtdtotal = rel_qtdtotal + 1
               rel_vlrtotal = rel_vlrtotal + tt-rel-analitico.vllanmto
               aux_qtdregis = aux_qtdregis + 1
               aux_vltotreg = aux_vltotreg + tt-rel-analitico.vllanmto.
       
       
       IF LAST-OF(tt-rel-analitico.cdocorre) THEN DO:
      
           DISPLAY STREAM str_1 tt-rel-analitico.dsocorre
                                rel_qtdtotal
                                rel_vlrtotal
                                WITH FRAME f_relat_sintetico.
          DOWN STREAM str_1 WITH FRAME f_relat_sintetico.
       END.

   END.

   IF  aux_qtdregis > 0 THEN
       DISPLAY STREAM str_1 aux_qtdregis  aux_vltotreg  
                            WITH FRAME f_tot_sintetico.
   /**FIM DO RELAT SINTETICO **/




   /*** Relatorio Analitico ***/
   ASSIGN aux_qtdregis = 0
          aux_vltotreg = 0.
          
   FOR EACH tt-rel-analitico
      BREAK BY tt-rel-analitico.cdocorre
            BY tt-rel-analitico.cdcooper
            BY tt-rel-analitico.cdagenci
            BY tt-rel-analitico.nrdconta
            BY tt-rel-analitico.nrdocmto:
       
       IF   LINE-COUNTER(str_1) > 84 THEN DO:
            PAGE STREAM str_1.

           IF glb_cdcooper = 3 THEN
               DISPLAY STREAM str_1 tt-rel-analitico.dsocorre
               WITH FRAME f_head_analitico_central. 
           ELSE
               DISPLAY STREAM str_1 tt-rel-analitico.dsocorre
               WITH FRAME f_head_analitico_coop.
                
       END.


       ASSIGN aux_qtdregis = aux_qtdregis + 1
              aux_vltotreg = aux_vltotreg + tt-rel-analitico.vllanmto.
              

       IF  FIRST-OF(tt-rel-analitico.cdocorre) THEN DO:
           IF glb_cdcooper = 3 THEN
               DISPLAY STREAM str_1 tt-rel-analitico.dsocorre
               WITH FRAME f_head_analitico_central. 
           ELSE
               DISPLAY STREAM str_1 tt-rel-analitico.dsocorre
               WITH FRAME f_head_analitico_coop.
       END.

       /** Dados **/
       IF glb_cdcooper = 3 THEN DO:
      
           DISPLAY STREAM str_1 tt-rel-analitico.nmrescop
                                tt-rel-analitico.cdagenci
                                tt-rel-analitico.nrdconta
                                tt-rel-analitico.nrdctabb
                                tt-rel-analitico.nrnosnum
                                tt-rel-analitico.nrdocmto
                                tt-rel-analitico.dtvencto
                                tt-rel-analitico.vllanmto
                                tt-rel-analitico.dtmvtolt 
                                WITH FRAME f_relat_analitico_central.
          DOWN WITH FRAME f_relat_analitico_central.
       END.
       ELSE DO:
           DISPLAY STREAM str_1 tt-rel-analitico.cdagenci
                                tt-rel-analitico.nrdconta
                                tt-rel-analitico.nrdctabb
                                tt-rel-analitico.nrnosnum
                                tt-rel-analitico.nrdocmto
                                tt-rel-analitico.dtvencto
                                tt-rel-analitico.vllanmto
                                tt-rel-analitico.dtmvtolt 
                                WITH FRAME f_relat_analitico_coop.
           DOWN WITH FRAME f_relat_analitico_coop.
       END.

       /* Totais */
       IF  LAST-OF(tt-rel-analitico.cdocorre) THEN DO:

           IF glb_cdcooper = 3 THEN
               DISPLAY STREAM str_1 aux_qtdregis  aux_vltotreg 
                   WITH FRAME f_tot_analitico_central.
           ELSE
               DISPLAY STREAM str_1 aux_qtdregis  aux_vltotreg 
                   WITH FRAME f_tot_analitico_coop.

           ASSIGN aux_qtdregis = 0
                  aux_vltotreg = 0.
       END.

   END.

   OUTPUT STREAM str_1 CLOSE.
              
   ASSIGN glb_nrcopias = 1
          glb_nmformul = "132col"
          glb_nmarqimp = aux_nmarqimp
          glb_cdcritic = 0.
    
   RUN fontes/imprim.p.
       
   
END PROCEDURE. /* fim */

/*............................................................................*/


