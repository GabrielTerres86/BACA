/* .............................................................................

   Programa: Fontes/lancstl.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Reinert
   Data    : Abril/2014.                         Ultima atualizacao: 27/04/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LANCSTL - Lote de Arquivo de Cheques.

   Alteracoes: 19/05/2015 - Alterar buscas da craphcc e crapdcc para listar os
                            cheques com intipmvt 1 (Remessa) e 3 (Manual)
                          - Adicionado opção de desconciliar o cheque
                            (Douglas - Melhoria 060 - Custódia de Cheque)
                           
              25/06/2015 - Alterado a impressão do relatorio para exibir
                           CHEQUES DA COOPERATIVA. (Douglas - Chamado 301154)
   
              27/11/2015 - Alterado o ponto onde era usado RM com basename da
                           sessao do usuario para excluir o arquivo que imprimi
                           protocolo de custodia (Tiago/Elton SD360770).

              11/02/2016 - Novas validacoes SD385085 (Tiago/Elton).

              27/04/2015 - Alterado para exibir separadamente os cheques de 
                           intipmvt 1 e 3 (Arquivo e Manual) 
                           (Douglas - Chamado 441428)
............................................................................. */   

{ includes/var_online.i }
{ includes/var_lancst.i }
{ includes/proc_lancst.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_ttchqarq AS INTE                                            NO-UNDO.
DEF VAR aux_ttconarq AS INTE                                            NO-UNDO.
DEF VAR aux_dtinicst AS DATE                                            NO-UNDO.
DEF VAR aux_dsdocmc7 AS CHAR FORMAT "x(34)"                             NO-UNDO.
DEF VAR aux_linhbrws AS INTE INIT 1                                     NO-UNDO.
DEF VAR aux_linmaxbs AS INTE INIT 1                                     NO-UNDO.
DEF VAR aux_flgenccq AS LOGI INIT FALSE                                 NO-UNDO.
DEF VAR aux_flgbuscq AS LOGI INIT FALSE                                 NO-UNDO.
DEF VAR aux_stimeout AS INTE                                            NO-UNDO.
DEF VAR aux_linhform AS CHAR                                            NO-UNDO.
DEF VAR aux_linhfrm2 AS CHAR                                            NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                            NO-UNDO.
DEF VAR aux_stsnrcal AS LOGI                                            NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                            NO-UNDO.
DEF VAR aux_vlcheque LIKE crapdcc.vlcheque                              NO-UNDO.
DEF VAR aux_nrseqarq AS INTE INIT 1                                     NO-UNDO.

DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                            NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                          NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5                 NO-UNDO.

DEF VAR rel_nrmodulo AS INT     FORMAT "9"                              NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]                 NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                            NO-UNDO.

DEF VAR aux_vltotchq AS DECI                                            NO-UNDO.
DEF VAR tel_cddopcao AS CHAR    FORMAT "!(1)"                           NO-UNDO.

DEF VAR par_flgrodar AS LOGICAL INIT TRUE                               NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                         NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                            NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL INIT TRUE                               NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"           NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"           NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                         NO-UNDO.

DEF VAR aux_flgcqcon AS LOGI                                            NO-UNDO.
DEF VAR aux_flgocorr AS LOGI                                            NO-UNDO.
DEF VAR aux_qtdocorr AS INTE                                            NO-UNDO.

DEF STREAM str_1.

DEF TEMP-TABLE tt-arquivo NO-UNDO
    FIELD cdcooper LIKE craphcc.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD dtmvtolt AS DATE FORMAT "99/99/99"
    FIELD nmarquiv AS CHAR FORMAT "x(26)"
    FIELD qttotcnc AS CHAR FORMAT "x(9)"
    FIELD insithcc AS CHAR FORMAT "x(5)"
    FIELD dtcustod AS DATE FORMAT "99/99/99"
    FIELD nrconven LIKE craphcc.nrconven
    FIELD nrremret LIKE craphcc.nrremret
    FIELD intipmvt LIKE craphcc.intipmvt
    FIELD vltotchq AS DECI FORMAT "zzz,zzz,zz9.99".

DEF TEMP-TABLE tt-cheque NO-UNDO
    FIELD cdcooper LIKE crapdcc.cdcooper
    FIELD cdcmpchq LIKE crapdcc.cdcmpchq
    FIELD cdbanchq LIKE crapdcc.cdbanchq
    FIELD cdagechq LIKE crapdcc.cdagechq
    FIELD nrctachq LIKE crapdcc.nrctachq
    FIELD nrcheque LIKE crapdcc.nrcheque
    FIELD vlcheque LIKE crapdcc.vlcheque
    FIELD inconcil AS CHAR FORMAT "X"
    FIELD dtlibera LIKE crapdcc.dtlibera
    FIELD nrseqarq LIKE crapdcc.nrseqarq
    FIELD cdagenci LIKE crapdcc.cdagenci
    FIELD cdbccxlt LIKE crapdcc.cdbccxlt
    FIELD nrdolote LIKE crapdcc.nrdolote                                        
    FIELD nrinsemi AS CHAR
    FIELD nrddigc1 AS INTE FORMAT "9"
    FIELD nrddigc2 AS INTE FORMAT "9"
    FIELD nrddigc3 AS INTE FORMAT "9"
    FIELD dsdocmc7 LIKE crapdcc.dsdocmc7
    FIELD nrdconta LIKE crapdcc.nrdconta
    FIELD nrconven LIKE crapdcc.nrconven
    FIELD nrremret LIKE crapdcc.nrremret
    FIELD intipmvt LIKE crapdcc.intipmvt
    FIELD dtdcaptu LIKE crapdcc.dtdcaptu
    FIELD dsusoemp LIKE crapdcc.dsusoemp
    FIELD cdtipmvt LIKE crapdcc.cdtipmvt
    FIELD dstipmvt AS CHAR
    FIELD cdocorre LIKE crapdcc.cdocorre
    FIELD dsocorre AS CHAR
    FIELD nmcheque LIKE crapcec.nmcheque.

DEF QUERY q_cheque FOR tt-cheque.

DEF QUERY q_arquivo FOR tt-arquivo.
    
DEF BROWSE b_arquivo QUERY q_arquivo
    DISPLAY tt-arquivo.nrdconta COLUMN-LABEL "Conta/DV"
            tt-arquivo.dtmvtolt COLUMN-LABEL "Data"
            /*tt-arquivo.nmarquiv COLUMN-LABEL "Arquivo"*/
            tt-arquivo.nrremret COLUMN-LABEL "Remessa" format "zzzzzzzz9"
            tt-arquivo.vltotchq COLUMN-LABEL "Vlr Total"                       
            tt-arquivo.qttotcnc COLUMN-LABEL "Cheques"            
            tt-arquivo.insithcc COLUMN-LABEL "Status"
            tt-arquivo.dtcustod COLUMN-LABEL "Custodia"
            WITH NO-BOX 8 DOWN WIDTH 74.

DEF BROWSE b_cheque QUERY q_cheque
    DISPLAY tt-cheque.cdcmpchq COLUMN-LABEL "Comp"
            tt-cheque.cdbanchq COLUMN-LABEL "Bco"
            tt-cheque.cdagechq COLUMN-LABEL "Ag."
            tt-cheque.nrddigc1 COLUMN-LABEL "C1"
            tt-cheque.nrctachq COLUMN-LABEL "Conta"
            tt-cheque.nrddigc2 COLUMN-LABEL "C2"
            tt-cheque.nrcheque COLUMN-LABEL "Cheque"
            tt-cheque.nrddigc3 COLUMN-LABEL "C3"
            tt-cheque.vlcheque COLUMN-LABEL "Valor"
            tt-cheque.inconcil COLUMN-LABEL "C"
            tt-cheque.cdocorre COLUMN-LABEL "Ocorre" 
            WITH 9 DOWN WIDTH 76 NO-BOX.
 
FORM 
    b_arquivo HELP "<ENTER>Conciliar   <T>Conc. Todos   <F1>Custodiar   <P>Imprimir"
    WITH ROW 10 COLUMN 3 WIDTH 76 OVERLAY NO-BOX  
    FRAME f_custod.

FORM
    tt-arquivo.nrdconta  LABEL "Conta/DV"                AT 2
    tt-arquivo.nmarquiv  LABEL "Arquivo"                 AT 23
    tt-arquivo.insithcc  LABEL "Status"                  AT 60
    SKIP(1)
    aux_dsdocmc7         LABEL "Conciliar Cheque CMC7"   
                         AUTO-RETURN                     AT 2
    HELP "<ENTER> Digitar CMC-7, <D> Visualizar, <X> Desconciliar"
    SKIP(1)
    
    WITH ROW 6 COLUMN 2 WIDTH 76 OVERLAY SIDE-LABEL NO-BOX
    FRAME f_chequeh.

FORM
    b_cheque    
    WITH ROW 10 COLUMN 2 WIDTH 76 OVERLAY SIDE-LABEL NO-BOX
    FRAME f_chequeb.

