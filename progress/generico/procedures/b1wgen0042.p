/*..............................................................................

   Programa: b1wgen0042.p                  
   Autor   : Paulo - Precise.
   Data    : 06/08/2009                        Ultima atualizacao: 25/04/2014 

   Dados referentes ao programa:

   Objetivo  : BO PARA VALIDAR FORMATO DE ARQUIVO PARA FOLHA.
               PROCEDURE VALIDA ARQUIVO.
               Baseada nos programa fontes/valida.p.

               BO COM ROTINAS DE APOIO PARA O SOL062.P
                  - GRAVA LOTE, ALTERA OU ELIMINA LOE DE ARQUIVO A SER LIDO
                  - VALIDA LAY-OUT DE ARQUIVO.
                  - AGENDA IMPORTAÇÃO DO ARQUIVO OU CHAMA O PROGRAMA PARA
                    IMPORTAÇÃO INSTANTANEA DO ARQUIVO.
               ROTINAS DOS PROGRAMAS CRPS120_1, CRPS120_2,CRPS120_3,LELEM,
                                     CRPS120_L, CRPS120_R,CRPS120_E.

   Alteracoes: 11/11/2009 - Alteracao dos parametros recebidos pela a funcao 
                           "consiste_arquivo_sol" e inclusao do cdcooper no
                           FIND FIRST nesta funcao. (Guilherme / Precise).

               19/05/2010 - Desativar Rating quando liquidado o Emprestimo
                            (Gabriel).

               18/06/2012 - Alteracao na leitura da craptco (David Kruger).  

               21/01/2013 - Removido o indice crapass4 (Daniele).           

               20/12/2013 - Adicionado validate para as tabelas craplem,
                            craplct, craplcm, craplot, craplcs, craprej,
                            crapfol (Tiago).             

               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074). 

               15/05/2015 - Projeto 158 - Servico Folha de Pagto
                            (Andre Santos - SUPERO)
*.............................................................................*/


DEF STREAM str_1.   /* Para arquivos de dados */
DEF STREAM str_2.   /* Para arquivos de dados */
DEF STREAM str_3.   /* Para arquivos de dados */

{sistema/generico/includes/b1wgen0042tt.i}


DEF VAR aux_cdagenci AS INTE     INIT 1                             NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE     INIT 100                           NO-UNDO.
                                                                   
                                                                   
PROCEDURE lista_arquivos:
                                                                    
    DEF INPUT  PARAM  par_cdcooper AS INTE                          NO-UNDO.
    DEF INPUT  PARAM  par_tpintegr AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-listaarq. 
    

    DEF VAR aux_nmarqint AS CHAR    FORMAT "x(60)"                  NO-UNDO.    
    DEF VAR aux_dstitulo AS CHAR                                    NO-UNDO.

    
    EMPTY TEMP-TABLE tt-listaarq.


    INPUT THROUGH ls integra NO-ECHO.

    REPEAT:

        SET aux_nmarqint WITH NO-BOX NO-LABELS FRAME f_ls.
        
        IF   SUBSTRING(aux_nmarqint,1,1) <> par_tpintegr   THEN
             NEXT.
        
        IF   SUBSTRING(aux_nmarqint,1,3) = "err"           THEN
             NEXT.
        
        CREATE tt-listaarq.

        IF  par_tpintegr = "f" THEN
            DO:
                IF LENGTH(aux_nmarqint) > 14  THEN  /* cdempres 99999 */ 
                    ASSIGN tt-listaarq.cdempres = 
                                        INTEGER(SUBSTR(aux_nmarqint,02,5))
                           tt-listaarq.dtrefere = 
                                        DATE(INTEGER(SUBSTR(aux_nmarqint,9,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,7,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,11,4)))
                           tt-listaarq.ddcredit = SUBSTR(aux_nmarqint,16,2).
                ELSE
                    ASSIGN tt-listaarq.cdempres = 
                                        INTEGER(SUBSTR(aux_nmarqint,02,2))
                           tt-listaarq.dtrefere = 
                                       DATE(INTEGER(SUBSTR(aux_nmarqint,6,2)),
                                            INTEGER(SUBSTR(aux_nmarqint,4,2)),
                                            INTEGER(SUBSTR(aux_nmarqint,8,4)))
                           tt-listaarq.ddcredit = SUBSTR(aux_nmarqint,13,2).
            END.
        ELSE
        IF  par_tpintegr = "e" THEN
            DO:
                IF   LENGTH(aux_nmarqint) > 11  THEN  /* cdempres 99999 */
                    ASSIGN tt-listaarq.cdempres = 
                                        INTEGER(SUBSTR(aux_nmarqint,02,5))
                           tt-listaarq.dtrefere = 
                                       DATE(INTEGER(SUBSTR(aux_nmarqint,9,2)),
                                            INTEGER(SUBSTR(aux_nmarqint,7,2)),
                                            INTEGER(SUBSTR(aux_nmarqint,11,4)))
                           tt-listaarq.ddcredit = "".
                ELSE
                    ASSIGN tt-listaarq.cdempres = 
                                        INTEGER(SUBSTR(aux_nmarqint,02,2))
                           tt-listaarq.dtrefere = 
                                       DATE(INTEGER(SUBSTR(aux_nmarqint,6,2)),
                                            INTEGER(SUBSTR(aux_nmarqint,4,2)),
                                            INTEGER(SUBSTR(aux_nmarqint,8,4)))
                           tt-listaarq.ddcredit = "".
            END.
        ELSE
            ASSIGN tt-listaarq.cdempres = 
                                        INTEGER(SUBSTR(aux_nmarqint,02,5))
                   tt-listaarq.dtrefere = 
                                        DATE(INTEGER(SUBSTR(aux_nmarqint,9,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,7,2)),
                                             INTEGER(SUBSTR(aux_nmarqint,11,4)))
                   tt-listaarq.ddcredit = SUBSTR(aux_nmarqint,16,2). 
            
        FIND crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                           crapemp.cdempres = tt-listaarq.cdempres NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE crapemp THEN
            tt-listaarq.nmempres = STRING(tt-listaarq.cdempres,"99999") + " - " +
                                   FILL("*",15).
        ELSE
            tt-listaarq.nmempres = STRING(tt-listaarq.cdempres,"99999") + " - " +
                                   crapemp.nmresemp.
        
    END.     /*  Fim do REPEAT  */

    INPUT CLOSE.

END PROCEDURE.


/* incluido do sol062_bo */
PROCEDURE consulta_arquivo:

    DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrsolici AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT  PARAM par_nrseqsol AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_cdempres AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsempres AS CHAR FORMAT "x(15)"            NO-UNDO.
    DEF OUTPUT PARAM par_dtrefere AS DATE.
    DEF OUTPUT PARAM par_dialiber AS INT.
                                
    DEF OUTPUT PARAM par_ingerest AS CHAR FORMAT "x(01)"            NO-UNDO.
    DEF OUTPUT PARAM par_inexecut AS CHAR FORMAT "x(01)"            NO-UNDO.
    DEF OUTPUT PARAM par_dssitsol AS CHAR FORMAT "x(15)"            NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE.

    DEFINE VAR aux_contador       AS INTE                           NO-UNDO.      
 

    DO  aux_contador = 1 TO 10:

        FIND crapsol WHERE crapsol.cdcooper = par_cdcooper   AND 
                           crapsol.nrsolici = par_nrsolici   AND
                           crapsol.dtrefere = par_dtmvtolt   AND
                           crapsol.nrseqsol = par_nrseqsol
                           USE-INDEX crapsol1 NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapsol   THEN
             DO:
                 IF   LOCKED crapsol   THEN
                     DO:
                         par_cdcritic = 120.
                         NEXT.
                     END.
                 ELSE
                     DO:
                         par_cdcritic = 115.
                         LEAVE.
                     END.
             END.
        ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.

    END.

    IF   aux_contador = 0 THEN
         IF   crapsol.insitsol <> 1 THEN
              ASSIGN par_cdcritic = 150
                     aux_contador = 1.

    IF   aux_contador <> 0   THEN
         LEAVE.

    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper      AND 
                       crapemp.cdempres = par_cdempres 
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE (crapemp)   THEN
         par_dsempres = " - " + crapemp.nmresemp.
    ELSE
         par_dsempres = " - NAO CADASTRADA".

    ASSIGN par_cdempres = crapsol.cdempres
           par_dtrefere = DATE(INTEGER(SUBSTRING(crapsol.dsparame,4,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,1,2)),
                               INTEGER(SUBSTRING(crapsol.dsparame,7,4)))
           par_dialiber = INTEGER(SUBSTRING(crapsol.dsparame,12,2))
           par_ingerest = IF (SUBSTRING(crapsol.dsparame,17,1))
                          = "1" THEN "S" ELSE "N"
           par_inexecut = IF (SUBSTRING(crapsol.dsparame,15,1))
                              = "1" THEN "S" ELSE "N"
           par_dssitsol = IF crapsol.insitsol = 1 THEN
                            " 1 - A FAZER"         ELSE
                            " 2 - PROCESSADA"
           par_cdcritic = 0.

END PROCEDURE.


PROCEDURE atualiza_crapsol:

DEFINE INPUT PARAMETER   par_cdcooper   AS INTEGER.
DEFINE INPUT PARAMETER   par_nrsolici   AS INTEGER.
DEFINE INPUT PARAMETER   par_dtmvtolt   AS DATE.
DEFINE INPUT PARAMETER   par_nrseqsol   AS INTEGER.
DEFINE INPUT PARAMETER   par_cdempres   AS INTEGER.
DEFINE INPUT PARAMETER   par_dtrefere   AS DATE.
DEFINE INPUT PARAMETER   par_dialiber   AS INT.
DEFINE INPUT PARAMETER   par_ingerest   AS CHAR FORMAT "x(01)".
DEFINE INPUT PARAMETER   par_inexecut   AS CHAR FORMAT "x(01)".

ASSIGN par_inexecut = IF par_inexecut = "S" THEN
                      "1" ELSE "2"
       par_ingerest = IF par_ingerest = "S" THEN
                      "1" ELSE "2".


FIND crapsol 
    WHERE crapsol.cdcooper = par_cdcooper   AND 
          crapsol.nrsolici = par_nrsolici   AND
          crapsol.dtrefere = par_dtmvtolt   AND
          crapsol.nrseqsol = par_nrseqsol
          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

ASSIGN crapsol.cdempres = par_cdempres
       crapsol.dsparame =
       STRING(par_dtrefere,"99/99/9999") + " " +
       STRING(par_dialiber,"99")         + " " +
       STRING(par_inexecut,"9")          + " " +
       STRING(par_ingerest,"9").

RELEASE crapsol.

END PROCEDURE.

PROCEDURE consiste_arquivo_sol:

DEFINE INPUT  PARAMETER  par_cdempres  AS INTEGER.
DEFINE INPUT  PARAMETER  par_dtrefere  AS DATE.
DEFINE INPUT  PARAMETER  par_dialiber  AS INTEGER.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-critic.

FIND FIRST crapsol 
    WHERE crapsol.cdempres = par_cdempres   AND 
          DATE (
          substring(crapsol.dsparame,1,2) + "/" +
          substring(crapsol.dsparame,4,2) + "/" +
          substring(crapsol.dsparame,7,4)) =  par_dtrefere AND
          TRIM(substring(crapsol.dsparame,12,2)) = 
                 TRIM(STRING(par_dialiber,"99")) AND
          crapsol.insitsol = 1
          NO-LOCK NO-ERROR NO-WAIT.
IF AVAIL crapsol THEN
    DO:
        CREATE tt-critic.
        ASSIGN tt-critic.cdcritic = 0
               tt-critic.cdsequen = 1.
               tt-critic.dscritic = "Ja existe solicitacao para este arquivo!" +
                   " Solicitacao nro: " + STRING (crapsol.nrsolici).
        RETURN "NOK".
    END.

END PROCEDURE.

PROCEDURE cria_crapsol:

DEFINE INPUT PARAMETER   par_cdcooper   AS INTEGER.
DEFINE INPUT PARAMETER   par_nrsolici   AS INTEGER.
DEFINE INPUT PARAMETER   par_dtmvtolt   AS DATE.
DEFINE INPUT PARAMETER   par_nrseqsol   AS INTEGER.
DEFINE INPUT PARAMETER   par_cdempres   AS INTEGER.
DEFINE INPUT PARAMETER   par_dtrefere   AS DATE.
DEFINE INPUT PARAMETER   par_dialiber   AS INT.
DEFINE INPUT PARAMETER   par_ingerest   AS CHAR.
DEFINE INPUT PARAMETER   par_inexecut   AS CHAR.

ASSIGN par_inexecut = IF par_inexecut = "S" THEN
                      "1" ELSE "2"
       par_ingerest = IF par_ingerest = "S" THEN
                      "1" ELSE "2".
CREATE crapsol.
ASSIGN crapsol.nrsolici = par_nrsolici 
       crapsol.dtrefere = par_dtmvtolt 
       crapsol.nrseqsol = par_nrseqsol 
       crapsol.cdempres = par_cdempres 
       crapsol.dsparame =
               STRING(par_dtrefere,"99/99/9999") + " " +
               STRING(par_dialiber,"99") + " " +
               STRING(par_inexecut,"9")  + " " +
               STRING(par_ingerest,"9")
       crapsol.insitsol = 1
       crapsol.nrdevias = 1
       crapsol.cdcooper = par_cdcooper. 

RELEASE crapsol.

END PROCEDURE.

    
PROCEDURE deleta_arquivo:

DEFINE INPUT PARAMETER   par_cdcooper   AS INTEGER.
DEFINE INPUT PARAMETER   par_nrsolici   AS INTEGER.
DEFINE INPUT PARAMETER   par_dtmvtolt   AS DATE.
DEFINE INPUT PARAMETER   par_nrseqsol   AS INTEGER.

FIND crapsol 
    WHERE crapsol.cdcooper = par_cdcooper   AND 
          crapsol.nrsolici = par_nrsolici   AND
          crapsol.dtrefere = par_dtmvtolt   AND
          crapsol.nrseqsol = par_nrseqsol
          USE-INDEX crapsol1 EXCLUSIVE-LOCK NO-ERROR.

DELETE crapsol.

END PROCEDURE.

PROCEDURE pesquisa_crapsol:

DEFINE INPUT  PARAMETER   par_cdcooper   AS INTEGER.
DEFINE INPUT  PARAMETER   par_nrsolici   AS INTEGER.
DEFINE INPUT  PARAMETER   par_dtmvtolt   AS DATE.
DEFINE INPUT  PARAMETER   par_nrseqsol   AS INTEGER.
DEFINE OUTPUT PARAMETER   par_cdcritic   AS INTEGER.

FIND crapsol 
     WHERE crapsol.cdcooper = par_cdcooper   AND 
           crapsol.nrsolici = par_nrsolici   AND
           crapsol.dtrefere = par_dtmvtolt   AND
           crapsol.nrseqsol = par_nrseqsol
           USE-INDEX crapsol1 NO-LOCK NO-ERROR NO-WAIT.

IF   AVAILABLE crapsol   THEN
DO:
    ASSIGN par_cdcritic = 118.
    LEAVE.
END.

END PROCEDURE.

PROCEDURE localiza_empresa:

DEFINE INPUT  PARAMETER par_cdcooper   AS INTEGER.
DEFINE INPUT  PARAMETER par_cdempres   AS INTEGER.
DEFINE OUTPUT PARAMETER par_inavscot   AS INTEGER.
DEFINE OUTPUT PARAMETER par_inavsemp   AS INTEGER.
DEFINE OUTPUT PARAMETER par_cdcritic   AS INTEGER.

FIND crapemp WHERE crapemp.cdcooper = par_cdcooper  AND 
                   crapemp.cdempres = par_cdempres
                   NO-LOCK NO-ERROR.

IF    NOT AVAILABLE crapemp THEN
DO:
    ASSIGN par_cdcritic = 40.
    LEAVE.
END.
    
IF  NOT CAN-DO("2,3",STRING(crapemp.tpdebcot,"9")) OR
    NOT CAN-DO("2,3",STRING(crapemp.tpdebemp,"9")) THEN
DO:
    ASSIGN par_cdcritic = 445.
    LEAVE.
END.

ASSIGN par_inavscot = crapemp.inavscot
       par_inavsemp = crapemp.inavsemp.


END PROCEDURE.

PROCEDURE verifica_arquivos:

DEFINE INPUT  PARAMETER   par_cdempres   AS INTEGER.
DEFINE INPUT  PARAMETER   par_dtrefere   AS DATE.
DEFINE INPUT  PARAMETER   par_ingerest   AS CHAR.
DEFINE INPUT  PARAMETER   par_inexecut   AS CHAR.
DEFINE INPUT  PARAMETER   par_inavscot   AS INT.
DEFINE INPUT  PARAMETER   par_inavsemp   AS INT.
DEFINE INPUT  PARAMETER   par_dtfimref   AS DATE.
DEFINE INPUT  PARAMETER   par_inclusao   AS LOGICAL.
DEFINE OUTPUT PARAMETER   par_qtarqfol   AS INTEGER.
DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-critic.

DEFINE VAR aux_qtarqfol  AS INTEGER                      NO-UNDO.
DEFINE VAR aux_arqfolha  AS CHAR    FORMAT "x(45)"       NO-UNDO.
DEFINE VAR asux_contacr  AS INT                          NO-UNDO.

ASSIGN par_qtarqfol = 0.
ASSIGN aux_arqfolha = "f" + STRING(par_cdempres,"99999") +
       STRING(par_dtrefere,"99999999")   + ".*".

INPUT THROUGH VALUE("ll integra/" + aux_arqfolha +
                    " 2> /dev/null | wc -l") NO-ECHO.

SET  aux_qtarqfol.

INPUT CLOSE.

ASSIGN par_qtarqfol = aux_qtarqfol.

ASSIGN aux_arqfolha = "f" + STRING(par_cdempres,"99") +
                STRING(par_dtrefere,"99999999")   + ".*".

INPUT THROUGH VALUE("ll integra/" + aux_arqfolha +
                    " 2> /dev/null | wc -l") NO-ECHO.

SET  aux_qtarqfol.

INPUT CLOSE.

ASSIGN par_qtarqfol = par_qtarqfol + aux_qtarqfol.

IF par_inclusao THEN
    DO:
        IF  (par_inavscot <> 1 OR par_inavsemp <> 1) AND
             par_dtrefere = (par_dtfimref - 1)   THEN
            DO:
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 522
                       tt-critic.cdsequen = 1.
                FIND crapcri WHERE crapcri.cdcritic = 522
                             NO-LOCK NO-ERROR NO-WAIT.
                IF   NOT AVAILABLE crapcri   THEN
                    ASSIGN tt-critic.dscritic = STRING(522) 
                          + " - Critica nao cadastrada!".
                ELSE
                    ASSIGN tt-critic.dscritic = crapcri.dscritic.
            END.
           
        IF par_ingerest = "S" AND 
           MONTH(par_dtrefere) = MONTH(par_dtrefere + 1) THEN
            DO:
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 653
                       tt-critic.cdsequen = 1.
                FIND crapcri WHERE crapcri.cdcritic = 653
                             NO-LOCK NO-ERROR NO-WAIT.
                IF   NOT AVAILABLE crapcri   THEN
                    ASSIGN tt-critic.dscritic = STRING(653) 
                           + " - Critica nao cadastrada!".
                ELSE
                    ASSIGN tt-critic.dscritic = crapcri.dscritic.            
            END.  
    END.

IF par_ingerest = "S" THEN
    DO:
        IF par_qtarqfol > 1 THEN
            DO:
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 442
                       tt-critic.cdsequen = 3.
                FIND crapcri WHERE crapcri.cdcritic = 442
                             NO-LOCK NO-ERROR NO-WAIT.
                IF   NOT AVAILABLE crapcri   THEN
                    ASSIGN tt-critic.dscritic = STRING(442) 
                           + " - Critica nao cadastrada!".
                ELSE
                    ASSIGN tt-critic.dscritic = crapcri.dscritic.
            END.
        ELSE      /* Nao Solicitar */
        IF par_qtarqfol <= 1 THEN
            DO:
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 443
                       tt-critic.cdsequen = 4.
                FIND crapcri WHERE crapcri.cdcritic = 443.
                IF   NOT AVAILABLE crapcri   THEN
                    ASSIGN tt-critic.dscritic = STRING(443) 
                           + " - Critica nao cadastrada!".
                ELSE
                    ASSIGN tt-critic.dscritic = crapcri.dscritic.
            END.
    END.

IF   par_inexecut = "N"  THEN
    DO: 
        CREATE tt-critic.
        ASSIGN tt-critic.cdcritic = 0
               tt-critic.cdsequen = 5
               tt-critic.dscritic = "Deseja fazer o credito neste momento ?".

        CREATE tt-critic.
        ASSIGN tt-critic.cdcritic = 78
               tt-critic.cdsequen = 6.
        FIND crapcri WHERE crapcri.cdcritic = 78.
        IF   NOT AVAILABLE crapcri   THEN
            ASSIGN tt-critic.dscritic = STRING(78) 
                   + " - Critica nao cadastrada!".
        ELSE
            ASSIGN tt-critic.dscritic = crapcri.dscritic.

    END.
END PROCEDURE.


PROCEDURE proc_total_arquivo:

DEFINE INPUT  PARAMETER  par_cdempres  AS INTEGER.
DEFINE INPUT  PARAMETER  par_dtrefere  AS DATE.
DEFINE INPUT  PARAMETER  par_dialiber  AS INTEGER.
DEFINE OUTPUT PARAMETER  par_vltotfol  AS DECIMAL.

DEF VAR aux_arqfolha AS CHAR    FORMAT "x(45)"                NO-UNDO.
DEF VAR aux_tpregist AS INT     FORMAT "9"                    NO-UNDO.
DEF VAR aux_vllanmto AS DECIMAL FORMAT "999999999999.99"      NO-UNDO.


FOR EACH tt-critic:
    DELETE tt-critic.
END.

aux_arqfolha = "integra/f" + STRING(par_cdempres,"99999") +
                             STRING(par_dtrefere,"99999999") + "." +
                             STRING(par_dialiber,"99").

