/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+-------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                 |
  +------------------------------------+-------------------------------------+
  | procedures/b1wgen0050.p	           | SSPB0001                            |
  |   obtem-log-cecred                 |   pc_obtem-log-cecred               |
  |   busca-log-ted                    |   pc_busca_log_SPB                  |
  |   le-arquivo-log                   |   pc_le_arquivo_log                 |
  |   grava-msg-log                    |   pc_grava_msg_log                  |
  |   busca-enviada-ok                 |   pc_busca_log_SPB                  |
  |   busca-enviada-nok                |   pc_busca_log_SPB                  |
  |   busca-Recebida-ok                |   pc_busca_log_SPB                  |
  |   busca-Recebida-nok               |   pc_busca_log_SPB                  | 
  |   busca-rejeitada-ok               |   pc_busca_log_SPB                  |
  |   grava-enviada-ok                 |   pc_grava_detalhe                  |
  |   grava-enviada-nok                |   pc_grava_detalhe                  |
  |   grava-Recebida-ok                |   pc_grava_detalhe                  |
  |   grava-Recebina-nok               |   pc_grava_detalhe                  |
  |   grava-rejeitada-ok               |   pc_grava_detalhe                  |
  |   grava-log-ted                    |   SSPB0001.pc_grava_log_ted         | 
  +------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/








/*..............................................................................

    Programa: b1wgen0050.p
    Autor   : David
    Data    : Novembro/2009                   Ultima Atualizacao: 17/11/2017
           
    Dados referentes ao programa:
                
    Objetivo  : BO referente aos logs de transacoes SPB.
                Baseada no programa fontes/logspb.p.
                    
    Alteracoes: 21/05/2010 - Ajustar captura (SUBSTR) de dados dos logs (David).
    
                01/06/2010 - Acerto na leitura de log do Bancoob (David).
                
                26/06/2010 - Trocados tipo das variaveis nrctarem e nrctadst de
                             decimal para char - conta com digito X (Fernando).
                             
                16/07/2010 - Incluido tratamento para as transacoes rejeitadas
                            (Elton).
                            
                21/10/2010 - Adaptado LOG da mensagem RECEBIDA OK (Diego).
                
                06/12/2010 - Tratar mensagens STR0018 e STR0019 (Diego).
                
                09/04/2012 - Criado a procedure grava-log-ted. (Fabricio)
                
                12/04/2012 - Chamada da procedure busca-log-ted para os tipos
                             "ENVIADAS" / "RECEBIDAS"; na procedure 
                             obtem-log-cecred.
                             Criacao das procedures: busca-enviada-ok,
                                                     busca-enviada-nok,
                                                     busca-recebida-ok,
                                                     busca-recebida-nok,
                                                     busca-rejeitada-ok.
                                                            (Fabricio)
                                                            
                30/05/2012 - Adicionado as procedures imprime-log e
                             imprime-relatorio. (Fabricio)
                             
                29/06/2012 - Ajuste na procedure grava-log-ted, para receber
                             parametros char nos numeros de conta (David).
                             
                30/07/2012 - Inclusão de novos parametros na procedure grava-log-ted
                             campos: cdagenci, nrdcaixa, cdoperad.(Lucas R).
                             
                20/12/2013 - Adicionada procedure obtem-log-teds-migradas
                            para contas migradas Acredi >> Viacredi. (Fabricio)

                24/03/2014 - Retirar controle de sequencia na craplmt (Gabriel) 
                
                04/09/2014 - Adicionado parametros na procedure obtem-log-cecred. 
                             CHAMADO: 161899 - (Jonathan - RKAM)
                             
                20/11/2014 - Alterada a procedure obtem-log-teds-migradas para
                            tratar a integração da Concredi e Credimilsul (Vanessa)
                            
                11/12/2014 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                                         
                30/12/2014 - Criado proc. busca-detalhe-transferencia e proc.
                             busca-detalhe-doc.
                             (Jorge/Elton) - SD 229245
                
                13/04/2015 - Alteração na procedure grava-log-ted para tratar as alterações
                             solicitadas no SD271603 FDR041 (Vanessa)                         
                 
                16/05/2015 - Criação da procedure obtem-log-sistema-cecred e adição dos
                             campos cdtiptra e dstiptra na temp-table tt-logspb-detalhe
                             para o projeto Mobile (Dionathan)
                                                                                                                                             
                22/06/2015 - Incluir clausula crapldt.ndctadst = par_nrdcomto na proc.
                             busca-detalhe-transferencia pois estava buscando os
                             dados da primeira conta destino, caso houve-se mais que
                             uma Transferancia no mesmo dia (Lucas Ranghetti #297519)

                08/07/2015 - Evitar erro de remetente nao encontrado quando
                             historico 1011 (Gabriel-RKAM).
                             
                04/08/2015 - Ajustes referentes a Melhoria Gestao de TEDs/TECs - 85 
                             Tela LOGSPB (Lucas Ranghetti)
                             
                26/08/2015 - Limpar temp-table tt-logspb-detalhe na procedure
                             obtem-log-sistema-cecred (David).

                29/10/2015 - Inclusao do indicador estado de crise na 
                             grava-log-ted. (Jaison/Andrino)
                             
                09/11/2015 - Adicionado parametro de entrada par_inestcri em 
                             proc. obtem-log-spb, impressao-log-pdf e
                             impressao-log-csv. (Jorge/Andrino)             
                             
                17/05/2016 - Alterar procedures busca-detalhe-transferencia para buscar 
                             dados de credito da forma correta, na busca-detalhe-doc
                             alterar o campo do cpf do remetente para buscar do campo 
                             correto (Lucas Ranghetti #440959)
                           - Remover chamado em duplicidade das opcoes "ENVIADOS -> TODOS" 
                             e "RECEBIDOS -> TODOS" na procedure obtem-log-cecred (Lucas Ranghetti #445186)                             
                
                27/09/2016 - M211 - Adicionado parametros par_cdifconv nas procs 
                            obtem-log-spb, impressao-log-pdf e impressao-log-csv.
                            Tambem chamada a rotina convertida da obtem-log-cecred
                            (Jonata-RKAM)
                             
                19/07/2017 - Alterado impressao-log-pdf e impressao-log-csv para quando
                             chamar obtem-log-cecred nao limitar os resultados a 9999 (Tiago #708595)
							 
				17/11/2017 - Ajustado o relatorio da opcao R para 234 colunas, e tambem o relatorio da opcao
							 L aumentado o tamanho da conta do remetente e destinatario, conforme solicitado
							 no chamado 776168. (Kelvin).

..............................................................................*/


/*................................ DEFINICOES ................................*/