FORM
    "Comp  Bco   Ag. C1            Conta C2  Cheque C3"         AT 1
    "      Valor      Seq. C"
    SKIP
    tt-cheque.cdcmpchq  NO-LABEL
    tt-cheque.cdbanchq  NO-LABEL
    tt-cheque.cdagechq  NO-LABEL
    SPACE(2)
    tt-cheque.nrddigc1  NO-LABEL
    tt-cheque.nrctachq  NO-LABEL
    SPACE(2)
    tt-cheque.nrddigc2  NO-LABEL
    tt-cheque.nrcheque  NO-LABEL
    SPACE(2)
    tt-cheque.nrddigc3  NO-LABEL
    tt-cheque.vlcheque  NO-LABEL
    tt-cheque.nrseqarq  NO-LABEL
    tt-cheque.inconcil  NO-LABEL
    SKIP
    aux_linhform NO-LABEL FORMAT "x(74)"                        
    SKIP
    tt-arquivo.dtmvtolt FORMAT "99/99/9999" LABEL "Data Movto"  
    tt-cheque.cdagenci  FORMAT "zz9"        LABEL "PA"          AT 31
    tt-cheque.cdbccxlt                      LABEL "Banco/Caixa" AT 41
    tt-cheque.nrdolote                      LABEL "Lote"        AT 59
    SKIP
    tt-cheque.nrinsemi FORMAT "x(18)"       LABEL "CPF/CNPJ"    
    tt-cheque.dtdcaptu FORMAT "99/99/99"    LABEL "Captura"     AT 55
    SKIP
    tt-cheque.nmcheque                      LABEL "Emitente"    
    tt-cheque.dtlibera FORMAT "99/99/99"    LABEL "Liberacao"   AT 53
    SKIP
    tt-cheque.dsdocmc7                      LABEL "CMC-7"       
    aux_vlcheque                            LABEL "Valor"       AT 51
    SKIP
    tt-cheque.dsusoemp                      LABEL "Seu Numero"
    SKIP
    aux_linhfrm2 NO-LABEL FORMAT "x(74)"                        
    SKIP
    tt-cheque.cdtipmvt                      LABEL "Cod. Movto"    
    tt-cheque.dstipmvt FORMAT "x(50)"       NO-LABEL
    SKIP
    tt-cheque.cdocorre                      LABEL "Ocorrencia"
    tt-cheque.dsocorre FORMAT "x(50)"       NO-LABEL
    WITH ROW 9 COLUMN 3 WIDTH 76 OVERLAY SIDE-LABEL 
    TITLE "Detalhes do cheque"
    FRAME f_desc_cheque.

FORM     
    aux_linhform NO-LABEL FORMAT "x(78)"                AT 1       
    SKIP(1)
    crapass.nrdconta       LABEL "CONTA/DV"             AT 1
    "-"
    crapass.nmprimtl       NO-LABEL                     AT 24    
    SKIP(1)
    craplot.dtmvtolt       LABEL "DATA    "             AT 1
    craplot.cdagenci       LABEL "PA"                   AT 24 
    craplot.cdbccxlt       LABEL "BANCO/CAIXA"          AT 40 
    craplot.nrdolote       LABEL "LOTE"                 AT 66 
    SKIP(2)
    craplot.qtinfocc       LABEL "CHEQUES DA COOPERATIVA" AT 1
    craplot.vlinfocc       NO-LABEL                     AT 32 
    craphcc.nrremret       LABEL "REMESSA"              AT 63
    SKIP(1)
    craplot.qtinfoci       LABEL "CHEQUES MENORES       " AT 1
    craplot.vlinfoci       NO-LABEL                     AT 32 
    SKIP(1)
    craplot.qtinfocs       LABEL "CHEQUES MAIORES       " AT 1
    craplot.vlinfocs       NO-LABEL                     AT 32 
    SKIP(3)
    craplot.qtinfoln       LABEL "TOTAL                 " AT 1  
    craplot.vlinfocr       NO-LABEL                     AT 28
    craplot.dtmvtopg       LABEL "DATA DE LIBERACAO"    AT 50
    SKIP(3)
    "CONCILIADO POR  : __________________________"      AT 1
    "EM: _____ / _____ / ________"                      AT 50
    SKIP(2)
    "CUSTODIADO POR  : __________________________"      AT 1
    "EM: _____ / _____ / ________"                      AT 50
    SKIP(2)
    "DIGITALIZADO POR: __________________________"      AT 1
    "EM: _____ / _____ / ________"                      AT 50
    SKIP(2)
    aux_linhfrm2 NO-LABEL FORMAT "x(78)"
    WITH NO-BOX WIDTH 80 SIDE-LABEL FRAME f_imp_custod.
     
ASSIGN glb_cdempres    = 11
       glb_cdrelato[1] = 680
       glb_nmdestin[1] = "FINANCEIRO".       

{ includes/cabrel080_1.i }

DISPLAY glb_cddopcao WITH FRAME f_lancstl.

ASSIGN tel_insithcc:LIST-ITEM-PAIRS = "TODOS,0,PENDENTE,1,PROCESSADO,2"
       aux_linhform = FILL("-",78).

ON  RETURN OF tel_insithcc   IN FRAME f_lancstl
    DO:
        tel_insithcc = tel_insithcc:SCREEN-VALUE.        
        APPLY "GO".
    END.

ON T,t OF b_arquivo IN FRAME f_custod DO:
    /* Se temp-table possui registros */
    IF  TEMP-TABLE tt-arquivo:HAS-RECORDS THEN
        DO: /* Se Status do arquivo for pendente */
            IF  tt-arquivo.insithcc = "Pend." THEN
                DO:                    
                    
                    RUN Confirma(INPUT "Deseja marcar todos os cheques como conciliado? S/N").

                    IF  aux_confirma = "N" OR RETURN-VALUE = "NOK" THEN
                        LEAVE.

                    /* Zera contador de cheques com ocorrencias */
                    ASSIGN aux_qtdocorr = 0.
                    MESSAGE "Processando...".
                    FOR EACH crapdcc WHERE crapdcc.cdcooper = tt-arquivo.cdcooper
                                       AND crapdcc.nrdconta = tt-arquivo.nrdconta
                                       AND crapdcc.nrremret = tt-arquivo.nrremret
                                       AND crapdcc.nrconven = tt-arquivo.nrconven
                                       AND crapdcc.inconcil = 0
                                       AND crapdcc.intipmvt = tt-arquivo.intipmvt
                                       NO-LOCK:
                        
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_conciliar_cheque_arquivo 
                            aux_handproc = PROC-HANDLE NO-ERROR
                                             (INPUT crapdcc.cdcooper,    /* Cooperativa         */
                                              INPUT crapdcc.nrdconta,    /* Nr. da conta        */
                                              INPUT crapdcc.nrremret,    /* Nr. remessa/retorno */
                                              INPUT crapdcc.dsdocmc7,    /* CMC-7               */
                                              INPUT crapdcc.nrseqarq,    /* Nr. Sequencial      */
                                              INPUT crapdcc.intipmvt,    /* Tipo de Movimento (1-Arquivo/3-Manual)*/
                                              INPUT 1,                   /* OK ou Conciliado    */
                                              INPUT glb_dtmvtolt,        /* Data atual          */
                                              OUTPUT 0,                  /* Cd. erro            */
                                              OUTPUT "").                /* Desc. erro          */
                     
                        CLOSE STORED-PROC pc_conciliar_cheque_arquivo 
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                     
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = ""
                               aux_cdcritic = pc_conciliar_cheque_arquivo.pr_cdcritic 
                                              WHEN pc_conciliar_cheque_arquivo.pr_cdcritic <> ?
                               aux_dscritic = pc_conciliar_cheque_arquivo.pr_dscritic 
                                              WHEN pc_conciliar_cheque_arquivo.pr_dscritic <> ?.

                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                        /* Se retornou critica da procedure */
                        IF  aux_cdcritic <> 0   OR
                            aux_dscritic <> ""  THEN
                            ASSIGN aux_qtdocorr = aux_qtdocorr + 1.
                        ELSE
                            /* Se nao retornou critica, cheque foi conciliado */                                                
                            /* Atualiza campo de cheque conciliados no arquivo ("0000 + 1 /9999") */
                            ASSIGN tt-arquivo.qttotcnc = STRING(INTE(SUBSTR(tt-arquivo.qttotcnc, 1, 4)) + 1, "9999") + "/" + 
                                                         SUBSTR(tt-arquivo.qttotcnc, 6, 4).                                                                                                            

                    END.
                    HIDE MESSAGE NO-PAUSE.
                    /* Atualiza browse */                        
                    b_arquivo:REFRESH().

                    IF  aux_qtdocorr <= 0 THEN
                        DO:
                            BELL.
                            MESSAGE "Cheques conciliados com sucesso".
                            PAUSE 2 NO-MESSAGE.
                        END.
                    ELSE
                        DO:
                            BELL.
                            MESSAGE "Existe(m) " + STRING(aux_qtdocorr) + " cheque(s) com ocorrência(s)".
                            PAUSE 2 NO-MESSAGE.
                        END.

                END.
            ELSE
                DO:
                    BELL.
                    MESSAGE "Remessa ja foi processada".                                    
                    PAUSE 2 NO-MESSAGE.
                END.                                                            
        END.
    ELSE
        DO:
            BELL.
            MESSAGE "Nao ha arquivo a ser conciliado".
            PAUSE 2 NO-MESSAGE.
        END.
