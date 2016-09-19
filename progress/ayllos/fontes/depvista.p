/*..............................................................................
                    
    Programa: fontes/depvista.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor(a): David
    Data    : Setembro/2010                   Ultima atualizacao: 14/10/2015
   
    Dados referentes ao programa:
   
    Frequencia: Diario (on-line)
    Objetivo  : Mostrar a rotina DEP.VISTA na tela ATENDA.
    
    Alteracoes: 22/08/2011 - Incluir o campo dsidenti na listagem do extrato
                             (Gabriel).
                              
                15/09/2011 - Utilizar BO 83 da tela EXTRAT para listagem do
                             extrato (David).             
                             
                09/02/2012 - Utilizar BO b1wgen0112 para imprimir extrato da
                             conta corrente (David).             
                             
                12/04/2012 - Apresentar mensagem referente a liberacao de
                             emprestimos (David).
                             
                18/06/2013 - Busca Saldo Bloqueio Judicial
                            (Andre Santos - SUPERO)           
    
                09/07/2013 - Retirado tel_flgtarif da tela este processo nao
                             sera mais feito manualmente, projeto tarifas (Tiago). 
                             
                31/07/2013 - Adicionados parametros na procedure Busca_Extrato (Lucas)
                
                11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)
                             
                02/06/2014 - Concatena o numero do servidor no endereco do
                             terminal (Tiago-RKAM).
                
               21/01/2015 - Inclusao do parametro aux_intpextr na chamada da funcao
                            Gera_Impressao para ser usado na pc_gera_impressao_car.
                            (Carlos Rafael Tanholi - Projeto Captacao)    
               
               14/10/2015 - Adicionado novos campos média do mês atual e dias úteis decorridos.
						    SD 320300 (Kelvin).             
                
..............................................................................*/

{ includes/var_online.i}
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0103tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.

DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0027 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0112 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dslibera AS CHAR EXTENT 2                                  NO-UNDO.
DEF VAR aux_dtmvtolt AS CHAR                                           NO-UNDO.
DEF VAR aux_dshistor AS CHAR                                           NO-UNDO.
DEF VAR aux_vllanmto AS CHAR                                           NO-UNDO.
DEF VAR aux_vlsdtota AS CHAR                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!"                                NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_lsrelext AS CHAR 
        INIT "SOMENTE EXTRATO,CHEQUES,DEP.IDENTIFICADOS,TODOS"         NO-UNDO.

DEF VAR aux_flgerlog AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR aux_flgcance AS LOGI                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_vlsdante AS DECI                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_inrelext AS INTE                                           NO-UNDO.

DEF VAR tel_nmmesano AS CHAR EXTENT 7                                  NO-UNDO.
DEF VAR tel_vlsmdmes AS CHAR EXTENT 7                                  NO-UNDO.
DEF VAR tel_titsldos AS CHAR                                           NO-UNDO.
DEF VAR tel_dsrelext AS CHAR                                           NO-UNDO.
DEF VAR tel_dshistor AS CHAR                                           NO-UNDO.
DEF VAR tel_dsliblan AS CHAR                                           NO-UNDO.
DEF VAR tel_dsimprim AS CHAR                                           NO-UNDO.
DEF VAR tel_dscancel AS CHAR                                           NO-UNDO.

DEF VAR tel_vlbscpmf AS DECI EXTENT 2                                  NO-UNDO.
DEF VAR tel_vlpgcpmf AS DECI EXTENT 2                                  NO-UNDO.

DEF VAR tel_dsexcpmf AS INTE EXTENT 2                                  NO-UNDO.

DEF VAR tel_dtiniper AS DATE                                           NO-UNDO.
DEF VAR tel_dtfimper AS DATE                                           NO-UNDO.

DEF VAR tel_flgtarif AS LOGI                                           NO-UNDO.

DEF VAR par_flgrodar AS LOGI                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.

DEF VAR btn_extratos AS CHAR INIT "Extrato"                            NO-UNDO.
DEF VAR btn_sldmedio AS CHAR INIT "Medias"                             NO-UNDO.
DEF VAR btn_imprextr AS CHAR INIT "Imprime Extrato"                    NO-UNDO.
DEF VAR btn_extdcpmf AS CHAR INIT "CPMF"                               NO-UNDO.
DEF VAR btn_sldanter AS CHAR INIT "Saldos Anteriores"                  NO-UNDO.
DEF VAR btn_extdcash AS CHAR INIT "Cash"                               NO-UNDO.
/* tipo de extrato (1=Simplificado, 2=Detalhado) */
DEF  VAR aux_intpextr AS INTE INIT 0                                   NO-UNDO.