{ sistema/generico/includes/b1wgen0050tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1cabrelvar.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrseqlog AS INTE                                           NO-UNDO.
DEF VAR aux_qtdenvok AS INTE                                           NO-UNDO.
DEF VAR aux_qtdrecok AS INTE                                           NO-UNDO.
DEF VAR aux_qtenvnok AS INTE                                           NO-UNDO.
DEF VAR aux_qtrecnok AS INTE                                           NO-UNDO.
DEF VAR aux_qtrejeit AS INTE                                           NO-UNDO.
DEF VAR aux_qtdrejok AS INTE                                           NO-UNDO.

DEF VAR aux_vlrenvok AS DECI                                           NO-UNDO.
DEF VAR aux_vlrrecok AS DECI                                           NO-UNDO.
DEF VAR aux_vlenvnok AS DECI                                           NO-UNDO.
DEF VAR aux_vlrecnok AS DECI                                           NO-UNDO.
DEF VAR aux_vlrrejok AS DECI                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinlog AS CHAR                                           NO-UNDO.

DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_pontilha AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dstitcab AS CHAR                                           NO-UNDO.

DEF VAR aux_dtmvtlog AS DATE                                           NO-UNDO.

  


FORM SKIP(2) 
     aux_dstitcab NO-LABEL FORMAT "x(35)"
     SKIP(1)
     WITH NO-BOX WIDTH 234 FRAME f_titulo.

FORM "                       DESTINATARIO                       "
     "                        REMETENTE                         "
     SKIP
     "---------------------------------------------------------------------------------------------------   "
     "   ---------------------------------------------------------------------------------------------------"
     SKIP
     "BCO  AGE          CONTA/DV DESTINATARIO           CPF/CNPJ" 
     "BCO  AGE          CONTA/DV REMETENTE              CPF/CNPJ"
     "         VALOR"
     SKIP
     aux_pontilha FORMAT "x(234)"
     WITH NO-BOX NO-LABEL WIDTH 234 FRAME f_cabecalho.

FORM aux_dslinlog FORMAT "x(234)"
     WITH NO-BOX NO-LABEL DOWN WIDTH 234 FRAME f_rejeitadas.

FORM tt-logspb-detalhe.cdbandst FORMAT "zz9"
     tt-logspb-detalhe.cdagedst FORMAT "zzz9" AT 6
     tt-logspb-detalhe.nrctadst FORMAT "xxxx.xxx.xxx.xxx.xxx.xxx-x" AT 13
     tt-logspb-detalhe.dsnomdst FORMAT "x(40)" AT 43
     tt-logspb-detalhe.dscpfdst FORMAT "99999999999999" AT 86
     tt-logspb-detalhe.cdbanrem FORMAT "zz9" AT 107
     tt-logspb-detalhe.cdagerem FORMAT "zzz9" AT 112
     tt-logspb-detalhe.nrctarem FORMAT "xxxx.xxx.xxx.xxx.xxx.xxx-x" AT 119
     tt-logspb-detalhe.dsnomrem FORMAT "x(40)" AT 150
     tt-logspb-detalhe.dscpfrem FORMAT "99999999999999" AT 192
     tt-logspb-detalhe.vltransa FORMAT "zzz,zzz,zz9.99" AT 219
     SKIP
     "MOTIVO:"
     tt-logspb-detalhe.dsmotivo FORMAT "x(90)"
     WITH NO-BOX NO-LABEL DOWN WIDTH 234 FRAME f_devolucao.

FORM SKIP(1)
     aux_dtmvtlog LABEL "DATA" FORMAT "99/99/9999"
     SKIP(1)
     "TED'S/TEC'S ENVIADAS"        AT 012
     "DEVOL.TED'S/TEC'S ENVIADAS"  AT 036
     "TED'S/TEC'S RECEBIDAS"       AT 066
     "DEVOL.TED'S/TEC'S RECEBIDAS" AT 091
     "REJEITADAS"                  AT 123
     SKIP(1)
     "REGISTROS:"
     tt-logspb-totais.qtdenvok AT 021 NO-LABEL FORMAT "zzz,zzz,zz9"
     tt-logspb-totais.qtenvnok AT 051 NO-LABEL FORMAT "zzz,zzz,zz9"
     tt-logspb-totais.qtdrecok AT 076 NO-LABEL FORMAT "zzz,zzz,zz9"
     tt-logspb-totais.qtrecnok AT 107 NO-LABEL FORMAT "zzz,zzz,zz9"
     tt-logspb-totais.qtrejeit AT 122 NO-LABEL FORMAT "zzz,zzz,zz9"
     SKIP
     tt-logspb-totais.vlrenvok AT 014 NO-LABEL FORMAT "zzz,zzz,zzz,zz9.99"
     tt-logspb-totais.vlenvnok AT 044 NO-LABEL FORMAT "zzz,zzz,zzz,zz9.99"
     tt-logspb-totais.vlrrecok AT 069 NO-LABEL FORMAT "zzz,zzz,zzz,zz9.99"
     tt-logspb-totais.vlrecnok AT 100 NO-LABEL FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX SIDE-LABELS WIDTH 234 FRAME f_totais.
                                                                    
/* BUSCA O ISPB DA CECRED PARA ALIMENTAR A TELA DE DETALHES*/
FIND crapban  WHERE crapban.cdbccxlt = 85 NO-LOCK NO-ERROR.
/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**     Procedure para obter log das transacoes com SPB (Bancoob/Cecred)     **/
/******************************************************************************/
PROCEDURE obtem-log-spb:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgidlog AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtlog AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_numedlog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idacesso AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inestcri AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrdated AS DECIMAL                        NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-logspb-detalhe.
    DEF OUTPUT PARAM TABLE FOR tt-logspb-totais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE     aux_flgimprl AS LOGI                           NO-UNDO.

    /**********************************************************************/
    /** par_flgidlog => 1 - BANCOOB / 2 - CECRED  / 3 - SICREDI          **/
    /**********************************************************************/    
    
    IF  par_flgidlog = 1 THEN
        RUN obtem-log-bancoob (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nmdatela,
                               INPUT par_idorigem,
                               INPUT par_dtmvtlog,
                               INPUT par_numedlog,
                              OUTPUT TABLE tt-logspb,
                              OUTPUT TABLE tt-erro).    
    ELSE
        RUN obtem-log-cecred (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_cdoperad,
                              INPUT par_nmdatela,
                              INPUT par_idorigem,
                              INPUT par_dtmvtlog,
                              INPUT par_dtmvtlog,
                              INPUT par_numedlog,
                              INPUT par_cdsitlog,
                              INPUT par_nrdconta,
                              INPUT 0,
                              INPUT par_nriniseq,
                              INPUT par_nrregist,
                              INPUT par_inestcri,
                              INPUT (IF par_flgidlog = 2 THEN
										0 /*Somente ted CECRED*/
									 ELSE
									    1 /*Somente ted SICREDI*/),
                              INPUT par_vlrdated,
                             OUTPUT TABLE tt-logspb,
                             OUTPUT TABLE tt-logspb-detalhe,
                             OUTPUT TABLE tt-logspb-totais,
                             OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    ASSIGN aux_flgimprl = FALSE.
    
    IF (par_flgidlog = 1  OR ( (par_flgidlog = 2 OR par_flgidlog = 3 ) AND par_numedlog = 3)) AND 
        CAN-FIND(FIRST tt-logspb) THEN
    DO: 
        RUN imprime-log (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_dsiduser,
                         INPUT TABLE tt-logspb,
                        OUTPUT par_nmarqimp,
                        OUTPUT TABLE tt-erro).

        IF RETURN-VALUE = "NOK" THEN
            RETURN "NOK".

        ASSIGN aux_flgimprl = TRUE.

    END.
    ELSE
    IF par_numedlog = 0 THEN
    DO:
        RUN imprime-relatorio (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_dtmvtlog,
                               INPUT par_dsiduser,
                               INPUT TABLE tt-logspb,
                               INPUT TABLE tt-logspb-detalhe,
                               INPUT TABLE tt-logspb-totais,
                              OUTPUT par_nmarqimp,
                              OUTPUT TABLE tt-erro).

        IF RETURN-VALUE = "NOK" THEN
            RETURN "NOK".

        ASSIGN aux_flgimprl = TRUE.
    END.
    
    IF aux_flgimprl THEN
    DO:
        EMPTY TEMP-TABLE tt-logspb.
        EMPTY TEMP-TABLE tt-logspb-detalhe.
        EMPTY TEMP-TABLE tt-logspb-totais.
        
        IF par_idacesso = 5 THEN /* Ayllos WEB */
        DO:
            RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.
               
            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,         
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            
            RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_nmarqimp,
                                                  OUTPUT par_nmarqpdf,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0024.

            IF RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
        END.
    END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE obtem-log-teds-migradas:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_datmigra AS DATE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_nmarqlog AS CHAR NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqimp AS CHAR           NO-UNDO.
    DEF VAR aux_cabecalh AS LOGI INIT TRUE NO-UNDO.

    DEF VAR aux_horated  AS CHAR NO-UNDO.
    DEF VAR aux_vllanmto AS CHAR NO-UNDO.
    DEF VAR aux_nrctaant AS CHAR NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR NO-UNDO.

    ASSIGN par_nmarqlog = "/usr/coop/cecred/log/" +
                          "teds_migradas" + 
                          STRING(par_cdcooper, "99")   +
                          STRING(DAY(par_datmigra), "99")   +  
                          STRING(MONTH(par_datmigra), "99") +
                          STRING(YEAR(par_datmigra), "9999")  + ".lst".

   
    IF SEARCH(par_nmarqlog) <> ? THEN
    DO:
        IF par_idorigem = 5 THEN /* Ayllos Web */
        DO:
            ASSIGN aux_nmarqimp = REPLACE(par_nmarqlog, ".lst", ".ex").

            UNIX SILENT VALUE("cp " + par_nmarqlog + " " + aux_nmarqimp).
            
            RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.
            
            IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,         
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            
            RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT aux_nmarqimp,
                                                  OUTPUT par_nmarqpdf,
                                                  OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0024.
            
            IF RETURN-VALUE = "NOK" THEN
                RETURN "NOK".
        END.
    END.
    ELSE
    DO:
        ASSIGN aux_cdcritic = 182
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


/******************************************************************************/
/**           Procedure para obter log das transacoes com BANCOOB            **/
/******************************************************************************/
PROCEDURE obtem-log-bancoob:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtlog AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_numedlog AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-logspb.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqlog AS CHAR                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-logspb.
    EMPTY TEMP-TABLE tt-erro.

    /**********************************************************************/
    /** par_numedlog => 1 - TODOS / 2 - SUCESSO / 3 - ERRO               **/
    /**********************************************************************/

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN aux_nmarqlog = "/usr/coop/" + crapcop.dsdircop + 
                          "/log/mqbancoob_processa_" +
                          STRING(DAY(par_dtmvtlog),"99") +
                          STRING(MONTH(par_dtmvtlog),"99") +
                          SUBSTR(STRING(YEAR(par_dtmvtlog)),3) + ".log".
          
    IF  SEARCH(aux_nmarqlog) = ?  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao existe log das transacoes para este " +
                                  "dia.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".    
        END.

    ASSIGN aux_nrseqlog = 0.

    INPUT STREAM str_1 FROM VALUE(aux_nmarqlog) NO-ECHO.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_dslinlog.

        IF  par_numedlog = 2                      AND
            NOT aux_dslinlog MATCHES "*SUCESSO*"  THEN
            NEXT.
        ELSE
        IF  par_numedlog = 3                   AND
            NOT aux_dslinlog MATCHES "*ERRO*"  THEN
            NEXT.

        RUN grava-msg-log.

    END.

    INPUT STREAM str_1 CLOSE.

    IF  NOT CAN-FIND(FIRST tt-logspb)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao existem mensagens de " + 
                                 (IF  par_numedlog = 1  THEN
                                      "log"
                                  ELSE
                                  IF  par_numedlog = 2  THEN
                                      "sucesso"
                                  ELSE
                                      "erro") +
                                  " para este dia.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".    
        END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**            Procedure para obter log das transacoes da CECRED             **/
/******************************************************************************/
PROCEDURE obtem-log-cecred:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_numedlog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrsequen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inestcri AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdifconv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrdated AS DECIMAL                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-logspb.
    DEF OUTPUT PARAM TABLE FOR tt-logspb-detalhe.
    DEF OUTPUT PARAM TABLE FOR tt-logspb-totais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE   NO-UNDO.   
    DEF VAR xRoot         AS HANDLE   NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE   NO-UNDO.
	DEF VAR xRoot3        AS HANDLE   NO-UNDO.   
    DEF VAR xField        AS HANDLE   NO-UNDO.
	DEF VAR xField2       AS HANDLE   NO-UNDO.  
	DEF VAR xField3       AS HANDLE   NO-UNDO. 
    DEF VAR xText         AS HANDLE   NO-UNDO. 
	DEF VAR hTextTag      AS HANDLE   NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
	DEF VAR aux_cont2     AS INTEGER  NO-UNDO. 
	DEF VAR aux_cont3     AS INTEGER  NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
    DEF VAR xml_logspb         AS LONGCHAR NO-UNDO. 
    DEF VAR xml_logspb_detalhe AS LONGCHAR NO-UNDO. 
    DEF VAR xml_logspb_totais  AS LONGCHAR NO-UNDO. 
    
     /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */         

    EMPTY TEMP-TABLE tt-logspb.
    EMPTY TEMP-TABLE tt-logspb-detalhe.
    EMPTY TEMP-TABLE tt-logspb-totais.
    EMPTY TEMP-TABLE tt-erro.

    /*********************************************************************************/
    /** par_numedlog => 1 - ENVIADAS / 2 - RECEBIDAS / 3 - DEMAIS MSG'S / 4 - TODOS **/
    /** par_cdsitlog => "P" - MSG'S PROCESSADAS / "D" - MSG'S DEVOLVIDAS 
                        "R" - MSG'S REJEITADAS / "T" - TODOS         *****************/
    /*********************************************************************************/

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                 
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
	CREATE X-NODEREF  xRoot3.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
	CREATE X-NODEREF  xField2.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
	CREATE X-NODEREF  hTextTag. /* Vai conter o texto que existe dentro da tag xField */ 
	
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_obtem_log_cecred_car
       aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_cdorigem,                                                            
										   INPUT par_dtmvtini,
                                           INPUT par_dtmvtfim,                                                             
										   INPUT STRING(par_numedlog),
                                           INPUT par_cdsitlog,
                                           INPUT STRING(par_nrdconta),
                           INPUT par_nrsequen,
                           INPUT par_nriniseq,
                                           INPUT STRING(par_nrregist),
                           INPUT par_inestcri,
                                           INPUT par_cdifconv,
                           INPUT par_vlrdated,
                                           OUTPUT ?,  /* pr_clob_logspb */
                                           OUTPUT 0, /* cdcritic */
                                           OUTPUT ""). /* dscritic */
    
	
	/* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_obtem_log_cecred_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    /*************************************************************/
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_logspb_totais = pc_obtem_log_cecred_car.pr_clob_logspb         .
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_obtem_log_cecred_car.pr_cdcritic 
                          WHEN pc_obtem_log_cecred_car.pr_cdcritic <> ?
           aux_dscritic = pc_obtem_log_cecred_car.pr_dscritic 
                          WHEN pc_obtem_log_cecred_car.pr_dscritic <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
    
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> "OK"  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.cdcritic = aux_cdcritic
                   tt-erro.dscritic = aux_dscritic.     
            RETURN "NOK".
            
        END.
        
	EMPTY TEMP-TABLE tt-logspb.
	EMPTY TEMP-TABLE tt-logspb-detalhe.
    EMPTY TEMP-TABLE tt-logspb-totais.
        
    /********** BUSCAR LANCAMENTOS **********/
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_logspb_totais) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_logspb_totais.    
    
    IF  ponteiro_xml <> ? THEN
        DO:
           xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE) NO-ERROR. 
           xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
           
           DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
               
               xRoot:GET-CHILD(xRoot2,aux_cont_raiz) NO-ERROR. 

               IF  xRoot2:SUBTYPE <> "ELEMENT"   THEN 
                   NEXT.            

               IF xRoot2:name = "linhas_logspb" THEN
        DO:
				     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

					   xRoot2:GET-CHILD(xField,aux_cont). 

					   IF xField:SUBTYPE <> "ELEMENT" THEN 
						  NEXT. 

						IF xRoot2:NUM-CHILDREN > 0 THEN
                           CREATE tt-logspb.
					   
						DO aux_cont2 = 1 TO xField:NUM-CHILDREN: 
						
   						   xField:GET-CHILD(xField2,aux_cont2) no-error. 
						
						   IF xField2:SUBTYPE <> "ELEMENT" THEN 
							   NEXT. 

						   DO aux_cont3 = 1 TO xField2:NUM-CHILDREN: 
						 
							   xField2:GET-CHILD(hTextTag,1) NO-ERROR.
							   
							   /* Se nao vier conteudo na TAG */ 
							   IF ERROR-STATUS:ERROR             OR  
								  ERROR-STATUS:NUM-MESSAGES > 0  THEN
								  NEXT.
							   
							   ASSIGN tt-logspb.nrseqlog = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "nrseqlog"
                        tt-logspb.dslinlog = hTextTag:NODE-VALUE  WHEN xField2:NAME = "dslinlog".
				 
        END.
        
						 END. 
						 
				     END. 
				  
				  END. 
			   ELSE
			   IF xRoot2:name = "linhas_logspb_detalhe" THEN
        DO:
				     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

					   xRoot2:GET-CHILD(xField,aux_cont). 

					   IF xField:SUBTYPE <> "ELEMENT" THEN 
						  NEXT. 
					   
					   IF xRoot2:NUM-CHILDREN > 0 THEN
                          CREATE tt-logspb-detalhe.
				  
						DO aux_cont2 = 1 TO xField:NUM-CHILDREN: 
						
   						   xField:GET-CHILD(xField2,aux_cont2) no-error. 
						
						   IF xField2:SUBTYPE <> "ELEMENT" THEN 
							   NEXT. 

						   DO aux_cont3 = 1 TO xField2:NUM-CHILDREN: 
						 
							   xField2:GET-CHILD(hTextTag,1) NO-ERROR.
							   
							   /* Se nao vier conteudo na TAG */ 
							   IF ERROR-STATUS:ERROR             OR  
								  ERROR-STATUS:NUM-MESSAGES > 0  THEN
								  NEXT.
							   
							   ASSIGN tt-logspb-detalhe.nrseqlog = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "nrseqlog"         
									  tt-logspb-detalhe.cdbandst = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdbandst"
										tt-logspb-detalhe.cdagedst = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdagedst"
										tt-logspb-detalhe.nrctadst =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "nrctadst"
										tt-logspb-detalhe.dsnomdst =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "dsnomdst"
										tt-logspb-detalhe.dscpfdst = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "dscpfdst"
										tt-logspb-detalhe.cdbanrem = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdbanrem"
										tt-logspb-detalhe.cdagerem = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdagerem"
										tt-logspb-detalhe.nrctarem =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "nrctarem"
										tt-logspb-detalhe.dsnomrem =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "dsnomrem"
										tt-logspb-detalhe.dscpfrem = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "dscpfrem"
										tt-logspb-detalhe.hrtransa =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "hrtransa"
										tt-logspb-detalhe.vltransa = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "vltransa"
										tt-logspb-detalhe.dsmotivo =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "dsmotivo"
										tt-logspb-detalhe.dstransa =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "dstransa"
										tt-logspb-detalhe.dsorigem =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "dsorigem"
										tt-logspb-detalhe.cdagenci = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdagenci"
										tt-logspb-detalhe.nrdcaixa = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "nrdcaixa"
										tt-logspb-detalhe.cdoperad =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "cdoperad"
                    
                    tt-logspb-detalhe.dttransa = DATE(hTextTag:NODE-VALUE)  WHEN xField2:NAME = "dttransa"
                    tt-logspb-detalhe.nrsequen = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "nrsequen"
										tt-logspb-detalhe.cdisprem = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdisprem"
										tt-logspb-detalhe.cdispdst = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdispdst"
										tt-logspb-detalhe.cdtiptra = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "cdtiptra"
										tt-logspb-detalhe.dstiptra =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "dstiptra"
                    tt-logspb-detalhe.nmevento =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "nmevento"
                    tt-logspb-detalhe.nrctrlif =     hTextTag:NODE-VALUE  WHEN xField2:NAME = "nrctrlif"     .
				 
        END.

						 END. 
						 
				     END. 
				  
				  END. 
			   ELSE
			   IF xRoot2:name = "linhas_logspb_totais" THEN
        DO:
    CREATE tt-logspb-totais.
				     DO aux_cont = 1 TO xRoot2:NUM-CHILDREN: 

					   xRoot2:GET-CHILD(xField,aux_cont). 

					   IF xField:SUBTYPE <> "ELEMENT" THEN 
						  NEXT. 

					   DO aux_cont2 = 1 TO xField:NUM-CHILDREN: 
						
   						   xField:GET-CHILD(xField2,aux_cont2) no-error. 
						
						   IF xField2:SUBTYPE <> "ELEMENT" THEN 
							   NEXT. 

						   DO aux_cont3 = 1 TO xField2:NUM-CHILDREN: 
						 
							   xField2:GET-CHILD(hTextTag,1) NO-ERROR.
							   
							   /* Se nao vier conteudo na TAG */ 
							   IF ERROR-STATUS:ERROR             OR  
								  ERROR-STATUS:NUM-MESSAGES > 0  THEN
								  NEXT.
							   
							   ASSIGN tt-logspb-totais.qtdenvok = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "qtdenvok"         
									      tt-logspb-totais.vlrenvok = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "vlrenvok"                        
                        tt-logspb-totais.qtenvnok = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "qtenvnok"         
									      tt-logspb-totais.vlenvnok = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "vlenvnok"                        
                        tt-logspb-totais.qtdrecok = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "qtdrecok"         
									      tt-logspb-totais.vlrrecok = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "vlrrecok"                        
                        tt-logspb-totais.qtrecnok = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "qtrecnok"         
									      tt-logspb-totais.vlrecnok = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "vlrecnok"                        
                        tt-logspb-totais.qtdrejok = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "qtdrejok"         
									      tt-logspb-totais.vlrrejok = DEC(hTextTag:NODE-VALUE) WHEN xField2:NAME = "vlrrejok"                        
                        tt-logspb-totais.qtrejeit = INT(hTextTag:NODE-VALUE) WHEN xField2:NAME = "qtrejeit".
				 
							 END. 
							 
						 END. 
						 
				     END. 
				  
				  END.      
             
           END.    
           
           SET-SIZE(ponteiro_xml) = 0.    
        END.           
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
	  DELETE OBJECT xRoot3. 
    DELETE OBJECT xField. 
	  DELETE OBJECT xField2. 
    DELETE OBJECT xText.
	  DELETE OBJECT hTextTag.
    
    /* Chegou ao fim com sucesso */
    RETURN "OK".