END.

ON P,p OF b_arquivo IN FRAME f_custod DO:
    /* Se temp-table possui registros */
    IF  TEMP-TABLE tt-arquivo:HAS-RECORDS THEN
        DO: /* Se Status do arquivo for processado */                               
            IF  tt-arquivo.insithcc = "Proc." THEN
                DO: /* Se remessa possuir um ou mais cheques custodiados */
                    IF  INTE(SUBSTR(tt-arquivo.qttotcnc, 1, 4)) > 0 THEN
                        DO:
                            /* Imprime protocolo de custodia */
                            RUN imprime_protocolo(INPUT tt-arquivo.cdcooper
                                                 ,INPUT tt-arquivo.nrdconta
                                                 ,INPUT tt-arquivo.nrconven                                                        
                                                 ,INPUT tt-arquivo.nrremret
                                                 ,INPUT tt-arquivo.dtcustod
                                                 ,INPUT tt-arquivo.nmarquiv).
                        END.
                    ELSE
                        DO:
                            BELL.
                            MESSAGE "Remessa nao possui cheques custodiados".
                            PAUSE 2 NO-MESSAGE.
                        END.
                END.
            ELSE
                DO:
                    BELL.
                    MESSAGE "Remessa ainda nao foi processada para impressao".
                    PAUSE 2 NO-MESSAGE.
                END.                            
        END.
END.

ON F1 OF b_arquivo IN FRAME f_custod DO:    

    IF  TEMP-TABLE tt-arquivo:HAS-RECORDS THEN
        DO: /* Se Status do arquivo for pendente */                               
            IF  tt-arquivo.insithcc = "Pend." THEN                            
                DO:                                 
                    RUN verifica_cheques_conciliados(INPUT tt-arquivo.cdcooper
                                                    ,INPUT tt-arquivo.nrdconta
                                                    ,INPUT tt-arquivo.nrconven                                                        
                                                    ,INPUT tt-arquivo.nrremret
                                                    ,OUTPUT aux_flgcqcon
                                                    ,OUTPUT aux_flgocorr).
                    IF  aux_flgcqcon THEN
                        DO:
                            RUN Confirma(INPUT "Existem cheques nao conciliados. Deseja continuar? S/N").
                            IF  aux_confirma = "N" OR RETURN-VALUE = "NOK" THEN
                                LEAVE.
                        END.
                    IF  aux_flgocorr THEN
                        DO:
                            RUN Confirma(INPUT "Existem cheques com ocorrencias. Deseja continuar? S/N").
                            /* Se apertou end/f4 ao confirmar */
                            IF  RETURN-VALUE = "NOK" THEN
                                LEAVE.
                            IF  aux_confirma = "S" THEN
                                DO:
                                    RUN Confirma(INPUT "Esta operacao ira custodiar esta remessa. Deseja continuar? S/N").
                                    IF  aux_confirma = "N" OR RETURN-VALUE = "NOK" THEN
                                        LEAVE.
                                END.
                            ELSE
                                LEAVE.
                        END.
                    ELSE
                        DO:
                            RUN Confirma(INPUT "Deseja custodiar esta remessa? S/N").
                            IF  aux_confirma = "N" OR RETURN-VALUE = "NOK" THEN
                                LEAVE.
                        END.

                    /* pc_custodiar_cheques
                      (pr_cdcooper IN crapcop.cdcooper%TYPE -- Código da cooperativa
                      ,pr_nrdconta IN crapass.nrdconta%TYPE -- Numero Conta do cooperado 
                      ,pr_nrconven IN crapccc.nrconven%TYPE -- Numero do Convenio
                      ,pr_nrremret IN craphcc.nrremret%TYPE -- Numero Remessa/Retorno
                      ,pr_intipmvt IN craphcc.intipmvt%TYPE -- Tipo de Movimento (1-Arquivo/3-Manual)
                      ,pr_dtmvtolt IN DATE -- Data do Movimento
                      ,pr_idorigem IN INTEGER -- Origem (1-Ayllos, 3-Internet, 7-FTP)
                      ,pr_cdoperad IN crapope.cdoperad%TYPE -- Codigo Operador
                      ,pr_cdcritic OUT INTEGER -- Código do erro
                      ,pr_dscritic OUT VARCHAR2) IS -- Descricao do erro */                                    
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                    RUN STORED-PROCEDURE pc_custodiar_cheques
                        aux_handproc = PROC-HANDLE NO-ERROR
                                         (INPUT glb_cdcooper,           /* Cooperativa */
                                          INPUT tt-arquivo.nrdconta,    /* Nr. da conta */
                                          INPUT tt-arquivo.nrconven,    /* Convenio */
                                          INPUT tt-arquivo.nrremret,    /* Nr. remessa/retorno */
                                          INPUT tt-arquivo.intipmvt,    /* Tipo de Movimento (1-Arquivo/3-Manual)*/
                                          INPUT glb_dtmvtolt,           /* Data atual */
                                          INPUT 1,                      /* Origem (1-Ayllos, 3-Internet, 7-FTP)*/
                                          INPUT glb_cdoperad,           /* Cd. operador */
                                          OUTPUT 0,                     /* Cd. critica */
                                          OUTPUT "").                   /* Desc. critica */

                    CLOSE STORED-PROC pc_custodiar_cheques
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           aux_cdcritic = pc_custodiar_cheques.pr_cdcritic 
                                          WHEN pc_custodiar_cheques.pr_cdcritic <> ?
                           aux_dscritic = pc_custodiar_cheques.pr_dscritic 
                                          WHEN pc_custodiar_cheques.pr_dscritic <> ?.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    IF  aux_cdcritic <> 0   OR
                        aux_dscritic <> ""  THEN
                        DO:
                            BELL.
                            MESSAGE aux_dscritic.
                            PAUSE 2 NO-MESSAGE.
                        END.
                    ELSE
                        DO:
                            BELL.
                            MESSAGE "Arquivo processado".                                            
                            RUN atualiza_custodia (INPUT tt-arquivo.cdcooper
                                                  ,INPUT tt-arquivo.nrdconta
                                                  ,INPUT tt-arquivo.nrremret
                                                  ,INPUT tt-arquivo.nrconven
                                                  ,INPUT tt-arquivo.intipmvt).                                            
                        END.                                    

                    IF  tt-arquivo.insithcc = "Proc."               AND 
                        INTE(SUBSTR(tt-arquivo.qttotcnc, 1, 4)) > 0 THEN 
                        DO:
                            RUN imprime_protocolo(INPUT tt-arquivo.cdcooper
                                                 ,INPUT tt-arquivo.nrdconta
                                                 ,INPUT tt-arquivo.nrconven                                                        
                                                 ,INPUT tt-arquivo.nrremret
                                                 ,INPUT tt-arquivo.dtcustod
                                                 ,INPUT tt-arquivo.nmarquiv).

                            RUN gerar_previa (INPUT tt-arquivo.cdcooper
                                             ,INPUT tt-arquivo.nrdconta
                                             ,INPUT tt-arquivo.nrconven
                                             ,INPUT tt-arquivo.nrremret).

                            IF  RETURN-VALUE = "NOK" THEN 
                                DO:
                                    BELL.
                                    MESSAGE "Erro ao gerar previa. Favor utilizar tela COMPEL"
                                        VIEW-AS ALERT-BOX.
                                END.
                        END.
                    ELSE
                        DO:
                            BELL.
                            MESSAGE "Remessa ainda nao foi processada para impressao".
                            PAUSE 2 NO-MESSAGE.
                        END.
                END.
            ELSE
                DO:
                    BELL.
                    MESSAGE "Remessa ja foi processada".                                    
                    PAUSE 2 NO-MESSAGE.
                END.                                                            
        END.
    ELSE
        DO:
            BELL.
            MESSAGE "Nao ha arquivo a ser custodiado".
            PAUSE 2 NO-MESSAGE.
        END.
    
END.

/* A cada linha mostrada no browse de cheques */
ON ROW-DISPLAY OF b_cheque IN FRAME f_chequeb DO:          
   /* Procura cheque da linha */
   FIND CURRENT tt-cheque NO-LOCK NO-ERROR.
   
   /* Variavel possuira a ultima linha mostrada no browse de cheques */
   ASSIGN aux_linmaxbs = CURRENT-RESULT-ROW("q_cheque").

   /* Se cheque da linha for igual ao de entrada do usuario */
   IF   tt-cheque.dsdocmc7 = aux_dsdocmc7   AND 
        (aux_cdcritic = 0 OR aux_dscritic = "") THEN
               /* Armazaena posicao da linha em que foi 
                  encontrada o cheque */
       ASSIGN aux_linhbrws = CURRENT-RESULT-ROW("q_cheque")                            
              aux_flgenccq = TRUE.     /* Encontrou cheque */

