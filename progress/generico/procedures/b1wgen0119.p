/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0119.p                  
    Autor(a): Fabricio
    Data    : Dezembro/2011                      Ultima atualizacao: 12/04/2019
  
    Dados referentes ao programa:
  
    Objetivo  : BO com regras de negocio refente a tela PAMCAR.
                
  
    Alteracoes:  03/02/2012 - Ajuste de layout nas procedures:
                              - gera_termo_cancelamento
                              - gera_termo_adesao
                              - processa_arquivo_debito
                              E demais ajustes PAMCAR
                              (Adriano).
                              
                 06/03/2012 - Alterado na procedure gera_relatorio_615,
                              a extensao do relatorio a ser gerado; de: ".ex"
                              para: ".lst". (Fabricio)
                              
                 11/06/2012 - Alterado a composicao do campo craplcm.nrdocmto
                              para 5 posicoes do horario atual + 3 posicoes do
                              contador (0 a 999). (Fabricio)
                              
                 10/07/2012 - Ajuste impressao relatorio processamento (David).
                 
                 30/10/2012 - Criados relatórios de Limite de Cheque Especial e 
                              Informações Cadastrais para a opção "R" (Lucas)
                              
                 10/12/2012 - Incluso impressao dos totais de processados e rejeitados
                              (Daniel).
                              
                 14/01/2013 - Alteração na procedure 'gera_relatorio_615' para 
                              separar por PAC e adicionar totais das colunas 
                              RECARGA e TARIFA (Lucas).          
                
                 13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                              a escrita será PA (André Euzébio - Supero).  
                              
                 12/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
                 
                 26/02/2014 - Atribuicao ao campo tt-dados-conta.flgdemis
                              na procedure obtem_dados_conta. (Fabricio)
                             
				 07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                              departamento passando a considerar o código (Renato Darosci)   
                 
                 12/12/2016 - Incorporacao - Alterada busca_cooperativas para
                              para listar apenas Coops Ativas
                              Telas que utilizam a procedure (IMGCHQ/PARMON)
                              (Guilherme/SUPERO)
                              
                 12/04/2019 - RITM0011920 Na rotina verifica_permissao, incluida 
                              a permissao de acesso para a coop 9 (Carlos)
.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0119tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1cabrelvar.i }

FORM tt-criticas-rel615.nrdconta 
     tt-criticas-rel615.nmprimtl FORMAT "x(40)"
     tt-criticas-rel615.nrcpfcgc FORMAT "99999999999999"
     tt-criticas-rel615.vllanmto FORMAT "zzz,zz9.99"
     tt-criticas-rel615.pertxpam FORMAT "zzz,zz9.99"
     tt-criticas-rel615.dscritic FORMAT "x(30)"
     WITH DOWN NO-LABELS NO-BOX FRAME f_criticas WIDTH 132.

FORM tt-debitos-rel615.nrdconta 
     tt-debitos-rel615.nmprimtl FORMAT "x(50)"
     tt-debitos-rel615.nrcpfcgc FORMAT "99999999999999"
     tt-debitos-rel615.vllanmto FORMAT "zzz,zz9.99"
     tt-debitos-rel615.pertxpam
     WITH DOWN NO-LABELS NO-BOX FRAME f_debitos WIDTH 132.

FORM "  CONTA/DV  NOME/RAZAO SOCIAL                    " 
     "                  CPF/CNPJ    RECARGA     TARIFA"
     SKIP
     "---------- --------------------------------------------------"
     "-------------- ---------- ----------"
     WITH NO-LABELS NO-BOX FRAME f_cab_debitos WIDTH 132.

FORM " CONTA/DV  NOME/RAZAO SOCIAL                    "
     "        CPF/CNPJ     RECARGA     TARIFA CRITICA"
     SKIP
     "---------- ---------------------------------------- --------------"
     "---------- ---------- ------------------------------"
     WITH NO-LABELS NO-BOX FRAME f_cab_criticas WIDTH 132.

DEF STREAM str_1.

DEFINE TEMP-TABLE tt-saldos_original LIKE tt-saldos.

DEF VAR aux_cdcritic AS INTE NO-UNDO.
DEF VAR aux_dscritic AS CHAR NO-UNDO.
DEF VAR aux_termoade AS CHAR NO-UNDO.


PROCEDURE verifica_permissao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cddepart AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    IF par_cdcooper <> 3 AND par_cdcooper <> 9 THEN
        DO:            
            ASSIGN aux_cdcritic = 36
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

PROCEDURE grava_registro:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dthabpam AS DATE NO-UNDO.
    DEF INPUT PARAM par_vllimpam AS DECI NO-UNDO.
    DEF INPUT PARAM par_vlmenpam AS DECI NO-UNDO.
    DEF INPUT PARAM par_pertxpam AS DECI NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       EXCLUSIVE-LOCK.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.


    IF crapcop.vllimpam <> par_vllimpam THEN
        RUN gera_log (INPUT "Limite",
                      INPUT STRING(crapcop.vllimpam, "zzz,zzz,zz9.99"),
                      INPUT STRING(par_vllimpam, "zzz,zzz,zz9.99"),
                      INPUT par_dthabpam,
                      INPUT par_cdoperad,
                      INPUT crapcop.dsdircop).

    IF crapcop.vlmenpam <> par_vlmenpam THEN
        RUN gera_log (INPUT "Mensalidade",
                      INPUT STRING(crapcop.vlmenpam, "zzz,zzz,zz9.99"),
                      INPUT STRING(par_vlmenpam, "zzz,zzz,zz9.99"),
                      INPUT par_dthabpam,
                      INPUT par_cdoperad,
                      INPUT crapcop.dsdircop).

    IF crapcop.pertxpam <> par_pertxpam THEN
        RUN gera_log (INPUT "% Tarifa",
                      INPUT STRING(crapcop.pertxpam, "zz9.99"),
                      INPUT STRING(par_pertxpam, "zzz,zzz,zz9.99"),
                      INPUT par_dthabpam,
                      INPUT par_cdoperad,
                      INPUT crapcop.dsdircop).

    ASSIGN crapcop.vllimpam = par_vllimpam
           crapcop.vlmenpam = par_vlmenpam
           crapcop.pertxpam = par_pertxpam
           crapcop.cdoprpam = par_cdoperad
           crapcop.dthabpam = par_dthabpam.



END PROCEDURE.

PROCEDURE busca_registro:

    DEF INPUT  PARAM par_cdcooper  AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdcopalt  AS INTE NO-UNDO.
    DEF INPUT  PARAM par_cdagenci  AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa  AS INTE NO-UNDO.

    DEF OUTPUT PARAM par_vllimpam  AS DECI NO-UNDO.
    DEF OUTPUT PARAM par_vlpamuti  AS DECI NO-UNDO.
    DEF OUTPUT PARAM par_vlmenpam  AS DECI NO-UNDO.
    DEF OUTPUT PARAM par_prtaxpam  AS DECI NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

   
    FIND crapcop WHERE crapcop.cdcooper = par_cdcopalt 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcopalt,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    ASSIGN par_vllimpam = crapcop.vllimpam
           par_vlpamuti = crapcop.vlpamuti
           par_vlmenpam = crapcop.vlmenpam
           par_prtaxpam = crapcop.pertxpam.

END PROCEDURE.

PROCEDURE busca_cooperativas:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-crapcop.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    IF  par_cdcooper = 3 THEN DO:

        FOR EACH crapcop
           WHERE crapcop.cdcooper <> 3
             AND crapcop.flgativo = TRUE
         NO-LOCK:
              
               CREATE tt-crapcop.

               ASSIGN tt-crapcop.codcoope = crapcop.cdcooper
                      tt-crapcop.nmrescop = crapcop.nmrescop.
     
           END.
       END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_log:

    DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlrcampo AS CHAR NO-UNDO.
    DEF INPUT PARAM par_vlcampo2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsdircop AS CHAR NO-UNDO.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")       +
                      " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"    +
                      " Operador " + par_cdoperad + " - " + "Alterou"   +
                      " campo " + par_dsdcampo + ", de "                + 
                      par_vlrcampo + " para " + 
                      par_vlcampo2 +
                      ". >> /usr/coop/" + par_dsdircop + "/log/pamcar.log").


END PROCEDURE.

PROCEDURE obtem_dados_conta:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdctitg AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados-conta.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VARIABLE    aux_dscritic AS CHAR NO-UNDO.

    IF par_nrdconta <> 0 THEN
        FIND crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    ELSE
        FIND crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.nrdctitg = par_nrdctitg NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 9,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".
    END.

    FIND crappam WHERE crappam.cdcooper = crapass.cdcooper AND
                       crappam.nrdconta = crapass.nrdconta 
                       NO-LOCK NO-ERROR.
    
    CREATE tt-dados-conta.
    ASSIGN tt-dados-conta.nrdconta = crapass.nrdconta
           tt-dados-conta.nrdctitg = crapass.nrdctitg
           tt-dados-conta.dssititg = IF crapass.flgctitg = 2 THEN
                                        "Ativa"
                                     ELSE
                                     IF crapass.flgctitg = 3 THEN
                                        "Inativa"
                                     ELSE
                                     IF crapass.nrdctitg <> "" THEN
                                        "Em Proc"
                                     ELSE
                                        ""
           tt-dados-conta.nmprimtl = crapass.nmprimtl
           tt-dados-conta.nrcpfcgc = crapass.nrcpfcgc
           tt-dados-conta.flgpamca = crappam.flgpamca WHEN AVAIL crappam
           tt-dados-conta.vllimpam = crappam.vllimpam WHEN AVAIL crappam
           tt-dados-conta.dddebpam = crappam.dddebpam WHEN AVAIL crappam
           tt-dados-conta.nrctapam = crappam.nrctapam WHEN AVAIL crappam
           tt-dados-conta.flgdemis = crapass.dtdemiss <> ?.

    RETURN "OK".


END PROCEDURE.