END PROCEDURE.


PROCEDURE imprime-relatorio:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR NO-UNDO.

    DEF INPUT PARAM TABLE FOR tt-logspb.
    DEF INPUT PARAM TABLE FOR tt-logspb-detalhe.
    DEF INPUT PARAM TABLE FOR tt-logspb-totais.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE     aux_flgfirst AS LOGI NO-UNDO.
    DEF VARIABLE     aux_contador AS INTE NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/O538_" + 
                          par_dsiduser + "_" + 
                                  STRING(TIME,"99999") + ".ex"
           aux_pontilha = FILL("-",234).
      
    UNIX SILENT VALUE("rm " + par_nmarqimp + " 2> /dev/null").
                            
    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.

    { sistema/generico/includes/b1cabrel234.i "15" "538" }
    
    FIND FIRST tt-logspb-totais NO-LOCK NO-ERROR.
                                          
    ASSIGN aux_flgfirst = TRUE.

    FOR EACH tt-logspb-detalhe WHERE
             tt-logspb-detalhe.dstransa = "ENVIADA NAO OK"  OR
             tt-logspb-detalhe.dstransa = "RECEBIDA NAO OK" NO-LOCK
             BREAK BY tt-logspb-detalhe.dstransa 
                       BY tt-logspb-detalhe.nrseqlog:
        
        IF  aux_flgfirst  THEN
            DO:
                RUN mostra-totais.

                ASSIGN aux_flgfirst = FALSE.
            END.
        
        IF  FIRST-OF(tt-logspb-detalhe.dstransa)  THEN
            DO:
                IF  tt-logspb-detalhe.dstransa = "ENVIADA NAO OK"  THEN
                    ASSIGN aux_dstitcab = ">> DEVOLUCAO TED'S/TEC'S " +
                                              "ENVIADAS".
                ELSE
                IF  tt-logspb-detalhe.dstransa = "RECEBIDA NAO OK"  THEN
                    ASSIGN aux_dstitcab = ">> DEVOLUCAO TED'S/TEC'S " +
                                              "RECEBIDAS".

                IF  NOT aux_flgfirst  THEN
                    DO:
                        IF  (LINE-COUNTER(str_1) + 9) > 
                            PAGE-SIZE(str_1)  THEN
                            DO:
                                PAGE STREAM str_1.

                                RUN mostra-totais.
                            END.
                        
                        DISPLAY STREAM str_1 aux_dstitcab 
                                             WITH FRAME f_titulo.

                        DISPLAY STREAM str_1 aux_pontilha 
                                             WITH FRAME f_cabecalho.
                    END.
            END.

        IF  (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                RUN mostra-totais.
                            
                DISPLAY STREAM str_1 aux_dstitcab 
                                     WITH FRAME f_titulo.

                DISPLAY STREAM str_1 aux_pontilha 
                                     WITH FRAME f_cabecalho.
            END.

        DISPLAY STREAM str_1 tt-logspb-detalhe.cdbandst
                             tt-logspb-detalhe.cdagedst
                             tt-logspb-detalhe.nrctadst
                             tt-logspb-detalhe.dsnomdst
                             tt-logspb-detalhe.dscpfdst
                             tt-logspb-detalhe.cdbanrem
                             tt-logspb-detalhe.cdagerem
                             tt-logspb-detalhe.nrctarem
                             tt-logspb-detalhe.dsnomrem
                             tt-logspb-detalhe.dscpfrem
                             tt-logspb-detalhe.vltransa
                             tt-logspb-detalhe.dsmotivo
                             WITH FRAME f_devolucao.

        DOWN STREAM str_1 WITH FRAME f_devolucao.
        
        IF  LINE-COUNTER(str_1) = PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.

                RUN mostra-totais.
                            
                IF  NOT LAST-OF(tt-logspb-detalhe.dstransa)  THEN
                    DO:
                        DISPLAY STREAM str_1 aux_dstitcab 
                                             WITH FRAME f_titulo.

                        DISPLAY STREAM str_1 aux_pontilha 
                                             WITH FRAME f_cabecalho.
                    END.
            END.
                    
    END. /** Fim do FOR EACH tt-logspb-detalhe **/
                                        
    IF  CAN-FIND(FIRST tt-logspb)  THEN
        DO:
            ASSIGN aux_dstitcab = ">> REJEITADAS".

            IF  aux_flgfirst                                 OR
               (LINE-COUNTER(str_1) + 4) > PAGE-SIZE(str_1)  THEN
                DO:
                    IF  NOT aux_flgfirst  THEN
                        PAGE STREAM str_1.

                    RUN mostra-totais.
                END.

            DISPLAY STREAM str_1 aux_dstitcab WITH FRAME f_titulo.
        END.
                                        
    FOR EACH tt-logspb NO-LOCK BREAK BY tt-logspb.nrseqlog:

        ASSIGN aux_contador = 1.

        DO WHILE TRUE:
                    
            ASSIGN aux_dslinlog = SUBSTR(tt-logspb.dslinlog,
                                  aux_contador,132) NO-ERROR.

            IF  ERROR-STATUS:ERROR       OR
                TRIM(aux_dslinlog) = ""  THEN
                DO:
                    DOWN 1 STREAM str_1 WITH FRAME f_rejeitadas.

                    LEAVE.
                END.

            DISPLAY STREAM str_1 aux_dslinlog WITH FRAME f_rejeitadas.

            DOWN STREAM str_1 WITH FRAME f_rejeitadas.

            ASSIGN aux_contador = aux_contador + 132.

            IF  (LINE-COUNTER(str_1) + 1) > PAGE-SIZE(str_1)  THEN
                DO:
                    PAGE STREAM str_1.

                    RUN mostra-totais.

                    DISPLAY STREAM str_1 aux_dstitcab 
                                         WITH FRAME f_titulo.
                END.
                        
        END. /** Fim do DO WHILE TRUE **/

    END. /** Fim do FOR EACH tt-logspb **/
                                          
    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE.


PROCEDURE le-arquivo-log:

    DEF  INPUT PARAM par_nmarqlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_numedlog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitlog AS CHAR                           NO-UNDO.
        
    INPUT STREAM str_1 FROM VALUE(par_nmarqlog) NO-ECHO.
        
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE ON ERROR UNDO, LEAVE:

        IMPORT STREAM str_1 UNFORMATTED aux_dslinlog.

        IF  par_numedlog = 0  THEN
            DO:
                IF  aux_dslinlog MATCHES "*ENVIADA OK*"  THEN
                    RUN grava-enviada-ok.
                ELSE
                IF  aux_dslinlog MATCHES "*ENVIADA NAO OK*"  THEN 
                    RUN grava-enviada-nok.
                ELSE
                IF  aux_dslinlog MATCHES "*RECEBIDA OK*"  THEN 
                    RUN grava-recebida-ok.
                ELSE
                IF  aux_dslinlog MATCHES "*RECEBIDA NAO OK*"  THEN 
                    RUN grava-recebida-nok.
                ELSE
                IF  aux_dslinlog MATCHES "*REJEITADA OK*" THEN
                    RUN grava-rejeitada-ok. 
                ELSE
                IF  aux_dslinlog MATCHES "*RETORNO JD OK*"    OR
                    aux_dslinlog MATCHES "*RETORNO SPB*"      OR
                    aux_dslinlog MATCHES "*REJEITADA NAO OK*" OR 
                    aux_dslinlog MATCHES "*PAG0101*"          OR
                    aux_dslinlog MATCHES "*STR0018*"          OR
                    aux_dslinlog MATCHES "*STR0019*"        THEN
                    RUN grava-msg-log.
            END.
        ELSE
        IF  par_numedlog = 1  THEN    
            DO:
                IF  par_cdsitlog = "P"  THEN 
                    RUN grava-enviada-ok.
                ELSE
                IF  par_cdsitlog = "D"                       AND
                    aux_dslinlog MATCHES "*ENVIADA NAO OK*"  THEN 
                    RUN grava-enviada-nok.
                ELSE 
                IF  par_cdsitlog = "R"                    AND 
                    aux_dslinlog MATCHES "*REJEITADA OK*" THEN
                    RUN  grava-rejeitada-ok.
            END.
        ELSE
        IF  par_numedlog = 2  THEN    
            DO:
                IF  par_cdsitlog = "P"                    AND 
                    aux_dslinlog MATCHES "*RECEBIDA OK*"  THEN 
                    RUN grava-recebida-ok.
                ELSE
                IF  par_cdsitlog = "D"                        AND
                    aux_dslinlog MATCHES "*RECEBIDA NAO OK*"  THEN 
                    RUN grava-recebida-nok.
            END.
        ELSE
        IF  par_numedlog = 3                          AND
           (aux_dslinlog MATCHES "*RETORNO JD OK*"    OR
            aux_dslinlog MATCHES "*RETORNO SPB*"      OR
            aux_dslinlog MATCHES "*REJEITADA NAO OK*" OR    
            aux_dslinlog MATCHES "*PAG0101*"          OR
            aux_dslinlog MATCHES "*STR0018*"          OR
            aux_dslinlog MATCHES "*STR0019*")         THEN
            RUN grava-msg-log.

    END. /** Fim do DO WHILE TRUE **/

    INPUT STREAM str_1 CLOSE.

END PROCEDURE.


PROCEDURE grava-msg-log:

    CREATE tt-logspb.
    ASSIGN aux_qtrejeit       = aux_qtrejeit + 1
           aux_nrseqlog       = aux_nrseqlog + 1
           tt-logspb.nrseqlog = aux_nrseqlog
           tt-logspb.dslinlog = aux_dslinlog.

    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-enviada-ok:

    ASSIGN aux_dslinlog = SUBSTR(aux_dslinlog,INDEX(aux_dslinlog,"-->") + 4)
           aux_nrseqlog = aux_nrseqlog + 1.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.nrseqlog = aux_nrseqlog
           tt-logspb-detalhe.cdbanrem = INTE(SUBSTR(aux_dslinlog,162,3))
           tt-logspb-detalhe.cdagerem = INTE(SUBSTR(aux_dslinlog,183,4))
           tt-logspb-detalhe.nrctarem = TRIM(SUBSTR(aux_dslinlog,203,9))
           tt-logspb-detalhe.dsnomrem = CAPS(SUBSTR(aux_dslinlog,227,40))
           tt-logspb-detalhe.dscpfrem = DECI(SUBSTR(aux_dslinlog,286,14))
           tt-logspb-detalhe.cdbandst = INTE(SUBSTR(aux_dslinlog,315,3))
           tt-logspb-detalhe.cdagedst = INTE(SUBSTR(aux_dslinlog,335,4))
           tt-logspb-detalhe.nrctadst = TRIM(SUBSTR(aux_dslinlog,354,14))
           tt-logspb-detalhe.dsnomdst = CAPS(SUBSTR(aux_dslinlog,382,40))
           tt-logspb-detalhe.dscpfdst = DECI(SUBSTR(aux_dslinlog,440,14))
           tt-logspb-detalhe.hrtransa = SUBSTR(aux_dslinlog,115,8)
           tt-logspb-detalhe.vltransa = DECI(SUBSTR(aux_dslinlog,132,14))
           tt-logspb-detalhe.dsmotivo = 
                             IF SUBSTR(aux_dslinlog,59,7) = "STR0004"  THEN
                                "STR0004 - " + SUBSTR(aux_dslinlog,454)
                             ELSE
                                ""                                
           tt-logspb-detalhe.dstransa = "ENVIADA OK"
           tt-logspb-detalhe.nrsequen = craplmt.nrsequen.

    ASSIGN aux_qtdenvok = aux_qtdenvok + 1
           aux_vlrenvok = aux_vlrenvok + tt-logspb-detalhe.vltransa.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).

    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-recebida-ok:

    ASSIGN aux_dslinlog = SUBSTR(aux_dslinlog,INDEX(aux_dslinlog,"-->") + 4)
           aux_nrseqlog = aux_nrseqlog + 1.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.nrseqlog = aux_nrseqlog
           tt-logspb-detalhe.cdbanrem = INTE(SUBSTR(aux_dslinlog,162,3))
           tt-logspb-detalhe.cdagerem = INTE(SUBSTR(aux_dslinlog,183,4))
           tt-logspb-detalhe.nrctarem = TRIM(SUBSTR(aux_dslinlog,203,14))
           tt-logspb-detalhe.dsnomrem = CAPS(SUBSTR(aux_dslinlog,232,40))
           tt-logspb-detalhe.dscpfrem = DECI(SUBSTR(aux_dslinlog,291,14))
           tt-logspb-detalhe.cdbandst = INTE(SUBSTR(aux_dslinlog,320,3))
           tt-logspb-detalhe.cdagedst = INTE(SUBSTR(aux_dslinlog,340,4))
           tt-logspb-detalhe.nrctadst = TRIM(SUBSTR(aux_dslinlog,359,14))
           tt-logspb-detalhe.dsnomdst = CAPS(SUBSTR(aux_dslinlog,387,40))
           tt-logspb-detalhe.dscpfdst = DECI(SUBSTR(aux_dslinlog,445,14))
           tt-logspb-detalhe.hrtransa = SUBSTR(aux_dslinlog,115,8)
           tt-logspb-detalhe.vltransa = DECI(SUBSTR(aux_dslinlog,132,14))
           tt-logspb-detalhe.dsmotivo = ""
           tt-logspb-detalhe.dstransa = "RECEBIDA OK"
           tt-logspb-detalhe.nrsequen = craplmt.nrsequen.

    ASSIGN aux_qtdrecok = aux_qtdrecok + 1
           aux_vlrrecok = aux_vlrrecok + tt-logspb-detalhe.vltransa.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).

    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-enviada-nok:

    ASSIGN aux_dslinlog = SUBSTR(aux_dslinlog,INDEX(aux_dslinlog,"-->") + 4)
           aux_nrseqlog = aux_nrseqlog + 1.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.nrseqlog = aux_nrseqlog
           tt-logspb-detalhe.cdbanrem = INTE(SUBSTR(aux_dslinlog,267,3))
           tt-logspb-detalhe.cdagerem = INTE(SUBSTR(aux_dslinlog,288,4))
           tt-logspb-detalhe.nrctarem = TRIM(SUBSTR(aux_dslinlog,308,9))
           tt-logspb-detalhe.dsnomrem = CAPS(SUBSTR(aux_dslinlog,332,40))
           tt-logspb-detalhe.dscpfrem = DECI(SUBSTR(aux_dslinlog,391,14))
           tt-logspb-detalhe.cdbandst = INTE(SUBSTR(aux_dslinlog,420,3))
           tt-logspb-detalhe.cdagedst = INTE(SUBSTR(aux_dslinlog,440,4))
           tt-logspb-detalhe.nrctadst = TRIM(SUBSTR(aux_dslinlog,459,14))
           tt-logspb-detalhe.dsnomdst = CAPS(SUBSTR(aux_dslinlog,487,40))
           tt-logspb-detalhe.dscpfdst = DECI(SUBSTR(aux_dslinlog,545,14))
           tt-logspb-detalhe.hrtransa = SUBSTR(aux_dslinlog,220,8)
           tt-logspb-detalhe.vltransa = DECI(SUBSTR(aux_dslinlog,237,14))
           tt-logspb-detalhe.dsmotivo = CAPS(SUBSTR(aux_dslinlog,83,90))
           tt-logspb-detalhe.dstransa = "ENVIADA NAO OK"
           tt-logspb-detalhe.nrsequen = craplmt.nrsequen.

    ASSIGN aux_qtenvnok = aux_qtenvnok + 1
           aux_vlenvnok = aux_vlenvnok + tt-logspb-detalhe.vltransa.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).

    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-recebida-nok:

    ASSIGN aux_dslinlog = SUBSTR(aux_dslinlog,INDEX(aux_dslinlog,"-->") + 4)
           aux_nrseqlog = aux_nrseqlog + 1.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.nrseqlog = aux_nrseqlog
           tt-logspb-detalhe.cdbanrem = INTE(SUBSTR(aux_dslinlog,267,3))
           tt-logspb-detalhe.cdagerem = INTE(SUBSTR(aux_dslinlog,288,4))
           tt-logspb-detalhe.nrctarem = TRIM(SUBSTR(aux_dslinlog,308,14))
           tt-logspb-detalhe.dsnomrem = CAPS(SUBSTR(aux_dslinlog,337,40))
           tt-logspb-detalhe.dscpfrem = DECI(SUBSTR(aux_dslinlog,396,14))
           tt-logspb-detalhe.cdbandst = INTE(SUBSTR(aux_dslinlog,425,3))
           tt-logspb-detalhe.cdagedst = INTE(SUBSTR(aux_dslinlog,445,4))
           tt-logspb-detalhe.nrctadst = TRIM(SUBSTR(aux_dslinlog,464,14))
           tt-logspb-detalhe.dsnomdst = CAPS(SUBSTR(aux_dslinlog,492,40))
           tt-logspb-detalhe.dscpfdst = DECI(SUBSTR(aux_dslinlog,550,14))
           tt-logspb-detalhe.hrtransa = SUBSTR(aux_dslinlog,220,8)
           tt-logspb-detalhe.vltransa = DECI(SUBSTR(aux_dslinlog,237,14))
           tt-logspb-detalhe.dsmotivo = CAPS(SUBSTR(aux_dslinlog,83,90))
           tt-logspb-detalhe.dstransa = "RECEBIDA NAO OK"
           tt-logspb-detalhe.nrsequen = craplmt.nrsequen.

    ASSIGN aux_qtrecnok = aux_qtrecnok + 1
           aux_vlrecnok = aux_vlrecnok + tt-logspb-detalhe.vltransa.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).

    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).

    RETURN "OK".