DEF QUERY q_extrato FOR tt-extrato_conta.
DEF QUERY q_cash    FOR tt-extcash.

DEF BROWSE b_extrato QUERY q_extrato DISPLAY
    aux_dtmvtolt              LABEL "Data"          FORMAT "x(10)"
    aux_dshistor              LABEL "Historico"     FORMAT "x(18)"
    tt-extrato_conta.nrdocmto LABEL "Documento"     FORMAT "x(12)"
    tt-extrato_conta.indebcre LABEL "D/C"           FORMAT " x "
    aux_vllanmto              LABEL "       Valor"  FORMAT "x(12)"
    aux_vlsdtota              LABEL "        Saldo" FORMAT "x(14)" 
    WITH 8 DOWN NO-BOX NO-LABEL.

DEF BROWSE b_cash QUERY q_cash DISPLAY
    tt-extcash.dtrefere LABEL "Data de emissao"            FORMAT "99/99/9999"
    tt-extcash.dtmesano LABEL "Data ref"                   FORMAT "x(8)"
    tt-extcash.cdagenci LABEL "PA "                        FORMAT "zz9"
    tt-extcash.nrnmterm LABEL "Numero terminal financeiro" FORMAT "x(35)"
    tt-extcash.inisenta LABEL "Tarifou"                    FORMAT "  SIM/  NAO"
    WITH 9 DOWN NO-BOX NO-LABEL.

FORM b_extrato
     HELP "Utilize as setas para navegar ou pressione <F4> para voltar"
     SKIP
     "----------------------------------------------------------------" AT 03
     SPACE(0)
     "----------"
     SKIP
     tel_dshistor              AT 03 LABEL "Historico" FORMAT "x(27)"
     tt-extrato_conta.dsidenti AT 42 NO-LABEL          FORMAT "x(14)" 
     tel_dsliblan              AT 57 LABEL "Dt.Libera" FORMAT  "x(9)"
     WITH ROW 8 CENTERED SIDE-LABELS OVERLAY TITLE " Extrato " FRAME f_extrato.

FORM b_cash
     HELP "Utilize as setas para navegar ou pressione <F4> para voltar"
     WITH ROW 9 CENTERED OVERLAY 
          TITLE " Emissao de Extratos Via Caixa Eletronico " FRAME f_cash.

FORM tel_dtiniper AT 02 LABEL "Entre com a Data Inicial" FORMAT "99/99/9999"
         HELP "Informe a Data Inicial ou Enter para o Mes Corrente"
     WITH ROW 13 WIDTH 40 CENTERED OVERLAY SIDE-LABELS FRAME f_periodo.

FORM tel_dtiniper AT 02 LABEL "Entre com a Data Desejada" FORMAT "99/99/9999"
         HELP "Informe a Data Desejada"
     WITH ROW 13 WIDTH 41 CENTERED OVERLAY SIDE-LABELS FRAME f_data.

FORM tel_dtiniper LABEL "Periodo"  FORMAT "99/99/9999"
         HELP "Informe a Data Inicial ou Enter para o Mes Corrente"
     "a"
     tel_dtfimper NO-LABEL         FORMAT "99/99/9999"
         HELP "Informe a Data Final ou Enter para o Mes Corrente"
     SPACE(2)
     "Listar?"
     tel_dsrelext NO-LABEL         FORMAT "x(17)" 
         HELP "Informe 'SOMENTE EXTRATO','CHEQUES','DEP.IDENTIFICADOS','TODOS'"
     SPACE(12)
     WITH NO-BOX NO-LABEL ROW 20 COLUMN 4 OVERLAY SIDE-LABELS 
          FRAME f_imprime_extrato.