PROCEDURE grava_registro_convenio:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI NO-UNDO.
    DEF INPUT PARAM par_flgpamca AS LOGI NO-UNDO.
    DEF INPUT PARAM par_vllimpam AS DECI NO-UNDO.
    DEF INPUT PARAM par_dddebpam AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrctapam AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER b-crapass1 FOR crapass.
    DEF BUFFER b-crappam1 FOR crappam.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       EXCLUSIVE-LOCK NO-ERROR.

    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.
     
    /* valida limite da cooperativa */
    IF crapcop.vllimpam = 0 THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Limite PAMCARD nao cadastrado na cooperativa.".
                       
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                      
           RETURN "NOK".
     
       END.

    /* Verifica se ja existe um convenio ativo para o CPF/CNPJ */
    ASSIGN aux_dscritic = "".


    IF par_flgpamca THEN
    DO: 
        FOR EACH crapass WHERE crapass.cdcooper =  par_cdcooper AND
                               crapass.nrcpfcgc =  par_nrcpfcgc AND
                               crapass.nrdconta <> par_nrdconta AND
                               crapass.dtdemiss = ? 
                               NO-LOCK:

            IF CAN-FIND(FIRST crappam WHERE crappam.cdcooper = crapass.cdcooper AND
                                            crappam.nrdconta = crapass.nrdconta AND
                                            crappam.flgpamca = TRUE) THEN
            DO:
                ASSIGN aux_dscritic = "Ja existe um convenio ativo para este " 
                                        + "CPF/CNPJ.".

                LEAVE.
            END.
        END.

        IF aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 0,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).      
        
            RETURN "NOK".

        END.

    END.
    
    IF par_nrctapam <> 0 THEN
    DO:
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrctapam 
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_dscritic = "Conta duplicada invalida.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 0,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).      
        
            RETURN "NOK".
        END.

        IF crapass.nrcpfcgc <> par_nrcpfcgc THEN
        DO:
            ASSIGN aux_dscritic = "CPF/CNPJ da conta duplicada deve ser o " +
                                  "mesmo da conta/dv.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 0,
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

        IF crapass.dtdemiss <> ? THEN
        DO:
            ASSIGN aux_dscritic = "Conta duplicada encerrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT 0,
                           INPUT 0,            /** Sequencia **/
                           INPUT 0,
                           INPUT-OUTPUT aux_dscritic).      
        
            RETURN "NOK".

        END.

    END.

    FIND crappam WHERE crappam.cdcooper = par_cdcooper AND 
                       crappam.nrdconta = par_nrdconta 
                       EXCLUSIVE-LOCK NO-ERROR.

    IF AVAIL crappam THEN
    DO:
        IF crappam.flgpamca <> par_flgpamca THEN
            RUN gera_log (INPUT "Ind. Convenio PAMCARD",
                          INPUT crappam.flgpamca,
                          INPUT par_flgpamca,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT crapcop.dsdircop).

        IF crappam.vllimpam <> par_vllimpam THEN
            RUN gera_log (INPUT "Limite de Recarga",
                          INPUT STRING(crappam.vllimpam, "zzz,zzz,zz9.99"),
                          INPUT STRING(par_vllimpam, "zzz,zzz,zz9.99"),
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT crapcop.dsdircop).

        IF crappam.dddebpam <> par_dddebpam THEN
            RUN gera_log (INPUT "Dia Debito PAMCARD",
                          INPUT STRING(crappam.dddebpam, "99"),
                          INPUT STRING(par_dddebpam, "99"),
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT crapcop.dsdircop).

        IF crappam.nrctapam <> par_nrctapam THEN
            RUN gera_log (INPUT "Nr. Conta Cartao",
                          INPUT STRING(crappam.nrctapam, "zzz,zz9,9"),
                          INPUT STRING(par_nrctapam, "zzz,zz9,9"),
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT crapcop.dsdircop).
        
        IF par_flgpamca AND (par_flgpamca = crappam.flgpamca) 
                        AND (crappam.vllimpam <> par_vllimpam) THEN
        DO:
            IF (crappam.vllimpam - par_vllimpam < 0) THEN
            DO:
                IF (crapcop.vlpamuti + 
                    ((crappam.vllimpam - par_vllimpam) * -1)) > 
                        crapcop.vllimpam THEN
                DO:
                    ASSIGN aux_cdcritic = 945
                           aux_dscritic = "".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                   
                    RETURN "NOK".

                END.
                  ELSE
                      ASSIGN crapcop.vlpamuti = crapcop.vlpamuti + 
                                    ((crappam.vllimpam - par_vllimpam) * -1).
            END.
              ELSE
                  IF (crapcop.vlpamuti - (crappam.vllimpam - par_vllimpam)) 
                                                  > crapcop.vllimpam THEN
                      DO:
                          ASSIGN aux_cdcritic = 945
                                 aux_dscritic = "".
                          
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                         
                          RETURN "NOK".
                     
                      END.
                  ELSE
                      ASSIGN crapcop.vlpamuti = crapcop.vlpamuti -
                                              (crappam.vllimpam - par_vllimpam).
        END.
        ELSE
          IF NOT par_flgpamca                   AND 
             (crappam.flgpamca <> par_flgpamca) THEN
              ASSIGN crapcop.vlpamuti = crapcop.vlpamuti - crappam.vllimpam.
          ELSE
            IF par_flgpamca                       AND 
               (crappam.flgpamca <> par_flgpamca) THEN
                IF (crapcop.vlpamuti + par_vllimpam) > crapcop.vllimpam THEN
                   DO:
                       ASSIGN aux_cdcritic = 945
                              aux_dscritic = "".
                           
                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,            /** Sequencia **/
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).
                          
                       RETURN "NOK".
                  
                   END.
                ELSE
                   ASSIGN crapcop.vlpamuti = crapcop.vlpamuti + par_vllimpam.


        ASSIGN crappam.flgpamca = par_flgpamca
               crappam.vllimpam = par_vllimpam
               crappam.dddebpam = par_dddebpam
               crappam.nrctapam = par_nrctapam
               crappam.dtdespam = IF par_flgpamca THEN
                                    ?
                                  ELSE
                                    par_dtmvtolt
               crappam.cdoperad = par_cdoperad
               crappam.dtmvtolt = par_dtmvtolt.

                                 
        FOR EACH b-crapass1 WHERE b-crapass1.cdcooper =  par_cdcooper AND
                                  b-crapass1.nrcpfcgc =  par_nrcpfcgc AND
                                  b-crapass1.nrdconta <> par_nrdconta 
                                  NO-LOCK:

            FIND b-crappam1 WHERE b-crappam1.cdcooper = b-crapass1.cdcooper AND
                                  b-crappam1.nrdconta = b-crapass1.nrdconta 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
            IF AVAIL b-crappam1 THEN
               DELETE b-crappam1.
            ELSE 
               IF LOCKED b-crappam1 THEN
                  DO:
                     ASSIGN aux_cdcritic = 341
                            aux_dscritic = "".
                         
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                        
                     RETURN "NOK".

                  END.

        END.                       


    END.
    ELSE
    DO:
        IF par_flgpamca THEN
            IF (crapcop.vlpamuti + par_vllimpam) > crapcop.vllimpam THEN
            DO:
                ASSIGN aux_cdcritic = 945
                       aux_dscritic = "".
                    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                   
                RETURN "NOK".

            END.

        CREATE crappam.

        ASSIGN crappam.cdcooper = par_cdcooper
               crappam.nrdconta = par_nrdconta
               crappam.flgpamca = par_flgpamca
               crappam.vllimpam = par_vllimpam
               crappam.dddebpam = par_dddebpam
               crappam.nrctapam = par_nrctapam
               crappam.dtdespam = IF par_flgpamca THEN
                                    ?
                                  ELSE
                                    par_dtmvtolt
               crappam.cdoperad = par_cdoperad
               crappam.dtmvtolt = par_dtmvtolt.
        VALIDATE crappam.                             

        FOR EACH b-crapass1 WHERE b-crapass1.cdcooper =  par_cdcooper AND
                                  b-crapass1.nrcpfcgc =  par_nrcpfcgc AND
                                  b-crapass1.nrdconta <> par_nrdconta 
                                  NO-LOCK:

            FIND b-crappam1 WHERE b-crappam1.cdcooper = b-crapass1.cdcooper AND
                                  b-crappam1.nrdconta = b-crapass1.nrdconta 
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF AVAIL b-crappam1 THEN
               DELETE b-crappam1.
            ELSE 
               IF LOCKED b-crappam1 THEN
                  DO:
                     ASSIGN aux_cdcritic = 341
                            aux_dscritic = "".

                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT 1,            /** Sequencia **/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).

                     RETURN "NOK".

                  END.

        END.                         


        IF par_flgpamca THEN
           ASSIGN crapcop.vlpamuti = crapcop.vlpamuti + par_vllimpam.

         
    END.


    RELEASE crappam.
    RELEASE crapcop.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_termo_adesao:

    DEF INPUT  PARAM par_cdcooper AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                 NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                 NO-UNDO.
                                                          
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                 NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_valexte1 AS CHAR FORMAT "x(82)"           NO-UNDO.
    DEF VAR aux_valexte2 AS CHAR FORMAT "x(81)"           NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                          NO-UNDO. 
    DEF VAR aux_dscritic AS CHAR                          NO-UNDO. 
    DEF VAR aux_nmcidade AS CHAR FORMAT "x(25)"           NO-UNDO.
    DEF VAR aux_dtmvtolt AS CHAR FORMAT "x(10)"           NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                          NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR                          NO-UNDO.
   
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    ASSIGN aux_nmcidade = crapcop.nmcidade
           aux_dtmvtolt = ""
           aux_nrcpfcgc = ""
           aux_nrdconta = ""
           aux_dtmvtolt = STRING(par_dtmvtolt,"99/99/9999").

    FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 9,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".

    END.

    IF crapass.inpessoa = 1 THEN
       ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
              aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
       ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
              aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

    FIND FIRST crapenc WHERE crapenc.cdcooper = crapass.cdcooper AND
                             crapenc.nrdconta = crapass.nrdconta 
                             NO-LOCK NO-ERROR.

    IF NOT AVAIL crapenc THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 247,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".

    END.

    FIND crappam WHERE crappam.cdcooper = par_cdcooper AND
                       crappam.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crappam THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 9,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".

    END.

    RUN fontes/extenso.p (INPUT crappam.vllimpam,
                          INPUT 82,
                          INPUT 81,
                          INPUT "M",
                          OUTPUT aux_valexte1,
                          OUTPUT aux_valexte2).

    ASSIGN aux_nrdconta = TRIM(STRING(crapass.nrdconta,"zzzz,zz9,9"))
           aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                 "/arq/termo_adesao_pamcard.ex".

    /** Se houver arquivo no arq, faz a remocao **/
    UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop 
                       + "/arq/termo_adesao_pamcard* 2> /dev/null").

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84 NO-ECHO.


    PUT STREAM str_1 SKIP(5)
                     "TERMO DE ADESAO AO CONTRATO DE PRESTACAO DE SERVICOS E AFILIACAO AO SISTEMA PAMCARD" AT 03
                     SKIP(6)
                     "Pelo presente Instrumento Particular de Termo de Adesao ao Contrato de Prestacao de" AT 03
                     SKIP
                     "Servicos e Afiliacao ao Sistema Pamcard, na forma da legislacao cooperativa,  assim" AT 03
                     SKIP
                     "como de acordo com o Estatuto Social da Cooperativa e das normas internas vigentes," AT 03
                     SKIP
                     "as partes tem entre si, justo e  contratado,  sendo  que  reciprocamente  concordam" AT 03
                     SKIP
                     "e aceitam as clausulas e condicoes abaixo:"                                          AT 03
                     SKIP(2)
                     "1 - DAS PARTES"                                                                      AT 03
                     SKIP(1)
                     "COOPERATIVA: A "                                                                     AT 03
                     TRIM(crapcop.nmextcop) FORMAT "x(50)"
                     "- "
                     crapcop.nmrescop FORMAT "x(15)"
                     ","
                     SKIP
                     "sociedade cooperativa, inscrita no CNPJ/MF sob o n. "                                AT 03
                     crapcop.nrdocnpj
                     ","
                     SKIP
                     "com sede na "                                                                        AT 03
                     TRIM(crapcop.dsendcop) FORMAT "x(40)"
                     ", n. "
                     TRIM(STRING(crapcop.nrendcop))
                     ", bairro"
                     SKIP
                     crapcop.nmbairro                                                                      AT 03
                     ", na cidade de "                                                                   
                     TRIM(aux_nmcidade) FORMAT "x(25)"
                     "/"
                     crapcop.cdufdcop FORMAT "x(2)"
                     " - CEP "
                     crapcop.nrcepend ","
                     SKIP
                     "neste ato representada por seus procuradores infra-assinados."                     AT 03
                     SKIP
                     "COOPERADO: "                                                                         AT 03
                     TRIM(crapass.nmprimtl) FORMAT "x(42)"
                     ", CPF/CNPJ:" TRIM(aux_nrcpfcgc) FORMAT "x(18)" ", "                     
                     SKIP
                     "endereco "                                                                          AT 03
                     TRIM(crapenc.dsendere) FORMAT "x(29)"                                                 
                     ", n. " TRIM(STRING(crapenc.nrendere)) ", ".
                     
                    
    

    IF crapenc.complend <> "" THEN
        PUT STREAM str_1 TRIM(crapenc.complend) FORMAT "x(29)"
                         ", "
                         SKIP.
         
    PUT STREAM str_1 SKIP
                     "bairro "                                                                           AT 03
                     TRIM(crapenc.nmbairro) FORMAT "x(40)" ", "                                
                     "CEP "                                                                                
                     TRIM(STRING(crapenc.nrcepend)) ", "                                                       
                     "cidade "
                     SKIP
                     TRIM(crapenc.nmcidade) FORMAT "x(25)"                                                 AT 03
                     ", " TRIM(crapenc.cdufende) FORMAT "X(2)"
                     ", neste ato representado por seus procuradores"
                     SKIP
                     "infra-assinados."                                                  AT 03
                     SKIP(2)
                     "2 - DO OBJETO"                                                                       AT 03
                     SKIP(1)
                     "O presente contrato tem por objeto  a  concessao  de  direito  de  uso  do  Sistema" AT 03
                     SKIP
                     "Pamcard, em face de convenio formalizado entre a COOPERATIVA  e  o  Banco  Bradesco" AT 03
                     SKIP
                     "S.A. e GPS Logistica e Gerenciamento de Riscos Ltda, possibilitando, em decorrencia" AT 03
                     SKIP
                     "deste convenio, a prestacao, pelas Contratadas, do servico de pagamento  eletronico" AT 03
                     SKIP
                     "de  frete   e   pedagio,   mediante   saldo   disponivel,   atraves   dos   Cartoes" AT 03
                     SKIP
                     "Pamcard-BR-Bradesco, emitidos em favor dos prestadores de  servico  indicados  pelo" AT 03
                     SKIP
                     "COOPERADO, dentro dos limites operacionais ajustados."                               AT 03
                     SKIP(2)
                     "3 - DO LIMITE OPERACIONAL"                                                           AT 03
                     SKIP(1)
                     "A COOPERATIVA abre ao COOPERADO um limite operacional de R$"                         AT 03
                     crappam.vllimpam
                     SKIP
                     "("                                                                                   AT 03
                     aux_valexte1.
                     
    IF LENGTH(aux_valexte2) > 0 THEN
        PUT STREAM str_1 SKIP
                         aux_valexte2 AT 03.

    ASSIGN aux_valexte1 = ""
           aux_valexte2 = "".

    RUN fontes/extenso.p (INPUT crapcop.vlmenpam,
                          INPUT 62,
                          INPUT 0,
                          INPUT "M",
                          OUTPUT aux_valexte1,
                          OUTPUT aux_valexte2).

    PUT STREAM str_1 "),"
                     SKIP
                     "para utilizacao  no  Sistema  Pamcard,  destinado  exclusivamente  as  recargas  de" AT 03
                     SKIP
                     "valores nas funcoes Vale Pedagio e Vale Frete  dos  Cartoes  Pamcard  BR  Bradesco," AT 03
                     SKIP
                     "fornecidos aos prestadores de servicos de transportes contratados  pelo  COOPERADO." AT 03
                     SKIP
                     "Paragrafo unico. O limite  ora  concedido  sera  recomposto  diariamente,  sendo  a" AT 03
                     SKIP
                     "recomposicao efetuada no dia subsequente ao do pagamento  dos  valores  utilizados," AT 03
                     "cujo pagamento se procedera mediante debito na conta corrente do Cooperado."         AT 03
                     SKIP(2)
                     "4 - DA FORMA DE UTILIZACAO DOS VALORES"                                              AT 03
                     SKIP(1)
                     "O repasse de valores do COOPERADO  aos  seus  prestadores  de  servico  sera  feito" AT 03
                     SKIP
                     "exclusivamente  por  intermedio  de  Cartoes  Pamcard-BR-Bradesco,  sendo   que   o" AT 03
                     SKIP
                     "carregamento dos cartoes e de responsabilidade do  COOPERADO,  feito  por  meio  de" AT 03
                     SKIP
                     "acesso a internet, por intermedio  de  endereco  eletronico  especifico  para  este" AT 03
                     SKIP
                     "servico, sendo tambem de responsabilidade do COOPERADO o cadastro e  utilizacao  de" AT 03
                     SKIP
                     "senhas para tal fim."                                                                AT 03
                     SKIP(1)
                     "§ 1o. Para a utilizacao da funcao Vale Pedagio e  necessario  um  carregador  smart" AT 03
                     SKIP
                     "card (chip), o qual devera atender ao padrao Visa Vale Pedagio, e  que  devera  ser" AT 03
                     SKIP
                     "adquirido pelo proprio COOPERADO, as suas expensas."                                 AT 03
                     SKIP(1)
                     "§ 2o. Por ser de conhecimento exclusivo do COOPERADO, cabera a este zelar pelo  uso" AT 03
                     SKIP
                     "adequado das senhas, nao as repassando para terceiros,  nao  podendo,  em  hipotese" AT 03
                     SKIP
                     "nenhuma, ser a COOPERATIVA responsabilizada pelo uso inadequado dos servicos."       AT 03
                     SKIP(1)
                     "§ 3o. O COOPERADO declara-se ciente de que em  caso  de  liberacao  de  valores  em" AT 03
                     SKIP
                     "cartao de terceiros, por erro operacional seu,  e  uma  vez  sacado  o  valor  pelo" AT 03
                     SKIP
                     "favorecido,  nao  existirao  meios  eletronicos  disponiveis   para   bloqueio   da" AT 03
                     SKIP
                     "utilizacao, retencao ou devolucao dos valores."                                      AT 03
                     SKIP(2)
                     "5 - DOS DEBITOS"                                                                     AT 03
                     SKIP(1)
                     "Fica a COOPERATIVA autorizada a proceder  debitos  diarios  na  conta  corrente  do" AT 03
                     SKIP
                     "COOPERADO, independentemente de previo aviso, para cobrir obrigacoes assumidas pela" AT 03
                     SKIP
                     "COOPERATIVA,  caracterizadas  pelas  recargas  nos  Cartoes  Pamcard  BR  Bradesco," AT 03
                     SKIP
                     "efetuadas em favor dos prestadores de servico de transportes por este  contratados." AT 03
                     SKIP(2)
                     "6 - DAS TARIFAS"                                                                     AT 03
                     SKIP(1)
                     "Alem dos debitos do total das recargas efetuadas pelo COOPERADO, fica a COOPERATIVA" AT 03
                     SKIP
                     "autorizada a proceder diariamente o debito das  tarifas  no  percentual  de"         AT 03
                     crapcop.pertxpam FORMAT "zz9.99"
                     "%,"
                     SKIP
                     "incidente e apurada sobre cada transacao de recarga efetuada nos cartoes."           AT 03
                     SKIP(2)
                     "7 - DA MENSALIDADE"                                                                  AT 03
                     SKIP(1)
                     "O COOPERADO, pela prestacao de servicos ora contratados, pagara, ainda,  a  quantia" AT 03
                     SKIP
                     "de R$"                                                                               AT 03
                     crapcop.vlmenpam
                     "("
                     aux_valexte1 FORMAT "x(62)"
                     ")"
                     SKIP 
                     "por mes a COOPERATIVA, com vencimento  no  dia "                                     AT 03
                     crappam.dddebpam FORMAT "99"
                     " de cada mes."
                     SKIP(2)
                     "8 - DA BASE DE DEFINICAO DO LIMITE OPERACIONAL"                                      AT 03
                     SKIP(1)
                     "O limite operacional  estabelecido  no  item  3  do  presente  Contrato,  destinado" AT 03
                     SKIP
                     "exclusivamente a concessao de limites para recarga dos Cartoes Pamcard BR Bradesco," AT 03
                     SKIP
                     "por parte dos seus Cooperados usuarios do referido produto, sera limitado ao  valor" AT 03
                     SKIP
                     "do limite do cheque especial concedido ao COOPERADO pela COOPERATIVA,  podendo  ser" AT 03
                     SKIP
                     "alterado para menos, mediante simples aviso de uma das partes à outra,  passando  o" AT 03
                     SKIP
                     "novo limite a vigorar na data fixada na comunicacao, assim como o  referido  limite" AT 03
                     SKIP
                     "podera, a criterio da COOPERATIVA, ser alterado para mais, passando o  novo  limite" AT 03
                     SKIP
                     "a vigorar na data fixada na comunicacao, ou pela efetiva utilizacao do novo  limite" AT 03
                     SKIP
                     "definido."                                                                           AT 03
                     SKIP(2)
                     "9 - DOS EXCESSOS QUANTO AO USO DO LIMITE"                                            AT 03
                     SKIP(1)
                     "O COOPERADO se compromete a exercer controle assiduo sobre os estouros de conta  em" AT 03
                     SKIP
                     "decorrencia das recargas efetuadas nos Cartoes BR Bradesco.  Inobstante,  sobre  os" AT 03
                     SKIP
                     "eventuais excessos ao limite contratual, em substituicao aos encargos do limite  de" AT 03
                     SKIP
                     "credito contratado no Contrato de Abertura de Credito em Conta Corrente,  incidirao" AT 03
                     SKIP
                     "encargos calculados a mesma taxa aplicada sobre os  adiantamentos  a  depositantes," AT 03
                     SKIP
                     "a mesma epoca."                                                                      AT 03
                     SKIP
                     "Paragrafo unico. A COOPERATIVA podera nao somente reduzir,  como  tambem  zerar,  o" AT 03
                     SKIP
                     "limite  operacional  dos  Cartoes  Pamcard,  apos  analise   da   conta   corrente," AT 03
                     SKIP
                     "independentemente do motivo de estouro da conta,  assim  como  cancelar  o  proprio" AT 03
                     SKIP
                     "Contrato de Abertura de Credito em Conta Corrente se houver reiterada utilizacao de" AT 03
                     SKIP
                     "excessos do limite de credito."                                                      AT 03
                     SKIP(2)
                     "10 - DO CREDITO ROTATIVO"                                                            AT 03
                     SKIP(1)
                     "Para manter o credito rotativo fica a COOPERATIVA autorizada  a  duplicar  a  conta" AT 03
                     SKIP
                     "original do COOPERADO, mediante abertura  de  outra  conta  corrente  e  limite  de" AT 03
                     SKIP
                     "credito, se assim aprovado apos analise de credito."                                 AT 03
                     SKIP
                     "Paragrafo unico. O limite de credito da conta duplicada sera a garantia da operacao" AT 03
                     SKIP
                     "Pamcard, sendo que se mantera bloqueada  pela  COOPERATIVA  para  movimentacao  por" AT 03
                     SKIP
                     "parte do COOPERADO, estando, porem, a primeira autorizada a efetuar  transferencias" AT 03
                     SKIP
                     "diarias da conta duplicada para a conta  original  do  COOPERADO,  para  cobrir  os" AT 03
                     SKIP
                     "debitos das recargas e tarifas efetuadas  na  conta  original,  conforme  termo  de" AT 03
                     SKIP
                     "autorizacao assinado pelo COOPERADO."                                                AT 03
                     SKIP(2)
                     "11 - DAS MULTAS E PENALIDADES LEGAIS"                                                AT 03
                     SKIP(1)
                     "O COOPERADO assume integral responsabilidade decorrente  de  eventuais  multas  que" AT 03
                     SKIP
                     "venham ser aplicadas contra a COOPERATIVA, por  culpa  direta  ou  indireta  deste," AT 03
                     SKIP
                     "decorrentes  de  qualquer  infracao,  nos  termos  do  previsto  na  Resolucao   de" AT 03
                     SKIP
                     "n. 3.658/2011, da AGENCIA NACIONAL DE TRANSPORTES TERRESTRES - ANTT."                AT 03
                     SKIP(2)
                     "12 - DOS DOCUMENTOS PROBANTES"                                                       AT 03
                     SKIP(1)
                     "O COOPERADO reconhece como prova de seus debitos  os  registros  de  utilizacao  do" AT 03
                     SKIP
                     "limite existentes no sistema operacional da  COOPERATIVA  e  os  demonstrativos  de" AT 03
                     SKIP
                     "lancamentos que a COOPERATIVA vier a expedir-lhe em consequencia os debitos diarios" AT 03
                     SKIP
                     "efetuados no extrato de conta corrente do COOPERADO."                                AT 03
                     SKIP(2)
                     "13 - DO PRAZO DO CONTRATO"                                                           AT 03
                     SKIP(1)
                     "O presente contrato vigorara por prazo indeterminado,  podendo,  contudo,  qualquer" AT 03
                     SKIP
                     "das partes declara-lo vencido  antecipadamente,  independentemente  de  notificacao" AT 03
                     SKIP
                     "judicial ou extrajudicial, bastante comunicacao por escrito a outra parte."          AT 03
                     SKIP
                     "§ 1o.  Operada  a  resilicao,  por  ato  unilateral  de  uma  das  partes,  fica  a" AT 03
                     SKIP
                     "COOPERATIVA, expressamente isenta do pagamento de toda e  qualquer  indenizacao  ou" AT 03
                     SKIP
                     "ressarcimento ao COOPERADO, o qual sera obrigado, contudo, ao integral pagamento de" AT 03
                     SKIP
                     "seu debito para com a COOPERATIVA, representado pelo saldo devedor."                 AT 03
                     SKIP
                     "§ 2o. O presente contrato tambem vencera antecipadamente,  autorizando  a  cobranca" AT 03
                     SKIP
                     "administrativa  ou  judicial  para  efeito  de  ser  exigido  de  imediato  na  sua" AT 03
                     SKIP
                     "totalidade,  com  todos  os  seus   acrescimos,   independentemente   de   qualquer" AT 03
                     SKIP
                     "notificacao, alem dos casos previstos em lei e nos itens anteriores deste contrato," AT 03
                     SKIP
                     "nas seguintes hipoteses:"                                                            AT 03
                     SKIP(1)
                     "a) descumprimento de qualquer das condicoes pactuadas;"                              AT 03
                     SKIP
                     "b) utilizar valor excedente ao limite de credito disponibilizado."                   AT 03
                     SKIP(2)
                     "14 - DO SALDO NO ENCERRAMENTO DO CONTRATO"                                           AT 03
                     SKIP(1)
                     "No vencimento do presente  contrato  por  qualquer  motivo,  legal  ou  contratual," AT 03
                     SKIP
                     "o COOPERADO obriga-se a pagar a COOPERATIVA o  saldo  devedor  existente  na  conta" AT 03
                     SKIP
                     "corrente referida neste instrumento, acrescido dos encargos contratuais  previstos," AT 03
                     SKIP
                     "no prazo maximo de 24 (vinte e quatro) horas, sob pena  de  constituicao  em  mora," AT 03
                     SKIP
                     "independentemente de aviso, notificacao ou interpelacao judicial ou  extrajudicial," AT 03
                     SKIP
                     "sujeitando-se  o  debito  aos  encargos  convencionais  e  moratorios,   multa   de" AT 03
                     SKIP
                     "2 % (dois por cento) e honorarios advocaticios ate a efetiva liquidacao."            AT 03
                     SKIP(2)
                     "15 - DA TOLERANCIA"                                                                  AT 03
                     SKIP(1)
                     "A eventual tolerancia por parte da COOPERATIVA no exigir o cumprimento do  presente" AT 03
                     SKIP
                     "contrato nao  acarretara  no  cancelamento  das  penalidades  previstas,  as  quais" AT 03
                     SKIP
                     "poderao ser aplicadas e exigidas a qualquer tempo, ainda que a tolerancia ou a  nao" AT 03
                     SKIP
                     "aplicacao das cominacoes ocorram repetidas vezes, consecutivas  ou  alternadamente," AT 03
                     SKIP
                     "o que nao implicara em precedentes,  renovacao  ou  modificacao  de  quaisquer  das" AT 03
                     SKIP
                     "disposicoes deste contrato, as  quais  permanecerao  integras  e  em  pleno  vigor," AT 03
                     SKIP
                     "como se nenhum favor tivesse ocorrido."                                              AT 03
                     SKIP(2)
                     "16 - DOS EFEITOS DO CONTRATO"                                                        AT 03
                     SKIP(1)
                     "Este contrato obriga a COOPERATIVA e o COOPERADO ao fiel cumprimento das  clausulas" AT 03
                     SKIP
                     "e condicoes estabelecidas no  mesmo,  sendo  celebrado  em  carater  irrevogavel  e" AT 03
                     SKIP
                     "irretratavel,  obrigando,  tambem,  seus  herdeiros,  cessionarios  e   sucessores," AT 03
                     SKIP
                     "a qualquer título."                                                                  AT 03
                     SKIP(2)
                     "17 - DO VINCULO COOPERATIVO"                                                         AT 03
                     SKIP(1)
                     "As partes declaram que o presente instrumento esta tambem vinculado as  disposicoes" AT 03
                     SKIP
                     "legais  que  regulam  o  cooperativismo,  ao  estatuto   social   da   COOPERATIVA," AT 03
                     SKIP
                     "as deliberacoes assembleares desta e as do seu Conselho de Administracao, aos quais" AT 03
                     SKIP
                     "o COOPERADO livre e espontaneamente aderiu ao  integrar  o  quadro  de  associados," AT 03
                     SKIP
                     "e cujo teor as partes ratificam, reconhecendo-se nesta operacao a celebracao de  um" AT 03
                     SKIP
                     "ATO COOPERATIVO."                                                                    AT 03
                     SKIP(2)
                     "18 - DO FORO"                                                                        AT 03
                     SKIP(1)
                     "As partes, de comum acordo, elegem o foro da Comarca  de  domicilio  do  COOPERADO," AT 03
                     SKIP
                     "com a exclusa de qualquer outro, por  mais  privilegiado  que  seja,  para  dirimir" AT 03
                     SKIP
                     "quaisquer questoes resultantes do presente contrato. E assim, por acharem justos  e" AT 03
                     SKIP
                     "contratados, assinaram o presente contrato, em 02  (duas)  vias  de  igual  teor  e" AT 03
                     SKIP
                     "forma, na presenca de duas testemunhas abaixo que, estando cientes, tambem assinam," AT 03
                     SKIP
                     "para que produzam os devidos efeitos legais."                                        AT 03
                     SKIP(5)
                     TRIM(aux_nmcidade) FORMAT "x(25)"                                                     AT 03
                     " ("
                     crapcop.cdufdcop
                     "),  " aux_dtmvtolt
                     SKIP(3)
                     "_____________________________________________"                                       AT 35
                     crapass.nmprimtl FORMAT "x(40)"                                                       AT 35
                     SKIP(1)
                     "Conta: "                                                                             AT 35
                     aux_nrdconta FORMAT "x(10)".



                            
    PAGE STREAM str_1.
    
    OUTPUT STREAM str_1 CLOSE.

    ASSIGN par_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + 
                                     "/arq/termo_adesao_pamcard.pdf".

    RUN gera_impressao (INPUT par_cdcooper,
                        INPUT aux_nmarquiv,
                        INPUT-OUTPUT par_nmarqpdf,
                       OUTPUT aux_dscritic).

    IF aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT aux_dscritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_termo_cancelamento:

    DEF INPUT PARAM par_cdcooper AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                   NO-UNDO.

    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                  NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR                           NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                           NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR FORMAT "x(25)"            NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR FORMAT "x(18)"            NO-UNDO.
    DEF VAR aux_dtmvtolt AS CHAR FORMAT "x(10)"            NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR                           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    ASSIGN aux_nmcidade = crapcop.nmcidade
           aux_nrcpfcgc = ""
           aux_dtmvtolt = ""
           aux_nrdconta = ""
           aux_dtmvtolt = STRING(par_dtmvtolt,"99/99/9999")
           aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crappam WHERE crappam.cdcooper = crapcop.cdcooper AND 
                       crappam.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crappam THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 9,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".

    END.

    FIND crapass WHERE crapass.cdcooper = crappam.cdcooper AND
                       crapass.nrdconta = crappam.nrdconta
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL crapass THEN
    DO:
        ASSIGN aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT 9,
                       INPUT-OUTPUT aux_dscritic).      
        
        RETURN "NOK".

    END.

    IF crapass.inpessoa = 1 THEN
       ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
              aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
       ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
              aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

    ASSIGN aux_nrdconta = TRIM(STRING(crapass.nrdconta,"zzzz,zz9,9"))
           aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                 "/arq/termo_cancelamento_pamcard.ex".


    /** Se houver arquivo no arq, faz a remocao **/
    UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop 
                       + "/arq/termo_cancelamento_pamcard* 2> /dev/null").

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84 NO-ECHO.

    PUT STREAM str_1 SKIP(3)
                     "A"                                                                                   AT 03
                     SKIP(2)
                     crapcop.nmextcop FORMAT "x(50)"                                                       AT 03
                     " - "
                     crapcop.nmrescop FORMAT "x(15)"
                     SKIP(2)
                     TRIM(aux_nmcidade) FORMAT "x(25)"                                                     AT 03
                     " - "
                     crapcop.cdufdcop
                     "."
                     SKIP(2)
                     "PEDIDO DE CANCELAMENTO DO TERMO DE ADESAO AO CONTRATO DE PRESTACAO  DE  SERVICOS  E" AT 03
                     SKIP
                     "AFILIACAO AO SISTEMA PAMCARD"                                                        AT 30
                     SKIP(3)
                     "Venho, pelo presente, requerer o cancelamento da minha adesao ao Termo de Adesao ao" AT 03
                     SKIP
                     "Contrato de Prestacao  de  Servicos  e  Afiliacao  ao  Sistema  Pamcard,  destinado" AT 03
                     SKIP
                     "exclusivamente as recargas de valores nas funcoes Vale Pedagio  e  Vale  Frete  dos" AT 03
                     SKIP
                     "Cartoes Pamcard BR Bradesco, mantido pela COOPERATIVA em forma de Convenio,  com  o" AT 03
                     SKIP
                     "BANCO BRADESCO S.A. e GPS LOGISTICA E GERENCIAMENTO DE RISCOS LTDA.,  declarando-me" AT 03
                     SKIP
                     "ciente que doravante  estarao  bloqueadas  todas  as  operacoes  dele  decorrentes," AT 03
                     SKIP
                     "assim como, assumindo ainda o compromisso de efetuar o pagamento total  de  valores" AT 03
                     SKIP
                     "pendentes ou valores futuros (encargos) gerados pela operacao Pamcard."              AT 03
                     SKIP(2)
                     "Por outro lado, a criterio da COOPERATIVA, podera ser cancelado o Credito Rotativo," AT 03
                     SKIP
                     "conforme  disposto  na  Clausula  10,  e,  por  consequencia,  o  encerramento   da" AT 03
                     SKIP
                     "conta-corrente de n."                                                                AT 03
                     crappam.nrctapam " e contrato de limite de credito a ela vinculada."
                     SKIP(3)
                     TRIM(aux_nmcidade) FORMAT "x(25)"                                                     AT 03
                     " ("
                     crapcop.cdufdcop
                     "),  " aux_dtmvtolt
                     SKIP(3)
                     "_____________________________________________"                                       AT 35
                     crapass.nmprimtl FORMAT "x(40)"                                                       AT 35
                     SKIP(1)
                     "Conta: "                                                                             AT 35
                     aux_nrdconta FORMAT "x(10)"                                       
                     SKIP(1)
                     "CPF/CNPJ: "                                                                          AT 35
                     aux_nrcpfcgc                                                      
                     SKIP(3)
                     "Recebido: ____/____/________"                                                        AT 03
                     SKIP(8)
                     "__________________________________"                                                  AT 03
                     SKIP
                     "(Assinatura e carimbo Cooperativa)"                                                  AT 03.

    PAGE STREAM str_1.
    
    OUTPUT STREAM str_1 CLOSE.


    ASSIGN par_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + 
                          "/arq/termo_cancelamento_pamcard.pdf".

    RUN gera_impressao (INPUT par_cdcooper,
                        INPUT aux_nmarquiv,
                        INPUT-OUTPUT par_nmarqpdf,
                        OUTPUT aux_dscritic).


    IF aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT aux_dscritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_impressao:

    DEF INPUT  PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT  PARAM par_nmarqimp AS CHAR NO-UNDO.

    DEF INPUT-OUTPUT  PARAM par_nmarqpdf AS CHAR NO-UNDO.

    DEF OUTPUT PARAM par_dscritic AS CHAR NO-UNDO.

    DEF VARIABLE h-b1wgen0024     AS HANDLE NO-UNDO.

               
    Imp-Web: DO WHILE TRUE:
        RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.
               
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN par_dscritic = "Handle invalido para BO b1wgen0024.".
            LEAVE Imp-Web.
        END.

        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                INPUT par_nmarqpdf).
              
        IF  SEARCH(par_nmarqpdf) = ?  THEN
        DO:
            ASSIGN par_dscritic = "Nao foi possivel gerar " + 
                                                "a impressao.".
            LEAVE Imp-Web.
        END.
               
        UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                      '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra 
                      + ':/var/www/ayllos/documentos/' + crapcop.dsdircop 
                      + '/temp/" 2>/dev/null').
               
        LEAVE Imp-Web.
    END. /** Fim do DO WHILE TRUE **/
               
    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE OBJECT h-b1wgen0024.  

    ASSIGN par_nmarqpdf = ENTRY(NUM-ENTRIES(par_nmarqpdf,"/"),par_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE processa_arquivo_debito:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR NO-UNDO.

    DEF OUTPUT PARAM par_flgrejei AS LOG NO-UNDO.
    DEF OUTPUT PARAM par_flgsuces AS LOG NO-UNDO.
    DEF OUTPUT PARAM par_flgjapro AS LOG NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_setlinha AS CHAR NO-UNDO.
    DEF VAR aux_qtregass AS INTE NO-UNDO.
    DEF VAR aux_qtregpam AS INTE NO-UNDO.
    DEF VAR aux_cdagenci AS INTE NO-UNDO.
    DEF VAR aux_nrdconta AS INTE NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.
    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_contador AS INTE NO-UNDO.

    EMPTY TEMP-TABLE tt-criticas-rel615.

    ASSIGN par_flgrejei = FALSE
           par_flgjapro = FALSE
           par_flgsuces = FALSE
           aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    /* Verifica se o arquivo de debito ja foi processado */
    FIND LAST craplog WHERE craplog.cdcooper = par_cdcooper AND
                            craplog.cdprogra = "PAMCARD"    AND
                            craplog.dstransa MATCHES par_nmarquiv + "*" 
                            NO-LOCK NO-ERROR.

    /* Se ja foi processado, entao remove o arquivo do diretorio /micros da
       cooperativa */
    IF AVAIL craplog THEN
       DO:
           ASSIGN par_flgjapro = TRUE.
           UNIX SILENT VALUE ("rm " + par_nmarquiv + " 2>/dev/null").
      
       END.
    ELSE
    DO:
        INPUT STREAM str_1 THROUGH VALUE("cat " + par_nmarquiv) NO-ECHO.

        IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

        DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
        
            IMPORT STREAM str_1 UNFORMATTED aux_setlinha.

            IF SUBSTR(aux_setlinha, 1, 1) = "9" THEN
                NEXT.

            ASSIGN aux_qtregass = 0
                   aux_qtregpam = 0.

            IF aux_contador = 10000 THEN
                ASSIGN aux_contador = 0.

            
            FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrcpfcgc = 
                                            DECI(SUBSTR(aux_setlinha, 16, 14)) 
                                   NO-LOCK:
                
                ASSIGN aux_qtregass = aux_qtregass + 1
                       aux_cdagenci = crapass.cdagenci
                       aux_nrdconta = crapass.nrdconta
                       aux_nmprimtl = crapass.nmprimtl.
                
                FIND crappam WHERE crappam.cdcooper = crapass.cdcooper AND
                                   crappam.nrdconta = crapass.nrdconta AND
                                   crappam.flgpamca = TRUE
                                   NO-LOCK NO-ERROR.

                IF AVAIL crappam THEN
                   DO: 
                       IF crapass.dtdemiss <> ? THEN
                          DO:
                              RUN gera_critica_rel615 
                                            (INPUT crapass.cdagenci,
                                             INPUT crappam.nrdconta,
                                             INPUT crapass.nmprimtl,
                                             INPUT crapass.nrcpfcgc,
                                             INPUT (DECI(SUBSTR(aux_setlinha,
                                                    346, 9)) / 100),
                                             INPUT (((DECI(SUBSTR(aux_setlinha,
                                                    346, 9)) / 100) * 
                                                    crapcop.pertxpam) / 100),
                                             INPUT "Cooperado Demitido." +
                                                   " Encerre o convenio.").
                   
                              NEXT.
                   
                          END.
                   
                       FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                          craphis.cdhistor = 1025
                                          NO-LOCK NO-ERROR.
                   
                       IF NOT AVAILABLE craphis THEN
                          DO:
                              ASSIGN aux_cdcritic = 526
                                     aux_dscritic = "".
                        
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,         /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).
                   
                              RETURN "NOK".
                   
                          END.
                           
                       IF craphis.indebcre = "C" THEN
                          DO:
                              ASSIGN aux_cdcritic = 093
                                     aux_dscritic = "".
                     
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,         /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).
                           
                              RETURN "NOK".
                     
                          END.
                   
                       FIND craphis WHERE craphis.cdcooper = par_cdcooper AND
                                          craphis.cdhistor = 1026
                                          NO-LOCK NO-ERROR.
                   
                       IF NOT AVAILABLE craphis THEN
                          DO:
                              ASSIGN aux_cdcritic = 526
                                     aux_dscritic = "".
                         
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,       /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).
                           
                              RETURN "NOK".
                         
                          END.
                       
                       IF craphis.indebcre = "C" THEN
                          DO:
                              ASSIGN aux_cdcritic = 093
                                     aux_dscritic = "".
                          
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT 1,        /** Sequencia **/
                                             INPUT aux_cdcritic,
                                             INPUT-OUTPUT aux_dscritic).
                           
                              RETURN "NOK".
                      
                          END.
                   
                       ASSIGN aux_cdcritic = 0.    
                       
                       FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                          craplot.dtmvtolt = par_dtmvtolt AND
                                          craplot.cdagenci = 1            AND
                                          craplot.cdbccxlt = 100          AND
                                          craplot.nrdolote = 9064 
                                          NO-ERROR.
                   
                       IF NOT AVAILABLE craplot THEN
                          DO:
                              CREATE craplot.
                   
                              ASSIGN craplot.cdcooper = par_cdcooper
                                     craplot.dtmvtolt = par_dtmvtolt
                                     craplot.cdagenci = 1
                                     craplot.cdbccxlt = 100
                                     craplot.nrdolote = 9064
                                     craplot.cdoperad = par_cdoperad
                                     craplot.tplotmov = 1.
                          END.

                       CREATE craplcm.
                       ASSIGN craplot.qtcompln = craplot.qtcompln + 1
                              craplot.qtinfoln = craplot.qtinfoln + 1
                              craplot.vlcompdb = craplot.vlcompdb + 
                                      (DECI(SUBSTR(aux_setlinha, 346, 9)) / 100)
                              craplot.vlinfodb = craplot.vlinfodb + 
                                      (DECI(SUBSTR(aux_setlinha, 346, 9)) / 100)
                              craplot.nrseqdig = craplot.nrseqdig + 1
                              craplcm.dtmvtolt = craplot.dtmvtolt
                              craplcm.cdagenci = craplot.cdagenci
                              craplcm.cdbccxlt = craplot.cdbccxlt
                              craplcm.nrdolote = craplot.nrdolote
                              craplcm.cdoperad = craplot.cdoperad
                              craplcm.nrdconta = crapass.nrdconta
                              craplcm.nrdctabb = crapass.nrdconta
                              craplcm.nrdctitg = crapass.nrdctitg
                              craplcm.vllanmto = 
                                      (DECI(SUBSTR(aux_setlinha, 346, 9)) / 100)
                              craplcm.cdhistor = 1025 /* DEB. PAMCARD */
                              craplcm.nrseqdig = craplot.nrseqdig
                              craplcm.nrdocmto = DECI(STRING(TIME, "99999") +
                                                      STRING(aux_contador))
                              
                              craplcm.cdcooper = par_cdcooper.
                       VALIDATE craplcm.

                              
                       ASSIGN aux_contador = aux_contador + 1.
                       
                       CREATE craplcm.
                       ASSIGN craplot.qtcompln = craplot.qtcompln + 1
                              craplot.qtinfoln = craplot.qtinfoln + 1
                              craplot.vlcompdb = craplot.vlcompdb + 
                                      ((DECI(SUBSTR(aux_setlinha, 346, 9)) / 100) *
                                        crapcop.pertxpam) / 100
                              craplot.vlinfodb = craplot.vlinfodb + 
                                      ((DECI(SUBSTR(aux_setlinha, 346, 9)) / 100) *
                                        crapcop.pertxpam) / 100
                              craplot.nrseqdig = craplot.nrseqdig + 1
                              craplcm.dtmvtolt = craplot.dtmvtolt
                              craplcm.cdagenci = craplot.cdagenci
                              craplcm.cdbccxlt = craplot.cdbccxlt
                              craplcm.nrdolote = craplot.nrdolote
                              craplcm.cdoperad = craplot.cdoperad
                              craplcm.nrdconta = crapass.nrdconta
                              craplcm.nrdctabb = crapass.nrdconta
                              craplcm.nrdctitg = crapass.nrdctitg
                              craplcm.vllanmto = 
                                 ((DECI(SUBSTR(aux_setlinha, 346, 9)) / 100) *
                                               crapcop.pertxpam) / 100
                              craplcm.cdhistor = 1026 /* TRFA PAMCARD */
                              craplcm.nrseqdig = craplot.nrseqdig
                              craplcm.nrdocmto = DECI(STRING(TIME, "99999") +
                                                      STRING(aux_contador))
                              craplcm.cdcooper = par_cdcooper.
                       VALIDATE craplcm.
                       VALIDATE craplot.

                       ASSIGN aux_contador = aux_contador + 1.
                   
                   
                       RUN gera_debito_rel615 (INPUT crapass.cdagenci,
                                               INPUT crappam.nrdconta,
                                               INPUT crapass.nmprimtl,
                                               INPUT crapass.nrcpfcgc,
                                               INPUT (DECI(SUBSTR(aux_setlinha, 
                                                                346, 9)) / 100),
                                               INPUT ((DECI(SUBSTR(aux_setlinha,
                                                         346, 9)) / 100) *
                                                       crapcop.pertxpam) / 100).
                   
                   
                   END.
                ELSE
                   DO:
                       FIND crappam WHERE crappam.cdcooper = crapass.cdcooper AND
                                          crappam.nrdconta = crapass.nrdconta AND
                                          crappam.flgpamca = FALSE
                                          NO-LOCK NO-ERROR.
                     
                       IF AVAIL crappam THEN
                          DO: 
                              RUN gera_critica_rel615 
                                      (INPUT aux_cdagenci,
                                       INPUT aux_nrdconta,
                                       INPUT aux_nmprimtl,
                                       INPUT DECI(SUBSTR(aux_setlinha, 16, 14)),
                                       INPUT (DECI(SUBSTR(aux_setlinha, 346, 9))
                                                                          / 100),
                                       INPUT (((DECI(SUBSTR(aux_setlinha,
                                                346, 9)) / 100) *
                                                crapcop.pertxpam) / 100),
                                       INPUT "Convenio inativo.").
                          
                              ASSIGN par_flgrejei = TRUE.
                     
                          END.   
                       ELSE
                          ASSIGN aux_qtregpam = aux_qtregpam + 1.


                   END.

            END.
            
            IF aux_qtregass = 0 THEN
               DO: 
                   RUN gera_critica_rel615 
                                    (INPUT 0,
                                     INPUT 0,
                                     INPUT "",
                                     INPUT DECI(SUBSTR(aux_setlinha, 16, 14)),
                                     INPUT (DECI(SUBSTR(aux_setlinha, 346, 9))
                                                                       / 100),
                                     INPUT (((DECI(SUBSTR(aux_setlinha,
                                                     346, 9)) / 100) *
                                                     crapcop.pertxpam) / 100),
                                     INPUT "CPF/CNPJ nao localizado.").
           
                   ASSIGN par_flgrejei = TRUE.
           
               END.
            ELSE
            IF aux_qtregass = aux_qtregpam THEN
               DO:   
                   RUN gera_critica_rel615
                                    (INPUT aux_cdagenci,
                                     INPUT 0           ,
                                     INPUT aux_nmprimtl,
                                     INPUT DECI(SUBSTR(aux_setlinha, 16, 14)),
                                     INPUT (DECI(SUBSTR(aux_setlinha, 346, 9))
                                                                       / 100),
                                     INPUT (((DECI(SUBSTR(aux_setlinha,
                                                      346, 9)) / 100) *
                                                      crapcop.pertxpam) / 100),
                                     INPUT "Cooperado sem convenio.").
           
                   ASSIGN par_flgrejei = TRUE.
           
               END.

        END.

        INPUT STREAM str_1 CLOSE.
        
        IF par_flgrejei THEN
           DO:
               CREATE craplog.
               ASSIGN craplog.cdcooper = par_cdcooper
                      craplog.cdprogra = "PAMCARD"
                      craplog.dttransa = par_dtmvtolt
                      craplog.hrtransa = TIME
                      craplog.cdoperad = par_cdoperad
                      craplog.dstransa = par_nmarquiv + 
                                           " - PROCESSADO COM REJEICOES.".
               VALIDATE craplog.

           END.
        ELSE
           DO:
               CREATE craplog.
               ASSIGN craplog.cdcooper = par_cdcooper
                      craplog.cdprogra = "PAMCARD"
                      craplog.dttransa = par_dtmvtolt
                      craplog.hrtransa = TIME
                      craplog.cdoperad = par_cdoperad
                      craplog.dstransa = par_nmarquiv + 
                                           " - PROCESSADO COM SUCESSO."
                      par_flgsuces = TRUE.
               VALIDATE craplog.
          
           END.

        UNIX SILENT VALUE ("cp " + par_nmarquiv + " /usr/coop/" + 
                           crapcop.dsdircop + "/salvar/" + 
                           SUBSTR(par_nmarquiv, INDEX(par_nmarquiv, "MT"),
                           LENGTH(par_nmarquiv) - 
                           INDEX(par_nmarquiv, "MT") + 1)).

        UNIX SILENT VALUE ("rm " + par_nmarquiv + " 2>/dev/null").

        RUN gera_relatorio_615 (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_dtmvtolt,
                                INPUT craplog.dstransa,
                                OUTPUT TABLE tt-erro).

        
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_critica_rel615:

    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmprimtl AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.
    DEF INPUT PARAM par_pertxpam AS DECI NO-UNDO.
    DEF INPUT PARAM par_dscritic AS CHAR NO-UNDO.

    CREATE tt-criticas-rel615.

    ASSIGN tt-criticas-rel615.cdagenci = par_cdagenci
           tt-criticas-rel615.nrdconta = par_nrdconta
           tt-criticas-rel615.nmprimtl = par_nmprimtl
           tt-criticas-rel615.nrcpfcgc = par_nrcpfcgc
           tt-criticas-rel615.vllanmto = par_vllanmto
           tt-criticas-rel615.pertxpam = par_pertxpam
           tt-criticas-rel615.dscritic = par_dscritic.