END PROCEDURE.

PROCEDURE grava-rejeitada-ok:
    
    ASSIGN aux_dslinlog = SUBSTR(aux_dslinlog,INDEX(aux_dslinlog,"-->") + 4)
           aux_nrseqlog = aux_nrseqlog + 1.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.nrseqlog = aux_nrseqlog
           tt-logspb-detalhe.cdbanrem = INTE(SUBSTR(aux_dslinlog,267,3))
           tt-logspb-detalhe.cdagerem = INTE(SUBSTR(aux_dslinlog,288,4))
           tt-logspb-detalhe.nrctarem = TRIM(SUBSTR(aux_dslinlog,308,9))
           tt-logspb-detalhe.dsnomrem = CAPS(SUBSTR(aux_dslinlog,332,40))
           tt-logspb-detalhe.dscpfrem = DECI(SUBSTR(aux_dslinlog,391,14))
           tt-logspb-detalhe.cdbandst = INTE(SUBSTR(aux_dslinlog,420,3))
           tt-logspb-detalhe.cdagedst = INTE(SUBSTR(aux_dslinlog,440,4))
           tt-logspb-detalhe.nrctadst = TRIM(SUBSTR(aux_dslinlog,459,14))
           tt-logspb-detalhe.dsnomdst = CAPS(SUBSTR(aux_dslinlog,487,40))
           tt-logspb-detalhe.dscpfdst = DECI(SUBSTR(aux_dslinlog,545,14))
           tt-logspb-detalhe.hrtransa = SUBSTR(aux_dslinlog,220,8)
           tt-logspb-detalhe.vltransa = DECI(SUBSTR(aux_dslinlog,237,14))
           tt-logspb-detalhe.dsmotivo = CAPS(SUBSTR(aux_dslinlog,83,90))
           tt-logspb-detalhe.dstransa = "REJEITADA OK"
           tt-logspb-detalhe.nrsequen = craplmt.nrsequen.
           
    ASSIGN aux_qtdrejok = aux_qtdrejok + 1
           aux_vlrrejok = aux_vlrrejok + tt-logspb-detalhe.vltransa.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).

    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE adiciona_digito_zero:

  DEFINE INPUT PARAMETER aux_qtdzeros          AS INTEGER   NO-UNDO.
  DEFINE INPUT-OUTPUT PARAMETER aux_variavel   AS CHARACTER NO-UNDO.
  
  DEFINE VARIABLE aux_contador                 AS INTEGER   NO-UNDO.
  DEFINE VARIABLE aux_contzero                 AS INTEGER   NO-UNDO.
    
  IF   LENGTH(aux_variavel) < aux_qtdzeros  THEN
       DO:
          aux_contzero = aux_qtdzeros - LENGTH(aux_variavel).
          DO aux_contador = 1 TO aux_contzero:
             aux_variavel = "0" + aux_variavel.
          END.
       END.

  RETURN "OK".