END.

/* Se precionar seta para cima */
ON CURSOR-UP OF aux_dsdocmc7 IN FRAME f_chequeh DO:

    IF  aux_linhbrws > 1 THEN
        DO:
            /* Decrementa posicao da linha selecionada no browse de cheques */
            ASSIGN aux_linhbrws = aux_linhbrws - 1.
            /* Reposiciona linha para cima */
            REPOSITION q_cheque TO ROW aux_linhbrws.
        END.

END.

/* Se precionar seta para baixo */
ON CURSOR-DOWN OF aux_dsdocmc7 IN FRAME f_chequeh DO:

    IF aux_linhbrws < NUM-RESULTS("q_cheque") THEN
        DO:
            /* Incrementa posicao da linha selecionada no browse de cheques */
            ASSIGN aux_linhbrws = aux_linhbrws + 1.
            /* Reposiciona linha para baixo */
            REPOSITION q_cheque TO ROW aux_linhbrws.
        END.

END.

/* Ao precionar enter no arquivo selecionado */
ON ENTER OF b_arquivo IN FRAME f_custod DO:

    ASSIGN aux_linmaxbs = 1.           

    /* Se possuir algum arquivo */
    IF  TEMP-TABLE tt-arquivo:HAS-RECORDS THEN
        DO:            

            EMPTY TEMP-TABLE tt-cheque. 

            FOR EACH crapdcc FIELDS (cdcmpchq cdbanchq cdagechq nrctachq 
                                     nrcheque vlcheque dtlibera nrseqarq
                                     cdagenci cdbccxlt nrdolote nrinsemi
                                     dsdocmc7 inconcil nrdconta nrconven
                                     nrremret cdcooper intipmvt dtdcaptu
                                     dsusoemp cdtipmvt cdocorre cdtipemi)
                             WHERE crapdcc.cdcooper = tt-arquivo.cdcooper AND
                                   crapdcc.nrdconta = tt-arquivo.nrdconta AND
                                   crapdcc.nrconven = tt-arquivo.nrconven AND
                                   crapdcc.nrremret = tt-arquivo.nrremret AND
                                   crapdcc.intipmvt = tt-arquivo.intipmvt
                                   NO-LOCK:                        
        
                /* Alimenta cmc7 para buscar digito na procedure mostra_dados */
                ASSIGN tel_dsdocmc7 = crapdcc.dsdocmc7.
                /* Retorna numero de digito (C1, C2, C3) */
                RUN mostra_dados.
        
                CREATE tt-cheque.
                ASSIGN tt-cheque.cdcooper = crapdcc.cdcooper
                       tt-cheque.cdcmpchq = crapdcc.cdcmpchq
                       tt-cheque.cdbanchq = crapdcc.cdbanchq
                       tt-cheque.cdagechq = crapdcc.cdagechq
                       tt-cheque.nrddigc1 = tel_nrddigc1
                       tt-cheque.nrctachq = crapdcc.nrctachq 
                       tt-cheque.nrddigc2 = tel_nrddigc2
                       tt-cheque.nrcheque = crapdcc.nrcheque
                       tt-cheque.nrddigc3 = tel_nrddigc3
                       tt-cheque.vlcheque = crapdcc.vlcheque
                       tt-cheque.dtlibera = crapdcc.dtlibera
                       tt-cheque.nrseqarq = crapdcc.nrseqarq
                       tt-cheque.cdagenci = crapdcc.cdagenci
                       tt-cheque.cdbccxlt = crapdcc.cdbccxlt
                       tt-cheque.nrdolote = crapdcc.nrdolote
                       tt-cheque.dsdocmc7 = crapdcc.dsdocmc7
                       tt-cheque.nrdconta = crapdcc.nrdconta
                       tt-cheque.nrconven = crapdcc.nrconven
                       tt-cheque.nrremret = crapdcc.nrremret
                       tt-cheque.intipmvt = crapdcc.intipmvt
                       tt-cheque.dtdcaptu = crapdcc.dtdcaptu
                       tt-cheque.dsusoemp = crapdcc.dsusoemp
                       tt-cheque.cdtipmvt = crapdcc.cdtipmvt                   
                       tt-cheque.cdocorre = crapdcc.cdocorre                    
                       tt-cheque.inconcil = IF crapdcc.inconcil = 1 THEN "X" ELSE ""
                       tel_dsdocmc7 = "".                               
                      
                /* Tipo de pessoa do emissor */
                IF  crapdcc.cdtipemi <> 0 THEN
                    ASSIGN tt-cheque.nrinsemi = IF  crapdcc.cdtipemi = 1 THEN 
                                                    STRING(STRING(crapdcc.nrinsemi, "99999999999"),"xxx.xxx.xxx-xx")
                                                ELSE
                                                    STRING(STRING(crapdcc.nrinsemi, "99999999999999"),"xx.xxx.xxx/xxxx-xx").            
                /* Nome do emissor */
                FOR FIRST crapcec FIELDS (cdcooper nrcpfcgc nmcheque)
                                  WHERE crapcec.cdcooper = crapdcc.cdcooper AND
                                        crapcec.nrcpfcgc = crapdcc.nrinsemi
                                  NO-LOCK:
                    ASSIGN tt-cheque.nmcheque = crapcec.nmcheque.
                END.
                IF  NOT AVAIL crapcec THEN
                    ASSIGN tt-cheque.nmcheque = "NAO CADASTRADO".
        
                /* Descricao do movimento */
                FOR FIRST crapocc FIELDS (cdocorre cdtipmvt dsocorre)
                                  WHERE crapocc.cdtipmvt = crapdcc.cdtipmvt AND
                                        crapocc.cdocorre = '00'
                                  NO-LOCK:
                    ASSIGN tt-cheque.dstipmvt = "- " + crapocc.dsocorre.
                END.
                /* Descricao da ocorrencia */
                FOR FIRST crapocc FIELDS (cdocorre cdtipmvt dsocorre intipmvt)
                                  WHERE crapocc.cdtipmvt = 21               AND
                                        crapocc.intipmvt = 2                AND
                                        crapocc.cdocorre = crapdcc.cdocorre
                                  NO-LOCK:
                    ASSIGN tt-cheque.dsocorre = "- " + crapocc.dsocorre.
                END.            
        
            END. /* Fim - FOR EACH crapdcc */

            DISPLAY tt-arquivo.nrdconta
                    tt-arquivo.nmarquiv
                    tt-arquivo.insithcc
                    WITH FRAME f_chequeh.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN aux_linhbrws = 1.

                IF  glb_cdcritic > 0 OR glb_dscritic <> "" THEN
                    DO:
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.

                        ASSIGN glb_cdcritic = 0
                               glb_dscritic = "".
                    END.

                /* Para cada cheque do arquivo selecionado */                
                OPEN QUERY q_cheque FOR EACH tt-cheque                                    
                                       WHERE tt-cheque.nrdconta = tt-arquivo.nrdconta 
                                         AND tt-cheque.nrconven = tt-arquivo.nrconven
                                         AND tt-cheque.nrremret = tt-arquivo.nrremret
                                     NO-LOCK.
        
                ENABLE b_cheque WITH FRAME f_chequeb.

                REPOSITION q_cheque TO ROW aux_linhbrws.
                
                IF aux_flgbuscq THEN
                    /* Procura cmc7 no browse */
                    DO WHILE TRUE:
                        /* Se encontrou cheque */
                        IF  aux_flgenccq THEN
                            DO:
                                /* Reposiciona cursor para linha do cheque encontrado */
                                REPOSITION q_cheque TO ROW aux_linhbrws.
                                ASSIGN aux_flgbuscq = FALSE.
                                /* Ao encontrar cheque, sair da busca */
                                LEAVE.
                            END.
                        ELSE
                            DO:                                                                                                                        
                                /* Se nao chegou no fim do browse */
                                IF  NUM-RESULTS("q_cheque") <> CURRENT-RESULT-ROW("q_cheque") THEN 
                                    DO:                                                      
                                        /* Reposiciona cursor para ultima linha 
                                           do display do browse */
                                        REPOSITION q_cheque TO ROW aux_linmaxbs.                                    
                                    END.
                                ELSE
                                    DO:
                                        BELL.
                                        MESSAGE "Cheque nao encontrado".
                                        REPOSITION q_cheque TO ROW aux_linhbrws.
                                        ASSIGN aux_flgbuscq = FALSE
                                               aux_dsdocmc7 = "".
                                        /* Se nao encontrar cheque, 
                                           sai da busca no browse */
                                        LEAVE.
                                    END.
                            END.
                    END.

                /* 
                CUST0001.pc_conciliar_cheque_arquivo (pr_cdcooper      IN crapcop.cdcooper%TYPE  -- Código da cooperativa
                                                     ,pr_nrdconta      IN crapass.nrdconta%TYPE  -- Numero Conta do cooperado    
                                                     ,pr_nrremret      IN craphcc.nrremret%TYPE  -- Numero Remessa/Retorno
                                                     ,pr_dsdocmc7      IN crapdcc.dsdocmc7%TYPE  -- CMC7
                                                     ,pr_nrseqarq      IN crapdcc.nrseqarq%TYPE  -- Numero Sequencial
                                                     ,pr_inconcil      IN crapdcc.inconcil%TYPE  -- Indicador de conciliar (0-Pendente, 1-OK, 2-Sem físico)
                                                     ,pr_dtmvtolt      IN crapass.dtmvtolt%TYPE  -- Data atual
                                                     ,pr_cdcritic     OUT INTEGER                -- Código do erro
                                                     ,pr_dscritic     OUT VARCHAR2) IS           -- Descricao do erro                               
                */           
                /* Se encontrou cheque */
                IF  aux_flgenccq THEN
                    DO:
                        /* Se arquivo estiver pendente*/
                        IF  tt-arquivo.insithcc = "Pend." THEN
                            DO:
                                IF  tt-cheque.inconcil <> "X" THEN
                                    DO:
                                    
                                        DO TRANSACTION:
                                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
             
                
                                        RUN STORED-PROCEDURE pc_conciliar_cheque_arquivo 
                                            aux_handproc = PROC-HANDLE NO-ERROR
                                                             (INPUT tt-cheque.cdcooper,  /* Cooperativa         */
                                                              INPUT tt-cheque.nrdconta,  /* Nr. da conta        */
                                                              INPUT tt-cheque.nrremret,  /* Nr. remessa/retorno */
                                                              INPUT aux_dsdocmc7,        /* CMC-7               */
                                                              INPUT tt-cheque.nrseqarq,  /* Nr. Sequencial      */
                                                              INPUT tt-cheque.intipmvt,  /* Tipo de Movimento (1-Arquivo/3-Manual)*/
                                                              INPUT 1,                   /* OK ou Conciliado    */
                                                              INPUT glb_dtmvtolt,        /* Data atual          */
                                                              OUTPUT 0,                  /* Cd. erro            */
                                                              OUTPUT "").                /* Desc. erro          */
                                     
                                        CLOSE STORED-PROC pc_conciliar_cheque_arquivo 
                                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
                                     
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = ""
                                               aux_cdcritic = pc_conciliar_cheque_arquivo.pr_cdcritic 
                                                              WHEN pc_conciliar_cheque_arquivo.pr_cdcritic <> ?
                                               aux_dscritic = pc_conciliar_cheque_arquivo.pr_dscritic 
                                                              WHEN pc_conciliar_cheque_arquivo.pr_dscritic <> ?.                                                                          
                
                                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                                        
                                        /* Atualiza tt-cheque */
                                        RUN atualiza_conciliacao (INPUT tt-cheque.cdcooper
                                                                 ,INPUT tt-cheque.nrdconta
                                                                 ,INPUT tt-cheque.nrremret
                                                                 ,INPUT tt-cheque.nrseqarq
                                                                 ,INPUT tt-cheque.nrconven
                                                                 ,INPUT tt-cheque.intipmvt).                                
                                        /* Se retornou critica da procedure */
                                        IF  aux_cdcritic <> 0   OR
                                            aux_dscritic <> ""  THEN
                                            DO:
                                                BELL.
                                                MESSAGE aux_dscritic.
                                            END.
                                        ELSE
                                            DO: /* Se nao retornou critica, cheque foi conciliado */                                                
                                                /* Atualiza campo de cheque conciliados no arquivo ("0000 + 1 /9999") */
                                                ASSIGN tt-arquivo.qttotcnc = STRING(INTE(SUBSTR(tt-arquivo.qttotcnc, 1, 4)) + 1, "9999") + "/" + 
                                                                             SUBSTR(tt-arquivo.qttotcnc, 6, 4).                                                
                                                BELL.
                                                MESSAGE "Cheque conciliado com sucesso".                                                
                                            END.
                                        
                                        /* Atualiza browse */                        
                                        b_cheque:REFRESH().
                
                                        END. /* Fim da transacao */
                
                
                                        ASSIGN aux_flgenccq = FALSE
                                               aux_dsdocmc7 = "".        /* Zera variavel de entrada do cheque */
                                    END.
                                ELSE
                                    DO:
                                        BELL.
                                        MESSAGE "Cheque ja foi conciliado".
                                        ASSIGN aux_dsdocmc7 = ""
                                               aux_flgenccq = FALSE.
                                    END.
                            END.
                        ELSE
                            DO:
                                BELL.
                                MESSAGE "Arquivo ja foi processado".
                                ASSIGN aux_dsdocmc7 = ""
                                       aux_flgenccq = FALSE.
                            END.
                    END.
                            

                /* Entrada do cmc7 do cheque */
                UPDATE aux_dsdocmc7 WITH FRAME f_chequeh
                    
                EDITING:
                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        READKEY.
                        PAUSE 0 NO-MESSAGE.
                        /* Se pressionar "d" mostrar descricao do cheque */
                        IF  LASTKEY = KEYCODE("d") OR 
                            LASTKEY = KEYCODE("D") THEN
                            DO:                                
                                DISPLAY tt-cheque.cdcmpchq
                                        tt-cheque.cdbanchq
                                        tt-cheque.cdagechq
                                        tt-cheque.nrddigc1
                                        tt-cheque.nrctachq
                                        tt-cheque.nrddigc2
                                        tt-cheque.nrcheque
                                        tt-cheque.nrddigc3
                                        tt-cheque.vlcheque
                                        tt-cheque.nrseqarq
                                        tt-cheque.inconcil
                                        aux_linhform
                                        tt-arquivo.dtmvtolt
                                        tt-cheque.cdagenci
                                        tt-cheque.cdbccxlt
                                        tt-cheque.nrdolote
                                        tt-cheque.nrinsemi
                                        tt-cheque.dtdcaptu 
                                        tt-cheque.nmcheque
                                        tt-cheque.dtlibera
                                        tt-cheque.dsdocmc7
                                        tt-cheque.vlcheque @ aux_vlcheque
                                        tt-cheque.dsusoemp
                                        aux_linhform @ aux_linhfrm2
                                        tt-cheque.cdtipmvt
                                        tt-cheque.dstipmvt
                                        tt-cheque.cdocorre
                                        tt-cheque.dsocorre
                                        WITH FRAME f_desc_cheque.
                                    
                                HIDE FRAME f_desc_cheque.
                            END.
                        ELSE
                            DO:  
                            /* Se pressionar "x" realiza a desconciliação do cheque */
                            IF  LASTKEY = KEYCODE("x") OR 
                                LASTKEY = KEYCODE("X") THEN
                            DO:
                                /* Verificar se o cheque não está conciliado*/
                                IF tt-cheque.inconcil <> "X" THEN
                                    DO:
                                        /* Exibe mensagem informando a situacao, nao permite desconciliar */
                                        MESSAGE "Cheque nao foi conciliado".
                                    END.
                                ELSE 
                                    DO:

                                      IF  tt-arquivo.insithcc = "Proc." THEN
                                          DO:
                                            MESSAGE "Arquivo ja processado.".
                                          END.
                                      ELSE
									      DO:

											{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
											RUN STORED-PROCEDURE pc_conciliar_cheque_arquivo 
												aux_handproc = PROC-HANDLE NO-ERROR
																 (INPUT tt-cheque.cdcooper,    /* Cooperativa         */
																  INPUT tt-cheque.nrdconta,    /* Nr. da conta        */
																  INPUT tt-cheque.nrremret,    /* Nr. remessa/retorno */
																  INPUT tt-cheque.dsdocmc7,    /* CMC-7               */
																  INPUT tt-cheque.nrseqarq,    /* Nr. Sequencial      */
																  INPUT tt-cheque.intipmvt,    /* Tipo de Movimento (1-Arquivo/3-Manual)*/
																  INPUT 0,                     /* NOK ou Desconciliado    */
																  INPUT glb_dtmvtolt,          /* Data atual          */
																  OUTPUT 0,                    /* Cd. erro            */
																  OUTPUT "").                  /* Desc. erro          */
    
											CLOSE STORED-PROC pc_conciliar_cheque_arquivo 
												  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
											ASSIGN aux_cdcritic = 0
												   aux_dscritic = ""
												   aux_cdcritic = pc_conciliar_cheque_arquivo.pr_cdcritic 
																  WHEN pc_conciliar_cheque_arquivo.pr_cdcritic <> ?
												   aux_dscritic = pc_conciliar_cheque_arquivo.pr_dscritic 
																  WHEN pc_conciliar_cheque_arquivo.pr_dscritic <> ?.
    
											{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
											/* Se retornou critica da procedure */
											IF  aux_cdcritic <> 0   OR
												aux_dscritic <> ""  THEN
												DO:
													BELL.
													MESSAGE aux_dscritic.
													PAUSE 2 NO-MESSAGE.
												END.
											ELSE
												DO:

													/* Atualiza tt-cheque */
													RUN atualiza_conciliacao (INPUT tt-cheque.cdcooper
																			 ,INPUT tt-cheque.nrdconta
																			 ,INPUT tt-cheque.nrremret
																			 ,INPUT tt-cheque.nrseqarq
																			 ,INPUT tt-cheque.nrconven
																			 ,INPUT tt-cheque.intipmvt).                                
                                                
													/* Atualiza browse */                        
													b_cheque:REFRESH().

													/* Se nao retornou critica, cheque foi descconciliado */
													/* Atualiza campo de cheque conciliados no arquivo ("0000 + 1 /9999") */
													ASSIGN tt-arquivo.qttotcnc = STRING(INTE(SUBSTR(tt-arquivo.qttotcnc, 1, 4)) - 1, "9999") + "/" + 
																				 SUBSTR(tt-arquivo.qttotcnc, 6, 4).
                                                
													/* Atualiza browse */                        
													b_arquivo:REFRESH().
                                            
													BELL.
													MESSAGE "Cheque desconciliado com sucesso".
													PAUSE 2 NO-MESSAGE.
												END.
										  END.
									END. 
                                END.
                            
                            ELSE
                            
                                IF  CAN-DO("CURSOR-UP,CURSOR-DOWN,BACKSPACE",KEYLABEL(LASTKEY)) OR                          
                                    CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY)) THEN
                                    DO:
                                        IF  KEYLABEL(LASTKEY) = "G"   THEN
                                            APPLY KEYCODE(":").                          
                                        ELSE
                                            APPLY LASTKEY.
                                    END.
                                    
                            END.
                      LEAVE.

                    END. /* Fim DO WHILE TRUE */                   

                END. /* Fim EDITING */

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
                    DO:
                        HIDE FRAME f_chequeh NO-PAUSE.
                        HIDE FRAME f_chequeb NO-PAUSE.
                        b_arquivo:REFRESH().
                        LEAVE.
                    END.

                /* Se for entrada do cmc7 por leitor */
                IF  TRIM(aux_dsdocmc7) <> ""   THEN
                    DO:
                        IF   LENGTH(aux_dsdocmc7) <> 34            OR
                             SUBSTRING(aux_dsdocmc7,01,1) <> "<"   OR
                             SUBSTRING(aux_dsdocmc7,10,1) <> "<"   OR
                             SUBSTRING(aux_dsdocmc7,21,1) <> ">"   OR
                             SUBSTRING(aux_dsdocmc7,34,1) <> ":"   THEN
                             DO:
                                 glb_cdcritic = 666.
                                 NEXT.
                             END.
                
                        RUN fontes/dig_cmc7.p (INPUT  aux_dsdocmc7,
                                               OUTPUT glb_nrcalcul,
                                               OUTPUT aux_lsdigctr).
                          
                        IF   glb_nrcalcul > 0                 OR
                             NUM-ENTRIES(aux_lsdigctr) <> 3   THEN
                             DO:
                                 glb_cdcritic = 666.
                                 NEXT.
                             END.
        
                        IF   glb_cdcritic > 0   THEN
                             NEXT.
                    END.
                ELSE /* Se campo do cmc7 estiver vazio e for dado RETURN do campo do cmc7,
                        entrar com o cheque manualmente */
                    DO:
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            
                            RUN fontes/cmc7.p (OUTPUT aux_dsdocmc7).
                                
                            IF  LENGTH(aux_dsdocmc7) <> 34   THEN
                                LEAVE.
        
                            RUN fontes/dig_cmc7.p (INPUT  aux_dsdocmc7,
                                                   OUTPUT glb_nrcalcul,
                                                   OUTPUT aux_lsdigctr).
                                                       
                            IF  glb_nrcalcul > 0                 OR
                                NUM-ENTRIES(aux_lsdigctr) <> 3   THEN
                            DO:
                                glb_cdcritic = 666.
                                NEXT.
                            END.
                                  
                            IF   glb_cdcritic > 0   THEN
                                NEXT.
        
                            LEAVE.
                           
                        END.  /*  Fim do DO WHILE TRUE  */

                        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                            NEXT.
                          
                    END.
                    
                ASSIGN aux_flgbuscq = TRUE.                

            END.

            CLOSE QUERY q_cheque.
        
        END.    