END PROCEDURE.

PROCEDURE gera_debito_rel615:

    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmprimtl AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc AS DECI NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI NO-UNDO.
    DEF INPUT PARAM par_pertxpam AS DECI NO-UNDO.
    
    CREATE tt-debitos-rel615.
    ASSIGN tt-debitos-rel615.cdagenci = par_cdagenci
           tt-debitos-rel615.nrdconta = par_nrdconta
           tt-debitos-rel615.nmprimtl = par_nmprimtl
           tt-debitos-rel615.nrcpfcgc = par_nrcpfcgc
           tt-debitos-rel615.vllanmto = par_vllanmto
           tt-debitos-rel615.pertxpam = par_pertxpam.

END PROCEDURE.

PROCEDURE busca_log_processamento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtinicio AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtfim    AS DATE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-log-processamento.

    EMPTY TEMP-TABLE tt-log-processamento.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.


    FOR EACH craplog WHERE craplog.cdcooper = par_cdcooper
                       AND craplog.cdprogra = "PAMCARD"
                       AND craplog.dttransa >= par_dtinicio
                       AND craplog.dttransa <= par_dtfim NO-LOCK:
        
        CREATE tt-log-processamento.
        ASSIGN tt-log-processamento.nmarquiv = SUBSTR(craplog.dstransa,
                                               INDEX(craplog.dstransa, "MT"),
                                            INDEX(craplog.dstransa, ".txt") -
                                            INDEX(craplog.dstransa, "MT") + 4)
               tt-log-processamento.dsstatus = SUBSTR(craplog.dstransa, 
                                              INDEX(craplog.dstransa, "-") + 1,
                                              LENGTH(craplog.dstransa) - 
                                              INDEX(craplog.dstransa, "-") - 1)
               tt-log-processamento.dtproces = craplog.dttransa.

    END.

    RETURN "OK".