END.

PROCEDURE grava-log-ted:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_dttransa AS DATE NO-UNDO.
    DEF INPUT PARAM par_hrtransa AS INTE NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR NO-UNDO.
    DEF INPUT PARAM par_idsitmsg AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmarqmsg AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmevento AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrctrlif AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vldocmto AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdbanctl AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagectl AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmcopcta AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrcpfcop AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdbandif AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagedif AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrctadif AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmtitdif AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrcpfdif AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdidenti AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsmotivo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO. 
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO. 
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrispbif AS INTE NO-UNDO.
    DEF INPUT PARAM par_inestcri AS INTE NO-UNDO.

    DEF BUFFER crablmt FOR craplmt.

    DEFINE VARIABLE aux_nrsequen AS INTE NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTE NO-UNDO.
    DEFINE VARIABLE aux_flgtrans AS LOGI NO-UNDO.
    DEFINE VARIABLE aux_nrcaract AS INTE NO-UNDO.
    DEFINE VARIABLE aux_nrdconta AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_nrctadif AS CHAR NO-UNDO.
    DEFINE VARIABLE aux_caracter AS CHAR NO-UNDO.

    ASSIGN aux_flgtrans = FALSE
           par_nrdconta = TRIM(par_nrdconta).
           par_nrctadif = TRIM(par_nrctadif).

    DECI(par_nrdconta) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:             
            ASSIGN aux_nrdconta = "".

            DO aux_nrcaract = 1 TO LENGTH(par_nrdconta):

                ASSIGN aux_caracter = SUBSTR(par_nrdconta,aux_nrcaract,1).
    
                IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",aux_caracter)  THEN
                    ASSIGN aux_caracter = "0".
    
                ASSIGN aux_nrdconta = aux_nrdconta + aux_caracter.
    
            END.
        END.
    ELSE
        ASSIGN aux_nrdconta = par_nrdconta.

    DECI(par_nrctadif) NO-ERROR.

    IF  ERROR-STATUS:ERROR  THEN
        DO:             
            ASSIGN aux_nrctadif = "".

            DO aux_nrcaract = 1 TO LENGTH(par_nrctadif):

                ASSIGN aux_caracter = SUBSTR(par_nrctadif,aux_nrcaract,1).
    
                IF  NOT CAN-DO("0,1,2,3,4,5,6,7,8,9",aux_caracter)  THEN
                    ASSIGN aux_caracter = "0".
    
                ASSIGN aux_nrctadif = aux_nrctadif + aux_caracter.
    
            END.
        END.
    ELSE
        ASSIGN aux_nrctadif = par_nrctadif.

    DO TRANSACTION ON ERROR UNDO,  LEAVE
                   ON ENDKEY UNDO, LEAVE:

       /* Busca a proxima sequencia  */
       RUN STORED-PROCEDURE pc_sequence_progress
       aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLMT"
                                           ,INPUT "NRSEQUEN"
                                           ,INPUT STRING(par_cdcooper) + ";" + 
                                                  STRING(par_dttransa,"99/99/9999") + ";" + 
                                                  STRING(DECI(aux_nrdconta))
                                           ,INPUT "N"
                                           ,"").
       
       CLOSE STORED-PROC pc_sequence_progress
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                 
       ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
                             WHEN pc_sequence_progress.pr_sequence <> ?.


      

       CREATE craplmt.
       ASSIGN craplmt.cdcooper = par_cdcooper
              craplmt.dttransa = par_dttransa
              craplmt.hrtransa = par_hrtransa
              craplmt.idorigem = par_idorigem
              craplmt.cdprogra = par_cdprogra
              craplmt.idsitmsg = par_idsitmsg
              craplmt.nmarqmsg = par_nmarqmsg
              craplmt.nmevento = par_nmevento
              craplmt.nrctrlif = par_nrctrlif
              craplmt.vldocmto = par_vldocmto
              craplmt.cdbanctl = par_cdbanctl
              craplmt.cdagectl = par_cdagectl
              craplmt.nrdconta = DECI(aux_nrdconta)
              craplmt.nmcopcta = par_nmcopcta
              craplmt.nrcpfcop = par_nrcpfcop
              craplmt.cdbandif = par_cdbandif
              craplmt.cdagedif = par_cdagedif
              craplmt.nrctadif = DECI(aux_nrctadif)
              craplmt.nmtitdif = par_nmtitdif
              craplmt.nrcpfdif = par_nrcpfdif
              craplmt.cdidenti = par_cdidenti
              craplmt.dsmotivo = par_dsmotivo
              craplmt.nrsequen = aux_nrsequen
              craplmt.cdagenci = par_cdagenci
              craplmt.nrdcaixa = par_nrdcaixa
              craplmt.cdoperad = par_cdoperad
              craplmt.nrispbif = par_nrispbif
              craplmt.inestcri = par_inestcri.

       ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION **/

    IF  AVAIL crablmt  THEN
        DO:
            FIND CURRENT crablmt NO-LOCK NO-ERROR.
            RELEASE crablmt.
        END.

    IF  AVAIL craplmt  THEN
        DO:
            FIND CURRENT craplmt NO-LOCK NO-ERROR.
            RELEASE craplmt.
        END.

    IF  NOT aux_flgtrans  THEN
        RETURN "NOK".
    ELSE
        RETURN "OK".