FORM SKIP(1)
     tt-saldos.vlsddisp AT 08 LABEL "Disponivel"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     tt-saldos.vlsaqmax AT 43 LABEL "SAQUE MAXIMO"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdbloq AT 09 LABEL "Bloqueado"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     tt-saldos.vlacerto AT 40 LABEL "ACERTO DE CONTA"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdblpr AT 03 LABEL "Bloqueado Praca"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdblfp AT 02 LABEL "Bloq. Fora Praca"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     tt-saldos.vlipmfpg AT 41 LABEL "Prox. Db. CPMF"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdchsl AT 04 LABEL "Cheque Salario"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlblqjud AT 04 LABEL "Bloq. Judicial"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlstotal AT 07 LABEL "Saldo Total"
                              FORMAT "zzz,zzz,zzz,zz9.99-" 
     SKIP(1)
     tt-saldos.vllimcre AT 03 LABEL "Lim. de Credito"
                              FORMAT "zzz,zzz,zzz,zz9.99"
     tt-saldos.dslimcre AT 39 NO-LABEL
                              FORMAT "x(4)"
     tt-saldos.dtultlcr AT 47 LABEL "Ultima Atualizacao"
                              FORMAT "99/99/9999"
     SKIP(1)         
     btn_extratos AT 05 NO-LABEL FORMAT "x(7)"  
     btn_sldmedio AT 15 NO-LABEL FORMAT "x(6)"
     btn_imprextr AT 24 NO-LABEL FORMAT "x(15)"
     btn_extdcpmf AT 42 NO-LABEL FORMAT "x(4)"
     btn_sldanter AT 49 NO-LABEL FORMAT "x(17)"
     btn_extdcash AT 69 NO-LABEL FORMAT "x(4)"
     WITH ROW 8 CENTERED NO-LABELS SIDE-LABELS OVERLAY
          TITLE " Depositos A Vista " FRAME f_depvista.

FORM SKIP(1)
     tel_nmmesano[1]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[1]         AT 17 NO-LABEL FORMAT "x(14)"
     tt-comp_medias.vlsmnmes AT 33 LABEL "Media Negativa do Mes"
                             FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_nmmesano[2]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[2]         AT 17 NO-LABEL FORMAT "x(14)"
     SKIP
     tel_nmmesano[3]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[3]         AT 17 NO-LABEL FORMAT "x(14)"
     tt-comp_medias.vlsmnesp AT 32 LABEL "Media Neg. Esp. do Mes"
                             FORMAT "zzz,zzz,zz9.99-"
     SKIP
     tel_nmmesano[4]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[4]         AT 17 NO-LABEL FORMAT "x(14)"
     SKIP
     tel_nmmesano[5]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[5]         AT 17 NO-LABEL FORMAT "x(14)"
     tt-comp_medias.vlsmnblq AT 32 LABEL "Med. Saque s/bloqueado"
                             FORMAT "zzz,zzz,zz9.99-" 
     SKIP
     tel_nmmesano[6]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[6]         AT 17 NO-LABEL FORMAT "x(14)"
     SKIP
     tel_nmmesano[7]         AT 08 NO-LABEL FORMAT "x(9)"
     tel_vlsmdmes[7]         AT 17 NO-LABEL FORMAT "x(14)"
     tt-comp_medias.qtdiaute AT 37 LABEL "Dias Uteis no Mes" 
                             FORMAT "z9"
     SKIP
     tt-comp_medias.vltsddis AT 07 LABEL "Mes Atual"
                             FORMAT "zzz,zzz,zz9.99-"
     tt-comp_medias.qtdiauti AT 33 LABEL "Dias Uteis Decorridos"
                             FORMAT "z9"
     
     SKIP
     tt-comp_medias.vlsmdtri AT 07 LABEL "Trimestre"
                             FORMAT "zzz,zzz,zz9.99-" 
     tt-comp_medias.vlsmdsem AT 08 LABEL "Semestre" 
                             FORMAT "zzz,zzz,zz9.99-" 
     WITH ROW 9 CENTERED NO-LABELS SIDE-LABELS OVERLAY
          TITLE " Saldo Medio " FRAME f_medias.

FORM SKIP(1)
     "Exercicio" AT 22 tel_dsexcpmf[1] FORMAT "9999" NO-LABEL
     "Exercicio" AT 43 tel_dsexcpmf[2] FORMAT "9999" NO-LABEL
     SKIP(1)
     "Base de calculo:" AT 02  
     tel_vlbscpmf[1] NO-LABEL FORMAT "zz,zzz,zzz,zz9.99" SPACE(4)
     tel_vlbscpmf[2] NO-LABEL FORMAT "zz,zzz,zzz,zz9.99"
     SKIP(1)
     "Valor pago:" AT 02
     tel_vlpgcpmf[1] NO-LABEL FORMAT "zz,zzz,zzz,zz9.99" SPACE(4)
     tel_vlpgcpmf[2] NO-LABEL FORMAT "zz,zzz,zzz,zz9.99" SPACE(1)
     SKIP(1)
     WITH ROW 12 CENTERED NO-LABELS SIDE-LABELS OVERLAY 
          TITLE " CPMF " FRAME f_cpmf.

