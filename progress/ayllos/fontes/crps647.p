/* ..........................................................................

Programa: Fontes/crps647.p
Sistema : Conta-Corrente - Cooperativa de Credito
Sigla   : CRED
Autora  : Lucas R.
Data    : Setembro/2013                        Ultima atualizacao: 19/05/2016

Dados referentes ao programa:

Frequencia: Diario (Batch).
Objetivo  : Integrar Arquivos de debitos de consorcios enviados pelo SICREDI.
            Emite relatorio 661 e 673.

Alteracoes: 27/11/2013 - Incluido o RUN do fimprg no final do programa e onde 
                         a glb_cdcritic <> 0 antes do return. (Lucas R.)
                         
            10/12/2013 - Alterado crapndb.dtmvtolt para armazenar data de 
                         vencimneto do debito, (aux_setlinha,45,8).
                       - Substituido glb_dtmvtoan por glb_dtmvtolt (Lucas R.)
                       
            11/12/2013 - Ajustes na gravacao da crapndb para gravar posicao
                         70,60 (Lucas R.)
                         
            14/01/2014 - Alteracao referente a integracao Progress X 
                         Dataserver Oracle 
                         Inclusao do VALIDATE ( Andre Euzebio / SUPERO)       
                         
            20/01/2014 - Na critica 182 substituir NEXT por 
                         "RUN fontes/fimprg.p RETURN".
                       - Mover IF  glb_cdcritic <> 0 THEN RETURN para logo apos
                         o run fontes/iniprg.p. (Lucas R.)
                         
            12/02/2014 - Ajustes para importar arquivo de debito automatico
                         junto com o de consorcios - Softdesk 128107 (Lucas R)
                         
            18/02/2014 - Alterado craptab.cdacesso = "LOTEINT031" para
                         craptab.cdacesso = "LOTEINT032" - Softdesk 131871 
                         (Lucas R.)
                         
            04/04/2014 - Retirado craptab do LOTEINT032 e substituido por
                         aux_nrdolote = 6650.
                       - Na craplau adicionado ao create o campo cdempres 
                         (Lucas R)
                         
            23/05/2014 - incluido nas consultas da craplau
                         craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                         
            03/10/2014 - Alterado lo/proc_batch para log/proc_message.log
                         (Lucas R./Elton)             
                         
            24/03/2015 - Criada a function verificaUltDia e chamada sempre
                         que for criado um registro na crapndb ou craplau
                         (SD245218 - Tiago)
                         
            30/03/2015 - Alterado gravacao da crapass.cdagenci quando nao 
                         encontrar PA, na critica 961 (Lucas R. #265513)
                         
            08/04/2015 - Adicionado a data na frente do log do proc_message
                         (Tiago).             
                                                 
                        06/05/2015 - Retirado a gravacao do campo nrcrcard na tabela
                         craplau pois havia problemas de conversao com os 
                         dados que estavam vindo do arquivo FUT e este dado
                         acabava nao sendo usado posteriormente
                         SD282057 (Tiago/Fabricio).
                         
            14/08/2015 - Ajustes na busca de arquivos no diretorio do Connect.
                         (Chamado 276157) - (Fabricio)
                         
            04/09/2015 - Incluir validacao caso o cooperado esteja demitido 
                         (Lucas Ranghetti #324974)
                         
            21/09/2015 - Ajustes no processamento dos arquivos.
                         Gerar quoter em outro diretorio pois o diretorio do
                         Connect no Unix eh um mapeamento do servidor Connect
                         Windows e acontecem alguns problemas ao trabalhar com
                         arquivos dentro deste mapeamento. 
                         (Chamado 276157) - (Fabricio)
                         
            18/01/2016 - Ajuste na leitura da tabela CRAPCNS (consorcio) para
                         filtrar tambem pela conta Sicredi (quando um cooperado
                         possui duas contas e migra o consorcio de uma conta
                         para outra, o n. do contrato nao se altera e, como
                         o CPF eh o mesmo da falha no FIND porque retorna dois
                         registros). (Chamado 377579) - (Fabricio)
                         
            25/01/2016 - Incluido crapatr.dtfimatr = ? na verificacao da autorizacao,
                         pois autorizacao nao pode estar cancelada ao efetuar 
                         agendamento (Ranghetti #389327)
                         
            29/01/2016 - Incluir craplau.insitlau = 1 na busca do registro para 
                         cancelamento(Ranghetti #384817)
                       - Adicionar crapass para uma temp-table para ganhar performace
                         na execucao do programa (Ranghetti/Elton)
                         
            19/05/2016 - Incluido ajuste para notificar cooperado qnd valor 
                         da fatura ultrapassar limite definido 
                         PRJ320 - Oferta DebAut (Odirlei-AMcom)  
                            
............................................................................*/

{ sistema/generico/includes/var_oracle.i }
DEF BUFFER crabcop FOR crapcop.
DEF BUFFER crabatr FOR crapatr.
DEF VAR h-b1wgen0116 AS HANDLE                                  NO-UNDO.

DEF STREAM str_1.   /*  crrl661 */
DEF STREAM str_2.   /*  Para arquivo de importacao         */
DEF STREAM str_3.   /*  Para arquivo                       */
DEF STREAM str_4.   /*  crrl673 */

{ includes/var_batch.i }  

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 9
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "CADASTROS",
                                     "PROCESSOS",
                                     "PARAMETRIZACAO",
                                     "SOLICITACOES",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR    FORMAT "x(70)"                NO-UNDO.
DEF        VAR aux_setlinha AS CHAR    FORMAT "x(210)"               NO-UNDO.
DEF        VAR aux_cdultcop AS INT                                   NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_flgrejei AS LOG                                   NO-UNDO. 
DEF        VAR aux_flgdupli AS LOG                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_tpregist AS CHAR                                  NO-UNDO.
DEF        VAR aux_vldebito AS DECI                                  NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dsmovmto AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscritic AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmtabela AS CHAR                                  NO-UNDO.
DEF        VAR aux_contareg AS INTE                                  NO-UNDO.
DEF        VAR aux_seqparam AS INTE                                  NO-UNDO.
DEF        VAR aux_digitmes AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqmov AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdcritic AS INTE                                  NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_vllanaut AS CHAR                                  NO-UNDO.
DEF        VAR aux_nrdocmto AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdseqtel AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfirst AS LOG                                   NO-UNDO.
DEF        VAR tab_nmarquiv AS CHAR    FORMAT "x(50)"   EXTENT 99    NO-UNDO.
DEF        VAR aux_nmarqdeb AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_contador AS INTE                                  NO-UNDO.
DEF        VAR aux_nrdconta AS INT                                   NO-UNDO.
DEF        VAR aux_nrctrato AS INT                                   NO-UNDO.
DEF        VAR aux_nmempres AS CHAR                                  NO-UNDO.
DEF        VAR aux_tpdebito AS INTE                                  NO-UNDO.
DEF        VAR aux_cdagenci AS INTE                                  NO-UNDO.
DEF        VAR aux_cdempres AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdrefere AS CHAR FORMAT "x(25)"                   NO-UNDO.

DEF        VAR aux_cont     AS INT FORMAT "999999"                   NO-UNDO.
DEF        VAR aux_geraerro AS LOG INIT FALSE                        NO-UNDO.

DEF        VAR tot_qtdrejei AS INT                                   NO-UNDO.
DEF        VAR tot_vlpareje AS DEC                                   NO-UNDO.
DEF        VAR tot_qtdreceb AS INT                                   NO-UNDO.
DEF        VAR tot_vlparceb AS DEC                                   NO-UNDO.
DEF        VAR tot_qtdinteg AS INT                                   NO-UNDO.
DEF        VAR tot_vlpainte AS DEC                                   NO-UNDO.
DEF        VAR aux_dtdebito AS DATE                                  NO-UNDO.

DEF        VAR aux_nmquoter AS CHAR                                  NO-UNDO.
DEF        VAR tab_nmquoter AS CHAR    FORMAT "x(50)"   EXTENT 99    NO-UNDO.
DEF        VAR aux_nrdolote_sms AS DEC                               NO-UNDO.

DEF TEMP-TABLE w-relato NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapcns.nrdconta
    FIELD cdrefere AS CHAR
    FIELD vlparcns LIKE crapcns.vlparcns
    FIELD nrctacns LIKE crapcns.nrctacns
    FIELD dtdebito AS DATE
    FIELD cdcritic AS INTE
    FIELD dscritic AS CHAR
    FIELD tpdebito AS INTE /*  (1 – consorcio 2 – débito automatico) */
    FIELD nmempres AS CHAR
    FIELD cdagenci AS INTE.   