END PROCEDURE.

PROCEDURE imprime-log:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR NO-UNDO.

    DEF INPUT PARAM TABLE FOR tt-logspb.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INT NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                          "/log/arquivo_spb" + par_dsiduser + ".ex".

    UNIX SILENT VALUE("rm " + par_nmarqimp + " 2>/dev/null").

    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp).
            
    FOR EACH tt-logspb NO-LOCK:

        ASSIGN aux_contador = 1.

        DO WHILE TRUE:

            ASSIGN aux_dslinlog = SUBSTR(tt-logspb.dslinlog,
                                         aux_contador,270) NO-ERROR.
                                                   
            IF  ERROR-STATUS:ERROR       OR
                TRIM(aux_dslinlog) = ""  THEN
                LEAVE.

            PUT STREAM str_1 UNFORMATTED aux_dslinlog SKIP.

            ASSIGN aux_contador = aux_contador + 270.

        END. /** Fim do DO WHILE TRUE **/

    END. /** Fim do FOR EACH tt-logspb **/

    OUTPUT STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE mostra-totais:

    DISPLAY STREAM str_1 aux_dtmvtlog 
                         tt-logspb-totais.qtdenvok 
                         tt-logspb-totais.qtenvnok 
                         tt-logspb-totais.qtdrecok 
                         tt-logspb-totais.qtrecnok 
                         tt-logspb-totais.qtrejeit 
                         tt-logspb-totais.vlrenvok 
                         tt-logspb-totais.vlenvnok 
                         tt-logspb-totais.vlrrecok 
                         tt-logspb-totais.vlrecnok 
                         WITH FRAME f_totais.

END PROCEDURE.