FORM SKIP(1)
     tt-saldos.vlsddisp AT 08 LABEL "Disponivel"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdbloq AT 09 LABEL "Bloqueado"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdblpr AT 03 LABEL "Bloqueado Praca"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdblfp AT 02 LABEL "Bloq. Fora Praca"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdchsl AT 04 LABEL "Cheque Salario"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlsdindi AT 06 LABEL "Indisponivel"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlblqjud AT 04 LABEL "Bloq. Judicial"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP
     tt-saldos.vlstotal AT 07 LABEL "Saldo Total"
                              FORMAT "zzz,zzz,zzz,zz9.99-"
     SKIP(1)
     tt-saldos.vllimcre AT 03 LABEL "Lim. de Credito" 
                              FORMAT "zzz,zzz,zzz,zz9.99"
     WITH ROW 9 CENTERED NO-LABELS SIDE-LABELS OVERLAY
          TITLE tel_titsldos FRAME f_saldos_anteriores.  

ON ROW-DISPLAY OF b_extrato IN FRAME f_extrato DO:

    ASSIGN aux_dtmvtolt = IF  tt-extrato_conta.nrsequen = 0  THEN
                              "          "
                          ELSE
                              STRING(tt-extrato_conta.dtmvtolt,"99/99/9999")
           aux_dshistor = IF  tt-extrato_conta.nrsequen = 0  THEN
                              tt-extrato_conta.dshistor
                          ELSE
                              STRING(tt-extrato_conta.cdhistor,"9999") + "-" + 
                              tt-extrato_conta.dshistor
           aux_vllanmto = IF  tt-extrato_conta.nrsequen = 0  THEN
                              "            "
                          ELSE
                              STRING(tt-extrato_conta.vllanmto,"zzzzz,zz9.99")
           aux_vlsdtota = IF  tt-extrato_conta.vlsdtota = 0  AND 
                              tt-extrato_conta.nrsequen > 0  THEN 
                              "            "
                          ELSE
                              STRING(tt-extrato_conta.vlsdtota,
                                     "zzzzzz,zz9.99-").

    ASSIGN aux_dtmvtolt:SCREEN-VALUE IN BROWSE b_extrato = aux_dtmvtolt
           aux_vllanmto:SCREEN-VALUE IN BROWSE b_extrato = aux_vllanmto 
           aux_vlsdtota:SCREEN-VALUE IN BROWSE b_extrato = aux_vlsdtota.
    
END.

ON VALUE-CHANGED, ENTRY OF b_extrato IN FRAME f_extrato DO:

    ASSIGN tel_dshistor = (IF  tt-extrato_conta.cdhistor > 0  THEN
                               STRING(tt-extrato_conta.cdhistor,"9999") + " - "
                           ELSE
                               "") + tt-extrato_conta.dshistor
           tel_dsliblan = tt-extrato_conta.dtliblan.

    DISPLAY tel_dshistor 
            tt-extrato_conta.dsidenti 
            tel_dsliblan WITH FRAME f_extrato.

END.

RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT SET h-b1wgen0001.

IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
    DO:
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0001.".
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.
        RETURN.
    END.