IF   SEARCH(aux_arqfolha) = ?   THEN
    DO: 
        aux_arqfolha = "integra/f" + STRING(par_cdempres,"99") +
                        STRING(par_dtrefere,"99999999") + "." +
                        STRING(par_dialiber,"99").
                            
         IF   SEARCH(aux_arqfolha) = ?   THEN
             DO:  
                 par_vltotfol = 0.
                 RETURN.  
             END.           
    END.

INPUT STREAM str_1 FROM VALUE(aux_arqfolha) NO-ECHO.
     
SET STREAM str_1 aux_tpregist ^ ^ ^ ^ NO-ERROR.
    
par_vltotfol = 0.
    
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
    SET STREAM str_1 aux_tpregist ^ ^ aux_vllanmto ^ NO-ERROR.
 
    IF   aux_tpregist = 0   THEN
        par_vltotfol = par_vltotfol + aux_vllanmto.
    ELSE
        LEAVE.
    
END.  /*   Fim do DO WHILE TRUE  */
    
END PROCEDURE.



/* fim da inlcusao do sol62_bo */

PROCEDURE critica:

DEFINE INPUT  PARAMETER par_cdcritic AS INTEGER NO-UNDO.
DEFINE OUTPUT PARAMETER par_dscritic AS CHAR NO-UNDO.

FIND crapcri WHERE crapcri.cdcritic = par_cdcritic 
     NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE crapcri   THEN
     par_dscritic = STRING(par_cdcritic) + " - Critica nao cadastrada!".
ELSE
     par_dscritic = crapcri.dscritic.

END PROCEDURE.


PROCEDURE valida_arquivo:
       
DEFINE INPUT  PARAMETER  par_cdcooper  AS INT            NO-UNDO.
DEFINE INPUT  PARAMETER  par_diretorio AS CHAR           NO-UNDO.
DEFINE INPUT  PARAMETER  par_arquivo   AS CHAR           NO-UNDO.
DEFINE INPUT  PARAMETER  par_mesref    AS INT            NO-UNDO.
DEFINE INPUT  PARAMETER  par_anoref    AS INT            NO-UNDO.
DEFINE INPUT  PARAMETER  par_tipoarq   AS CHAR           NO-UNDO.
DEFINE OUTPUT PARAMETER TABLE FOR tt-consiste.

DEF VAR aux_nroempre  AS INT FORMAT "999"                NO-UNDO.
DEF VAR aux_dtrefere  AS DATE FORMAT "99999999"          NO-UNDO. 

DEF VAR aux_vlindice  AS INT                             NO-UNDO.
DEF VAR aux_tipolinh  AS INT     FORMAT "9"              NO-UNDO.
DEF VAR aux_nrsequen  AS INT     FORMAT "999999"         NO-UNDO.
DEF VAR aux_nroconta  AS INT     FORMAT "999999999"      NO-UNDO.
DEF VAR aux_decvllan  AS DECIMAL FORMAT "9999999999.99"  NO-UNDO.
DEF VAR aux_vllanmto  AS CHAR    FORMAT "x(15)"          NO-UNDO.
DEF VAR aux_vlhstarq  AS INT     FORMAT "9999"           NO-UNDO.
DEF VAR aux_nmarquiv  AS CHAR    FORMAT "x(35)"          NO-UNDO.
DEF VAR aux_nmdireto  AS CHAR    FORMAT "x(50)"          NO-UNDO.
DEF VAR aux_indtipar  AS CHAR    FORMAT "x"              NO-UNDO.
DEF VAR aux_qtdregis  AS INT     FORMAT "zz,zz9"         NO-UNDO.
DEF VAR aux_vlrimpor  AS DECIMAL FORMAT "9999999.99"     NO-UNDO.
DEF VAR aux_qtdimpor  AS INT     FORMAT "999"            NO-UNDO.
DEF VAR aux_contlinh  AS INT                             NO-UNDO.

DEF VAR aux_datachar  AS CHAR    FORMAT "x(10)"          NO-UNDO.
DEF VAR aux_dataconv  AS DATE    FORMAT "99/99/9999"     NO-UNDO.

DEF VAR aux_nrarquiv  AS INT                             NO-UNDO.
DEF VAR aux_flgrodape AS LOGICAL                         NO-UNDO.
DEF VAR aux_nrposcar  AS INT                             NO-UNDO.
DEF VAR aux_vlsomarq  AS DECIMAL FORMAT "zzz,zzz,zz9.99" NO-UNDO.

DEF VAR aux_totvllan  AS DECIMAL FORMAT "zzz,zzz,zz9.99" 
                                 EXTENT 5000             NO-UNDO.
DEF VAR aux_totvlsom  AS DECIMAL FORMAT "zzz,zzz,zz9.99" NO-UNDO.
DEF VAR aux_dtultdia  AS DATE    FORMAT "99999999"       NO-UNDO.

DEF VAR aux_dtcorren  AS DATE                            NO-UNDO.
DEF VAR aux_indrespo  AS LOGICAL FORMAT "S/N" INIT TRUE  NO-UNDO.
DEF VAR aux_inderros  AS LOGICAL                         NO-UNDO.
DEF VAR aux_inmesref  AS INT     FORMAT "zz"             NO-UNDO.
DEF VAR aux_inanoref  AS INT     FORMAT "zzzz"           NO-UNDO.
DEF VAR aux_cdcooper  AS INT                             NO-UNDO.
DEF VAR aux_qtderros  AS INT                             NO-UNDO.
DEF VAR aux_tamstrin  AS INT                             NO-UNDO.
DEF VAR tab_nmarqtel  AS CHAR EXTENT 999                 NO-UNDO.
DEF VAR aux_qtdarqui  AS INT                             NO-UNDO.

DEFINE VAR h_valida AS HANDLE NO-UNDO.


ASSIGN aux_cdcooper = par_cdcooper  /* cooperativa */
       aux_nmdireto = par_diretorio /* diretorio */
       aux_nmarquiv = par_arquivo   /* arquivo */ 
       aux_inmesref = par_mesref    /* mes de referencia */ 
       aux_inanoref = par_anoref    /* ano de aux_dtreferencia */
       aux_indtipar = par_tipoarq.  /* tipo folha */ 


ASSIGN aux_nmarquiv = aux_nmdireto + aux_nmarquiv.



INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
      NO-ECHO.
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)" .

 /*  UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                     aux_nmarquiv + ".q 2> /dev/null"). */

   ASSIGN aux_nrarquiv               = aux_nrarquiv + 1
          tab_nmarqtel[aux_nrarquiv] = aux_nmarquiv.

END.  /*  Fim do DO WHILE TRUE  */


INPUT STREAM str_1 CLOSE.

IF aux_nrarquiv > 0 THEN
  DO:

    DO aux_qtdarqui = 1 TO aux_nrarquiv:
   
        ASSIGN aux_nmarquiv = tab_nmarqtel[aux_qtdarqui]
               aux_tamstrin = LENGTH(aux_nmdireto) + 1
               aux_nmarquiv = SUBSTR(aux_nmarquiv,aux_tamstrin,99).
        
        
        ASSIGN aux_dtcorren = DATE(aux_inmesref,01,aux_inanoref)
               aux_dtultdia = 
               ((DATE(MONTH(aux_dtcorren),28,YEAR(aux_dtcorren)) + 4) -
                                DAY(DATE(MONTH(aux_dtcorren),28,
                                YEAR(aux_dtcorren)) + 4)).
        ASSIGN aux_indtipar = CAPS(aux_indtipar).
        IF aux_indtipar = "S" THEN
            ASSIGN aux_indrespo = TRUE.
        ELSE
            ASSIGN aux_indrespo = FALSE.

   
        ASSIGN aux_qtderros  = 0
               aux_totvllan  = 0
               aux_totvlsom  = 0
               aux_qtdregis  = 0
               aux_flgrodape = FALSE
               aux_inderros  = TRUE.
               
        INPUT STREAM str_1 FROM VALUE(tab_nmarqtel[aux_qtdarqui]) NO-ECHO.
      
        SET STREAM str_1 aux_tipolinh aux_dtrefere aux_nroempre aux_qtdimpor 
                   aux_vlrimpor NO-ERROR. 
/*........................................................................... */
        /* le HEADER 
           campos: - tipo 
                   - data de referencia 
                   - empresa do arquivo de dados 
                   - aux_qtdimpor - quantidade importada
                   - aux_vlrimpor - valor importado */

        IF aux_tipolinh <> 1 THEN
           DO:
               ASSIGN aux_qtderros = 1.
               CREATE tt-consiste.
               ASSIGN tt-consiste.nmarquiv = aux_nmarquiv 
                   tt-consiste.nrsequen = aux_qtdarqui
                   tt-consiste.nrolinha = 1
                   tt-consiste.conterro = 
                   "Registro de controle faltando ou invalido!".
               NEXT. 
           END.
        IF aux_indrespo THEN
            DO:
              IF   aux_nmarquiv BEGINS "f"  THEN     /****  FOLHA  ****/
                DO:
                  IF   STRING(aux_dtultdia,"99999999") <>
                       SUBSTRING(aux_nmarquiv,4,8) THEN
                    DO:    
                        ASSIGN aux_qtderros = 1.
                        CREATE tt-consiste.
                        ASSIGN tt-consiste.nmarquiv = aux_nmarquiv 
                               tt-consiste.nrsequen = aux_qtdarqui
                               tt-consiste.nrolinha = 1
                               tt-consiste.conterro = 
                               "Data no nome do arquivo errada!".
                        NEXT. 
                    END. 
        
                  IF   aux_dtultdia <> aux_dtrefere THEN
                    DO:
                        ASSIGN aux_qtderros = 1.
                        CREATE tt-consiste.
                        ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                               tt-consiste.nrsequen = aux_qtdarqui
                               tt-consiste.nrolinha = 1
                               tt-consiste.conterro = 
                               "Data no arquivo errada!".
                        NEXT. 
                    END.
                        
                  FIND crapemp 
                     WHERE crapemp.cdcooper = aux_cdcooper AND                  
                           crapemp.cdempres = 
                           INTEGER(SUBSTRING(aux_nmarquiv,2,2))
                           NO-LOCK NO-ERROR.
                  IF   NOT AVAILABLE crapemp THEN
                    DO:
                        ASSIGN aux_qtderros = 1.
                        CREATE tt-consiste.
                        ASSIGN tt-consiste.nmarquiv = aux_nmarquiv 
                               tt-consiste.nrsequen = aux_qtdarqui
                               tt-consiste.nrolinha = 1
                               tt-consiste.conterro = 
                               "Empresa inexistente!" +
                               "Verifique nome arquivo ".
                        NEXT.            
                    END.
                  IF   crapemp.cdempfol <> aux_nroempre THEN
                    DO:
                        ASSIGN aux_qtderros = 1.
                        CREATE tt-consiste.
                        ASSIGN tt-consiste.nmarquiv = aux_nmarquiv 
                               tt-consiste.nrsequen = aux_qtdarqui
                               tt-consiste.nrolinha = 1
                               tt-consiste.conterro = 
                               "Empresa inexistente!" +
                               "Verifique empresa no arquivo ".
                        NEXT.
                    END.
                END.
              ELSE  /****  CONVENIO  ****/
                DO:
                  IF STRING(aux_dtultdia,"99999999") <>  
                     SUBSTRING(aux_nmarquiv,1,8) THEN
                    DO:
                        ASSIGN aux_qtderros = 1.
                        CREATE tt-consiste.
                        ASSIGN tt-consiste.nmarquiv = aux_nmarquiv 
                               tt-consiste.nrsequen = aux_qtdarqui
                               tt-consiste.nrolinha = 1
                               tt-consiste.conterro = 
                               "Data no nome do arquivo errada!".
                        NEXT.
                    END.
          
                  IF   aux_dtultdia <> aux_dtrefere THEN
                    DO:
                        ASSIGN aux_qtderros = 1.
                        CREATE tt-consiste.
                        ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                               tt-consiste.nrsequen = aux_qtdarqui
                               tt-consiste.nrolinha = 1
                               tt-consiste.conterro = 
                               "Data no arquivo errada!".
                        NEXT. 
                    END.
                END.
           END.
        ELSE      
            DO: /****  FOLHA  ****/
                IF aux_nmarquiv BEGINS "f" THEN 
                  DO:
                      IF STRING(aux_dtultdia,"99999999") = 
                         SUBSTRING(aux_nmarquiv,4,8) THEN
                         DO:
                             ASSIGN aux_qtderros = 1.
                             CREATE tt-consiste.
                             ASSIGN tt-consiste.nmarquiv = 
                                    aux_nmarquiv
                                    tt-consiste.nrsequen = 
                                    aux_qtdarqui
                                    tt-consiste.nrolinha = 1
                                    tt-consiste.conterro = 
                           "Data no nome do arquivo nao pode ser " +
                           "ultimo dia do mes!".
                             NEXT. 
                         END. 
                      IF aux_dtultdia = aux_dtrefere THEN
                        DO:
                            ASSIGN aux_qtderros = 1.
                            CREATE tt-consiste.
                            ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                   tt-consiste.nrsequen = aux_qtdarqui
                                   tt-consiste.nrolinha = 1
                                   tt-consiste.conterro = 
                                   "Data no arquivo nao pode ser " +
                                   "ultimo dia do mes!".
                            NEXT. 
                        END.
                      IF SUBSTRING(aux_nmarquiv,4,8) <> 
                           STRING(aux_dtrefere,"99999999") THEN
                        DO:
                            ASSIGN aux_qtderros = 1.
                            CREATE tt-consiste.
                            ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                   tt-consiste.nrsequen = aux_qtdarqui
                                   tt-consiste.nrolinha = 1
                                   tt-consiste.conterro = 
                                   "Datas diferentes. Verifique arquivo.".
                            NEXT. 
                        END.
                      FIND crapemp WHERE crapemp.cdcooper = aux_cdcooper AND
                                   crapemp.cdempres = 
                                   INTEGER(SUBSTRING(aux_nmarquiv,2,2))
                                   NO-LOCK NO-ERROR.
           
                      IF   NOT AVAILABLE crapemp THEN
                        DO:
                            ASSIGN aux_qtderros = 1.
                            CREATE tt-consiste.
                            ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                   tt-consiste.nrsequen = aux_qtdarqui
                                   tt-consiste.nrolinha = 1
                                   tt-consiste.conterro = 
                                   "Empresa inexistente! " + 
                                   "Verifique nome arquivo ".
                            NEXT. 
                        END.
        
                      IF   crapemp.cdempfol <> aux_nroempre THEN
                        DO:
                           ASSIGN aux_qtderros = 1.
                           CREATE tt-consiste.
                           ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                  tt-consiste.nrsequen = aux_qtdarqui
                                  tt-consiste.nrolinha = 1
                                  tt-consiste.conterro = 
                                  "Empresa invalida no arquivo! ".
                            NEXT.                  
                        END.
                  END.
                ELSE             /****  CONVENIO  ****/
                  DO:
                      IF STRING(aux_dtultdia,"99999999") =  
                         SUBSTRING(aux_nmarquiv,1,8) THEN
                        DO:
                            ASSIGN aux_qtderros = 1.
                            CREATE tt-consiste.
                            ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                   tt-consiste.nrsequen = aux_qtdarqui
                                   tt-consiste.nrolinha = 1
                                   tt-consiste.conterro = 
                                   "Data no nome do arquivo nao " + 
                                   "pode ser ultimo dia do mes!".
                            NEXT.                  
                        END.
 
                      IF aux_dtultdia = aux_dtrefere THEN
                        DO:
                            ASSIGN aux_qtderros = 1.
                            CREATE tt-consiste.
                            ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                   tt-consiste.nrsequen = aux_qtdarqui
                                   tt-consiste.nrolinha = 1
                                   tt-consiste.conterro = 
                                   "Data no arquivo nao pode " +
                                   "ser ultimo dia do mes!".
                            NEXT.
                        END.
            
                      IF SUBSTRING(aux_nmarquiv,1,8) <> 
                         STRING(aux_dtrefere,"99999999") THEN
                        DO:
                            ASSIGN aux_qtderros = 1.
                            CREATE tt-consiste.
                            ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                                   tt-consiste.nrsequen = aux_qtdarqui
                                   tt-consiste.nrolinha = 1
                                   tt-consiste.conterro =
                                   "Datas diferentes. Verifique arquivo.".
                            NEXT.
                        END.
                  END.             
            END. /* fim do header */

        ASSIGN aux_contlinh = 1.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           ASSIGN aux_contlinh = aux_contlinh + 1.
           SET STREAM str_1 aux_tipolinh aux_nrsequen aux_nroconta 
                            aux_vllanmto aux_vlhstarq aux_datachar.
           IF   LENGTH(STRING(aux_vlhstarq)) > 3   THEN
             DO:
                 ASSIGN aux_qtderros = 1.
                 CREATE tt-consiste.
                 ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                        tt-consiste.nrsequen = aux_qtdarqui
                        tt-consiste.nrolinha = aux_contlinh
                        tt-consiste.conterro =
                        "Historico Incorreto. Verifique arquivo.".
                 NEXT.
             END.

           IF   aux_tipolinh = 0 THEN                                           
             DO:          
                 IF NOT CAN-DO("1,2,3,4,5,6,7,8,9,0",
                               SUBSTRING(aux_datachar,1,1)) 
                        AND aux_datachar <> "" THEN
                   DO:
                       ASSIGN aux_qtderros = 1.
                       CREATE tt-consiste.
                       ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                              tt-consiste.nrsequen = aux_qtdarqui
                              tt-consiste.nrolinha = aux_contlinh
                              tt-consiste.conterro =
                              "COLUNA DE DATA POSSUI CARACTERES." +
                              " Conta:" + string(aux_nroconta,"zzzz,zzz,z") + 
                              " Data: " + aux_datachar. 
                       NEXT.        
                   END.
 
                 ASSIGN aux_dataconv = DATE(aux_datachar) NO-ERROR.
                  
                 IF   ERROR-STATUS:ERROR THEN
                   DO:
                       ASSIGN aux_qtderros = 1.
                       CREATE tt-consiste.
                       ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                              tt-consiste.nrsequen = aux_qtdarqui
                              tt-consiste.nrolinha = aux_contlinh
                              tt-consiste.conterro =
                              "DATA COM FORMATO INCORRETO." +
                              " Conta:" + string(aux_nroconta,"zzzz,zzz,z") + 
                              " Data: " + aux_datachar. 
                       NEXT.
                   END.
                 IF   SUBSTR(aux_vllanmto,10,1) = "." THEN
                   DO:
                       ASSIGN aux_qtderros = 1.
                       CREATE tt-consiste.
                       ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                              tt-consiste.nrsequen = aux_qtdarqui
                              tt-consiste.nrolinha = aux_contlinh
                              tt-consiste.conterro =
                              "VALORES COM PONTOS." +
                              " Conta:" + string(aux_nroconta,"zzzz,zzz,z") + 
                              " Valor: " + aux_vllanmto. 
                       NEXT.
                   END.
               
                 ASSIGN aux_decvllan = DECIMAL(aux_vllanmto).
                  
                 ASSIGN aux_totvllan[aux_vlhstarq] = 
                        aux_totvllan[aux_vlhstarq] + aux_decvllan
                        aux_qtdregis = aux_qtdregis + 1.

                 FIND crapass WHERE crapass.cdcooper = aux_cdcooper AND
                            crapass.nrdconta = aux_nroconta NO-LOCK NO-ERROR.
                 IF   NOT AVAILABLE crapass   THEN
                   DO:
                       ASSIGN aux_qtderros = 1.
                       CREATE tt-consiste.
                       ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                              tt-consiste.nrsequen = aux_qtdarqui
                              tt-consiste.nrolinha = aux_contlinh
                              tt-consiste.conterro =
                              "CONTA NAO CADASTRADA. --> " +
                              " Conta:" + string(aux_nroconta,"zzzz,zzz,z"). 
                       NEXT.
                   END.

               IF   crapass.dtdemiss <> ? THEN
                 DO:
                       ASSIGN aux_qtderros = 1.
                       CREATE tt-consiste.
                       ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                              tt-consiste.nrsequen = aux_qtdarqui
                              tt-consiste.nrolinha = aux_contlinh
                              tt-consiste.conterro =
                              "CONTA DE DEMITIDO. --> " +
                              " Conta:" + string(aux_nroconta,"zzzz,zzz,z"). 
                       NEXT.
                 END.
             END.
           ELSE
           IF   aux_tipolinh = 9 THEN
             DO:
                 ASSIGN aux_vlsomarq  = DECIMAL(aux_vllanmto)
                        aux_flgrodape = TRUE
                        aux_inderros  = FALSE.
                  
                 ASSIGN aux_dataconv = DATE(aux_datachar) NO-ERROR.

                 IF   ERROR-STATUS:ERROR THEN
                   DO:
                       ASSIGN aux_qtderros = 1.
                       CREATE tt-consiste.
                       ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                              tt-consiste.nrsequen = aux_qtdarqui
                              tt-consiste.nrolinha = aux_contlinh
                              tt-consiste.conterro =
                              "DATA DE REGISTRO DE CONTROLE NO" +
                              "RODAPE C/ PROBLEMA.". 
                   END.
          
                 LEAVE.
             END.

        END.  /* Fim do DO WHILE - REGISTROS */
    

        DO aux_vlindice = 1 TO 5000:
            IF  NOT aux_flgrodape   THEN
              DO:
                  ASSIGN aux_contlinh = aux_contlinh + 1.
                  CREATE tt-consiste.
                  ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                         tt-consiste.nrsequen = aux_qtdarqui
                         tt-consiste.nrolinha = aux_contlinh
                         tt-consiste.conterro =
                         "NAO ENCONTRADO REGISTRO " + 
                         "RODAPE PARA TOTALIZAR ARQUIVO." +
                         "TOTAIS INDICARAO ERRO!!!!!".
              END.
                   
            IF aux_totvllan[aux_vlindice] > 0  THEN
              DO:
                  ASSIGN aux_contlinh = aux_contlinh + 1.
                  CREATE tt-consiste.
                  ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                         tt-consiste.nrsequen = aux_qtdarqui
                         tt-consiste.nrolinha = aux_contlinh
                         tt-consiste.conterro =
                         "TOTAL HISTORICO " + 
                         STRING (aux_vlindice,"Z,ZZ9") + 
                         "  "  + STRING (aux_totvllan[aux_vlindice],
                                 "ZZZ,ZZZ,ZZ9.99") + ".".
                  ASSIGN aux_totvlsom = aux_totvlsom + 
                                     aux_totvllan[aux_vlindice].
              END.
        END.   /* Fim do DO... */

        IF aux_flgrodape THEN
          DO:
              CREATE tt-consiste.
              ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                     tt-consiste.nrsequen = aux_qtdarqui
                     tt-consiste.nrolinha = 1000000
                     tt-consiste.conterro =
                     "TOTAL SOMADO " + 
                     STRING (aux_totvlsom,"zzzz,zzz,zZ9.99") + ".".

              IF   aux_totvlsom <> aux_vlsomarq  THEN
                DO:
                    ASSIGN aux_qtderros = 1.
                    CREATE tt-consiste.
                    ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                           tt-consiste.nrsequen = aux_qtdarqui
                           tt-consiste.nrolinha = 1000001
                           tt-consiste.conterro =
                           "TOTAL GERAL NO ARQUIVO " + 
                           STRING (aux_vlsomarq,"zzzz,zzz,zZ9.99") +
                           " DIFERENTE DO TOTAL SOMADO.".
                END.
              ELSE
                DO:
                    CREATE tt-consiste.
                    ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                           tt-consiste.nrsequen = aux_qtdarqui
                           tt-consiste.nrolinha = 1000002
                           tt-consiste.conterro =
                           "TOTAL GERAL NO ARQUIVO " + 
                           STRING (aux_vlsomarq,"zzzz,zzz,zZ9.99") +
                           " CONFERE COM TOTAL SOMADO.".
                END.
          END.

        IF aux_qtderros > 0 THEN
          DO:
              CREATE tt-consiste.
              ASSIGN tt-consiste.nmarquiv = aux_nmarquiv
                     tt-consiste.nrsequen = aux_qtdarqui
                     tt-consiste.nrolinha = 2000000
                     tt-consiste.conterro =
                     "**** ERRO **** ARQUIVO COM ERROS! VERIFIQUE!".
          END.
    END.  /* Fim do DO CONTADOR DE AQRQUIVOS */
  END.