PROCEDURE busca-detalhe-transferencia:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI NO-UNDO.
    DEF INPUT PARAM par_dttransa AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-logspb-detalhe.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_cdbanrem AS INTE NO-UNDO.
    DEF VAR aux_cdagerem AS INTE NO-UNDO. 
    DEF VAR aux_nrctarem AS DECI NO-UNDO.
    DEF VAR aux_dsnomrem AS CHAR NO-UNDO.
    DEF VAR aux_dscpfrem AS DECI NO-UNDO.
    DEF VAR aux_cdbandst AS INTE NO-UNDO.
    DEF VAR aux_cdagedst AS INTE NO-UNDO.
    DEF VAR aux_nrctadst AS DECI NO-UNDO.
    DEF VAR aux_dsnomdst AS CHAR NO-UNDO.
    DEF VAR aux_dscpfdst AS DECI NO-UNDO.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-logspb-detalhe.
    EMPTY TEMP-TABLE tt-erro.

    IF CAN-DO("1014,1015", STRING(par_cdhistor)) THEN
    DO:
        IF par_cdhistor = 1014 THEN /* DEBITO */
            FIND FIRST crapldt WHERE crapldt.cdcooper = par_cdcooper
                                 AND crapldt.nrctarem = par_nrdconta
                                 AND crapldt.tpoperac = 4
                                 AND crapldt.dttransa = par_dttransa
                                 AND crapldt.nrctadst = par_nrdocmto /* Conta Destinatario*/
                                 NO-LOCK NO-ERROR.
        ELSE /* 1015 CREDITO */
            FIND FIRST crapldt WHERE crapldt.cdcooper = par_cdcooper
                                 AND crapldt.nrctadst = par_nrdconta
                                 AND crapldt.tpoperac = 4
                                 AND crapldt.dttransa = par_dttransa
                                 AND crapldt.nrctarem = par_nrdocmto /* Conta Remetente */
                                 NO-LOCK NO-ERROR.
            
        IF NOT AVAIL crapldt THEN
        DO:    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Detalhes da transferencia nao encontrados".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        /* DADOS DO REMETENTE */
        
        FIND FIRST crapcop WHERE crapcop.cdagectl = crapldt.cdagerem
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Agencia remetente nao encontrada".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper
                             AND crapass.nrdconta = crapldt.nrctarem
                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Remetente nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
        
        /* DADOS DO DESTINATARIO */

        FIND FIRST crabcop WHERE crabcop.cdagectl = crapldt.cdagedst
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crabcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Agencia destino nao encontrada".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        FIND FIRST crabass WHERE crabass.cdcooper = crabcop.cdcooper
                             AND crabass.nrdconta = crapldt.nrctadst
                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crabass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Destinatario nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        ASSIGN aux_cdbanrem = crapcop.cdbcoctl
               aux_cdagerem = crapldt.cdagerem
               aux_nrctarem = crapldt.nrctarem
               aux_dscpfrem = crapass.nrcpfcgc
               aux_dsnomrem = crapass.nmprimtl
               aux_cdbandst = crabcop.cdbcoctl
               aux_cdagedst = crapldt.cdagedst
               aux_nrctadst = crapldt.nrctadst
               aux_dscpfdst = crabass.nrcpfcgc   
               aux_dsnomdst = crabass.nmprimtl.
              
    END. /*  cdhistor 1014,1015 */
    ELSE
    DO:  /* OUTRAS TRANSFERENCIAS */
        
        IF CAN-DO("1009,1011", STRING(par_cdhistor)) THEN
            FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                                 AND craplcm.nrdconta = par_nrdconta
                                 AND craplcm.dtmvtolt = par_dttransa
                                 AND craplcm.cdhistor = par_cdhistor
                                 AND craplcm.vllanmto = par_vllanmto
                                 AND craplcm.nrdctabb = par_nrdocmto
                                 NO-LOCK NO-ERROR.
        ELSE
            FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                                 AND craplcm.nrdconta = par_nrdconta
                                 AND craplcm.dtmvtolt = par_dttransa
                                 AND craplcm.cdhistor = par_cdhistor
                                 AND craplcm.vllanmto = par_vllanmto
                                 AND SUBSTR(craplcm.cdpesqbb,45,8) 
                                   = STRING(par_nrdocmto,"99999999")
                                 NO-LOCK NO-ERROR.

        IF NOT AVAIL craplcm THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lancamento nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
        
        /* OPERACOES DE DEBITO */
        IF  CAN-DO("375,537,1009",STRING(par_cdhistor)) THEN
        DO:
            IF  par_cdhistor = 1009 THEN
                ASSIGN aux_cdbanrem = craplcm.cdcooper
                       aux_nrctarem = craplcm.nrdconta
                       aux_cdbandst = INTE(SUBSTR(craplcm.dsidenti,10,4))
                       aux_nrctadst = DECI(SUBSTR(craplcm.dsidenti,25,10)).
            ELSE
                ASSIGN aux_cdbanrem = craplcm.cdcooper
                       aux_nrctarem = craplcm.nrdconta
                       aux_cdbandst = craplcm.cdcooper
                       aux_nrctadst = DECI(SUBSTR(craplcm.cdpesqbb,45,8)).
        END.
        ELSE /* OPERACOES DE CREDITO 377,539,1011 */
        DO:
            IF  par_cdhistor = 1011 THEN
                ASSIGN aux_cdbanrem = INTE(SUBSTR(craplcm.dsidenti,10,4))
                       aux_nrctarem = INTE(ENTRY(3,craplcm.dsidenti,":"))
                       aux_cdbandst = craplcm.cdcooper
                       aux_nrctadst = craplcm.nrdconta.
            ELSE
                ASSIGN aux_cdbanrem = craplcm.cdcooper
                       aux_nrctarem = DECI(SUBSTR(craplcm.cdpesqbb,45,8))
                       aux_cdbandst = craplcm.cdcooper
                       aux_nrctadst = craplcm.nrdconta.

        END.


        /* DADOS DO REMETENTE */
        
        IF  par_cdhistor = 1011 THEN
            FIND FIRST crapcop WHERE crapcop.cdagectl = aux_cdbanrem
                               NO-LOCK NO-ERROR.
        ELSE
            FIND FIRST crapcop WHERE crapcop.cdcooper = aux_cdbanrem
                               NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cooperativa remetente nao encontrada".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper
                             AND crapass.nrdconta = aux_nrctarem
                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Remetente nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        /* DADOS DO DESTINATARIO */
        
        IF  par_cdhistor = 1009 THEN
            FIND FIRST crabcop WHERE crabcop.cdagectl = aux_cdbandst
                               NO-LOCK NO-ERROR.
        ELSE 
            FIND FIRST crabcop WHERE crabcop.cdcooper = aux_cdbandst
                               NO-LOCK NO-ERROR.

        IF NOT AVAIL crabcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cooperativa destinatario nao encontrada".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        FIND FIRST crabass WHERE crabass.cdcooper = crabcop.cdcooper
                             AND crabass.nrdconta = aux_nrctadst
                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crabass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Destinatario nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
        
        ASSIGN aux_cdbanrem = crapcop.cdbcoctl
               aux_cdagerem = crapcop.cdagectl
               aux_dscpfrem = crapass.nrcpfcgc
               aux_dsnomrem = crapass.nmprimtl
               aux_cdbandst = crabcop.cdbcoctl
               aux_cdagedst = crabcop.cdagectl
               aux_dscpfdst = crabass.nrcpfcgc   
               aux_dsnomdst = crabass.nmprimtl.

    END. /* Fim OUTROS LANCAMENTOS */
    
    IF AVAIL crabcop THEN
       RELEASE crabcop.

    IF AVAIL crabass THEN
       RELEASE crabass.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.dttransa = par_dttransa
           tt-logspb-detalhe.cdbanrem = aux_cdbanrem
           tt-logspb-detalhe.cdagerem = aux_cdagerem
           tt-logspb-detalhe.nrctarem = STRING(aux_nrctarem)
           tt-logspb-detalhe.dsnomrem = aux_dsnomrem
           tt-logspb-detalhe.dscpfrem = aux_dscpfrem
           tt-logspb-detalhe.cdbandst = aux_cdbandst
           tt-logspb-detalhe.cdagedst = aux_cdagedst
           tt-logspb-detalhe.nrctadst = STRING(aux_nrctadst)
           tt-logspb-detalhe.dsnomdst = aux_dsnomdst
           tt-logspb-detalhe.dscpfdst = aux_dscpfdst.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14, 
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).
    
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).

   
    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-detalhe-doc:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR NO-UNDO.
    DEF INPUT PARAM par_cdorigem AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS DECI NO-UNDO.
    DEF INPUT PARAM par_dttransa AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-logspb-detalhe.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_cdbanrem AS INTE NO-UNDO.
    DEF VAR aux_cdagerem AS INTE NO-UNDO. 
    DEF VAR aux_nrctarem AS DECI NO-UNDO.
    DEF VAR aux_dsnomrem AS CHAR NO-UNDO.
    DEF VAR aux_dscpfrem AS DECI NO-UNDO.
    DEF VAR aux_cdbandst AS INTE NO-UNDO.
    DEF VAR aux_cdagedst AS INTE NO-UNDO.
    DEF VAR aux_nrctadst AS DECI NO-UNDO.
    DEF VAR aux_dsnomdst AS CHAR NO-UNDO.
    DEF VAR aux_dscpfdst AS DECI NO-UNDO.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-logspb-detalhe.
    EMPTY TEMP-TABLE tt-erro.
    
    /* DEBITO */
    IF CAN-DO("103,355", STRING(par_cdhistor)) THEN
    DO:
        FIND FIRST craptvl WHERE craptvl.cdcooper = par_cdcooper
                             AND craptvl.dtmvtolt = par_dttransa
                             AND craptvl.nrdconta = par_nrdconta
                             AND craptvl.nrdocmto = par_nrdocmto
                             AND craptvl.vldocrcb = par_vllanmto
                             NO-LOCK NO-ERROR.

        IF NOT AVAIL craptvl THEN
        DO:    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Detalhes do DOC nao encontrados".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        /* DADOS DO REMETENTE */
        
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Agencia remetente nao encontrada".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
        
        ASSIGN aux_cdbanrem = crapcop.cdbcoctl
               aux_cdagerem = crapcop.cdagectl
               aux_nrctarem = craptvl.nrdconta
               aux_dscpfrem = craptvl.cpfcgemi
               aux_dsnomrem = craptvl.nmpesemi
               aux_cdbandst = craptvl.cdbccrcb
               aux_cdagedst = craptvl.cdagercb
               aux_nrctadst = craptvl.nrcctrcb
               aux_dscpfdst = craptvl.cpfcgrcb   
               aux_dsnomdst = craptvl.nmpesrcb.
              
    END. /*  FIM cdhistor 103,355 */
    ELSE /* -> CREDITO */
    DO:  /* INICIO cdhistor 575 */
        FIND FIRST craplcm WHERE craplcm.cdcooper = par_cdcooper
                             AND craplcm.nrdconta = par_nrdconta
                             AND craplcm.dtmvtolt = par_dttransa
                             AND craplcm.nrdocmto = par_nrdocmto
                             AND craplcm.vllanmto = par_vllanmto
                             NO-LOCK NO-ERROR.
        IF NOT AVAIL craplcm THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Lancamento do DOC nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        FIND FIRST gncpdoc WHERE gncpdoc.cdcooper = craplcm.cdcooper
                             AND gncpdoc.nrdconta = craplcm.nrdconta
                             AND gncpdoc.dtmvtolt = craplcm.dtmvtolt
                             AND gncpdoc.nrdocmto = craplcm.nrdocmto
                             NO-LOCK NO-ERROR.
        IF AVAIL gncpdoc THEN
        DO:
            ASSIGN aux_dscpfrem = gncpdoc.cpfcgemi
                   aux_dsnomrem = gncpdoc.nmpesemi.
        END.

        ASSIGN aux_cdbanrem = craplcm.cdbanchq
               aux_cdagerem = craplcm.cdagechq
               aux_nrctarem = craplcm.nrctachq.

        /* DESTINATARIO */
        
        FIND FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper
                               NO-LOCK NO-ERROR.

        IF NOT AVAIL crabcop THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cooperativa destinatario nao encontrada".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        FIND FIRST crabass WHERE crabass.cdcooper = crabcop.cdcooper
                             AND crabass.nrdconta = par_nrdconta                             NO-LOCK NO-ERROR.
        
        IF NOT AVAIL crabass THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Destinatario nao encontrado".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
        
       ASSIGN aux_cdbandst = crabcop.cdbcoctl
              aux_cdagedst = crabcop.cdagectl
              aux_nrctadst = crabass.nrdconta
              aux_dscpfdst = crabass.nrcpfcgc   
              aux_dsnomdst = crabass.nmprimtl.

    END. /* Fim cdhistor 575 */
    
    IF AVAIL crabcop THEN
       RELEASE crabcop.

    IF AVAIL crabass THEN
       RELEASE crabass.

    CREATE tt-logspb-detalhe.
    ASSIGN tt-logspb-detalhe.dttransa = par_dttransa
           tt-logspb-detalhe.cdbanrem = aux_cdbanrem
           tt-logspb-detalhe.cdagerem = aux_cdagerem
           tt-logspb-detalhe.nrctarem = STRING(aux_nrctarem)
           tt-logspb-detalhe.dsnomrem = aux_dsnomrem
           tt-logspb-detalhe.dscpfrem = aux_dscpfrem
           tt-logspb-detalhe.cdbandst = aux_cdbandst
           tt-logspb-detalhe.cdagedst = aux_cdagedst
           tt-logspb-detalhe.nrctadst = STRING(aux_nrctadst)
           tt-logspb-detalhe.dsnomdst = aux_dsnomdst
           tt-logspb-detalhe.dscpfdst = aux_dscpfdst.

    /* Variaveis CHAR
       Como pode haver digito X nas contas - adicionar 0 a frente
       PS: mesmo a conta do remetente pode ter, pois pode ser o
       remetente de outra instituicao financeira. */
    RUN adiciona_digito_zero (INPUT 14, 
                              INPUT-OUTPUT tt-logspb-detalhe.nrctarem).
    
    RUN adiciona_digito_zero (INPUT 14,
                              INPUT-OUTPUT tt-logspb-detalhe.nrctadst).

   
    RETURN "OK".

END PROCEDURE.

/******************************************************************************
Procedure para obter log das transferencias intercooperativas do sistema CECRED
******************************************************************************/
PROCEDURE obtem-log-sistema-cecred:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniper AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimper AS DATE                           NO-UNDO.
	
    DEF OUTPUT PARAM TABLE FOR tt-logspb-detalhe.
    
    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-logspb-detalhe.

	FOR EACH craplcm WHERE craplcm.cdcooper =  par_cdcooper AND
                           craplcm.nrdconta =  par_nrdconta AND
                           craplcm.dtmvtolt >= par_dtiniper AND
                           craplcm.dtmvtolt <= par_dtfimper AND
                          (craplcm.cdhistor = 539   OR
                           craplcm.cdhistor = 1011  OR
                           craplcm.cdhistor = 1015) NO-LOCK:
	
        IF  CAN-DO("539,1015", STRING(craplcm.cdhistor)) THEN
        	DO:
                /* Dados do remetente */
                FOR FIRST crapcop WHERE 
                          crapcop.cdcooper = craplcm.cdcooper NO-LOCK. END.
             
                IF  NOT AVAIL crapcop  THEN
                    NEXT.
             
                FOR FIRST crapass WHERE 
                          crapass.cdcooper = crapcop.cdcooper AND
                          crapass.nrdconta = INTE(SUBSTR(craplcm.cdpesqbb,45,8)) 
                          NO-LOCK. END.
             
                IF  NOT AVAIL crapass  THEN
                    NEXT.
             
                /* Dados do destinatário */
                FOR FIRST crabcop WHERE 
                          crabcop.cdcooper = craplcm.cdcooper NO-LOCK. END.
             
                IF  NOT AVAIL crabcop  THEN
                    NEXT.
             
                FOR FIRST crabass WHERE 
                          crabass.cdcooper = crabcop.cdcooper AND
                          crabass.nrdconta = craplcm.nrdconta NO-LOCK. END.
             
                IF  NOT AVAIL crabass  THEN
                    NEXT.
        	END.
    	ELSE
        	DO:
        	    /* Dados do remetente */
                FOR FIRST crapcop WHERE 
                          crapcop.cdagectl = INTE(SUBSTR(craplcm.cdpesqbb,10,4)) 
                          NO-LOCK. END.

                IF  NOT AVAIL crapcop  THEN
                    NEXT.
                
                FOR FIRST crapass WHERE
                          crapass.cdcooper = crapcop.cdcooper AND
                          crapass.nrdconta = craplcm.nrdctabb NO-LOCK. END.

                IF  NOT AVAIL crapass  THEN
                    NEXT.
         
                /* Dados do destinatário */
                FOR FIRST crabcop WHERE 
                          crabcop.cdcooper = craplcm.cdcooper NO-LOCK. END.

                IF  NOT AVAIL crabcop  THEN
                    NEXT.

                FOR FIRST crabass WHERE
                          crabass.cdcooper = crabcop.cdcooper AND
                          crabass.nrdconta = craplcm.nrdconta NO-LOCK. END.

                IF  NOT AVAIL crabass  THEN
                    NEXT.
        	END.
	
	    CREATE tt-logspb-detalhe.
		ASSIGN tt-logspb-detalhe.cdbanrem = crapcop.cdbcoctl
			   tt-logspb-detalhe.cdagerem = crapcop.cdagectl
			   tt-logspb-detalhe.nrctarem = STRING(crapass.nrdconta)
			   tt-logspb-detalhe.dsnomrem = crapass.nmprimtl
			   tt-logspb-detalhe.dscpfrem = crapass.nrcpfcgc
			   tt-logspb-detalhe.cdbandst = crabcop.cdbcoctl
			   tt-logspb-detalhe.cdagedst = crabcop.cdagectl
			   tt-logspb-detalhe.nrctadst = STRING(crabass.nrdconta)
			   tt-logspb-detalhe.dsnomdst = crabass.nmprimtl
			   tt-logspb-detalhe.dscpfdst = crabass.nrcpfcgc
			   tt-logspb-detalhe.dttransa = craplcm.dtmvtolt
			   tt-logspb-detalhe.hrtransa = STRING(craplcm.hrtransa, "HH:MM:SS")
			   tt-logspb-detalhe.vltransa = craplcm.vllanmto
			   tt-logspb-detalhe.cdtiptra = 1
			   tt-logspb-detalhe.dstiptra = "TRANSFERENCIA".
	
	END. /* Fim do FOR EACH craplcm */