DO WHILE TRUE: 
          
    RUN carrega_dep_vista IN h-b1wgen0001 (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT par_nrdconta,
                                           INPUT glb_dtmvtolt,
                                           INPUT 1,
                                           INPUT 1,
                                           INPUT glb_nmdatela,
                                           INPUT aux_flgerlog,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-saldos,
                                          OUTPUT TABLE tt-libera-epr).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-erro.
            PAUSE 3 NO-MESSAGE.
            HIDE MESSAGE NO-PAUSE.
            LEAVE.
        END.

    IF  aux_flgerlog  THEN
        ASSIGN aux_flgerlog = FALSE.

    ASSIGN aux_dslibera = "".

    FOR EACH tt-libera-epr NO-LOCK:

        IF  aux_dslibera[1] = ""  THEN
            ASSIGN aux_dslibera[1] = "Liberacao de emprestimos para "
                   aux_dslibera[2] = "                              ".
        
        IF  LENGTH(aux_dslibera[1]) > 75  THEN
            ASSIGN aux_dslibera[2] = aux_dslibera[2]  +
                               STRING(tt-libera-epr.dtlibera,"99/99/9999") + 
                               " (" + TRIM(STRING(tt-libera-epr.vllibera,
                                                  "zzz,zzz,zz9.99")) + "), ".
        ELSE
            ASSIGN aux_dslibera[1] = aux_dslibera[1]  +
                               STRING(tt-libera-epr.dtlibera,"99/99/9999") + 
                               " (" + TRIM(STRING(tt-libera-epr.vllibera,
                                                  "zzz,zzz,zz9.99")) + "), ".

    END. /** Fim do FOR EACH tt-libera-epr **/
    
    FIND FIRST tt-saldos NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-saldos  THEN
        DISPLAY tt-saldos.vlsddisp tt-saldos.vlsdbloq tt-saldos.vlsdblpr 
                tt-saldos.vlsdblfp tt-saldos.vlsdchsl tt-saldos.vlblqjud
                tt-saldos.vlstotal tt-saldos.vlsaqmax tt-saldos.vlacerto 
                tt-saldos.vllimcre tt-saldos.dslimcre tt-saldos.vlipmfpg 
                tt-saldos.dtultlcr WITH FRAME f_depvista.
      
    DISPLAY btn_extratos btn_sldmedio btn_imprextr     
            btn_extdcpmf btn_sldanter btn_extdcash WITH FRAME f_depvista.

    HIDE MESSAGE NO-PAUSE.

    IF  aux_dslibera[1] <> ""  THEN
        DO:
            MESSAGE COLOR NORMAL aux_dslibera[1].

            IF  TRIM(aux_dslibera[2]) <> ""  THEN
                MESSAGE COLOR NORMAL aux_dslibera[2].
        END.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        CHOOSE FIELD btn_extratos btn_sldmedio btn_imprextr     
                     btn_extdcpmf btn_sldanter btn_extdcash 
                     WITH FRAME f_depvista.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        LEAVE.
    
    HIDE MESSAGE NO-PAUSE.

    IF  FRAME-VALUE = btn_extratos  THEN
        RUN extrato.
    ELSE
    IF  FRAME-VALUE = btn_sldmedio  THEN
        RUN medias.
    ELSE
    IF  FRAME-VALUE = btn_imprextr  THEN
        RUN imprime-extrato.
    ELSE
    IF  FRAME-VALUE = btn_extdcpmf  THEN
        RUN cpmf.
    ELSE
    IF  FRAME-VALUE = btn_sldanter  THEN
        RUN saldos-anteriores.
    ELSE
    IF  FRAME-VALUE = btn_extdcash  THEN
        RUN cash.

END.

HIDE MESSAGE NO-PAUSE.

HIDE FRAME f_depvista NO-PAUSE.

DELETE PROCEDURE h-b1wgen0001.

/*................................ PROCEDURES ................................*/

PROCEDURE extrato:

    DEF VAR h-b1wgen0103 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_dtfimmov AS DATE                                    NO-UNDO.

    ASSIGN tel_dtiniper = ?.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_dtiniper WITH FRAME f_periodo.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_periodo NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        RETURN.

    MESSAGE "Aguarde, carregando extrato ...".

    IF  NOT VALID-HANDLE(h-b1wgen0103) THEN
        RUN sistema/generico/procedures/b1wgen0103.p
            PERSISTENT SET h-b1wgen0103.

    RUN Busca_Extrato IN h-b1wgen0103
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmoperad,
          INPUT glb_nmdatela,
          INPUT "T",
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dsdepart,
          INPUT par_nrdconta,
          INPUT tel_dtiniper,
          INPUT ?,
          INPUT "",
          INPUT 0,
          INPUT 0,
          INPUT "",
          INPUT YES,
         OUTPUT aux_qtregist,
         OUTPUT tel_dtiniper,
         OUTPUT aux_dtfimmov,
         OUTPUT TABLE tt-extrat,
         OUTPUT TABLE tt-extrato_conta,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0103) THEN
        DELETE OBJECT h-b1wgen0103.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            HIDE MESSAGE NO-PAUSE.
            RUN mostra-erro.
            RETURN.
        END.

    HIDE MESSAGE NO-PAUSE.
                     
    IF  NOT CAN-FIND(FIRST tt-extrato_conta NO-LOCK)  THEN
        DO:
            ASSIGN glb_cdcritic = 81.
            RUN fontes/critic.p.
            ASSIGN glb_cdcritic = 0.
            
            BELL.
            MESSAGE glb_dscritic.
         
            RETURN.
        END.

    OPEN QUERY q_extrato FOR EACH tt-extrato_conta NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_extrato WITH FRAME f_extrato.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    CLOSE QUERY q_extrato.

    HIDE FRAME f_extrato NO-PAUSE.