ELSE
  DO:
      CREATE tt-consiste.
      ASSIGN tt-consiste.nmarquiv = ""
             tt-consiste.nrsequen = 1
             tt-consiste.nrolinha = 1
             tt-consiste.conterro =
             "****** ERRO ****** NENHUM ARQUIVO ENCONTRADO!!!".
  END.



END PROCEDURE.


PROCEDURE lelem:

/* incluir no b1wgen0042.p da cecred a partir deste ponto */


/* .............................................................................

   Procedure: lelem.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/93.                    Ultima atualizacao: 10/08/2009

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Processar a rotina de calculo de emprestimo.

               
............................................................................. */

DEFINE  INPUT PARAMETER par_cdcooper AS INTEGER                      NO-UNDO.
DEFINE  INPUT PARAMETER par_dtmvtolt AS DATE                         NO-UNDO.
DEFINE  INPUT PARAMETER par_dtmvtopr AS DATE                         NO-UNDO.
DEFINE  INPUT PARAMETER par_nrdconta LIKE crapepr.nrdconta           NO-UNDO.
DEFINE  INPUT PARAMETER par_eprdtmvt LIKE crapepr.dtmvtolt           NO-UNDO.      
DEFINE  INPUT PARAMETER par_cdlcremp LIKE crapepr.cdlcremp           NO-UNDO.
DEFINE  INPUT PARAMETER par_cdempres LIKE crapepr.cdempres           NO-UNDO. 
DEFINE  INPUT PARAMETER par_flgpagto LIKE crapepr.flgpagto           NO-UNDO.
DEFINE  INPUT PARAMETER par_nrctremp LIKE crapepr.nrctremp           NO-UNDO.
DEFINE  INPUT PARAMETER par_dtultpag LIKE crapepr.dtultpag           NO-UNDO.
DEFINE  INPUT PARAMETER par_vlpreemp LIKE crapepr.vlpreemp           NO-UNDO.
DEFINE  INPUT PARAMETER par_qtpreemp LIKE crapepr.qtpreemp           NO-UNDO.
DEFINE  INPUT PARAMETER par_dtdpagto LIKE crapepr.dtdpagto           NO-UNDO.
DEFINE  INPUT PARAMETER par_inliquid LIKE crapepr.inliquid           NO-UNDO.
DEFINE  INPUT PARAMETER par_inproces AS INTEGER                      NO-UNDO.
DEFINE  INPUT PARAMETER par_cdprogra AS CHAR                         NO-UNDO.
DEFINE  INPUT PARAMETER par_vlsdeved AS DECIMAL 
                                     FORMAT "zzz,zzz,zzz,zz9.99-"    NO-UNDO.
DEFINE  INPUT PARAMETER par_txdjuros AS DECIMAL DECIMALS 7           NO-UNDO. 
DEFINE  INPUT PARAMETER par_qtprepag AS INTEGER FORMAT "zz9"         NO-UNDO.
DEFINE  INPUT PARAMETER par_dtcalcul AS DATE                         NO-UNDO.
DEFINE  INPUT PARAMETER par_vljuracu LIKE crapepr.vljuracu           NO-UNDO.
DEFINE OUTPUT PARAMETER TABLE FOR tt-critic.

DEF BUFFER crabemp FOR crapemp.
DEF BUFFER crabhis FOR craphis.
DEF        VAR aux_dscritic AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR lem_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR lem_qtprecal AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR lem_qtprepag AS DECIMAL DECIMALS 4                    NO-UNDO.
DEF        VAR lem_vlrpgmes LIKE crapepr.vlpreemp EXTENT 30          NO-UNDO.
DEF        VAR lem_qtdpgmes AS INTEGER                               NO-UNDO.
DEF        VAR lem_exipgmes AS LOGICAL                               NO-UNDO.
DEF        VAR lem_varqtdpg AS INTEGER                               NO-UNDO.
DEF        VAR tab_diapagto AS INTEGER                               NO-UNDO.
DEF        VAR aux_dtmesant AS DATE                                  NO-UNDO.
DEF        VAR aux_nrdiacal AS INTEGER                               NO-UNDO.
DEF        VAR aux_vlprepag AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vljurmes AS DECIMAL                               NO-UNDO.
DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_ddlanmto AS INTEGER                               NO-UNDO.
DEF        VAR aux_nrdiames AS INT                                   NO-UNDO.
DEF        VAR aux_nrdiamss AS INT                                   NO-UNDO.
DEF        VAR lem_flctamig AS LOG                                   NO-UNDO.

ASSIGN tab_diapagto = 0.

FIND crabemp WHERE crabemp.cdcooper = par_cdcooper      AND 
                   crabemp.cdempres = par_cdempres  NO-LOCK NO-ERROR.
                     
IF AVAILABLE crabemp THEN
    IF (NOT crabemp.flgpagto OR NOT crabemp.flgpgtib) THEN
        tab_diapagto = 0.

IF (tab_diapagto > 0) AND (NOT par_flgpagto) THEN
     tab_diapagto = 0.

ASSIGN lem_dtmvtolt = par_dtmvtolt
       lem_flctamig = NO
       lem_qtprecal = 0
       lem_vlrpgmes = 0
       lem_qtdpgmes = 0
       aux_dtmesant = lem_dtmvtolt - DAY(lem_dtmvtolt)

       aux_nrdiacal = IF MONTH(par_eprdtmvt) = MONTH(lem_dtmvtolt) AND
                          YEAR(par_eprdtmvt) =  YEAR(lem_dtmvtolt)
                         THEN DAY(par_eprdtmvt)
                         ELSE 0

       aux_vlprepag = 0
       aux_vljurmes = 0
       aux_dtultdia = ((DATE(MONTH(par_dtmvtolt),28,YEAR(par_dtmvtolt)) + 4) -
                             DAY(DATE(MONTH(par_dtmvtolt),28,
                                      YEAR(par_dtmvtolt)) + 4))

       aux_inhst093 = FALSE.



/*  Testa se esta rodando no batch e e' mensal  */

IF   par_inproces > 2   THEN
     IF   CAN-DO("CRPS080,CRPS085,CRPS120",par_cdprogra)   THEN
          IF   MONTH(lem_dtmvtolt) <> MONTH(par_dtmvtopr)   THEN
               ASSIGN lem_dtmvtolt = aux_dtultdia
                      aux_dtmesant = aux_dtultdia
                      aux_nrdiacal = 0.

IF  par_inliquid = 1   AND
    par_vlsdeved = 0   THEN
    DO:
        FIND craptco WHERE craptco.cdcopant = par_cdcooper AND
                           craptco.nrctaant = par_nrdconta AND
                           craptco.tpctatrf = 1            AND
                           craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.
        IF   AVAILABLE craptco   THEN
             DO:
                 FIND LAST craplem
                     WHERE craplem.cdcooper = par_cdcooper   AND
                           craplem.nrdconta = par_nrdconta   AND
                           craplem.nrctremp = par_nrctremp   AND
                           craplem.cdhistor = 921 /* zerado pela migracao */
                           NO-LOCK NO-ERROR.
                 IF   AVAILABLE craplem  THEN
                      ASSIGN lem_flctamig = YES.
             END.
    END.

DO WHILE TRUE:
    FOR EACH craplem WHERE craplem.cdcooper = par_cdcooper   AND
                           craplem.dtmvtolt > aux_dtmesant   AND
                           craplem.nrdconta = par_nrdconta   AND
                           craplem.nrctremp = par_nrctremp   NO-LOCK
                           BY craplem.cdhistor DESCENDING:
        /*** Conta migrada teve o seu zeramento no primeiro dia util do
             mes seguinte ***/
        IF  lem_flctamig THEN
            NEXT.
        
        FIND crabhis OF craplem NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crabhis   THEN
          DO:
              RUN critica (INPUT 80,
                           OUTPUT aux_dscritic).
              CREATE tt-critic.
              ASSIGN tt-critic.cdcritic = 80.
                     tt-critic.dscritic = aux_dscritic.
              RETURN "NOK".
          END.


       /*  Calcula percentual pago na prestacao e/ou acerto  */

       IF   CAN-DO("88,91,92,93,94,95,120,277,349,353,392,393,507",
                   STRING(craplem.cdhistor))   THEN
         DO:
             ASSIGN lem_qtprepag = 0.

             IF   craplem.vlpreemp > 0   THEN
                 ASSIGN lem_qtprepag = ROUND(craplem.vllanmto /
                                             craplem.vlpreemp,4).

             IF   CAN-DO("88,120,507",STRING(craplem.cdhistor))  THEN
                 ASSIGN lem_qtprecal = lem_qtprecal - lem_qtprepag.
             ELSE
                 ASSIGN lem_qtprecal = lem_qtprecal + lem_qtprepag.
         END.

       ASSIGN aux_ddlanmto = DAY(craplem.dtmvtolt).

       IF   CAN-DO("91,92,94,277,349,353,392,393",
                               STRING(craplem.cdhistor))   THEN
         DO:
             ASSIGN par_dtultpag = craplem.dtmvtolt.
             IF par_vlsdeved > 0   THEN
                 IF aux_nrdiacal > aux_ddlanmto   THEN
                     ASSIGN aux_vljurmes = aux_vljurmes + (craplem.vllanmto *
                                           par_txdjuros * (aux_ddlanmto - 
                                                           aux_nrdiacal)).
                 ELSE
                     ASSIGN aux_vljurmes = aux_vljurmes + (par_vlsdeved *
                                           par_txdjuros * (aux_ddlanmto -
                                                           aux_nrdiacal)).

             ASSIGN aux_nrdiacal = IF aux_nrdiacal > aux_ddlanmto
                                 THEN aux_nrdiacal
                                 ELSE aux_ddlanmto.

             IF   CAN-DO("31,39",STRING(par_cdlcremp))   THEN
                 ASSIGN par_qtprepag = par_qtprepag + 1.
             ELSE                                                               
                 ASSIGN par_qtprepag = par_qtprepag + 
                       TRUNCATE(craplem.vllanmto /
                                    par_vlpreemp,0).

                 ASSIGN par_vlsdeved = par_vlsdeved - craplem.vllanmto
                        aux_vlprepag = aux_vlprepag + craplem.vllanmto
                        lem_qtdpgmes = lem_qtdpgmes + 1
                        lem_vlrpgmes[lem_qtdpgmes] = craplem.vllanmto.
         END.
       ELSE
       IF   craplem.cdhistor = 93   OR
            craplem.cdhistor = 95   THEN
         DO:
             ASSIGN par_dtultpag = craplem.dtmvtolt.

             IF   aux_ddlanmto > tab_diapagto   THEN
               DO:
                   IF   par_vlsdeved > 0   THEN
                       ASSIGN aux_vljurmes = aux_vljurmes + (par_vlsdeved *
                                             par_txdjuros * (aux_ddlanmto -
                                             aux_nrdiacal))
                              aux_nrdiacal = aux_ddlanmto.
                   ELSE
                       ASSIGN aux_nrdiacal = aux_ddlanmto.
               END.
             ELSE
               DO:
                   IF   par_vlsdeved > 0   THEN
                       ASSIGN aux_vljurmes = aux_vljurmes + (par_vlsdeved *
                                             par_txdjuros *
                                             (tab_diapagto - aux_nrdiacal))
                              aux_nrdiacal = tab_diapagto
                              aux_inhst093 = TRUE.
                   ELSE
                       ASSIGN aux_nrdiacal = tab_diapagto.

                   ASSIGN par_qtprepag = par_qtprepag + 1
                          par_vlsdeved = par_vlsdeved - craplem.vllanmto
                          aux_vlprepag = aux_vlprepag + craplem.vllanmto
                          lem_qtdpgmes = lem_qtdpgmes + 1
                          lem_vlrpgmes[lem_qtdpgmes] = craplem.vllanmto.
               END.
         END.
       ELSE                               /* Mirtes Verificar aqui */
       IF   CAN-DO("88,395,441,443,507",STRING(craplem.cdhistor))   THEN
           DO:
               IF   par_vlsdeved > 0   THEN
                 DO:
                     IF   aux_ddlanmto < tab_diapagto   THEN
                       DO:
                           IF   aux_nrdiacal = tab_diapagto   THEN
                               ASSIGN aux_vljurmes = aux_vljurmes +
                                             (craplem.vllanmto * par_txdjuros *
                                             (tab_diapagto - aux_ddlanmto)).
                           ELSE
                                ASSIGN aux_vljurmes = aux_vljurmes +
                                             (par_vlsdeved * par_txdjuros *
                                             (aux_ddlanmto - aux_nrdiacal))
                                       aux_nrdiacal = aux_ddlanmto.
                       END.
                     ELSE
                       DO:
                           IF   aux_ddlanmto > tab_diapagto   THEN
                               ASSIGN aux_vljurmes = aux_vljurmes +
                                            (par_vlsdeved * par_txdjuros *
                                            (aux_ddlanmto - aux_nrdiacal))
                                      aux_nrdiacal = aux_ddlanmto.
                       END.
                 END.  
               ELSE
                 DO:
                     ASSIGN aux_nrdiacal = IF aux_nrdiacal > aux_ddlanmto
                                           THEN aux_nrdiacal
                                           ELSE aux_ddlanmto.
                
                     IF   craplem.cdhistor = 88   OR
                         craplem.cdhistor = 507  THEN /* estorno de pagamento */
                       DO:
                           ASSIGN aux_vlprepag = 
                                  aux_vlprepag - craplem.vllanmto.
                           IF aux_vlprepag < 0   THEN
                              aux_vlprepag = 0.
                       END.
                     
                     ASSIGN par_vlsdeved = par_vlsdeved + craplem.vllanmto
                                           lem_exipgmes = NO.

                     DO lem_varqtdpg = 1 TO lem_qtdpgmes:
                         IF lem_vlrpgmes[lem_varqtdpg] = 
                              craplem.vllanmto THEN
                           DO:
                               ASSIGN lem_exipgmes = YES.
                               LEAVE.
                           END.    
                     END. 
                
                     IF   lem_exipgmes   THEN                                         
                     DO:
                         IF craplem.cdhistor <> 88 AND 
                             craplem.cdhistor <> 507 THEN
                             ASSIGN aux_vlprepag = 
                                 IF aux_vlprepag >= craplem.vllanmto
                                                   THEN aux_vlprepag - 
                                                      craplem.vllanmto
                                                   ELSE 0.

                         IF   craplem.vllanmto >= par_vlpreemp   THEN
                             ASSIGN par_qtprepag = par_qtprepag -
                                                 TRUNCATE(craplem.vllanmto /
                                                 par_vlpreemp,0)
                                    par_qtprepag = IF par_qtprepag > 0
                                                 THEN par_qtprepag
                                                 ELSE 0.
                     END.
                 END.
           END.

    END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos de emprestimos  */

    IF CAN-FIND (tt-critic) THEN
        LEAVE.

    IF   par_inproces > 2   THEN
        IF   CAN-DO("CRPS080,CRPS085,CRPS120",par_cdprogra)   THEN
             IF   MONTH(lem_dtmvtolt) <> MONTH(par_dtmvtopr)   THEN
                  aux_nrdiacal = 0.
             ELSE
                  aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
        ELSE
             IF   MONTH(lem_dtmvtolt) <> MONTH(par_dtmvtopr)   THEN
                  aux_nrdiacal = DAY(aux_dtultdia) - aux_nrdiacal.
             ELSE
                  aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.
    ELSE
        aux_nrdiacal = DAY(lem_dtmvtolt) - aux_nrdiacal.

    ASSIGN aux_vljurmes = IF par_vlsdeved > 0
                         THEN aux_vljurmes + (par_vlsdeved * par_txdjuros *
                                              aux_nrdiacal)
                         ELSE aux_vljurmes

          par_qtprepag = IF par_vlsdeved > 0
                         THEN par_qtprepag
                         ELSE par_qtpreemp.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

ASSIGN aux_nrdiacal = 0.

IF   par_dtcalcul <> ?   AND
     par_vlsdeved  > 0   THEN
  DO:
      ASSIGN aux_nrdiacal = par_dtcalcul - lem_dtmvtolt
             aux_nrdiames = IF par_dtcalcul > aux_dtultdia
                            THEN DAY(aux_dtultdia) - DAY(lem_dtmvtolt)
                            ELSE aux_nrdiacal

             aux_nrdiamss = IF par_dtcalcul > aux_dtultdia
                            THEN aux_nrdiacal - aux_nrdiames
                            ELSE 0.

      IF   aux_nrdiamss = 0   THEN
          ASSIGN aux_vljurmes = aux_vljurmes + (par_vlsdeved *
                                par_txdjuros * aux_nrdiames).
      ELSE
          ASSIGN aux_vljurmes = aux_vljurmes + (par_vlsdeved *
                                par_txdjuros * aux_nrdiames)
                 aux_vljurmes = ROUND(aux_vljurmes,2)
                 par_vlsdeved = par_vlsdeved + aux_vljurmes
                 par_vljuracu = par_vljuracu + aux_vljurmes
                 aux_vljurmes = par_vlsdeved * par_txdjuros * aux_nrdiamss.

       ASSIGN aux_nrdiacal = IF DAY(par_dtcalcul) < tab_diapagto
                             THEN tab_diapagto - DAY(par_dtcalcul)
                             ELSE 0.
  END.
ELSE
     IF   DAY(lem_dtmvtolt) < tab_diapagto AND
          par_inproces < 3 AND par_vlsdeved > 0 AND NOT aux_inhst093 THEN
          ASSIGN aux_nrdiacal = tab_diapagto - DAY(lem_dtmvtolt).
     ELSE
          ASSIGN aux_nrdiacal = 0.

/*  Calcula juros sobre a prest. quando a consulta e' menor que o data pagto  */

IF   aux_nrdiacal > 0   AND par_dtdpagto <= aux_dtultdia   THEN
     IF   par_vlsdeved > par_vlpreemp   THEN
          aux_vljurmes = aux_vljurmes + (par_vlpreemp * par_txdjuros *
                                         aux_nrdiacal).
     ELSE
          aux_vljurmes = aux_vljurmes + (par_vlsdeved * par_txdjuros *
                                         aux_nrdiacal).

ASSIGN aux_vljurmes = ROUND(aux_vljurmes,2)
       par_vljuracu = par_vljuracu + aux_vljurmes
       par_vlsdeved = par_vlsdeved + aux_vljurmes.

IF par_vlsdeved > 0 AND par_inliquid > 0 THEN
  DO:
      IF par_inproces > 2 AND par_cdprogra = "crps078" THEN
        DO:
            IF   aux_vljurmes >= par_vlsdeved   THEN
              DO:
                  ASSIGN aux_vljurmes = aux_vljurmes - par_vlsdeved
                         par_vljuracu = par_vljuracu - par_vlsdeved
                         par_vlsdeved = 0.
              END.
            ELSE
              DO:
                 CREATE tt-critic.
                 ASSIGN tt-critic.cdcritic = 0
                        tt-critic.dscritic = STRING(TIME,"HH:MM:SS") +
                          " - " + par_cdprogra + "' --> '" +
                              "ATENCAO: NAO FOI POSSIVEL ZERAR O SALDO -" +
                              " CONTA = " +
                              STRING(par_nrdconta,"zzzz,zzz,9") +
                              " CONTRATO = " +
                              STRING(par_nrctremp,"z,zzz,zz9") +
                              " SALDO = " +
                              STRING(par_vlsdeved,"zzz,zz9.99").
              END.
        END.
      ELSE
          ASSIGN aux_vljurmes = aux_vljurmes - par_vlsdeved
                 par_vljuracu = par_vljuracu - par_vlsdeved
                 par_vlsdeved = 0.
  END.

END PROCEDURE.
/* .......................................................................... */

PROCEDURE proc_deb_empres:
/* ..........................................................................

   Programa: Fontes/crps120_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                            Ultima atualizacao: 23/01/2009

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pelo crps120.
   Objetivo  : Processar os debitos de emprestimos.

              
............................................................................. */