END.

/* Bloco principal do programa */
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    EMPTY TEMP-TABLE tt-arquivo.
    EMPTY TEMP-TABLE tt-cheque.

    ASSIGN tel_nrddigc1 = 0
           tel_nrddigc2 = 0
           tel_nrddigc3 = 0
           tel_nrdconta = 0
           tel_nmprimtl = ""
           tel_dtinicst = ?
           tel_dtfimcst = ?
           aux_ttchqarq = 0
           aux_ttconarq = 0.

    DISPLAY tel_nrdconta
            tel_nmprimtl
            tel_dtinicst
            tel_dtfimcst            
            WITH FRAME f_lancstl.

    IF  glb_cdcritic > 0 OR glb_dscritic <> "" THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic. 
            
            ASSIGN glb_cdcritic = 0
                   glb_dscritic = "".
        END.

    UPDATE tel_nrdconta WITH FRAME f_lancstl.

    FOR FIRST crapass FIELDS(nmprimtl)
                      WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = tel_nrdconta
                      NO-LOCK:
        ASSIGN tel_nmprimtl = crapass.nmprimtl.
        DISPLAY tel_nmprimtl WITH FRAME f_lancstl.
    END.

    UPDATE  tel_dtinicst
            tel_dtfimcst
            tel_insithcc
            WITH FRAME f_lancstl.   

    FOR EACH craphcc FIELDS (cdcooper nrdconta nrconven nrremret
                             dtmvtolt nmarquiv insithcc dtcustod)
                     WHERE craphcc.cdcooper = glb_cdcooper        AND
                          (IF tel_nrdconta > 0 THEN 
                           craphcc.nrdconta = tel_nrdconta
                           ELSE TRUE)                             AND
                          (IF tel_dtinicst <> ? THEN 
                           craphcc.dtmvtolt >= tel_dtinicst
                           ELSE TRUE)                             AND 
                          (IF tel_dtfimcst <> ? THEN 
                           craphcc.dtmvtolt <= tel_dtfimcst
                           ELSE TRUE)                             AND
                          (IF INTE(tel_insithcc) > 0 THEN
                           craphcc.insithcc = INTE(tel_insithcc)
                           ELSE TRUE)                             AND
                           (craphcc.intipmvt = 1 OR craphcc.intipmvt = 3)
                           NO-LOCK:            

        /* Zera variaveis do campo Cheques */
        ASSIGN aux_ttchqarq = 0               
               aux_ttconarq = 0
               aux_vltotchq = 0.

        
        FOR EACH crapdcc FIELDS (vlcheque inconcil)
                         WHERE crapdcc.cdcooper = craphcc.cdcooper AND
                               crapdcc.nrdconta = craphcc.nrdconta AND
                               crapdcc.nrconven = craphcc.nrconven AND
                               crapdcc.nrremret = craphcc.nrremret AND
                               crapdcc.intipmvt = craphcc.intipmvt
                               NO-LOCK:            

            /* Quantidade total de cheques no arquivo */                     
            ASSIGN aux_ttchqarq = aux_ttchqarq + 1
                   aux_vltotchq = aux_vltotchq + crapdcc.vlcheque.
            IF crapdcc.inconcil = 1 THEN
               /* Quantidade de cheques conciliados no arquivo */
               ASSIGN aux_ttconarq = aux_ttconarq  + 1.

        END. /* Fim - FOR EACH crapdcc */

        CREATE tt-arquivo.
        ASSIGN tt-arquivo.cdcooper = craphcc.cdcooper
               tt-arquivo.nrdconta = craphcc.nrdconta
               tt-arquivo.dtmvtolt = craphcc.dtmvtolt
               tt-arquivo.nmarquiv = craphcc.nmarquiv
               tt-arquivo.qttotcnc = STRING(aux_ttconarq, "9999") + "/" + 
                                     STRING(aux_ttchqarq, "9999")
               tt-arquivo.insithcc = IF craphcc.insithcc = 1 THEN "Pend." ELSE "Proc."
               tt-arquivo.dtcustod = craphcc.dtcustod
               tt-arquivo.nrconven = craphcc.nrconven
               tt-arquivo.nrremret = craphcc.nrremret
               tt-arquivo.intipmvt = craphcc.intipmvt
               tt-arquivo.vltotchq = aux_vltotchq.
               
    END. /* Fim - FOR EACH craphcc */        

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        OPEN QUERY q_arquivo FOR EACH tt-arquivo NO-LOCK BY tt-arquivo.nrdconta
                                                         BY tt-arquivo.dtmvtolt
                                                         BY tt-arquivo.nrremret.

        UPDATE b_arquivo WITH FRAME f_custod.                

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            HIDE FRAME f_custod NO-PAUSE.
            VIEW FRAME f_lancstl.
            LEAVE.
        END.
                
    END. 

    CLOSE QUERY q_arquivo.
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            HIDE FRAME f_custod NO-PAUSE.
            VIEW FRAME f_lancstl.
        END.
    