END PROCEDURE.

PROCEDURE medias:

    RUN carrega_medias IN h-b1wgen0001 (INPUT glb_cdcooper,  
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT glb_dtmvtolt,
                                        INPUT 1,
                                        INPUT 1,
                                        INPUT glb_nmdatela,
                                        INPUT TRUE,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-medias,
                                       OUTPUT TABLE tt-comp_medias).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN mostra-erro.
            RETURN.
        END.

    ASSIGN tel_nmmesano = "MMM/AAAA"
           tel_vlsmdmes = "0,00"
           aux_contador = 0.

    FOR EACH tt-medias NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1
               tel_nmmesano[aux_contador] = tt-medias.periodo + ":"
               tel_vlsmdmes[aux_contador] = STRING(DECI(tt-medias.vlsmstre),
                                                   "zzz,zzz,zz9.99").

    END. /** Fim do FOR EACH tt-medias **/

    FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.

    DISPLAY tel_nmmesano            tel_vlsmdmes 
            tt-comp_medias.vlsmnmes tt-comp_medias.vlsmnesp
            tt-comp_medias.vlsmnblq tt-comp_medias.qtdiaute
            tt-comp_medias.vltsddis tt-comp_medias.qtdiauti 
            tt-comp_medias.vlsmdtri tt-comp_medias.vlsmdsem
            WITH FRAME f_medias.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <FIM> para encerrar.".
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_medias NO-PAUSE.

END PROCEDURE.