END PROCEDURE.

PROCEDURE impressao-log-pdf:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgidlog AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtlog AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_numedlog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.        
    DEF  INPUT PARAM par_vlrdated AS DECIMAL                        NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inestcri AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.    

    FORM 
         tt-logspb-detalhe.dttransa COLUMN-LABEL "Data"          FORMAT "99/99/9999"
         tt-logspb-detalhe.nmevento COLUMN-LABEL "Mensagem"      FORMAT "x(10)"
         tt-logspb-detalhe.nrctrlif COLUMN-LABEL "Num.Controle"  FORMAT "x(20)"                         
         tt-logspb-detalhe.cdbandst COLUMN-LABEL "Banco Dst."    FORMAT "zz9"
         tt-logspb-detalhe.cdagedst COLUMN-LABEL "Age. Dst."     FORMAT "zzz9"
         tt-logspb-detalhe.nrctadst COLUMN-LABEL "Conta Dst."    FORMAT "xxxx.xxx.xxx.xxx.xxx.xxx-x"
         tt-logspb-detalhe.dscpfdst COLUMN-LABEL "Cpf/Cnpj Dst." FORMAT "99999999999999"
         tt-logspb-detalhe.dsnomdst COLUMN-LABEL "Nome Dst."     FORMAT "x(16)"                         
         tt-logspb-detalhe.cdbanrem COLUMN-LABEL "Banco Rem."    FORMAT "zz9"
         tt-logspb-detalhe.cdagerem COLUMN-LABEL "Age. Rem."     FORMAT "zzz9"
         tt-logspb-detalhe.nrctarem COLUMN-LABEL "Conta Rem."    FORMAT "xxxx.xxx.xxx.xxx.xxx.xxx-x"
         tt-logspb-detalhe.dscpfrem COLUMN-LABEL "Cpf/Cnpj Rem." FORMAT "99999999999999"
         tt-logspb-detalhe.dsnomrem COLUMN-LABEL "Nome Rem."     FORMAT "x(16)"                         
         tt-logspb-detalhe.vltransa COLUMN-LABEL "Valor"         FORMAT "zzz,zzz,zz9.99"                
         tt-logspb-detalhe.hrtransa COLUMN-LABEL "Hora"          FORMAT "x(10)"
    WITH NO-BOX DOWN WIDTH 234 FRAME f_todos.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.    
       
    /* Buscar movimentacoes das TEDs/TECs - Cecred  */
    RUN obtem-log-cecred (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_dtmvtlog,
                          INPUT par_dtmvtlog,
                          INPUT par_numedlog,
                          INPUT par_cdsitlog,
                          INPUT par_nrdconta,
                          INPUT 0,
                          INPUT 1,
                          INPUT 0, /*Qtd registros passar 0 pra trazer 9999999*/
                          INPUT par_inestcri,
                          INPUT (IF par_flgidlog = 2 THEN
									0 /*Somente ted CECRED*/
								 ELSE
								    1 /*Somente ted SICREDI*/),
                          INPUT par_vlrdated,
                         OUTPUT TABLE tt-logspb,
                         OUTPUT TABLE tt-logspb-detalhe,
                         OUTPUT TABLE tt-logspb-totais,
                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/RelLogspbTed_" + 
                          par_dsiduser + "_" + STRING(TIME,"99999") + ".ex".
      
    UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").
                            
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.
    
    FOR EACH tt-logspb-detalhe NO-LOCK:
        
        DISPLAY STREAM str_1 tt-logspb-detalhe.dttransa
                             tt-logspb-detalhe.nmevento 
                             tt-logspb-detalhe.nrctrlif 
                             tt-logspb-detalhe.cdbandst 
                             tt-logspb-detalhe.cdagedst 
                             tt-logspb-detalhe.nrctadst 
                             tt-logspb-detalhe.dscpfdst 
                             tt-logspb-detalhe.dsnomdst 
                             tt-logspb-detalhe.cdbanrem 
                             tt-logspb-detalhe.cdagerem 
                             tt-logspb-detalhe.nrctarem 
                             tt-logspb-detalhe.dscpfrem 
                             tt-logspb-detalhe.dsnomrem 
                             tt-logspb-detalhe.vltransa 
                             tt-logspb-detalhe.hrtransa 
                         WITH FRAME f_todos.
                             
        DOWN STREAM str_1 WITH FRAME f_todos.        
        
    END.
    
    OUTPUT STREAM str_1 CLOSE.
    
    RUN sistema/generico/procedures/b1wgen0024.p 
        PERSISTENT SET h-b1wgen0024.
       
    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,         
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        
        RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT aux_nmarqimp,
                                              OUTPUT par_nmarqpdf,
                                              OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE = "NOK" THEN
            RETURN "NOK".
     

END PROCEDURE.

PROCEDURE impressao-log-csv:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgidlog AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtlog AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_numedlog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.        
    DEF  INPUT PARAM par_vlrdated AS DECIMAL                        NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inestcri AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.       

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.    
       
    /* Buscar movimentacoes das TEDs/TECs - Cecred  */
    RUN obtem-log-cecred (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_cdoperad,
                          INPUT par_nmdatela,
                          INPUT par_idorigem,
                          INPUT par_dtmvtlog,
                          INPUT par_dtmvtlog,
                          INPUT par_numedlog,
                          INPUT par_cdsitlog,
                          INPUT par_nrdconta,
                          INPUT 0,
                          INPUT 1,
                          INPUT 0, /*Qtd registros passar 0 pra trazer 9999999*/
                          INPUT par_inestcri,
                          INPUT (IF par_flgidlog = 2 THEN
									0 /*Somente ted CECRED*/
								 ELSE
								    1 /*Somente ted SICREDI*/),
                          INPUT par_vlrdated,
                         OUTPUT TABLE tt-logspb,
                         OUTPUT TABLE tt-logspb-detalhe,
                         OUTPUT TABLE tt-logspb-totais,
                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/RelLogspbTed_" + 
                          par_dsiduser + "_" + STRING(TIME,"99999") + ".csv".              
                                   
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp).
    
    PUT STREAM str_1 UNFORMATTED "Data;Mensagem;Num.Controle;Banco Dst.;Age. Dst.;Conta Dst.;Cpf/Cnpj Dst.;Nome Dst.;" + 
                                 "Banco Rem.;Age. Rem.;Conta Rem.;Cpf/Cnpj Rem.;Nome Rem.;Valor;Hora;" SKIP.
    
    FOR EACH tt-logspb-detalhe NO-LOCK:
        
        PUT STREAM str_1 tt-logspb-detalhe.dttransa FORMAT "99/99/9999" ";"
                         tt-logspb-detalhe.nmevento FORMAT "x(20)" ";" 
                         tt-logspb-detalhe.nrctrlif FORMAT "x(20)" ";"
                         tt-logspb-detalhe.cdbandst FORMAT "zz9" ";"
                         tt-logspb-detalhe.cdagedst FORMAT "zzz9" ";"
                         tt-logspb-detalhe.nrctadst FORMAT "xxxx.xxx.xxx.xxx.xxx.xxx-x" ";"
                         tt-logspb-detalhe.dscpfdst FORMAT "99999999999999" ";"
                         tt-logspb-detalhe.dsnomdst FORMAT "x(50)" ";"
                         tt-logspb-detalhe.cdbanrem FORMAT "zz9" ";"
                         tt-logspb-detalhe.cdagerem FORMAT "zzz9" ";"
                         tt-logspb-detalhe.nrctarem FORMAT "xxxx.xxx.xxx.xxx.xxx.xxx-x" ";"
                         tt-logspb-detalhe.dscpfrem FORMAT "99999999999999" ";"
                         tt-logspb-detalhe.dsnomrem FORMAT "x(50)" ";"
                         tt-logspb-detalhe.vltransa FORMAT "zzz,zzz,zz9.99" ";"
                         tt-logspb-detalhe.hrtransa FORMAT "x(10)" ";" SKIP.                   
        
    END.
    
    OUTPUT STREAM str_1 CLOSE.       
     
     RUN sistema/generico/procedures/b1wgen0024.p 
        PERSISTENT SET h-b1wgen0024.
       
    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,         
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        
        RUN envia-arquivo-web IN h-b1wgen0024 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT aux_nmarqimp,
                                              OUTPUT par_nmarqimp,
                                              OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0024.

        IF  RETURN-VALUE = "NOK" THEN
            RETURN "NOK".     
     
     IF  aux_nmarqimp <> "" THEN    
        UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2> /dev/null").
     
    RETURN "OK".
  
END PROCEDURE.


/*............................................................................*/