END. /* Fim - DO WHILE TRUE */

PROCEDURE atualiza_custodia:

    DEF INPUT PARAM par_cdcooper LIKE craphcc.cdcooper                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE craphcc.nrdconta                    NO-UNDO.
    DEF INPUT PARAM par_nrremret LIKE craphcc.nrremret                    NO-UNDO.
    DEF INPUT PARAM par_nrconven LIKE craphcc.nrconven                    NO-UNDO.
    DEF INPUT PARAM par_intipmvt LIKE craphcc.intipmvt                    NO-UNDO.
    
    FOR FIRST craphcc FIELDS (dtcustod insithcc cdcooper nrdconta
                              nrremret nrconven intipmvt)
                      WHERE craphcc.cdcooper = par_cdcooper AND
                            craphcc.nrdconta = par_nrdconta AND
                            craphcc.nrremret = par_nrremret AND
                            craphcc.nrconven = par_nrconven AND
                            craphcc.intipmvt = par_intipmvt NO-LOCK:

        FOR EACH crapdcc FIELDS (nrdconta nrconven nrremret cdcooper 
                                 intipmvt cdtipmvt cdocorre nrseqarq)
                         WHERE crapdcc.cdcooper = craphcc.cdcooper AND
                               crapdcc.nrdconta = craphcc.nrdconta AND
                               crapdcc.nrconven = craphcc.nrconven AND
                               crapdcc.nrremret = craphcc.nrremret AND
                               crapdcc.intipmvt = craphcc.intipmvt
                               NO-LOCK:            

            FOR FIRST tt-cheque WHERE tt-cheque.cdcooper = crapdcc.cdcooper AND
                                  tt-cheque.nrdconta = crapdcc.nrdconta AND
                                  tt-cheque.nrremret = crapdcc.nrremret AND
                                  tt-cheque.nrseqarq = crapdcc.nrseqarq AND
                                  tt-cheque.nrconven = crapdcc.nrconven AND 
                                  tt-cheque.intipmvt = crapdcc.intipmvt:
                
                /* Descricao do movimento */
                FOR FIRST crapocc FIELDS (cdocorre cdtipmvt dsocorre)
                                  WHERE crapocc.cdtipmvt = crapdcc.cdtipmvt AND
                                        crapocc.cdocorre = '00'
                                  NO-LOCK:
                    ASSIGN tt-cheque.dstipmvt = "- " + crapocc.dsocorre.
                END.
                /* Descricao da ocorrencia */
                FOR FIRST crapocc FIELDS (cdocorre cdtipmvt dsocorre intipmvt)
                                  WHERE crapocc.cdtipmvt = 21               AND
                                        crapocc.intipmvt = 2                AND
                                        crapocc.cdocorre = crapdcc.cdocorre
                                  NO-LOCK:

                    ASSIGN  tt-cheque.cdocorre = crapdcc.cdocorre
                            tt-cheque.dsocorre = "- " + crapocc.dsocorre.
                END.            
            END.
        END.

        FOR FIRST tt-arquivo WHERE tt-arquivo.cdcooper = craphcc.cdcooper AND
                                   tt-arquivo.nrdconta = craphcc.nrdconta AND
                                   tt-arquivo.nrremret = craphcc.nrremret AND
                                   tt-arquivo.nrconven = craphcc.nrconven AND 
                                   tt-arquivo.intipmvt = craphcc.intipmvt:
            ASSIGN tt-arquivo.dtcustod = craphcc.dtcustod
                   tt-arquivo.insithcc = IF craphcc.insithcc = 1 THEN "Pend." ELSE "Proc.".
        END.
    END.