PROCEDURE imprime-extrato:

    ASSIGN aux_inrelext = 1
           tel_dsrelext = ENTRY(aux_inrelext,aux_lsrelext)
           tel_dtiniper = ?
           tel_dtfimper = ?
           tel_flgtarif = TRUE
           par_flgrodar = TRUE
           par_flgfirst = TRUE 
           par_flgcance = FALSE.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_dtiniper tel_dtfimper tel_dsrelext
               WITH FRAME f_imprime_extrato

        EDITING:
                
            READKEY.
                    
            IF  FRAME-FIELD = "tel_dsrelext"  THEN
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  THEN
                        DO:
                            IF  aux_inrelext > NUM-ENTRIES(aux_lsrelext)  THEN
                                aux_inrelext = NUM-ENTRIES(aux_lsrelext).
                        
                            aux_inrelext = aux_inrelext - 1.
    
                            IF  aux_inrelext = 0  THEN
                                aux_inrelext = NUM-ENTRIES(aux_lsrelext).
                            
                            tel_dsrelext = ENTRY(aux_inrelext,aux_lsrelext).
                          
                            DISPLAY tel_dsrelext WITH FRAME f_imprime_extrato.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"  OR
                        KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"  THEN
                        DO:
                            aux_inrelext = aux_inrelext + 1.
    
                            IF  aux_inrelext > NUM-ENTRIES(aux_lsrelext)  THEN
                                aux_inrelext = 1.
    
                            tel_dsrelext = ENTRY(aux_inrelext,aux_lsrelext).
     
                            DISPLAY tel_dsrelext WITH FRAME f_imprime_extrato.
                        END.
                    ELSE
                    IF  KEYFUNCTION(LASTKEY) = "RETURN"     OR
                        KEYFUNCTION(LASTKEY) = "BACK-TAB"   OR
                        KEYFUNCTION(LASTKEY) = "GO"         OR
                        KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        APPLY LASTKEY.
                END.
            ELSE      
                APPLY LASTKEY.  
                     
        END. /** Fim do EDITING **/

        IF  tel_dtiniper = ?  THEN
            tel_dtiniper = DATE(MONTH(glb_dtmvtolt),1,YEAR(glb_dtmvtolt)).
                                                     
        IF  tel_dtfimper = ?  THEN
            tel_dtfimper = glb_dtmvtolt.  

        RUN valida-impressao-extrato IN h-b1wgen0001
                                    (INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_nmdatela,
                                     INPUT 1, 
                                     INPUT par_nrdconta,
                                     INPUT 1,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_dtiniper,
                                     INPUT tel_dtfimper,
                                     INPUT IF tel_flgtarif THEN 0 ELSE 1,
                                     INPUT TRUE,
                                    OUTPUT TABLE tt-msg-confirma,
                                    OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                RUN mostra-erro.
                NEXT.
            END.

        FIND FIRST tt-msg-confirma NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-msg-confirma  THEN
            DO:
                ASSIGN aux_confirma = "N".
    
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        
                    BELL.
                    MESSAGE tt-msg-confirma.dsmensag UPDATE aux_confirma.
                    LEAVE.
    
                END. /** Fim do DO WHILE TRUE **/
    
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  OR
                    aux_confirma <> "S"                 THEN
                    NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    HIDE MESSAGE NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            HIDE FRAME f_imprime_extrato NO-PAUSE.
            RETURN.
        END.

    MESSAGE "Aguarde! Imprimindo o extrato.".

    RUN sistema/generico/procedures/b1wgen0112.p PERSISTENT SET h-b1wgen0112.

    IF  VALID-HANDLE(h-b1wgen0112)  THEN
        DO:
            INPUT THROUGH basename `tty` NO-ECHO.
                SET aux_nmendter WITH FRAME f_terminal.
            INPUT CLOSE.
            aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                  aux_nmendter.

            RUN Gera_Impressao IN h-b1wgen0112
                    (INPUT glb_cdcooper, 
                     INPUT 0, 
                     INPUT 0, 
                     INPUT 1, 
                     INPUT glb_nmdatela, 
                     INPUT glb_dtmvtolt, 
                     INPUT glb_dtmvtopr, 
                     INPUT glb_cdprogra, 
                     INPUT glb_inproces, 
                     INPUT glb_cdoperad, 
                     INPUT aux_nmendter, 
                     INPUT TRUE, 
                     INPUT par_nrdconta, 
                     INPUT 1, 
                     INPUT 1, 
                     INPUT tel_dtiniper, 
                     INPUT tel_dtfimper, 
                     INPUT tel_flgtarif, 
                     INPUT aux_inrelext, 
                     INPUT 0, 
                     INPUT 0, 
                     INPUT 0, 
                     INPUT 0, 
                     INPUT YES,
                     INPUT aux_intpextr,
                    OUTPUT aux_nmarqimp, 
                    OUTPUT aux_nmarqpdf, 
                    OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0112.

            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    RUN mostra-erro.

                    HIDE MESSAGE NO-PAUSE.
                    HIDE FRAME f_imprime_extrato NO-PAUSE.

                    RETURN.
                END.

            FIND FIRST crapass NO-LOCK NO-ERROR.

            { includes/impressao.i }   
    
            IF  NOT par_flgcance  THEN
                DO: 
                    RUN gera-tarifa-extrato IN h-b1wgen0001 
                                           (INPUT glb_cdcooper, 
                                            INPUT 0, 
                                            INPUT 0, 
                                            INPUT glb_cdoperad,
                                            INPUT glb_nmdatela,
                                            INPUT 1, 
                                            INPUT par_nrdconta, 
                                            INPUT 1, 
                                            INPUT tel_dtiniper,                                             INPUT glb_inproces, 
                                            INPUT TRUE,
                                            INPUT TRUE, 
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT 0,
                                           OUTPUT TABLE tt-msg-confirma,
                                           OUTPUT TABLE tt-erro).
                
                    IF  RETURN-VALUE = "NOK"  THEN
                        RUN mostra-erro.
                END.
        END.
        
    HIDE MESSAGE NO-PAUSE.
    
    HIDE FRAME f_imprime_extrato NO-PAUSE.

END PROCEDURE.

PROCEDURE cpmf:

    RUN obtem-cpmf IN h-b1wgen0001 (INPUT glb_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT glb_cdoperad,
                                    INPUT par_nrdconta,
                                    INPUT 1,
                                    INPUT 1,
                                    INPUT glb_nmdatela,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-cpmf).

    IF  RETURN-VALUE = "NOK"  THEN
        DO: 
            RUN mostra-erro.
            RETURN.
        END.

    ASSIGN tel_vlbscpmf = 0
           tel_vlpgcpmf = 0
           tel_dsexcpmf = 0
           aux_contador = 0.

    FOR EACH tt-cpmf NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1
               tel_vlbscpmf[aux_contador] = tt-cpmf.vlbscpmf
               tel_vlpgcpmf[aux_contador] = tt-cpmf.vlpgcpmf
               tel_dsexcpmf[aux_contador] = tt-cpmf.dsexcpmf.

    END. /** Fim do FOR EACH tt-cpmf **/

    DISPLAY tel_vlbscpmf tel_vlpgcpmf tel_dsexcpmf
            WITH FRAME f_cpmf.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <FIM> para encerrar.".
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_cpmf NO-PAUSE.

END PROCEDURE. 

PROCEDURE saldos-anteriores:

    ASSIGN tel_dtiniper = ?.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE tel_dtiniper WITH FRAME f_data.

        IF  tel_dtiniper = ?  THEN
            ASSIGN tel_dtiniper = glb_dtmvtoan.

        HIDE MESSAGE NO-PAUSE.

        RUN obtem-saldos-anteriores IN h-b1wgen0001 (INPUT glb_cdcooper,
                                                     INPUT 0,
                                                     INPUT 0,
                                                     INPUT glb_cdoperad,
                                                     INPUT glb_nmdatela,
                                                     INPUT 1,
                                                     INPUT par_nrdconta,
                                                     INPUT 1,
                                                     INPUT glb_dtmvtolt,
                                                     INPUT glb_dtmvtoan,
                                                     INPUT tel_dtiniper,
                                                     INPUT TRUE,
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT TABLE tt-saldos).
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO: 
                RUN mostra-erro.
                NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    HIDE FRAME f_data NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        RETURN.

    ASSIGN tel_titsldos = " Saldo do Dia " + 
                          STRING(tel_dtiniper,"99/99/9999") + " ".

    FIND FIRST tt-saldos NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-saldos  THEN
        DO:
            DISPLAY tt-saldos.vlsddisp tt-saldos.vlsdchsl tt-saldos.vlsdbloq
                    tt-saldos.vlsdblpr tt-saldos.vlsdblfp tt-saldos.vlsdindi
                    tt-saldos.vlblqjud tt-saldos.vllimcre tt-saldos.vlstotal
                    WITH FRAME f_saldos_anteriores.
    
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                PAUSE MESSAGE "Tecle <FIM> para encerrar.".
                LEAVE.
        
            END. /** Fim do DO WHILE TRUE **/

            HIDE FRAME f_saldos_anteriores NO-PAUSE.
        END.

END PROCEDURE.

PROCEDURE cash:

    ASSIGN tel_dtiniper = ?.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
        UPDATE tel_dtiniper WITH FRAME f_periodo.
        LEAVE.               
        
    END. /** Fim do DO WHILE TRUE **/
    
    HIDE FRAME f_periodo NO-PAUSE.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        RETURN.

    MESSAGE "Aguarde, carregando extrato ...".

    IF  tel_dtiniper = ?  THEN
        ASSIGN tel_dtiniper = DATE(MONTH(glb_dtmvtolt),01,YEAR(glb_dtmvtolt)).

    RUN sistema/generico/procedures/b1wgen0027.p PERSISTENT SET h-b1wgen0027.

    IF  NOT VALID-HANDLE(h-b1wgen0027)  THEN
        DO:
            BELL.
            MESSAGE "Handle invalido para BO b1wgen0027.".
            RETURN.
        END.

    RUN extratos_emitidos_no_cash IN h-b1wgen0027 (INPUT glb_cdcooper,
                                                   INPUT 0,  
                                                   INPUT 0,  
                                                   INPUT glb_cdoperad,
                                                   INPUT par_nrdconta,
                                                   INPUT 1, 
                                                   INPUT glb_nmdatela,
                                                   INPUT tel_dtiniper,
                                                   INPUT 1, 
                                                   INPUT TRUE, 
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-extcash).

    DELETE PROCEDURE h-b1wgen0027.

    HIDE MESSAGE NO-PAUSE.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:               
            RUN mostra-erro.
            RETURN.
        END.

    IF  NOT CAN-FIND(FIRST tt-extcash NO-LOCK)  THEN
        DO:
            BELL.
            MESSAGE "Nao foram retirados extratos no periodo informado.".
            RETURN.
        END.

    OPEN QUERY q_cash FOR EACH tt-extcash NO-LOCK BY tt-extcash.dtrefere.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE b_cash WITH FRAME f_cash.
        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    CLOSE QUERY q_cash.

    HIDE FRAME f_cash NO-PAUSE.

END PROCEDURE.

PROCEDURE mostra-erro:

    FIND FIRST tt-erro NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-erro  THEN
        DO:
            BELL.
            MESSAGE tt-erro.dscritic.
        END.

END PROCEDURE.

/*............................................................................*/