END PROCEDURE.

PROCEDURE copia_relatorio_processamento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0024 AS HANDLE NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    par_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_nmarquiv.
    
    IF  SEARCH(par_nmarquiv) = ?  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Relatorio nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "HANDLE invalido para BO b1wgen0024.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    RUN efetua-copia-pdf IN h-b1wgen0024 (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_nmarquiv,
                                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0024.

    IF  RETURN-VALUE <> "OK"  THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_relatorio_615:

    DEF INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                NO-UNDO.
    DEF INPUT PARAM par_nmarquiv AS CHAR                NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmarquiv AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                        NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                        NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                      NO-UNDO.
    DEF VAR aux_nrdconta AS CHAR                        NO-UNDO.
    DEF VAR aux_totrecpr AS DEC FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_tottarpr AS DEC FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_totrecrj AS DEC FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_tottarrj AS DEC FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_totrecpg AS DEC FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_tottarpg AS DEC FORMAT "zzz,zz9.99"     NO-UNDO.
    DEF VAR aux_recid    AS RECID                       NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_totrecpr = 0  
           aux_tottarpr = 0
           aux_totrecrj = 0  
           aux_tottarrj = 0
           aux_totrecpg = 0
           aux_tottarpg = 0
           aux_dscritic = ""
           aux_nrdconta = ""
           aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                 "/rl/crrl615_" + 
                            SUBSTR(par_nmarquiv, INDEX(par_nmarquiv, "MT"),
                                   INDEX(par_nmarquiv, ".txt") - 
                                   INDEX(par_nmarquiv, "MT")) + ".lst".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,     /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    /** Se houver arquivo no rl, faz a remocao **/
    UNIX SILENT VALUE("rm " + aux_nmarquiv + " 2> /dev/null").

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84 NO-ECHO.

    /* Cdempres = 11 , Relatorio 615 em 132 colunas */
    { sistema/generico/includes/b1cabrel132.i "11" "615" }.
    
    PUT STREAM str_1 SKIP(1)
                     "STATUS DO ARQUIVO " SUBSTR(par_nmarquiv, 
                                                  INDEX(par_nmarquiv, "MT"),
                                                  LENGTH(par_nmarquiv) - 
                                                  INDEX(par_nmarquiv, "MT"))
                                                    FORMAT "x(40)".

    IF INDEX(par_nmarquiv, "REJEICOES") > 0 THEN
       PUT STREAM str_1 SKIP(3)
                        "DEBITOS REJEITADOS"
                        SKIP(2).

    FOR EACH tt-criticas-rel615 NO-LOCK BREAK BY tt-criticas-rel615.cdagenci
                                              BY tt-criticas-rel615.nrdconta:

        IF  LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) THEN
            DO:
                PAGE STREAM str_1.
            
                PUT STREAM str_1 SKIP(3)
                                 "DEBITOS REJEITADOS"
                                 SKIP(2).

                FIND crapage WHERE crapage.cdcooper = par_cdcooper               AND
                                   crapage.cdagenci = tt-criticas-rel615.cdagenci
                                   NO-LOCK NO-ERROR.
            
                PUT STREAM str_1 SKIP
                                 "PA " + STRING(tt-criticas-rel615.cdagenci) + " - " + 
                                 IF AVAIL crapage THEN crapage.nmresage ELSE "NAO INFORMADO" FORMAT "X(30)"
                                 SKIP(1).

                VIEW STREAM str_1 FRAME f_cab_criticas.

            END.

        IF  FIRST-OF (tt-criticas-rel615.cdagenci) THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = par_cdcooper               AND
                                   crapage.cdagenci = tt-criticas-rel615.cdagenci
                                   NO-LOCK NO-ERROR.

                PUT STREAM str_1 SKIP
                                 "PA " + STRING(tt-criticas-rel615.cdagenci) + " - " + 
                                 IF AVAIL crapage THEN crapage.nmresage ELSE "NAO INFORMADO" FORMAT "X(30)"
                                 SKIP(1).

                VIEW STREAM str_1 FRAME f_cab_criticas.

            END.

        ASSIGN aux_nrdconta = ""
               aux_nrdconta = TRIM(STRING(tt-criticas-rel615.nrdconta,
                                          "zzzz,zz9,9"))
               aux_totrecrj = aux_totrecrj + tt-criticas-rel615.vllanmto
               aux_tottarrj = aux_tottarrj + tt-criticas-rel615.pertxpam
               aux_totrecpg = aux_totrecpg + tt-criticas-rel615.vllanmto
               aux_tottarpg = aux_tottarpg + tt-criticas-rel615.pertxpam.
               
               
        DISP STREAM str_1 aux_nrdconta FORMAT "x(10)"
                        @ tt-criticas-rel615.nrdconta
                          tt-criticas-rel615.nmprimtl
                          tt-criticas-rel615.nrcpfcgc
                          tt-criticas-rel615.vllanmto
                          tt-criticas-rel615.pertxpam
                          tt-criticas-rel615.dscritic
                          WITH FRAME f_criticas.
        
        DOWN STREAM str_1 WITH FRAME f_criticas.

        IF  LAST-OF (tt-criticas-rel615.cdagenci) THEN
            DO:
                PUT STREAM str_1 SKIP "----------" AT 68
                                      "----------" AT 79.
       
                PUT STREAM str_1 SKIP
                                "TOTAL:"     AT 0
                                aux_totrecpg AT 68
                                aux_tottarpg AT 79
                                SKIP(2).
       
                ASSIGN aux_totrecpg = 0
                       aux_tottarpg = 0.
               
           END.
    END.
    
    IF CAN-FIND(FIRST tt-debitos-rel615) THEN
       DO:
           PUT STREAM str_1 SKIP(3)
                            "DEBITOS PROCESSADOS"
                            SKIP(2).
       END.

    ASSIGN aux_totrecpg = 0
           aux_tottarpg = 0
           aux_recid    = ?.

  
    FOR EACH tt-debitos-rel615 NO-LOCK BREAK BY tt-debitos-rel615.cdagenci
                                             BY tt-debitos-rel615.nrdconta:

        IF LINE-COUNTER(str_1) > PAGE-SIZE(str_1) THEN
           DO:
               PAGE STREAM str_1.
         
               PUT STREAM str_1 SKIP(3)
                                "DEBITOS PROCESSADOS"
                                SKIP(2).

               FIND crapage WHERE crapage.cdcooper = par_cdcooper               AND
                                  crapage.cdagenci = tt-debitos-rel615.cdagenci
                                  NO-LOCK NO-ERROR.

               PUT STREAM str_1 SKIP
                                "PA " + STRING(tt-debitos-rel615.cdagenci) + " - " + 
                                IF AVAIL crapage THEN crapage.nmresage ELSE "NAO INFORMADO" FORMAT "X(30)"
                                SKIP(1).

               VIEW STREAM str_1 FRAME f_cab_debitos.
         
           END.

        IF  FIRST-OF (tt-debitos-rel615.cdagenci) THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = par_cdcooper               AND
                                   crapage.cdagenci = tt-debitos-rel615.cdagenci
                                   NO-LOCK NO-ERROR.

                PUT STREAM str_1 SKIP
                                 "PA " + STRING(tt-debitos-rel615.cdagenci) + " - " + 
                                 IF AVAIL crapage THEN crapage.nmresage ELSE "NAO INFORMADO" FORMAT "X(30)"
                                 SKIP(1).

                VIEW STREAM str_1 FRAME f_cab_debitos.

            END.
            
        ASSIGN aux_nrdconta = ""
               aux_nrdconta = TRIM(STRING(tt-debitos-rel615.nrdconta,
                                          "zzzz,zz9,9"))
               aux_totrecpr = aux_totrecpr + tt-debitos-rel615.vllanmto
               aux_tottarpr = aux_tottarpr + tt-debitos-rel615.pertxpam
               aux_totrecpg = aux_totrecpg + tt-debitos-rel615.vllanmto
               aux_tottarpg = aux_tottarpg + tt-debitos-rel615.pertxpam.

        DISP STREAM str_1 aux_nrdconta FORMAT "x(10)" 
                        @ tt-debitos-rel615.nrdconta
                          tt-debitos-rel615.nmprimtl
                          tt-debitos-rel615.nrcpfcgc
                          tt-debitos-rel615.vllanmto
                          tt-debitos-rel615.pertxpam
                          WITH FRAME f_debitos.

        DOWN STREAM str_1 WITH FRAME f_debitos.

        IF  LAST-OF (tt-debitos-rel615.cdagenci) THEN
            DO:
                PUT STREAM str_1 SKIP "----------" AT 79
                                      "----------" AT 90.

                PUT STREAM str_1 SKIP
                                 "TOTAL:"     AT 0
                                 aux_totrecpg AT 78
                                 aux_tottarpg AT 89
                                 SKIP(2).
   
                ASSIGN aux_totrecpg = 0
                       aux_tottarpg = 0.
               
           END.
    END.

    PUT STREAM str_1 SKIP(3)
                     "Processados:    Recarga - " aux_totrecpr
                     "Tarifas - " AT 41
                     aux_tottarpr "Tota" AT 65 "l - " AT 69 (aux_totrecpr + aux_tottarpr)
                     SKIP(1)
                     "Rejeitados:     Recarga - " aux_totrecrj
                     "Tarifas - " AT 41
                     aux_tottarrj "Tota" AT 65 "l - " AT 69 (aux_totrecrj + aux_tottarrj).


    OUTPUT STREAM str_1 CLOSE.

    ASSIGN aux_nmarqpdf = SUBSTR(aux_nmarquiv, 1, LENGTH(aux_nmarquiv) - 3) +
                                "pdf".
    
    RUN gera_impressao (INPUT par_cdcooper,
                        INPUT aux_nmarquiv,
                        INPUT-OUTPUT aux_nmarqpdf,
                       OUTPUT aux_dscritic).

    
    IF aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT 0,
                       INPUT 0,            /** Sequencia **/
                       INPUT aux_dscritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
    Imp-Web: DO WHILE TRUE:
        RUN sistema/generico/procedures/b1wgen0024.p 
                                            PERSISTENT SET h-b1wgen0024.
               
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".
            LEAVE Imp-Web.
        END.
        
        RUN gera-arquivo-intranet IN h-b1wgen0024 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_dtmvtolt,
                                                   INPUT aux_nmarquiv,
                                                   INPUT "132col",
                                                  OUTPUT TABLE tt-erro).

        LEAVE Imp-Web.

    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE OBJECT h-b1wgen0024.

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE gera-rel-cheque-especial:

    DEF INPUT PARAM par_cdcooper AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                                   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                                   NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                                  NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                                  NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
    DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.

    DEFINE BUFFER crablim FOR craplim.

    DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
    DEF VAR aux_vlstotal AS DECI FORMAT "zzz,zzz,zz9.99-"                  NO-UNDO.
    DEF VAR aux_vllimite AS DECI                                           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 84.

    /* Cdempres = 11 , Relatorio 630 em 132 colunas */
    { sistema/generico/includes/b1cabrel132.i "11" "630" }.

     RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
            SET h-b1wgen0001.

     IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
         DO: 
             ASSIGN aux_dscritic = "Handle invalido para BO " +
                                   "b1wgen0001.".
             LEAVE.
         END.
   
    FOR EACH crappam WHERE crappam.cdcooper = par_cdcooper     AND
                           crappam.flgpamca = TRUE
                           NO-LOCK,
       FIRST craplim WHERE craplim.cdcooper = crappam.cdcooper AND
                           craplim.nrdconta = crappam.nrctapam AND
                           craplim.insitlim <> 3               AND
                           craplim.tpctrlim = 1 
                           NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper = crappam.cdcooper AND
                           crapass.nrdconta = crappam.nrdconta AND
                           crapass.dtdemiss = ?
                           NO-LOCK
                           BY crapass.cdagenci.

        FIND FIRST crablim WHERE crablim.cdcooper = craplim.cdcooper AND
                                 crablim.nrdconta = crappam.nrdconta AND
                                 crablim.insitlim <> 3               AND
                                 crablim.tpctrlim = 1 
                                 NO-LOCK NO-ERROR.

        IF  NOT AVAIL crablim THEN
            ASSIGN aux_vllimite = 0.
        ELSE
            ASSIGN aux_vllimite = crablim.vllimite.

        ASSIGN aux_vlstotal = 0.

        RUN carrega_dep_vista IN h-b1wgen0001 (INPUT crappam.cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT crappam.nrctapam,
                                               INPUT par_dtmvtolt,
                                               INPUT 1,
                                               INPUT 1,
                                               INPUT "PAMCAR",
                                               INPUT FALSE,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-saldos,
                                              OUTPUT TABLE tt-libera-epr).
    
        IF  RETURN-VALUE = "NOK"  THEN
            NEXT.

        RUN carrega_dep_vista IN h-b1wgen0001 (INPUT crappam.cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT crappam.nrdconta,
                                               INPUT par_dtmvtolt,
                                               INPUT 1,
                                               INPUT 1,
                                               INPUT "PAMCAR",
                                               INPUT FALSE,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-saldos_original,
                                              OUTPUT TABLE tt-libera-epr).

        IF  RETURN-VALUE = "NOK"  THEN
            NEXT.

        FIND FIRST tt-saldos_original NO-LOCK NO-ERROR.
        FIND FIRST tt-saldos          NO-LOCK NO-ERROR.

        IF  NOT AVAIL tt-saldos OR
            NOT AVAIL tt-saldos_original THEN
            NEXT.

        IF  tt-saldos.vlstotal < 0 THEN
            ASSIGN aux_vlstotal = tt-saldos.vlstotal.
        ELSE
            ASSIGN aux_vlstotal = 0.

        DISPLAY STREAM str_1 crapass.cdagenci COLUMN-LABEL "PA"
                             crappam.nrdconta COLUMN-LABEL "Conta/Dv"
                             crappam.nrctapam COLUMN-LABEL "C/C Duplic."
                             crapass.nmprimtl COLUMN-LABEL "Nome"
                             crappam.vllimpam COLUMN-LABEL "Lim.Pamcard"
                             craplim.vllimite COLUMN-LABEL "Lim.Cred.C/C Dupl."
                             aux_vlstotal     COLUMN-LABEL "Lim.Utiliz.C/C Duplic."
                             tt-saldos_original.vlstotal COLUMN-LABEL "Saldo C/C Orig."
                             aux_vllimite     COLUMN-LABEL "Lim.Cred.C/C Original."
                             WITH WIDTH 200.

        IF LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

    END.

    IF  VALID-HANDLE(h-b1wgen0001)  THEN
        DELETE PROCEDURE h-b1wgen0001.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.

        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO: 
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
                LEAVE.
            END.
        
        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                INPUT aux_nmarqpdf).

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  SEARCH(aux_nmarqpdf) = ?  THEN
            DO: 
                ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                      " a impressao.".
                LEAVE.                      
            END.

            UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                               '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                               ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                               '/temp/" 2>/dev/null').

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE PROCEDURE h-b1wgen0024.

    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").


    RETURN "OK".

