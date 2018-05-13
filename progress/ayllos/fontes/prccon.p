/* ............................................................................

   Programa: fontes/prccon.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Fevereiro/2013                   Ultima alteracao: 17/12/2013
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar rotinas de Convenio - SICREDI.
               Chamado Softdesk 43660.
   
   Alteracoes: 29/05/2013 - Solicitação para crps637 alterada para 92 (Lucas).
   
               10/12/2013 - Incluir script login_cifs_mount.sh (Lucas R.)
               
               17/12/2013 - Inclusao de VALIDATE crapsol (Carlos)
                            
............................................................................ */

{ sistema/generico/includes/var_internet.i } 
{ includes/var_online.i }

DEF STREAM str_1.

DEF VAR tel_pesquisa AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR tel_cddopcao AS CHAR        FORMAT "!(1)"                      NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nomedarq AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR        FORMAT "!"                         NO-UNDO.
DEF VAR aux_tamarqui AS CHAR                                           NO-UNDO.
DEF VAR tel_datadlog AS DATE        FORMAT "99/99/9999"                NO-UNDO.

/* variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR        FORMAT "x(8)" INIT "Imprimir"      NO-UNDO.
DEF VAR tel_dscancel AS CHAR        FORMAT "x(8)" INIT "Cancelar"      NO-UNDO.
DEF VAR aux_nmendter AS CHAR        FORMAT "x(20)"                     NO-UNDO.
DEF VAR par_flgrodar AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                              NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                        NO-UNDO.
DEF VAR aux_contador AS INT         INIT 0                             NO-UNDO.

FORM tel_datadlog    AT 10 LABEL "Data Log"
                           HELP "Informe a data para visualizar LOG"
     tel_pesquisa    AT 32 LABEL "Pesquisar"
                           HELP "Informe texto a pesquisar (espaco em branco, tudo)."
                           WITH ROW 6 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon_l.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao    AT 03 LABEL "Opcao" AUTO-RETURN
                           HELP  "Informe a opcao desejada (I, E ou L)."
                           VALIDATE(CAN-DO("L,I,E",glb_cddopcao), "014 - Opcao errada.")
                           WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_prccon.

ASSIGN glb_cddopcao = "I"
       glb_cdcritic = 0.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

prccon:
DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF  glb_cdcritic > 0   THEN 
            DO:
                RUN fontes/critic.p.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                PAUSE 2 NO-MESSAGE.
            END.

        UPDATE glb_cddopcao WITH FRAME f_prccon.

        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN 
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "PRCCON"  THEN
                DO:
                    HIDE FRAME f_prccon.
                    HIDE FRAME f_moldura.
                    HIDE MESSAGE NO-PAUSE.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.
    
    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

    /* Executar script de login das cifs */
    UNIX SILENT VALUE ("/usr/local/cecred/bin/login_cifs_mount.sh").

    HIDE MESSAGE NO-PAUSE.
         
    IF  glb_cddopcao = "I"   THEN
        DO:
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "Importar os arquivos do Sicredi?",
                                   OUTPUT aux_confirma).
                    
            IF  aux_confirma <> "S" THEN 
                NEXT.

            MESSAGE "Realizando importacao dos arquivos...".

            /* Cria solicitação */
            DO TRANSACTION:
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = glb_cdcooper   AND 
                           crapsol.nrsolici = 92             AND
                           crapsol.dtrefere = glb_dtmvtolt   
                           NO-LOCK NO-ERROR.
                           
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.

                CREATE crapsol. 
                ASSIGN crapsol.nrsolici = 92
                       crapsol.dtrefere = glb_dtmvtolt
                       crapsol.nrseqsol = 1
                       crapsol.cdempres = 11
                       crapsol.dsparame = ""
                       crapsol.insitsol = 1
                       crapsol.nrdevias = 0
                       crapsol.cdcooper = glb_cdcooper.
                VALIDATE crapsol.
            END.
            
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")        + 
                               " - "   + STRING(TIME,"HH:MM:SS")           +
                               " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                               "Iniciada execucao manual da importacao."   +
                               " >> log/prccon.log").

            /* Executa programa de importação dos arquivos */
            RUN fontes/crps637.p.

            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                               " - "   + STRING(TIME,"HH:MM:SS")           +
                               " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                               "Finalizada execucao manual da importacao." +
                               " >> log/prccon.log").

            DO TRANSACTION:
                /* Limpa solicitacao se existente */
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = glb_cdcooper   AND 
                           crapsol.nrsolici = 92             AND
                           crapsol.dtrefere = glb_dtmvtolt   
                           NO-LOCK NO-ERROR.
                           
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.

            END. /* Fim TRANSACTION */

            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Importacao finalizada!".
            
        END.

    IF  glb_cddopcao = "E"   THEN
        DO:
            ASSIGN aux_confirma = "N".
            RUN fontes/confirma.p (INPUT  "Exportar os arquivos do Sicredi?",
                                   OUTPUT aux_confirma).

            IF  aux_confirma <> "S" THEN 
                NEXT.

            MESSAGE "Realizando exportacao dos arquivos...".

            /* Cria solicitação */
            DO TRANSACTION:
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = glb_cdcooper   AND 
                           crapsol.nrsolici = 89             AND
                           crapsol.dtrefere = glb_dtmvtolt   
                           NO-LOCK NO-ERROR.
                           
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.
        
                CREATE crapsol. 
                ASSIGN crapsol.nrsolici = 89
                       crapsol.dtrefere = glb_dtmvtolt
                       crapsol.nrseqsol = 1
                       crapsol.cdempres = 11
                       crapsol.dsparame = ""
                       crapsol.insitsol = 1
                       crapsol.nrdevias = 0
                       crapsol.cdcooper = glb_cdcooper.
                VALIDATE crapsol.
            END.
        
            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                               " - "   + STRING(TIME,"HH:MM:SS")           +
                               " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                               "Iniciada execucao manual da exportacao."   +
                               " >> log/prccon.log").

            /* Executa programa de exportação dos arquivos */
            RUN fontes/crps636.p.

            UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") + 
                               " - "   + STRING(TIME,"HH:MM:SS")           +
                               " - "   + CAPS(glb_cdprogra) + "'  --> '"   +
                               "Finalizada execucao manual da exportacao." +
                               " >> log/prccon.log").

            DO TRANSACTION:
                /* Limpa solicitacao se existente */
                FIND FIRST crapsol WHERE 
                           crapsol.cdcooper = glb_cdcooper   AND 
                           crapsol.nrsolici = 89             AND
                           crapsol.dtrefere = glb_dtmvtolt   
                           NO-LOCK NO-ERROR.
                           
                IF  AVAILABLE crapsol  THEN
                     DO:
                         FIND CURRENT crapsol EXCLUSIVE-LOCK.
                         DELETE crapsol.
                     END.

            END. /* Fim TRANSACTION */

            HIDE MESSAGE NO-PAUSE.
            MESSAGE "Exportacao finalizada!".

        END.

    IF  glb_cddopcao = "L"   THEN
        DO:
            ASSIGN tel_pesquisa = ""
                   aux_nomedarq = ""
                   tel_datadlog = glb_dtmvtolt.

            DO WHILE TRUE ON ENDKEY UNDO, NEXT prccon:

                UPDATE tel_datadlog tel_pesquisa WITH FRAME f_prccon_l.
                LEAVE.

            END.

            HIDE tel_datadlog tel_pesquisa IN FRAME f_prccon_l.

            ASSIGN aux_nmarqimp = "/usr/coop/cecred/log/prccon.log".

            IF  SEARCH(aux_nmarqimp) = ? THEN
                DO:
                    MESSAGE "NAO HA REGISTRO DE LOG PARA ESTA DATA!".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.

            /* nome do arquivo temporário */
            ASSIGN aux_nomedarq = "log/tmp_ged_" + STRING(TIME).

            IF  tel_datadlog <> ?  THEN
                UNIX SILENT VALUE('grep -i "' + STRING(tel_datadlog,"99/99/9999") + '" ' + aux_nmarqimp + ' | grep -i "' + tel_pesquisa + '" ' +
                                  ' >> '   + aux_nomedarq + ' 2> /dev/null').
            ELSE
                UNIX SILENT VALUE('grep -i "' + tel_pesquisa + '" ' + aux_nmarqimp +
                                  ' >> '   + aux_nomedarq + ' 2> /dev/null').

            ASSIGN aux_nmarqimp = aux_nomedarq.

            /* Verifica se o arquivo esta vazio e critica */
            INPUT STREAM str_1 THROUGH VALUE("wc -m " +
                                             aux_nmarqimp + " 2> /dev/null") 
                                             NO-ECHO.
            
            SET STREAM str_1 aux_tamarqui FORMAT "x(30)".
            
            IF  INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0 THEN
                DO:
                    MESSAGE "Nenhuma ocorrencia encontrada.".
                    INPUT STREAM str_1 CLOSE.
                    NEXT.
                END.

            /* inicializa com opção T(Terminal) */
            ASSIGN tel_cddopcao = "T".
           
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.
                LEAVE.

            END.
           
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                NEXT.
           
            IF  tel_cddopcao = "T" THEN
                RUN fontes/visrel.p (INPUT aux_nmarqimp).
            ELSE
                IF  tel_cddopcao = "I" THEN
                    DO:
                        /* somente para o includes/impressao.i */
                        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                                 NO-LOCK NO-ERROR.
           
                        { includes/impressao.i }
                    END.
                ELSE
                    DO:
                        ASSIGN glb_cdcritic = 14.
                        RUN fontes/critic.p.
                        MESSAGE glb_dscritic.
                        ASSIGN glb_cdcritic = 0.
                        NEXT.
                    END.
           
            /* apaga arquivo temporario */
            IF aux_nomedarq <> "" THEN
                UNIX SILENT VALUE ("rm " + aux_nomedarq + " 2> /dev/null").
                            
        END.
END.