END PROCEDURE.
  
PROCEDURE atualiza_conciliacao:

    DEF INPUT PARAM par_cdcooper LIKE crapdcc.cdcooper                    NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crapdcc.nrdconta                    NO-UNDO.
    DEF INPUT PARAM par_nrremret LIKE crapdcc.nrremret                    NO-UNDO.
    DEF INPUT PARAM par_nrseqarq LIKE crapdcc.nrseqarq                    NO-UNDO.
    DEF INPUT PARAM par_nrconven LIKE crapdcc.nrconven                    NO-UNDO.
    DEF INPUT PARAM par_intipmvt LIKE crapdcc.intipmvt                    NO-UNDO.

    FOR FIRST crapdcc FIELDS (inconcil cdcooper nrdconta nrremret
                              nrseqarq nrconven intipmvt cdtipmvt
                              cdocorre)
                       WHERE crapdcc.cdcooper = par_cdcooper AND
                             crapdcc.nrdconta = par_nrdconta AND
                             crapdcc.nrremret = par_nrremret AND
                             crapdcc.nrseqarq = par_nrseqarq AND 
                             crapdcc.nrconven = par_nrconven AND
                             crapdcc.intipmvt = par_intipmvt NO-LOCK:

        FOR FIRST tt-cheque WHERE tt-cheque.cdcooper = crapdcc.cdcooper AND
                                  tt-cheque.nrdconta = crapdcc.nrdconta AND
                                  tt-cheque.nrremret = crapdcc.nrremret AND
                                  tt-cheque.nrseqarq = crapdcc.nrseqarq AND
                                  tt-cheque.nrconven = crapdcc.nrconven AND 
                                  tt-cheque.intipmvt = crapdcc.intipmvt:

            /* Descricao do movimento */
            FOR FIRST crapocc FIELDS (cdocorre cdtipmvt dsocorre)
                              WHERE crapocc.cdtipmvt = crapdcc.cdtipmvt AND
                                    crapocc.cdocorre = '00'
                              NO-LOCK:
                ASSIGN tt-cheque.dstipmvt = "- " + crapocc.dsocorre.
            END.
            /* Descricao da ocorrencia */
            FOR FIRST crapocc FIELDS (cdocorre cdtipmvt dsocorre intipmvt)
                              WHERE crapocc.cdtipmvt = 21               AND
                                    crapocc.intipmvt = 2                AND
                                    crapocc.cdocorre = crapdcc.cdocorre
                              NO-LOCK:

                ASSIGN  tt-cheque.cdocorre = crapdcc.cdocorre
                        tt-cheque.dsocorre = "- " + crapocc.dsocorre.
            END.            

            ASSIGN tt-cheque.inconcil = IF crapdcc.inconcil = 1 THEN "X" ELSE "".
                        
        END.

    END.    

END PROCEDURE.

PROCEDURE Confirma:

   DEF INPUT PARAM aux_dsmensag AS CHAR                              NO-UNDO.

    /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "S".
      MESSAGE COLOR NORMAL 
             aux_dsmensag
             UPDATE aux_confirma.
      LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.

            ASSIGN glb_cdcritic = 0
                   glb_dscritic = "".

            PAUSE 2 NO-MESSAGE.
            RETURN "NOK".
        END. /* Mensagem de confirmacao */

    RETURN "OK".

END PROCEDURE.