DEF TEMP-TABLE tt-crapass NO-UNDO
    FIELD cdcooper LIKE crapass.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrctacns LIKE crapass.nrctacns
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dtdemiss LIKE crapass.dtdemiss
    INDEX tt-crapass1 AS PRIMARY cdcooper nrctacns.

FORM aux_setlinha  FORMAT "x(210)"
     WITH FRAME AA WIDTH 150 NO-BOX NO-LABELS.

FORM SKIP(1)
     "ARQUIVO:"         AT 01
     aux_nmarqmov       AT 10 FORMAT "x(35)"    NO-LABEL
     SKIP(1)
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM SKIP
     w-relato.nrdconta FORMAT "zzzz,zzz,9" COLUMN-LABEL "CONTA/DV"  
     w-relato.nrctacns FORMAT "zzzz,zzz,9" COLUMN-LABEL "CTA.CONSORCIO"
     w-relato.cdrefere FORMAT "9999999999999999999999999" 
                                           COLUMN-LABEL "IDENTIFICACAO CONSORCIO"
     w-relato.vlparcns FORMAT "zzz,zz9.99" COLUMN-LABEL "VALOR"
     w-relato.dtdebito FORMAT "99/99/9999" COLUMN-LABEL "DATA.DEB."
     w-relato.dscritic FORMAT "x(50)"      COLUMN-LABEL "CRITICA"
     WITH NO-BOX DOWN  WIDTH 132  FRAME f_lanctos_661.

FORM SKIP
     w-relato.cdagenci FORMAT "zz9"        COLUMN-LABEL "PA"
     w-relato.nrdconta FORMAT "zzzz,zzz,9" COLUMN-LABEL "CONTA/DV"  
     w-relato.nrctacns FORMAT "zzzz,zzz,9" COLUMN-LABEL "CT SICREDI"
     w-relato.nmempres FORMAT "x(20)"      COLUMN-LABEL "CONVENIO"
     w-relato.cdrefere FORMAT "9999999999999999999999999" 
                                           COLUMN-LABEL "IDENTIFICACAO"
     w-relato.vlparcns FORMAT "zzz,zz9.99" COLUMN-LABEL "VALOR"
     w-relato.dtdebito FORMAT "99/99/9999" COLUMN-LABEL "DATA DEB."
     w-relato.dscritic FORMAT "x(35)"      COLUMN-LABEL "CRITICA"
     WITH NO-BOX DOWN  WIDTH 132  FRAME f_lanctos_673.


FUNCTION verificaUltDia RETURNS DATE
    ( INPUT par_cdcooper AS INTEGER, INPUT par_dtrefere AS   DATE) :

    DEF VAR vr_dtultdia             AS      DATE                NO-UNDO.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapdat) THEN
        DO:
            RETURN par_dtrefere.
        END.

    ASSIGN vr_dtultdia = DATE('31/12/' + STRING(YEAR(crapdat.dtmvtolt),'9999')).

    IF  par_dtrefere = vr_dtultdia THEN
        DO:
            ASSIGN par_dtrefere = par_dtrefere + 1.

            DO WHILE TRUE:
            
                FIND crapfer WHERE crapfer.dtferiad = par_dtrefere 
                               AND crapfer.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL(crapfer)          AND 
                   (WEEKDAY(par_dtrefere) <> 1  AND
                    WEEKDAY(par_dtrefere) <> 7) THEN
                    DO:
                       LEAVE.
                    END.
                
                ASSIGN par_dtrefere = par_dtrefere + 1.

            END.
        END.

    RETURN par_dtrefere.
END FUNCTION.
   

ASSIGN glb_cdprogra = "crps647"
       glb_progerad    = "647".
       
RUN fontes/iniprg.p.

IF  glb_cdcritic <> 0 THEN
    RETURN.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper 
                   NO-LOCK NO-ERROR.

IF  NOT AVAILABLE crapcop   THEN
    DO:
        glb_cdcritic = 651.
        RUN fontes/critic.p.
        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") +
                           " - " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_message.log").
        RETURN.                 
    END.

ASSIGN aux_nrdolote = 6650.

/* Monta digito do Mês para nome o arquivo SICREDI */
IF  MONTH(glb_dtmvtolt) = 10 THEN
    ASSIGN aux_digitmes = "O".
ELSE
IF  MONTH(glb_dtmvtolt) = 11 THEN
    ASSIGN aux_digitmes = "N".
ELSE
IF  MONTH(glb_dtmvtolt) = 12 THEN
    ASSIGN aux_digitmes = "D".
ELSE
    ASSIGN aux_digitmes = STRING(MONTH(glb_dtmvtolt),"9").

ASSIGN aux_nmarqmov = "0"                                             +
                      FILL("0", 4 - LENGTH(STRING(crapcop.nrctasic))) +
                      TRIM(SUBSTR(STRING(crapcop.nrctasic),1,4))      +
                      aux_digitmes + STRING(DAY(glb_dtmvtolt),"99").
    
ASSIGN aux_nmarqdeb = "/usr/connect/sicredi/recebe/" + aux_nmarqmov + ".FUT"
       aux_nmquoter = "/usr/coop/" + LOWER(crapcop.dsdircop) + "/arq/" +
                      aux_nmarqmov + ".FUT.q"
       aux_contador = 0.

IF  SEARCH(aux_nmarqdeb) = ? THEN
    DO:
        ASSIGN aux_nmarqdeb = "/usr/connect/sicredi/recebe/" + aux_nmarqmov +
                              ".fut"
               aux_nmquoter = "/usr/coop/" + LOWER(crapcop.dsdircop) + "/arq/" +
                              aux_nmarqmov + ".fut.q".

        IF  SEARCH(aux_nmarqdeb) = ? THEN
            DO:
                ASSIGN glb_cdcritic = 182.
                RUN fontes/critic.p.
                UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") +
                                   " - " + STRING(TIME,"HH:MM:SS")    +
                                   " - " + glb_cdprogra + "' --> '"     + 
                                   glb_dscritic + "' --> '"             + 
                                   "Arquivo esperado: " + aux_nmarqmov  +
                                   ".FUT" + " >> log/proc_message.log").
                RUN fontes/fimprg.p.
                RETURN.
 
            END.
    END.

INPUT STREAM str_3 THROUGH VALUE( "ls " + aux_nmarqdeb + " 2> /dev/null") 
NO-ECHO.

DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

    SET STREAM str_3 aux_nmarquiv FORMAT "x(70)".
   
    UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                      aux_nmquoter + " 2> /dev/null").

    INPUT STREAM str_2 FROM VALUE(aux_nmquoter) NO-ECHO.

    SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 210.

    INPUT STREAM str_2 CLOSE.
    
    ASSIGN aux_contador = aux_contador + 1
           tab_nmarquiv[aux_contador] = aux_nmarquiv
           tab_nmquoter[aux_contador] = aux_nmquoter.

END. /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_3 CLOSE.

