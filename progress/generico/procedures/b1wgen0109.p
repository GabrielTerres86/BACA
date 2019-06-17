/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0109.p
    Autor   : Gabriel Capoia dos Santos (DB1)
    Data    : Agosto/2011                        Ultima atualizacao: 26/05/2018

    Objetivo  : Tranformacao BO tela IMPREL

    Alteracoes: 13/08/2013 - Nova forma de chamar as agências, alterado para
                             "Posto de Atendimento" (PA). 
                             (André Santos - SUPERO)
                         
                24/10/2013 - Ajuste na procedure Gera_Impressao para contemplar
                             os relatorios com a nova formatacao do PA
                             (Adriano).
                             
                25/10/2013 - Ajuste para nao mostrar erro na tela ao buscar
                             PAs com codigo maior que 99. (Reinert)        
                             
                30/10/2013 - Ajuste para inclusao do relatorio crrl668
                             (Adriano).                  
                             
                30/10/2013 - Inclusao dos relatorios crrl456 e crrl481
                             (Carlos)
   
                26/02/2014 - Incluir relatorio crrl620 (Lucas R.)
                
                18/06/2014 - Incluir relatorio crrl102 (Carlos Rafael)                
                
                27/06/2014 - #152775 Incluir relatorio crrl593 (Carlos)  
                
                22/07/2014 - Quando for buscar o crrl620 sempre deve
                             mover do diretorio /salvar da cooperativa para
                             o diretorio /rl, pois este relatorio 'e gerado
                             no dia anterior.
                             (Chamado 173350) - (Fabricio).
                             
                04/09/2014 - #189652 Chamada da procedure 
                             envia-arquivo-web-sem-pcl p/ a opcao D (Carlos)
                             
                11/09/2014 - Documentacao e retirada do rel crrl102 da opcao
                             D (Carlos)
                             
                06/10/2014 - Tratar todos os relatorios 620. Chamado 148405.
                             (Jonata-RKAM).
                             
                             
                13/11/2014 - Correção de impressao de arquivos opcao D
                             Tela IMPREL. Ajustando a paginacao dos arquivos
                             que sao impressos via ayllos caracter
                             (Andre Santos - SUPERO).
                             
                26/11/2014 - Ajuste verificacao crrl620. (Fabricio)
                
                05/12/2014 - De acordo com a circula 3.656 do Banco Central, 
                             substituir nomenclaturas Cedente por Beneficiário 
                             e  Sacado por Pagador Chamado 229313 
                             (Jean Reddiga - RKAM).
                             
                12/01/2015 - Incluir o relatorio de "Limites de Creditos Vencidos"
                             (James)
                             
                07/04/2015 - Incluir novo comando se relatorio chamado for o 
                             crrl620, para que se não encontrar o relatorio
                             no diretorio salvar da cooperativa, busque do 
                             win12/salvar da cooperativa (Lucas R. #250244)
               
                08/04/2015 - Alterado a forma de concatenar arquivos usando a
                             funcao "CAT" para um script chamado 
                             "concatena_relatorios.sh". Alteração feita para ajustar 
                             o problema que ocorria ao imprimir os relatórios
                             na opção "D", conforme chamado 264577. (Kelvin/Adriano)
                             
                31/08/2016 - #500713 Inclusao do relatorio 626 (Relac. de 
                             ocorrencias TIC) (Carlos)

				26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
        
                13/06/2019 - RITM0021049 Inclusao relatorios 392 e 572 (Yuri Mouts)


............................................................................*/

/*............................. DEFINICOES .................................*/