DEF INPUT  PARAM par_cdcooper AS INT.
DEF INPUT  PARAM par_cdprogra AS CHAR                                NO-UNDO.
DEF INPUT  PARAM par_inproces AS INTEGER                             NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_dtmvtopr AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrctremp AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_nrdolote AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_vldaviso AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_vlsalliq AS DECIMAL                             NO-UNDO.
DEF INPUT  PARAM par_dtintegr AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_insitavs AS INT                                 NO-UNDO.
DEF OUTPUT PARAM par_vldebito AS DECIMAL                             NO-UNDO.
DEF OUTPUT PARAM par_vlestdif AS DECIMAL                             NO-UNDO.
DEF OUTPUT PARAM par_flgproce AS LOGICAL                             NO-UNDO.
DEFINE OUTPUT PARAMETER TABLE FOR tt-critic.

DEF        VAR tab_vlmindeb AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmesnov AS DATE                                  NO-UNDO.
DEF        VAR aux_inusatab AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO. 
DEF        VAR aux_nrdconta AS INT     FORMAT "99999999"             NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL FORMAT "9999999999.99-"       NO-UNDO.
DEF        VAR aux_dtultpag AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF        VAR aux_vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"  NO-UNDO.
DEF        VAR aux_txdjuros AS DECIMAL DECIMALS 7                    NO-UNDO.
DEF        VAR aux_inhst093 AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrctremp AS INT                                   NO-UNDO.
DEF        VAR aux_nrultdia AS INT                                   NO-UNDO.
DEF        VAR aux_inliquid AS INT                                   NO-UNDO.
DEF        VAR aux_qtprepag AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR    FORMAT "X(100)"               NO-UNDO.

ASSIGN par_vldebito = 0
       par_flgproce = FALSE.

FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = 11           AND
                   craptab.cdacesso = "TAXATABELA" AND
                   craptab.tpregist = 0 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     aux_inusatab = FALSE.
ELSE
     aux_inusatab = IF SUBSTRING(craptab.dstextab,1,1) = "0"
                       THEN FALSE
                       ELSE TRUE.
/* Valor minimo para debito dos atrasos das prestacoes */
FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "GENERI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "VLMINDEBTO"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craptab THEN
     ASSIGN tab_vlmindeb = 0.
ELSE
     ASSIGN tab_vlmindeb = DEC(craptab.dstextab).    

/*  Leitura do contrato de emprestimo  */

DO WHILE TRUE:

    FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND   
                       crapepr.nrdconta = par_nrdconta   AND
                       crapepr.nrctremp = par_nrctremp
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE crapepr   THEN
      DO:
          IF   LOCKED crapepr   THEN
            DO:
                PAUSE 2 NO-MESSAGE.
                NEXT.
            END.
          ELSE
            DO:
                RUN critica (INPUT 356,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 356.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                   par_cdprogra + "' --> '" + aux_dscritic +
                                  " CTA: " + STRING(par_nrdconta,"zzzzzzz,9") +
                                  " CTR: " + STRING(par_nrctremp,"z,zzz,zz9").
                RETURN "NOK".
            END.
      END.
    IF   crapepr.inliquid > 0   THEN
      DO:
          ASSIGN par_insitavs = 1
                 par_vlestdif = par_vldaviso
                 par_flgproce = TRUE.
          RETURN.
      END.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

IF aux_inusatab AND crapepr.inliquid = 0 THEN
  DO:
    /* FIND craplcr OF crapepr NO-LOCK NO-ERROR. */
      FIND craplcr WHERE craplcr.cdcooper = par_cdcooper     AND
                         craplcr.cdlcremp = crapepr.cdlcremp 
                         NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craplcr   THEN
        DO:
            RUN critica (INPUT 363,
                         OUTPUT aux_dscritic).
            CREATE tt-critic.
            ASSIGN tt-critic.cdcritic = 363.
                   tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                par_cdprogra + "' --> '" + aux_dscritic +
                                " LCR: " + STRING(crapepr.cdlcremp,"zzz9").
            RETURN "NOK".
        END.
      ELSE
         ASSIGN aux_txdjuros = craplcr.txdiaria.
  END.
ELSE
     aux_txdjuros = crapepr.txjuremp.

/*  Inicializacao das variaves de calculo  */

ASSIGN aux_nrdconta = crapepr.nrdconta
       aux_nrctremp = crapepr.nrctremp
       aux_vlsdeved = crapepr.vlsdeved
       aux_vljuracu = crapepr.vljuracu
       aux_dtultpag = crapepr.dtultpag
       aux_inliquid = crapepr.inliquid
       aux_qtprepag = crapepr.qtprepag
       aux_dtcalcul = IF par_inproces > 2
                         THEN par_dtintegr
                         ELSE ?.


RUN lelem (input par_cdcooper,
           input par_dtmvtolt,
           input par_dtmvtopr,
           input crapepr.nrdconta,
           input crapepr.dtmvtolt,      
           input crapepr.cdlcremp,
           input crapepr.cdempres, 
           input crapepr.flgpagto,
           input crapepr.nrctremp,
           input crapepr.dtultpag,
           input crapepr.vlpreemp,
           input crapepr.qtpreemp,
           input crapepr.dtdpagto,
           input crapepr.inliquid,
           input par_inproces,
           input par_cdprogra,
           input crapepr.vlsdeved,
           input aux_txdjuros, 
           input aux_qtprepag,
           input aux_dtcalcul,
           input crapepr.vljuracu,
           OUTPUT TABLE tt-critic).

IF RETURN-VALUE <> "" THEN
    RETURN "NOK".

IF   aux_vlsdeved <= 0   THEN
  DO:
      ASSIGN crapepr.inliquid = 1
             par_vlestdif     = par_vldaviso
             par_insitavs     = 1
             par_flgproce     = TRUE.
      RETURN.
  END.

IF   aux_vlsdeved > par_vldaviso   THEN
  DO:
      IF   par_vldaviso > par_vlsalliq   THEN
          ASSIGN aux_vllanmto = par_vlsalliq
                 par_vlestdif = par_vlsalliq - par_vldaviso
                 par_insitavs = 0.
      ELSE
          ASSIGN aux_vllanmto = par_vldaviso
                 par_vlestdif = 0
                 par_insitavs = 1
                 par_flgproce = TRUE.
                    
      IF   aux_vllanmto < tab_vlmindeb   THEN
        DO:
            ASSIGN par_vlestdif = par_vldaviso * -1
                   par_insitavs = 0
                   par_flgproce = FALSE.
            RETURN.
        END.
  END.
ELSE
  DO:
      IF   aux_vlsdeved > par_vlsalliq   THEN
          ASSIGN aux_vllanmto = par_vlsalliq
                 par_vlestdif = par_vlsalliq - aux_vlsdeved
                 par_insitavs = 0.
      ELSE
          ASSIGN aux_vllanmto = aux_vlsdeved
                 par_vlestdif = par_vldaviso - aux_vlsdeved
                 par_insitavs = 1
                 par_flgproce = TRUE.
  END.

DO WHILE TRUE:

   FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                      craplot.dtmvtolt = par_dtintegr   AND
                      craplot.cdagenci = aux_cdagenci   AND
                      craplot.cdbccxlt = aux_cdbccxlt   AND
                      craplot.nrdolote = par_nrdolote
                      USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

   IF   NOT AVAILABLE craplot   THEN
     DO:
          IF   LOCKED craplot   THEN
            DO:
                NEXT.
            END.
          ELSE
            DO:
                RUN critica (INPUT 60,
                          OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 60.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                  par_cdprogra + "' --> '" + aux_dscritic +
                                  " AG: 001 BCX: 100 LOTE: " +
                                  STRING(par_nrdolote,"999999").
                RETURN "NOK".
            END.
     END.
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

CREATE craplem.
ASSIGN craplem.dtmvtolt = craplot.dtmvtolt
       craplem.cdagenci = craplot.cdagenci
       craplem.cdbccxlt = craplot.cdbccxlt
       craplem.nrdolote = craplot.nrdolote
       craplem.nrdconta = aux_nrdconta
       craplem.nrctremp = crapepr.nrctremp
       craplem.nrdocmto = craplot.nrseqdig + 1
       craplem.vllanmto = aux_vllanmto
       craplem.cdhistor = par_cdhistor
       craplem.nrseqdig = craplot.nrseqdig + 1
       craplem.dtpagemp = craplot.dtmvtolt
       craplem.txjurepr = aux_txdjuros
       craplem.cdcooper = par_cdcooper
       craplem.vlpreemp = crapepr.vlpreemp
       craplot.qtinfoln = craplot.qtinfoln + 1
       craplot.qtcompln = craplot.qtcompln + 1
       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
       craplot.nrseqdig = craplem.nrseqdig
       crapepr.dtultpag = craplot.dtmvtolt
       crapepr.txjuremp = aux_txdjuros
       crapepr.inliquid = IF (aux_vlsdeved - aux_vllanmto) > 0 
                          THEN 0 ELSE 1
       par_vldebito     = aux_vllanmto.
VALIDATE craplem.


/* .......................................................................... */

END PROCEDURE.


PROCEDURE proc_deb_plano_capital:
/* ..........................................................................

       Programa: Fontes/crps120_2.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Deborah/Edson
       Data    : Junho/95.                      Ultima atualizacao: 16/02/2006

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado pelo crps120.
       Objetivo  : Processar os debitos dos planos de capital (Cotas).


............................................................................. */
DEF INPUT  PARAM par_cdcooper AS INT                                 NO-UNDO.
DEF INPUT  PARAM par_dtmvtolt AS DATE                                NO-UNDO.
DEF INPUT  PARAM par_cdprogra AS CHAR                                NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrdconta AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrctrpla AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrdolote AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_vldaviso AS DECIMAL                      NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_vlsalliq AS DECIMAL                      NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_dtintegr AS DATE                         NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_dtdemiss AS DATE                         NO-UNDO.
DEF INPUT  PARAM par_cdhistor AS INT                                 NO-UNDO.
DEF INPUT-OUTPUT PARAM par_insitavs AS INT                           NO-UNDO.
DEF INPUT-OUTPUT PARAM par_vldebito AS DECIMAL                       NO-UNDO.
DEF INPUT-OUTPUT PARAM par_vlestdif AS DECIMAL                       NO-UNDO.
DEF INPUT-OUTPUT PARAM par_vldoipmf AS DECIMAL                       NO-UNDO.
DEF INPUT-OUTPUT PARAM par_flgproce AS LOGICAL                       NO-UNDO.
DEFINE OUTPUT PARAMETER TABLE FOR tt-critic.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrmesant AS INT                                   NO-UNDO.
DEF        VAR aux_flgsomar AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vllanmto AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.
ASSIGN par_vldebito = 0
       par_flgproce = FALSE
       aux_nrmesant = IF MONTH(par_dtmvtolt) = 1
                      THEN 12
                      ELSE MONTH(par_dtmvtolt) - 1.

/*  Leitura do contrato de plano  */

DO WHILE TRUE:
    FIND FIRST crappla WHERE crappla.cdcooper = par_cdcooper  AND
                             crappla.nrdconta = par_nrdconta  AND
                             crappla.tpdplano = 1             AND
                             crappla.cdsitpla = 1
                             USE-INDEX crappla1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE crappla   THEN
      DO:
          IF   LOCKED crappla   THEN
            DO:
                NEXT.
            END.
          ELSE
            DO:
                ASSIGN par_vlestdif = par_vldaviso
                       par_insitavs = 1
                       par_flgproce = TRUE.
                RETURN.
            END.
      END.
    ELSE
      DO:
          IF   crappla.qtprepag > crappla.qtpremax  THEN
            DO:
                ASSIGN par_vlestdif = par_vldaviso
                       par_insitavs = 1
                       par_flgproce = TRUE.
                RETURN.
            END.
      END.
    
    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper       AND
                       crapcot.nrdconta = crappla.nrdconta   
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE crapcot   THEN
      DO:
          IF   LOCKED crapcot   THEN
              NEXT.
          ELSE
            DO:
                RUN critica (INPUT 169,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 169.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                  par_cdprogra + "' --> '" + aux_dscritic +
                                  " CTA: " + STRING(par_nrdconta,"zzzzzzz,9").
                RETURN "NOK".
            END.
      END.
    LEAVE.
END.  /*  Fim do DO WHILE TRUE  */

IF   MONTH(par_dtmvtolt) = MONTH(crappla.dtultpag) THEN
    aux_flgsomar = TRUE.
ELSE
    aux_flgsomar = FALSE.

par_vldoipmf = 0.

IF   par_vldaviso > (par_vlsalliq + par_vldoipmf)   THEN
  DO:
      ASSIGN par_vlestdif = par_vldaviso * -1
             par_insitavs = 0
             par_vldoipmf = 0.
      RETURN.
  END.
ELSE
    ASSIGN aux_vllanmto = par_vldaviso
           par_vlestdif = 0
           par_insitavs = 1
           par_flgproce = TRUE.

DO WHILE TRUE:
    FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                       craplot.dtmvtolt = par_dtintegr   AND
                       craplot.cdagenci = aux_cdagenci   AND
                       craplot.cdbccxlt = aux_cdbccxlt   AND
                       craplot.nrdolote = par_nrdolote
                       USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE craplot   THEN
        IF   LOCKED craplot   THEN
          DO:
              NEXT.
          END.
        ELSE
          DO:
              RUN critica (INPUT 60,
                           OUTPUT aux_dscritic).
              CREATE tt-critic.
              ASSIGN tt-critic.cdcritic = 60.
                     tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                               par_cdprogra + "' --> '" + aux_dscritic +
                               " AG: 001 BCX: 100 LOTE: " +
                               STRING(par_nrdolote,"999999").
              RETURN "NOK".
          END.
        LEAVE.
END.  /*  Fim do DO WHILE TRUE  */

CREATE craplct.
ASSIGN craplct.dtmvtolt = craplot.dtmvtolt
       craplct.cdagenci = craplot.cdagenci
       craplct.cdbccxlt = craplot.cdbccxlt
       craplct.nrdolote = craplot.nrdolote
       craplct.nrdconta = crappla.nrdconta
       craplct.nrdocmto = craplot.nrdolote
       craplct.cdhistor = par_cdhistor
       craplct.vllanmto = aux_vllanmto
       craplct.nrseqdig = craplot.nrseqdig + 1
       craplct.nrctrpla = crappla.nrctrpla
       craplct.cdcooper = par_cdcooper

       craplot.qtinfoln = craplot.qtinfoln + 1
       craplot.qtcompln = craplot.qtcompln + 1
       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
       craplot.nrseqdig = craplct.nrseqdig

       crapcot.vldcotas = crapcot.vldcotas + aux_vllanmto
       crapcot.qtprpgpl = crapcot.qtprpgpl + 1

       crappla.vlpagmes = IF aux_flgsomar
                          THEN crappla.vlpagmes + aux_vllanmto
                          ELSE aux_vllanmto

       crappla.dtultpag = craplot.dtmvtolt
       crappla.qtprepag = crappla.qtprepag + 1
       crappla.vlprepag = crappla.vlprepag + aux_vllanmto

       par_vldebito     = aux_vllanmto.

VALIDATE craplct.

IF   crappla.qtprepag = crappla.qtpremax THEN
    ASSIGN crappla.dtcancel = par_dtmvtolt
           crappla.cdsitpla = 2.
/* .......................................................................... */


END PROCEDURE.



PROCEDURE proc_lanct_deposito:
/* ..........................................................................

   Programa: Fontes/crps120_d.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                            Ultima atualizacao: 29/10/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado pelo crps120.
   Objetivo  : Processar os debitos de emprestimos.

............................................................................. */

DEF INPUT         PARAM par_cdcooper AS INT                          NO-UNDO. 
DEF INPUT         PARAM par_cdprogra AS CHAR                         NO-UNDO.
DEF INPUT         PARAM par_cdempres AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_dtintegr AS DATE                         NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_cdagenci AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_cdbccxlt AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrlotfol AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrdconta AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM TABLE FOR tt-vldebcta.
DEF INPUT-OUTPUT  PARAM TABLE FOR tt-critic.

DEF VAR                 aux_dscritic AS CHAR                         NO-UNDO.

TRANS_1:

DO ON ERROR UNDO TRANS_1, RETURN:

   FOR EACH tt-vldebcta:
      
      IF tt-vldebcta.vldebcta > 0   THEN
        DO:
            DO WHILE TRUE:

                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtintegr   AND
                                   craplot.cdagenci = par_cdagenci   AND
                                   craplot.cdbccxlt = par_cdbccxlt   AND
                                   craplot.nrdolote = par_nrlotfol
                                   USE-INDEX craplot1
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craplot   THEN
                    IF   LOCKED craplot   THEN
                      DO:
                          NEXT.
                      END.
                    ELSE                                                          
                      DO:
                          RUN critica (INPUT 60,
                                       OUTPUT aux_dscritic).
                          CREATE tt-critic.
                          ASSIGN tt-critic.cdcritic = 60.
                                 tt-critic.dscritic = 
                                     STRING(TIME,"HH:MM:SS") + " - " +
                                 par_cdprogra + "' --> '" + aux_dscritic +
                                 " EMPRESA = " + 
                                 STRING(par_cdempres,"99999") +
                                 " LOTE = " +
                                 STRING(par_nrlotfol,"9,999").
                          UNDO TRANS_1, RETURN "NOK".
                      END.

                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
            CREATE craplcm.
            ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrdconta = par_nrdconta
                   craplcm.nrdctabb = par_nrdconta
                   craplcm.nrdctitg = STRING(par_nrdconta,"99999999")
                   craplcm.nrdocmto = craplot.nrseqdig + 1
                   craplcm.cdhistor = tt-vldebcta.nrsequen
                   craplcm.vllanmto = tt-vldebcta.vldebcta
                   craplcm.nrseqdig = craplot.nrseqdig + 1
                   craplcm.cdcooper = par_cdcooper
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.vlinfodb = craplot.vlinfodb +
                                      tt-vldebcta.vldebcta
                   craplot.vlcompdb = craplot.vlcompdb +
                                      tt-vldebcta.vldebcta
                   craplot.nrseqdig = craplcm.nrseqdig.
            VALIDATE craplcm.
        END.

   END.  /*  Fim do DO .. while  */

END. /* transaction */
END PROCEDURE.

PROCEDURE cpmf:
/*.............................................................................

   Programa: ipmf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Paulo - Precise
   Data    : Agosto/2009.                        

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IPMF.

............................................................................. */
/*  Tabela com a taxa do CPMF */

DEF INPUT         PARAM par_cdcooper AS INT                          NO-UNDO.
DEF INPUT         PARAM par_dtmvtolt AS DATE                         NO-UNDO.
DEF OUTPUT        PARAM par_dtinipmf AS DATE                         NO-UNDO.
DEF OUTPUT        PARAM par_dtfimpmf AS DATE                         NO-UNDO.
DEF OUTPUT        PARAM par_txcpmfcc AS DECIMAL                      NO-UNDO.
DEF OUTPUT        PARAM par_txrdcpmf AS DECIMAL                      NO-UNDO.
DEF OUTPUT        PARAM par_indabono AS INTE                         NO-UNDO.
DEF OUTPUT        PARAM par_dtiniabo AS DATE                         NO-UNDO.
DEF INPUT-OUTPUT  PARAM TABLE FOR tt-critic.    
DEF VAR                 aux_dscritic AS CHAR                         NO-UNDO.



FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "USUARI"           AND
                   craptab.cdempres = 11                 AND
                   craptab.cdacesso = "CTRCPMFCCR"       AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
  DO:
      RUN critica (INPUT 641,
                   OUTPUT aux_dscritic).
      CREATE tt-critic.
      ASSIGN tt-critic.cdcritic = 641.
             tt-critic.dscritic = aux_dscritic .
      RETURN "NOK".     
  END.
 
ASSIGN par_dtinipmf = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                           INT(SUBSTRING(craptab.dstextab,1,2)),
                           INT(SUBSTRING(craptab.dstextab,7,4)))
       par_dtfimpmf = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                           INT(SUBSTRING(craptab.dstextab,12,2)),
                           INT(SUBSTRING(craptab.dstextab,18,4)))
       par_txcpmfcc = IF par_dtmvtolt >= par_dtinipmf AND
                         par_dtmvtolt <= par_dtfimpmf 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,23,13))
                         ELSE 0
       par_txrdcpmf = IF par_dtmvtolt >= par_dtinipmf AND
                         par_dtmvtolt <= par_dtfimpmf 
                         THEN DECIMAL(SUBSTR(craptab.dstextab,38,13))
                         ELSE 1
       par_indabono = INTE(SUBSTR(craptab.dstextab,51,1))  /* 0 = abona
                                                              1 = nao abona */
       par_dtiniabo = DATE(INT(SUBSTRING(craptab.dstextab,56,2)),
                           INT(SUBSTRING(craptab.dstextab,53,2)),
                           INT(SUBSTRING(craptab.dstextab,59,4))). /* data de
                                         inicio do abono */
END PROCEDURE.


PROCEDURE digfun:
/* .............................................................................

   Programa: digfun.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : Genericos
   Autor   : Paulo - Precise
   Data    : Agosto/2009

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.
               Disponibilizar nro calculado digito "X" 


............................................................................. */
DEF INPUT-OUTPUT PARAM par_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" NO-UNDO.
DEF INPUT-OUTPUT PARAM par_stsnrcal AS LOGICAL                         NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 9                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

IF   LENGTH(STRING(par_nrcalcul)) < 2   THEN
  DO:
      par_stsnrcal = FALSE.
      RETURN.
  END.

DO  aux_posicao = (LENGTH(STRING(par_nrcalcul)) - 1) TO 1 BY -1:

    aux_calculo = aux_calculo + 
                 (INTEGER(SUBSTRING(STRING(par_nrcalcul),aux_posicao,1)) 
                  * aux_peso).

    aux_peso = aux_peso - 1.

    IF aux_peso = 1 THEN
        aux_peso = 9.
END.  /*  Fim do DO .. TO  */

aux_resto = aux_calculo MODULO 11.
                             
IF   aux_resto > 9   THEN
     aux_digito = 0.
ELSE
     aux_digito = aux_resto.

IF  (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                LENGTH(STRING(par_nrcalcul)),1))) <> aux_digito   THEN
    par_stsnrcal = FALSE.