END PROCEDURE.



PROCEDURE gera-rel-inf-cadastrais:

    DEF INPUT PARAM par_cdcooper AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                                   NO-UNDO.
    DEF INPUT PARAM par_dsiduser AS CHAR                                   NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                                   NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                                  NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                                  NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 84.

    /* Cdempres = 11 , Relatorio 629 em 132 colunas */
    { sistema/generico/includes/b1cabrel132.i "11" "629" }.

    FOR EACH crappam WHERE crappam.cdcooper = par_cdcooper
                           NO-LOCK,
       EACH  craplim WHERE craplim.cdcooper = crappam.cdcooper AND
                           craplim.nrdconta = crappam.nrctapam AND
                           craplim.insitlim <> 3               AND
                           craplim.tpctrlim = 1                
                           NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper = crappam.cdcooper AND
                           crapass.nrdconta = crappam.nrdconta AND
                           crapass.dtdemiss = ?                 
                           NO-LOCK
                           BY crappam.flgpamca DESC
                           BY crapass.cdagenci.

        DISPLAY STREAM str_1 crapass.cdagenci COLUMN-LABEL "PA"
                             crappam.nrdconta COLUMN-LABEL "Conta/Dv" AT 7
                             crapass.nmprimtl COLUMN-LABEL "Nome/Razao Social" AT 20
                             crapass.nrcpfcgc COLUMN-LABEL "CPF/CNPJ"       AT 73   
                             crappam.vllimpam COLUMN-LABEL "Lim.Pamcard"    AT 88   
                             crappam.dddebpam COLUMN-LABEL "Deb.Mens."      AT 105
                             crappam.nrctapam COLUMN-LABEL "C/C Duplic."    AT 117
                             craplim.vllimite COLUMN-LABEL "Lim.C/C Dupl."  AT 131
                             crappam.flgpamca FORMAT "Ativo/Inativo"
                                              COLUMN-LABEL "Sit.Conv"       AT 149   
                             WITH WIDTH 200.

        IF LINE-COUNTER(str_1) >= PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

    END.

    OUTPUT STREAM str_1 CLOSE.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.

        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO: 
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0024.".
                LEAVE.
            END.
        
        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                INPUT aux_nmarqpdf).

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  SEARCH(aux_nmarqpdf) = ?  THEN
            DO: 
                ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                      " a impressao.".
                LEAVE.                      
            END.

            UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                               '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                               ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                               '/temp/" 2>/dev/null').

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE PROCEDURE h-b1wgen0024.

    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    RETURN "OK".

END PROCEDURE.