DO  i = 1 TO aux_contador:
                                                 
    ASSIGN glb_cdcritic = 0
           aux_vldebito = 0.
    
    ASSIGN aux_flgrejei = FALSE
           aux_flgdupli = FALSE.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        INPUT STREAM str_2 FROM VALUE(tab_nmquoter[i]) NO-ECHO.
        
        SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 210.
        
        /* faz a primeira linha do arquivo */
        ASSIGN aux_diarefer = INT(SUBSTR(aux_setlinha,72,2))
               aux_mesrefer = INT(SUBSTR(aux_setlinha,70,2))
               aux_anorefer = INT(SUBSTR(aux_setlinha,66,4)).
              
        IF  aux_mesrefer < 1  OR
            aux_mesrefer > 12 OR 
            aux_diarefer < 1 THEN
            ASSIGN glb_cdcritic = 13.
        ELSE
            ASSIGN  aux_dtrefere = DATE(aux_mesrefer,01,aux_anorefer).
        
        IF  glb_cdcritic <> 13 THEN
            DO:
                IF  MONTH(aux_dtrefere) = 12 THEN
                    ASSIGN aux_dtrefere = DATE(01,01,YEAR(aux_dtrefere) + 1).
                ELSE
                    ASSIGN aux_dtrefere = DATE(MONTH(aux_dtrefere) + 1,01,
                                          YEAR(aux_dtrefere)).
                
                ASSIGN aux_dtrefere = aux_dtrefere - DAY(aux_dtrefere).
                
                IF  aux_diarefer > DAY(aux_dtrefere) THEN
                    ASSIGN glb_cdcritic = 13.
                ELSE
                    ASSIGN  aux_dtrefere = DATE(aux_mesrefer, aux_diarefer,
                                                aux_anorefer).
            END.

        LEAVE.
    END. /* fim do do while true */
    
    INPUT STREAM str_2 CLOSE.
    
    ASSIGN aux_contareg = 1
           glb_cdcritic = 0.

    INPUT STREAM str_2 FROM VALUE(tab_nmquoter[i]) NO-ECHO.

    SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 210.
    
    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 210.
    
        ASSIGN aux_tpregist = SUBSTR(aux_setlinha,1,1).
    
        IF  NOT CAN-DO("A,C,D,E,Z",aux_tpregist) THEN
            DO:
               ASSIGN glb_cdcritic = 468.
               RUN fontes/critic.p.
               UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                                  " - " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  + 
                                  glb_dscritic + " >> log/proc_message.log").
               glb_cdcritic = 0. 
               NEXT.
            END. 

        /* somatoria da quantidade de registros no arquivo */
        ASSIGN  aux_contareg = aux_contareg + 1.
    
        IF  aux_tpregist = "A" THEN
            DO:
               ASSIGN  glb_cdcritic = 468.
               LEAVE.
            END.
        ELSE
        IF  aux_tpregist = "E" THEN
            DO:
                      
               ASSIGN aux_vldebito = aux_vldebito +
                      (DEC(SUBSTR(aux_setlinha,53,15)) / 100).
               
               ASSIGN aux_diarefer = INT(SUBSTR(aux_setlinha,51,2))
                      aux_mesrefer = INT(SUBSTR(aux_setlinha,49,2))
                      aux_anorefer = INT(SUBSTR(aux_setlinha,45,4)).
                                    
               IF  aux_mesrefer < 1  OR
                   aux_mesrefer > 12 OR
                   aux_diarefer < 1  THEN
                   ASSIGN  glb_cdcritic = 13.
               ELSE
                   ASSIGN  aux_dtrefere = DATE(aux_mesrefer,aux_diarefer,
                                               aux_anorefer).

               IF  glb_cdcritic > 0 THEN
                   LEAVE.
            END.      
        ELSE
        IF  aux_tpregist = "Z" THEN
            DO:
               IF  aux_contareg <> INT(SUBSTR(aux_setlinha,2,6)) THEN
                   DO:
                      ASSIGN glb_cdcritic = 504.
                      LEAVE.
                   END.
               ELSE
               IF  aux_vldebito <> (DEC(SUBSTR(aux_setlinha,08,17)) / 100) THEN
                   DO:
                      glb_cdcritic  = 505.
                      LEAVE.
                   END.
            END.
        
    END. /* Fim do DO WHILE */

    IF  glb_cdcritic <> 0 AND glb_cdcritic <> 484 THEN
        DO: /* gera arquivo erro e nao importa para recebidos */
           RUN fontes/critic.p.
           aux_nmarquiv = "/usr/connect/sicredi/recebe/err" + aux_nmarqmov + 
                          ".FUT".
           UNIX SILENT VALUE("rm " + tab_nmquoter[i] + " 2> /dev/null").
           UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " " + aux_nmarquiv).
           UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                            " - " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '"   +
                            glb_dscritic + " " + aux_nmarquiv  +
                            " >> log/proc_message.log").
           RUN fontes/fimprg.p.
           RETURN.
        END.

    INPUT STREAM str_2 CLOSE.

    /************************************************************************/
    /************************ INTEGRA ARQUIVO RECEBIDO **********************/
    /************************************************************************/

    /* Gravar registros das contas consorcios na temp-table */
    FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrctacns <> 0 NO-LOCK:

        CREATE tt-crapass.
        ASSIGN tt-crapass.cdcooper = crapass.cdcooper
               tt-crapass.nrdconta = crapass.nrdconta
               tt-crapass.nrctacns = crapass.nrctacns
               tt-crapass.cdagenci = crapass.cdagenci
               tt-crapass.dtdemiss = crapass.dtdemiss.
    END.
    
    ASSIGN  glb_cdcritic = 219.
            RUN fontes/critic.p.
            UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                      " - " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"          +
                      glb_dscritic + "' --> '" + "recebe/" + aux_nmarqmov   + 
                      ".FUT" + " >> log/proc_message.log").

    ASSIGN  glb_cdcritic = 0.
    
    INPUT STREAM str_2 FROM VALUE(tab_nmquoter[i]) NO-ECHO.

    SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 210.

    TRANS_1:
    DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:
    
        SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 210.

        ASSIGN aux_tpregist = SUBSTR(aux_setlinha,1,1)
               glb_cdcritic = 0.

        IF  aux_tpregist = "E" OR 
            aux_tpregist = "D" OR 
            aux_tpregist = "C" THEN
            DO:
                ASSIGN aux_cdrefere = SUBSTR(aux_setlinha,2,25).
                
                FIND crapscn WHERE 
                     crapscn.cdempres = TRIM(SUBSTR(aux_setlinha,148,10))
                     NO-LOCK NO-ERROR.

                IF  AVAIL crapscn THEN
                    ASSIGN aux_nmempres = crapscn.dsnomcnv
                           aux_cdempres = crapscn.cdempres.
                ELSE
                    ASSIGN aux_nmempres = ""
                           aux_cdempres = "".
        
                IF  TRIM(SUBSTR(aux_setlinha,148,10)) = "J5" THEN /* Consorcios */
                    ASSIGN aux_tpdebito = 1
                           aux_cdhistor = 1230.
                ELSE
                    ASSIGN aux_tpdebito = 2
                           aux_cdhistor = 1019.

                FIND FIRST tt-crapass WHERE 
                           tt-crapass.cdcooper = glb_cdcooper AND
                           tt-crapass.nrctacns = INT(SUBSTR(aux_setlinha,31,14))
                           USE-INDEX tt-crapass1 NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL tt-crapass THEN
                    DO: 
                        ASSIGN aux_nrdconta = 0.

                        CREATE crapndb.
                        ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                               crapndb.nrdconta = aux_nrdconta
                               crapndb.cdhistor = aux_cdhistor
                               crapndb.flgproce = FALSE
                               crapndb.dstexarq = "F" +
                                                  SUBSTR(aux_setlinha,2,66)   +
                                                  "15" +
                                                  SUBSTR(aux_setlinha,70,60)  +
                                                  FILL(" ",16)                +
                                                  SUBSTR(aux_setlinha,140,2)  +
                                                  SUBSTR(aux_setlinha,148,10) +
                                                  SUBSTR(aux_setlinha,158,1)  +
                                                  FILL(" ", 2) 
                               crapndb.cdcooper = glb_cdcooper.
                        VALIDATE crapndb.

                        /* nao existe conta consorcio */
                        ASSIGN glb_cdcritic = 961.
                        RUN fontes/critic.p.
                        
                        CREATE w-relato.
                        ASSIGN w-relato.cdcooper = glb_cdcooper
                               w-relato.nrdconta = aux_nrdconta
                               w-relato.nrctacns = DEC(SUBSTR(aux_setlinha,
                                                   31,14))
                               w-relato.cdrefere = aux_cdrefere
                               w-relato.vlparcns = IF aux_tpregist = "E" THEN
                                                      (DEC(SUBSTR(aux_setlinha,
                                                       53,15)) / 100)
                                                   ELSE 0
                               w-relato.dtdebito = IF aux_tpregist = "E" THEN
                                                      aux_dtrefere
                                                   ELSE ?
                               w-relato.cdcritic = glb_cdcritic
                               w-relato.dscritic = glb_dscritic
                               w-relato.nmempres = aux_nmempres
                               w-relato.tpdebito = aux_tpdebito
                               w-relato.cdagenci = 0. /* nao precisa ter agencia
                                                         quando nao encontra 
                                                         associado */

                        NEXT TRANS_1.
                    END.
                ELSE /* se achou conta na crapass */
                    DO:
                        ASSIGN aux_nrdconta = tt-crapass.nrdconta.
                        
                        /* Caso o cooperado esteja demitido */
                        IF  tt-crapass.dtdemiss <> ? THEN
                            DO:
                                CREATE crapndb.
                                ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                                       crapndb.nrdconta = aux_nrdconta
                                       crapndb.cdhistor = aux_cdhistor
                                       crapndb.flgproce = FALSE
                                       crapndb.dstexarq = "F" +
                                                          SUBSTR(aux_setlinha,2,66)   +
                                                          "15" +
                                                          SUBSTR(aux_setlinha,70,60)  +
                                                          FILL(" ",16)                +
                                                          SUBSTR(aux_setlinha,140,2)  +
                                                          SUBSTR(aux_setlinha,148,10) +
                                                          SUBSTR(aux_setlinha,158,1)  +
                                                          FILL(" ", 2) 
                                       crapndb.cdcooper = glb_cdcooper.
                                VALIDATE crapndb.

                                /* associado nao cadastrado */
                                ASSIGN glb_cdcritic = 09.
                                RUN fontes/critic.p.
                                
                                CREATE w-relato.
                                ASSIGN w-relato.cdcooper = glb_cdcooper
                                       w-relato.nrdconta = aux_nrdconta
                                       w-relato.nrctacns = DEC(SUBSTR(aux_setlinha,
                                                           31,14))
                                       w-relato.cdrefere = aux_cdrefere
                                       w-relato.vlparcns = IF aux_tpregist = "E" THEN
                                                              (DEC(SUBSTR(aux_setlinha,
                                                               53,15)) / 100)
                                                           ELSE 0
                                       w-relato.dtdebito = IF aux_tpregist = "E" THEN
                                                              aux_dtrefere
                                                           ELSE ?
                                       w-relato.cdcritic = glb_cdcritic
                                       w-relato.dscritic = glb_dscritic
                                       w-relato.nmempres = aux_nmempres
                                       w-relato.tpdebito = aux_tpdebito
                                       w-relato.cdagenci = tt-crapass.cdagenci.
                                NEXT TRANS_1.          
                            END.                       
                    END.
                    
                /* nao e consorcio <> J5 */
                IF  TRIM(SUBSTR(aux_setlinha,148,10)) <> "J5" THEN
                    DO:
                        FIND crapatr  WHERE  
                             crapatr.cdcooper = glb_cdcooper AND
                             crapatr.nrdconta = aux_nrdconta AND
                             crapatr.cdrefere = DECI(aux_cdrefere) AND
                             crapatr.cdhistor = 1019  AND 
                             crapatr.cdempres = TRIM(SUBSTR(aux_setlinha,148,10)) AND
                             crapatr.dtfimatr = ?
                             EXCLUSIVE-LOCK NO-ERROR.

                        IF  NOT AVAIL crapatr THEN
                            DO:
                               CREATE crapndb.
                               ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                                      crapndb.nrdconta = aux_nrdconta
                                      crapndb.cdhistor = aux_cdhistor 
                                      crapndb.flgproce = FALSE
                                      crapndb.dstexarq = "F" +
                                              SUBSTR(aux_setlinha,2,66)   + 
                                              "30"                        +
                                              SUBSTR(aux_setlinha,70,60)  +
                                              FILL(" ",16)                +
                                              SUBSTR(aux_setlinha,140,2)  +
                                              SUBSTR(aux_setlinha,148,10) +
                                              SUBSTR(aux_setlinha,158,1)  +
                                              FILL(" ", 2)
                                      crapndb.cdcooper = glb_cdcooper.
                               VALIDATE crapndb.
                               
                               glb_cdcritic = 484.
                               RUN fontes/critic.p. 
                               
                               CREATE w-relato.
                               ASSIGN w-relato.cdcooper = glb_cdcooper
                                      w-relato.nrdconta = aux_nrdconta
                                      w-relato.nrctacns = 
                                               DEC(SUBSTR(aux_setlinha,31,14))
                                      w-relato.cdrefere = aux_cdrefere
                                      w-relato.vlparcns = 
                                               IF aux_tpregist = "E" THEN
                                                  (DEC(SUBSTR(aux_setlinha,
                                                   53,15)) / 100)
                                               ELSE 0
                                      w-relato.dtdebito = 
                                               IF aux_tpregist = "E" THEN
                                                  aux_dtrefere
                                               ELSE ?
                                      w-relato.cdcritic = glb_cdcritic
                                      w-relato.dscritic = glb_dscritic
                                      w-relato.nmempres = aux_nmempres
                                      w-relato.tpdebito = aux_tpdebito
                                      w-relato.cdagenci = tt-crapass.cdagenci.
                               
                               NEXT TRANS_1.
                            END. /* Fim do find crapatr */
                    END.
                ELSE /* se for consorcios J5 */
                DO:
                    FIND crapcns WHERE 
                         crapcns.cdcooper = glb_cdcooper                    AND
                         crapcns.nrctrato = INT(SUBSTR(aux_setlinha,2,8))   AND
                         crapcns.nrcpfcgc = DEC(SUBSTR(aux_setlinha,10,14)) AND
                         crapcns.nrctacns = DEC(SUBSTR(aux_setlinha,31,14))
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF  NOT AVAIL crapcns THEN
                        DO: 
                            
                            CREATE crapndb.
                            ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                                   crapndb.nrdconta = aux_nrdconta
                                   crapndb.cdhistor = aux_cdhistor
                                   crapndb.flgproce = FALSE
                                   crapndb.dstexarq = "F" +
                                           SUBSTR(aux_setlinha,2,66)   + 
                                           "30"                        +
                                           SUBSTR(aux_setlinha,70,60)  +
                                           FILL(" ",16)                +
                                           SUBSTR(aux_setlinha,140,2)  +
                                           SUBSTR(aux_setlinha,148,10) +
                                           SUBSTR(aux_setlinha,158,1)  +
                                           FILL(" ", 2)
                                   crapndb.cdcooper = glb_cdcooper.
                            VALIDATE crapndb.
                    
                            glb_cdcritic = 484.
                            RUN fontes/critic.p. 
                          
                            CREATE w-relato.
                            ASSIGN w-relato.cdcooper = glb_cdcooper
                                   w-relato.nrdconta = aux_nrdconta
                                   w-relato.nrctacns = DEC(SUBSTR(aux_setlinha,
                                                                  31,14))
                                   w-relato.cdrefere = aux_cdrefere
                                   w-relato.vlparcns = 
                                            IF aux_tpregist = "E" THEN
                                               (DEC(SUBSTR(aux_setlinha,
                                                53,15)) / 100)
                                            ELSE 0
                                   w-relato.dtdebito = 
                                            IF aux_tpregist = "E" THEN
                                               aux_dtrefere
                                            ELSE ?
                                   w-relato.cdcritic = glb_cdcritic
                                   w-relato.dscritic = glb_dscritic
                                   w-relato.nmempres = aux_nmempres
                                   w-relato.tpdebito = aux_tpdebito
                                   w-relato.cdagenci = tt-crapass.cdagenci.
                    
                            NEXT TRANS_1.
                        END.
                    ELSE
                        DO:
                            ASSIGN glb_cdcritic = 0.
                            
                            CASE crapcns.tpconsor:
                                 WHEN 1 THEN /* MOTO */
                                      ASSIGN aux_cdhistor = 1230. 
                                 WHEN 2 THEN /* AUTO */
                                      ASSIGN aux_cdhistor = 1231.
                                 WHEN 3 THEN /* PESADOS */
                                      ASSIGN aux_cdhistor = 1232.
                                 WHEN 4 THEN /* IMOVEIS */
                                      ASSIGN aux_cdhistor = 1233.
                                 WHEN 5 THEN /* SERVICOS */
                                      ASSIGN aux_cdhistor = 1234.
                            END CASE.
                            
                            ASSIGN crapcns.nrdaviso = INT(SUBSTR(aux_setlinha,
                                                                 89,11))
                                   crapcns.nrboleto = INT(SUBSTR(aux_setlinha,
                                                                 70,9)).
                            
                            ASSIGN glb_cdcritic = 0.
                        END.
                END.
            END. /* tpregist = "E,C,D" */

        IF  aux_tpregist = "E" THEN
            DO:
                aux_dtdebito = DATE(INT(SUBSTR(aux_setlinha,49,2)),
                                    INT(SUBSTR(aux_setlinha,51,2)),
                                    INT(SUBSTR(aux_setlinha,45,4)) ).

                ASSIGN aux_diarefer = INT(SUBSTR(aux_setlinha,51,2))
                       aux_mesrefer = INT(SUBSTR(aux_setlinha,49,2))
                       aux_anorefer = INT(SUBSTR(aux_setlinha,45,4)).
              
                IF  aux_mesrefer < 1  OR
                    aux_mesrefer > 12 OR
                    aux_diarefer < 1  THEN
                    ASSIGN  glb_cdcritic = 13.
                ELSE
                    ASSIGN aux_dtrefere = DATE(aux_mesrefer,aux_diarefer,
                                               aux_anorefer).

                IF  (aux_dtrefere + 30) < glb_dtmvtolt THEN
                     ASSIGN glb_cdcritic = 13.

                IF  glb_cdcritic = 13 THEN 
                    DO:
                        CREATE crapndb.
                        ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                               crapndb.nrdconta = aux_nrdconta
                               crapndb.cdhistor = aux_cdhistor
                               crapndb.flgproce = FALSE
                               crapndb.dstexarq = "F" +
                                                  SUBSTR(aux_setlinha,2,66)   +
                                                  "13"                        +
                                                  SUBSTR(aux_setlinha,70,60)  +
                                                  FILL(" ",16)                +
                                                  SUBSTR(aux_setlinha,140,2)  +
                                                  SUBSTR(aux_setlinha,148,10) +
                                                  SUBSTR(aux_setlinha,158,1)  +
                                                  FILL(" ", 2)
                               crapndb.cdcooper = glb_cdcooper.
                        VALIDATE crapndb.

                        glb_cdcritic = 13.
                        RUN fontes/critic.p. 
                      
                        CREATE w-relato.
                        ASSIGN w-relato.cdcooper = glb_cdcooper
                               w-relato.nrdconta = aux_nrdconta
                               w-relato.nrctacns = DEC(SUBSTR(aux_setlinha,
                                                              31,14))
                               w-relato.cdrefere = aux_cdrefere
                               w-relato.vlparcns = IF aux_tpregist = "E" THEN
                                                      (DEC(SUBSTR(aux_setlinha,
                                                       53,15)) / 100)
                                                   ELSE 0
                               w-relato.dtdebito = IF aux_tpregist = "E" THEN
                                                      aux_dtrefere
                                                   ELSE ?
                               w-relato.nmempres = aux_nmempres
                               w-relato.tpdebito = aux_tpdebito
                               w-relato.cdcritic = glb_cdcritic
                               w-relato.dscritic = glb_dscritic
                               w-relato.cdagenci = tt-crapass.cdagenci.
                        NEXT TRANS_1.
                    END.

                /* codigo do movimento 0 = inclusao/1 = cancelamento */
                IF  INT(SUBSTR(aux_setlinha,158,1)) = 0 THEN
                    DO:
                        FIND FIRST craplau WHERE 
                                   craplau.cdcooper = glb_cdcooper AND
                                   craplau.dtmvtopg = aux_dtrefere AND
                                   craplau.nrdconta = aux_nrdconta AND
                                   craplau.nrdocmto = DECI(aux_cdrefere) AND
                                   craplau.cdhistor = aux_cdhistor AND
                                   craplau.insitlau <> 3
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                        IF  AVAIL craplau THEN
                            DO:

                                CREATE crapndb.
                                ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                                       crapndb.nrdconta = aux_nrdconta
                                       crapndb.cdhistor = aux_cdhistor
                                       crapndb.flgproce = FALSE
                                       crapndb.dstexarq = "F" +
                                               SUBSTR(aux_setlinha,2,66)   + 
                                               "04"                        +
                                               SUBSTR(aux_setlinha,70,60)  +
                                               FILL(" ",16)                +
                                               SUBSTR(aux_setlinha,140,2)  +
                                               SUBSTR(aux_setlinha,148,10) +
                                               SUBSTR(aux_setlinha,158,1)  +
                                               FILL(" ", 2)
                                       crapndb.cdcooper = glb_cdcooper.

                                ASSIGN glb_cdcritic = 092.
                                RUN fontes/critic.p.
                       
                                CREATE w-relato.
                                ASSIGN w-relato.cdcooper = glb_cdcooper
                                       w-relato.nrdconta = aux_nrdconta
                                       w-relato.nrctacns =
                                       DECI(SUBSTR(aux_setlinha,31,14))
                                       w-relato.cdrefere = aux_cdrefere
                                       w-relato.vlparcns = 
                                       (DECI(SUBSTR(aux_setlinha,
                                                   53,15)) / 100)
                                       w-relato.dtdebito = aux_dtrefere
                                       w-relato.cdcritic = glb_cdcritic
                                       w-relato.dscritic = glb_dscritic
                                       w-relato.nmempres = aux_nmempres
                                       w-relato.tpdebito = aux_tpdebito
                                       w-relato.cdagenci = tt-crapass.cdagenci.
                                    
                                ASSIGN aux_flgdupli = TRUE.
                                
                            END.
                        
                        IF  glb_cdcritic > 0 THEN
                            DO:
                               glb_cdcritic  = 0.
                               NEXT TRANS_1.
                            END.

                        DO  WHILE TRUE:
                           
                            FIND craplot WHERE 
                                 craplot.cdcooper = glb_cdcooper AND 
                                 craplot.dtmvtolt = glb_dtmvtolt AND
                                 craplot.cdagenci = 1            AND
                                 craplot.cdbccxlt = 100          AND
                                 craplot.nrdolote = aux_nrdolote
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                               
                            IF  NOT AVAILABLE craplot   THEN
                                IF  LOCKED craplot   THEN
                                    DO:
                                       PAUSE 2 NO-MESSAGE.
                                       NEXT.
                                    END.
                                ELSE
                                    DO:
                                       CREATE craplot.
                                       ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                                              craplot.dtmvtopg = glb_dtmvtopr
                                              craplot.cdagenci = 1
                                              craplot.cdbccxlt = 100
                                              craplot.cdbccxpg = 11
                                              craplot.cdhistor = aux_cdhistor
                                              craplot.nrdolote = aux_nrdolote
                                              craplot.cdoperad= "1"
                                              craplot.tplotmov = 12
                                              craplot.tpdmoeda = 1
                                              craplot.cdcooper = glb_cdcooper.
                                       VALIDATE craplot.
                                    END.
                            
                            LEAVE.
                            
                        END.  /*  Fim do DO WHILE TRUE  */
                        
                        FIND craplau WHERE 
                             craplau.cdcooper = glb_cdcooper     AND
                             craplau.dtmvtolt = glb_dtmvtolt     AND
                             craplau.cdagenci = craplot.cdagenci AND
                             craplau.cdbccxlt = craplot.cdbccxlt AND
                             craplau.nrdolote = aux_nrdolote     AND
                             craplau.nrdconta = aux_nrdconta     AND
                             craplau.nrdocmto = DECI(aux_cdrefere)
                             NO-LOCK NO-ERROR.
    
                        IF  AVAIL craplau THEN
                            DO:
                                IF  LOCKED craplau  THEN
                                    DO:
                                       PAUSE 2 NO-MESSAGE.
                                       NEXT.
                                    END.
    
                                ASSIGN glb_cdcritic = 103.
                                RUN fontes/critic.p.

                                CREATE w-relato.
                                ASSIGN w-relato.cdcooper = glb_cdcooper
                                       w-relato.nrdconta = aux_nrdconta
                                       w-relato.nrctacns = 
                                       DECI(SUBSTR(aux_setlinha,31,14))
                                       w-relato.cdrefere = aux_cdrefere
                                       w-relato.vlparcns = 
                                       (DECI(SUBSTR(aux_setlinha,53,15)) / 100)
                                       w-relato.dtdebito = aux_dtrefere
                                       w-relato.cdcritic = glb_cdcritic
                                       w-relato.dscritic = glb_dscritic
                                       w-relato.nmempres = aux_nmempres
                                       w-relato.tpdebito = aux_tpdebito
                                       w-relato.cdagenci = tt-crapass.cdagenci.

                                NEXT TRANS_1.
                            END.
                        ELSE
                            DO:
                                CREATE w-relato.
                                ASSIGN w-relato.cdcooper = glb_cdcooper
                                       w-relato.nrdconta = aux_nrdconta
                                       w-relato.nrctacns = 
                                       DECI(SUBSTR(aux_setlinha,31,14))
                                       w-relato.cdrefere = aux_cdrefere
                                       w-relato.vlparcns = 
                                       (DECI(SUBSTR(aux_setlinha,53,15)) / 100)
                                       w-relato.dtdebito = aux_dtrefere
                                       w-relato.cdcritic = 0
                                       w-relato.dscritic = ""
                                       w-relato.nmempres = aux_nmempres
                                       w-relato.tpdebito = aux_tpdebito
                                       w-relato.cdagenci = tt-crapass.cdagenci.
                            END.
    
                        ASSIGN aux_vllanaut = SUBSTR(aux_setlinha,53,15)                                
                               aux_cdseqtel = SUBSTR(aux_setlinha,70,60).
    
                        CREATE craplau.
                        ASSIGN craplau.cdcooper = glb_cdcooper
                               craplau.dtmvtopg = verificaUltDia(glb_cdcooper, aux_dtrefere)
                               craplau.cdagenci = craplot.cdagenci 
                               craplau.cdbccxlt = craplot.cdbccxlt
                               craplau.cdbccxpg = craplot.cdbccxpg
                               craplau.cdhistor = aux_cdhistor
                               craplau.dtmvtolt = craplot.dtmvtolt
                               craplau.insitlau = 1
                               craplau.nrdconta = aux_nrdconta
                               craplau.nrdctabb = aux_nrdconta
                               craplau.nrdolote = craplot.nrdolote
                               craplau.nrseqdig = craplot.nrseqdig + 1
                               craplau.tpdvalor = 1
                               craplau.vllanaut = (DECI(aux_vllanaut) / 100)
                               craplau.nrdocmto = DECI(aux_cdrefere)                               
                               craplau.cdseqtel = aux_cdseqtel
                               craplau.cdempres = aux_cdempres
                               craplau.dscedent = aux_nmempres 
                               craplau.dttransa = glb_dtmvtolt
                               craplau.hrtransa = TIME.
                        VALIDATE craplau.
    
                        ASSIGN craplot.nrseqdig = craplot.nrseqdig + 1
                               craplot.qtcompln = craplot.qtcompln + 1
                               craplot.qtinfoln = craplot.qtinfoln + 1
                               craplot.vlcompdb = craplot.vlcompdb + 
                                                  craplau.vllanaut
                               craplot.vlcompcr = 0
                               craplot.vlinfodb = craplot.vlcompdb
                               craplot.vlinfocr = 0.
                        
                        /* Validar valor maior que o limite parametrizado*/
                        IF crapatr.flgmaxdb AND 
                           craplau.vllanaut > crapatr.vlrmaxdb THEN  
                          DO:   
                              
                              /* Notificar cooperado que fatura excede limite */
                              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                              RUN STORED-PROCEDURE pc_notif_cooperado_DEBAUT
                                  aux_handproc = PROC-HANDLE NO-ERROR
                                   (INPUT 967                /* pr_cdcritic */
                                   ,INPUT glb_cdcooper       /* pr_cdcooper */
                                   ,INPUT crapcop.nmrescop   /* pr_nmrescop */
                                   ,INPUT glb_cdprogra       /* pr_cdprogra */
                                   ,INPUT craplau.nrdconta   /* pr_nrdconta */
                                   ,INPUT craplau.nrdocmto   /* pr_nrdocmto */
                                   ,INPUT aux_nmempres       /* pr_nmconven */
                                   ,INPUT craplau.dtmvtopg   /* pr_dtmvtopg */
                                   ,INPUT craplau.vllanaut   /* pr_vllanaut */
                                   ,INPUT crapatr.vlrmaxdb   /* pr_vlrmaxdb */
                                   ,INPUT crapatr.cdrefere   /* pr_cdrefere */
                                   ,INPUT crapatr.cdhistor   /* pr_cdhistor */
                                   ,INPUT 0                  /* pr_tpdnotif 0-Todos */
								   ,INPUT 0              /* pr_flfechar_lote*/
                                   ,INPUT-OUTPUT aux_nrdolote_sms).                       
                              
                              CLOSE STORED-PROC pc_notif_cooperado_DEBAUT
                                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                            
                              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                             
                              ASSIGN aux_nrdolote_sms = 0
                                     aux_nrdolote_sms = pc_notif_cooperado_DEBAUT.pr_idlote_sms
                                                        WHEN pc_notif_cooperado_DEBAUT.pr_idlote_sms <> ?.                               
                          END.
                        
                    END.
                ELSE /* CANCELAMENTO */
                    DO:
                        
                        FIND craplau WHERE 
                             craplau.cdcooper = glb_cdcooper       AND
                             craplau.dtmvtopg = aux_dtrefere       AND
                             craplau.nrdconta = aux_nrdconta       AND
                             craplau.nrdocmto = DECI(aux_cdrefere) AND
                             craplau.insitlau = 1
                             EXCLUSIVE-LOCK NO-ERROR.
                            
                        IF  AVAIL craplau THEN
                            DO:
                               ASSIGN craplau.dtdebito = glb_dtmvtolt
                                      craplau.insitlau = 3
                                      glb_cdcritic = 739.
                                           
                               CREATE crapndb.
                               ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                                      crapndb.nrdconta = aux_nrdconta
                                      crapndb.cdhistor = aux_cdhistor
                                      crapndb.flgproce = FALSE
                                      crapndb.dstexarq = "F" +
                                              SUBSTR(aux_setlinha,2,66)   + 
                                              "99"                        +
                                              SUBSTR(aux_setlinha,70,60)  +
                                              FILL(" ",16)                +
                                              SUBSTR(aux_setlinha,140,2)  +
                                              SUBSTR(aux_setlinha,148,10) +
                                              SUBSTR(aux_setlinha,158,1)  +
                                              FILL(" ", 2)
                                      crapndb.cdcooper = glb_cdcooper.
                               VALIDATE crapndb.

                               glb_cdcritic = 739.
                               RUN fontes/critic.p.

                               CREATE w-relato.
                               ASSIGN w-relato.cdcooper = glb_cdcooper
                                      w-relato.nrdconta = aux_nrdconta
                                      w-relato.nrctacns = 
                                      DEC(SUBSTR(aux_setlinha,31,14))
                                      w-relato.cdrefere = aux_cdrefere
                                      w-relato.vlparcns = 
                                      (DEC(SUBSTR(aux_setlinha,53,15)) / 100)
                                      w-relato.dtdebito = aux_dtrefere
                                      w-relato.cdcritic = glb_cdcritic
                                      w-relato.dscritic = glb_dscritic
                                      w-relato.nmempres = aux_nmempres
                                      w-relato.tpdebito = aux_tpdebito
                                      w-relato.cdagenci = tt-crapass.cdagenci.

                            END.
                        ELSE
                            DO:
                                CREATE crapndb.
                                ASSIGN crapndb.dtmvtolt = verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                                       crapndb.nrdconta = aux_nrdconta
                                       crapndb.cdhistor = aux_cdhistor
                                       crapndb.flgproce = FALSE
                                       crapndb.dstexarq = "F" +
                                               SUBSTR(aux_setlinha,2,66)   + 
                                               "97"                        +
                                               SUBSTR(aux_setlinha,70,60)  +
                                               FILL(" ",16)                +
                                               SUBSTR(aux_setlinha,140,2)  +
                                               SUBSTR(aux_setlinha,148,10) +
                                               SUBSTR(aux_setlinha,158,1)  +
                                               FILL(" ", 2) 
                                       crapndb.cdcooper = glb_cdcooper. 
                                VALIDATE crapndb.

                                glb_cdcritic = 501.
                                RUN fontes/critic.p.

                                CREATE w-relato.
                                ASSIGN w-relato.cdcooper = glb_cdcooper
                                       w-relato.nrdconta = aux_nrdconta
                                       w-relato.nrctacns = 
                                       DEC(SUBSTR(aux_setlinha,31,14))
                                       w-relato.cdrefere = aux_cdrefere
                                       w-relato.vlparcns = 
                                       (DEC(SUBSTR(aux_setlinha,53,15)) / 100)
                                       w-relato.dtdebito = aux_dtrefere
                                       w-relato.cdcritic = glb_cdcritic
                                       w-relato.dscritic = glb_dscritic
                                       w-relato.nmempres = aux_nmempres
                                       w-relato.tpdebito = aux_tpdebito
                                       w-relato.cdagenci = tt-crapass.cdagenci.
                                
                            END.
                    END.
                NEXT TRANS_1.
            END. /* Fim do registro "E" */
        ELSE
        IF  aux_tpregist = "C" THEN
            DO:
                CREATE w-relato.
                ASSIGN w-relato.cdcooper = glb_cdcooper
                       w-relato.nrdconta = aux_nrdconta
                       w-relato.nrctacns = DECI(SUBSTR(aux_setlinha,31,14))
                       w-relato.cdrefere = aux_cdrefere
                       w-relato.vlparcns = 0
                       w-relato.dtdebito = ?
                       w-relato.cdcritic = 0
                       w-relato.nmempres = aux_nmempres
                       w-relato.tpdebito = aux_tpdebito
                       w-relato.dscritic = SUBSTR(aux_setlinha,45,40)
                       w-relato.cdagenci = tt-crapass.cdagenci.
                      
                IF  AVAILABLE crapatr THEN
                    IF  SUBSTR(aux_setlinha,158,1) <> "1"   THEN
                        ASSIGN crapatr.dtfimatr = crapatr.dtiniatr. 

                NEXT TRANS_1.
            END. /* Fim do registro "C" */
        ELSE
        IF  aux_tpregist = "D" THEN
            DO:
                CREATE w-relato.
                ASSIGN w-relato.cdcooper = glb_cdcooper
                       w-relato.nrdconta = aux_nrdconta
                       w-relato.nrctacns = DEC(SUBSTR(aux_setlinha,31,14))
                       w-relato.cdrefere = SUBSTR(aux_setlinha,45,25)
                       w-relato.vlparcns = 0
                       w-relato.dtdebito = ?
                       w-relato.cdcritic = 0
                       w-relato.nmempres = aux_nmempres
                       w-relato.tpdebito = aux_tpdebito
                       w-relato.dscritic = SUBSTR(aux_setlinha,70,60)
                       w-relato.cdagenci = tt-crapass.cdagenci.

                IF  TRIM(SUBSTR(aux_setlinha,148,10)) <> "J5" THEN 
                    DO:
                       IF  INT(SUBSTR(aux_setlinha,158,1)) = 1 THEN
                           DO:
                               IF  crapatr.dtfimatr = ? THEN
                                   ASSIGN crapatr.dtfimatr = glb_dtmvtolt.
                           END.
                       ELSE
                       IF  INT(SUBSTR(aux_setlinha,158,1)) = 0 THEN
                           DO  WHILE TRUE:
                               FIND crabatr WHERE
                                    crabatr.cdcooper = glb_cdcooper AND
                                    crabatr.nrdconta = aux_nrdconta AND
                                    crabatr.cdhistor = 1019 AND
                                    crabatr.cdrefere = DEC(SUBSTR(aux_setlinha,
                                                                  45,25))
                                    EXCLUSIVE-LOCK NO-ERROR.
                               
                               IF  AVAIL crabatr   THEN
                                   crabatr.dtfimatr = ?. /* Tira canc. */
                               ELSE
                               IF  LOCKED crabatr  THEN
                                   DO:
                                      PAUSE 2 NO-MESSAGE.
                                      NEXT.
                                   END.
                               ELSE /* Nao existe registro anterior */
                               DO:
                                   CREATE crabatr.
                                   ASSIGN crabatr.nrdconta = crapatr.nrdconta
                                          crabatr.cdrefere = 
                                                DEC(SUBSTR(aux_setlinha,45,25))
                                          crabatr.cddddtel = 0
                                          crabatr.cdhistor = aux_cdhistor
                                          crabatr.ddvencto = crapatr.ddvencto
                                          crabatr.dtiniatr = crapatr.dtiniatr
                                          crabatr.dtultdeb = ?
                                          crabatr.nmfatura = crapatr.nmfatura
                                          crabatr.dtfimatr = crapatr.dtfimatr
                                          crabatr.cdcooper = glb_cdcooper.
                                   VALIDATE crabatr.
                               
                               END.
                               
                               ASSIGN crapatr.dtfimatr = glb_dtmvtolt.
                               
                               /* Verifica se existe lancamento automatico para
                                   a fatura e atualiza o numero */
                               FOR EACH craplau 
                                   WHERE craplau.cdcooper = glb_cdcooper     AND
                                         craplau.nrdconta = crapatr.nrdconta AND
                                         craplau.dtmvtolt >= glb_dtmvtolt    AND
                                         craplau.nrdocmto  = DEC(SUBSTR(aux_setlinha,2,25)) AND
                                         craplau.insitlau  = 1               AND
                                         craplau.dsorigem <> "INTERNET"      AND
                                         craplau.dsorigem <> "TAA"           AND
                                         craplau.dsorigem <> "PG555"         AND
                                         craplau.dsorigem <> "CARTAOBB"      AND
                                         craplau.dsorigem <> "BLOQJUD"       AND
                                         craplau.dsorigem <> "DAUT BANCOOB"
                                         EXCLUSIVE-LOCK:
                               
                                    ASSIGN craplau.nrdocmto = 
                                           DEC(SUBSTR(aux_setlinha,45,25)).
                              END.

                              LEAVE.
                           END.  /* Fim while true */
                    END.
                NEXT TRANS_1.
            END. /* Fim do registro "D" */

        /* Critica de lancamento ja existente */
        IF  aux_flgdupli THEN
            DO: 
               ASSIGN aux_nmarquiv = "recebe/" + aux_nmarqmov +
                                     ".FUT".
               glb_cdcritic = 740.
               RUN fontes/critic.p.
               UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                          " - " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '" +
                          glb_dscritic + "' --> '" +  aux_nmarquiv +
                          " >> log/proc_message.log").               
            END. 

        FIND FIRST w-relato WHERE w-relato.dscritic <> "" NO-LOCK NO-ERROR.

        IF  AVAIL w-relato THEN
            ASSIGN aux_geraerro = TRUE.

        /* se nao houver erro importa arquivo e exibe critica 190 */
        IF  NOT aux_geraerro THEN
            DO: 
               aux_nmarquiv = "/usr/connect/sicredi/recebidos/" + aux_nmarqmov +
                              ".FUT".
               UNIX SILENT VALUE("rm " + tab_nmquoter[i] + " 2> /dev/null").
               UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " " + aux_nmarquiv).

               glb_cdcritic = 190. /* arquivo intgrado com sucesso */
               RUN fontes/critic.p.
               UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") +
                                " - " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '"   +
                                glb_dscritic + " " + "recebe/"     + 
                                aux_nmarqmov + ".FUT >> log/proc_message.log").
               INPUT STREAM str_2 CLOSE.
               
            END.
        ELSE /* se houver erro importa arquivo e exibe critica 191 */
        IF  aux_geraerro THEN
            DO:               
               aux_nmarquiv = "/usr/connect/sicredi/recebidos/" + aux_nmarqmov +
                              ".FUT".
               UNIX SILENT VALUE("rm " + tab_nmquoter[i] + " 2> /dev/null").
               UNIX SILENT VALUE("mv " + tab_nmarquiv[i] + " " + aux_nmarquiv).

               glb_cdcritic = 191. /* arquivo intgrado com rejeitados */
               RUN fontes/critic.p.
               UNIX SILENT VALUE("echo " + STRING(TODAY,"99/99/9999") + 
                                " - " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '"   +
                                glb_dscritic + " " + "recebe/"     + 
                                aux_nmarqmov + ".FUT >> log/proc_message.log").
               INPUT STREAM str_2 CLOSE.
                
            END.

        LEAVE TRANS_1.
    END. /* Fim do TRANS_1 */
    
    INPUT STREAM str_2 CLOSE.

    LEAVE.