ELSE
    par_stsnrcal = TRUE.

par_nrcalcul = DECIMAL(SUBSTRING(STRING(par_nrcalcul),1,
                                 LENGTH(STRING(par_nrcalcul)) - 1) +
                                 STRING(aux_digito)).

/* Trata conta da CONCREDI na CEF */

IF   par_nrcalcul = 30035007 THEN
     ASSIGN par_nrcalcul = 30035008
            par_stsnrcal = TRUE.

END PROCEDURE.

PROCEDURE cria_lote:

/* ..........................................................................

   Programa: Includes/crps120_l.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : Genericos
   Autor   : Paulo - Precise
   Data    : Agosto/2009.
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Leitura e criacao dos lotes utilizados.
DEF INPUT         PARAM par_cdprogra AS CHAR                         NO-UNDO.


............................................................................. */

DEF INPUT         PARAM par_cdcooper AS INT                          NO-UNDO.
DEF INPUT         PARAM par_cdprogra AS CHAR                         NO-UNDO.
DEF INPUT         PARAM par_dtintegr AS DATE                         NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_cdempsol LIKE crapsol.cdempres           NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrlotfol AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_flgclote AS LOGICAL                      NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrlotcot AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAM par_nrlotemp AS INT                          NO-UNDO.
DEF INPUT-OUTPUT  PARAMETER TABLE FOR tt-critic.

DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.