{ sistema/generico/includes/b1wgen0109tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.

DEF VAR aux_lsrelato AS CHAR                                        NO-UNDO.
DEF VAR aux_qtrelato AS INT                                         NO-UNDO.
DEF VAR cmd          AS CHAR    FORMAT "x(37)" EXTENT 42            NO-UNDO.
DEF VAR proglist     AS CHAR                   EXTENT 42            NO-UNDO.
DEF VAR pac          AS LOGICAL                EXTENT 42 INIT TRUE  NO-UNDO.

/* relatorios que aparecem na opcao D */
ASSIGN aux_lsrelato = "crrl007,crrl011,crrl033,crrl055,crrl135,crrl145," +
                      "crrl156,crrl211,crrl229,crrl266,crrl272," +
                      "crrl280,crrl294,crrl309,crrl345,crrl352,crrl353," +
                      "crrl362,crrl372,crrl426,crrl456,crrl458,crrl481," +
                      "crrl529,crrl597,crrl598,crrl599,crrl626,crrl668,crrl620," +
                      "crrl276,crrl593"
       
       proglist[01] = "crrl007"
       proglist[02] = "crrl011"
       proglist[03] = "crrl033"
       proglist[04] = "crrl055"
       proglist[05] = "crrl090"
       proglist[06] = "crrl100"
       proglist[07] = "crrl102"
       proglist[08] = "crrl108"
       proglist[09] = "crrl135"
       proglist[10] = "crrl145"
       proglist[11] = "crrl156"
       proglist[12] = "crrl211"
       proglist[13] = "crrl229"
       proglist[14] = "crrl266"
       proglist[15] = "crrl272"
       proglist[16] = "crrl278"
       proglist[17] = "crrl280"
       proglist[18] = "crrl294"
       proglist[19] = "crrl309"
       proglist[20] = "crrl345"
       proglist[21] = "crrl352"
       proglist[22] = "crrl353"
       proglist[23] = "crrl362"
       proglist[24] = "crrl372"
       proglist[25] = "crrl386"
       proglist[26] = "crrl392"
       proglist[27] = "crrl395"
       proglist[28] = "crrl396"
       proglist[29] = "crrl426"
       proglist[30] = "crrl456"
       proglist[31] = "crrl481"
       proglist[32] = "crrl497"
       proglist[33] = "crrl529"
       proglist[34] = "crrl572"
       proglist[35] = "crrl593"
       proglist[36] = "crrl597"
       proglist[37] = "crrl598"
       proglist[38] = "crrl599"
       proglist[39] = "crrl626"
       proglist[40] = "crrl668"
       proglist[41] = "crrl620_credito"
       proglist[42] = "crrl620_matric"
       proglist[43] = "crrl620_cadastro"
       proglist[44] = "crrl692"
      
       aux_qtrelato = EXTENT(proglist)
       
       cmd[01] = "007-Saldos Devedores por PA          "
       cmd[02] = "011-Resumo do Movimento              "
       cmd[03] = "033-Exclusoes no Mes                 "
       cmd[04] = "055-Maiores Depositantes             "
       cmd[05] = "090-Resumo de RDCA por Aniversario   "
       cmd[06] = "100-Saldos Apos Processo PA          "
       cmd[07] = "102-Debitos em conta via caixa       " 
       cmd[08] = "108-Taxas de RDC e RDCA.             "
       cmd[09] = "135-Debitos nao efetuados emprestimos"
       cmd[10] = "145-Comprovantes pendentes           "
       cmd[11] = "156-Deb. nao efetuados emprest/cotas "
       cmd[12] = "211-Debitos p/ Banco por PA          "
       cmd[13] = "229-Controle Cartoes Magne. Entregues"
       cmd[14] = "266-Relacao Contratos Emprest./Descto" 
       cmd[15] = "272-Abertura/Recadastramento de c/c  "
       cmd[16] = "278-Negativos Qdo Integ. Apos Proces "
       cmd[17] = "280-Novas matriculas                 "
       cmd[18] = "294-Resumo diario Aplicacao/Resgate  "
       cmd[19] = "309-Resumo das Devol. Bco do Brasil  " 
       cmd[20] = "345-Subscricao de Capital nao Debitad"
       cmd[21] = "352-CPF Sem Consulta.                "
       cmd[22] = "353-Relacao Cheques Compe por PA     "
       cmd[23] = "362-Cartas a serem Solicitadas p/PA  "
       cmd[24] = "372-Saldo Conta Investimento(CI)     "
       cmd[25] = "386-Diferencas de Caixas (Mensal)    "
       cmd[26] = "392-Pedido de Talonarios             "
       cmd[27] = "395-Cadastros de Conta Integracao    "
       cmd[28] = "396-Criticas dos retornos C/C Integr."
       cmd[29] = "426-Ctas Duplicadas (maiores 16 anos)"
       cmd[30] = "456-Credito aplicacoes RDC           "
       cmd[31] = "481-Poupanca a vencer em 5 dias uteis"
       cmd[32] = "497-Tit. Dscto Debitados Beneficiario"
       cmd[33] = "529-Cheque Devolvido (AILOS)         "
       cmd[34] = "572-Pedido Formulario Continuo       "
       cmd[35] = "593-Cheques nao digitalizados        "
       cmd[36] = "597-Contratacao Seguro Prestamista   "
       cmd[37] = "598-Emprestimos Sem Seg.Prestamista  "
       cmd[38] = "599-Relac. Chq Compe p/PA apos proc  "
       cmd[39] = "626-Relac. de ocorrencias TIC "
       cmd[40] = "668-Emprestimos prefixados em atraso "
       cmd[41] = "620-Docs nao Digitalizados_Credito   "
       cmd[42] = "620-Docs nao Digitalizados_Matricula "
       cmd[43] = "620-Docs nao Digitalizados_Cadastro  "
       cmd[44] = "692-Limites de Credito Vencidos".

       pac[08] = FALSE.

FUNCTION CriticaArquivo RETURNS CHARACTER PRIVATE 
    ( INPUT par_nmarqimp AS CHAR ) FORWARD.

/*................................ PROCEDURES ..............................*/

/* ------------------------------------------------------------------------ */
/*                 Gera Lista com Relatórios do Sistama                     */
/* ------------------------------------------------------------------------ */
PROCEDURE Lista_Relatorios:

    DEF OUTPUT PARAM TABLE FOR tt-nmrelato.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-nmrelato.

    DO aux_contador = 1 TO aux_qtrelato:


        CREATE tt-nmrelato.
        ASSIGN tt-nmrelato.nmrelato = cmd[aux_contador]
               tt-nmrelato.contador = aux_contador
               tt-nmrelato.flgrelat = 
                          CAN-DO(aux_lsrelato, STRING(proglist[aux_contador]))
               tt-nmrelato.flgvepac = pac[aux_contador]
               tt-nmrelato.nmdprogm = proglist[aux_contador].
    
    END.

    RETURN "OK".

END PROCEDURE. /* Lista_Relatorios */

PROCEDURE Gera_Impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrelat AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenca AS INTE                           NO-UNDO.

    DEF  OUTPUT PARAM par_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM par_nmarqpdf AS CHAR                          NO-UNDO.
    
    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmendter AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgexist AS LOGI                                    NO-UNDO.
    DEF VAR aux_arquivos AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dstransa = "Imprime Relatorio do Sistema"
           aux_dscritic = ""
           aux_returnvl = "NOK"
           aux_flgexist = NO
           aux_arquivos = "".
    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.
        EMPTY TEMP-TABLE tt-nmrelato.

        IF  NOT CAN-DO("C,D",par_cddopcao) THEN
            DO:
                ASSIGN aux_cdcritic = 14.
                LEAVE Imprime.
            END.

        FOR FIRST crabcop FIELDS(dsdircop) 
                              WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
            END.
           
            IF  NOT AVAILABLE crabcop  THEN
                DO: 
                    ASSIGN aux_cdcritic = 651
                           aux_dscritic = "".
                    LEAVE Imprime.
                END.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                               par_dsiduser.
    
        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               par_nmarqimp = aux_nmendter
               par_nmarqpdf = aux_nmendter + ".pdf".


        RUN Lista_Relatorios( OUTPUT TABLE tt-nmrelato ).

        

        FOR EACH tt-nmrelato WHERE ( IF par_cddopcao = "C" THEN 
                                       tt-nmrelato.contador = par_nrdrelat
                                     ELSE
                                       tt-nmrelato.contador >= par_nrdrelat AND 
                                       tt-nmrelato.flgrelat):

            IF  SUBSTR(tt-nmrelato.nmdprogm,1,7) = "crrl620" THEN
                DO:
                    /* se achar o crrrl620 no diretorio salvar da cooperativa, move dele mesmo para o rl,
                       se achar no win12/salvar move para o rl da cooperativa */
                    UNIX SILENT VALUE(" [ -f /usr/coop/" + crabcop.dsdircop + "/salvar/*crrl620* ] " +
                                      "&& mv /usr/coop/" + crabcop.dsdircop + "/salvar/*crrl620* "   +
                                      "/usr/coop/" + crabcop.dsdircop +  "/rl" +
                                      " || mv /usr/coop/win12/" + crabcop.dsdircop + "/salvar/*crrl620*" +
                                      " /usr/coop/" + crabcop.dsdircop + "/rl 2> /dev/null").
                    
                    /* comentado este comando para utilizar o de cima, em forma de IF 
                    UNIX SILENT VALUE("mv /usr/coop/" + crabcop.dsdircop +
                                      "/salvar/crrl620*.lst /usr/coop/"  +
                                      crabcop.dsdircop + "/rl 2> /dev/null").*/
                END.
            
            IF tt-nmrelato.flgvepac THEN
               DO:
                  ASSIGN aux_nmarqimp = "/usr/coop/" + crabcop.dsdircop +
                                        "/rl/" +  tt-nmrelato.nmdprogm  +
                                        "_" + STRING(par_cdagenca,"99") +
                                        ".lst" NO-ERROR.
                  
                  IF SEARCH(aux_nmarqimp) = ? THEN
                     DO:
                        ASSIGN aux_nmarqimp = "/usr/coop/" + crabcop.dsdircop +
                                              "/rl/" +  tt-nmrelato.nmdprogm  +
                                              "_" + STRING(par_cdagenca,"999") +
                                              ".lst".

                        IF SEARCH(aux_nmarqimp) = ? THEN
                           IF par_cddopcao = "C" THEN
                              DO:
                                 ASSIGN aux_dscritic = CriticaArquivo
                                                      (INPUT aux_nmarqimp).
                                 LEAVE Imprime.

                              END.
                           ELSE
                              NEXT.
                        
                     END.

               END.      
            ELSE
                DO:
                    ASSIGN aux_nmarqimp = "/usr/coop/" + crabcop.dsdircop +
                                          "/rl/" + tt-nmrelato.nmdprogm + 
                                          ".lst".

                    IF  SEARCH(aux_nmarqimp) = ? THEN
                        IF  par_cddopcao = "C" THEN
                            DO:
                                ASSIGN aux_dscritic = CriticaArquivo
                                                          (INPUT aux_nmarqimp).
                                LEAVE Imprime.
                            END.
                        ELSE
                            NEXT.
                END.
            
            ASSIGN aux_flgexist = YES
                   aux_arquivos = aux_arquivos + aux_nmarqimp + " ".

        END.
        
        IF  NOT aux_flgexist  OR 
            aux_arquivos = "" THEN
            DO:
                ASSIGN aux_dscritic = "Nenhum relatorio foi encontrado para " +
                                      "o PA  " + STRING(par_cdagenca,"99") .
                LEAVE Imprime.
            END.
        
        /*Script "concatena_relatorios.sh" feito para substituir o cat em situações
          especificas de quebra de linha (Kelvin/Adriano)*/
        ASSIGN par_nmarqimp = par_nmarqimp + ".ex"
               aux_dscomand = "/usr/local/cecred/bin/concatena_relatorios.sh " +
                               aux_arquivos + " > " + 
                               par_nmarqimp + " 2>/dev/null".
                
        UNIX SILENT VALUE(aux_dscomand) NO-ECHO.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                IF par_cddopcao = "D" THEN
                    RUN envia-arquivo-web-sem-pcl IN h-b1wgen0024 
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_nmarqimp,
                         OUTPUT par_nmarqpdf,
                         OUTPUT TABLE tt-erro ).
                ELSE
                    RUN envia-arquivo-web IN h-b1wgen0024 
                        ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_nmarqimp,
                         OUTPUT par_nmarqpdf,
                         OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_returnvl = "NOK".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Gera_Impressao */

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION CriticaArquivo RETURNS CHARACTER PRIVATE 
    ( INPUT aux_nmarqimp AS CHAR ):
/*-----------------------------------------------------------------------------
  Objetivo:  Retorna crítica de arquivo não encontrado com o nome do arquivo
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_dscriarq AS CHAR                                    NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
        RUN sistema/generico/procedures/b1wgen0060.p 
            PERSISTENT SET h-b1wgen0060.

    ASSIGN aux_dscriarq = DYNAMIC-FUNCTION("BuscaCritica" IN h-b1wgen0060,182).

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    RETURN aux_dscriarq + " " + aux_nmarqimp.

END FUNCTION. /* CriticaArquivo */