/* Procedure que gera impressao dos protocolos de custodia */
PROCEDURE imprime_protocolo:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_nrconven AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrremret AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_dtcustod AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                            NO-UNDO.

    
    /* Confirma se deve imprimir */
    RUN Confirma(INPUT "Deseja imprimir os protocolos de custódia? S/N").
    /* Se apertou end/f4 ao confirmar */
    IF  RETURN-VALUE = "NOK" THEN
        LEAVE.

    IF  aux_confirma = "S" THEN
        DO:            
            MESSAGE "Aguarde...Gerando Relatorio...".                    
                            
            /* Pega codigo da sessao do usuario */
            INPUT THROUGH basename `tty` NO-ECHO.
            SET aux_nmendter WITH FRAME f_terminal.
            INPUT CLOSE.

            ASSIGN aux_nmendter = glb_nmdatela + aux_nmendter.
            
            FOR FIRST crapcop FIELDS (dsdircop)
                               WHERE crapcop.cdcooper = par_cdcooper
                               NO-LOCK:
                /* Atribui nome do arquivo com a sessao do usuario */
                ASSIGN aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                                      aux_nmendter.

                /* Remove arquivos gerados por esta sessao */
                UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop + "/rl/" + glb_nmdatela + "* 2>/dev/null"). 

            END.                    

                   
            /* Atribui a hora e a extensao ao nome do arquivo */
            ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
                   aux_nmarqimp = aux_nmendter + ".ex".                    
                   

            /* Saida do relatorio*/
            OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 62.

            /* Busca crapass para include */
            FOR FIRST crapass FIELDS(cdagenci nrdconta nmprimtl)
                               WHERE crapass.cdcooper = glb_cdcooper AND
                                     crapass.nrdconta = par_nrdconta
                             NO-LOCK:
            END.

            /* Busca detalhe da custodia de cheque por arquivo */
            FOR EACH crapdcc FIELDS (nrdolote cdcooper cdagenci cdbccxlt 
                                     nrdolote)
                             WHERE crapdcc.cdcooper = par_cdcooper AND
                                   crapdcc.nrdconta = par_nrdconta AND
                                   crapdcc.nrconven = par_nrconven AND
                                   crapdcc.nrremret = par_nrremret AND
                                  (crapdcc.intipmvt = 1 OR crapdcc.intipmvt = 3)
                                   NO-LOCK BREAK BY crapdcc.nrdolote:
                /* Devemos imprimir cada lote da dcc */
                IF  FIRST-OF(crapdcc.nrdolote) THEN
                    DO:
                        FOR FIRST craplot FIELDS (dtmvtolt cdagenci cdbccxlt nrdolote
                                                  qtinfocc vlinfocc qtinfoci vlinfoci
                                                  qtinfocs vlinfocs qtinfoln vlinfocr
                                                  dtmvtopg)
                                          WHERE craplot.cdcooper = crapdcc.cdcooper AND
                                                craplot.dtmvtolt = par_dtcustod     AND 
                                                craplot.cdagenci = crapdcc.cdagenci AND
                                                craplot.cdbccxlt = crapdcc.cdbccxlt AND
                                                craplot.nrdolote = crapdcc.nrdolote
                                                NO-LOCK:                            
        
                            /* Coloca o cabecalho no relatorio */
                            VIEW STREAM str_1 FRAME f_cabrel080_1.                            
                            /* Mostra os dados do relatorio */
                            DISPLAY STREAM str_1 
                                    aux_linhform
                                    crapass.nrdconta
                                    crapass.nmprimtl
                                    par_nrremret @ craphcc.nrremret
                                    craplot.dtmvtolt
                                    craplot.cdagenci
                                    craplot.cdbccxlt
                                    craplot.nrdolote
                                    craplot.qtinfocc
                                    craplot.vlinfocc
                                    craplot.qtinfoci
                                    craplot.vlinfoci
                                    craplot.qtinfocs
                                    craplot.vlinfocs
                                    craplot.qtinfoln
                                    craplot.vlinfocr
                                    craplot.dtmvtopg
                                    aux_linhform @ aux_linhfrm2 
                                    WITH FRAME f_imp_custod.
                            DISPLAY STREAM str_1 SKIP.                                           
                        END.
                    END.
            END.
            /* Fecha saida do arquivo */
            OUTPUT STREAM str_1 CLOSE.

            /* Esconde mensagem de aguardo */
            HIDE MESSAGE NO-PAUSE.                            


            ASSIGN tel_cddopcao = "T".
            MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_cddopcao.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.

                    ASSIGN glb_cdcritic = 0
                           glb_dscritic = "".

                    PAUSE 2 NO-MESSAGE.
                END. /* Mensagem de confirmacao */

            /* Se for Terminal */
            IF  tel_cddopcao = "T"  THEN
                DO:
                    HIDE FRAME f_custod.
                    /* Mostrar relatorio no terminal */
                    RUN fontes/visrel.p (INPUT aux_nmarqimp).                    
                    ENABLE b_arquivo WITH FRAME f_custod.
                END.
            ELSE
                DO:            
                    IF  tel_cddopcao = "I"  THEN
                        DO:
                            /* Senao, imprime relatorio */
                            ASSIGN glb_nmformul = "80col"
                                   glb_nrdevias = 1    
                                   glb_nrcopias = 1
                                   glb_nmarqimp = aux_nmarqimp.                                   
        
                            { includes/impressao.i }
                        END.                    
                    ELSE
                        DO:                    
                            BELL.
                            MESSAGE "Opcao invalida".                           
                            PAUSE 2 NO-MESSAGE.
                        END.
                END.

        END.

END PROCEDURE.

PROCEDURE verifica_cheques_conciliados:

    DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS DECI                            NO-UNDO.
    DEF INPUT  PARAM par_nrconven AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrremret AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_flgcqcon AS LOGI INIT FALSE                 NO-UNDO.
    DEF OUTPUT PARAM par_flgocorr AS LOGI INIT FALSE                 NO-UNDO.

    /* Verifica se ha algum cheque conciliado na remessa */
    FOR FIRST crapdcc WHERE crapdcc.cdcooper = par_cdcooper AND
                            crapdcc.nrdconta = par_nrdconta AND
                            crapdcc.nrconven = par_nrconven AND
                            crapdcc.nrremret = par_nrremret AND
                            crapdcc.inconcil = 0            AND
                           (crapdcc.intipmvt = 1 OR crapdcc.intipmvt = 3) AND

                            TRIM(crapdcc.cdocorre) = ""
                            NO-LOCK:

        ASSIGN par_flgcqcon = TRUE.

    END.

    /* Quantidade de cheques com ocorrencia na remessa */
    FOR FIRST crapdcc WHERE crapdcc.cdcooper = par_cdcooper AND
                            crapdcc.nrdconta = par_nrdconta AND
                            crapdcc.nrconven = par_nrconven AND
                            crapdcc.nrremret = par_nrremret AND
                            crapdcc.inconcil = 0            AND
                           (crapdcc.intipmvt = 1 OR crapdcc.intipmvt = 3) AND
                            TRIM(crapdcc.cdocorre) <> ""
                            NO-LOCK:

        ASSIGN par_flgocorr = TRUE.

    END.

END PROCEDURE.

PROCEDURE gerar_previa:

    DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS DECI                            NO-UNDO.
    DEF INPUT  PARAM par_nrconven AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrremret AS INTE                            NO-UNDO.

    DEF VAR h-b1wgen0012          AS HANDLE                          NO-UNDO.

    DEF VAR aux_qtarquiv          AS INTE                            NO-UNDO.
    DEF VAR aux_totregis          AS INTE                            NO-UNDO.
    DEF VAR aux_vlrtotal          AS DECI                            NO-UNDO.

/******* ROTINA PARA BLOQUEAR O OPERADOR NO PROCESSO DA PRÉVIA **********/

    FIND craptab WHERE craptab.cdcooper = par_cdcooper         AND
                       craptab.nmsistem = "CRED"               AND
                       craptab.tptabela = "GENERI"             AND
                       craptab.cdempres = par_cdcooper         AND
                       craptab.cdacesso = "COMPEL"             AND
                       craptab.tpregist = 1  
                       EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

    IF  AVAIL craptab THEN     
        DO:
            ASSIGN craptab.dstextab = glb_cdoperad.
            RELEASE craptab.
        END.

/*********************************************************************/
 
    /* Instancia a BO 12 */
    RUN sistema/generico/procedures/b1wgen0012.p 
        PERSISTENT SET h-b1wgen0012.
    
    IF NOT VALID-HANDLE(h-b1wgen0012) THEN
        DO:
            BELL.
            MESSAGE "Handle invalido para BO b1wgen0012.".
            LEAVE.
        END.
  
    FOR EACH  crapdcc FIELDS (cdagenci nrdolote dtlibera)
        WHERE crapdcc.cdcooper = par_cdcooper
          AND crapdcc.nrdconta = par_nrdconta
          AND crapdcc.nrconven = par_nrconven
          AND crapdcc.nrremret = par_nrremret
          AND (crapdcc.intipmvt = 1 OR crapdcc.intipmvt = 3)
          AND crapdcc.nrdolote > 0
          NO-LOCK
          BREAK BY crapdcc.nrdolote:

        IF  FIRST-OF(crapdcc.nrdolote) THEN DO:

            MESSAGE "Gerando previa - lote " crapdcc.nrdolote.

            PAUSE 1.
         
            RUN gerar_arquivos_cecred IN h-b1wgen0012
                                           (INPUT "COMPEL",
                                            INPUT glb_dtmvtolt,
                                            INPUT par_cdcooper,
                                            INPUT crapdcc.cdagenci,
                                            INPUT crapdcc.cdagenci,
                                            INPUT glb_cdoperad,
                                            INPUT "COMPEL_CST", /* nmdatela */
                                            INPUT crapdcc.nrdolote,   /*Lote*/
                                            INPUT 0,
                                            INPUT "600", /*Cxa*/
                                            OUTPUT glb_cdcritic,
                                            OUTPUT aux_qtarquiv,
                                            OUTPUT aux_totregis,
                                            OUTPUT aux_vlrtotal).

            IF  glb_cdcritic > 0 OR glb_dscritic <> "" THEN
                DO:
                    IF  VALID-HANDLE(h-b1wgen0012) THEN
                        DELETE PROCEDURE h-b1wgen0012.
                    
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.

                    ASSIGN glb_cdcritic = 0
                           glb_dscritic = "".

                    RETURN "NOK".
                END.

            HIDE MESSAGE NO-PAUSE.
        END.

    END.
 
    IF  VALID-HANDLE(h-b1wgen0012) THEN
        DELETE PROCEDURE h-b1wgen0012.

/******* ROTINA PARA DESBLOQUEAR O OPERADOR NO PROCESSO DA PRÉVIA **********/
                     
  FIND craptab WHERE craptab.cdcooper = par_cdcooper         AND
                     craptab.nmsistem = "CRED"               AND       
                     craptab.tptabela = "GENERI"             AND
                     craptab.cdempres = par_cdcooper         AND       
                     craptab.cdacesso = "COMPEL"             AND
                     craptab.tpregist = 1  
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  IF   AVAIL craptab THEN      
       DO:
           ASSIGN craptab.dstextab = " ".
           RELEASE craptab.
       END.           

/**********************************************************************/

  RETURN "OK".

END PROCEDURE.