DO WHILE TRUE:           /*  Lote do Credito Folha/Debito  */

    FIND craptab 
        WHERE craptab.cdcooper = par_cdcooper   AND
              craptab.nmsistem = "CRED"         AND
              craptab.tptabela = "GENERI"       AND
              craptab.cdempres = 0              AND
              craptab.cdacesso = "NUMLOTEFOL"   AND
              craptab.tpregist = par_cdempsol
              USE-INDEX craptab1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   NOT AVAILABLE craptab   THEN
      DO:
          IF   LOCKED craptab   THEN
          DO:
              NEXT.
          END.
          ELSE
            DO:     
                RUN critica (INPUT 175,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 641.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                            par_cdprogra + "' --> '" + aux_dscritic +
                            " EMPRESA = " + STRING(par_cdempsol,"99999") .
                RETURN "NOK".
            END.
      END.
    ELSE
        par_nrlotfol = INTEGER(craptab.dstextab).

    IF par_flgclote   THEN
      DO:
          par_nrlotfol = par_nrlotfol + 1.

          IF   CAN-FIND(craplot WHERE craplot.cdcooper = par_cdcooper AND
                                      craplot.dtmvtolt = par_dtintegr AND
                                      craplot.cdagenci = aux_cdagenci AND
                                      craplot.cdbccxlt = aux_cdbccxlt AND
                                      craplot.nrdolote = par_nrlotfol
                                      USE-INDEX craplot1)   THEN
            DO:
                RUN critica (INPUT 59,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 59.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                par_cdprogra + "' --> '" + aux_dscritic +
                                " EMPRESA = " + STRING(par_cdempsol,"99999") +
                                " LOTE = " + STRING(par_nrlotfol,"9,99999").
                RETURN "NOK".
            END.
          CREATE craplot.
          ASSIGN craplot.dtmvtolt = par_dtintegr
                 craplot.cdagenci = aux_cdagenci
                 craplot.cdbccxlt = aux_cdbccxlt
                 craplot.nrdolote = par_nrlotfol
                 craplot.tplotmov = 1
                 craplot.cdcooper = par_cdcooper
                 craptab.dstextab = "9" + 
                         STRING(INT(SUBSTR(STRING(par_nrlotfol),2)),"99999").
          VALIDATE craplot.
      END.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

DO WHILE TRUE:               /*  Lote do Credito de COTAS  */

    FIND craptab 
        WHERE craptab.cdcooper = par_cdcooper   AND
              craptab.nmsistem = "CRED"         AND
              craptab.tptabela = "GENERI"       AND
              craptab.cdempres = 0              AND
              craptab.cdacesso = "NUMLOTECOT"   AND
              craptab.tpregist = par_cdempsol
              USE-INDEX craptab1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab   THEN
      DO:
          IF   LOCKED craptab   THEN
          DO:
              NEXT.
          END.
          ELSE
          DO:
              RUN critica (INPUT 175,
                          OUTPUT aux_dscritic).
              CREATE tt-critic.
              ASSIGN tt-critic.cdcritic = 59.
                     tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                              par_cdprogra + "' --> '" + aux_dscritic +
                              " EMPRESA = " + STRING(par_cdempsol,"99999") .
              RETURN "NOK".
          END.
      END.
    ELSE
        par_nrlotcot = INTEGER(craptab.dstextab).

    IF par_flgclote   THEN
      DO:
          par_nrlotcot = par_nrlotcot + 1.

          IF   CAN-FIND(craplot WHERE craplot.cdcooper = par_cdcooper AND
                                      craplot.dtmvtolt = par_dtintegr AND
                                      craplot.cdagenci = aux_cdagenci AND
                                      craplot.cdbccxlt = aux_cdbccxlt AND
                                      craplot.nrdolote = par_nrlotcot
                                      USE-INDEX craplot1)   THEN
            DO:
                RUN critica (INPUT 59,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 59.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                par_cdprogra + "' --> '" + aux_dscritic +
                                " EMPRESA = " + STRING(par_cdempsol,"99999") +
                                " LOTE = " + STRING(par_nrlotcot,"9,99999").
                RETURN "NOK".
            END.

          CREATE craplot.
          ASSIGN craplot.dtmvtolt = par_dtintegr
                 craplot.cdagenci = aux_cdagenci
                 craplot.cdbccxlt = aux_cdbccxlt
                 craplot.nrdolote = par_nrlotcot
                 craplot.tplotmov = 3
                 craplot.cdcooper = par_cdcooper
                 craptab.dstextab = "8" + STRING(INT(SUBSTR(
                                          STRING(par_nrlotcot),2)),
                                                "99999").
          VALIDATE craplot.
      END.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

DO WHILE TRUE:         /*  Lote do Credito de EMPRESTIMOS  */

    FIND craptab 
        WHERE craptab.cdcooper = par_cdcooper   AND
              craptab.nmsistem = "CRED"         AND
              craptab.tptabela = "GENERI"       AND
              craptab.cdempres = 0              AND
              craptab.cdacesso = "NUMLOTEEMP"   AND
              craptab.tpregist = par_cdempsol
              USE-INDEX craptab1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF NOT AVAILABLE craptab THEN
      DO:
          IF   LOCKED craptab   THEN
            DO:
                NEXT.
            END.
          ELSE
            DO:
                RUN critica (INPUT 175,
                         OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 175.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                    par_cdprogra + "' --> '" + aux_dscritic +
                                  " EMPRESA = " + STRING(par_cdempsol,"99999").
                RETURN "NOK".
            END.
      END.
    ELSE
        par_nrlotemp = INTEGER(craptab.dstextab).

    IF par_flgclote   THEN
      DO:
          par_nrlotemp = par_nrlotemp + 1.

          IF CAN-FIND(craplot 
             WHERE craplot.cdcooper = par_cdcooper   AND
                   craplot.dtmvtolt = par_dtintegr   AND
                   craplot.cdagenci = aux_cdagenci   AND
                   craplot.cdbccxlt = aux_cdbccxlt   AND
                   craplot.nrdolote = par_nrlotemp
                   USE-INDEX craplot1)   THEN
            DO:
                RUN critica (INPUT 59,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 59.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                              par_cdprogra + "' --> '" + aux_dscritic +
                              " EMPRESA = " + STRING(par_cdempsol,"99999") +
                              " LOTE = " + STRING(par_nrlotemp,"9,99999").
                RETURN "NOK".
            END.

          CREATE craplot.
          ASSIGN craplot.dtmvtolt = par_dtintegr
                 craplot.cdagenci = aux_cdagenci
                 craplot.cdbccxlt = aux_cdbccxlt
                 craplot.nrdolote = par_nrlotemp
                 craplot.tplotmov = 5
                 craplot.cdcooper = par_cdcooper
                 craptab.dstextab = "5" + STRING(INT(SUBSTR(
                                          STRING(par_nrlotemp),2)),
                                                 "99999").
          VALIDATE craplot.
      END.

    LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

par_flgclote = FALSE.

END PROCEDURE.
/* .......................................................................... */

PROCEDURE trata_cdempres:

DEF INPUT  PARAM par_cdcooper AS INT  NO-UNDO.
DEF INPUT  PARAM par_inpessoa AS INT  NO-UNDO.
DEF INPUT  PARAM par_nrdconta AS INT  NO-UNDO.
DEF OUTPUT PARAM par_cdempres AS INT  NO-UNDO.

ASSIGN par_cdempres = 0.
  
IF   par_inpessoa = 1  THEN
  DO:
      FIND crapttl WHERE crapttl.cdcooper = par_cdcooper  AND
                         crapttl.nrdconta = par_nrdconta  AND
                         crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
                               
      IF   AVAIL crapttl  THEN
          ASSIGN par_cdempres = crapttl.cdempres.
  END.
ELSE
  DO:
      FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                         crapjur.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.
                                      
      IF   AVAIL crapjur  THEN
          ASSIGN par_cdempres = crapjur.cdempres.
  END.

END PROCEDURE.

/**********************************************************************/

PROCEDURE p_trata_crapccs:

DEFINE INPUT        PARAM par_cdcooper AS INTEGER NO-UNDO. 
DEFINE INPUT        PARAM par_cdprogra AS CHAR    NO-UNDO.
DEFINE INPUT        PARAM par_cdoperad AS CHAR    NO-UNDO. 
DEFINE INPUT-OUTPUT PARAM par_flfirst2 AS LOGICAL NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_nrlotccs AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_dtintegr AS DATE    NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_dtmvtolt AS DATE    NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_nrdconta AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_cdempres AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_cdhistor AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_vllanmto AS DECIMAL NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_nrseqint AS INTEGER NO-UNDO.
DEFINE INPUT-OUTPUT PARAM TABLE FOR tt-critic.

DEFINE VAR aux_nrdocmto AS INTEGER                NO-UNDO.
DEFINE VAR aux_nrdocmt2 AS INTEGER                NO-UNDO.
DEFINE VAR aux_dscritic AS CHAR                   NO-UNDO.
DEFINE VAR aux_cdcritic AS INTEGER                NO-UNDO.

aux_nrdocmto = INTEGER(STRING(par_nrseqint,"99999")).
    
DO WHILE TRUE:
    ASSIGN aux_cdcritic = 0.
    IF   crapccs.cdsitcta = 2 THEN
        aux_cdcritic = 444.
    ELSE
    IF   crapccs.dtcantrf <> ? THEN
        aux_cdcritic = 890.

    IF aux_cdcritic > 0 THEN
      DO:
          RUN critica (INPUT  aux_cdcritic,
                       OUTPUT aux_dscritic).
          CREATE tt-critic.
          ASSIGN tt-critic.cdcritic = aux_cdcritic.
                 tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                      par_cdprogra + "' --> '" + aux_dscritic.
      END.
    LEAVE.
END.

TRANS_4:

DO TRANSACTION ON ERROR UNDO TRANS_4, RETURN:

    IF  par_flfirst2 THEN
        par_nrlotccs = 10201.

    DO WHILE TRUE:
         
        FIND craplot 
            WHERE craplot.cdcooper = par_cdcooper   AND
                  craplot.dtmvtolt = par_dtintegr   AND
                  craplot.cdagenci = 1              AND
                  craplot.cdbccxlt = 100            AND
                  craplot.nrdolote = par_nrlotccs
                  USE-INDEX craplot1 NO-ERROR NO-WAIT.

        IF NOT AVAILABLE craplot  THEN
          DO:
              IF NOT LOCKED craplot   THEN
                DO:
                    CREATE craplot.
                    ASSIGN craplot.cdcooper = par_cdcooper
                           craplot.dtmvtolt = par_dtintegr
                           craplot.cdagenci = 1
                           craplot.cdbccxlt = 100
                           craplot.nrdolote = par_nrlotccs
                           craplot.tplotmov = 32
                           par_flfirst2     = FALSE.
                    VALIDATE craplot.

                    LEAVE.
                END.
              ELSE
                DO:
                    IF NOT par_flfirst2 THEN
                      DO:
                          PAUSE 1 NO-MESSAGE.
                          NEXT.
                      END.
                END.
          END.         
        ELSE
            IF par_flfirst2 THEN
                par_nrlotccs = par_nrlotccs + 1.
            ELSE
                LEAVE.
    END.
          
    IF   aux_cdcritic > 0   THEN
      DO:
          CREATE craprej.
          ASSIGN craprej.dtmvtolt = par_dtmvtolt
                 craprej.cdagenci = craplot.cdagenci
                 craprej.cdbccxlt = craplot.cdbccxlt
                 craprej.nrdolote = craplot.nrdolote
                 craprej.tplotmov = craplot.tplotmov
                 craprej.nrdconta = par_nrdconta
                 craprej.cdempres = par_cdempres
                 craprej.cdhistor = par_cdhistor
                 craprej.vllanmto = par_vllanmto
                 craprej.cdcritic = aux_cdcritic
                 craprej.tpintegr = 1
                 craprej.cdcooper = par_cdcooper
                 craplot.qtinfoln = craplot.qtinfoln + 1
                 craplot.vlinfocr = craplot.vlinfocr + par_vllanmto
                 aux_cdcritic     = 0.
          VALIDATE craprej.
      END.
    ELSE
      DO:
          aux_nrdocmt2 = aux_nrdocmto.
                
          DO WHILE TRUE:
                                
              FIND craplcs 
                   WHERE craplcs.cdcooper = par_cdcooper   AND
                         craplcs.dtmvtolt = par_dtintegr   AND
                         craplcs.nrdconta = par_nrdconta   AND
                         craplcs.cdhistor = 560            AND
                         craplcs.nrdocmto = aux_nrdocmt2
                         NO-LOCK NO-ERROR NO-WAIT.

              IF   AVAILABLE craplcs THEN
                  aux_nrdocmt2 = (aux_nrdocmt2 + 1000000).
              ELSE
                  LEAVE.
          
          END.  /*  Fim do DO WHILE TRUE  */

          aux_nrdocmto = aux_nrdocmt2.
          
          CREATE craplcs.
          ASSIGN craplcs.cdcooper = par_cdcooper
                 craplcs.cdopecrd = par_cdoperad
                 craplcs.dtmvtolt = par_dtintegr
                 craplcs.nrdconta = par_nrdconta
                 craplcs.nrdocmto = aux_nrdocmto
                 craplcs.vllanmto = par_vllanmto
                 craplcs.cdhistor = 560
                 craplcs.nrdolote = craplot.nrdolote 
                 craplcs.cdbccxlt = craplot.cdbccxlt
                 craplcs.cdagenci = craplot.cdagenci
                 craplcs.flgenvio = FALSE
                 craplcs.cdopetrf = ""
                 craplcs.dttransf = ?
                 craplcs.hrtransf = 0
                 craplcs.nmarqenv = ""
                 craplot.qtinfoln = craplot.qtinfoln + 1
                 craplot.qtcompln = craplot.qtcompln + 1
                 craplot.vlinfocr = craplot.vlinfocr + par_vllanmto
                 craplot.vlcompcr = craplot.vlcompcr + par_vllanmto
                 craplot.nrseqdig = par_nrseqint.
          VALIDATE craplcs.
      END.
                              
    DO WHILE TRUE:

        FIND crapres 
            WHERE crapres.cdcooper = par_cdcooper  AND
                  crapres.cdprogra = par_cdprogra
                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crapres   THEN
            IF   LOCKED crapres   THEN
              DO:
                  PAUSE 1 NO-MESSAGE.
                  NEXT.
              END.
            ELSE
              DO:
                  RUN critica (INPUT 151,
                               OUTPUT aux_dscritic).
                  CREATE tt-critic.
                  ASSIGN tt-critic.cdcritic = 151.
                     tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                              par_cdprogra + "' --> '" + aux_dscritic.
                  UNDO TRANS_4, RETURN "NOK".
              END.
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    crapres.nrdconta = par_nrseqint.

END.  /*  Fim da Transacao  */

END PROCEDURE.


PROCEDURE integra_folha_deb_cotas:

/* ..........................................................................

   Programa: Fontes/crps120_3.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/95.                        Ultima atualizacao: 01/09/2008

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Integrar folha de pagamento e debito de cotas e emprestimos.

............................................................................*/

DEFINE INPUT        PARAM par_cdcooper AS INTEGER              NO-UNDO. 
DEFINE INPUT        PARAM par_cdprogra AS CHAR                 NO-UNDO.
DEFINE INPUT        PARAM par_dtmvtolt AS DATE                 NO-UNDO.
DEFINE INPUT        PARAM par_dtmvtopr AS DATE                 NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_dtintegr AS DATE                 NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_dtrefere AS DATE                 NO-UNDO.
DEFINE INPUT        PARAM par_nmarqint AS CHAR    
                                          FORMAT "x(50)"       NO-UNDO.
DEFINE INPUT        PARAM par_flgfirst AS LOGICAL              NO-UNDO.
DEFINE INPUT        PARAM par_inrestar AS INTEGER              NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_cdempfol LIKE crapemp.cdempfol   NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_cdempsol LIKE crapsol.cdempres   NO-UNDO.
DEFINE INPUT        PARAM par_nrctares AS INT 
                                          FORMAT "zzzz,zzz,9"  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_nrlotfol AS INT                  NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_flgclote AS LOGICAL              NO-UNDO.
DEFINE INPUT-OUTPUT PARAM par_nrlotcot AS INT                  NO-UNDO.
DEFINE INPUT        PARAM par_dtultdma AS DATE                 NO-UNDO.
DEFINE INPUT        PARAM par_dtultdia AS DATE                 NO-UNDO.
DEFINE INPUT        PARAM par_cdemprez AS INT                  NO-UNDO.
DEFINE INPUT        PARAM par_inproces AS INT                  NO-UNDO.
DEFINE INPUT        PARAM par_indmarca AS INT                  NO-UNDO.
DEFINE INPUT        PARAM par_dsempres AS CHAR                 NO-UNDO.
DEFINE INPUT        PARAM par_cdoperad AS CHAR                 NO-UNDO.
DEFINE INPUT-OUTPUT PARAM rel_qttarifa AS INT                  NO-UNDO.
DEFINE OUTPUT       PARAM TABLE FOR tt-estconv.
DEFINE OUTPUT       PARAM TABLE FOR tt-estouro.
DEFINE OUTPUT       PARAM TABLE FOR tt-totais-est.
DEFINE OUTPUT       PARAM TABLE FOR tt-aviso.
DEFINE INPUT-OUTPUT PARAM TABLE FOR tt-critic.
DEFINE OUTPUT       PARAM TABLE FOR tt-integracao.
DEFINE OUTPUT       PARAM TABLE FOR tt-rejeitados.
DEFINE OUTPUT       PARAM TABLE FOR tt-totais.

DEF VAR   aux_cfrvipmf      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_vlsalliq      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_flgdente      AS    LOGICAL                      NO-UNDO.
DEF VAR   aux_vldebita      AS    DECIMAL                      NO-UNDO.
DEF VAR   aux_vlpgempr      LIKE  crapepr.vlsdeved             NO-UNDO.
DEF VAR   aux_vldebtot      LIKE  crapepr.vlsdeved             NO-UNDO.
DEF VAR   aux_cdempres_2    AS INT                             NO-UNDO.
DEF VAR   aux_nrlotcot      AS INT                             NO-UNDO.
DEF VAR   aux_flfirst2      AS LOGICAL                         NO-UNDO.
DEF VAR   aux_nrlotccs      AS INT                             NO-UNDO.
DEF VAR   aux_dscritic      AS CHAR                            NO-UNDO.
DEF VAR   aux_cdcritic      AS INT                             NO-UNDO.
DEF VAR   aux_tpregist      AS INT  FORMAT "9"                 NO-UNDO.
DEF VAR   aux_dtmvtoin      AS DATE FORMAT "99/99/9999"        NO-UNDO.
DEF VAR   aux_cdempres      AS INT  FORMAT "99999"             NO-UNDO.
DEF VAR   aux_tpdebito      AS INT  FORMAT "9"                 NO-UNDO.
DEF VAR   aux_vldaurvs      AS DEC  FORMAT "99999.99"          NO-UNDO.
DEF VAR   aux_nrseqint      AS INT  FORMAT "999999"            NO-UNDO.
DEF VAR   ant_nrdconta      AS INT                             NO-UNDO.
DEF VAR   aux_nrdconta      AS INT  FORMAT "zzzz,zzz,9"        NO-UNDO.
DEF VAR   aux_vllanmto      AS DEC  FORMAT "99999999999.99-"   NO-UNDO.
DEF VAR   aux_cdhistor      AS INT  FORMAT "9999"              NO-UNDO.
DEF VAR   aux_flgsomar      AS LOGICAL                         NO-UNDO.
DEF VAR   aux_flgctsal      AS LOGICAL                         NO-UNDO.
DEF VAR   aux_stsnrcal      AS LOGICAL                         NO-UNDO.
DEF VAR   aux_flglotes      AS LOGICAL                         NO-UNDO.
DEF VAR   aux_nrlotemp      AS INT                             NO-UNDO.
DEF VAR   aux_nrdoclot      AS CHAR                            NO-UNDO.
DEF VAR   aux_nrdocmto      AS INT                             NO-UNDO.
DEF VAR   tot_vlsalliq      AS DECIMAL                         NO-UNDO.
DEF VAR   tot_vldebcta      AS DECIMAL EXTENT 999              NO-UNDO.
DEF VAR   aux_vldoipmf      AS DECIMAL                         NO-UNDO.
DEF VAR   rel_qtdifeln      AS INTEGER                         NO-UNDO.
DEF VAR   aux_lshstfun      AS CHAR                            NO-UNDO.
DEF VAR   aux_lshstsau      AS CHAR                            NO-UNDO.
DEF VAR   aux_lshstdiv      AS CHAR                            NO-UNDO.
DEF VAR   tab_dtinipmf      AS DATE                            NO-UNDO.
DEF VAR   tab_dtfimpmf      AS DATE                            NO-UNDO.
DEF VAR   tab_txcpmfcc      AS DECIMAL                         NO-UNDO.
DEF VAR   tab_txrdcpmf      AS DECIMAL                         NO-UNDO.
DEF VAR   tab_indabono      AS INTE                            NO-UNDO.
DEF VAR   tab_dtiniabo      AS DATE                            NO-UNDO.
DEF VAR   aux_flgatual      AS LOGICAL                         NO-UNDO.
def var   aux_flgexist      AS LOGICAL                         NO-UNDO.
aux_flglotes = TRUE.
aux_nrlotcot = 0.
aux_nrlotemp = 0.


DEF BUFFER crabass FOR crapass.
DEF BUFFER crabttl FOR crapttl.

/*  Inicializa flag de atualizacao do fator salarial  */

FIND FIRST crapavs WHERE crapavs.cdcooper = par_cdcooper   AND
                         crapavs.dtrefere = par_dtrefere   AND
                         crapavs.tpdaviso = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapavs   THEN
    aux_flgatual = FALSE.
ELSE
    aux_flgatual = TRUE.

IF   par_cdemprez = 11 OR par_cdemprez = 99 THEN
    aux_flgatual = FALSE.

/*  Historicos do convenio 14 - Plano de saude Bradesco ..................... */

FIND crapcnv WHERE crapcnv.cdcooper = par_cdcooper AND
                   crapcnv.nrconven = 14           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcnv THEN
     aux_lshstsau = "".
ELSE
     aux_lshstsau = TRIM(crapcnv.lshistor).

/*  Historicos do convenio 10 e 15 - Hering e ADM diversos .................. */

FIND crapcnv WHERE crapcnv.cdcooper = par_cdcooper AND
                   crapcnv.nrconven = 10           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcnv THEN
     aux_lshstdiv = "".
ELSE
     aux_lshstdiv = TRIM(crapcnv.lshistor).

FIND crapcnv WHERE crapcnv.cdcooper = par_cdcooper AND
                   crapcnv.nrconven = 15           NO-LOCK NO-ERROR.

IF   AVAILABLE crapcnv THEN
  DO:
      IF TRIM(crapcnv.lshistor) <> aux_lshstdiv THEN
          aux_lshstdiv = aux_lshstdiv + "," + TRIM(crapcnv.lshistor).
  END.

FIND crapcnv WHERE crapcnv.cdcooper = par_cdcooper AND
                   crapcnv.nrconven = 18           NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcnv THEN
    aux_lshstfun = "".
ELSE
    aux_lshstfun = TRIM(crapcnv.lshistor).

FIND crapcnv WHERE crapcnv.cdcooper = par_cdcooper AND
                   crapcnv.nrconven = 19           NO-LOCK NO-ERROR.

IF   AVAILABLE crapcnv THEN
  DO:
      IF   TRIM(crapcnv.lshistor) <> aux_lshstfun   THEN
          aux_lshstfun = aux_lshstfun + "," + TRIM(crapcnv.lshistor).
  END.

/* Se e periodo de cobranca de CPMF atualiza variaveis */
RUN cpmf (INPUT  par_cdcooper,
          INPUT  par_dtmvtolt,
          OUTPUT tab_dtinipmf,
          OUTPUT tab_dtfimpmf,
          OUTPUT tab_txcpmfcc,
          OUTPUT tab_txrdcpmf,
          OUTPUT tab_indabono,
          OUTPUT tab_dtiniabo,
          INPUT-OUTPUT TABLE tt-critic).

IF RETURN-VALUE = "NOK" THEN
    RETURN "NOK".
aux_flfirst2 = TRUE.

/*  Leitura do arquivo com os liquidos de pagamento  */

INPUT  STREAM str_2 FROM VALUE(par_nmarqint) NO-ECHO.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, RETURN:
    aux_cdcritic = 0.

    IF   par_flgfirst   THEN
      DO:
          IF   par_inrestar = 0   THEN
            DO:
                RUN critica (INPUT 219,
                             OUTPUT aux_dscritic).
                CREATE tt-critic.
                ASSIGN tt-critic.cdcritic = 219.
                       tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                par_cdprogra + "' --> '" + aux_dscritic + 
                                "' --> '" + par_nmarqint.

                SET STREAM str_2       /*  Registro de controle  */
                    aux_tpregist  aux_dtmvtoin  aux_cdempres
                    aux_tpdebito  aux_vldaurvs.

            /* Coloca sempre tipo de debito 1 (moeda corrente) */

                aux_tpdebito = 1.
                IF aux_tpregist <> 1 THEN
                    aux_cdcritic = 181.
                ELSE
                IF aux_dtmvtoin <> par_dtrefere THEN
                    aux_cdcritic = 789.
                ELSE
                IF   aux_cdempres <> par_cdempfol   THEN
                    aux_cdcritic = 173.
                ELSE
                IF   NOT CAN-DO("1,2",STRING(aux_tpdebito))   THEN
                    aux_cdcritic = 379.

                IF   aux_cdcritic > 0   THEN
                  DO:
                      RUN critica (INPUT aux_cdcritic,
                                 OUTPUT aux_dscritic).
                      CREATE tt-critic.                                         
                      ASSIGN tt-critic.cdcritic = aux_cdcritic.
                             tt-critic.dscritic = 
                                 STRING(TIME,"HH:MM:SS") + " - " +
                                 par_cdprogra + "' --> '" + aux_dscritic + 
                                 " EMPRESA = " + STRING(par_cdempsol,"99999").
                      RETURN "NOK".      /* Le proxima solicitacao */
                  END.

                ASSIGN par_flgfirst = FALSE
                       aux_cdempres = par_cdempsol.
            END.
          ELSE
            DO:
                SET STREAM str_2       /*  Registro de controle  */
                           aux_cdempres aux_tpdebito aux_vldaurvs.

                /* Coloca sempre tipo de debito 1 (moeda corrente) */

                aux_tpdebito = 1.

                DO WHILE aux_nrseqint <> par_nrctares:
                    SET STREAM str_2
                    aux_tpregist  aux_nrseqint ant_nrdconta ^ ^.
                END.
                IF   aux_tpregist = 9   THEN
                    LEAVE.

                ASSIGN par_flgfirst = FALSE
                       aux_cdempres = par_cdempsol.
            END.
      END.
    SET STREAM str_2
        aux_tpregist  aux_nrseqint  aux_nrdconta  aux_vllanmto  aux_cdhistor.
    IF   aux_tpregist = 9 OR aux_nrdconta = 99999999 THEN
        LEAVE.

    /*  Verifica se deve somar o fator salarial  */

    IF   aux_nrdconta = ant_nrdconta    THEN
        aux_flgsomar = TRUE.
    ELSE
        ASSIGN aux_flgsomar = FALSE
               ant_nrdconta = aux_nrdconta
               rel_qttarifa = rel_qttarifa + 1.

   /*--------------Alteracao Numero da Conta - Cecrisa ----*/

    IF  par_cdcooper = 5 THEN 
      DO:
          IF  aux_cdempres = 1 OR aux_cdempres = 2 OR
              aux_cdempres = 3 OR aux_cdempres = 5 OR
              aux_cdempres = 6 OR aux_cdempres = 7 OR
              aux_cdempres = 8 OR aux_cdempres = 15 THEN
            DO:
                ASSIGN aux_flgexist = FALSE.
                FOR EACH crapass 
                    WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrcadast = aux_nrdconta,
                    FIRST crapttl WHERE 
                          crapttl.cdcooper = par_cdcooper      AND
                          crapttl.nrdconta = crapass.nrdconta  AND
                          crapttl.idseqttl = 1                 AND
                          crapttl.cdempres = aux_cdempres  NO-LOCK:
                                         
                    ASSIGN aux_flgexist = TRUE.
                    FOR EACH crabass WHERE
                        crabass.cdcooper  = par_cdcooper AND
                        crabass.nrcadast  = aux_nrdconta AND
                        crabass.nrdconta <> crapass.nrdconta AND
                        crabass.cdsitdct <> 3,
                        FIRST crabttl WHERE
                             crabttl.cdcooper = par_cdcooper     AND
                             crabttl.nrdconta = crabass.nrdconta AND
                             crabttl.idseqttl = 1                AND
                             crabttl.cdempres = aux_cdempres  NO-LOCK:
                           
                        ASSIGN aux_cdcritic = 775. /*+ de 1 cont p/ass*/
                        LEAVE.
                    END.
                    IF   aux_cdcritic <> 775  THEN
                         ASSIGN aux_nrdconta = crapass.nrdconta.
                    LEAVE.     
                END.
                                                                                     
                IF   aux_flgexist = FALSE  THEN
                    ASSIGN  aux_cdcritic  = 9.
            END.
      END.       
   
    ASSIGN aux_flgctsal = FALSE.
   
   /*-------------------------------------------------------*/

   TRANS_1:

   DO TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

      DO WHILE TRUE:
         IF  aux_cdcritic = 0 THEN 
           DO:
               FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                  crapass.nrdconta = aux_nrdconta
                                  USE-INDEX crapass1 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   NOT AVAILABLE crapass   THEN
                 DO:
                     IF   LOCKED crapass  THEN
                       DO:
                           PAUSE 2 NO-MESSAGE.
                           NEXT.
                       END.
                     ELSE
                       DO:
                           FIND crapccs WHERE 
                                crapccs.cdcooper = par_cdcooper AND
                                crapccs.nrdconta = aux_nrdconta
                           USE-INDEX crapccs1 NO-LOCK NO-ERROR.
                                      
                           IF   AVAILABLE crapccs THEN
                             DO:
                                 RUN p_trata_crapccs
                                     (INPUT par_cdcooper, 
                                      INPUT par_cdprogra,
                                      INPUT par_cdoperad, 
                                      INPUT-OUTPUT aux_flfirst2,
                                      INPUT-OUTPUT aux_nrlotccs,
                                      INPUT-OUTPUT par_dtintegr,
                                      INPUT-OUTPUT par_dtmvtolt,
                                      INPUT-OUTPUT aux_nrdconta,
                                      INPUT-OUTPUT aux_cdempres,
                                      INPUT-OUTPUT aux_cdhistor,
                                      INPUT-OUTPUT aux_vllanmto,
                                      INPUT-OUTPUT aux_nrseqint,
                                      INPUT-OUTPUT TABLE tt-critic).
                                 ASSIGN aux_flgctsal = TRUE.
                                 LEAVE.
                             END.
                           ELSE
                             DO:
                                 RUN digfun (INPUT-OUTPUT aux_nrdconta,
                                             INPUT-OUTPUT aux_stsnrcal).
                                 IF   NOT aux_stsnrcal THEN
                                     aux_cdcritic = 8.
                                 ELSE
                                     aux_cdcritic = 9.
                             END.         
                       END.
                 END.
               ELSE
               DO:
                   RUN trata_cdempres (INPUT  par_cdcooper,
                                       INPUT  crapass.inpessoa,
                                       INPUT  crapass.nrdconta,
                                       OUTPUT aux_cdempres_2).
                   IF   aux_cdempres_2 <> par_cdempsol   THEN
                     DO:
                         IF CAN-DO("00080,00081,00099",
                           STRING(aux_cdempres_2,"99999")) AND
                           (par_cdempsol = 31 or par_cdempsol = 90) THEN
                             aux_cdcritic = 0.
                         ELSE    
                             aux_cdcritic = 174.
                     END.
                   ELSE
                     DO:
                         IF crapass.dtelimin <> ? THEN
                             aux_cdcritic = 410.
                         ELSE
                         IF CAN-DO("5,6,7,8",STRING(crapass.cdsitdtl)) THEN
                              aux_cdcritic = 695.
                         ELSE
                         IF CAN-DO("2,4,6,8",STRING(crapass.cdsitdtl)) THEN
                           DO:
                               FIND FIRST craptrf WHERE
                                   craptrf.cdcooper = par_cdcooper     AND
                                   craptrf.nrdconta = crapass.nrdconta AND
                                   craptrf.tptransa = 1                AND
                                   craptrf.insittrs = 2
                                   USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                               IF   AVAILABLE craptrf THEN
                                   aux_nrdconta = craptrf.nrsconta.
                               ELSE
                                   aux_cdcritic = 95.
                           END.
                     END.
               END.                              
           END.
         LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */

      IF   aux_flgctsal THEN
           NEXT.
      IF   aux_flglotes   THEN
        DO:
            /*  Leitura dos lotes  */
            RUN cria_lote (INPUT        par_cdcooper,
                           INPUT        par_cdprogra,
                           INPUT        par_dtintegr,
                           INPUT-OUTPUT par_cdempsol,
                           INPUT-OUTPUT par_nrlotfol,
                           INPUT-OUTPUT par_flgclote,                                                      INPUT-OUTPUT aux_nrlotcot,                                                       INPUT-OUTPUT aux_nrlotemp,
                           INPUT-OUTPUT TABLE tt-critic).          
            IF RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
           
            aux_flglotes = FALSE.
        END.
      DO WHILE TRUE:
         FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                            craplot.dtmvtolt = par_dtintegr   AND
                            craplot.cdagenci = aux_cdagenci   AND
                            craplot.cdbccxlt = aux_cdbccxlt   AND
                            craplot.nrdolote = par_nrlotfol
                            USE-INDEX craplot1 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   NOT AVAILABLE craplot   THEN
           DO:
               IF   LOCKED craplot   THEN
                 DO:
                     NEXT.
                 END.
               ELSE
                 DO:
                     RUN critica (INPUT 60,
                                  OUTPUT aux_dscritic).
                     CREATE tt-critic.                                          
                     ASSIGN tt-critic.cdcritic = 60.
                            tt-critic.dscritic = 
                                       STRING(TIME,"HH:MM:SS") + " - " +
                                      par_cdprogra + "' --> '" + aux_dscritic + 
                                       " EMPRESA = " +
                                       STRING(par_cdempsol,"99999") + 
                                       " LOTE = " +
                                       STRING(par_nrlotfol,"9,999").
                     UNDO TRANS_1, RETURN "NOK".
                END.
           END. 
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */
      

      ASSIGN aux_nrdoclot = SUBSTRING(STRING(par_nrlotfol,"999999"),2,5)
             aux_nrdocmto = INTEGER(aux_nrdoclot + STRING(aux_nrseqint,
                                                              "99999")).

      IF aux_cdcritic = 0 AND aux_cdempres = 4 THEN
        DO:
            IF CAN-FIND(craplcm WHERE craplcm.cdcooper = par_cdcooper     AND
                                      craplcm.nrdconta = aux_nrdconta     AND
                                      craplcm.dtmvtolt = craplot.dtmvtolt AND
                                      craplcm.cdhistor = aux_cdhistor     AND
                                      craplcm.nrdocmto = aux_nrdocmto
                                      USE-INDEX craplcm2)                 THEN
              DO:
                  aux_cdcritic = 285.
                  RUN critica (INPUT 285,
                               OUTPUT aux_dscritic).
                  CREATE tt-critic.
                  ASSIGN tt-critic.cdcritic = 60.
                         tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                      par_cdprogra + "' --> '" + aux_dscritic + 
                                      " EMP = " + STRING(aux_cdempres) +
                                      " SEQ = " + STRING(aux_nrseqint) +
                                      " CONTA = " + STRING(aux_nrdconta).
              END.
        END.
      
      IF aux_cdcritic > 0   THEN 
        DO:
            CREATE craprej.
            ASSIGN craprej.dtmvtolt = craplot.dtmvtolt
                   craprej.cdagenci = craplot.cdagenci
                   craprej.cdbccxlt = craplot.cdbccxlt
                   craprej.nrdolote = craplot.nrdolote
                   craprej.tplotmov = craplot.tplotmov
                   craprej.nrdconta = aux_nrdconta
                   craprej.cdempres = par_cdempsol
                   craprej.cdhistor = aux_cdhistor
                   craprej.vllanmto = aux_vllanmto
                   craprej.cdcritic = aux_cdcritic
                   craprej.tpintegr = 1
                   craprej.cdcooper = par_cdcooper
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                   aux_cdcritic     = 0.
            VALIDATE craprej.
        END.
      ELSE
        DO: /*  Credito do liquido de pagamento  */
            IF   aux_vllanmto > 0 THEN
              DO:
                  CREATE craplcm.
                  ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                     craplcm.cdagenci = craplot.cdagenci
                     craplcm.cdbccxlt = craplot.cdbccxlt
                     craplcm.nrdolote = craplot.nrdolote
                     craplcm.nrdconta = aux_nrdconta
                     craplcm.nrdctabb = aux_nrdconta
                     craplcm.nrdctitg = STRING(aux_nrdconta,
                                              "99999999")
                     craplcm.nrdocmto = aux_nrdocmto
                     craplcm.cdhistor = aux_cdhistor
                     craplcm.vllanmto = aux_vllanmto
                     craplcm.nrseqdig = craplot.nrseqdig + 1
                     craplcm.cdcooper = par_cdcooper
                     craplot.qtinfoln = craplot.qtinfoln + 1
                     craplot.qtcompln = craplot.qtcompln + 1
                     craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                     craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                     craplot.nrseqdig = craplcm.nrseqdig.
                  VALIDATE craplcm.

              END.

            IF par_dtrefere = par_dtultdma OR /* Somente criar crapfol*/
               par_dtrefere = par_dtultdia THEN /* se for folha mensal*/
              DO:
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                      FIND crapfol WHERE crapfol.cdcooper = par_cdcooper AND
                                         crapfol.cdempres = aux_cdempres AND
                                         crapfol.nrdconta = aux_nrdconta AND
                                         crapfol.dtrefere = par_dtrefere 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                  
                      IF   NOT AVAILABLE crapfol   THEN
                        DO:
                            IF   LOCKED(crapfol)   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                            ELSE 
                              DO:
                                  CREATE crapfol.
                                  ASSIGN crapfol.cdcooper = par_cdcooper
                                         crapfol.cdempres = aux_cdempres
                                         crapfol.nrdconta = aux_nrdconta
                                         crapfol.dtrefere = par_dtrefere
                                         crapfol.vllanmto = aux_vllanmto.
                                  VALIDATE crapfol.
                                  LEAVE.
                              END.
                        END.
                      ELSE
                          ASSIGN crapfol.vllanmto = aux_vllanmto.
                       
                      LEAVE.
                  END. /* DO WHILE TRUE...... */
              END.
            ASSIGN tot_vlsalliq = aux_vllanmto
                   aux_flgdente = TRUE
                   tot_vldebcta = 0.
          
            /*  Atualiza o fator salarial  */

            IF aux_flgatual THEN
                ASSIGN crapass.dtedvmto = par_dtrefere
                       crapass.vledvmto =
                IF NOT aux_flgsomar THEN 
                    ROUND((aux_vllanmto * 1.15) * 0.30,2)
                ELSE crapass.vledvmto +
                    ROUND((aux_vllanmto * 1.15) * 0.30,2).

            IF   aux_cdhistor = 8   THEN
              DO:
                 /*  Leitura dos avisos de debitos  */
                  FOR EACH crapavs WHERE
                      crapavs.cdcooper = par_cdcooper   AND
                      crapavs.nrdconta = aux_nrdconta   AND
                      crapavs.tpdaviso = 1              AND
                      crapavs.dtrefere = par_dtrefere   AND
                      crapavs.insitavs = 0
                      BY IF CAN-DO(aux_lshstsau, 
                                STRING(crapavs.cdhistor)) THEN "1"              
                      ELSE
                      IF CAN-DO(aux_lshstfun,         /*  Convenio 18 e 19  */
                               STRING(crapavs.cdhistor))  THEN "2"
                      ELSE
                      IF CAN-DO(aux_lshstdiv,        /*  Convenio 10 e 15  */
                               STRING(crapavs.cdhistor))  THEN "3"
                      ELSE
                      IF crapavs.cdhistor = 108   THEN "4"
                      ELSE
                      IF crapavs.cdhistor = 127   THEN "7"
                      ELSE
                      IF (crapavs.cdhistor = 160   OR
                          crapavs.cdhistor = 175   OR
                          crapavs.cdhistor = 199   OR
                          crapavs.cdhistor = 341)  THEN "8"
                      ELSE "6"
                      BY crapavs.cdhistor
                      BY crapavs.dtintegr:

                      IF crapavs.cdhistor = 108 THEN /*  Emprestimos  */
                        DO:
                            ASSIGN aux_vlsalliq = TRUNCATE(tab_txrdcpmf *
                                                  tot_vlsalliq,2)
                                   aux_vlpgempr = crapavs.vllanmto -
                                                  crapavs.vldebito
                                   aux_vldebtot = 0.
                                                    
                            IF   aux_vlsalliq > 0   THEN
                              DO:
                                  RUN proc_deb_empres
                                      (INPUT par_cdcooper,
                                       INPUT par_cdprogra,
                                       INPUT par_inproces,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT crapavs.nrdconta,
                                       INPUT crapavs.nrdocmto,
                                       INPUT aux_nrlotemp,
                                       INPUT aux_vlpgempr,
                                       INPUT aux_vlsalliq,
                                       INPUT par_dtintegr,
                                       INPUT 95,
                                       OUTPUT crapavs.insitavs,
                                       OUTPUT aux_vldebtot,
                                       OUTPUT crapavs.vlestdif,
                                       OUTPUT crapavs.flgproce,
                                       OUTPUT TABLE tt-critic).

                                  IF aux_cdcritic > 0 THEN
                                      UNDO TRANS_1, RETURN "NOK".                   

                                  ASSIGN crapavs.vldebito = crapavs.vldebito +
                                                            aux_vldebtot
                                         tot_vldebcta[108] = tot_vldebcta[108] +
                                                             aux_vldebtot
                                         tot_vlsalliq = tot_vlsalliq -
                                                     TRUNC((1 + tab_txcpmfcc) *
                                                     aux_vldebtot,2).
                              END.
                        END.
                      ELSE
                          IF crapavs.cdhistor = 127 THEN /* Planos de capital */ 
                            DO:
                                IF tot_vlsalliq >= crapavs.vllanmto  THEN
                                  DO:
                                      RUN proc_deb_plano_capital
                                          (INPUT        par_cdcooper,
                                           INPUT        par_dtmvtolt,
                                           INPUT        par_cdprogra,
                                           INPUT-OUTPUT crapavs.nrdconta,
                                           INPUT-OUTPUT crapavs.nrdocmto,
                                           INPUT-OUTPUT aux_nrlotcot,
                                           INPUT-OUTPUT crapavs.vllanmto,
                                           INPUT-OUTPUT tot_vlsalliq,
                                           INPUT-OUTPUT par_dtintegr,
                                           INPUT-OUTPUT crapass.dtdemiss,
                                           INPUT        75,
                                           INPUT-OUTPUT crapavs.insitavs,
                                           INPUT-OUTPUT crapavs.vldebito,
                                           INPUT-OUTPUT crapavs.vlestdif,
                                           INPUT-OUTPUT aux_vldoipmf,
                                           INPUT-OUTPUT crapavs.flgproce,
                                           OUTPUT TABLE tt-critic).

                                      IF RETURN-VALUE <> "" THEN
                                          UNDO TRANS_1, RETURN "NOK".          

                                      ASSIGN tot_vldebcta[127] = 
                                             tot_vldebcta[127] +
                                             crapavs.vldebito
                                             tot_vlsalliq = tot_vlsalliq -
                                             crapavs.vldebito + aux_vldoipmf.
                                  END.
                            END.
                          ELSE
                              IF  (crapavs.cdhistor = 160 OR /* P. Programada */
                                   crapavs.cdhistor = 175 OR /* Seguro Casa */ 
                                   crapavs.cdhistor = 199 OR /* Seguro Auto */
                                   crapavs.cdhistor = 341) THEN /* Seg. Vida */
                                  ASSIGN crapavs.insitavs = 1
                                         crapavs.vldebito = crapavs.vllanmto
                                         crapavs.vlestdif = 0
                                         crapavs.flgproce = TRUE.
                              ELSE
                                DO: /*  Demais historicos  */                   
                                    aux_vldebita = crapavs.vllanmto - 
                                                   crapavs.vldebito.
                                    IF tot_vlsalliq >= 
                                       TRUNCATE((1 + tab_txcpmfcc) *
                                       aux_vldebita,2) THEN
                                        ASSIGN crapavs.insitavs = 1
                                               crapavs.flgproce = TRUE
                                               crapavs.vldebito = 
                                               crapavs.vllanmto
                                               crapavs.vlestdif = 0
                                               tot_vldebcta[crapavs.cdhistor] =
                                               tot_vldebcta[crapavs.cdhistor] +
                                               aux_vldebita
                                               tot_vlsalliq = tot_vlsalliq -
                                               TRUNCATE((1 + tab_txcpmfcc) *
                                                         aux_vldebita,2).
                                END.

                          IF crapavs.vldebito = 0 AND
                             crapavs.insitavs = 0 THEN
                              crapavs.vlestdif = crapavs.vllanmto * -1.

                  END.  /*  Fim do FOR EACH -- Leitura dos avisos  */
                        
       /*paulo*/  RUN proc_lanct_deposito
                      (INPUT        par_cdcooper, 
                       INPUT        par_cdprogra,
                       INPUT        aux_cdempres,
                       INPUT-OUTPUT par_dtintegr,
                       INPUT-OUTPUT aux_cdagenci,
                       INPUT-OUTPUT aux_cdbccxlt,
                       INPUT-OUTPUT par_nrlotfol,
                       INPUT-OUTPUT aux_nrdconta,
                       input-output table tt-vldebcta,
                       input-output table tt-critic).  
                        /* Efetua os lancamentos */

                  IF  RETURN-VALUE <> ""    THEN
                       UNDO TRANS_1, RETURN "NOK".
              END.
        END.

      /*  Cria registro de restart  */

      DO WHILE TRUE:
          FIND crapres WHERE crapres.cdcooper = par_cdcooper AND
                             crapres.cdprogra = par_cdprogra
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapres   THEN
              IF   LOCKED crapres   THEN
                DO:
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
              ELSE
                DO:
                    RUN critica (INPUT 151,
                                OUTPUT aux_dscritic).
                    CREATE tt-critic.
                    ASSIGN tt-critic.cdcritic = 151.
                           tt-critic.dscritic = 
                                    STRING(TIME,"HH:MM:SS") + " - " +
                                    par_cdprogra + "' --> '" + aux_dscritic.

                    UNDO TRANS_1, RETURN "NOK".
                END.
          LEAVE.
      END.  /*  Fim do DO WHILE TRUE  */

      ASSIGN crapres.nrdconta = aux_nrseqint
             crapres.dsrestar = STRING(rel_qttarifa,"999999") + " " +
                                STRING(par_indmarca,"9").

   END.  /*  Fim da Transacao  */

END.   /*  Fim do DO WHILE TRUE  */

INPUT  STREAM str_2 CLOSE.

IF aux_cdcritic = 0 THEN
  DO:
      RUN resumo_integracao(INPUT par_cdcooper,
                            INPUT par_cdprogra,
                            INPUT par_dsempres,
                            INPUT par_nrlotfol,
                            INPUT par_dtmvtolt,
                            INPUT aux_cdempres,
                            INPUT rel_qttarifa,
                            INPUT par_dtintegr,
                            INPUT aux_nrlotemp,
                            INPUT aux_nrlotcot,
                            INPUT aux_nrlotccs,
                            OUTPUT TABLE tt-integracao,
                            OUTPUT TABLE tt-rejeitados,
                            OUTPUT TABLE tt-totais,
                            INPUT-OUTPUT TABLE tt-critic).

      IF   aux_cdcritic > 0   THEN
        DO:
            RUN critica (INPUT aux_cdcritic,
                         OUTPUT aux_dscritic).
            CREATE tt-critic.
            ASSIGN tt-critic.cdcritic = aux_cdcritic.
                   tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                        par_cdprogra + "' --> '" + aux_dscritic.

            RETURN "NOK".
        END.

      aux_cdcritic = IF rel_qtdifeln = 0 THEN 190 ELSE 191.
    
      IF aux_cdcritic > 0 THEN
        DO:
            RUN critica (INPUT aux_cdcritic,
                     OUTPUT aux_dscritic).
            CREATE tt-critic.
            ASSIGN tt-critic.cdcritic = aux_cdcritic.
                   tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                                        par_cdprogra + "' --> '" + aux_dscritic.
            IF aux_cdcritic <> 190 THEN
                RETURN "NOK".
        
        END.

 /*   ASSIGN glb_nrcopias = 2
           glb_nmformul = "80col"
           glb_nmarqimp = aux_nmarqimp[aux_contaarq].

    RUN fontes/imprim.p.  */

    /*  Exclui rejeitados apos a impressao  */

    TRANS_2:

    FOR EACH craprej WHERE craprej.cdcooper = par_cdcooper AND
                           craprej.dtmvtolt = par_dtmvtolt AND
                           craprej.cdagenci = aux_cdagenci AND
                           craprej.cdbccxlt = aux_cdbccxlt AND
                           craprej.nrdolote = par_nrlotfol AND
                           craprej.cdempres = par_cdempsol AND
                           craprej.tpintegr = 1 EXCLUSIVE-LOCK
                           TRANSACTION ON ERROR UNDO TRANS_2, RETURN:

        DELETE craprej. 

    END.   /*  Fim do FOR EACH e da transacao  */

    TRANS_3:

    DO TRANSACTION ON ERROR UNDO TRANS_3, RETURN:

        DO WHILE TRUE:

            FIND crapres WHERE crapres.cdcooper = par_cdcooper AND
                               crapres.cdprogra = par_cdprogra
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAILABLE crapres   THEN
                IF   LOCKED crapres   THEN
                  DO:
                      NEXT.
                  END.
                ELSE
                  DO:
                      RUN critica (INPUT aux_cdcritic,
                                  OUTPUT aux_dscritic).
                      CREATE tt-critic.
                      ASSIGN tt-critic.cdcritic = aux_cdcritic.                 
                             tt-critic.dscritic = 
                              STRING(TIME,"HH:MM:SS") + " - " +
                              par_cdprogra + "' --> '" + aux_dscritic.
                    UNDO TRANS_3, RETURN "NOK".
                  END.
            LEAVE.
        END.  /*  Fim do DO WHILE TRUE  */

        ASSIGN crapres.nrdconta = 0
               crapres.dsrestar = ""
               aux_cdcritic     = 0.

    END.  /*  Fim da transacao  */

END.  /*  Fim da impressao do relatorio  */

END PROCEDURE.
/* .......................................................................... */

PROCEDURE resumo_integracao:

/* ..........................................................................

       Programa: crps120_r.p
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Paulo - Precise
       Data    : Agosto/2009.                          

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado pelo crps120.
       Objetivo  : Processar os resumos da integracao.
............................................................................. */

DEFINE INPUT        PARAM par_cdcooper AS INTEGER              NO-UNDO.
DEFINE INPUT        PARAM par_cdprogra AS CHAR                 NO-UNDO.
DEFINE INPUT        PARAM par_dsempres AS CHAR                 NO-UNDO.
DEFINE INPUT        PARAM par_nrlotfol AS INTEGER              NO-UNDO.
DEFINE INPUT        PARAM par_dtmvtolt AS DATE                 NO-UNDO.
DEFINE INPUT        PARAM par_cdempres AS INTEGER              NO-UNDO.
DEFINE INPUT        PARAM par_qttarifa AS INTEGER              NO-UNDO.
DEFINE INPUT        PARAM par_dtintegr AS DATE                 NO-UNDO.
DEFINE INPUT        PARAM par_nrlotemp AS INT                  NO-UNDO.
DEFINE INPUT        PARAM par_nrlotcot AS INT                  NO-UNDO.
DEFINE INPUT        PARAM par_nrlotccs AS INT                  NO-UNDO.
DEFINE OUTPUT       PARAM TABLE FOR tt-integracao.
DEFINE OUTPUT       PARAM TABLE FOR tt-rejeitados.
DEFINE OUTPUT       PARAM TABLE FOR tt-totais.
DEFINE INPUT-OUTPUT       PARAM TABLE FOR tt-critic.


DEFINE VAR aux_dscritic AS CHAR    NO-UNDO.
DEFINE VAR aux_cdcritic AS INTEGER NO-UNDO.
DEFINE VAR rel_dsintegr AS CHAR    NO-UNDO.
DEFINE VAR rel_nmempres AS CHAR    NO-UNDO.
DEFINE VAR rel_qtdifeln AS INTEGER NO-UNDO.
DEFINE VAR rel_vldifedb AS DECIMAL NO-UNDO.
DEFINE VAR rel_vldifecr AS DECIMAL NO-UNDO.
DEFINE VAR rel_vltarifa AS DECIMAL NO-UNDO.
DEFINE VAR rel_vlcobrar AS DECIMAL NO-UNDO.

  /* variavel nao inicializada IF   aux_lshstden <> ""   THEN
  rel_dsintegr = "CREDITO DE PAGAMENTO, DEBITO DE EMPRESTIMOS, CAPITAL E " +
                       "CONVENIOS".
  ELSE */

ASSIGN rel_dsintegr = "CREDITO DE PAGAMENTO, DEBITO DE EMPRESTIMOS E CAPITAL".

ASSIGN rel_nmempres = par_dsempres.

IF  par_nrlotfol = 0 THEN
  DO:
      CREATE tt-integracao.
      ASSIGN tt-integracao.nrtiporl = 1
             tt-integracao.dsintegr = rel_dsintegr
             tt-integracao.dsempres = par_dsempres
             tt-integracao.dtmvtolt = ?
             tt-integracao.cdagenci = 0 
             tt-integracao.cdbccxlt = 0
             tt-integracao.nrdolote = 0
             tt-integracao.tplotmov = 0.

       ASSIGN rel_qtdifeln = 0
              rel_vldifedb = 0
              rel_vldifecr = 0.
  END.
ELSE
  DO:
      /*  Resumo da integracao da folha  */
      FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                         craplot.dtmvtolt = par_dtmvtolt AND
                         craplot.cdagenci = aux_cdagenci AND
                         craplot.cdbccxlt = aux_cdbccxlt AND
                         craplot.nrdolote = par_nrlotfol
                         USE-INDEX craplot1 NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craplot   THEN
        DO:
            RUN critica (INPUT 60,
                         OUTPUT aux_dscritic).
            CREATE tt-critic.
            ASSIGN tt-critic.cdcritic = 60.
                   tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                   par_cdprogra + "' --> '" + aux_dscritic +
                   " EMPRESA = " + par_dsempres +
                   " LOTE = " + STRING(par_nrlotfol,"9,999").
            RETURN "NOK".
        END.

      ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.

      CREATE tt-integracao.
      ASSIGN tt-integracao.nrtiporl = 1
             tt-integracao.dsintegr = rel_dsintegr
             tt-integracao.dsempres = par_dsempres
             tt-integracao.dtmvtolt = craplot.dtmvtolt
             tt-integracao.cdagenci = craplot.cdagenci 
             tt-integracao.cdbccxlt = craplot.cdbccxlt
             tt-integracao.nrdolote = craplot.nrdolote
             tt-integracao.tplotmov = craplot.tplotmov.
  END.

FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                   craptab.nmsistem = "CRED"       AND
                   craptab.tptabela = "USUARI"     AND
                   craptab.cdempres = par_cdempres AND
                   craptab.cdacesso = "VLTARIF008" AND
                   craptab.tpregist = 1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
    rel_vltarifa = 0.
ELSE
    rel_vltarifa = DECIMAL(craptab.dstextab).

rel_vlcobrar = par_qttarifa * rel_vltarifa.

FOR EACH craprej WHERE craprej.cdcooper = par_cdcooper   AND
                       craprej.dtmvtolt = par_dtmvtolt   AND
                       craprej.cdagenci = aux_cdagenci   AND
                       craprej.cdbccxlt = aux_cdbccxlt   AND
                       craprej.nrdolote = par_nrlotfol   AND
                       craprej.cdempres = par_cdempres   AND
                       craprej.tpintegr = 1              NO-LOCK
                       BREAK BY craprej.dtmvtolt  BY craprej.cdagenci
                             BY craprej.cdbccxlt  BY craprej.nrdolote
                             BY craprej.cdempres  BY craprej.tpintegr
                             BY craprej.nrdconta:
    IF aux_cdcritic <> craprej.cdcritic   THEN
      DO:
          aux_cdcritic = craprej.cdcritic.
          RUN critica (INPUT aux_cdcritic,
                       OUTPUT aux_dscritic).
          IF aux_cdcritic = 211   THEN                                            
              aux_dscritic = aux_dscritic + " URV do dia " + 
                             STRING(par_dtintegr,"99/99/9999").
          CREATE tt-critic.
          ASSIGN tt-critic.cdcritic = aux_cdcritic.
                 tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                 par_cdprogra + "' --> '" + aux_dscritic.
      END.

    CREATE tt-rejeitados.
    ASSIGN tt-rejeitados.nrtiporl = 1
           tt-rejeitados.nrdconta = craprej.nrdconta
           tt-rejeitados.cdhistor = craprej.cdhistor
           tt-rejeitados.vllanmto = craprej.vllanmto
           tt-rejeitados.dscritic = aux_dscritic.

END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

IF   par_nrlotfol > 0 THEN
  DO:
      CREATE tt-totais.
      ASSIGN tt-totais.nrtiporl = 1
             tt-totais.qtinfoln = craplot.qtinfoln  
             tt-totais.vlinfodb = craplot.vlinfodb
             tt-totais.vlinfocr = craplot.vlinfocr  
             tt-totais.qtcompln = craplot.qtcompln
             tt-totais.vlcompdb = craplot.vlcompdb  
             tt-totais.vlcompcr = craplot.vlcompcr
             tt-totais.qtdifeln = rel_qtdifeln
             tt-totais.vldifedb = rel_vldifedb
             tt-totais.vldifecr = rel_vldifecr
             tt-totais.qttarifa = par_qttarifa
             tt-totais.vltarifa = rel_vltarifa
             tt-totais.vlcobrar = rel_vlcobrar.
  END.
ELSE
  DO:
      CREATE tt-totais.
      ASSIGN tt-totais.nrtiporl = 1
             tt-totais.qtinfoln = 0 
             tt-totais.vlinfodb = 0
             tt-totais.vlinfocr = 0 
             tt-totais.qtcompln = 0
             tt-totais.vlcompdb = 0  
             tt-totais.vlcompcr = 0
             tt-totais.qtdifeln = rel_qtdifeln
             tt-totais.vldifedb = rel_vldifedb
             tt-totais.vldifecr = rel_vldifecr
             tt-totais.qttarifa = par_qttarifa
             tt-totais.vltarifa = rel_vltarifa
             tt-totais.vlcobrar = rel_vlcobrar.
  END.

aux_cdcritic = 0.

/*  Resumo da integra dos emprestimos  */
FIND craplot 
     WHERE craplot.cdcooper = par_cdcooper   AND
           craplot.dtmvtolt = par_dtmvtolt   AND
           craplot.cdagenci = aux_cdagenci   AND
           craplot.cdbccxlt = aux_cdbccxlt   AND
           craplot.nrdolote = par_nrlotemp
           USE-INDEX craplot1 NO-LOCK NO-ERROR.

IF   AVAILABLE craplot   THEN
  DO:
      ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
             rel_dsintegr = "CREDITO DE EMPRESTIMOS".

      CREATE tt-integracao.
      ASSIGN tt-integracao.dsintegr = rel_dsintegr
             tt-integracao.dsempres = par_dsempres
             tt-integracao.dtmvtolt = craplot.dtmvtolt
             tt-integracao.cdagenci = craplot.cdagenci 
             tt-integracao.cdbccxlt = craplot.cdbccxlt
             tt-integracao.nrdolote = craplot.nrdolote
             tt-integracao.tplotmov = craplot.tplotmov.
             tt-integracao.nrtiporl = 2.

      CREATE tt-totais.
      ASSIGN tt-totais.nrtiporl = 2
             tt-totais.qtinfoln = craplot.qtinfoln  
             tt-totais.vlinfodb = craplot.vlinfodb
             tt-totais.vlinfocr = craplot.vlinfocr  
             tt-totais.qtcompln = craplot.qtcompln
             tt-totais.vlcompdb = craplot.vlcompdb  
             tt-totais.vlcompcr = craplot.vlcompcr
             tt-totais.qtdifeln = rel_qtdifeln
             tt-totais.vldifedb = rel_vldifedb
             tt-totais.vldifecr = rel_vldifecr
             tt-totais.qttarifa = 0
             tt-totais.vltarifa = 0
             tt-totais.vlcobrar = 0.

  END.

/*  Resumo da integra dos planos de capital  */

FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                   craplot.dtmvtolt = par_dtmvtolt   AND
                   craplot.cdagenci = aux_cdagenci   AND
                   craplot.cdbccxlt = aux_cdbccxlt   AND
                   craplot.nrdolote = par_nrlotcot
                   USE-INDEX craplot1 NO-LOCK NO-ERROR.
IF   AVAILABLE craplot   THEN
  DO:
      ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
             rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
             rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
             rel_dsintegr = "CREDITO DE CAPITAL".
      CREATE tt-integracao.
      ASSIGN tt-integracao.dsintegr = rel_dsintegr
             tt-integracao.dsempres = par_dsempres
             tt-integracao.dtmvtolt = craplot.dtmvtolt
             tt-integracao.cdagenci = craplot.cdagenci 
             tt-integracao.cdbccxlt = craplot.cdbccxlt
             tt-integracao.nrdolote = craplot.nrdolote
             tt-integracao.tplotmov = craplot.tplotmov.
             tt-integracao.nrtiporl = 3.

      CREATE tt-totais.
      ASSIGN tt-totais.nrtiporl = 3
             tt-totais.qtinfoln = craplot.qtinfoln  
             tt-totais.vlinfodb = craplot.vlinfodb
             tt-totais.vlinfocr = craplot.vlinfocr  
             tt-totais.qtcompln = craplot.qtcompln
             tt-totais.vlcompdb = craplot.vlcompdb  
             tt-totais.vlcompcr = craplot.vlcompcr
             tt-totais.qtdifeln = rel_qtdifeln
             tt-totais.vldifedb = rel_vldifedb
             tt-totais.vldifecr = rel_vldifecr
             tt-totais.qttarifa = 0
             tt-totais.vltarifa = 0
             tt-totais.vlcobrar = 0.
  END.


/*  Imprime Conta Salario  */

rel_dsintegr = "CREDITO DE CONTA SALARIO".

FIND craplot WHERE craplot.cdcooper = par_cdcooper  AND
                   craplot.dtmvtolt = par_dtintegr  AND
                   craplot.cdagenci = 1             AND
                   craplot.cdbccxlt = 100           AND
                   craplot.nrdolote = par_nrlotccs
                   USE-INDEX craplot1 NO-LOCK NO-ERROR.

IF   AVAILABLE craplot   THEN
    ASSIGN rel_qtdifeln = craplot.qtcompln - craplot.qtinfoln
           rel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
           rel_vldifecr = craplot.vlcompcr - craplot.vlinfocr.
ELSE
    NEXT.

CREATE tt-integracao.
ASSIGN tt-integracao.dsintegr = rel_dsintegr
       tt-integracao.dsempres = par_dsempres
       tt-integracao.dtmvtolt = craplot.dtmvtolt
       tt-integracao.cdagenci = craplot.cdagenci 
       tt-integracao.cdbccxlt = craplot.cdbccxlt
       tt-integracao.nrdolote = craplot.nrdolote
       tt-integracao.tplotmov = craplot.tplotmov.
       tt-integracao.nrtiporl = 4.

FOR EACH craprej 
    WHERE craprej.cdcooper = par_cdcooper  AND
          craprej.dtmvtolt = par_dtmvtolt  AND
          craprej.cdagenci = 1             AND
          craprej.cdbccxlt = 100           AND
          craprej.nrdolote = par_nrlotccs  AND
          craprej.cdempres = par_cdempres  AND
          craprej.tpintegr = 1             NO-LOCK
          BREAK BY craprej.dtmvtolt  
                BY craprej.cdagenci
                BY craprej.cdbccxlt  
                BY craprej.nrdolote
                BY craprej.cdempres  
                BY craprej.tpintegr
                BY craprej.nrdconta:

    IF   aux_cdcritic <> craprej.cdcritic   THEN
      DO:
          aux_cdcritic = craprej.cdcritic.
          RUN critica (INPUT aux_cdcritic,
                       OUTPUT aux_dscritic).
          CREATE tt-critic.
          ASSIGN tt-critic.cdcritic = aux_cdcritic.
                 tt-critic.dscritic = STRING(TIME,"HH:MM:SS") + " - " +
                 par_cdprogra + "' --> '" + aux_dscritic.
      END.

    CREATE tt-rejeitados.
    ASSIGN tt-rejeitados.nrtiporl = 4
           tt-rejeitados.nrdconta = craprej.nrdconta
           tt-rejeitados.cdhistor = craprej.cdhistor
           tt-rejeitados.vllanmto = craprej.vllanmto
           tt-rejeitados.dscritic = aux_dscritic.

END.   /*  Fim do FOR EACH  --  Leitura dos rejeitados  */

CREATE tt-totais.
ASSIGN tt-totais.nrtiporl = 4
       tt-totais.qtinfoln = craplot.qtinfoln  
       tt-totais.vlinfodb = craplot.vlinfodb
       tt-totais.vlinfocr = craplot.vlinfocr  
       tt-totais.qtcompln = craplot.qtcompln
       tt-totais.vlcompdb = craplot.vlcompdb  
       tt-totais.vlcompcr = craplot.vlcompcr
       tt-totais.qtdifeln = rel_qtdifeln
       tt-totais.vldifedb = rel_vldifedb
       tt-totais.vldifecr = rel_vldifecr
       tt-totais.qttarifa = 0
       tt-totais.vltarifa = 0
       tt-totais.vlcobrar = 0.

END PROCEDURE.
/* .......................................................................... */

PROCEDURE gera_rel_estouros.
/* ..........................................................................

   Programa: fontes/crps120_e.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Paulo - Precise
   Data    : Maio/95.                            

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Gerar relatorio de estouros (99 e 114)

............................................................................. */
DEF INPUT PARAM par_cdempres AS INT                                  NO-UNDO.
DEF INPUT PARAM par_cdcooper AS INT                                  NO-UNDO.
DEF INPUT PARAM par_dtrefere AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdprogra AS CHAR                                 NO-UNDO.
DEF INPUT PARAM par_dsempres AS CHAR                                 NO-UNDO.
DEF OUTPUT PARAM par_vlavsemp AS DECIMAL                             NO-UNDO. 
/* ger_vlavsemp */
DEF OUTPUT PARAM par_vldebemp AS DECIMAL                             NO-UNDO. 
/* ger_vldebemp */
DEF OUTPUT PARAM par_vlantemp AS DECIMAL                             NO-UNDO. 
/* ger_vlantemp */
DEF OUTPUT PARAM par_vlavscot AS DECIMAL                             NO-UNDO. 
/* ger_vlavscot */       
DEF OUTPUT PARAM par_vldebcot AS DECIMAL                             NO-UNDO. 
/* ger_vldebcot */
DEF OUTPUT PARAM par_vlantcot AS DECIMAL                             NO-UNDO. 
/* ger_vlantcot */
DEF OUTPUT PARAM par_qtestcot AS INTEGER                             NO-UNDO. 
/* ger_qtestcot */
DEF OUTPUT PARAM par_vlestcot AS DECIMAL                             NO-UNDO. 
/* ger_vlestcot */
DEF OUTPUT PARAM par_qtestemp AS INTEGER                             NO-UNDO. 
/* ger_qtestemp */
DEF OUTPUT PARAM par_vlestemp AS DECIMAL                             NO-UNDO. 
/* ger_vlestemp */
DEFINE OUTPUT PARAM TABLE FOR tt-critic.
DEFINE OUTPUT PARAM TABLE FOR tt-estconv.
DEFINE OUTPUT PARAM TABLE FOR tt-estouro.
DEFINE OUTPUT PARAM TABLE FOR tt-totais-est.
DEFINE OUTPUT PARAM TABLE FOR tt-totais-den.
DEFINE OUTPUT PARAM TABLE FOR tt-aviso.
DEFINE OUTPUT PARAM TABLE FOR tt-agencia.        


DEF VAR aux_flgexist AS LOGICAL                                      NO-UNDO.
DEF VAR est_flgsomar AS LOGICAL                                      NO-UNDO.


DEF VAR aux_dshstden AS CHAR                   EXTENT 999  NO-UNDO.

DEF VAR aux_nroseque AS INT                                          NO-UNDO.
DEF VAR con_flgfirst AS LOGICAL                                      NO-UNDO.
DEF VAR aux_cdempres AS INT                                          NO-UNDO.
DEF VAR avs_vlestdif AS DEC                                          NO-UNDO.
DEF VAR ass_vlestemp AS DEC                                          NO-UNDO.
DEF VAR ass_vlestdif AS DEC                                          NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_lshstden AS CHAR                                         NO-UNDO.
DEF VAR aux_cdagenci AS INT                                          NO-UNDO.
DEF VAR aux_contaavi AS INT                                          NO-UNDO.
DEF VAR rel_dsconven AS CHAR                                         NO-UNDO.
DEF VAR rel_dshistor AS CHAR                                         NO-UNDO.
DEF VAR rel_dscritic AS CHAR                                         NO-UNDO.
DEF VAR rel_vlestdif AS DECIMAL                                      NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_cdturnos AS INT                                          NO-UNDO.
DEF VAR rel_dsagenci AS CHAR EXTENT 1000                             NO-UNDO.

ASSIGN par_qtestcot = 0   par_vlestcot = 0   par_qtestemp = 0
       par_vlestemp = 0   par_vlavscot = 0   par_vlavsemp = 0 
       par_vldebcot = 0   par_vldebemp = 0   par_vlantcot = 0 
       par_vlantemp = 0   ass_vlestemp = 0   rel_dsconven = ""
       rel_dshistor = "".

FOR EACH crapage WHERE crapage.cdcooper = par_cdcooper NO-LOCK:

    rel_dsagenci[crapage.cdagenci] = STRING(crapage.cdagenci,"999") + " - " +
                                     crapage.nmresage.

END.  /*  Fim do FOR EACH -- Leitura do cadastro de agencias  */

FOR EACH crapass 
         WHERE crapass.cdcooper = par_cdcooper         AND
               crapass.dtelimin = ?                    NO-LOCK
               BREAK BY crapass.cdagenci
                     BY crapass.nrdconta: 

    ASSIGN aux_cdempres = 0.
    
    IF   crapass.inpessoa = 1   THEN
      DO:
          FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                             crapttl.nrdconta = crapass.nrdconta   AND
                             crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
        
          IF   AVAIL crapttl  THEN
              ASSIGN aux_cdempres = crapttl.cdempres.
      END.
    ELSE
      DO:
          FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                             crapjur.nrdconta = crapass.nrdconta
                             NO-LOCK NO-ERROR.
        
          IF AVAIL crapjur  THEN
              ASSIGN aux_cdempres = crapjur.cdempres.
      END.

    IF aux_cdempres <> par_cdempres THEN
        NEXT.

    ASSIGN est_flgsomar = TRUE.

    FOR EACH crapavs WHERE crapavs.cdcooper = par_cdcooper      AND
                           crapavs.nrdconta = crapass.nrdconta  AND
                           crapavs.tpdaviso = 1                 AND
                           crapavs.dtrefere = par_dtrefere      AND
                         ((crapavs.cdhistor = 108               OR
                           crapavs.cdhistor = 127)              OR
                           crapavs.nrconven > 0) USE-INDEX crapavs2 NO-LOCK:

        IF   crapavs.nrconven > 0   THEN
          DO:
              FIND tt-estconv WHERE nroseque = crapavs.nrconven NO-ERROR.
              IF NOT AVAILABLE tt-estconv THEN
                DO:
                    CREATE tt-estconv.
                    ASSIGN tt-estconv.nroseque = crapavs.nrconven.
                END.                                                            
              ASSIGN 
              tt-estconv.vlavscnv = tt-estconv.vlavscnv + crapavs.vllanmto 
              tt-estconv.qtavscnv = tt-estconv.qtavscnv + 1.

              IF   crapavs.vldebito > 0   THEN
                  ASSIGN tt-estconv.vldebcnv = tt-estconv.vldebcnv + 
                                               crapavs.vldebito
                         tt-estconv.qtdebcnv = tt-estconv.qtdebcnv + 1.
              ELSE                                   /*  Estouro integral  */
                  ASSIGN tt-estconv.vlestcnv = tt-estconv.vlestcnv + 
                                             crapavs.vllanmto
                         tt-estconv.qtestcnv = tt-estconv.qtestcnv + 1.
              NEXT.
          END.

        /*  Tratamento dos historicos 108 e 127  */

        IF crapavs.vldebito = 0   AND   crapavs.vlestdif = 0   THEN
             avs_vlestdif = crapavs.vllanmto * -1.
        ELSE
             avs_vlestdif = crapavs.vlestdif.

        /*  Acumula total geral dos aviso  */

        IF crapavs.cdhistor = 108 THEN
          DO:
              ASSIGN par_vlavsemp = par_vlavsemp + crapavs.vllanmto
                     par_vldebemp = par_vldebemp + crapavs.vldebito.

              IF avs_vlestdif > 0   THEN
                  par_vlantemp = par_vlantemp + avs_vlestdif.
              ELSE
              IF avs_vlestdif < 0   THEN
                  par_vlantemp = par_vlantemp + (crapavs.vllanmto +
                                 avs_vlestdif - crapavs.vldebito).
          END.
        ELSE
        IF crapavs.cdhistor = 127 THEN
          DO:
              ASSIGN par_vlavscot = par_vlavscot + crapavs.vllanmto
                     par_vldebcot = par_vldebcot + crapavs.vldebito.

              IF avs_vlestdif > 0 THEN
                  par_vlantcot = par_vlantcot + avs_vlestdif.
              ELSE
              IF avs_vlestdif < 0   THEN
                  par_vlantcot = par_vlantcot + (crapavs.vllanmto +
                                 avs_vlestdif - crapavs.vldebito).
          END.

        IF crapavs.vldebito = crapavs.vllanmto THEN
            NEXT.

        IF avs_vlestdif > 0   THEN
            ASSIGN rel_vlestdif = avs_vlestdif
                   rel_dscritic = "DEBITO MENOR".
        ELSE
        IF avs_vlestdif < 0   THEN
          DO:
              ASSIGN rel_vlestdif = avs_vlestdif * -1
                     rel_dscritic = "ESTOURO".
              IF crapavs.cdhistor = 108 THEN
                DO:
                    FIND FIRST tt-estouro 
                         WHERE tt-estouro.nroseque = crapass.cdagenci NO-ERROR.
                    IF NOT AVAILABLE tt-estouro THEN
                      DO:

                          CREATE tt-estouro.
                          ASSIGN tt-estouro.nroseque = crapass.cdagenci         
                                 tt-estouro.dsagenci = 
                                 rel_dsagenci[crapass.cdagenci].
                      END.
                    ASSIGN tt-estouro.qtestemp = tt-estouro.qtestemp +
                           IF est_flgsomar THEN 1 ELSE 0

                           tt-estouro.vlestemp = tt-estouro.vlestemp + 
                                                 rel_vlestdif

                           ass_vlestemp = rel_vlestdif
                           ass_vlestdif = ass_vlestdif + rel_vlestdif
                           est_flgsomar = FALSE.
                END.
              ELSE
              IF crapavs.cdhistor = 127 THEN
                DO:
                    FIND FIRST tt-estouro 
                         WHERE tt-estouro.nroseque = 
                               crapass.cdagenci NO-ERROR.
                    IF NOT AVAILABLE tt-estouro THEN
                      DO:
                          CREATE tt-estouro.
                          ASSIGN tt-estouro.nroseque = crapass.cdagenci         
                                 tt-estouro.dsagenci = 
                                 rel_dsagenci[crapass.cdagenci].
                      END.
                    ASSIGN tt-estouro.qtestcot = tt-estouro.qtestcot + 1
                           tt-estouro.vlestcot = tt-estouro.vlestcot +
                                                 rel_vlestdif.
                END.
          END.
    END.  /*  Fim do FOR EACH -- Leitura dos avisos  */

    ASSIGN ass_vlestdif = 0
           ass_vlestemp = 0.

END.  /*  Fim do FOR EACH -- Leitura dos associados  */

CREATE tt-agencia.
ASSIGN tt-agencia.cdagenci = 1000
       tt-agencia.cdhistor = -1
       tt-agencia.dsagenci = "RESUMO GERAL"
       tt-agencia.dsconven = ""
       tt-agencia.dsempres = ""
       tt-agencia.dtrefere = par_dtrefere.



FOR EACH tt-estouro:
    ASSIGN par_qtestcot = par_qtestcot + tt-estouro.qtestcot
           par_qtestemp = par_qtestemp + tt-estouro.qtestemp
           par_vlestcot = par_vlestcot + tt-estouro.vlestcot
           par_vlestemp = par_vlestemp + tt-estouro.vlestemp.
END.  

/*  Trata estouro dos CONVENIOS ............................................. */

aux_contador = NUM-ENTRIES(aux_lshstden).

FOR EACH craptab 
    WHERE craptab.cdcooper = par_cdcooper       AND
          craptab.nmsistem = "CRED"             AND
          craptab.tptabela = "GENERI"           AND
          craptab.cdempres = 0                  AND
          craptab.cdacesso = "CONVFOLHAS" NO-LOCK:

    ASSIGN aux_lshstden = aux_lshstden + 
                          (IF aux_lshstden = ""
                           THEN STRING(craptab.tpregist)
                           ELSE "," + STRING(craptab.tpregist))

           aux_contador = aux_contador + 1
           aux_dshstden[aux_contador] = craptab.dstextab.

END.  /*  Fim do FOR EACH -- Leitura dos historicos de convenio  */

FOR EACH crapavs 
    WHERE crapavs.cdcooper = par_cdcooper   AND
          crapavs.cdempres = par_cdempres   AND
          crapavs.tpdaviso = 1              AND
          crapavs.dtrefere = par_dtrefere   AND
          CAN-DO(aux_lshstden,STRING(crapavs.cdhistor)) NO-LOCK
          BREAK BY crapavs.cdhistor
                BY crapavs.cdagenci
                BY crapavs.nrdconta:

    IF   FIRST-OF(crapavs.cdhistor)   THEN
      DO:
          ASSIGN ass_vlestdif = 0
                 aux_flgexist = TRUE
                 rel_dsconven = aux_dshstden[LOOKUP(STRING(crapavs.cdhistor),
                                             aux_lshstden)].

          FIND craphis NO-LOCK WHERE
               craphis.cdcooper = crapavs.cdcooper AND 
               craphis.cdhistor = crapavs.cdhistor NO-ERROR.
          IF NOT AVAILABLE craphis   THEN
              rel_dshistor = "N/CADASTRADO".
          ELSE
              rel_dshistor = craphis.dshistor.

          CREATE tt-agencia.
          ASSIGN tt-agencia.cdagenci = crapavs.cdagenci
                 tt-agencia.cdhistor = crapavs.cdhistor
                 tt-agencia.dsagenci = rel_dsagenci[crapavs.cdagenci]
                 tt-agencia.dsconven = rel_dsconven
                 tt-agencia.dsempres = par_dsempres 
                 tt-agencia.dtrefere = par_dtrefere.
      END.

    IF crapavs.vldebito = 0 AND crapavs.vlestdif = 0 THEN
        avs_vlestdif = crapavs.vllanmto * -1.
    ELSE
        avs_vlestdif = crapavs.vlestdif.

    /*  Acumula total geral dos aviso  */

    FIND tt-totais-den WHERE tt-totais-den.cdhistor = crapavs.cdhistor NO-ERROR.
    IF NOT AVAIL tt-totais-den THEN
      DO:
          CREATE tt-totais-den.
          ASSIGN tt-totais-den.cdhistor = crapavs.cdhistor.
      END.

    ASSIGN tt-totais-den.vlavsden = tt-totais-den.vlavsden + crapavs.vllanmto
           tt-totais-den.vldebden = tt-totais-den.vldebden + crapavs.vldebito
           tt-totais-den.qtavsden = tt-totais-den.qtavsden + 1
           tt-totais-den.qtdebden = tt-totais-den.qtdebden + 
           (IF crapavs.vldebito > 0 THEN 1 ELSE 0).

    IF   crapavs.vldebito <> crapavs.vllanmto   THEN
      DO:
          IF   avs_vlestdif > 0   THEN
              ASSIGN rel_vlestdif = avs_vlestdif
                     rel_dscritic = "DEBITO MENOR".
          ELSE
          IF   avs_vlestdif < 0   THEN
            DO:
                ASSIGN rel_vlestdif = avs_vlestdif * -1
                       rel_dscritic = "ESTOURO".

                FIND FIRST tt-totais-est 
                     WHERE tt-totais-est.cdagenci = crapavs.cdagenci 
                       AND tt-totais-est.cdhistor = crapavs.cdhistor 
                       NO-ERROR.
                IF AVAIL tt-totais-est THEN
                  DO:
                      ASSIGN tt-totais-est.tot_qtestden = 
                             tt-totais-est.tot_qtestden + 1     
                             tt-totais-est.tot_vlestden = 
                             tt-totais-est.tot_vlestden + 
                                           rel_vlestdif.
                  END.
                ELSE
                  DO:
                      CREATE tt-totais-est.
                      ASSIGN tt-totais-est.tot_qtestden = 1
                             tt-totais-est.tot_vlestden = rel_vlestdif
                             tt-totais-est.cdagenci = crapavs.cdagenci
                             tt-totais-est.cdhistor = crapavs.cdhistor.
                  END.

                FIND FIRST tt-totais-est 
                     WHERE tt-totais-est.cdagenci = 999 
                       AND tt-totais-est.cdhistor = 
                           crapavs.cdhistor NO-ERROR.
                IF AVAIL tt-totais-est THEN
                  DO:
                      ASSIGN tt-totais-est.tot_qtestden = 
                             tt-totais-est.tot_qtestden + 1     
                             tt-totais-est.tot_vlestden = 
                             tt-totais-est.tot_vlestden + 
                                               rel_vlestdif.
                  END.
                ELSE
                  DO:
                      CREATE tt-totais-est.
                      ASSIGN tt-totais-est.tot_qtestden = 1
                             tt-totais-est.tot_vlestden = 
                                           rel_vlestdif
                             tt-totais-est.cdagenci = 
                                           crapavs.cdagenci
                             tt-totais-est.cdhistor = 
                                           crapavs.cdhistor.
                  END.
            END.

          IF FIRST-OF(crapavs.nrdconta)   THEN
            DO:
                CREATE tt-aviso.
                ASSIGN aux_contaavi = 1.
                FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                                   crapass.nrdconta = crapavs.nrdconta
                                   NO-LOCK NO-ERROR.

                IF NOT AVAILABLE crapass   THEN
                  DO:
                      RUN critica (INPUT 251,
                                   OUTPUT aux_dscritic).
                      CREATE tt-critic.
                      ASSIGN tt-critic.cdcritic = 251.
                             tt-critic.dscritic = 
                                 STRING(TIME,"HH:MM:SS") + " - " +
                                 par_cdprogra + "' --> '" + aux_dscritic.
                      ASSIGN tt-aviso.cdagenci = crapavs.cdagenci
                             tt-aviso.cdhistor = crapavs.cdhistor
                             tt-aviso.nrdconta = crapavs.nrdconta
                             tt-aviso.nrsequen = 1
                             tt-aviso.nmprimtl = "NAO CADASTRADO".
                  END.
                ELSE
                  DO:
                      FIND crapttl NO-LOCK WHERE 
                           crapttl.cdcooper = par_cdcooper     AND
                           crapttl.nrdconta = crapass.nrdconta AND
                           crapttl.idseqttl = 1   NO-ERROR.
                      IF AVAILABLE crapttl THEN
                          aux_cdturnos = crapttl.cdturnos.
                      ELSE
                          aux_cdturnos = 0.
                               
                      ASSIGN tt-aviso.cdagenci = crapavs.cdagenci
                             tt-aviso.cdhistor = crapavs.cdhistor
                             tt-aviso.nrdconta = crapavs.nrdconta
                             tt-aviso.nrsequen = aux_contaavi
                             tt-aviso.nrramemp = crapass.nrramemp
                             tt-aviso.cdturnos = aux_cdturnos
                            tt-aviso.nmprimtl = crapass.nmprimtl.
                  END.
            END.
          ELSE
            DO:
                ASSIGN aux_contaavi = aux_contaavi + 1.
                CREATE tt-aviso.
                ASSIGN tt-aviso.cdagenci = crapavs.cdagenci
                       tt-aviso.nrdconta = crapavs.nrdconta
                       tt-aviso.nrsequen = aux_contaavi
                       tt-aviso.nrramemp = crapass.nrramemp
                       tt-aviso.cdturnos = aux_cdturnos
                       tt-aviso.nmprimtl = crapass.nmprimtl.
            END.


          ASSIGN tt-aviso.dshistor = rel_dshistor
                 tt-aviso.nrdocmto = crapavs.nrdocmto  
                 tt-aviso.nrseqdig = crapavs.nrseqdig
                 tt-aviso.vllanmto = crapavs.vllanmto 
                 tt-aviso.vldebito = crapavs.vldebito
                 tt-aviso.vlestdif = rel_vlestdif
                 tt-aviso.dscritic = rel_dscritic.
      END.

    IF   LAST-OF(crapavs.cdhistor)   THEN
      DO:
          FOR EACH tt-totais-est WHERE tt-totais-est.cdhistor < 999:
              ASSIGN tt-totais-den.qtestden = tt-totais-den.qtestden + 
                                              tt-totais-est.tot_qtestden
                     tt-totais-den.vlestden = tt-totais-den.vlestden + 
                                              tt-totais-est.tot_vlestden.

          END.  
      END.
END.  /*  Fim do FOR EACH  --  Leitura do crapavs  */

/*  Emite resumo de outros convenios - Sindicatos, farmacias, etc  */

con_flgfirst = TRUE.



END PROCEDURE.


/* .......................................................................... */