END.

IF aux_nrdolote_sms > 0 THEN
DO:
  /* encerrar lote de SMS */
  { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
  RUN STORED-PROCEDURE pc_conclui_lote_sms
      aux_handproc = PROC-HANDLE NO-ERROR
                 (INPUT aux_nrdolote_sms  /* pr_idlote_sms */
                 ,OUTPUT "" ).            /* pr_dscritic */
                                         

  CLOSE STORED-PROC pc_conclui_lote_sms
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

  ASSIGN aux_dscritic = ""
         aux_dscritic = pc_conclui_lote_sms.pr_dscritic
                            WHEN pc_conclui_lote_sms.pr_dscritic <> ?.  

END.
/* Concatenar o nome do arquivo com o .FUT para gerar nos relatorios */
ASSIGN aux_nmarqmov = aux_nmarqmov + ".FUT".

FIND FIRST w-relato WHERE w-relato.tpdebito = 1  NO-LOCK NO-ERROR.

IF  AVAIL w-relato THEN 
    RUN rel_661. /* Consorcios */ 

FIND FIRST w-relato WHERE w-relato.tpdebito = 2 NO-LOCK NO-ERROR.

IF  AVAIL w-relato THEN
    RUN rel_673. /* Importacao de debitos */        

RUN fontes/fimprg.p.

PROCEDURE rel_661:
    
    /* inicia variaveis dos totais como zero */
    ASSIGN aux_flgfirst = TRUE
           tot_qtdrejei = 0
           tot_vlpareje = 0
           tot_qtdreceb = 0
           tot_vlparceb = 0
           tot_qtdinteg = 0
           tot_vlpainte = 0.
    
    ASSIGN glb_cdrelato[1] = 661.
           
    { includes/cabrel132_1.i }
    
    ASSIGN aux_nmarqimp = "rl/crrl661.lst".
    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_1 FRAME f_cabrel132_1.
    
    /* IMPRESSAO DO RELATORIO crrl661 */
    FOR EACH w-relato NO-LOCK WHERE w-relato.tpdebito = 1
                      BREAK BY w-relato.cdcritic
                            BY w-relato.nrdconta
                            BY w-relato.nrctacns:
    
        IF  aux_flgfirst OR LINE-COUNTER(str_1) > 77 THEN
            DO: 
                DISPLAY STREAM str_1 aux_nmarqmov
                                     WITH FRAME f_cab.
                
                DOWN STREAM str_1 WITH FRAME f_cab.
                
                aux_flgfirst = FALSE.
            END. 
            
        /* recebidos */
        ASSIGN tot_qtdreceb = tot_qtdreceb + 1
               tot_vlparceb = tot_vlparceb + w-relato.vlparcns.

        /* rejeitados / nao considera a critica 739 pois e de cancelamento 
           de debitos */
        IF  w-relato.cdcritic <> 0 AND  
            w-relato.cdcritic <> 739 THEN 
            ASSIGN tot_qtdrejei = tot_qtdrejei + 1
                   tot_vlpareje = tot_vlpareje + w-relato.vlparcns.
        
        /* Integrados */
        IF  LAST-OF(w-relato.nrctacns) THEN
            ASSIGN tot_qtdinteg = tot_qtdreceb - tot_qtdrejei
                   tot_vlpainte = tot_vlparceb - tot_vlpareje.
        
        DISPLAY STREAM str_1 w-relato.nrdconta 
                             w-relato.nrctacns
                             w-relato.cdrefere
                             w-relato.vlparcns
                             w-relato.dtdebito 
                             w-relato.dscritic
                WITH FRAME f_lanctos_661.
    
        DOWN STREAM str_1 WITH FRAME f_lanctos_661.
    
    END. /*** fim for each w-relato ***/
    
    IF  LINE-COUNTER(str_1) > 77 THEN
        DO:
            PAGE STREAM str_1.
           
            DISPLAY STREAM str_1 aux_nmarqmov
                                 WITH FRAME f_cab.

            DOWN STREAM str_1 WITH FRAME f_cab.
        END.
    
    FIND FIRST w-relato WHERE w-relato.tpdebito = 1 
                        NO-LOCK NO-ERROR.

    /* Total geral do relatorio crrl661 */
    IF  AVAIL w-relato THEN
        PUT STREAM str_1  UNFORMATTED 
                         SKIP(2)
                         "RECEBIDOS"  AT 28
                         "INTEGRADOS" AT 43
                         "REJEITADOS" AT 59
                         SKIP
                         "QTD. DEBITOS:" AT 7
                         tot_qtdreceb  FORMAT "zzz,zz9" AT 30
                         tot_qtdinteg  FORMAT "zzz,zz9" AT 46
                         tot_qtdrejei  FORMAT "zzz,zz9" AT 62
                         SKIP
                         "TOTAL DEBITOS:" AT 6
                         tot_vlparceb  FORMAT "zzz,zzz,zz9.99" AT 23
                         tot_vlpainte  FORMAT "zzz,zzz,zz9.99" AT 39
                         tot_vlpareje  FORMAT "zzz,zzz,zz9.99" AT 55.
       
    OUTPUT STREAM str_1 CLOSE.
    
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqimp.
               
    RUN fontes/imprim_unif.p (INPUT glb_cdcooper). 
    
END.

PROCEDURE rel_673:

    /* inicia variaveis dos totais como zero */
    ASSIGN aux_flgfirst = TRUE
           tot_qtdrejei = 0
           tot_vlpareje = 0
           tot_qtdreceb = 0
           tot_vlparceb = 0
           tot_qtdinteg = 0
           tot_vlpainte = 0.
    
    ASSIGN glb_cdrelato[4] = 673.

    { includes/cabrel132_4.i }
    
    ASSIGN aux_nmarqimp = "rl/crrl673.lst".
    
    OUTPUT STREAM str_4 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    VIEW STREAM str_4 FRAME f_cabrel132_4.
    
    /* IMPRESSAO DO RELATORIO crrl673 */
    FOR EACH w-relato NO-LOCK WHERE w-relato.tpdebito = 2
                      BREAK BY w-relato.cdcritic
                            BY w-relato.cdagenci
                            BY w-relato.nrdconta
                            BY w-relato.nrctacns:
    
        IF  aux_flgfirst OR LINE-COUNTER(str_4) > 77 THEN
            DO: 
                DISPLAY STREAM str_4 aux_nmarqmov
                                     WITH FRAME f_cab.
                
                DOWN STREAM str_4 WITH FRAME f_cab.
                
                aux_flgfirst = FALSE.
            END. 
            
        /* recebidos */
        ASSIGN tot_qtdreceb = tot_qtdreceb + 1
               tot_vlparceb = tot_vlparceb + w-relato.vlparcns.

        /* rejeitados / nao considera a critica 739 pois e de cancelamento 
           de debitos */
        IF  w-relato.cdcritic <> 0 AND  
            w-relato.cdcritic <> 739 THEN 
            ASSIGN tot_qtdrejei = tot_qtdrejei + 1
                   tot_vlpareje = tot_vlpareje + w-relato.vlparcns.
        
        /* Integrados */
        IF  LAST-OF(w-relato.nrctacns) THEN
            ASSIGN tot_qtdinteg = tot_qtdreceb - tot_qtdrejei
                   tot_vlpainte = tot_vlparceb - tot_vlpareje.
        
        DISPLAY STREAM str_4 w-relato.cdagenci
                             w-relato.nrdconta 
                             w-relato.nrctacns
                             w-relato.nmempres
                             w-relato.cdrefere
                             w-relato.vlparcns
                             w-relato.dtdebito 
                             w-relato.dscritic
                WITH FRAME f_lanctos_673.
    
        DOWN STREAM str_4 WITH FRAME f_lanctos_673.
    
    END. /*** fim for each w-relato ***/
    
    IF  LINE-COUNTER(str_4) > 77 THEN
        DO:
            PAGE STREAM str_4.
            
            DISPLAY STREAM str_4 aux_nmarqmov
                                 WITH FRAME f_cab.

            DOWN STREAM str_4 WITH FRAME f_cab.
        END.
    
    FIND FIRST w-relato WHERE w-relato.tpdebito = 2 NO-LOCK NO-ERROR.

    /* Total geral do relatorio crrl673 */
    IF  AVAIL w-relato THEN
        PUT STREAM str_4  UNFORMATTED 
                         SKIP(2)
                         "RECEBIDOS"  AT 28
                         "INTEGRADOS" AT 43
                         "REJEITADOS" AT 59
                         SKIP
                         "QTD. DEBITOS:" AT 7
                         tot_qtdreceb  FORMAT "zzz,zz9" AT 30
                         tot_qtdinteg  FORMAT "zzz,zz9" AT 46
                         tot_qtdrejei  FORMAT "zzz,zz9" AT 62
                         SKIP
                         "TOTAL DEBITOS:" AT 6
                         tot_vlparceb  FORMAT "zzz,zzz,zz9.99" AT 23
                         tot_vlpainte  FORMAT "zzz,zzz,zz9.99" AT 39
                         tot_vlpareje  FORMAT "zzz,zzz,zz9.99" AT 55.
       
    OUTPUT STREAM str_4 CLOSE.
    
    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqimp.
               
    RUN fontes/imprim_unif.p (INPUT glb_cdcooper).

END.
