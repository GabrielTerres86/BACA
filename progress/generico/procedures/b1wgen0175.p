/* .............................................................................

   Programa: b1wgen0175.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Andre Santos - SUPERO
   Data    : Setembro/2013                      Ultima atualizacao: 16/04/2018
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : BO referente a DEVOLU
   Observacoes: Incluido tratamento para conta migrada da 
                Acredi->Viacredi e efetuada correcao na validacao
                dos campos aux_cdbanchq e aux_cdagechq quando for
                cheque de conta migrada - Softdesk 106687 (Diego).

                Referente a GERADEV.p - Exclusao da alinea 29. (Fabricio)

   Alteracoes: 06/03/2014 - Incluso VALIDATE (Daniel).
   

   27/04/2015 - #273953 - Inclusao de verificacao das incorporacoes de concredi e
                  credimilsul;
                - Correcao de verificacao de avail do buffer crabcop;
                - Melhoria de busca de crapsol;
                - Incluida a mensagem para devolucoes de BB e bancoob na procedure 
                  marcar_cheque_devolu;
                - Correcao da procedure valida_alinea para cheques ja devolvidos 
                  pela alinea 11;
                - Retiradas de chamadas duplicadas da procedure gera_erro;
                - Correcao de tratamento de migracao altovale;
                - Verificacao de erros para nao gerar log falso;
                - Correcao de mensagem de log de erro.
                (Carlos)

   16/06/2015 - #281178 Para separar os lançamentos manuais ref. a cheque compensado
                e não integrado dos demais lançamentos, foi criado o historico 1873 
                com base no 521. Tratamento p hist 1873 igual ao tratamento 
                do hist 521 (Carlos)

   31/07/2015 - Correcao do final do bloco da condicao "IF par_cddevolu >= 4";
              - Replicada a seguinte atividade que estah no crps264: Ajustar os 
                log para informar o que está acontecendo no processo ao invés de 
                imprimir MESSAGE que poluem o proc_batch (Douglas - Chamado 307649)
                (Carlos)

   07/08/2015 - Ajuste na busca-devolucoes-cheque na consulta na tabela craplcm 
                para melhorias de performace SD281896 (Odirlei-AMcom)      

   29/10/2015 - Inclusao do indicador estado de crise. (Jaison/Andrino)

   16/11/2015 - Incluido Fato Gerador no parametro cdpesqbb na procedure
                cria_lan_auto_tarifa, Projeto Tarifas (Jean Michel).

   07/12/2015 - #367740 Criado o tratamento para o historico 1874 assim como eh
                feito com o historico 1873 (Carlos)

   14/12/2015 - Incluir tratamento da alinea 59 SD360177 (Odirlei-AMcom)            

   21/12/2015 - Ajustar as validacoes de alinea, conforme revisao de alineas
                e processo de devolucao de cheque (Douglas - Melhoria 100)

   07/01/2016 - Ajustado para quando existir uma descricao especifica na validacao
                de alineas, gerar o erro com cdcritic = 0, para manter a descricao
                (Douglas - Melhoria 100)

   08/01/2016 - Ajustado para criar apenas um registro de erro na procedure
                valida_saldo_devolu (Douglas - Melhoria 100)

   12/02/2016 - Ajustes decorrente a homologação do projeto M100
				(Adriano).

   05/05/2016 - Ajuste na lógica utilizada para devolução de cheques
			    pela alinea 11
				(Adriano - SD 445681)

   12/07/2016 - #451040 Trazer número da conta para as devoluções de alínea 37 
                (Carlos)

   11/10/2016 - #534932 Incluido o parametro ISPB na chamada de grava-log-ted em 
                envia_arquivo_xml (Carlos)

   19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao automatica 
                de cheques (Lucas Ranghetti #484923)

   07/11/2016 - Validar horario para devolucao de acordo com o parametrizado na TAB055
                (Lucas Ranghetti #539626)

   02/12/2016 - Incorporacao Transulcred (Guilherme/SUPERO)

   02/12/2016 - Validar alinea zerada na marcacao do cheque (Lucas Ranghetti/Elton)

   29/12/2016 - Ajustes na procedure busca-devolucoes-cheque para considerar
                conta migrada e buscar de forma correta no PA correto
				(Tiago/Elton SD579158)
                
   27/03/2017 - Incluir tratamento para formularios migrados da acredi para viacredi 
                (Lucas Ranghetti #619830)
                
   13/06/2017 - Ajustes para o novo formato de devoluçao de Sessao Única, de 
                Fraudes/Impedimentos e remoçao do processo de devoluçao de Cheques.
                PRJ367 - Compe Sessao Unica (Lombardi)

   16/04/2018 - Incluido tratamento na procedure valida-alinea para nao 
                criticar horario limite de devolucao quando se tratar de 
				cheques trocados no caixa (Diego).
   
............................................................................. */
DEF STREAM str_1.  /*  Para relatorio de entidade  */

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0175tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1. /* Relatorios */
DEF STREAM str_2. /* Arquivos   */

DEF BUFFER crabass5 FOR crapass.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR rel_nmempres AS CHAR             FORMAT "x(15)"                NO-UNDO.
DEF VAR rel_nmresemp AS CHAR             FORMAT "x(15)"                NO-UNDO.
DEF VAR rel_nmrelato AS CHAR             FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF VAR rel_nrmodulo AS INTE             FORMAT "9"                    NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR             FORMAT "x(15)" EXTENT 5
                            INIT ["DEP. A VISTA   ","CAPITAL        ",
                                  "EMPRESTIMOS    ","DIGITACAO      ",
                                  "GENERICO       "]                   NO-UNDO.

DEF VAR res_nrdctabb AS INTE                                           NO-UNDO.
DEF VAR res_nrdocmto AS INTE                                           NO-UNDO.
DEF VAR res_cdhistor AS INTE                                           NO-UNDO.

DEF VAR tab_txdevchq AS DECI                                           NO-UNDO.

DEF VAR aux_cdagenci AS INTE     INIT 1                                NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE     INIT 100                              NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.

/* Variaveis para conta de integracao */
DEF VAR aux_nrctaass AS INT              FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF VAR aux_ctpsqitg LIKE craplcm.nrdctabb                             NO-UNDO.
DEF VAR aux_nrdctitg LIKE crapass.nrdctitg                             NO-UNDO.
                                                         
DEF VAR rel_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR aux_nmrescop AS CHAR     EXTENT 2                              NO-UNDO.
DEF VAR rel_qtchqdev AS INTE                                           NO-UNDO.
DEF VAR rel_vlchqdev AS DECI             FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF VAR rel_nmdestin AS CHAR                                           NO-UNDO.
DEF VAR aux_qtpalavr AS INTE                                           NO-UNDO.
DEF VAR aux_contapal AS INTE                                           NO-UNDO.

DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_nrctalcm AS INTE                                           NO-UNDO.
                                                   
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqdev AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdigitg AS CHAR                                           NO-UNDO.
DEF VAR aux_dtmovime AS CHAR                                           NO-UNDO.
DEF VAR flg_devolbcb AS LOGICAL                                        NO-UNDO.
                                                    
DEF VAR aux_cdhistor AS CHAR                                           NO-UNDO.
                                                    
DEF VAR aux_cdhisest AS INTE                                           NO-UNDO.
DEF VAR aux_dtdivulg AS DATE                                           NO-UNDO.
DEF VAR aux_dtvigenc AS DATE                                           NO-UNDO.
DEF VAR par_dscritic LIKE crapcri.dscritic                             NO-UNDO.
DEF VAR aux_vltarifa AS DECI             FORMAT "zz9.99"               NO-UNDO.
DEF VAR aux_cdfvlcop AS INTE                                           NO-UNDO.

/* Variaveis da taxa bacen*/
DEF VAR aux_cdhisbac AS INTE                                           NO-UNDO.
DEF VAR aux_vltarbac AS DECI             FORMAT "zz9.99"               NO-UNDO.
DEF VAR aux_cdfvlbac AS INTE                                           NO-UNDO.

DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0011 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0050 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0153 AS HANDLE                                         NO-UNDO.
DEF VAR h_b1wgen0000 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF VAR par_numipusr AS CHAR                                  NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

DEF VAR aux_nrdconta_tco AS INTE                              NO-UNDO. 
DEF VAR aux_cdagectl     AS INTE                              NO-UNDO. 
DEF VAR aux_cdcopant     AS INTE                              NO-UNDO.
DEF VAR aux_vlaplica     AS DEC                               NO-UNDO.

FUNCTION f_ver_contaitg RETURN INTEGER(INPUT  par_nrdctitg AS CHAR):

    IF  par_nrdctitg = "" THEN
        RETURN 0.
    ELSE DO:
        IF  CAN-DO("1,2,3,4,5,6,7,8,9,0",
            SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
            RETURN INTEGER(STRING(par_nrdctitg,"99999999")).
        ELSE
            RETURN INTEGER(SUBSTR(STRING(par_nrdctitg,"99999999"),
                               1,LENGTH(par_nrdctitg) - 1) + "0").
    END.

END. /* FUNCTION */

/******************************************************************************/

PROCEDURE busca-valor-cheque:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_nmsistem LIKE craptab.nmsistem                 NO-UNDO.
    DEF INPUT PARAM par_tptabela LIKE craptab.tptabela                 NO-UNDO.
    DEF INPUT PARAM par_cdempres LIKE craptab.cdempres                 NO-UNDO.
    DEF INPUT PARAM par_cdacesso LIKE craptab.cdacesso                 NO-UNDO.
    DEF INPUT PARAM par_tpregist LIKE craptab.tpregist                 NO-UNDO.

    DEF OUTPUT PARAM ret_valorvlb AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM ret_vldevolu AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    /*  Busca dados da cooperativa  */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop THEN DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        RETURN "NOK".
    END. 
             
    /* Leitura da tabela com o valor definido para cheque VLB */ 
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  
                   AND craptab.nmsistem = par_nmsistem        
                   AND craptab.tptabela = par_tptabela      
                   AND craptab.cdempres = par_cdempres             
                   AND craptab.cdacesso = par_cdacesso  
                   AND craptab.tpregist = par_tpregist             
                   NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craptab THEN DO:
        ASSIGN aux_cdcritic = 55
               aux_dscritic = "".
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        RETURN "NOK".
    END. 
    
    ASSIGN  ret_valorvlb = DECIMAL(ENTRY(2, craptab.dstextab, ";"))
            ret_vldevolu = DECIMAL(ENTRY(3, craptab.dstextab, ";")). 

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/


PROCEDURE busca-devolucoes-cheque:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdev.dtmvtolt                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan AS DATE                               NO-UNDO. 
    DEF INPUT PARAM par_stsnrcal AS LOGICAL                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta LIKE crapass.nrdconta                 NO-UNDO.
    DEF INPUT PARAM par_cdagenci LIKE crapage.cdagenci                 NO-UNDO.

    DEF INPUT PARAM par_flgpagin AS LOG                                NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INT                                NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INT                                NO-UNDO.
                                                                               
    DEF OUTPUT PARAM par_qtregist AS INT                               NO-UNDO.
    DEF OUTPUT PARAM ret_nmprimtl LIKE crapass.nmprimtl                NO-UNDO.
    DEF OUTPUT PARAM ret_dsdctitg AS CHAR                              NO-UNDO. 
    DEF OUTPUT PARAM TABLE FOR tt-lancto.
    DEF OUTPUT PARAM TABLE FOR tt-devolu.    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_dtrefere AS DATE                                       NO-UNDO.
    DEF VAR aux_nrcalcul AS INTE                                       NO-UNDO.
    DEF VAR aux_stsnrcal AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdconta LIKE crapass.nrdconta                         NO-UNDO.
    DEF VAR aux_cdcooper LIKE crapcop.cdcooper                         NO-UNDO.
    DEF VAR aux_cdagechq AS INTE                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_regexist AS LOG                                        NO-UNDO.
    
    DEF VAR aux_vlsldtot AS DEC                                        NO-UNDO.
    DEF VAR aux_vlsldprp AS DEC                                        NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.

    DEF  VAR aux_cdcopfdc AS INT                                       NO-UNDO.

    DEF VAR aux_nrregist AS INT NO-UNDO.

    EMPTY TEMP-TABLE tt-devolu.
    EMPTY TEMP-TABLE tt-lancto.    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_nrregist = par_nrregist.

    IF  par_cdagenci > 0 THEN
        DO:
            FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper
                                 AND crapage.cdagenci = par_cdagenci
                                 NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapage THEN DO:
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "PA nao cadastrado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            
            IF  par_nrdconta > 0 THEN
                DO:
                    /* Busca informacoes do associado com o PA*/
                    FIND crapass WHERE crapass.cdcooper = par_cdcooper              
                                   AND crapass.nrdconta = par_nrdconta
                                   AND crapass.cdagenci = par_cdagenci
                                   NO-LOCK NO-ERROR.
                                   
                    IF  NOT AVAILABLE crapass THEN DO:
                        
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Associado nao pertence ao PA.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.    
                END.
        END.  

    IF  par_nrdconta > 0 THEN DO:
            
        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
            SET h-b1wgen9999.
    
        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen9999.".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.        
  
      RUN dig_fun IN h-b1wgen9999(INPUT par_cdcooper,
                                  INPUT 0, /* par_cdagenci */
                                  INPUT 0, /* par_nrdcaixa */
                                  INPUT-OUTPUT par_nrdconta,
                                  OUTPUT TABLE tt-erro).
      
      IF  VALID-HANDLE(h-b1wgen9999)  THEN
          DELETE PROCEDURE h-b1wgen9999.
  
      IF  RETURN-VALUE <> "OK"   THEN
          RETURN "NOK".
  
        /* Busca informacoes do associado */
        FIND crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

        IF  NOT par_stsnrcal OR NOT AVAILABLE crapass THEN DO:
            
            IF NOT par_stsnrcal THEN DO:
               ASSIGN aux_cdcritic = 8 /* Digito Errado */
                      aux_dscritic = "".
            
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
            
               RETURN "NOK".
            END.
            ELSE DO:
               ASSIGN aux_cdcritic = 9 /* Associado nao cadastrado. */
                      aux_dscritic = "".
            
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
            
               RETURN "NOK".
            END. 

        END. 
        
        ASSIGN ret_nmprimtl = crapass.nmprimtl
               aux_dtrefere = par_dtmvtoan.

        IF   CAN-DO("1",STRING(par_cdcooper)) THEN  /* CUIDAR COM A COOP */
             IF   par_dtmvtolt = 09/12/2008   THEN     
                  ASSIGN aux_dtrefere = 09/10/2008.                
             
            FOR EACH craphis NO-LOCK
                WHERE craphis.cdcooper = par_cdcooper
                  AND CAN-DO("50,59,153,313,340,358,524,572,21,521,1873,1874",
                              STRING(craphis.cdhistor)):


                FOR EACH craplcm WHERE craplcm.cdcooper  = par_cdcooper
                                   AND craplcm.nrdconta  = par_nrdconta
                                   AND craplcm.dtmvtolt >= aux_dtrefere
                                   AND craplcm.cdhistor = craphis.cdhistor                               
                                   AND (craplcm.dtrefere >= aux_dtrefere
                                   AND craplcm.dtrefere <= par_dtmvtolt) 
                                   USE-INDEX craplcm2 NO-LOCK:
                    
                    IF CAN-DO("21,521,1873,1874",STRING(craplcm.cdhistor)) AND 
                         craplcm.cdbccxlt <> 100 THEN
                      DO:
                        NEXT.
                      END.

                    IF  craplcm.nrdolote = 7009 OR
                        craplcm.nrdolote = 7010 THEN DO:
            
                        FIND FIRST craptco WHERE craptco.cdcooper = craplcm.cdcooper
                               AND craptco.nrdconta = craplcm.nrdconta
                               AND craptco.tpctatrf = 1               
                               AND craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.
                 
                        IF  AVAILABLE craptco THEN
                            
                            ASSIGN aux_nrdconta = craptco.nrctaant
                                   aux_cdcooper = craptco.cdcopant.       
                        ELSE
                            ASSIGN aux_nrdconta = craplcm.nrdctabb
                                   aux_cdcooper = par_cdcooper.
                    END.
                    ELSE
                        ASSIGN aux_nrdconta = craplcm.nrdctabb
                               aux_cdcooper = par_cdcooper.
            
                    /* Desprezar lancamentos do dia para Custodia e Desconto */
                    IF  craplcm.cdbccxlt = 100          AND
                        craplcm.dtrefere = par_dtmvtolt AND
                      ((craplcm.cdhistor = 21           AND
                        craplcm.nrdolote = 4500)        OR
                       (craplcm.cdhistor = 521          AND
                        craplcm.nrdolote = 4501)        OR
                       (craplcm.cdhistor = 1873         AND 
                        craplcm.nrdolote = 4501)        OR
                       (craplcm.cdhistor = 1874         AND
                        craplcm.nrdolote = 4501))       THEN
                        NEXT.
            
                    IF  craplcm.cdbccxlt  = 100          AND
                        craplcm.dtmvtolt <= par_dtmvtoan THEN DO:
                        
                        IF  ((craplcm.cdhistor = 21       AND
                              craplcm.nrdolote = 4500)    OR
                             (craplcm.cdhistor = 521      AND
                              craplcm.nrdolote = 4501)    OR
                             (craplcm.cdhistor = 1873     AND
                              craplcm.nrdolote = 4501)    OR
                             (craplcm.cdhistor = 1874     AND
                              craplcm.nrdolote = 4501))   THEN
                              .
                        ELSE     
                            NEXT.
                    END.
            
                    /*  Consulta o Cheque p/ verificar
                    se esta com indicador 5 COMPENSADO */
                    RUN sistema/generico/procedures/b1wgen9998.p
                        PERSISTENT SET h-b1wgen9998.
            
                    RUN dig_bbx IN h-b1wgen9998 (INPUT par_cdcooper,
                                                 INPUT 0, /*par_cdagenci,*/
                                                 INPUT 0, /*par_nrdcaixa,*/
                                                 INPUT par_nrdconta,
                                                 OUTPUT ret_dsdctitg,
                                                 OUTPUT TABLE tt-erro).
                    
                    IF  VALID-HANDLE(h-b1wgen9998)  THEN
                        DELETE PROCEDURE h-b1wgen9998.
                
                    IF  RETURN-VALUE <> "OK"   THEN DO:
                        ASSIGN aux_cdcritic = 8
                               aux_dscritic = "".
                  
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                
                        RETURN "NOK".
                    END.
            
                    /*  Tratamento para TCO - Contas Migradas */
                    FIND crabcop WHERE crabcop.cdcooper = aux_cdcooper 
                                       NO-LOCK NO-ERROR.
            
                    IF  NOT AVAILABLE crabcop THEN DO:
                        ASSIGN aux_cdcritic = 651
                               aux_dscritic = "".
                        
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        
                        RETURN "NOK".
                    END. 
                    
                    /* Cheque vindos da Compensacao */
                    IF  craplcm.cdbccxlt <> 100 THEN DO:
                        IF  craplcm.cdbccxlt = 756 THEN
                            ASSIGN aux_cdbanchq = 756
                                   aux_cdagechq = crabcop.cdagebcb.
                        ELSE
                        IF  craplcm.cdbccxlt = 85 THEN
                            ASSIGN aux_cdbanchq = 85
                                   aux_cdagechq = crabcop.cdagectl.
                        ELSE
                            ASSIGN aux_cdbanchq = 1
                                   aux_cdagechq = crabcop.cdageitg.
                    END.                           
                    ELSE DO: /*  Para Cheque vindos do Desconto
                             de Cheques e Custodia  */
                        ASSIGN aux_cdbanchq = craplcm.cdbanchq.
                             
                        IF  craplcm.cdbanchq = 756 THEN
                            ASSIGN aux_cdagechq = crabcop.cdagebcb.
                        ELSE
                        IF  craplcm.cdbanchq = 85 THEN
                            ASSIGN aux_cdagechq = crabcop.cdagectl.
                        ELSE
                            ASSIGN aux_cdagechq = crabcop.cdageitg.
                    END.
            
                    ASSIGN aux_cdcopfdc = 0.
        
                    FIND crapfdc WHERE crapfdc.cdcooper = aux_cdcooper                   
                                   AND crapfdc.cdbanchq = aux_cdbanchq                   
                                   AND crapfdc.cdagechq = aux_cdagechq
                                   AND crapfdc.nrctachq = aux_nrdconta                   
                                   AND crapfdc.nrcheque = 
                                       INT(SUBSTR(STRING(craplcm.nrdocmto
                                                        ,"99999999"),1,7))
                                       USE-INDEX crapfdc1 NO-LOCK NO-ERROR. 
                    
                    IF  NOT AVAIL crapfdc THEN DO:
                        /*  Tratamento para as contas migradas da 
                            Viacredi->AltoVale ou  Acredi->Viacredi 
                            Concredi->Viacredi e da Credimilsul->Scrcred
                            Transulcred -> Transpocred
                            */
                        IF  par_cdcooper = 16
                        OR  par_cdcooper = 1
                        OR  par_cdcooper = 13
                        OR  par_cdcooper = 9  THEN DO:

                            FIND FIRST craptco
							     WHERE craptco.cdcooper = craplcm.cdcooper
                                   AND craptco.nrdconta = craplcm.nrdconta
                                   AND craptco.tpctatrf = 1
                                   AND craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.

                            IF  AVAIL craptco THEN DO:

                                FIND crabcop WHERE crabcop.cdcooper = craptco.cdcopant
                                                   NO-LOCK NO-ERROR.

                                IF  NOT AVAILABLE crabcop THEN DO:
                                    ASSIGN aux_cdcritic = 651
                                           aux_dscritic = "".

                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT 0,
                                                   INPUT 0,
                                                   INPUT 1, /*sequencia*/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).

                                    RETURN "NOK".
                                END. 

                                ASSIGN aux_nrdconta = craptco.nrctaant
                                       aux_cdcooper = craptco.cdcopant.       

                                /*  Cheque vindos da Compensacao  */
                               
                                ASSIGN aux_cdbanchq = IF craplcm.cdbccxlt <> 100 
                                                      THEN craplcm.cdbccxlt
                                                      ELSE craplcm.cdbanchq.

                                IF  aux_cdbanchq = 756 THEN
                                    ASSIGN aux_cdagechq = crabcop.cdagebcb. 
                                ELSE
                                IF  aux_cdbanchq = 85 THEN
                                    ASSIGN aux_cdagechq = crabcop.cdagectl.
                                ELSE
                                    ASSIGN aux_cdagechq = crabcop.cdageitg.
        
                                /* Cheques incorporados - copiados para coop nova */ 
                                IF  craptco.cdcopant = 4
                                OR  craptco.cdcopant = 15
                                OR  craptco.cdcopant = 17 THEN
                                   ASSIGN aux_cdcopfdc = craptco.cdcooper.
                                ELSE
                                   /* Cheques migrados - permanecem na coop antiga */ 
                                   ASSIGN aux_cdcopfdc = craptco.cdcopant.

                                FIND crapfdc WHERE crapfdc.cdcooper = aux_cdcopfdc 
                                               AND crapfdc.cdbanchq = aux_cdbanchq     
                                               AND crapfdc.cdagechq = aux_cdagechq     
                                               AND crapfdc.nrctachq = craptco.nrctaant 
                                               AND crapfdc.nrcheque = 
                                                   INT(SUBSTR(STRING(craplcm.nrdocmto,
                                                   "99999999"),1,7))
                                                   USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                            END. /* FIM -> IF  AVAIL craptco */
                        END.
                    END. /* FIM -> IF  NOT AVAIL crapfdc */

                    IF  NOT AVAILABLE crabcop THEN DO:
                        ASSIGN aux_cdcritic = 244
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
            
                        RETURN "NOK".
                    END.
            
                    IF  crapfdc.incheque <> 5 AND
                        crapfdc.incheque <> 6 THEN
                        NEXT.
                    
                    CREATE tt-lancto.
            
                    CASE crapfdc.cdbanchq:
                     
                        WHEN   1  THEN tt-lancto.dsbccxlt = "B.BRASIL".
                        WHEN  85  THEN tt-lancto.dsbccxlt = "CECRED".
                        WHEN 756  THEN tt-lancto.dsbccxlt = "BANCOOB".
                        WHEN 104  THEN tt-lancto.dsbccxlt = "CEF".
                   
                    END CASE.
        
                    ASSIGN tt-lancto.cdcooper = IF   aux_cdcopfdc > 0 
                                                THEN aux_cdcopfdc
                                                ELSE aux_cdcooper
                           tt-lancto.nrdocmto = craplcm.nrdocmto   
                           tt-lancto.vllanmto = craplcm.vllanmto   
                           tt-lancto.nrdctitg = craplcm.nrdctitg   
                           tt-lancto.cdbanchq = crapfdc.cdbanchq   
                           tt-lancto.cdagechq = crapfdc.cdagechq
                           tt-lancto.nrctachq = crapfdc.nrctachq   
                           tt-lancto.banco    = aux_cdbanchq                           
                           tt-lancto.nrdrecid = RECID(craplcm)                        
                           tt-lancto.dstabela = "craplcm"
                           aux_regexist      = TRUE                    
                           aux_nrcalcul      = crapfdc.nrcheque * 10.
            
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                
                    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen9999.".
                  
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                
                        RETURN "NOK".
                    END.
                    
                    RUN dig_fun IN h-b1wgen9999(INPUT craplcm.cdcooper,
                                                INPUT 1,
                                                INPUT 0, /* par_nrdcaixa */
                                                INPUT-OUTPUT aux_nrcalcul,
                                                OUTPUT TABLE tt-erro).
                    
                    IF  VALID-HANDLE(h-b1wgen9999)  THEN
                        DELETE PROCEDURE h-b1wgen9999.
                
                    RUN verifica-aplicacoes (INPUT craplcm.cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT "DEVOLU",
                                             INPUT craplcm.nrdconta,
                                             INPUT par_dtmvtolt,
                                            OUTPUT aux_vlsldtot,
                                            OUTPUT aux_vlaplica,
                                            OUTPUT aux_vlsldprp,
                                            OUTPUT TABLE tt-erro).                    
                                            
                    IF  aux_vlsldtot > craplcm.vllanmto THEN
                        tt-lancto.dsaplica = "SIM".
                    ELSE 
                        tt-lancto.dsaplica = "NAO".                               
                                            
                    ASSIGN tt-lancto.vlaplica = aux_vlaplica
                           tt-lancto.vlsldprp = aux_vlsldprp.
                                            
                    FIND FIRST crapdev WHERE crapdev.cdcooper = (IF   aux_cdcopfdc > 0 
																	  THEN aux_cdcopfdc
																 ELSE aux_cdcooper)
                                         AND crapdev.cdbanchq = crapfdc.cdbanchq
                                         AND crapdev.cdagechq = crapfdc.cdagechq
                                         AND crapdev.nrctachq = crapfdc.nrctachq
                                         AND crapdev.nrcheque = aux_nrcalcul       
                                         AND crapdev.cdhistor <> 46
                                         NO-LOCK NO-ERROR.
                    
                    IF  AVAIL crapdev THEN DO:
                        CASE crapdev.insitdev:
            
                             WHEN 0 THEN tt-lancto.dssituac = "a devolver".
                             WHEN 1 THEN tt-lancto.dssituac = "devolvido".
                             OTHERWISE   tt-lancto.dssituac = "indefinida".
            
                        END CASE.
            
                        FIND crapope WHERE crapope.cdcooper = par_cdcooper       
                                       AND crapope.cdoperad = crapdev.cdoperad
                                       NO-LOCK NO-ERROR.
            
                        ASSIGN tt-lancto.cddsitua = crapdev.insitdev
                               tt-lancto.flag     = TRUE
                               tt-lancto.cdalinea = crapdev.cdalinea
                               tt-lancto.nmoperad = IF AVAIL crapope THEN
                                                       TRIM(STRING(crapope.nmoperad,"x(16)"))
                                                    ELSE
                                                       STRING(crapdev.cdoperad) +
                                                       " Nao cadastrado".
            
                    END.
                    ELSE DO:                    
                        ASSIGN tt-lancto.cddsitua = 0
                               tt-lancto.dssituac = "normal"
                               tt-lancto.flag     = FALSE.
                    END.
                    
                END. /* FOR EACH */
            END. /* FOR EACH CRAPHIS */                
            
            /* Buscar alineas 35 da conta */
            FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper                                   
                               AND crapdev.nrctachq = par_nrdconta
                               AND crapdev.cdalinea = 35
                               AND crapdev.cdhistor <> 46
                               NO-LOCK:
                 
                 /* Verificar se ja criou alinea 35 anteriormente na leitura da craplcm */
                 FIND FIRST tt-lancto WHERE tt-lancto.cdcooper = crapdev.cdcooper
                                        AND tt-lancto.nrctachq = crapdev.nrctachq
                                        AND tt-lancto.nrdocmto = crapdev.nrcheque
                                        AND tt-lancto.cdalinea = crapdev.cdalinea
                            NO-LOCK NO-ERROR NO-WAIT.                
                
                 IF  AVAILABLE tt-lancto THEN
                     NEXT.
               
                CREATE tt-lancto.
                ASSIGN tt-lancto.cdcooper = crapdev.cdcooper
                       tt-lancto.nrdocmto = crapdev.nrcheque   
                       tt-lancto.vllanmto = crapdev.vllanmto   
                       tt-lancto.nrdctitg = crapdev.nrdctitg   
                       tt-lancto.cdbanchq = crapdev.cdbanchq   
                       tt-lancto.cdagechq = crapdev.cdagechq
                       tt-lancto.nrctachq = crapdev.nrctachq   
                       tt-lancto.banco    = crapdev.cdbanchq    
                       tt-lancto.cddsitua = crapdev.insitdev
                       tt-lancto.flag     = TRUE
                       tt-lancto.cdalinea = crapdev.cdalinea
                       aux_regexist      = TRUE    
                       tt-lancto.nrdrecid = RECID(crapdev)
                       tt-lancto.dstabela = "crapdev".
                       
                CASE crapdev.cdbanchq:                     
                    WHEN   1  THEN tt-lancto.dsbccxlt = "B.BRASIL".
                    WHEN  85  THEN tt-lancto.dsbccxlt = "CECRED".
                    WHEN 756  THEN tt-lancto.dsbccxlt = "BANCOOB".
                    WHEN 104  THEN tt-lancto.dsbccxlt = "CEF".                   
                END CASE.       
                       
                CASE crapdev.insitdev:            
                    WHEN 0 THEN tt-lancto.dssituac = "a devolver".
                    WHEN 1 THEN tt-lancto.dssituac = "devolvido".
                    OTHERWISE   tt-lancto.dssituac = "indefinida".      
                END CASE.
                
                RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT "DEVOLU",
                                         INPUT crapdev.nrdctabb,
                                         INPUT par_dtmvtolt,
                                        OUTPUT aux_vlsldtot,
                                        OUTPUT aux_vlaplica,
                                        OUTPUT aux_vlsldprp,
                                        OUTPUT TABLE tt-erro).                    
                                        
                IF  aux_vlsldtot > crapdev.vllanmto THEN
                    ASSIGN tt-lancto.dsaplica = "SIM".
                ELSE 
                    ASSIGN tt-lancto.dsaplica = "NAO".                               
                                        
                ASSIGN tt-lancto.vlaplica = aux_vlaplica
                       tt-lancto.vlsldprp = aux_vlsldprp.
                       
                FIND crapope WHERE crapope.cdcooper = par_cdcooper       
                               AND crapope.cdoperad = crapdev.cdoperad
                               NO-LOCK NO-ERROR.
        
                ASSIGN tt-lancto.nmoperad = IF AVAIL crapope THEN
                                               TRIM(STRING(crapope.nmoperad,"x(16)"))
                                            ELSE
                                               STRING(crapdev.cdoperad) +
                                               " Nao cadastrado".
                
            END. /* Fim da leitura da crapdev */
            
    END.    
    ELSE DO:        
        
        IF  par_cdagenci > 0 THEN DO:
             
            ASSIGN ret_nmprimtl = "TODAS AS DEVOLUCOES".            

            IF  par_cdcooper = 16 THEN DO:

                FOR EACH crapdev WHERE (crapdev.cdcooper =  16
                                    AND  crapdev.cdhistor <> 46
                                    AND (crapdev.dtmvtolt = par_dtmvtolt
                                     OR  crapdev.cdoperad = "1"))
                                     OR (crapdev.cdcooper =  1
                                    AND  crapdev.cdpesqui = "TCO"
                                    AND  crapdev.cdhistor <> 46)  NO-LOCK,
                    EACH crapope WHERE  crapope.cdcooper = par_cdcooper
                                    AND  crapope.cdoperad = crapdev.cdoperad
                    NO-LOCK BY  crapdev.nrdconta.                
                    
                    FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper
                                         AND crapass.nrdconta = crapdev.nrdctabb
                                         AND crapass.cdagenci = par_cdagenci
                                         NO-LOCK NO-ERROR.
                                         
                    IF  NOT AVAILABLE crapass THEN
                        NEXT.    

                    RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT "DEVOLU",
                                             INPUT crapass.nrdconta,
                                             INPUT par_dtmvtolt,
                                            OUTPUT aux_vlsldtot,
                                            OUTPUT aux_vlaplica,
                                            OUTPUT aux_vlsldprp,
                                            OUTPUT TABLE tt-erro).             

                    ASSIGN par_qtregist = par_qtregist + 1.
            
                    /* controles da paginação */
                    IF  par_flgpagin  AND
                       (par_qtregist < par_nriniseq  OR
                        par_qtregist > (par_nriniseq + par_nrregist))  THEN
                        NEXT.

                    IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                    DO:

                        CREATE tt-devolu.
                
                        CASE crapdev.insitdev:
                            WHEN 0 THEN tt-devolu.dssituac = "a devolver".
                            WHEN 1 THEN tt-devolu.dssituac = "devolvido".
                            OTHERWISE   tt-devolu.dssituac = "indefinida".
                        END CASE.
                
                        ASSIGN tt-devolu.cdbccxlt = crapdev.cdbccxlt
                               tt-devolu.cdagechq = crapdev.cdagechq.

                               IF crapdev.nrdconta <> 0 THEN
                                   tt-devolu.nrdconta = crapdev.nrdconta.
                               ELSE 
                                   tt-devolu.nrdconta = crapdev.nrdctabb.

                        ASSIGN tt-devolu.nrcheque = crapdev.nrcheque
                               tt-devolu.vllanmto = crapdev.vllanmto
                               tt-devolu.cdalinea = crapdev.cdalinea
                               tt-devolu.insitdev = crapdev.insitdev
                               tt-devolu.nmoperad = crapope.nmoperad
                               tt-devolu.vlaplica = aux_vlaplica
                               tt-devolu.vlsldprp = aux_vlsldprp                               
                               aux_regexist = TRUE.
                               
                        IF  aux_vlsldtot > crapdev.vllanmto THEN
                            tt-devolu.dsaplica = "SIM".
                        ELSE 
                            tt-devolu.dsaplica = "NAO".                               
                    END.

                    IF  par_flgpagin  THEN
                        ASSIGN aux_nrregist = aux_nrregist - 1.

                END. /* for each */
            END.
            ELSE
            IF  par_cdcooper = 1 THEN DO:

                FOR EACH crapdev WHERE (crapdev.cdcooper =  1
                                   AND  crapdev.cdhistor <> 46
                                   AND (crapdev.dtmvtolt = par_dtmvtolt
                                    OR  crapdev.cdoperad = "1"))
                                    OR (crapdev.cdcooper =  2
                                   AND  crapdev.cdpesqui = "TCO"
                                   AND  crapdev.cdhistor <> 46)  NO-LOCK,
                    EACH crapope WHERE  crapope.cdcooper = par_cdcooper
                                   AND  crapope.cdoperad = crapdev.cdoperad
                    NO-LOCK BY  crapdev.nrdconta.
            
                    FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper
                                         AND crapass.nrdconta = crapdev.nrdctabb
                                         AND crapass.cdagenci = par_cdagenci
                                         NO-LOCK NO-ERROR.
                                         
                    IF  NOT AVAILABLE crapass THEN
                        NEXT.                
                        
                    RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT "DEVOLU",
                                             INPUT crapass.nrdconta,
                                             INPUT par_dtmvtolt,
                                            OUTPUT aux_vlsldtot,
                                            OUTPUT aux_vlaplica,
                                            OUTPUT aux_vlsldprp,
                                            OUTPUT TABLE tt-erro).                    
            
                    ASSIGN par_qtregist = par_qtregist + 1.
                    
                    /* controles da paginação */
                    IF  par_flgpagin  AND
                       (par_qtregist < par_nriniseq  OR
                        par_qtregist > (par_nriniseq + par_nrregist))  THEN
                        NEXT.                    

                    IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                    DO:

                        CREATE tt-devolu.
                
                        CASE crapdev.insitdev:
                            WHEN 0 THEN tt-devolu.dssituac = "a devolver".
                            WHEN 1 THEN tt-devolu.dssituac = "devolvido".
                            OTHERWISE   tt-devolu.dssituac = "indefinida".
                        END CASE.
                
                        ASSIGN tt-devolu.cdbccxlt = crapdev.cdbccxlt
                               tt-devolu.cdagechq = crapdev.cdagechq.
                               
                               IF crapdev.nrdconta <> 0 THEN
                                   tt-devolu.nrdconta = crapdev.nrdconta.
                               ELSE 
                                   tt-devolu.nrdconta = crapdev.nrdctabb.

                        

                        ASSIGN tt-devolu.nrcheque = crapdev.nrcheque
                               tt-devolu.vllanmto = crapdev.vllanmto
                               tt-devolu.cdalinea = crapdev.cdalinea
                               tt-devolu.insitdev = crapdev.insitdev
                               tt-devolu.nmoperad = crapope.nmoperad
                               tt-devolu.vlaplica = aux_vlaplica
                               tt-devolu.vlsldprp = aux_vlsldprp                               
                               aux_regexist = TRUE.
                               
                        IF  aux_vlsldtot > crapdev.vllanmto THEN
                            tt-devolu.dsaplica = "SIM".
                        ELSE 
                            tt-devolu.dsaplica = "NAO".                               
                               
                    END.

                    IF  par_flgpagin  THEN
                        ASSIGN aux_nrregist = aux_nrregist - 1.

                END. /* for each */
            END.
            ELSE DO:
                FOR EACH crapdev WHERE  crapdev.cdcooper =  par_cdcooper
                                   AND  crapdev.cdhistor <> 46
                                   AND (crapdev.dtmvtolt = par_dtmvtolt
                                   OR   crapdev.cdoperad = "1") 
                                   NO-LOCK,
                    EACH crapope WHERE  crapope.cdcooper = par_cdcooper
                                   AND  crapope.cdoperad = crapdev.cdoperad
                    NO-LOCK BY  crapdev.nrdconta.
             
					/*tratamento de incorporação*/
					FIND crapcop WHERE crapcop.cdcooper = crapdev.cdcooper
					               AND crapcop.cdagectl = crapdev.cdagechq
								   NO-LOCK NO-ERROR.

				    /*Se nao encontrou entao e de conta migrada*/
					IF NOT AVAILABLE crapcop THEN
					   DO:

							FIND crapcop WHERE crapcop.cdagectl = crapdev.cdagechq NO-LOCK NO-ERROR.

							IF AVAILABLE crapcop THEN
							DO:
								FIND craptco WHERE craptco.cdcopant = crapcop.cdcooper
								               AND craptco.nrctaant = crapdev.nrdctabb
											   NO-LOCK NO-ERROR.

                                IF AVAILABLE craptco THEN
								DO:

									FIND FIRST crapass WHERE crapass.cdcooper = craptco.cdcooper
														 AND crapass.nrdconta = craptco.nrdconta
														 AND crapass.cdagenci = par_cdagenci
														 NO-LOCK NO-ERROR.

								END.
								ELSE
								  NEXT.
							END.
							ELSE
							  NEXT.

					   END.
                    ELSE
					   DO:
                    FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper
                                         AND crapass.nrdconta = crapdev.nrdctabb
                                         AND crapass.cdagenci = par_cdagenci
                                         NO-LOCK NO-ERROR.
					   END.

                                         
                    IF  NOT AVAILABLE crapass THEN
                        NEXT.                
             
                    RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT "DEVOLU",
                                             INPUT crapass.nrdconta,
                                             INPUT par_dtmvtolt,
                                            OUTPUT aux_vlsldtot,
                                            OUTPUT aux_vlaplica,
                                            OUTPUT aux_vlsldprp,
                                            OUTPUT TABLE tt-erro).                         
            
                    ASSIGN par_qtregist = par_qtregist + 1.
            
                    /* controles da paginação */
                    IF  par_flgpagin  AND
                       (par_qtregist < par_nriniseq  OR
                        par_qtregist > (par_nriniseq + par_nrregist))  THEN
                        NEXT.

                    IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                    DO:

                        CREATE tt-devolu.
                 
                        CASE crapdev.insitdev:
                            WHEN 0 THEN tt-devolu.dssituac = "a devolver".
                            WHEN 1 THEN tt-devolu.dssituac = "devolvido".
                            OTHERWISE   tt-devolu.dssituac = "indefinida".
                        END CASE.
                 
                        ASSIGN tt-devolu.cdbccxlt = crapdev.cdbccxlt
                               tt-devolu.cdagechq = crapdev.cdagechq.
                               
                               IF crapdev.nrdconta <> 0 THEN
                                   tt-devolu.nrdconta = crapdev.nrdconta.
                               ELSE 
                                   tt-devolu.nrdconta = crapdev.nrdctabb.

                        ASSIGN tt-devolu.nrcheque = crapdev.nrcheque
                               tt-devolu.vllanmto = crapdev.vllanmto
                               tt-devolu.cdalinea = crapdev.cdalinea
                               tt-devolu.insitdev = crapdev.insitdev
                               tt-devolu.nmoperad = crapope.nmoperad
                               tt-devolu.vlaplica = aux_vlaplica
                               tt-devolu.vlsldprp = aux_vlsldprp                               
                               aux_regexist = TRUE.
                               
                        IF  aux_vlsldtot > crapdev.vllanmto THEN
                            tt-devolu.dsaplica = "SIM".
                        ELSE 
                            tt-devolu.dsaplica = "NAO".                               
                               
                    END.

                    IF  par_flgpagin  THEN
                        ASSIGN aux_nrregist = aux_nrregist - 1.

                END. /* for each */
            END. /* else */
         
        END. /* par_cdagenci > 0 */
        ELSE DO:
            
            ASSIGN ret_nmprimtl = "TODAS AS DEVOLUCOES".
            
            IF  par_cdcooper = 16 THEN DO:

                    FOR EACH crapdev WHERE (crapdev.cdcooper =  16
                                        AND  crapdev.cdhistor <> 46
                                        AND (crapdev.dtmvtolt = par_dtmvtolt
                                         OR  crapdev.cdoperad = "1"))
                                         OR (crapdev.cdcooper =  1
                                        AND  crapdev.cdpesqui = "TCO"
                                        AND  crapdev.cdhistor <> 46)  NO-LOCK,
                        EACH crapope WHERE  crapope.cdcooper = par_cdcooper
                                        AND  crapope.cdoperad = crapdev.cdoperad
                        NO-LOCK BY  crapdev.nrdconta.
                
                        RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT "DEVOLU",
                                                 INPUT crapdev.nrdctabb,
                                                 INPUT par_dtmvtolt,
                                                OUTPUT aux_vlsldtot,
                                                OUTPUT aux_vlaplica,
                                                OUTPUT aux_vlsldprp,
                                                OUTPUT TABLE tt-erro).       
                        
                        ASSIGN par_qtregist = par_qtregist + 1.
                
                        /* controles da paginação */
                        IF  par_flgpagin  AND
                           (par_qtregist < par_nriniseq  OR
                            par_qtregist > (par_nriniseq + par_nrregist))  THEN
                            NEXT.

                        IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                        DO:

                            CREATE tt-devolu.
                    
                            CASE crapdev.insitdev:
                                WHEN 0 THEN tt-devolu.dssituac = "a devolver".
                                WHEN 1 THEN tt-devolu.dssituac = "devolvido".
                                OTHERWISE   tt-devolu.dssituac = "indefinida".
                            END CASE.
                    
                            ASSIGN tt-devolu.cdbccxlt = crapdev.cdbccxlt
                                   tt-devolu.cdagechq = crapdev.cdagechq.

                                   IF crapdev.nrdconta <> 0 THEN
                                       tt-devolu.nrdconta = crapdev.nrdconta.
                                   ELSE 
                                       tt-devolu.nrdconta = crapdev.nrdctabb.

                            ASSIGN tt-devolu.nrcheque = crapdev.nrcheque
                                   tt-devolu.vllanmto = crapdev.vllanmto
                                   tt-devolu.cdalinea = crapdev.cdalinea
                                   tt-devolu.insitdev = crapdev.insitdev
                                   tt-devolu.nmoperad = crapope.nmoperad
                                   tt-devolu.vlaplica = aux_vlaplica
                                   tt-devolu.vlsldprp = aux_vlsldprp                               
                                   aux_regexist = TRUE.
                                   
                            IF  aux_vlsldtot > crapdev.vllanmto THEN
                                tt-devolu.dsaplica = "SIM".
                            ELSE 
                                tt-devolu.dsaplica = "NAO".   
                        END.

                        IF  par_flgpagin  THEN
                            ASSIGN aux_nrregist = aux_nrregist - 1.

                    END. /* for each */
                END.
                ELSE
                IF  par_cdcooper = 1 THEN DO:

                    FOR EACH crapdev WHERE (crapdev.cdcooper =  1
                                       AND  crapdev.cdhistor <> 46
                                       AND (crapdev.dtmvtolt = par_dtmvtolt
                                        OR  crapdev.cdoperad = "1"))
                                        OR (crapdev.cdcooper =  2
                                       AND  crapdev.cdpesqui = "TCO"
                                       AND  crapdev.cdhistor <> 46)  NO-LOCK,
                        EACH crapope WHERE  crapope.cdcooper = par_cdcooper
                                       AND  crapope.cdoperad = crapdev.cdoperad
                        NO-LOCK BY  crapdev.nrdconta.                
                        
                        ASSIGN par_qtregist = par_qtregist + 1.
                        
                        /* controles da paginação */
                        IF  par_flgpagin  AND
                           (par_qtregist < par_nriniseq  OR
                            par_qtregist > (par_nriniseq + par_nrregist))  THEN
                            NEXT.                           
                        
                        RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT "DEVOLU",
                                                 INPUT crapdev.nrdctabb,
                                                 INPUT par_dtmvtolt,
                                                OUTPUT aux_vlsldtot,
                                                OUTPUT aux_vlaplica,
                                                OUTPUT aux_vlsldprp,
                                                OUTPUT TABLE tt-erro).
                            
                        FIND crapfdc WHERE crapfdc.cdcooper = crapdev.cdcooper
                                       AND crapfdc.cdbanchq = crapdev.cdbanchq
                                       AND crapfdc.cdagechq = crapdev.cdagechq
                                       AND crapfdc.nrctachq = crapdev.nrctachq
                                       AND crapfdc.nrcheque = 
                                       INT(SUBSTR(STRING(crapdev.nrcheque
                                                        ,"99999999"),1,7))
                                       USE-INDEX crapfdc1 NO-LOCK NO-ERROR.                        

                        IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                        DO:

                            CREATE tt-devolu.
                    
                            CASE crapdev.insitdev:
                                WHEN 0 THEN tt-devolu.dssituac = "a devolver".
                                WHEN 1 THEN tt-devolu.dssituac = "devolvido".
                                OTHERWISE   tt-devolu.dssituac = "indefinida".
                            END CASE.
                    
                            ASSIGN tt-devolu.cdbccxlt = crapdev.cdbccxlt
                                   tt-devolu.cdagechq = crapdev.cdagechq.
                                   
                                   IF crapdev.nrdconta <> 0 THEN
                                       tt-devolu.nrdconta = crapdev.nrdconta.
                                   ELSE 
                                       tt-devolu.nrdconta = crapdev.nrdctabb.

                            ASSIGN tt-devolu.nrcheque = crapdev.nrcheque
                                   tt-devolu.vllanmto = crapdev.vllanmto
                                   tt-devolu.cdalinea = crapdev.cdalinea
                                   tt-devolu.insitdev = crapdev.insitdev
                                   tt-devolu.nmoperad = crapope.nmoperad
                                   tt-devolu.vlaplica = aux_vlaplica
                                   tt-devolu.vlsldprp = aux_vlsldprp
                                   tt-devolu.dtliquid = crapfdc.dtliqchq WHEN AVAILABLE crapfdc
                                   tt-devolu.nrctachq = crapfdc.nrctachq WHEN AVAILABLE crapfdc
                                   aux_regexist = TRUE.
                                   
                            IF  aux_vlsldtot > crapdev.vllanmto THEN
                                tt-devolu.dsaplica = "SIM".
                            ELSE 
                                tt-devolu.dsaplica = "NAO".             
                        END.

                        IF  par_flgpagin  THEN
                            ASSIGN aux_nrregist = aux_nrregist - 1.

                    END. /* for each */
                END.
                ELSE DO:
                    FOR EACH crapdev WHERE  crapdev.cdcooper =  par_cdcooper
                                       AND  crapdev.cdhistor <> 46
                                       AND (crapdev.dtmvtolt = par_dtmvtolt
                                       OR   crapdev.cdoperad = "1") NO-LOCK,
                        EACH crapope WHERE  crapope.cdcooper = par_cdcooper
                                       AND  crapope.cdoperad = crapdev.cdoperad
                        NO-LOCK BY  crapdev.nrdconta.
                 
                        ASSIGN par_qtregist = par_qtregist + 1.
                
                        /* controles da paginação */
                        IF  par_flgpagin  AND
                           (par_qtregist < par_nriniseq  OR
                            par_qtregist > (par_nriniseq + par_nrregist))  THEN
                            NEXT.
                        
                        RUN verifica-aplicacoes (INPUT crapdev.cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT "DEVOLU",
                                                 INPUT crapdev.nrdctabb,
                                                 INPUT par_dtmvtolt,
                                                OUTPUT aux_vlsldtot,
                                                OUTPUT aux_vlaplica,
                                                OUTPUT aux_vlsldprp,
                                                OUTPUT TABLE tt-erro).

                        IF  NOT par_flgpagin OR aux_nrregist > 0 THEN
                        DO:

                            CREATE tt-devolu.
                     
                            CASE crapdev.insitdev:
                                WHEN 0 THEN tt-devolu.dssituac = "a devolver".
                                WHEN 1 THEN tt-devolu.dssituac = "devolvido".
                                OTHERWISE   tt-devolu.dssituac = "indefinida".
                            END CASE.
                     
                            ASSIGN tt-devolu.cdbccxlt = crapdev.cdbccxlt
                                   tt-devolu.cdagechq = crapdev.cdagechq.
                                   
                                   IF crapdev.nrdconta <> 0 THEN
                                       tt-devolu.nrdconta = crapdev.nrdconta.
                                   ELSE 
                                       tt-devolu.nrdconta = crapdev.nrdctabb.

                            ASSIGN tt-devolu.nrcheque = crapdev.nrcheque
                                   tt-devolu.vllanmto = crapdev.vllanmto
                                   tt-devolu.cdalinea = crapdev.cdalinea
                                   tt-devolu.insitdev = crapdev.insitdev
                                   tt-devolu.nmoperad = crapope.nmoperad
                                   tt-devolu.vlaplica = aux_vlaplica
                                   tt-devolu.vlsldprp = aux_vlsldprp                               
                                   aux_regexist = TRUE.
                                   
                            IF  aux_vlsldtot > crapdev.vllanmto THEN
                                tt-devolu.dsaplica = "SIM".
                            ELSE 
                                tt-devolu.dsaplica = "NAO".   
                        END.

                        IF  par_flgpagin  THEN
                            ASSIGN aux_nrregist = aux_nrregist - 1.

                    END. /* for each */
                END. /* else */            
        END.
        
    END. /* else todas as devolucoes */    
   
    IF  NOT aux_regexist THEN DO:
    
        IF  par_cdagenci > 0 AND par_nrdconta = 0 THEN
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao ha devolucoes para o PA.".
        ELSE 
            ASSIGN aux_cdcritic = 81
                   aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-telefone-email:
    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta                 NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-telefones.
    DEF OUTPUT PARAM TABLE FOR tt-emails.
   
    EMPTY TEMP-TABLE tt-telefones.
    EMPTY TEMP-TABLE tt-emails.
   
    FOR EACH craptfc WHERE craptfc.cdcooper = par_cdcooper 
                       AND craptfc.nrdconta = par_nrdconta
                       AND craptfc.idsittfc = 1
                       NO-LOCK:       

        CREATE tt-telefones.
        ASSIGN tt-telefones.idseqttl = craptfc.idseqttl
               tt-telefones.nrdddtfc = craptfc.nrdddtfc
               tt-telefones.nrtelefo = craptfc.nrtelefo.                
    END.
        
    FOR EACH crapcem WHERE crapcem.cdcooper = par_cdcooper
                       AND crapcem.nrdconta = par_nrdconta
                       NO-LOCK:        
        
        CREATE tt-emails.
        ASSIGN tt-emails.idseqttl = crapcem.idseqttl
               tt-emails.dsdemail = crapcem.dsdemail.
    END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/


PROCEDURE verifica-folha-cheque:

    /* Procedimento inicial para devolução de cheques */

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdev.dtmvtolt                 NO-UNDO.
    DEF INPUT PARAM par_nrctachq LIKE crapass.nrdconta                 NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dsbccxlt AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctitg AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagechq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cddsitua AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdrecid AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_flag     AS LOGICAL                            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_valorvlb AS DECI                                       NO-UNDO.
    DEF VAR aux_vldevolu AS DECI                                       NO-UNDO.
    DEF VAR aux_dtrefere AS DATE                                       NO-UNDO.
    DEF VAR aux_ultlinha AS INTE                                       NO-UNDO.
    DEF VAR aux_flghrexe AS LOG                                        NO-UNDO.
    DEF VAR aux_regexist AS LOG                                        NO-UNDO.
    DEF VAR aux_nrcalcul AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.                                          

    /* Leitura da tabela com o valor definido para cheque VLB */ 
    RUN busca-valor-cheque(INPUT par_cdcooper,
                           INPUT "CRED"      , /* par_nmsistem */
                           INPUT "GENERI"    , /* par_tptabela */
                           INPUT 0           , /* par_cdempres */
                           INPUT "VALORESVLB", /* par_cdacesso */
                           INPUT 0           , /* par_tpregist */
                           OUTPUT aux_valorvlb,
                           OUTPUT aux_vldevolu,
                           OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN DO:
        ASSIGN aux_cdcritic = 55
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF  par_cddsitua = 1   THEN DO:  /* Devolvido */
        ASSIGN aux_cdcritic = 414
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    aux_nrcalcul = INT(SUBSTR(STRING(par_nrdocmto,"9999999"),1,6)).

    FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper
                   AND crapfdc.cdbanchq = par_cdbanchq
                   AND crapfdc.cdagechq = par_cdagechq
                   AND crapfdc.nrctachq = par_nrctachq
                   AND crapfdc.nrcheque = INT(aux_nrcalcul)
                   USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapfdc THEN DO:
        ASSIGN aux_cdcritic = 108
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF  crapfdc.cdbanchq = 756 THEN
        IF  CAN-FIND(crapsol WHERE crapsol.cdcooper = par_cdcooper
                               AND crapsol.dtrefere = par_dtmvtolt
                               AND crapsol.nrsolici = 78
                               AND crapsol.nrseqsol = 1) THEN DO:
            ASSIGN aux_cdcritic = 138
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF  crapfdc.cdbanchq = 1 THEN DO:
        IF  CAN-FIND(crapsol WHERE crapsol.cdcooper = par_cdcooper
                               AND crapsol.dtrefere = par_dtmvtolt
                               AND crapsol.nrsolici = 78
                               AND (crapsol.nrseqsol = 2 OR 
                                    crapsol.nrseqsol = 3)) THEN DO:
            ASSIGN aux_cdcritic = 138
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    END.

    IF  crapfdc.cdbanchq = crapcop.cdbcoctl THEN DO:
        IF  par_vllanmto >= aux_valorvlb THEN DO:
            IF  CAN-FIND(crapsol WHERE crapsol.cdcooper = par_cdcooper
                                   AND crapsol.dtrefere = par_dtmvtolt
                                   AND crapsol.nrsolici = 78
                                   AND crapsol.nrseqsol = 4) THEN DO:
                ASSIGN aux_cdcritic = 138
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.
        END.
        ELSE DO:
            IF  CAN-FIND(crapsol WHERE crapsol.cdcooper = par_cdcooper
                                   AND crapsol.dtrefere = par_dtmvtolt
                                   AND crapsol.nrsolici = 78
                                   AND crapsol.nrseqsol = 6) THEN DO:
                ASSIGN aux_cdcritic = 138
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.
        END.
    END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE verifica_alinea:

    /* Segunda etapa do procedimento de devolucao de cheques */

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt LIKE crapdev.dtmvtolt                 NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagechq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctachq LIKE crapass.nrdconta                 NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdalinea AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtrefere AS DATE                                       NO-UNDO.
    DEF VAR aux_nrdconta LIKE crapass.nrdconta                         NO-UNDO.
    DEF VAR aux_cdcooper LIKE crapcop.cdcooper                         NO-UNDO.
    DEF VAR aux_cddevolu AS INTE                                       NO-UNDO.
    DEF VAR aux_cdagechq AS INTE                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_ultlinha AS INTE                                       NO-UNDO.
    DEF VAR aux_flghrexe AS LOG                                        NO-UNDO.
    DEF VAR aux_regexist AS LOG                                        NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
     
    /* Valida alinea informada */
    IF  NOT CAN-FIND (crapali WHERE crapali.cdalinea = par_cdalinea) THEN DO:
        
        ASSIGN aux_cdcritic = 412 /* Alinea Invalida */
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.

    /* se for um formulario migrado, vamos buscar a coop antiga*/
    FOR EACH craptco WHERE craptco.cdcopant = par_cdcooper
                       AND craptco.nrctaant = par_nrctachq
                       AND craptco.tpctatrf = 1         
                       AND craptco.flgativo = TRUE 
                       NO-LOCK:
    
        ASSIGN aux_nrdconta = craptco.nrdconta.
    END.

    aux_nrcalcul = INT(SUBSTR(STRING(par_nrdocmto,"9999999"),1,6)).

    FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper
                   AND crapfdc.cdbanchq = par_cdbanchq
                   AND crapfdc.cdagechq = par_cdagechq
                   AND crapfdc.nrctachq = par_nrctachq
                   AND crapfdc.nrcheque = INT(aux_nrcalcul)
                   USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapfdc THEN DO:
        ASSIGN aux_cdcritic = 108
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
                         
    RUN valida-alinea (INPUT crapfdc.cdcooper,
                       INPUT crapfdc.nrdconta,
                       INPUT IF aux_nrdconta > 0 THEN 
                                aux_nrdconta 
                             ELSE crapfdc.nrdctabb,
                       INPUT par_nrdocmto,
                       INPUT par_cdalinea,
                       INPUT par_dtmvtolt,
                       INPUT crapfdc.cdtpdchq,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK"    THEN
        RETURN "NOK".

    ASSIGN aux_nrcalcul = crapfdc.nrcheque * 10.

    RUN sistema/generico/procedures/b1wgen9999.p
        PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para BO " +
                              "b1wgen9999.".
      
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.

    RUN dig_fun IN h-b1wgen9999(INPUT par_cdcooper,
                                INPUT 0, /* par_cdagenci */
                                INPUT 0, /* par_nrdcaixa */
                                INPUT-OUTPUT aux_nrcalcul,
                                OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen9999)  THEN
        DELETE PROCEDURE h-b1wgen9999.

    /* Limpar erros do calculo do digito do cheque */
    EMPTY TEMP-TABLE tt-erro.

    FIND crapcor WHERE crapcor.cdcooper = par_cdcooper  
                   AND crapcor.cdbanchq = par_cdbanchq    
                   AND crapcor.cdagechq = par_cdagechq    
                   AND crapcor.nrctachq = par_nrctachq    
                   AND crapcor.nrcheque = INT(aux_nrcalcul)   
                   AND crapcor.flgativo = TRUE
                   USE-INDEX crapcor1 NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcor THEN DO:
        IF  CAN-DO("20,21,28,70",STRING(par_cdalinea)) THEN DO:
            ASSIGN aux_cdcritic = 412
                   aux_dscritic = "".
                                     
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    END.
    ELSE DO:
        IF  CAN-DO("11,12,13,14,22,23,24,25,26,27,29,30,31,33,35,38,39,40,41,42,44,45,48,59,60,61,64",STRING(par_cdalinea)) THEN DO:
            ASSIGN aux_cdcritic = 412
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

        IF  par_cdalinea = 20         AND
            crapcor.cdhistor <> 818   THEN DO:
            ASSIGN aux_cdcritic = 412
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
        
        IF  par_cdalinea = 21         AND
            crapcor.cdhistor <> 815   THEN DO:
            ASSIGN aux_cdcritic = 412
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

        IF  par_cdalinea = 28 AND
            crapcor.cdhistor <> 835 THEN DO:
            ASSIGN aux_cdcritic = 412
                       aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

        IF  par_cdalinea = 70 THEN DO:
            IF  crapcor.dtvalcor < par_dtmvtolt OR
                crapcor.dtvalcor = ?            THEN DO:
                ASSIGN aux_cdcritic = 412
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
    
                RETURN "NOK".
            END.
        END.
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE valida-alinea:

    /* Antigo Fonte: valida-alinea.p adaptado para BO */

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctabb AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrcheque AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdalinea AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdtpdchq AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_lsalinea AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsoperad AS CHAR                                       NO-UNDO.
    DEF VAR aux_qtdevolu AS INTE                                       NO-UNDO.
    DEF VAR ret_execucao AS LOGICAL                                    NO-UNDO.
    
    DEF BUFFER b-crapneg FOR crapneg.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper
                   AND crapass.nrdconta = par_nrdconta
                   NO-LOCK NO-ERROR.

    ASSIGN aux_lsalinea = "".
    
    FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper  
                       AND crapneg.nrdconta = par_nrdconta  
                       AND crapneg.cdhisest = 1             
                       AND crapneg.nrdocmto = par_nrcheque  
                       AND crapneg.nrdctabb = par_nrdctabb
                       NO-LOCK USE-INDEX crapneg1: 
        IF  aux_lsalinea = "" THEN
            aux_lsalinea = STRING(crapneg.cdobserv).
        ELSE     
            aux_lsalinea = aux_lsalinea + "," + STRING(crapneg.cdobserv).

    END. /*  Fim do FOR EACH -- crapneg  */

    /*  Tratamento para migracao AltoVale  */
    IF  par_cdcooper = 1 OR 
        par_cdcooper = 16 THEN DO:

        IF  aux_lsalinea = "" THEN DO:

            FIND craptco WHERE craptco.cdcooper = par_cdcooper
                           AND craptco.nrdconta = par_nrdconta
                           AND craptco.tpctatrf = 1
                           AND craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

            IF  AVAIL craptco THEN DO:
                FOR EACH crapneg WHERE crapneg.cdcooper = craptco.cdcopant  
                                   AND crapneg.nrdconta = craptco.nrctaant  
                                   AND crapneg.cdhisest = 1                    
                                   AND crapneg.nrdocmto = par_nrcheque         
                                   AND crapneg.nrdctabb = par_nrdctabb
                                   NO-LOCK USE-INDEX crapneg1: 
                                      
                    IF  aux_lsalinea = "" THEN
                        aux_lsalinea = STRING(crapneg.cdobserv).
                    ELSE     
                        aux_lsalinea = aux_lsalinea + ","
                                     + STRING(crapneg.cdobserv).

                END. /*  Fim do FOR EACH -- crapneg  */
            END.
        END.
    END.

    IF  par_cdalinea = 11 THEN DO:
		IF NOT CAN-DO(aux_lsalinea,"")   AND
		   NOT CAN-DO(aux_lsalinea,"31") AND
		   NOT CAN-DO(aux_lsalinea,"39") AND
		   NOT CAN-DO(aux_lsalinea,"48") AND
		   NOT CAN-DO(aux_lsalinea,"70") THEN 
		   DO:
            
            IF  par_cdcooper = 1       AND
                par_nrdconta = 6757987 AND
                par_nrcheque = 27      THEN
                .
            ELSE
            DO:
                RUN valida_saldo_devolu(INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT 1,
                                        INPUT par_nrcheque,
                                        INPUT par_nrdctabb,
                                        OUTPUT TABLE tt-erro).
                
                IF RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
               
        END.
        ELSE 
		DO: 
            IF  CAN-DO(aux_lsalinea,"11") THEN 
			    DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Cheque ja devolvido pela alinea 11.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT        aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".

            END.
        END.
    END.
    ELSE
        IF  par_cdalinea = 26   OR
            par_cdalinea = 27   OR
            par_cdalinea = 29   OR               
            par_cdalinea = 37   OR     
            par_cdalinea = 38   OR
            par_cdalinea = 40   OR
            par_cdalinea = 41   OR
            par_cdalinea = 42   OR            
            par_cdalinea = 59   OR            
            par_cdalinea = 60   OR            
            par_cdalinea = 61   OR            
            par_cdalinea = 64   OR            
            par_cdalinea = 72   OR
            par_cdalinea = 71   OR
            par_cdalinea = 100  THEN
            .
    ELSE
    IF  par_cdalinea = 12   THEN DO:   
        IF  NOT CAN-DO(aux_lsalinea,"11") THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Deve-se utilizar a alinea 11 para a devolucao.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        ELSE
        IF  CAN-DO(aux_lsalinea,"12")   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
    END.         
    ELSE
    IF  par_cdalinea = 13   THEN DO: 
        IF  crapass.cdsitdct = 1   THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta NAO encerrada - alinea 13 nao permitida.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
        ELSE 
        IF  CAN-DO(aux_lsalinea,"13")   THEN DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    END.
    ELSE
    IF  par_cdalinea = 14   THEN
        DO:  
            IF  CAN-DO(aux_lsalinea,"14")   THEN
                DO: 
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
              
            FOR EACH b-crapneg WHERE b-crapneg.cdcooper = par_cdcooper  AND
                                     b-crapneg.nrdconta = par_nrdconta  AND
                                     b-crapneg.cdhisest = 1             AND
                                     b-crapneg.nrdocmto = par_nrcheque  AND
                                     b-crapneg.nrdctabb = par_nrdctabb  AND
                                     b-crapneg.dtiniest = par_dtmvtolt 
                               NO-LOCK USE-INDEX crapneg1: 
             
                ASSIGN aux_qtdevolu = aux_qtdevolu + 1.

            END.   /*  Fim do FOR EACH -- crapneg  */
           
            IF aux_qtdevolu <= 3 THEN
                DO:
                    ASSIGN aux_cdcritic = 412
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 20   THEN 
        DO:
            IF  CAN-DO(aux_lsalinea,"20")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF   par_cdalinea = 21   THEN
         DO:
             IF  CAN-DO(aux_lsalinea,"21")   THEN
                 DO:
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT 1, /*sequencia*/
                                    INPUT aux_cdcritic,
                                    INPUT-OUTPUT aux_dscritic).
                     RETURN "NOK".
                 END.
         END.
    ELSE
    IF  par_cdalinea = 22  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"22")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 23  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"23")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
            END.
    ELSE
    IF  par_cdalinea = 24  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"24")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 25  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"25")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 28   THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"28")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 30  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"30")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 31  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"31")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 32   THEN DO:
        ASSIGN aux_cdcritic = 412
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        RETURN "NOK".
    END.
    ELSE
    IF  par_cdalinea = 33  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"33")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF   par_cdalinea = 34  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"34")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 43 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 35  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"35")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 39  THEN
        DO:
            IF  par_cdtpdchq = 433 OR
                par_cdtpdchq = 439 OR
                par_cdtpdchq = 90  OR
                par_cdtpdchq = 94  OR
                par_cdtpdchq = 95  THEN
            DO:
                ASSIGN aux_cdcritic = 412
                       aux_dscritic = "".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
        END.
    ELSE
    IF  par_cdalinea = 43  THEN
        DO: 
            IF  NOT CAN-DO(aux_lsalinea,"21")   AND 
                NOT CAN-DO(aux_lsalinea,"22")   AND 
                NOT CAN-DO(aux_lsalinea,"23")   AND 
                NOT CAN-DO(aux_lsalinea,"24")   AND 
                NOT CAN-DO(aux_lsalinea,"31")   AND 
                NOT CAN-DO(aux_lsalinea,"33")   AND 
                NOT CAN-DO(aux_lsalinea,"34")   THEN
                DO: 
                    ASSIGN aux_cdcritic = 412
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
            ELSE
            IF  CAN-DO(aux_lsalinea,"43")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 44  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"44")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 45  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"45")   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Deve-se utilizar a alinea 49 para a devolucao.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE
    IF  par_cdalinea = 48   THEN DO:
        /* ver cadastramento de contra-ordens */
    END.
    ELSE
    IF  par_cdalinea = 49   THEN DO:
        /******** Magui 22/06/2001 **/
        IF  NOT CAN-DO(aux_lsalinea,"12") AND
            NOT CAN-DO(aux_lsalinea,"13") AND
            NOT CAN-DO(aux_lsalinea,"14") AND
            NOT CAN-DO(aux_lsalinea,"20") AND
            NOT CAN-DO(aux_lsalinea,"25") AND
            NOT CAN-DO(aux_lsalinea,"28") AND
            NOT CAN-DO(aux_lsalinea,"30") AND
            NOT CAN-DO(aux_lsalinea,"35") AND
            NOT CAN-DO(aux_lsalinea,"43") AND
            NOT CAN-DO(aux_lsalinea,"44") AND 
            NOT CAN-DO(aux_lsalinea,"45") THEN DO:
            ASSIGN aux_cdcritic = 412
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.

        IF  CAN-DO(aux_lsalinea,"21") THEN DO:
            ASSIGN aux_cdcritic = 412
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
    END.
    ELSE
    IF  par_cdalinea = 70  THEN
        DO:
            IF  CAN-DO(aux_lsalinea,"12")   OR 
                CAN-DO(aux_lsalinea,"20")   OR
                CAN-DO(aux_lsalinea,"28")   OR
                CAN-DO(aux_lsalinea,"21")   OR
                CAN-DO(aux_lsalinea,"43")   OR
                CAN-DO(aux_lsalinea,"49")  THEN
                DO:
                    ASSIGN aux_cdcritic = 412
                           aux_dscritic = "".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    ELSE DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Alinea NAO tratada: "
                              + STRING(par_cdalinea).

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.
    
    /* Permitir somente alineas de Fraude e Impedimentos apos
      primeira devolucao */
    RUN verifica_hora_execucao(INPUT par_cdcooper,
                               INPUT par_dtmvtolt,
                               INPUT 4, /* Fim da primeira execucao */
                               OUTPUT ret_execucao,
                               OUTPUT TABLE tt-erro).
                               
    /*Excedeu limite de horario primeira devolucao*/
    IF ret_execucao AND
       NOT CAN-DO("20,21,24,25,28,30,35,70",STRING(par_cdalinea)) THEN
       DO:
	       FIND crapdat WHERE crapdat.cdcooper = par_cdcooper 
                NO-LOCK NO-ERROR.
                           
           /* Sistema so deve criticar horario quando for 
		      cheque recebido via COMPE. Devolucao de cheque
			  trocado no caixa devera permitir */
		   IF  CAN-FIND(craplcm WHERE 
                        craplcm.cdcooper = par_cdcooper      AND
                        craplcm.nrdconta = par_nrdconta      AND
                        craplcm.dtmvtolt = crapdat.dtmvtoan  AND  
                        craplcm.cdhistor = 524               AND
                        craplcm.nrdocmto = par_nrcheque)
                OR
               CAN-FIND(craplcm WHERE                       
                        craplcm.cdcooper = par_cdcooper      AND
                        craplcm.nrdconta = par_nrdconta      AND
                        craplcm.dtmvtolt = crapdat.dtmvtolt  AND
                        craplcm.cdhistor = 1873              AND
                        craplcm.nrdocmto = par_nrcheque)  
                     THEN
               DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Hora limite para marcar " + 
                                         "cheques foi ultrapassada!".
           
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT 0,
                                  INPUT 0,
                                  INPUT 1, /*sequencia*/
                                  INPUT aux_cdcritic,   
                                  INPUT-OUTPUT aux_dscritic).
                   RETURN "NOK".
               END.
           ELSE              
                .
       END.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valida-alinea-automatica:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctabb AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrcheque AS INT                                NO-UNDO.
    DEF INPUT PARAM par_dtvalcor AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM par_cdaliaut AS INTE                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_lsalinea AS CHAR                                       NO-UNDO.
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    ASSIGN aux_lsalinea = "".
                       
    FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper AND 
                           crapneg.nrdconta = par_nrdconta AND 
                           crapneg.cdhisest = 1            AND 
                           crapneg.nrdocmto = par_nrcheque AND 
                           crapneg.nrdctabb = par_nrdctabb  
                           NO-LOCK USE-INDEX crapneg1: 
                    
        IF aux_lsalinea = "" THEN
           ASSIGN aux_lsalinea = STRING(crapneg.cdobserv).
        ELSE     
           ASSIGN aux_lsalinea = aux_lsalinea + "," + STRING(crapneg.cdobserv).
                      
    END. /*  Fim do FOR EACH -- crapneg  */
                         
    /*  Tratamento para migracao AltoVale  */
    IF  par_cdcooper = 1 OR 
        par_cdcooper = 16 THEN DO:

        IF  aux_lsalinea = "" THEN DO:

            FIND craptco WHERE craptco.cdcooper = par_cdcooper AND
                               craptco.nrdconta = par_nrdconta AND
                               craptco.tpctatrf = 1            AND
                               craptco.flgativo = TRUE   
                               NO-LOCK NO-ERROR.

            IF AVAIL craptco THEN DO:
               FOR EACH crapneg WHERE crapneg.cdcooper = craptco.cdcopant  
                                  AND crapneg.nrdconta = craptco.nrctaant  
                                  AND crapneg.cdhisest = 1                    
                                  AND crapneg.nrdocmto = par_nrcheque         
                                  AND crapneg.nrdctabb = par_nrdctabb
                                  NO-LOCK USE-INDEX crapneg1: 
                                     
                   IF  aux_lsalinea = "" THEN
                       ASSIGN aux_lsalinea = STRING(crapneg.cdobserv).
                   ELSE     
                       ASSIGN aux_lsalinea = aux_lsalinea + ","
                                             + STRING(crapneg.cdobserv).

               END. /*  Fim do FOR EACH -- crapneg  */
            END.
        END.
    END.
    
    IF par_dtvalcor >= par_dtmvtolt  AND
       par_dtvalcor <> ?             THEN
       DO:
          IF NOT CAN-DO(aux_lsalinea,"70") THEN
             ASSIGN par_cdaliaut = 70.
          ELSE
             ASSIGN aux_cdcritic = 412.
       END.
    ELSE
       DO:
          IF par_cdhistor = 835 THEN
             DO:
                IF CAN-DO(aux_lsalinea,"28") THEN
                   ASSIGN par_cdaliaut = 49.
                ELSE
                   ASSIGN par_cdaliaut = 28.
             END.
          ELSE
          IF par_cdhistor = 818 THEN
             DO:
                IF CAN-DO(aux_lsalinea,"20") THEN
                   ASSIGN par_cdaliaut = 49.
                ELSE
                   ASSIGN par_cdaliaut = 20.
             END.
          ELSE
          IF par_cdhistor = 815 THEN
             DO:
                IF CAN-DO(aux_lsalinea,"21") THEN
                   ASSIGN par_cdaliaut = 43.
                ELSE
                   ASSIGN par_cdaliaut = 21.
             END.
          ELSE
             ASSIGN aux_cdcritic = 412.
          
       END.
    
   IF aux_cdcritic <> 0 THEN
      DO:
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".

      END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE valida_saldo_devolu:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdhisest AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrcheque AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctabb AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = "".

    FIND FIRST crapneg WHERE crapneg.cdcooper = par_cdcooper
                         AND crapneg.nrdconta = par_nrdconta
                         AND crapneg.cdhisest = par_cdhisest /* 1 */
                         AND crapneg.nrdocmto = par_nrcheque
                         AND crapneg.nrdctabb = par_nrdctabb
                         NO-LOCK USE-INDEX crapneg1 NO-ERROR.

    IF AVAIL crapneg THEN
    DO:
        ASSIGN aux_dscritic = "** Cheque devolvido em " +
                              STRING(crapneg.dtiniest,"99/99/9999") + " pela alinea "
                            + TRIM(STRING(crapneg.cdobserv,"z99")) + ".".
    
        IF  TRIM(crapneg.cdoperad) <> ""   THEN 
        DO:
            FIND crapope WHERE crapope.cdcooper = par_cdcooper
                           AND crapope.cdoperad = crapneg.cdoperad
                           NO-LOCK NO-ERROR.
            IF AVAIL crapope THEN
                ASSIGN aux_dscritic = aux_dscritic + "** Por " + TRIM(CAPS(crapope.nmoperad)) + ".".
        END.
    END.

    IF aux_dscritic <> "" THEN
    DO:
        ASSIGN aux_cdcritic = 0.
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE geracao-devolu:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdrecid AS RECID                              NO-UNDO.
    DEF INPUT PARAM par_inchqdev AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctitg AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_cdalinea AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdagechq LIKE crapfdc.cdagechq                 NO-UNDO.
    DEF INPUT PARAM par_nrctachq LIKE crapfdc.nrctachq                 NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela LIKE craptel.nmdatela                 NO-UNDO.
    DEF INPUT PARAM par_flag     AS LOGICAL                            NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-desmarcar.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dssituac AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdalinea AS INTE                                       NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR FORMAT "x(20)"                        NO-UNDO.
    DEF VAR aux_nrdrecid AS RECID                                      NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dssituac = "".

    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapope THEN
        ASSIGN aux_nmoperad = "OPE. NAO ENCONTRADO".
    ELSE
        ASSIGN aux_nmoperad = STRING(crapope.nmoperad,"x(20)").

    FIND FIRST tt-desmarcar NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-desmarcar THEN
        DO:
            IF  par_cdalinea = 0 THEN /* Validar alinea zerada na marcacao do cheque */
                DO:
                    ASSIGN aux_dscritic = "Erro ao marcar cheque. Tente novamente!".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    RETURN "NOK".
                END.
        
            DO  TRANSACTION:  /* transacao para devolver */        

                IF  par_flag THEN DO: /* a devolver */
                    
                    ASSIGN aux_dssituac = "normal"
                           par_flag     = FALSE
                           aux_cdalinea = 0
                           aux_nmoperad = "".

                    RUN gera-devolu (INPUT  par_cdcooper,
                                     INPUT  par_dtmvtolt,
                                     INPUT  par_cdbccxlt,
                                     INPUT  par_nrdrecid,
                                     INPUT  5 /* indevchq */,
                                     INPUT  par_nrdctitg,
                                     INPUT  par_vllanmto,
                                     INPUT  par_cdalinea,
                                     INPUT  47,  /* cdhistor */
                                     INPUT  par_cdoperad,
                                     INPUT  par_cdagechq,
                                     INPUT  par_nrctachq,
                                     INPUT  par_nrdconta,
                                     INPUT  par_nrdocmto,
                                     INPUT  "devolu", /* nmdatela */
                                     OUTPUT TABLE tt-erro).
                   
                    IF  RETURN-VALUE <> "OK"   THEN
                        RETURN "NOK".
                    
                END.
                ELSE DO:

                    ASSIGN par_flag     = TRUE
                           aux_dssituac = "a devolver" 
                           aux_nrdrecid = par_nrdrecid.

                    RUN gera-devolu (INPUT  par_cdcooper,
                                     INPUT  par_dtmvtolt,
                                     INPUT  par_cdbccxlt,
                                     INPUT  par_nrdrecid,
                                     INPUT  1 /* indevchq */,
                                     INPUT  par_nrdctitg,
                                     INPUT  par_vllanmto,
                                     INPUT  par_cdalinea,
                                     INPUT  47,  /* cdhistor */
                                     INPUT  par_cdoperad,
                                     INPUT  par_cdagechq,
                                     INPUT  par_nrctachq,
                                     INPUT  par_nrdconta,
                                     INPUT  par_nrdocmto,
                                     INPUT  "devolu", /* nmdatela */
                                     OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                END.

            END. /* Transaction */    
        END. /* Desmarcar */
    ELSE 
        DO:
            /* transacao para devolver */        
            DESMARCAR:
            FOR EACH tt-desmarcar NO-LOCK:

                IF  tt-desmarcar.flag THEN DO: /* a devolver */
                    
                    ASSIGN aux_dssituac = "normal"
                           par_flag     = FALSE
                           aux_cdalinea = 0
                           aux_nmoperad = "".

                    RUN gera-devolu (INPUT  par_cdcooper,
                                     INPUT  par_dtmvtolt,
                                     INPUT  tt-desmarcar.cdbanchq,
                                     INPUT  tt-desmarcar.nrdrecid,
                                     INPUT  5 /* indevchq */,
                                     INPUT  tt-desmarcar.nrdctitg,
                                     INPUT  tt-desmarcar.vllanmto,
                                     INPUT  tt-desmarcar.cdalinea,
                                     INPUT  47,  /* cdhistor */
                                     INPUT  par_cdoperad,
                                     INPUT  tt-desmarcar.cdagechq,
                                     INPUT  tt-desmarcar.nrctachq,
                                     INPUT  tt-desmarcar.nrdconta,
                                     INPUT  tt-desmarcar.nrcheque,
                                     INPUT  "devolu", /* nmdatela */
                                     OUTPUT TABLE tt-erro).
                   
                    IF  RETURN-VALUE <> "OK"   THEN
                        NEXT DESMARCAR.
                    
                END.
                ELSE DO:

                    ASSIGN par_flag     = TRUE
                           aux_dssituac = "a devolver" 
                           aux_nrdrecid = par_nrdrecid.

                    RUN gera-devolu (INPUT  par_cdcooper,
                                     INPUT  par_dtmvtolt,
                                     INPUT  tt-desmarcar.cdbanchq,
                                     INPUT  tt-desmarcar.nrdrecid,
                                     INPUT  1 /* indevchq */,
                                     INPUT  tt-desmarcar.nrdctitg,
                                     INPUT  tt-desmarcar.vllanmto,
                                     INPUT  tt-desmarcar.cdalinea,
                                     INPUT  47,  /* cdhistor */
                                     INPUT  par_cdoperad,
                                     INPUT  tt-desmarcar.cdagechq,
                                     INPUT  tt-desmarcar.nrctachq,
                                     INPUT  tt-desmarcar.nrdconta,
                                     INPUT  tt-desmarcar.nrcheque,
                                     INPUT  "devolu", /* nmdatela */
                                     OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT DESMARCAR.
                END.
            END.
        END.
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera-devolu:

    /* Terceira etapa do procedimento de devolucao de cheques */

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdrecid AS RECID                              NO-UNDO.
    DEF INPUT PARAM par_inchqdev AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdctitg AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_cdalinea AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdagechq LIKE crapfdc.cdagechq                 NO-UNDO.
    DEF INPUT PARAM par_nrctachq LIKE crapfdc.nrctachq                 NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela LIKE craptel.nmdatela                 NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF BUFFER crabdev FOR crapdev.

    DEF VAR aux_valorvlb AS DECI                                       NO-UNDO.
    DEF VAR aux_vldevolu AS DECI                                       NO-UNDO.
    DEF VAR ind_dtmvtolt AS DATE    FORMAT "99/99/9999"                NO-UNDO.
    DEF VAR ind_cdagenci AS INTE    FORMAT "999"                       NO-UNDO.
    DEF VAR ind_cdbccxlt AS INTE    FORMAT "999"                       NO-UNDO.
    DEF VAR ind_nrdolote AS INTE    FORMAT "999999"                    NO-UNDO.
    DEF VAR ind_nrseqdig AS INTE    FORMAT "99999"                     NO-UNDO.
    DEF VAR aux_cdpesqui AS CHAR                                       NO-UNDO.
    DEF VAR aux_vldasoma AS DECI                                       NO-UNDO.
    DEF VAR ind_nrdctitg AS INTE                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_conteudo AS CHAR                                       NO-UNDO.
    
    /*  Busca dados da cooperativa  */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop THEN DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    /* Leitura da tabela com o valor definido para cheque VLB */ 
    RUN busca-valor-cheque(INPUT par_cdcooper,
                           INPUT "CRED"      , /* par_nmsistem */
                           INPUT "GENERI"    , /* par_tptabela */
                           INPUT 0           , /* par_cdempres */
                           INPUT "VALORESVLB", /* par_cdacesso */
                           INPUT 0           , /* par_tpregist */
                           OUTPUT aux_valorvlb,
                           OUTPUT aux_vldevolu,
                           OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN DO:
        ASSIGN aux_cdcritic = 55
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    ASSIGN ind_nrdctitg = 0
           aux_cdpesqui = ""
           aux_cdbanchq = IF  par_cdbccxlt = 756 THEN
                              756
                          ELSE
                          IF  par_cdbccxlt = crapcop.cdbcoctl THEN
                              crapcop.cdbcoctl
                          ELSE 1.

    IF  par_nrdrecid > 0  THEN DO:
        DO  WHILE TRUE:
            FIND craplcm WHERE RECID(craplcm) = par_nrdrecid
                               NO-LOCK NO-ERROR.
    
            IF  NOT AVAIL craplcm   THEN
                LEAVE.
         
            /*  Cheque custodia/desconto   */
            IF  craplcm.cdagenci = 1      AND
                craplcm.cdbccxlt = 100    AND
               (craplcm.nrdolote = 4500   OR
                craplcm.nrdolote = 4501)  THEN DO:
                 
                aux_cdpesqui = craplcm.cdpesqbb.
                      
                ASSIGN ind_dtmvtolt = 
                                    DATE(INT(SUBSTRING(craplcm.cdpesqbb,04,02)),
                                    INT(SUBSTRING(craplcm.cdpesqbb,01,02)),
                                    INT(SUBSTRING(craplcm.cdpesqbb,07,04)))
                                   
                       ind_cdagenci = INT(SUBSTRING(craplcm.cdpesqbb,12,03))
                       ind_cdbccxlt = INT(SUBSTRING(craplcm.cdpesqbb,16,03))
                       ind_nrdolote = INT(SUBSTRING(craplcm.cdpesqbb,20,06))
                       ind_nrseqdig = INT(SUBSTRING(craplcm.cdpesqbb,27,05))
                       aux_vldasoma = 0.
                   
                FIND craplot WHERE craplot.cdcooper = par_cdcooper       
                               AND craplot.dtmvtolt = ind_dtmvtolt  
                               AND craplot.cdagenci = ind_cdagenci  
                               AND craplot.cdbccxlt = ind_cdbccxlt  
                               AND craplot.nrdolote = ind_nrdolote
                               NO-LOCK NO-ERROR.
                                         
                IF  AVAIL craplot   THEN
                    IF  craplcm.nrdolote = 4500   THEN DO: /*  Custodia */
                        FOR EACH crapcst
                                 WHERE crapcst.cdcooper = par_cdcooper
                                   AND crapcst.dtmvtolt = craplot.dtmvtolt
                                   AND crapcst.cdagenci = craplot.cdagenci
                                   AND crapcst.cdbccxlt = craplot.cdbccxlt
                                   AND crapcst.nrdolote = craplot.nrdolote
                                   NO-LOCK USE-INDEX crapcst1:
                                            
                            IF  crapcst.inchqcop <> 1   THEN
                                NEXT.
                                            
                            ASSIGN aux_vldasoma = aux_vldasoma
                                                + crapcst.vlcheque.
    
                        END.  /*  Fim do FOR EACH - crapcst.   */
                                   
                        ASSIGN aux_cdpesqui = aux_cdpesqui
                                            + " SOMA = "
                                            + TRIM(STRING(aux_vldasoma,
                                                         "zzz,zzz,zz9.99")).
                    END.
                    ELSE
                    IF  craplcm.nrdolote = 4501 THEN DO: /*  Desconto */
                        FIND crapcdb WHERE crapcdb.cdcooper = par_cdcooper
                                       AND crapcdb.dtmvtolt = ind_dtmvtolt
                                       AND crapcdb.cdagenci = ind_cdagenci
                                       AND crapcdb.cdbccxlt = ind_cdbccxlt
                                       AND crapcdb.nrdolote = ind_nrdolote
                                       AND crapcdb.nrseqdig = ind_nrseqdig
                                       USE-INDEX crapcdb4 NO-LOCK NO-ERROR.
                        
                        FIND crapcst WHERE crapcst.cdcooper = par_cdcooper       
                                       AND crapcst.cdcmpchq = crapcdb.cdcmpchq   
                                       AND crapcst.cdbanchq = crapcdb.cdbanchq   
                                       AND crapcst.cdagechq = crapcdb.cdagechq   
                                       AND crapcst.nrctachq = crapcdb.nrctachq   
                                       AND crapcst.nrcheque = crapcdb.nrcheque   
                                       AND crapcst.dtdevolu = crapcdb.dtmvtolt
                                       NO-LOCK NO-ERROR.
                                        
                        IF  NOT AVAIL crapcst THEN
                            FOR EACH crapcdb 
                                     WHERE crapcdb.cdcooper = par_cdcooper     
                                       AND crapcdb.dtmvtolt = craplot.dtmvtolt 
                                       AND crapcdb.cdagenci = craplot.cdagenci 
                                       AND crapcdb.cdbccxlt = craplot.cdbccxlt 
                                       AND crapcdb.nrdolote = craplot.nrdolote
                                       NO-LOCK USE-INDEX crapcdb1:
                                            
                                IF  crapcdb.inchqcop <> 1 THEN
                                    NEXT.
                                            
                                ASSIGN aux_vldasoma = aux_vldasoma
                                                    + crapcdb.vlcheque.
    
                            END.  /*  Fim do FOR EACH - crapcdb. */
                        ELSE DO:
                            ASSIGN ind_dtmvtolt = crapcst.dtmvtolt
                                   ind_cdagenci = crapcst.cdagenci
                                   ind_cdbccxlt = crapcst.cdbccxlt 
                                   ind_nrdolote = crapcst.nrdolote
                                   ind_nrseqdig = crapcst.nrseqdig
                                   aux_cdpesqui = STRING(ind_dtmvtolt,
                                                         "99/99/9999") + "-" +
                                                  STRING(ind_cdagenci,"999") +
                                                  "-" +
                                                  STRING(ind_cdbccxlt,"999") +
                                                  "-" +
                                                  STRING(ind_nrdolote,"999999")
                                                  + "-" +
                                                  STRING(crapcst.nrseqdig,
                                                         "99999")
                                   aux_vldasoma = 0.
     
                            FOR EACH crapcst WHERE
                                crapcst.cdcooper = par_cdcooper AND
                                crapcst.dtmvtolt = ind_dtmvtolt AND
                                crapcst.cdagenci = ind_cdagenci AND
                                crapcst.cdbccxlt = ind_cdbccxlt AND
                                crapcst.nrdolote = ind_nrdolote
                                NO-LOCK USE-INDEX crapcst1:
                            
                                IF   crapcst.inchqcop <> 1   THEN
                                     NEXT.
                            
                                ASSIGN aux_vldasoma = aux_vldasoma + 
                                               crapcst.vlcheque.
    
                            END.  /*  Fim do FOR EACH - crapcst. */
                        END.

                        ASSIGN aux_cdpesqui = aux_cdpesqui + 
                                            " SOMA = " +
                                            TRIM(STRING(aux_vldasoma,
                                                       "zzz,zzz,zz9.99")).

                    END.
                    ELSE
                        ASSIGN aux_cdpesqui = aux_cdpesqui + 
                                            (IF craplcm.nrdolote = 4500 THEN
                                                " SOMA = " +
                                                TRIM(STRING(craplot.vlcompcc,
                                                           "zzz,zzz,zz9.99"))
                                             ELSE
                                                " SOMA = " +
                                                TRIM(STRING(craplot.vlcompdb,
                                                           "zzz,zzz,zz9.99"))).
                ELSE
                    ASSIGN aux_cdpesqui = aux_cdpesqui + " LOTE JA BAIXADO".
            END.
            ELSE
                 ASSIGN aux_cdpesqui = "".
         
            LEAVE.
             
        END.  /*  Fim do WHILE TRUE  */
    
    END.
    
    /*  Tratamento para a TCO - Contas Migradas  */
    IF  par_cdcooper = 1 OR
        par_cdcooper = 2 THEN DO:
        FIND craptco WHERE craptco.cdcopant = par_cdcooper     
                       AND craptco.nrctaant = par_nrdconta
                       AND craptco.tpctatrf = 1                
                       AND craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.
                                             
        IF  AVAIL craptco THEN
            ASSIGN aux_cdpesqui = "TCO".

    END.
    
    /* cheque normal */    
    IF  par_inchqdev = 1 THEN DO:
        IF  CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   AND
                                   crapdev.cdbanchq = aux_cdbanchq   AND
                                   crapdev.cdagechq = par_cdagechq   AND
                                   crapdev.nrctachq = par_nrctachq   AND
                                   crapdev.nrcheque = par_nrdocmto   AND
                                   crapdev.cdhistor = 46)            OR
            CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   AND
                                   crapdev.cdbanchq = aux_cdbanchq   AND
                                   crapdev.cdagechq = par_cdagechq   AND
                                   crapdev.nrctachq = par_nrctachq   AND
                                   crapdev.nrcheque = par_nrdocmto   AND
                                   crapdev.cdhistor = par_cdhistor)  THEN DO:
            ASSIGN aux_cdcritic = 415
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
    
        IF  (par_cdalinea > 40 AND par_cdalinea < 50) OR
            (par_cdalinea = 20)                       OR
            (par_cdalinea = 28)                       OR
            (par_cdalinea = 30)                       OR
            (par_cdalinea = 31)                       OR
            (par_cdalinea = 32)                       OR
            (par_cdalinea = 35)                       OR
            (par_cdalinea = 37)                       OR
            (par_cdalinea = 39)                       OR
            (par_cdalinea = 72)                       THEN
            .
        ELSE DO: 
            CREATE crapdev.
            ASSIGN crapdev.cdcooper = par_cdcooper
                   crapdev.dtmvtolt = par_dtmvtolt
                   crapdev.cdbccxlt = par_cdbccxlt
                   crapdev.nrdconta = par_nrdconta
                   crapdev.nrdctabb = par_nrctachq
                   crapdev.nrdctitg = par_nrdctitg
                   crapdev.nrcheque = par_nrdocmto
                   crapdev.vllanmto = par_vllanmto
                   crapdev.cdalinea = par_cdalinea
                   crapdev.cdoperad = par_cdoperad
                   crapdev.cdhistor = 46
                   crapdev.cdpesqui = aux_cdpesqui
                   crapdev.insitdev = 0
                   crapdev.cdbanchq = IF   par_cdbccxlt = 756 THEN
                                           756
                                      ELSE
                                      IF  par_cdbccxlt = crapcop.cdbcoctl
                                           THEN crapcop.cdbcoctl
                                      ELSE 1
                   crapdev.cdagechq = par_cdagechq
                   crapdev.nrctachq = par_nrctachq
                   crapdev.cdcooper = par_cdcooper.
            
            IF   par_nrdctitg = ""   THEN   /* Nao eh conta-integracao */
                 crapdev.indctitg = FALSE.
            ELSE
                 crapdev.indctitg = TRUE.

            VALIDATE crapdev.
        END.
    
        CREATE crapdev.
        ASSIGN crapdev.cdcooper = par_cdcooper
               crapdev.dtmvtolt = par_dtmvtolt
               crapdev.cdbccxlt = par_cdbccxlt
               crapdev.nrdconta = par_nrdconta
               crapdev.nrdctabb = par_nrctachq
               crapdev.nrdctitg = par_nrdctitg
               crapdev.nrcheque = par_nrdocmto
               crapdev.vllanmto = par_vllanmto
               crapdev.cdalinea = par_cdalinea
               crapdev.cdoperad = par_cdoperad
               crapdev.cdhistor = par_cdhistor
               crapdev.cdpesqui = aux_cdpesqui
               crapdev.insitdev = 0
               crapdev.cdbanchq = IF   par_cdbccxlt = 756 THEN
                                       756
                                  ELSE
                                  IF   par_cdbccxlt = crapcop.cdbcoctl THEN
                                       crapcop.cdbcoctl
                                  ELSE 1
               crapdev.cdagechq = par_cdagechq
               crapdev.nrctachq = par_nrctachq
               crapdev.cdcooper = par_cdcooper.

        /* Nao eh conta-integracao */
        IF  par_nrdctitg = ""   THEN
            crapdev.indctitg = FALSE.
        ELSE
            crapdev.indctitg = TRUE.

        VALIDATE crapdev.
        
    END.
    ELSE
    IF  par_inchqdev = 2   OR
        par_inchqdev = 4   THEN DO:
        IF  CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   
                               AND crapdev.cdbanchq = aux_cdbanchq   
                               AND crapdev.cdagechq = par_cdagechq   
                               AND crapdev.nrctachq = par_nrctachq   
                               AND crapdev.nrcheque = par_nrdocmto   
                               AND crapdev.cdhistor = 46) THEN DO:
            ASSIGN aux_cdcritic = 415
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

        IF  (par_cdalinea > 40 AND
             par_cdalinea < 50) OR
            (par_cdalinea = 20) OR
            (par_cdalinea = 28) OR
            (par_cdalinea = 30) OR
            (par_cdalinea = 31) OR
            (par_cdalinea = 32) OR
            (par_cdalinea = 35) OR
            (par_cdalinea = 37) OR
            (par_cdalinea = 39) OR
            (par_cdalinea = 72) THEN
            .
        ELSE DO:                                    
            CREATE crapdev.
            ASSIGN crapdev.cdcooper = par_cdcooper
                   crapdev.dtmvtolt = par_dtmvtolt
                   crapdev.cdbccxlt = par_cdbccxlt
                   crapdev.nrdconta = par_nrdconta
                   crapdev.nrdctabb = par_nrctachq
                   crapdev.nrdctitg = par_nrdctitg
                   crapdev.nrcheque = par_nrdocmto
                   crapdev.vllanmto = par_vllanmto
                   crapdev.cdalinea = par_cdalinea
                   crapdev.cdoperad = par_cdoperad
                   crapdev.cdhistor = 46
                   crapdev.cdpesqui = aux_cdpesqui
                   crapdev.insitdev = 0
                   crapdev.cdbanchq = IF  par_cdbccxlt = 756 THEN
                                          756
                                      ELSE
                                      IF  par_cdbccxlt = crapcop.cdbcoctl THEN
                                          crapcop.cdbcoctl
                                      ELSE 1
                   crapdev.cdagechq = par_cdagechq
                   crapdev.nrctachq = par_nrctachq
                   crapdev.cdcooper = par_cdcooper.

            /* Nao eh conta-integracao */
            IF  par_nrdctitg = ""   THEN
                crapdev.indctitg = FALSE.
            ELSE
                crapdev.indctitg = TRUE.       

            VALIDATE crapdev.
        END.
    END.
    ELSE
    IF  par_inchqdev = 3   THEN DO: /* Transferencia */
    
        IF  CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   AND
                                   crapdev.cdbanchq = aux_cdbanchq   AND
                                   crapdev.cdagechq = par_cdagechq   AND
                                   crapdev.nrctachq = par_nrctachq   AND
                                   crapdev.nrcheque = par_nrdocmto   AND
                                   crapdev.cdhistor = 46)            OR
            CAN-FIND(crapdev WHERE crapdev.cdcooper = par_cdcooper   AND
                                   crapdev.cdbanchq = aux_cdbanchq   AND
                                   crapdev.cdagechq = par_cdagechq   AND
                                   crapdev.nrctachq = par_nrctachq   AND
                                   crapdev.nrcheque = par_nrdocmto   AND
                                   crapdev.cdhistor = par_cdhistor /*78*/ ) 
                                   THEN DO:
            ASSIGN aux_cdcritic = 415
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.

        IF   (par_cdalinea > 40 AND par_cdalinea < 50) OR
             (par_cdalinea = 20)                       OR
             (par_cdalinea = 28)                       OR
             (par_cdalinea = 30)                       OR
             (par_cdalinea = 31)                       OR
             (par_cdalinea = 32)                       OR
             (par_cdalinea = 35)                       OR
             (par_cdalinea = 37)                       OR
             (par_cdalinea = 39)                       OR
             (par_cdalinea = 72)                       THEN
             .
        ELSE DO:         
            CREATE crapdev.
            ASSIGN crapdev.cdcooper = par_cdcooper
                   crapdev.dtmvtolt = par_dtmvtolt
                   crapdev.cdbccxlt = par_cdbccxlt
                   crapdev.nrdconta = par_nrdconta
                   crapdev.nrdctabb = par_nrctachq
                   crapdev.nrdctitg = par_nrdctitg
                   crapdev.nrcheque = par_nrdocmto
                   crapdev.vllanmto = par_vllanmto
                   crapdev.cdalinea = par_cdalinea
                   crapdev.cdoperad = par_cdoperad
                   crapdev.cdhistor = 46
                   crapdev.cdpesqui = aux_cdpesqui
                   crapdev.insitdev = 0
                   crapdev.cdbanchq = IF  par_cdbccxlt = 756 THEN
                                          756
                                      ELSE
                                      IF  par_cdbccxlt = crapcop.cdbcoctl THEN
                                          crapcop.cdbcoctl
                                      ELSE 1
                   crapdev.cdagechq = par_cdagechq 
                   crapdev.nrctachq = par_nrctachq
                   crapdev.cdcooper = par_cdcooper.

            /* Nao eh conta-integracao */
            IF   par_nrdctitg = ""   THEN
                 crapdev.indctitg = FALSE.
            ELSE
                 crapdev.indctitg = TRUE.

            VALIDATE crapdev.

        END.

        CREATE crapdev.
        ASSIGN crapdev.cdcooper = par_cdcooper
               crapdev.dtmvtolt = par_dtmvtolt
               crapdev.cdbccxlt = par_cdbccxlt
               crapdev.nrdconta = par_nrdconta
               crapdev.nrdctabb = par_nrctachq
               crapdev.nrdctitg = par_nrdctitg
               crapdev.nrcheque = par_nrdocmto
               crapdev.vllanmto = par_vllanmto
               crapdev.cdalinea = par_cdalinea
               crapdev.cdoperad = par_cdoperad
               crapdev.cdhistor = par_cdhistor /* 78 */
               crapdev.cdpesqui = aux_cdpesqui
               crapdev.insitdev = 0
               crapdev.cdbanchq = IF  par_cdbccxlt = 756 THEN
                                      756
                                  ELSE
                                  IF  par_cdbccxlt = crapcop.cdbcoctl THEN
                                      crapcop.cdbcoctl
                                  ELSE 1
               crapdev.cdagechq = par_cdagechq
               crapdev.nrctachq = par_nrctachq
               crapdev.cdcooper = par_cdcooper.

        /* Nao eh conta-integracao */
        IF   par_nrdctitg = ""   THEN
             crapdev.indctitg = FALSE.
        ELSE
             crapdev.indctitg = TRUE.

        VALIDATE crapdev.
        
    END.
    ELSE
    IF  par_inchqdev = 5   THEN DO:
        DO WHILE TRUE:

            FIND crabdev WHERE crabdev.cdcooper = par_cdcooper   
                           AND crabdev.cdbanchq = aux_cdbanchq   
                           AND crabdev.cdagechq = par_cdagechq   
                           AND crabdev.nrctachq = par_nrctachq   
                           AND crabdev.nrcheque = par_nrdocmto   
                           AND crabdev.cdhistor = par_cdhistor /* 47  191 */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL  crabdev   THEN
                IF  LOCKED crabdev   THEN DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN aux_cdcritic = 416
                           aux_dscritic = "".
                     
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                     
                    RETURN "NOK".
                END.

            IF   (crabdev.cdalinea > 40 AND crabdev.cdalinea < 50) OR
                 (crabdev.cdalinea = 20)                           OR
                 (crabdev.cdalinea = 28)                           OR
                 (crabdev.cdalinea = 30)                           OR
                 (crabdev.cdalinea = 31)                           OR
                 (crabdev.cdalinea = 32)                           OR
                 (crabdev.cdalinea = 35)                           OR
                 (crabdev.cdalinea = 37)                           OR
                 (crabdev.cdalinea = 39)                           OR
                 (crabdev.cdalinea = 72)                           THEN
                  .
            ELSE DO:
                FIND crapdev WHERE crapdev.cdcooper = par_cdcooper 
                               AND crapdev.cdbanchq = aux_cdbanchq 
                               AND crapdev.cdagechq = par_cdagechq 
                               AND crapdev.nrctachq = par_nrctachq 
                               AND crapdev.nrcheque = par_nrdocmto 
                               AND crapdev.cdhistor = 46
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL  crapdev   THEN
                    IF  LOCKED crapdev   THEN DO:
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN aux_cdcritic = 416
                               aux_dscritic = "".
                         
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                         
                        RETURN "NOK".
                    END.

                DELETE crapdev.

            END.

            DELETE crabdev.

            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
    END.
    ELSE
    IF  par_inchqdev = 6   OR
        par_inchqdev = 8   THEN DO:
        DO WHILE TRUE:

            FIND crabdev WHERE crabdev.cdcooper = par_cdcooper
                           AND crabdev.cdbanchq = aux_cdbanchq
                           AND crabdev.cdagechq = par_cdagechq
                           AND crabdev.nrctachq = par_nrctachq
                           AND crabdev.nrcheque = par_nrdocmto
                           AND crabdev.cdhistor = par_cdhistor /* 47  191 */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crabdev   THEN
                IF  LOCKED crabdev   THEN DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN aux_cdcritic = 416
                           aux_dscritic = "".
                     
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                     
                    RETURN "NOK".
                END.

            IF   (crabdev.cdalinea > 40 AND crabdev.cdalinea < 50) OR
                 (crabdev.cdalinea = 20)                       OR
                 (crabdev.cdalinea = 28)                       OR
                 (crabdev.cdalinea = 30)                       OR
                 (crabdev.cdalinea = 31)                       OR
                 (crabdev.cdalinea = 32)                       OR
                 (crabdev.cdalinea = 35)                       OR
                 (crabdev.cdalinea = 37)                       OR
                 (crabdev.cdalinea = 39)                       OR
                 (crabdev.cdalinea = 72)                       THEN
                 .
            ELSE DO:   
                FIND crapdev WHERE crapdev.cdcooper = par_cdcooper   
                               AND crapdev.cdbanchq = aux_cdbanchq   
                               AND crapdev.cdagechq = par_cdagechq   
                               AND crapdev.nrctachq = par_nrctachq   
                               AND crapdev.nrcheque = par_nrdocmto   
                               AND crapdev.cdhistor = 46
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapdev   THEN
                    IF  LOCKED crapdev  THEN DO:
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN aux_cdcritic = 416
                               aux_dscritic = "".
                         
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                         
                        RETURN "NOK".
                    END.

                DELETE crapdev.
            END.

            DELETE crabdev.

            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
    END.
    ELSE
    IF  par_inchqdev = 7   THEN DO:
        DO WHILE TRUE:

            FIND crabdev WHERE crabdev.cdcooper = par_cdcooper
                           AND crabdev.cdbanchq = aux_cdbanchq
                           AND crabdev.cdagechq = par_cdagechq
                           AND crabdev.nrctachq = par_nrctachq
                           AND crabdev.nrcheque = par_nrdocmto
                           AND crabdev.cdhistor = par_cdhistor /* 47  191 */
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL  crabdev   THEN
                IF  LOCKED crabdev   THEN DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
                ELSE DO:
                    ASSIGN aux_cdcritic = 416
                           aux_dscritic = "".
                     
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                     
                    RETURN "NOK".
                END.

            IF   (crabdev.cdalinea > 40 AND crabdev.cdalinea < 50) OR
                 (crabdev.cdalinea = 20)                           OR
                 (crabdev.cdalinea = 28)                           OR
                 (crabdev.cdalinea = 30)                           OR
                 (crabdev.cdalinea = 31)                           OR
                 (crabdev.cdalinea = 32)                           OR
                 (crabdev.cdalinea = 35)                           OR
                 (crabdev.cdalinea = 37)                           OR
                 (crabdev.cdalinea = 39)                           OR
                 (crabdev.cdalinea = 72)                           THEN
                  .
            ELSE DO:
                FIND crapdev WHERE crapdev.cdcooper = par_cdcooper
                               AND crapdev.cdbccxlt = par_cdbccxlt
                               AND crapdev.cdagechq = par_cdagechq
                               AND crapdev.nrctachq = par_nrctachq
                               AND crapdev.nrcheque = par_nrdocmto
                               AND crapdev.cdhistor = 46
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL  crapdev  THEN
                    IF  LOCKED crapdev  THEN DO:
                        PAUSE 2 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN aux_cdcritic = 416
                               aux_dscritic = "".
                         
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                         
                        RETURN "NOK".
                    END.

                DELETE crapdev.

            END.

            DELETE crabdev.

            LEAVE.

        END.  /*  Fim do DO WHILE TRUE  */
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_log:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_flgopcao AS LOGICAL                            NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrctachq AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdalinea AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                               NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-desmarcar.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dsoperac AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Verificar se tem registro, se nao tiver, significa que iremos desmarcar */
    FIND FIRST tt-desmarcar NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-desmarcar THEN
        DO:
            IF  par_flgopcao THEN
                aux_dsoperac = "desmarcou".
            ELSE  
                aux_dsoperac = "marcou". 

            FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                 AND crapope.cdoperad = par_cdoperad
                                 NO-LOCK NO-ERROR.

            IF  AVAIL crapope THEN
                ASSIGN aux_nmoperad = crapope.nmoperad.

            FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                               NO-LOCK NO-ERROR.

            UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " + 
                              STRING(TIME,"HH:MM:SS") + " - Coop: " + STRING(par_cdcooper,"99")
                             + " - Processar: " + par_nmdatela
                             + "' --> '"  + STRING(par_cdoperad)
                             + "-" + TRIM(aux_nmoperad) + ", "
                             + TRIM(aux_dsoperac) + " o cheque "
                             + STRING(par_nrdocmto,"zzz,zz9")
                             + " da conta/dv " + STRING(par_nrctachq,"zzzz,zzz,9")
                             + " do Banco " + string(par_cdbanchq, "zz9")
                             + ", valor " + string(par_vllanmto, "zzz,zz9.99")
                             + " com alinea "+ string(par_cdalinea,"z9")
                             + " >> /usr/coop/" + TRIM(crapcop.dsdircop)
                             + "/log/devolu.log" ).
        END.
    ELSE /* Desmarcar cheques */
        DO:
            FOR EACH tt-desmarcar NO-LOCK:
                IF  par_flgopcao THEN
                    aux_dsoperac = "desmarcou".
                ELSE  
                    aux_dsoperac = "marcou". 

                FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                                     AND crapope.cdoperad = par_cdoperad
                                     NO-LOCK NO-ERROR.

                IF  AVAIL crapope THEN
                    ASSIGN aux_nmoperad = crapope.nmoperad.

                FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.

                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " + 
                                  STRING(TIME,"HH:MM:SS") + " - Coop: " + STRING(par_cdcooper,"99")
                                 + " - Processar: " + par_nmdatela
                                 + "' --> '"  + STRING(par_cdoperad)
                                 + "-" + TRIM(aux_nmoperad) + ", "
                                 + TRIM(aux_dsoperac) + " o cheque "
                                 + STRING(tt-desmarcar.nrcheque,"zzz,zz9")
                                 + " da conta/dv " + STRING(tt-desmarcar.nrctachq,"zzzz,zzz,9")
                                 + " do Banco " + STRING(tt-desmarcar.cdbanchq, "zz9")
                                 + ", valor " + STRING(tt-desmarcar.vllanmto, "zzz,zz9.99")
                                 + " com alinea "+ STRING(tt-desmarcar.cdalinea,"z9")
                                 + " >> /usr/coop/" + TRIM(crapcop.dsdircop)
                                 + "/log/devolu.log" ).
            END.
        END.
        
    RETURN "OK".

END PROCEDURE.     

/******************************************************************************/

PROCEDURE verifica-solicitacao-processo:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF  CAN-FIND(crapsol WHERE crapsol.cdcooper = par_cdcooper  
                           AND crapsol.dtrefere = par_dtmvtolt  
                           AND crapsol.nrsolici = 78            
                           AND crapsol.nrseqsol = par_cddevolu) THEN DO:


        ASSIGN aux_cdcritic = 138
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE grava_processo_solicitacao:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cddsenha AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0.

    CASE par_cddevolu:
         WHEN 1 THEN IF  par_cddsenha <> "nacndpv"   THEN aux_cdcritic = 03.
         WHEN 2 THEN IF  par_cddsenha <> "pspcersv"  THEN aux_cdcritic = 03.
         WHEN 3 THEN IF  par_cddsenha <> "veqsntv"   THEN aux_cdcritic = 03.
    END CASE.

    IF  aux_cdcritic > 0 THEN DO:
        ASSIGN aux_dscritic = "".
            
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    DO  TRANSACTION:
        CREATE crapsol.
        ASSIGN crapsol.cdcooper = par_cdcooper
               crapsol.nrsolici = 78
               crapsol.dtrefere = par_dtmvtolt
               crapsol.cdempres = 11
               crapsol.dsparame = ""
               crapsol.insitsol = 1
               crapsol.nrdevias = 0
               crapsol.nrseqsol = par_cddevolu.
    END.

    RELEASE crapsol.

    RETURN "OK".
            
END PROCEDURE.

/******************************************************************************/

PROCEDURE executa-processo-devolu:
    
    /***********************************************************
    Atende a solicitacao 78.
    Efetuar o lote de devolucoes e taxas de devolucoes para
    contra-ordem e gerar arquivo de devolucoes. Relatorio 219.
       
    Antigo Fonte crps264.p
    ***********************************************************/

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR FORMAT "X(10)"                NO-UNDO.
    DEF INPUT PARAM par_nmdatela LIKE craptel.nmdatela                 NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR FORMAT "X(10)"                NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_valorvlb AS DECI                                       NO-UNDO.
    DEF VAR aux_vldevolu AS DECI                                       NO-UNDO.
    DEF VAR res_nrdctabb AS INTE                                       NO-UNDO.
    DEF VAR res_nrdocmto AS INTE                                       NO-UNDO.
    DEF VAR res_cdhistor AS INTE                                       NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Valores do Parametro:  par_cddevolu
    1 = BANCOOB
    2 = CONTA BASE (BB)
    3 = CONTA INTEGRACAO (BB)
    4 = CHEQUE VLB  (CECRED)
    5 = 1a EXECUCAO (CECRED)
    6 = 2a EXECUCAO (CECRED) */

    /* Busca dados da cooperativa */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapcop THEN DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".
            
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.                      
    
    ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
         /*  res_nrdctabb = INTEGER(SUBSTRING(glb_dsrestar,01,08))
           res_nrdocmto = INTEGER(SUBSTRING(glb_dsrestar,10,07))
           res_cdhistor = INTEGER(SUBSTRING(glb_dsrestar,18,03)) */ .

    CASE par_cddevolu:

        /*  BANCOOB  */
        WHEN 1 THEN  aux_cdbanchq = 756.
    
        /*  CONTA BASE  */
        WHEN 2 THEN  aux_cdbanchq = 1.
    
        /*  CONTA INTEGRACAO  */
        WHEN 3 THEN  aux_cdbanchq = 1.
    
        /*  CECRED  */
        WHEN 4 OR WHEN 5 OR WHEN 6 THEN aux_cdbanchq = crapcop.cdbcoctl.
    
    END CASE.

    /* Leitura da tabela com o valor definido para cheque VLB */ 
    RUN busca-valor-cheque(INPUT par_cdcooper,
                           INPUT "CRED"      , /* par_nmsistem */
                           INPUT "GENERI"    , /* par_tptabela */
                           INPUT 0           , /* par_cdempres */
                           INPUT "VALORESVLB", /* par_cdacesso */
                           INPUT 0           , /* par_tpregist */
                           OUTPUT aux_valorvlb,
                           OUTPUT aux_vldevolu,
                           OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE <> "OK" THEN DO:
        ASSIGN aux_cdcritic = 55
               aux_dscritic = "".
        RUN fontes/critic.p.
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          par_cdprogra + "' --> '" + aux_dscritic +
                          " CRED-GENERI-00-VALORESVLB-001 " +
                          " >> log/proc_batch.log").

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF  par_cddevolu >= 4 THEN DO:
        RUN verifica_locks(INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT par_nmdatela,
                           INPUT par_cddevolu,
                           OUTPUT TABLE tt-erro).
    END.

    IF  RETURN-VALUE <> "OK" THEN
    DO:
        DO  TRANSACTION:
            FIND crapsol WHERE crapsol.cdcooper = par_cdcooper   
                           AND crapsol.dtrefere = par_dtmvtolt     
                           AND crapsol.nrsolici = 78               
                           AND crapsol.nrseqsol = par_cddevolu
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            DELETE crapsol.
        END. /* Fim da Transacao */

        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Devolucoes NAO processadas.".

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          aux_dscritic +
                          " Coop: " +  STRING(par_cdcooper) + 
                          " >> log/proc_batch.log").

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".

    END.
    ELSE 
    DO:
         /* Gerar log informando o inicio do processo de devolução dos cheques*/
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          "Inicio do processo - " + 
                          " Coop: " + STRING(par_cdcooper) + 
                          " >> log/proc_batch.log").

        RUN gera_lancamento(INPUT par_cdcooper,
                            INPUT par_dtmvtolt,
                            INPUT par_cdprogra,
                            INPUT par_inproces,
                            INPUT par_cddevolu,
                            INPUT aux_cdbanchq,
                            INPUT aux_valorvlb,
                            INPUT aux_vldevolu,
                            OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "OK" THEN DO:

            IF  par_cddevolu = 1 OR    /* BANCOOB    */
                par_cddevolu = 2 OR    /* CONTA BASE */
                par_cddevolu = 3 THEN  /* INTEGRACAO */
                
                RUN gera_impressao (INPUT par_cdcooper,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtoan,
                                    INPUT par_cdprogra,
                                    INPUT par_cddevolu,
                                    INPUT aux_cdbanchq,
                                    OUTPUT TABLE tt-erro).
                
            IF  RETURN-VALUE = "OK"   THEN DO:
                IF  par_cddevolu = 1    THEN /* BANCOOB */
                    RUN gera_arquivo_bancoob (INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              OUTPUT TABLE tt-erro).
                ELSE
                IF  par_cddevolu = 3    THEN /* CONTA ITG */
                    RUN gera_arquivo_ctaitg (INPUT par_cdcooper,
                                             INPUT par_dtmvtolt,
                                             INPUT par_cdprogra,
                                             OUTPUT TABLE tt-erro).
                ELSE
                IF  par_cddevolu = 5 OR
                    par_cddevolu = 6 THEN 
                DO: /* CECRED */
                    RUN gera_arquivo_cecred(INPUT par_cdcooper,
                                            INPUT par_dtmvtolt,
                                            INPUT par_dtmvtoan,
                                            INPUT par_cdprogra,
                                            INPUT par_cdoperad,
                                            INPUT par_cddevolu,
                                            INPUT aux_valorvlb,
                                            OUTPUT TABLE tt-erro).
                                            
                END.

                HIDE MESSAGE NO-PAUSE.

                /* Gerar log com o fim da execução */ 
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                                  " Devolucoes processadas. " +
                                  " Coop: " + STRING(par_cdcooper) + 
                                  " >> log/proc_batch.log").

            END.
        END.
    END.
    

    RETURN "OK".
    
END PROCEDURE.

/******************************************************************************/

PROCEDURE verifica_locks:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR    FORMAT "x(10)"             NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    DEF BUFFER crawdev FOR crapdev.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrdrecid AS INTE                                       NO-UNDO.
    DEF VAR aux_nrdolote AS INTE                                       NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                       NO-UNDO.
    
    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper 
                       AND crapdev.nrdconta > 0            
                       AND crapdev.insitdev = 0            
                       AND crapdev.cdbanchq = par_cdbanchq
                       NO-LOCK:
                       
        ASSIGN aux_contador = aux_contador + 1
               aux_nrdrecid = RECID(crapdev).
        
        FIND crawdev OF crapdev EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

        IF  LOCKED crawdev THEN DO:
            RUN acha_lock (INPUT  aux_nrdrecid,
                           INPUT  "crapdev",
                           OUTPUT aux_nmusuari).

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro utilizando por " +
                                  aux_nmusuari.

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              aux_dscritic +
                              " Avise a Equipe de Suporte da CECRED" +
                              " Coop: " + STRING(par_cdcooper) +
                              " Banco do Cheque: " + STRING(par_cdbanchq) +
                              " Tabela: crapdev " +
                              " RECID: " + STRING(aux_nrdrecid) +
                              " >> log/proc_batch.log").

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                      
            RETURN "NOK".

        END.
        ELSE DO:
            IF  CAN-DO("47,191,338,573",STRING(crapdev.cdhistor))  THEN DO:
                aux_nrcalcul = INT(SUBSTR(STRING(crapdev.nrcheque,
                                                "9999999"),1,6)).

                FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper        
                               AND crapfdc.cdbanchq = crapdev.cdbanchq  
                               AND crapfdc.cdagechq = crapdev.cdagechq  
                               AND crapfdc.nrctachq = crapdev.nrctachq  
                               AND crapfdc.nrcheque = INT(aux_nrcalcul)
                               USE-INDEX crapfdc1 NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapfdc THEN DO:
                    ASSIGN aux_cdcritic = 268
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                     + " - Coop:" + STRING(par_cdcooper,"99")
                                     + " - Processar:" + par_cdprogra
                                     + "' --> '" + aux_dscritic +
                                     "CTA: " + STRING(crapdev.nrdconta)
                                     + "CBS: " + STRING(crapdev.nrdctabb)
                                     + "DOC: " + STRING(crapdev.nrcheque)
                                     + " >> log/proc_batch.log").

                    RETURN "NOK".

                END.
                ELSE DO:
                    aux_nrdrecid = RECID(crapfdc).

                    FIND CURRENT crapfdc EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                    IF  LOCKED crapfdc THEN DO:
                        RUN acha_lock (INPUT  aux_nrdrecid,
                                       INPUT  "crapfdc",
                                       OUTPUT aux_nmusuari).

                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Registro utilizando por " +
                                              aux_nmusuari.

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                        
                        RETURN "NOK".
                    END.
                END.         
            END.
        END.

    END. /* Fim do FOR EACH */

    DO  aux_contador = 1 TO 2:

        IF  aux_contador = 1 THEN DO:
            CASE par_cddevolu:
                WHEN 1 THEN aux_nrdolote = 10110. /* BANCOOB */
                WHEN 2 THEN aux_nrdolote = 8451.  /* CONTA BASE */
                WHEN 3 THEN aux_nrdolote = 10109. /* CONTA INTEGRACAO */
                WHEN 4 THEN aux_nrdolote = 10117. /* CECRED */
            END CASE.
        END.
        ELSE
            IF  aux_contador = 2 THEN
                aux_nrdolote = 8452.

        FIND craplot WHERE craplot.cdcooper = par_cdcooper
                       AND craplot.dtmvtolt = par_dtmvtolt
                       AND craplot.cdagenci = aux_cdagenci
                       AND craplot.cdbccxlt = aux_cdbccxlt
                       AND craplot.nrdolote = aux_nrdolote
                     NO-LOCK NO-ERROR.

        IF  AVAILABLE craplot THEN DO:
            aux_nrdrecid = RECID(craplot).
                  
            FIND CURRENT craplot EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

            IF  LOCKED craplot   THEN DO:
                RUN acha_lock(INPUT  aux_nrdrecid, 
                              INPUT  "craplot",
                              OUTPUT aux_nmusuari). 
                
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro utilizando por " +
                                      aux_nmusuari.

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                        
                RETURN "NOK".

            END.
        END.

    END. /* Fim do DO */
                    
    RETURN "OK".

END PROCEDURE.
                                                                                
/******************************************************************************/

PROCEDURE acha_lock:

    DEF INPUT  PARAM par_recid    AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nmtabela AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmusuari AS CHAR                              NO-UNDO.

    FIND FIRST _file WHERE _file-name = par_nmtabela
                           NO-LOCK NO-ERROR.

    IF  NOT AVAIL _file THEN
        RETURN "OK".

    FIND FIRST _lock WHERE _lock-table = _file._file-number
                       AND _lock-recid = par_recid
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL _lock THEN
        RETURN "OK".

    ASSIGN par_nmusuari = _lock._lock-name.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_lancamento:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR FORMAT "X(10)"                NO-UNDO.
    DEF INPUT PARAM par_inproces AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_valorvlb AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_vldevolu AS DECI                               NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crawdev FOR crapdev.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                       NO-UNDO.
    DEF VAR aux_verifloc AS INTE                                       NO-UNDO.
    DEF VAR aux_cdtarifa AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdtarbac AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p 
            PERSISTENT SET h-b1wgen0153.

    TRANS_1:

    /* TCO = Transferencia de contas */
    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.nrdconta > 0
                       AND crapdev.insitdev = 0 EXCLUSIVE-LOCK
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

        FIND FIRST crapass WHERE crapass.cdcooper = crapdev.cdcooper
                             AND crapass.nrdconta = crapdev.nrdconta
                             NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN DO:
            ASSIGN aux_cdcritic = 251
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                              " - " + par_cdprogra + "' --> '" +
                              "Coop: " + STRING(par_cdcooper,"99") +
                              "Conta: " + STRING(crapdev.nrdconta,"zzzz,zz9,9") +
                              " Ref: " + STRING(par_dtmvtolt,"99/99/9999") +
                              aux_dscritic + 
                              " >> log/proc_batch.log").
            
            IF  VALID-HANDLE(h-b1wgen0153) THEN
                DELETE OBJECT h-b1wgen0153.

            UNDO TRANS_1, RETURN "NOK".

        END.
        
        IF  crapass.inpessoa = 1 THEN DO:
            ASSIGN aux_cdtarifa = "DEVOLCHQPF" 
                   aux_cdtarbac = "DEVCHQBCPF". 
        END.
        ELSE DO:
            ASSIGN aux_cdtarifa = "DEVOLCHQPJ" 
                   aux_cdtarbac = "DEVCHQBCPJ". 
        END.
            
        IF  aux_cdtarifa = "DEVOLCHQPF" OR
            aux_cdtarifa = "DEVOLCHQPJ" THEN DO:
            
            RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                            (INPUT  par_cdcooper,
                                             INPUT  aux_cdtarifa,
                                             INPUT  1, 
                                             INPUT  "", /*cdprogra*/
                                             OUTPUT aux_cdhistor,
                                             OUTPUT aux_cdhisest,
                                             OUTPUT aux_vltarifa,
                                             OUTPUT aux_dtdivulg,
                                             OUTPUT aux_dtvigenc,
                                             OUTPUT aux_cdfvlcop,
                                             OUTPUT TABLE tt-erro).
                
            IF  RETURN-VALUE <> "OK"  THEN DO:

                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL tt-erro THEN

                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                + " - Coop:" + STRING(par_cdcooper,"99")
                                + " - Processar:" + par_cdprogra + "'-->'"
                                + " Ref: " + STRING(par_dtmvtolt,"99/99/9999")
                                + STRING(crapdev.nrdconta,"zzzz,zz9,9")
                                + aux_dscritic + " >> log/proc_batch.log").

                IF  VALID-HANDLE(h-b1wgen0153) THEN
                    DELETE OBJECT h-b1wgen0153.
        
                UNDO TRANS_1, RETURN "NOK".

            END.
        END.
        
        /* BUSCA INFORMACOES TAXA BACEN*/
        IF  aux_cdtarbac = "DEVCHQBCPJ" OR
            aux_cdtarbac = "DEVCHQBCPF" THEN DO:

            RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                            (INPUT par_cdcooper,
                                             INPUT aux_cdtarbac,
                                             INPUT 1, 
                                             INPUT "", /*cdprogra*/
                                             OUTPUT aux_cdhisbac,
                                             OUTPUT aux_cdhisest,
                                             OUTPUT aux_vltarbac,
                                             OUTPUT aux_dtdivulg,
                                             OUTPUT aux_dtvigenc,
                                             OUTPUT aux_cdfvlbac,
                                             OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE = "NOK"  THEN DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL tt-erro THEN
                    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                              " - Coop:" + STRING(par_cdcooper,"99") +
                              " - Processar:" + par_cdprogra + "'-->'" +
                              " Ref: " + STRING(par_dtmvtolt,"99/99/9999") +
                              tt-erro.dscritic + " >> log/proc_batch.log").
                    
                IF  VALID-HANDLE(h-b1wgen0153) THEN
                    DELETE OBJECT h-b1wgen0153.

                UNDO TRANS_1, RETURN "NOK".
            END.
        END.

        ASSIGN aux_contador = aux_contador + 1.

        ASSIGN aux_cdcritic = 0
               aux_nrdconta_tco = 0
               aux_cdagectl = 0
               aux_cdcopant = 0.

        CASE par_cddevolu:

            /*  BANCOOB  */
            WHEN 1 THEN
                IF  crapdev.cdbanchq <> 756 THEN
                    NEXT.

            /*  CONTA BASE  */
            WHEN 2 THEN DO:
                IF  crapdev.cdbanchq <> 1  THEN
                    NEXT.

                ASSIGN aux_ctpsqitg = crapdev.nrdctabb.

                RUN sistema/generico/procedures/b1wgen9998.p
                    PERSISTENT SET h-b1wgen9998.
    
                IF  NOT VALID-HANDLE(h-b1wgen9998) THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen9998.".
      
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
    
                    RETURN "NOK".
                END.
                
                RUN existe_conta_integracao IN h-b1wgen9998
                                           (INPUT par_cdcooper,
                                            INPUT aux_ctpsqitg,
                                            OUTPUT aux_nrdctitg,
                                            OUTPUT aux_nrctaass).

                IF  aux_nrdctitg = ""   THEN
                    NEXT.

                IF  VALID-HANDLE(h-b1wgen9998) THEN
                    DELETE OBJECT h-b1wgen9998.
            END.

            /*  CONTA INTEGRACAO  */
            WHEN 3 THEN DO:
                IF  crapdev.cdbanchq <> 1  THEN
                    NEXT.

                ASSIGN aux_ctpsqitg = f_ver_contaitg(crapdev.nrdctitg).

                RUN sistema/generico/procedures/b1wgen9998.p
                    PERSISTENT SET h-b1wgen9998.
    
                IF  NOT VALID-HANDLE(h-b1wgen9998) THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO " +
                                          "b1wgen9998.".
      
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
    
                    RETURN "NOK".
                END.
                
                RUN existe_conta_integracao IN h-b1wgen9998
                                           (INPUT par_cdcooper,
                                            INPUT aux_ctpsqitg,
                                            OUTPUT aux_nrdctitg,
                                            OUTPUT aux_nrctaass).

                IF  aux_nrdctitg = ""   THEN
                    NEXT.

                IF  VALID-HANDLE(h-b1wgen9998) THEN
                    DELETE OBJECT h-b1wgen9998.

            END.                

            /*  CECRED */
            WHEN 5 OR WHEN 6 THEN
                IF  crapdev.cdbanchq <> crapcop.cdbcoctl THEN
                    NEXT.

        END CASE.
        
        IF  crapdev.cdpesqui = "TCO" THEN DO:
            FIND craptco WHERE craptco.cdcopant = par_cdcooper
                           AND craptco.nrctaant = crapdev.nrdconta
                           AND craptco.tpctatrf = 1
                           AND craptco.flgativo = TRUE
                           NO-LOCK NO-ERROR.

            IF  AVAILABLE craptco THEN
                ASSIGN aux_cdcooper = craptco.cdcooper
                       aux_nrdconta = craptco.nrdconta
                       aux_nrctalcm = craptco.nrdconta.
            ELSE
                ASSIGN aux_cdcooper = par_cdcooper
                       aux_nrdconta = crapdev.nrdconta
                       aux_nrctalcm = crapdev.nrdctabb.

        END.
        ELSE
        DO:
            ASSIGN aux_cdcooper = par_cdcooper
                   aux_nrdconta = crapdev.nrdconta
                   aux_nrctalcm = crapdev.nrdctabb.

            /* VIACON - Se for conta migrada das cooperativas 4 ou 15 devera
            tratar aux_nrctalcm para receber a nova conta. O campo
            crapdev.nrdctabb contem o numero da conta cheque */ 
            IF par_cdcooper = 1 OR     /* Viacredi */
               par_cdcooper = 13 THEN  /* Scrcred  */
            DO:

                RUN verifica_incorporacao(INPUT  par_cdcooper,
                                          INPUT  crapdev.nrdconta,
                                          INPUT  crapdev.nrcheque,
                                          OUTPUT aux_cdcopant,
                                          OUTPUT aux_nrdconta_tco,
                                          OUTPUT aux_cdagectl).

                /* Se aux_nrdconta_tco > 0 eh incorporacao */
                IF aux_nrdconta_tco > 0 THEN
                    ASSIGN aux_nrctalcm = crapdev.nrdconta. 

            END.

        END.
        /* Historicos que indicam cheque devolvido */
        IF  CAN-DO("47,191,338,573",STRING(crapdev.cdhistor)) THEN DO:
            aux_nrcalcul = INT(SUBSTR(STRING(crapdev.nrcheque,
                                            "9999999"),1,6)).

            DO  WHILE TRUE:

                FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper
                               AND crapfdc.cdbanchq = crapdev.cdbanchq
                               AND crapfdc.cdagechq = crapdev.cdagechq
                               AND crapfdc.nrctachq = crapdev.nrctachq
                               AND crapfdc.nrcheque = INT(aux_nrcalcul)
                               USE-INDEX crapfdc1
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapfdc   THEN DO:
                    
                    IF  LOCKED crapfdc   THEN DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        ASSIGN aux_cdcritic = 268
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1, /*sequencia*/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        LEAVE.
                    END.

                END.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            IF  aux_cdcritic > 0  THEN DO:
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                  " - Coop:" + STRING(par_cdcooper,"99") + 
                                  " - Processar:" + par_cdprogra + 
                                  " Ref: " + STRING(par_dtmvtolt,"99/99/9999") + 
                                  "'-->'" + aux_dscritic +
                                  "CTA: " + STRING(crapdev.nrdconta) + 
                                  "CBS: " + STRING(crapdev.nrdctabb) + 
                                  "DOC: " + STRING(crapdev.nrcheque) + 
                                  " >> log/proc_batch.log").

                ASSIGN aux_cdcritic = 0.

                IF  VALID-HANDLE(h-b1wgen0153) THEN
                    DELETE OBJECT h-b1wgen0153. 

                UNDO TRANS_1, RETURN "NOK".
            END.

            /*  Leitura do lote de devolucao de cheque  */
            DO  WHILE TRUE:
                
                IF  par_cddevolu = 1 THEN       /*  BANCOOB  */
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper
                                   AND craplot.dtmvtolt = par_dtmvtolt
                                   AND craplot.cdagenci = aux_cdagenci
                                   AND craplot.cdbccxlt = aux_cdbccxlt
                                   AND craplot.nrdolote = 10110
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                ELSE
                IF  par_cddevolu = 2 THEN       /*  CONTA BASE  */
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper 
                                   AND craplot.dtmvtolt = par_dtmvtolt
                                   AND craplot.cdagenci = aux_cdagenci
                                   AND craplot.cdbccxlt = aux_cdbccxlt
                                   AND craplot.nrdolote = 8451
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                ELSE
                IF  par_cddevolu = 3 THEN     /*  CONTA INTEGRACAO  */
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper
                                   AND craplot.dtmvtolt = par_dtmvtolt
                                   AND craplot.cdagenci = aux_cdagenci 
                                   AND craplot.cdbccxlt = aux_cdbccxlt 
                                   AND craplot.nrdolote = 10109
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                ELSE
                IF  par_cddevolu = 5 OR
                    par_cddevolu = 6 THEN       /*  CECRED  */
                    FIND craplot WHERE craplot.cdcooper = par_cdcooper
                                   AND craplot.dtmvtolt = par_dtmvtolt
                                   AND craplot.cdagenci = aux_cdagenci
                                   AND craplot.cdbccxlt = aux_cdbccxlt
                                   AND craplot.nrdolote = 10117
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craplot   THEN
                    IF  LOCKED craplot   THEN DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                    ELSE DO:
                        CREATE craplot.
                        ASSIGN craplot.cdcooper = par_cdcooper
                               craplot.dtmvtolt = par_dtmvtolt
                               craplot.cdagenci = aux_cdagenci
                               craplot.cdbccxlt = aux_cdbccxlt
                               craplot.tplotmov = 1.

                        CASE par_cddevolu:
                            WHEN 1 THEN craplot.nrdolote = 10110.
                            WHEN 2 THEN craplot.nrdolote = 8451.
                            WHEN 3 THEN craplot.nrdolote = 10109.
                            WHEN 5 OR WHEN 6 THEN 
                            craplot.nrdolote = 10117.
                        END CASE.

                        VALIDATE craplot.

                    END.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            /* FIND na craplcm deve ser feito na cooperativa atual com a 
               conta nova. Como o registro crapdev de conta MIGRADA eh 
               alimentado com a conta antiga(crapdev.nrdctabb), e antes
               estava utilizando crapdev.nrdctabb independente de conta
               migrada, poderia encontrar um lancamento em outra conta 
               da VIACREDI, com o mesmo numero da conta antiga na ACREDI, 
               e nao faria esta devolucao */ 

            DO  aux_verifloc = 1 TO 10:

                /* VIACON - aux_nrctalcm deve conter a nova conta se for conta incorporada  */
                FIND craplcm WHERE craplcm.cdcooper = par_cdcooper
                               AND craplcm.dtmvtolt = craplot.dtmvtolt 
                               AND craplcm.cdagenci = craplot.cdagenci 
                               AND craplcm.cdbccxlt = craplot.cdbccxlt 
                               AND craplcm.nrdolote = craplot.nrdolote 
                               AND craplcm.nrdctabb = aux_nrctalcm 
                               AND craplcm.nrdocmto = crapdev.nrcheque  
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL craplcm THEN DO:
                    IF  LOCKED craplcm THEN DO:

                        ASSIGN aux_cdcritic = 77.
                        LEAVE.
                    END.
                    ELSE DO: 
                        ASSIGN aux_cdcritic = 0.
                        LEAVE.
                    END.
                END.
                ELSE DO:
                    ASSIGN aux_cdcritic = 92
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    LEAVE.
                END.

            END. /* Fim do DO */

            IF  aux_cdcritic > 0  THEN DO:
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")
                                 + " - Coop:" + STRING(par_cdcooper,"99")
                                 + " - Processar:" + par_cdprogra + "' --> '"
                                 + " Ref: " + STRING(par_dtmvtolt,"99/99/9999")
                                 + aux_dscritic + 
                                  " Lote: " + STRING(craplot.nrdolote) +
                                  " CTA: " + STRING(aux_nrctalcm)      +
                                  " CBS: " + STRING(crapdev.nrdctabb)  +
                                  " DOC: " + STRING(crapdev.nrcheque)  +
                                  " >> log/proc_batch.log").

                ASSIGN aux_cdcritic = 0.

                IF  VALID-HANDLE(h-b1wgen0153) THEN
                    DELETE OBJECT h-b1wgen0153. 

                UNDO TRANS_1, RETURN "NOK".
            END.
            
            /* VIACON - cria lancamento na coop atual */
            CREATE craplcm.
            ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrdconta = aux_nrdconta
                   craplcm.nrdctabb = aux_nrctalcm
                   craplcm.nrdocmto = crapdev.nrcheque
                   craplcm.cdhistor = crapdev.cdhistor
                   craplcm.nrseqdig = craplot.nrseqdig + 1
                   craplcm.vllanmto = crapdev.vllanmto
                   craplcm.cdoperad = crapdev.cdoperad
                   craplcm.cdpesqbb = IF  crapdev.cdalinea <> 0 THEN
                                          STRING(crapdev.cdalinea)
                                      ELSE "21"
                   craplcm.cdcooper = aux_cdcooper
                   craplcm.cdbanchq = crapdev.cdbanchq
                   craplcm.cdagechq = crapdev.cdagechq
                   craplcm.nrctachq = crapdev.nrctachq
                    
                   craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                   craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.nrseqdig = craplot.nrseqdig + 1

                   crapfdc.incheque = crapfdc.incheque - 5
                   crapfdc.dtliqchq = ?
                   crapfdc.vlcheque = 0
                   crapfdc.vldoipmf = 0 NO-ERROR.

            VALIDATE craplot.
            
            IF  crapfdc.cdbantic <> 0 THEN
                ASSIGN crapfdc.cdbantic = 0
                       crapfdc.cdagetic = 0
                       crapfdc.nrctatic = 0
                       crapfdc.dtlibtic = ?
                       crapfdc.dtatutic = ?.

            IF  par_cddevolu = 2  OR   /* Conta Base */
                par_cddevolu = 3  THEN /* Conta Integracao */
                craplcm.nrdctitg = crapdev.nrdctitg.
            ELSE     
                craplcm.nrdctitg = "".

            IF  par_cddevolu = 5 OR
                par_cddevolu = 6 THEN DO:
                ASSIGN craplcm.nrdctitg = "".

                /* Atribui Valor para Alinea na GNCPCHQ */
                FIND LAST gncpchq 
                          WHERE gncpchq.cdcooper = aux_cdcooper     
                            AND gncpchq.dtmvtolt = crapfdc.dtliqchq 
                            AND gncpchq.cdbanchq = crapfdc.cdbanchq 
                            AND gncpchq.cdagechq = crapdev.cdagechq 
                            AND gncpchq.nrctachq = crapdev.nrctachq 
                            AND gncpchq.nrcheque = INT(crapdev.nrcheque)
                            AND (gncpchq.cdtipreg = 3              
                             OR gncpchq.cdtipreg = 4)              
                            AND gncpchq.vlcheque = crapdev.vllanmto
                            USE-INDEX gncpchq1 EXCLUSIVE-LOCK
                            NO-ERROR.

                IF  AVAILABLE gncpchq THEN DO:
                    IF  crapdev.cdalinea <> 0 THEN
                        gncpchq.cdalinea = crapdev.cdalinea.
                    ELSE 
                        gncpchq.cdalinea = 21.
                    END.
                            
                    IF  par_cddevolu = 5 THEN DO: /* 1a devolucao - 13:30* */
                          crapdev.indevarq = 2.   /* Envia */
                      END.
                    ELSE /* 2a devolucao – 19:00 – Sessao de Prevencao a Fraudes e Impedimentos*/
                         /* Somente alineas 20, 21, 24, 25, 28, 30, 35 e 70 */
                         /* Na segunda Devolucao envia todos com o 
                         indicador = 1, para saber quem ja foi env. */
                        crapdev.indevarq = 1.  /* Envia */
                           
                    craplcm.dsidenti = STRING(crapdev.indevarq,"9").
                END.
                ELSE
                    craplcm.dsidenti = "2".

                VALIDATE craplcm.
                
                /* iremos verificar se registro criado na craplcm anteriormente é historico 47, 
                   caso seja devmos criar outro com o 399 - DEVOLUCAO DE CHEQUE DESCONTADO */
                IF  crapdev.cdhistor = 47 THEN
                    DO:
                       /* Limpar leitura da craplot anterior */
                       FIND CURRENT craplot NO-LOCK NO-ERROR.                        
                       RELEASE craplot.
                       
                       /* Desconto */
                       FOR LAST crapcdb FIELDS(nrdconta nrcheque cdbanchq  cdagechq nrctachq) 
                                         WHERE crapcdb.cdcooper = aux_cdcooper
                                           AND crapcdb.cdcmpchq = crapfdc.cdcmpchq
                                           AND crapcdb.cdbanchq = crapfdc.cdbanchq
                                           AND crapcdb.cdagechq = crapfdc.cdagechq                                          
                                           AND crapcdb.nrctachq = crapfdc.nrctachq
                                           AND crapcdb.nrcheque = crapfdc.nrcheque
                                           AND CAN-DO("0,2",STRING(crapcdb.insitchq))
                                           NO-LOCK:
                       END.                        
                       
                       IF  AVAILABLE crapcdb THEN          
                           DO:                               
                               /* criar lancamento com o historico 399 e historico 10119 */
                               DO  WHILE TRUE:
                        
                                   FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                                      craplot.dtmvtolt = par_dtmvtolt AND
                                                      craplot.cdagenci = aux_cdagenci AND
                                                      craplot.cdbccxlt = aux_cdbccxlt AND
                                                      craplot.nrdolote = 10119
                                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                   IF   NOT AVAILABLE craplot   THEN
                                        IF   LOCKED craplot   THEN
                                             DO:
                                                 PAUSE 1 NO-MESSAGE.
                                                 NEXT.
                                             END.
                                        ELSE
                                             DO:
                                                 CREATE craplot.
                                                 ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                                        craplot.cdagenci = aux_cdagenci
                                                        craplot.cdbccxlt = aux_cdbccxlt
                                                        craplot.tplotmov = 1
                                                        craplot.cdcooper = aux_cdcooper
                                                        craplot.nrdolote = 10119.                                                 
                                             END.                   
                                  LEAVE.
                               END.
                               
                               CREATE craplcm.
                               ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                                      craplcm.cdagenci = craplot.cdagenci
                                      craplcm.cdbccxlt = craplot.cdbccxlt
                                      craplcm.nrdolote = craplot.nrdolote
                                      craplcm.nrdconta = crapcdb.nrdconta
                                      craplcm.nrdctabb = aux_nrctalcm
                                      craplcm.nrdocmto = crapcdb.nrcheque
                                      craplcm.cdhistor = 399
                                      craplcm.nrseqdig = craplot.nrseqdig + 1
                                      craplcm.vllanmto = crapdev.vllanmto
                                      craplcm.cdoperad = crapdev.cdoperad
                                      craplcm.cdpesqbb = IF   crapdev.cdalinea <> 0 THEN
                                                              STRING(crapdev.cdalinea)
                                                         ELSE "21"
                                      craplcm.cdcooper = crapcdb.cdcooper
                                      craplcm.cdbanchq = crapcdb.cdbanchq
                                      craplcm.cdagechq = crapcdb.cdagechq
                                      craplcm.nrctachq = crapcdb.nrctachq
                                      craplcm.hrtransa = TIME
                                      
                                      craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                                      craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                                      craplot.qtinfoln = craplot.qtinfoln + 1
                                      craplot.qtcompln = craplot.qtcompln + 1
                                      craplot.nrseqdig = craplot.nrseqdig + 1 NO-ERROR.

                               VALIDATE craplot.
                               VALIDATE craplcm.
                           END.
                       ELSE /* nao encontrou crapcdb */
                           DO:
                              /* Custodia */
                              FOR LAST crapcst FIELDS(nrdconta nrcheque cdbanchq  cdagechq nrctachq) 
                                                WHERE crapcst.cdcooper = aux_cdcooper
                                                  AND crapcst.cdcmpchq = crapfdc.cdcmpchq
                                                  AND crapcst.cdbanchq = crapfdc.cdbanchq
                                                  AND crapcst.cdagechq = crapfdc.cdagechq
                                                  AND crapcst.nrctachq = crapfdc.nrctachq
                                                  AND crapcst.nrcheque = crapfdc.nrcheque
                                                  AND CAN-DO("0,2",STRING(crapcdb.insitchq))
                                                  NO-LOCK:
                              END.
                        
                              IF  AVAILABLE crapcst THEN
                                  DO:
                                      /* criar lancamento com o historico 399 e historico 10119 */
                                      DO  WHILE TRUE:
                                
                                          FIND craplot WHERE craplot.cdcooper = aux_cdcooper AND
                                                             craplot.dtmvtolt = par_dtmvtolt AND
                                                             craplot.cdagenci = aux_cdagenci AND
                                                             craplot.cdbccxlt = aux_cdbccxlt AND
                                                             craplot.nrdolote = 10119
                                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                                          IF   NOT AVAILABLE craplot   THEN
                                               IF   LOCKED craplot   THEN
                                                    DO:
                                                        PAUSE 1 NO-MESSAGE.
                                                        NEXT.
                                                    END.
                                               ELSE
                                                    DO:
                                                        CREATE craplot.
                                                        ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                                               craplot.cdagenci = aux_cdagenci
                                                               craplot.cdbccxlt = aux_cdbccxlt
                                                               craplot.tplotmov = 1
                                                               craplot.cdcooper = aux_cdcooper
                                                               craplot.nrdolote = 10119.                                                        
                                                    END.                   
                                         LEAVE.
                                      END.
                                      
                                      CREATE craplcm.
                                      ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                                             craplcm.cdagenci = craplot.cdagenci
                                             craplcm.cdbccxlt = craplot.cdbccxlt
                                             craplcm.nrdolote = craplot.nrdolote
                                             craplcm.nrdconta = crapcst.nrdconta
                                             craplcm.nrdctabb = aux_nrctalcm
                                             craplcm.nrdocmto = crapcst.nrcheque
                                             craplcm.cdhistor = 399
                                             craplcm.nrseqdig = craplot.nrseqdig + 1
                                             craplcm.vllanmto = crapdev.vllanmto
                                             craplcm.cdoperad = crapdev.cdoperad
                                             craplcm.cdpesqbb = IF   crapdev.cdalinea <> 0 THEN
                                                                     STRING(crapdev.cdalinea)
                                                                ELSE "21"
                                             craplcm.cdcooper = crapcst.cdcooper
                                             craplcm.cdbanchq = crapcst.cdbanchq
                                             craplcm.cdagechq = crapcst.cdagechq
                                             craplcm.nrctachq = crapcst.nrctachq
                                             craplcm.hrtransa = TIME
                                             
                                             craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                                             craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto
                                             craplot.qtinfoln = craplot.qtinfoln + 1
                                             craplot.qtcompln = craplot.qtcompln + 1
                                             craplot.nrseqdig = craplot.nrseqdig + 1 NO-ERROR.
                                    
                                      VALIDATE craplot.
                                      VALIDATE craplcm.
                                  END.
                           END.
                    END. /* Fim do historico 47 */
        END.
        ELSE /*  taxa de devolucao de cheque  */
        IF  crapdev.cdhistor = 46  AND
            crapass.inpessoa <> 3 THEN DO:
            
            IF (aux_cdtarifa = "DEVOLCHQPF"  OR 
                aux_cdtarifa = "DEVOLCHQPJ") AND 
                aux_vltarifa > 0             THEN DO:
               
               RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                       (INPUT aux_cdcooper,
                                        INPUT aux_nrdconta, 
                                        INPUT par_dtmvtolt,
                                        INPUT aux_cdhistor, 
                                        INPUT aux_vltarifa,
                                        INPUT crapdev.cdoperad,
                                        INPUT 1, /*cdagenci*/
                                        INPUT 100, /* par_cdbccxlt */
                                        INPUT 8452, /*par_nrdolote */
                                        INPUT 1,   /* par_tpdolote */
                                        INPUT crapdev.nrcheque,
                                        INPUT crapdev.nrdctabb,
                                        INPUT crapdev.nrdctitg,
                                        INPUT "",  /*par_cdpesqbb*/
                                        INPUT crapdev.cdbanchq,   
                                        INPUT crapdev.cdagechq,   
                                        INPUT crapdev.nrctachq,   
                                        INPUT FALSE, /*par_flgaviso*/
                                        INPUT 0,  /*par_tpaviso*/
                                        INPUT aux_cdfvlcop,
                                        INPUT par_inproces,
                                        OUTPUT TABLE tt-erro).
                            
                IF  RETURN-VALUE = "NOK"  THEN DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF AVAIL tt-erro THEN
                       UNIX SILENT VALUE("echo " + 
                                 STRING(TIME,"HH:MM:SS") + 
                                 " - Coop:" + STRING(par_cdcooper,"99")       + 
                                 " - Processar:" + par_cdprogra + "' --> '"   + 
                                 " Ref: " + STRING(par_dtmvtolt,"99/99/9999") + 
                                 tt-erro.dscritic + 
                                 " >> log/proc_batch.log").

                    IF  VALID-HANDLE(h-b1wgen0153) THEN
                        DELETE OBJECT h-b1wgen0153.

                    UNDO TRANS_1, RETURN "NOK".
                END.
            END.

            /* Cria lancamento para tarifa dev cheque- Taxa BACEN*/     
            IF (aux_cdtarbac = "DEVCHQBCPJ"  OR 
                aux_cdtarbac = "DEVCHQBCPF") AND 
                aux_vltarbac > 0             THEN DO:

                RUN cria_lan_auto_tarifa IN h-b1wgen0153
                                        (INPUT par_cdcooper,
                                         INPUT aux_nrdconta, 
                                         INPUT par_dtmvtolt,
                                         INPUT aux_cdhisbac, 
                                         INPUT aux_vltarbac,
                                         INPUT crapdev.cdoperad,
                                         INPUT 1, /*cdagenci*/
                                         INPUT 100, /* par_cdbccxlt */
                                         INPUT 8452, /*par_nrdolote */
                                         INPUT 1,   /* par_tpdolote */
                                         INPUT crapdev.nrcheque, /*nrdocmto*/
                                         INPUT crapdev.nrdctabb,
                                         INPUT crapdev.nrdctitg,
                                         INPUT "Fato gerador tarifa:" + STRING(crapdev.nrcheque),  /*par_cdpesqbb*/
                                         INPUT crapdev.cdbanchq,   
                                         INPUT crapdev.cdagechq,   
                                         INPUT crapdev.nrctachq,   
                                         INPUT FALSE, /*par_flgaviso*/
                                         INPUT 0,  /*par_tpaviso*/
                                         INPUT aux_cdfvlbac,
                                         INPUT par_inproces,
                                         OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE = "NOK" THEN 
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAIL tt-erro THEN 
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")   + 
                                 " - Coop:" + STRING(par_cdcooper,"99")       + 
                                 " - Processar:" + par_cdprogra + "' --> '"   + 
                                 " Ref: " + STRING(par_dtmvtolt,"99/99/9999") + 
                                 tt-erro.dscritic                             + 
                                 " >> log/proc_batch.log").

                    IF  VALID-HANDLE(h-b1wgen0153) THEN
                        DELETE OBJECT h-b1wgen0153.

                    UNDO TRANS_1, RETURN "NOK".
                END.
            END. /* Fim do IF taxa bacen*/

        END. /* Fim do ELSE IF */

        ASSIGN crapdev.insitdev = 1 /* 1 = devolvido */
               crapdev.indctitg = IF  par_cddevolu = 3 THEN /* CONTA ITG */
                                      TRUE
                                  ELSE FALSE.
                                  
        IF  crapdev.cdpesqui = "TCO" THEN
            ASSIGN aux_cdcooper = par_cdcooper
                   aux_nrdconta = crapdev.nrdconta.
        
    END.  /*  Fim do FOR EACH e da transacao  */
    
    IF  VALID-HANDLE(h-b1wgen0153) THEN
        DELETE OBJECT h-b1wgen0153.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_impressao:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR FORMAT "X(10)"                NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crawdev FOR crapdev.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR        FORMAT "x(40)"                 NO-UNDO.
    DEF VAR aux_tprelato AS INTE                                       NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR    FORMAT "x(6)"                      NO-UNDO.
    DEF VAR aux_nmdbanco AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmdircop AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM SKIP(3)
         aux_nmcidade    FORMAT "x(14)" "," 
         par_dtmvtolt    FORMAT "99/99/9999"
         "."  
         SKIP(1)
         "Ao" SKIP
         aux_nmdbanco    FORMAT "x(20)"
         SKIP(3)
         "Solicitamos devolucao dos cheques do dia"
         par_dtmvtoan FORMAT "99/99/9999"
         "abaixo relacionados."
         SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_brasil.
    
    FORM "Banco  Age. Cta. Cheque    Cheque         Valor Alinea Titular(es)"
         SKIP
         "CPF/CNPJ/CONTA/PESQUISA"                  AT 56
         SKIP
         "----------------------------------------" AT 1
         "----------------------------------------" AT 41
         WITH NO-BOX NO-LABELS FRAME f_cabecalho.
       
    FORM crapdev.cdbanchq  FORMAT "z,zz9"          AT 01   NO-LABEL
         crapdev.cdagechq  FORMAT "z,zz9"          AT 07   NO-LABEL
         aux_nrdctitg      FORMAT "9.999.999-X"    AT 13   NO-LABEL
         crapdev.nrcheque  FORMAT "zzz,zz9,9"      AT 25   NO-LABEL
         crapdev.vllanmto  FORMAT "zz,zzz,zz9.99"  AT 35   NO-LABEL
         crapdev.cdalinea  FORMAT "z9"             AT 51   NO-LABEL
         crapass.nmprimtl  FORMAT "x(25)"          AT 56   NO-LABEL 
         SKIP
         rel_nrcpfcgc      FORMAT "x(18)"          AT 56   NO-LABEL
         crapdev.nrdconta  FORMAT "zzzz,zzz,9"     AT 75   NO-LABEL
         SKIP
         crapdev.cdpesqui  FORMAT "x(55)"          AT 56   NO-LABEL
         WITH NO-BOX WIDTH 132 NO-LABELS DOWN FRAME f_lanctos.
 
    FORM SKIP(3)
         "  TOTAL   "
         rel_qtchqdev 
         rel_vlchqdev
         SKIP(2)
         "  Atenciosamente"
         SKIP(2)
         aux_nmrescop[1] FORMAT "x(40)"
         SKIP
         aux_nmrescop[2] FORMAT "x(40)"
         WITH NO-BOX NO-LABELS FRAME f_fim.
     
    FORM SKIP(3)
         "  TOTAL   "
         rel_qtchqdev 
         rel_vlchqdev
         WITH NO-BOX NO-LABELS FRAME f_fim_resumido.
    
    FORM "Relacao dos cheques devolvidos no dia" AT 20
         par_dtmvtolt  NO-LABEL FORMAT "99/99/9999"
         SKIP(2)
         WITH NO-LABELS FRAME f_relacao.

    FORM crapass.nrdconta LABEL "Conta/dv"
         crapass.nmprimtl LABEL "Titular"       FORMAT "x(40)" 
         craptip.dstipcta LABEL "Tipo de conta" 
         crapdev.nrctachq LABEL "Conta Cheque"  FORMAT "zzzz,zz9,9"
         crapdev.nrcheque LABEL "Cheque"        FORMAT "zzz,zz9,9"
         crapdev.vllanmto LABEL "Valor"         FORMAT "zzzz,zz9.99"
         crapdev.cdalinea LABEL "Al"            FORMAT "z9"
         crapass.cdagenci LABEL "Pa"            FORMAT "zz9"
         crapope.nmoperad LABEL "Operador"      FORMAT "x(20)"
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_todos.

    /*** Busca dados da cooperativa ***/
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                          " - Coop:" + STRING(par_cdcooper,"99") +
                          " - Processar:" + par_cdprogra + "'-->'" +
                          aux_dscritic + " >> log/proc_batch.log").
        
        RETURN "NOK".
    END.    

    ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop 
           aux_nmcidade = TRIM(crapcop.nmcidade)
           aux_nmarquiv = aux_nmdircop + "/rl/crrl219_" + STRING(par_cddevolu,"9") + ".lst".

    CASE par_cddevolu:
         /*  BANCOOB  */
         WHEN 1 THEN aux_nmarqdev = "devolu_bancoob.txt".

         /*  CONTA BASE  */
         WHEN 2 THEN aux_nmarqdev = "devolu_base.txt".

         /*  CONTA INTEGRACAO  */
         WHEN 3 THEN aux_nmarqdev = "devolu_itg.txt".
    END CASE.     

    OUTPUT STREAM str_1 TO VALUE(aux_nmarquiv) PAGED PAGE-SIZE 84.

    /* Cdempres = 11 , Relatorio 219 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "219" "132" }

    /* Relacao para o envio ao Banco do Brasil (sem Desconto e Custodia) */
    
    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.cdbanchq = par_cdbanchq
                       AND crapdev.insitdev = 1
                       AND crapdev.cdhistor <> 46
                       AND crapdev.cdalinea > 0
                       AND crapdev.cdpesqui = "" NO-LOCK,
        EACH crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.nrdconta = crapdev.nrdconta
                       AND ((par_cddevolu = 1)
                        OR (par_cddevolu  = 2
                       AND crapass.nrdctitg <> crapdev.nrdctitg)
                        OR (par_cddevolu  = 3
                       AND crapass.nrdctitg = crapdev.nrdctitg))
                       NO-LOCK BREAK BY crapdev.cdbccxlt
                                     BY crapdev.nrdctabb
                                     BY crapdev.nrcheque:

        HIDE MESSAGE NO-PAUSE.

        ASSIGN aux_contador = aux_contador + 1.

        MESSAGE "Gerando Relatorio: " + STRING(aux_contador) + " ...".

        IF  FIRST-OF(crapdev.cdbccxlt) OR 
            LINE-COUNTER(str_1) > 80   THEN DO:
            
            IF  FIRST-OF(crapdev.cdbccxlt) THEN
                ASSIGN rel_qtchqdev = 0
                       rel_vlchqdev = 0.

                CASE par_cddevolu:
                      WHEN 1 THEN aux_nmdbanco = "BANCOOB".
                      OTHERWISE   aux_nmdbanco = "BANCO DO BRASIL".
                  END CASE.

                  DISPLAY STREAM str_1 aux_nmcidade par_dtmvtolt
                                       aux_nmdbanco par_dtmvtoan  
                                       WITH FRAME f_brasil.

                  VIEW STREAM str_1 FRAME f_cabecalho.
        END.

        IF  par_cddevolu = 2       AND    /*  CONTA BASE  */
            crapdev.cdhistor =  47 AND        
            crapdev.dtmvtolt <> par_dtmvtolt   THEN
            NEXT.

        IF  crapass.inpessoa = 1 THEN
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
             
        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.
          
        IF  par_cddevolu = 3 THEN /*  CONTA INTEGRACAO  */
            DISPLAY STREAM str_1  
                    crapdev.cdbanchq   crapdev.cdagechq
                    crapdev.nrdctitg @ aux_nrdctitg
                    crapdev.nrcheque   crapdev.vllanmto   
                    crapdev.cdalinea   crapass.nmprimtl   
                    crapdev.nrdconta   rel_nrcpfcgc
                    WITH FRAME f_lanctos.
        ELSE DO:    /*  CONTA BASE  OU  BANCOOB  */ 
    
            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.

            RUN dig_bbx IN h-b1wgen9998 (INPUT par_cdcooper,
                                         INPUT 0, /*par_cdagenci,*/
                                         INPUT 0, /*par_nrdcaixa,*/
                                         INPUT crapass.nrdconta,
                                         OUTPUT aux_dsdctitg,
                                         OUTPUT TABLE tt-erro).

            DISPLAY STREAM str_1
                    crapdev.cdbanchq   crapdev.cdagechq
                    aux_dsdctitg       crapdev.nrcheque
                    crapdev.vllanmto   crapdev.cdalinea
                    crapass.nmprimtl WHEN
                    (CAN-DO("12,13",STRING(crapdev.cdalinea))
                 OR (crapdev.cdalinea = 11
                AND crapdev.cdbccxlt = 756)
                 OR (crapdev.cdalinea = 11
                AND crapdev.cdbccxlt = crapcop.cdbcoctl))
                    rel_nrcpfcgc     WHEN 
                    (CAN-DO("12,13",STRING(crapdev.cdalinea))
                 OR (crapdev.cdalinea = 11
                AND crapdev.cdbccxlt = 756)
                 OR (crapdev.cdalinea = 11
                AND crapdev.cdbccxlt = crapcop.cdbcoctl))
                WITH FRAME f_lanctos.
            
            IF  VALID-HANDLE(h-b1wgen9998)  THEN
                DELETE PROCEDURE h-b1wgen9998.
        END.        

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF  LAST-OF(crapdev.cdbccxlt) THEN 
        DO:
            /* Rotina p/ dividir campo crapcop.nmextcop em duas Strings */

            ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ")
                                  / 2
                   aux_nmrescop = "".

            DO  aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):

                IF  aux_contapal <= aux_qtpalavr   THEN
                    aux_nmrescop[1] = aux_nmrescop[1] +
                                      (IF TRIM(aux_nmrescop[1]) = "" THEN
                                          ""
                                       ELSE " ") +
                                       ENTRY(aux_contapal,crapcop.nmextcop," ").
                ELSE
                    aux_nmrescop[2] = aux_nmrescop[2] +
                                      (IF TRIM(aux_nmrescop[2]) = "" THEN
                                          ""
                                       ELSE " ") +
                                       ENTRY(aux_contapal,crapcop.nmextcop," ").
            END.  /*  Fim DO .. TO  */ 

            ASSIGN aux_nmrescop[1] = FILL(" ",20 - 
                                             INT(LENGTH(aux_nmrescop[1]) / 2)) +
                                             aux_nmrescop[1]
                   aux_nmrescop[2] = FILL(" ",20 - 
                                             INT(LENGTH(aux_nmrescop[2]) / 2)) +
                                             aux_nmrescop[2].
            /*  Fim da Rotina  */

            DISPLAY STREAM str_1 rel_qtchqdev rel_vlchqdev aux_nmrescop
                      WITH FRAME f_fim.

            PAGE STREAM str_1.
        END.

    END.  /** Fim do FOR EACH crapdev **/

    /*  Relacao somente para Desconto de Cheques e Custodia  */
    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.cdbanchq = par_cdbanchq
                       AND crapdev.insitdev = 1
                       AND crapdev.cdhistor <> 46
                       AND crapdev.cdalinea > 0
                       AND (crapdev.cdpesqui <> ""
                       AND crapdev.cdpesqui <> "TCO") NO-LOCK,
        EACH crapass WHERE crapass.cdcooper = par_cdcooper        
                       AND crapass.nrdconta = crapdev.nrdconta  
                       AND ((par_cddevolu = 1)                      
                        OR  (par_cddevolu = 2                       
                       AND crapass.nrdctitg <> crapdev.nrdctitg)
                        OR (par_cddevolu = 3                       
                       AND crapass.nrdctitg = crapdev.nrdctitg))
                       NO-LOCK BREAK BY crapdev.cdbccxlt
                                     BY crapdev.nrdctabb
                                     BY crapdev.nrcheque:

        IF   FIRST-OF(crapdev.cdbccxlt) OR 
             LINE-COUNTER(str_1) > 80   THEN
             DO:
                  IF  FIRST-OF(crapdev.cdbccxlt) THEN
                      ASSIGN rel_qtchqdev = 0
                             rel_vlchqdev = 0.

                  IF  par_cddevolu = 1 THEN
                       aux_nmdbanco = "BANCOOB".
                  ELSE
                       aux_nmdbanco = "BANCO DO BRASIL".

                  DISPLAY STREAM str_1 aux_nmcidade par_dtmvtolt
                                       aux_nmdbanco par_dtmvtoan  
                                       WITH FRAME f_brasil.

                  VIEW STREAM str_1 FRAME f_cabecalho.
             END.

        IF   par_cddevolu = 2                   AND    /*  CONTA BASE  */
             crapdev.cdhistor =  47             AND        
             crapdev.dtmvtolt <> par_dtmvtolt   THEN
             NEXT.

        IF   crapass.inpessoa = 1 THEN
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.

        IF   par_cddevolu = 3 THEN       /*  CONTA INTEGRACAO  */
             DISPLAY STREAM str_1  
                     crapdev.cdbanchq   crapdev.cdagechq
                     crapdev.nrdctitg @ aux_nrdctitg
                     crapdev.nrcheque   crapdev.vllanmto   
                     crapdev.cdalinea   crapass.nmprimtl   
                     crapdev.nrdconta   rel_nrcpfcgc
                     crapdev.cdpesqui   WITH FRAME f_lanctos.
        ELSE 
            DO: /*  CONTA BASE, BANCOOB E CECRED  */

            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.

            RUN dig_bbx IN h-b1wgen9998 (INPUT par_cdcooper,
                                         INPUT 0, /*par_cdagenci,*/
                                         INPUT 0, /*par_nrdcaixa,*/
                                         INPUT crapass.nrdconta,
                                         OUTPUT aux_dsdctitg,
                                         OUTPUT TABLE tt-erro).

            DISPLAY STREAM str_1  
                    crapdev.cdbanchq   crapdev.cdagechq
                    aux_nrdctitg       crapdev.nrcheque
                    crapdev.vllanmto   crapdev.cdalinea
                    crapass.nmprimtl WHEN (CAN-DO("12,13",STRING(crapdev.cdalinea))  
                                       OR (crapdev.cdalinea = 11                     
                                      AND  crapdev.cdbccxlt = 756)                  
                                       OR (crapdev.cdalinea = 11                     
                                      AND  crapdev.cdbccxlt = crapcop.cdbcoctl))
                     rel_nrcpfcgc WHEN 
                                    (CAN-DO("12,13",STRING(crapdev.cdalinea)) OR
                                    (crapdev.cdalinea = 11 AND 
                                     crapdev.cdbccxlt = 756)                  OR
                                    (crapdev.cdalinea = 11    AND 
                                     crapdev.cdbccxlt = crapcop.cdbcoctl))
                                     crapdev.cdpesqui
                                     WITH FRAME f_lanctos.

            IF  VALID-HANDLE(h-b1wgen9998)  THEN
                DELETE PROCEDURE h-b1wgen9998.
        END.        

        DOWN STREAM str_1 WITH FRAME f_lanctos.

        IF  LAST-OF(crapdev.cdbccxlt) THEN DO:
            DISPLAY STREAM str_1 rel_qtchqdev rel_vlchqdev aux_nmrescop
                      WITH FRAME f_fim.

            PAGE STREAM str_1.
        END.

    END.  /** Fim do FOR EACH crapdev **/

    DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_relacao.

    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.cdbanchq = par_cdbanchq
                       AND crapdev.insitdev = 1
                       AND crapdev.cdhistor <> 46
                       AND crapdev.cdalinea > 0
                       AND crapdev.cdpesqui <> "TCO" NO-LOCK, 
        EACH crapass WHERE crapass.cdcooper = par_cdcooper          
                       AND crapass.nrdconta = crapdev.nrdconta    
                       AND ((par_cddevolu = 1)                        
                        OR  (par_cddevolu = 2                         
                       AND crapass.nrdctitg <> crapdev.nrdctitg)  
                        OR (par_cddevolu = 3                         
                       AND  crapass.nrdctitg = crapdev.nrdctitg))  NO-LOCK,
        EACH crapope WHERE crapope.cdcooper = par_cdcooper
                       AND crapope.cdoperad = crapdev.cdoperad     NO-LOCK,
        EACH craptip WHERE craptip.cdcooper = par_cdcooper
                       AND craptip.cdtipcta = crapass.cdtipcta     
                       NO-LOCK BREAK BY crapdev.cdbccxlt
                                     BY crapdev.nrdctabb
                                     BY crapdev.nrcheque:

        IF  LINE-COUNTER(str_1) > 80 THEN DO:
            PAGE STREAM str_1.
            DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_relacao.
        END.    

        IF   FIRST-OF(crapdev.cdbccxlt) THEN
             ASSIGN rel_qtchqdev = 0
                    rel_vlchqdev = 0.

        DISPLAY STREAM str_1 crapass.nrdconta  crapass.nmprimtl
                             craptip.dstipcta  crapdev.nrctachq
                             crapdev.nrcheque  crapdev.vllanmto
                             crapdev.cdalinea  crapass.cdagenci
                             crapope.nmoperad  WITH FRAME f_todos.
        DOWN STREAM str_1 WITH FRAME f_todos.

        ASSIGN rel_qtchqdev = rel_qtchqdev + 1
               rel_vlchqdev = rel_vlchqdev + crapdev.vllanmto.

        IF  LAST-OF(crapdev.cdbccxlt) THEN DO:
            DISPLAY STREAM str_1
                           rel_qtchqdev
                           rel_vlchqdev
                           aux_nmrescop
                      WITH FRAME f_fim_resumido.
       
            PAGE STREAM str_1.
        END.
    END.                          

    OUTPUT STREAM str_1 CLOSE.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    /*  Salvar copia relatorio para "/rlnsv"  */
    UNIX SILENT VALUE("cp " + aux_nmarquiv + " " +
                      aux_nmdircop + "/rlnsv").

    UNIX SILENT VALUE("ux2dos " + aux_nmarquiv + " > /micros/" + 
                      crapcop.dsdircop + "/devolu/" + aux_nmarqdev).
    
    /* Gerar log da copia de arquivos */
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                      " Cooperativa: " + STRING(par_cdcooper) +
                      " Executado os comandos: " + 
                      " Copiar arquivo " + aux_nmarquiv + " para  rlnsv " +
                      " e UX2DOS " + aux_nmarquiv + " para /micros/" + 
                      crapcop.dsdircop + "/devolu/" + aux_nmarqdev +
                      " >> log/proc_batch.log").

    ASSIGN aux_tprelato = 0
           aux_nmrelato = " ".

    FIND craprel WHERE craprel.cdcooper = par_cdcooper
                   AND craprel.cdrelato = 219
                       NO-LOCK NO-ERROR.

    IF  AVAIL craprel  THEN DO:
        IF  craprel.tprelato = 2   THEN
            ASSIGN aux_tprelato = 1.

            ASSIGN aux_nmrelato = craprel.nmrelato.
    END.

    ASSIGN aux_cdrelato = SUBSTR(aux_nmarquiv,
                          R-INDEX(aux_nmarquiv,"/") + 1)
           aux_nmarqtmp = aux_nmdircop + "/tmppdf/" + aux_cdrelato + ".txt"
           aux_nmarqpdf = SUBSTR(aux_cdrelato,1,
                                 LENGTH(aux_cdrelato) - 4) + ".pdf".

    OUTPUT STREAM str_2 TO VALUE (aux_nmarqtmp).

    PUT STREAM str_2 crapcop.nmrescop FORMAT "X(20)"                  ";"
                     STRING(YEAR(par_dtmvtolt),"9999") FORMAT "x(04)" ";"
                     STRING(MONTH(par_dtmvtolt),"99")  FORMAT "x(02)" ";"
                     STRING(DAY(par_dtmvtolt),"99")    FORMAT "x(02)" ";"
                     STRING(aux_tprelato,"z9")         FORMAT "x(02)" ";"
                     aux_nmarqpdf                                     ";"
                     CAPS(aux_nmrelato)                FORMAT "x(50)" ";"
                     SKIP.

    OUTPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("echo script/CriaPDF.sh " + aux_nmarquiv + " NAO 132col " +
                      STRING(YEAR(par_dtmvtolt),"9999") + "_" + 
                      STRING(MONTH(par_dtmvtolt),"99") + "/" + 
                      STRING(DAY(par_dtmvtolt),"99")
                      + " >> " + aux_nmdircop + "/log/CriaPDF.log").
    
    UNIX SILENT VALUE(aux_nmdircop + "/script/CriaPDF.sh "
                     + aux_nmarquiv + " NAO 132col "
                     + STRING(YEAR(par_dtmvtolt),"9999") + "_"
                     + STRING(MONTH(par_dtmvtolt),"99") + "/"
                     + STRING(DAY(par_dtmvtolt),"99")).

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_arquivo_ctaitg:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR FORMAT "X(10)"                NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crawdev FOR crapdev.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_tprelato AS INTE                                       NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR    FORMAT "x(6)"                      NO-UNDO.
    DEF VAR aux_nmdbanco AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdseqarq AS INTE                                       NO-UNDO.
    DEF VAR aux_cdseqchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqdat AS CHAR                                       NO-UNDO.
    DEF VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                       NO-UNDO.
    DEF VAR aux_nmdircop AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN
        ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop 
               aux_nmarqlog = aux_nmdircop + "/log/" + 
                              "prcitg_" + STRING(YEAR(par_dtmvtolt),"9999") +
                              STRING(MONTH(par_dtmvtolt),"99") + 
                              STRING(DAY(par_dtmvtolt),"99") + ".log".

    FIND craptab WHERE craptab.cdcooper = par_cdcooper    
                   AND craptab.nmsistem = "CRED"        
                   AND craptab.tptabela = "GENERI"      
                   AND craptab.cdempres = 00            
                   AND craptab.cdacesso = "NRARQMVITG"  
                   AND craptab.tpregist = 407
                   NO-LOCK NO-ERROR.

    IF  NOT AVAIL craptab   THEN DO:
        ASSIGN aux_cdcritic = 393
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                          " - Coop:" + STRING(par_cdcooper,"99") +
                          " - Processar:" + par_cdprogra + "'-->'" +
                          aux_dscritic + " >> " + aux_nmarqlog).
        RETURN "NOK".
    END.

    IF  INT(SUBSTR(craptab.dstextab,07,01)) = 1 THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "PROGRAMA BLOQUEADO PARA ENVIAR ARQUIVOS".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                          " - Coop:" + STRING(par_cdcooper,"99") +
                          " - Processar:" + par_cdprogra + "'-->'" +
                          aux_dscritic + " >> " + aux_nmarqlog).
        RETURN "NOK".
    END.

    ASSIGN aux_cdseqarq = INTEGER(SUBSTR(craptab.dstextab,01,05))
           aux_flgfirst = TRUE
           aux_dtmovime = STRING(DAY(par_dtmvtolt),"99") +
                          STRING(MONTH(par_dtmvtolt),"99") +
                          STRING(YEAR(par_dtmvtolt),"9999").

    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.cdhistor <> 46        
                       AND crapdev.insitdev = 1         
                       AND crapdev.indctitg = TRUE      
                       AND crapdev.cdalinea > 0         
                       AND crapdev.cdbccxlt = 1         
                       AND crapdev.cdpesqui = ""
                       NO-LOCK BY crapdev.nrdctabb
                               BY crapdev.nrcheque:

        ASSIGN aux_contador = aux_contador + 1.

        IF  aux_flgfirst  THEN DO:
            ASSIGN aux_cdseqchq = 0
                   aux_nmarqdat = "coo407" +
                                  STRING(DAY(par_dtmvtolt),"99") + 
                                  STRING(MONTH(par_dtmvtolt),"99") +
                                  STRING(aux_cdseqarq,"99999") + ".rem".

            IF  SEARCH(aux_nmdircop + "/arq/" + aux_nmarqdat) <> ? THEN
                UNIX SILENT VALUE("rm " + aux_nmdircop + "/arq/" + aux_nmarqdat + 
                                  " 2>/dev/null").

            OUTPUT STREAM str_2 TO VALUE(aux_nmdircop + "/arq/" + aux_nmarqdat).

            /* ------------   Header do Arquivo   ------------  */

            PUT STREAM str_2 "0000000"
                             crapcop.cdageitg     FORMAT "9999"
                             crapcop.nrctaitg     FORMAT "99999999"
                             "COO407  "
                             aux_cdseqarq         FORMAT "99999"
                             aux_dtmovime         FORMAT "x(08)"
                             crapcop.cdcnvitg     FORMAT "999999999"
                             FILL(" ",21)         FORMAT "x(21)" 
                             SKIP.

            ASSIGN aux_flgfirst = FALSE.

        END.  /*  Fim  do  aux_flgfirst  */

        /*  limite maximo de registros  */

        IF  aux_cdseqchq > 1998 THEN DO:

            /* ------------   Trailer do Arquivo   ------------  */
            PUT STREAM str_2 "9999999"
                             (aux_cdseqchq + 2)    FORMAT "999999999"
                             FILL(" ",54)          FORMAT "x(54)" 
                             SKIP.

            OUTPUT STREAM str_2 CLOSE.

            FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                                  NO-LOCK NO-ERROR.

            ASSIGN aux_cdcritic = 847
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                              " - Coop:" + STRING(par_cdcooper,"99") +
                              " - Processar:" + par_cdprogra + "'-->'" +
                              aux_dscritic + "  " + aux_nmarqdat +
                              " >> " + aux_nmarqlog).

            UNIX SILENT VALUE("ux2dos < " + aux_nmdircop + "/arq/"
                             + aux_nmarqdat + ' | tr -d "\032"' + " > /micros/"
                             + crapcop.dsdircop + "/compel/" + aux_nmarqdat +
                             " 2>/dev/null").

            UNIX SILENT VALUE("mv " + aux_nmdircop + "/arq/" +  aux_nmarqdat +
                              aux_nmdircop + "/salvar 2>/dev/null").

            ASSIGN aux_flgfirst = TRUE
                   aux_cdseqarq = aux_cdseqarq + 1.

            NEXT.
        END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.nrdconta = crapdev.nrdconta
                       NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass THEN DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                              " - Coop:" + STRING(par_cdcooper,"99") +
                              " - Processar:" + par_cdprogra + "'-->'" +
                              aux_dscritic + " " + aux_nmarqdat +
                              " >> " + aux_nmdircop + "log/proc_batch.log").   
            
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                              " - Coop:" + STRING(par_cdcooper,"99") +
                              " - Processar:" + par_cdprogra + "'-->'" +
                              aux_dscritic + "  " + aux_nmarqdat + " >> " +
                              aux_nmarqlog).

            NEXT.
        END.

        ASSIGN aux_cdseqchq = aux_cdseqchq + 1.

        ASSIGN aux_nrcalcul = INT(SUBSTR(STRING(crapdev.nrcheque,
                                               "9999999"),1,6)).

        PUT STREAM str_2
            aux_cdseqchq              FORMAT "99999"
            "01"
            crapass.nrdctitg          FORMAT "9999999X"
            "01"                   /* Incluir a Devolucao */
            aux_nrcalcul              FORMAT "999999"
            (crapdev.vllanmto * 100)  FORMAT "99999999999999999"
            crapdev.cdalinea          FORMAT "9999"
            crapdev.nrdconta          FORMAT "99999999"
            FILL(" ",18)              FORMAT "x(18)" 
            SKIP.

    END. /* Fim do FOR EACH crapdev */

    IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
        RETURN "NOK".

    IF  NOT aux_flgfirst THEN DO: /*  gerou algum arquivo  */
        
        /* ------------   Trailer do Arquivo   ------------  */

        PUT STREAM str_2 "9999999"
                         (aux_cdseqchq + 2)    FORMAT "999999999"
                         FILL(" ",54)          FORMAT "x(54)" 
                         SKIP.

        OUTPUT STREAM str_2 CLOSE.

        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                              NO-LOCK NO-ERROR.

        ASSIGN aux_cdcritic = 847
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                          " - Coop:" + STRING(par_cdcooper,"99") +
                          " - Processar:" + par_cdprogra + "'-->'" +
                          aux_dscritic + "  " + aux_nmarqdat +
                          " >> " + aux_nmarqlog).

        UNIX SILENT VALUE("ux2dos <" + aux_nmdircop + "/arq/" + aux_nmarqdat
                         + ' | tr -d "\032"' + " > /micros/"
                         + crapcop.dsdircop + "/compel/" + aux_nmarqdat
                         + " 2>/dev/null").

        UNIX SILENT VALUE("mv " + aux_nmdircop + "/arq/" +  aux_nmarqdat +
                          aux_nmdircop + "/salvar 2>/dev/null").
        
        DO  TRANSACTION ON ENDKEY UNDO, LEAVE:

            /*   Atualiza a sequencia da remessa  */
            DO  WHILE TRUE:
                FIND craptab WHERE craptab.cdcooper = par_cdcooper
                               AND craptab.nmsistem = "CRED"
                               AND craptab.tptabela = "GENERI"
                               AND craptab.cdempres = 00
                               AND craptab.cdacesso = "NRARQMVITG"
                               AND craptab.tpregist = 407
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE craptab   THEN
                    IF  LOCKED craptab   THEN DO:
                        ASSIGN aux_cdcritic = 77
                               aux_dscritic = "".
                        RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    LEAVE.
                    END.
                ELSE DO:
                    ASSIGN aux_cdcritic = 55
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    LEAVE.
                END.
                ELSE DO:
                    aux_cdcritic = 0.
                END.

                LEAVE.

            END.  /*  Fim do DO .. TO  */

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                          " - Coop:" + STRING(par_cdcooper,"99") +
                          " - Processar:" + par_cdprogra + "'-->'" +
                          aux_dscritic + " >> " + aux_nmarqlog).   
                
                RETURN "NOK".
            END.

            SUBSTR(craptab.dstextab,1,5) = STRING(aux_cdseqarq + 1, "99999").

        END. /*  Transaction  */

    END. /*  fim do aux_flgfirst  */

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_arquivo_bancoob:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crawdev FOR crapdev.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_tprelato AS INTE                                       NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR    FORMAT "x(6)"                      NO-UNDO.
    DEF VAR aux_nmdbanco AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdseqarq AS INTE                                       NO-UNDO.
    DEF VAR aux_cdseqchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqdat AS CHAR                                       NO-UNDO.
    DEF VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                       NO-UNDO.
    DEF VAR aux_linhadet AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                       NO-UNDO.
    DEF VAR aux_vldtotal AS DECI                                       NO-UNDO.
    DEF VAR aux_nmdircop AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    /* Busca descricao da Cooperativa */
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    IF  AVAIL crapcop THEN 
        ASSIGN aux_nmdircop = "/usr/coop/" + crapcop.dsdircop
               aux_dtmovime = STRING(YEAR(par_dtmvtolt),"9999") +
                              STRING(MONTH(par_dtmvtolt),"99") +
                              STRING(DAY(par_dtmvtolt),"99")
               aux_nmarquiv = "dev" + STRING(MONTH(par_dtmvtolt),"99") +
                              STRING(DAY(par_dtmvtolt),"99") + ".rem".
               aux_nmarqdev = aux_nmdircop + "/arq/" + 
                              "dev" + STRING(MONTH(par_dtmvtolt),"99") +
                              STRING(DAY(par_dtmvtolt),"99") + ".rem".
                         
    ASSIGN aux_nrsequen = 2
           aux_vldtotal = 0
           flg_devolbcb = FALSE.
   
    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.cdbanchq = 756
                       AND crapdev.insitdev = 1
                       AND crapdev.cdhistor <> 46
                       AND crapdev.cdalinea > 0
                       AND crapdev.cdpesqui = "" NO-LOCK,
        EACH crapass WHERE crapass.cdcooper = par_cdcooper
                       AND crapass.nrdconta = crapdev.nrdconta
                       NO-LOCK BREAK BY crapdev.nrctachq
                                     BY crapdev.nrcheque:

        FIND LAST craplcm WHERE craplcm.cdcooper = par_cdcooper
                            AND craplcm.nrdconta = crapdev.nrdconta
                            AND craplcm.nrdocmto = crapdev.nrcheque
                            AND craplcm.cdbccxlt = crapdev.cdbccxlt
                            AND craplcm.nrdctabb = crapdev.nrdctabb
                            AND CAN-DO("313,340,358,521,1873,1874",STRING(craplcm.cdhistor))
                            USE-INDEX craplcm2 NO-LOCK  NO-ERROR.

        ASSIGN aux_contador = aux_contador + 1.

        IF  AVAILABLE craplcm THEN DO:      
            IF flg_devolbcb = FALSE THEN DO:

                OUTPUT STREAM str_2 TO VALUE(aux_nmarqdev).

                PUT STREAM str_2 FILL("0",47)         FORMAT "x(47)"
                                      "CEL605"
                                      "452000175601"
                                      aux_dtmovime    FORMAT "x(08)"
                                      FILL(" ",77)    FORMAT "x(77)"
                                      "0000000001"
                                      SKIP.
                
                ASSIGN flg_devolbcb = TRUE.
            END.

            aux_linhadet = SUBSTR(craplcm.cdpesqbb,1,53)  + 
                           STRING(crapdev.cdalinea,"99")  + 
                           SUBSTR(craplcm.cdpesqbb,56,95) +
                           STRING(aux_nrsequen,"9999999999").

            PUT STREAM str_2 aux_linhadet FORMAT "x(160)".

            PUT STREAM str_2 SKIP.

            ASSIGN aux_nrsequen = aux_nrsequen + 1
                   aux_vldtotal = aux_vldtotal + crapdev.vllanmto.

        END.
    END. /* Fim do FOR EACH */

    IF  flg_devolbcb = TRUE THEN DO:
        PUT STREAM str_2 FILL("9",47)         FORMAT "x(47)"
                         "CEL605"
                         "452000175601"
                         aux_dtmovime         FORMAT "x(08)"
                         (aux_vldtotal * 100) FORMAT "99999999999999999"
                         FILL(" ",60)         FORMAT "x(60)"
                         aux_nrsequen         FORMAT "9999999999"
                         SKIP.

        OUTPUT STREAM str_2 CLOSE.

        UNIX SILENT VALUE("cp " + aux_nmarqdev + " " + aux_nmarquiv +
                          " 2> /dev/null").

        UNIX SILENT VALUE("mv " + aux_nmdircop + "/arq/" + aux_nmarquiv
                         + aux_nmdircop + "/salvar 2>/dev/null").

        UNIX SILENT VALUE("ux2dos " + aux_nmdircop + "/salvar/" + aux_nmarquiv
                         + " > /micros/" + aux_nmdircop + "/bancoob/"
                         + aux_nmarquiv).
    END.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE gera_arquivo_cecred:

    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtoan AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR FORMAT "X(10)"                NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cddevolu AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_valorvlb AS DECI                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crawdev FOR crapdev.
    
    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqtmp AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_nmrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdrelato AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR    FORMAT "x(40)"                     NO-UNDO.
    DEF VAR aux_dsdevolu AS CHAR    FORMAT "x(6)"                      NO-UNDO.
    DEF VAR aux_nmdbanco AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbanchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsdctitg AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdseqarq AS INTE                                       NO-UNDO.
    DEF VAR aux_cdseqchq AS INTE                                       NO-UNDO.
    DEF VAR aux_nmarqdat AS CHAR                                       NO-UNDO.
    DEF VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
    DEF VAR aux_nrcalcul AS DECI                                       NO-UNDO.
    DEF VAR aux_linhadet AS CHAR                                       NO-UNDO.
    DEF VAR aux_nrsequen AS INTE                                       NO-UNDO.
    DEF VAR aux_vldtotal AS DECI                                       NO-UNDO.
    DEF VAR aux_mes      AS CHAR                                       NO-UNDO.
    DEF VAR aux_extensao AS CHAR                                       NO-UNDO.
    DEF VAR aux_dscooper AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdcmpchq AS INTE                                       NO-UNDO.
    DEF VAR aux_dsorigem AS CHAR    FORMAT "x(13)"                     NO-UNDO.
    DEF VAR aux_totqtcax AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
    DEF VAR aux_totvlcax AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_totqtdiu AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
    DEF VAR aux_totvldiu AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_totqtnot AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
    DEF VAR aux_totvlnot AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_totqtdes AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
    DEF VAR aux_totvldes AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_totqtrej AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
    DEF VAR aux_totvlrej AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_totalqtd AS INTE    FORMAT "zzz,zz9"                   NO-UNDO.
    DEF VAR aux_totalvlr AS DECI    FORMAT "zzz,zzz,zzz,zz9.99"        NO-UNDO.
    DEF VAR aux_nmarqchq AS CHAR                                       NO-UNDO.
    DEF VAR aux_tprelato AS INTE                                       NO-UNDO.
    DEF VAR aux_dstipcta AS CHAR    FORMAT "x(15)"                     NO-UNDO.
    DEF VAR aux_indevarq AS INTE                                       NO-UNDO.
    DEF VAR aux_dssufarq AS CHAR                                       NO-UNDO.
    DEF VAR aux_cdbandep AS INTE                                       NO-UNDO.
    DEF VAR aux_cdagedep AS INTE                                       NO-UNDO.
    DEF VAR aux_cdtipdoc AS INTE                                       NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    DEF VAR aux_primeira AS LOGICAL                                    NO-UNDO.

    FORM "Relacao dos cheques 085 devolvidos no dia" AT 20
         par_dtmvtolt  NO-LABEL FORMAT "99/99/9999"
         SKIP(2)
         WITH NO-LABELS FRAME f_relacao.

    FORM "Conta/dv"       AT 01  
         "Titular"        AT 12 
         "Tipo de Conta"  AT 61
         "Cheque"         AT 80 
         "Valor"          AT 96 
         "Al"             AT 102 
         "Pa"             AT 106 
         "Operador"       AT 109
         "Origem"         AT 118
         SKIP          
         "Pesquisa"       AT 12
         SKIP
         "---------- ------------------------------------------------" AT 01
         "--------------- --------- -------------- -- --- --------"    AT 61
         "-------------"                                              AT 118
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_cabec.
         
    FORM tt-relchdv.nrdconta AT 001 FORMAT "zzzz,zzz,9"                     
         tt-relchdv.nmprimtl AT 012 FORMAT "x(48)"                          
         tt-relchdv.dstipcta AT 061 FORMAT "x(15)"
         tt-relchdv.nrcheque AT 077 FORMAT "zzz,zzz,9"                      
         tt-relchdv.vllanmto AT 087 FORMAT "zzz,zzz,zz9.99"                 
         tt-relchdv.cdalinea AT 102 FORMAT "99"                             
         tt-relchdv.cdagenci AT 105 FORMAT "z99"                            
         tt-relchdv.cdoperad AT 109 FORMAT "x(08)"                          
         tt-relchdv.dsorigem AT 118 FORMAT "x(13)"                          
         tt-relchdv.cdpesqui AT 012 FORMAT "x(48)"                          
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_todos_cecred.

    FORM SKIP(1)
         "Quantidade"                                 AT 62   
         "Valor"                                      AT 86   
         SKIP(1)
         "TOTAL DE DEVOLUCOES CAIXA: "                AT 35
         aux_totqtcax                                 AT 65
         aux_totvlcax                                 AT 73
         SKIP(1)
         "TOTAL DE DEVOLUCOES NO ARQUIVO DIURNO: "    AT 23
         aux_totqtdiu                                 AT 65
         aux_totvldiu                                 AT 73
         SKIP(1)
         "TOTAL DE DEVOLUCOES NO ARQUIVO NOTURNO: "   AT 22
         aux_totqtnot                                 AT 65
         aux_totvlnot                                 AT 73
         SKIP(1)
         "TOTAL DE DEVOLUCOES NO CUSTODIA/DESCONTO: " AT 20
         aux_totqtdes                                 AT 65
         aux_totvldes                                 AT 73
         SKIP
         "-----------------------------"              AT 62
         SKIP(1)
         "TOTAL DE DEVOLUCOES: "                      AT 41
         aux_totalqtd                                 AT 65
         aux_totalvlr                                 AT 73
         SKIP(3)
         "TOTAL DE DEVOLUCOES COM ALINEA 37: "        AT 27
         aux_totqtrej                                 AT 65
         aux_totvlrej                                 AT 73
         WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_totais.
   
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL crapcop THEN DO:
        
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".

    END.

    FIND FIRST crapage WHERE crapage.cdcooper = par_cdcooper
                         AND crapage.flgdsede = TRUE
                         NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapage THEN DO:
        
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "PA Sede nao cadastrado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".

    END.

    ASSIGN aux_dtmovime = STRING(YEAR(par_dtmvtolt),"9999")
                        + STRING(MONTH(par_dtmvtolt),"99")
                        + STRING(DAY(par_dtmvtolt),"99")
           aux_dscooper = "/usr/coop/" + crapcop.dsdircop + "/".

    /* Nome Arquivo definido por ABBC 1agenMDD.DVD */
    /* 1    - Fixo
       agen - Cod Agen Central crapcop.cdagectl
       M    - Mes Movim.(1-9 = Jan-Set) O=Out N=Nov D=Dez
       N    - Fixo
       xx   - Numero do PA */

    IF  MONTH(par_dtmvtolt) > 9 THEN
        CASE MONTH(par_dtmvtolt):
            WHEN 10 THEN aux_mes = "O".
            WHEN 11 THEN aux_mes = "N".
            WHEN 12 THEN aux_mes = "D".
        END CASE.
    ELSE
        aux_mes = STRING(MONTH(par_dtmvtolt),"9").

    /* 1a Exec = DVD | 2a Exec = DVT */

    IF  par_cddevolu = 5 THEN /* 1a Exec */
        ASSIGN aux_extensao = ".DVD"
               aux_nmarqchq = "rl/crrl219_5.lst"
               aux_nmarqdev = "devolu_cecred_diurna.txt"
               aux_dssufarq = "1".
    ELSE                     /* 2a Exec */
        ASSIGN aux_extensao = ".DVT"
               aux_nmarqchq = "rl/crrl219_6.lst"
               aux_nmarqdev = "devolu_cecred_noturna.txt"
               aux_dssufarq = "1".

    ASSIGN aux_nmarquiv = STRING(aux_dssufarq,"X(1)") + 
                          STRING(crapcop.cdagectl,"9999") + aux_mes +
                          STRING(DAY(par_dtmvtolt),"99") +  aux_extensao.

    ASSIGN aux_nrsequen = 2
           aux_vldtotal = 0
           flg_devolbcb = FALSE.

    OUTPUT STREAM str_1 TO VALUE(aux_dscooper + aux_nmarqchq)
                           PAGED PAGE-SIZE 84.

    /* Cdempres = 11 , Relatorio 219 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "219" "132" }

    ASSIGN aux_totqtcax = 0
           aux_totvlcax = 0
           aux_totqtdiu = 0
           aux_totvldiu = 0
           aux_totqtnot = 0
           aux_totvlnot = 0
           aux_totqtdes = 0
           aux_totvldes = 0
           aux_totqtrej = 0
           aux_totvlrej = 0
           aux_totalqtd = 0
           aux_totalvlr = 0
           aux_tprelato = 1
           aux_primeira = TRUE.

    FOR EACH crapdev WHERE crapdev.cdcooper = par_cdcooper
                       AND crapdev.cdbanchq = crapcop.cdbcoctl
                       AND crapdev.insitdev = 1
                       AND crapdev.cdhistor <> 46
                       AND crapdev.cdalinea > 0
                       NO-LOCK BREAK BY crapdev.cdagechq
                                     BY crapdev.nrctachq
                                     BY crapdev.nrcheque:

       IF FIRST-OF(crapdev.cdagechq) THEN
       DO:
           IF aux_primeira = TRUE  THEN
           DO:
               /* Não executa*/
           END.
           ELSE
           DO:
               IF  flg_devolbcb = TRUE THEN
                   DO:
                       PUT STREAM str_2 FILL("9",47)         FORMAT "x(47)"
                                     "CEL605"
                                     crapage.cdcomchq     FORMAT "999"
                                     "0001"
                                     crapcop.cdbcoctl     FORMAT "999" /*BANCO*/
                                     crapcop.nrdivctl     FORMAT "9"   /* DV  */
                                     "1"
                                     aux_dtmovime         FORMAT "x(08)"
                                     (aux_vldtotal * 100) FORMAT "99999999999999999"
                                     FILL(" ",60)         FORMAT "x(60)"
                                     aux_nrsequen         FORMAT "9999999999"
                                     SKIP.
                 
                        OUTPUT STREAM str_2 CLOSE.
                        ASSIGN aux_vldtotal = 0.
                 
                        UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + aux_nmarquiv +
                                          " > /micros/" + crapcop.dsdircop + "/abbc/" +
                                          aux_nmarquiv).
                                          
                        UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv + 
                                          " " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                                          "_" + STRING(TIME,"99999") + " 2>/dev/null").

                   END.
           END.                     

           ASSIGN flg_devolbcb = FALSE
                  aux_nmarquiv = STRING(aux_dssufarq,"X(1)") + 
                                 STRING(crapdev.cdagechq,"9999") + aux_mes +
                                 STRING(DAY(par_dtmvtolt),"99") +  aux_extensao
                  aux_nrsequen = 2
                  aux_primeira = FALSE.

       END.

       IF par_cdcooper = 1 OR     /* Viacredi */
          par_cdcooper = 13 THEN  /* Scrcred  */
       DO:
            RUN verifica_incorporacao(INPUT  par_cdcooper,
                                      INPUT  crapdev.nrdconta,
                                      INPUT  crapdev.nrcheque,
                                      OUTPUT aux_cdcopant,
                                      OUTPUT aux_nrdconta_tco,
                                      OUTPUT aux_cdagectl).
        END.


       /* Diego - Devolucoes automaticas alinea 37, não geram lançamento de 
       devolução na conta do cooperado, serão apenas retornadas no arquivo 
       de devolução  */
        IF  crapdev.nrdconta = 0 THEN DO:
            CREATE tt-relchdv.
            ASSIGN tt-relchdv.nrdconta = 0
                   tt-relchdv.nmprimtl = ""
                   tt-relchdv.cdpesqui = ""
                   tt-relchdv.nrcheque = crapdev.nrcheque
                   tt-relchdv.vllanmto = crapdev.vllanmto
                   tt-relchdv.cdalinea = crapdev.cdalinea
                   tt-relchdv.cdagenci = 1
                   tt-relchdv.cdoperad = crapdev.cdoperad
                   tt-relchdv.dstipcta = ""
                   aux_dsorigem        = "".       

            CASE crapdev.indevarq:
                WHEN 1 THEN 
                    ASSIGN aux_dsorigem = "Arq. Noturno"
                           aux_totqtnot = aux_totqtnot + 1
                           aux_totvlnot = aux_totvlnot +
                                          crapdev.vllanmto.
           
                WHEN 2 THEN 
                    ASSIGN aux_dsorigem = "Arq. Diurno"
                           aux_totqtdiu = aux_totqtdiu + 1
                           aux_totvldiu = aux_totvldiu +
                                          crapdev.vllanmto.
            END CASE.     

            ASSIGN aux_totqtrej = aux_totqtrej + 1                
                   aux_totvlrej = aux_totvlrej + crapdev.vllanmto
                   tt-relchdv.dsorigem = aux_dsorigem.
              
            IF  par_cddevolu = 5 THEN DO:
                IF  crapdev.indevarq <> 2 THEN
                    NEXT.
            END.
            ELSE
            IF  crapdev.indevarq <> 1 THEN
                NEXT.

            ASSIGN aux_contador = aux_contador + 1.
            
            IF  flg_devolbcb = FALSE THEN DO:
                OUTPUT STREAM str_2 TO VALUE(aux_dscooper + "arq/" +
                                             aux_nmarquiv).

                PUT STREAM str_2
                    FILL("0",47)     FORMAT "x(47)"
                    "CEL605"
                    crapage.cdcomchq FORMAT "999"
                    "0001"
                    crapcop.cdbcoctl FORMAT "999"
                    crapcop.nrdivctl FORMAT "9"   /* DV */
                    "1"              /* Ind. Remes */
                    aux_dtmovime     FORMAT "x(08)"
                    FILL(" ",77)     FORMAT "x(77)"
                    "0000000001"
                    SKIP.
                     
                    ASSIGN flg_devolbcb = TRUE.
            END.
            
            IF   crapdev.dtmvtolt < par_dtmvtoan THEN
                 ASSIGN aux_cdcmpchq = INT(SUBSTR(crapdev.cdpesqui,01,3)).
            ELSE
                 ASSIGN aux_cdcmpchq = INT(SUBSTR(crapdev.cdpesqui,79,3)).
                            
            ASSIGN aux_linhadet = SUBSTR(crapdev.cdpesqui,1,53)
                                + STRING(crapdev.cdalinea,"99")
                                + SUBSTR(crapdev.cdpesqui,56,23)
                                + STRING(aux_cdcmpchq,"999")
                                + SUBSTR(crapdev.cdpesqui,82,69)
                                + STRING(aux_nrsequen,"9999999999").

            PUT STREAM str_2
                aux_linhadet FORMAT "x(160)".

            PUT STREAM str_2
                SKIP.

            ASSIGN aux_nrsequen = aux_nrsequen + 1
                   aux_vldtotal = aux_vldtotal + crapdev.vllanmto.

            /* CRIACAO da GNCPCHQ */
            CREATE gncpdev.
            ASSIGN gncpdev.cdcooper = crapdev.cdcooper
                   gncpdev.cdagenci = 0
                   gncpdev.dtmvtolt = DATE(
                                      INTE(SUBSTR(crapdev.cdpesqui,86,2)),
                                      INTE(SUBSTR(crapdev.cdpesqui,88,2)),
                                      INTE(SUBSTR(crapdev.cdpesqui,82,4)))
                   gncpdev.cdagectl = DEC(SUBSTR(crapdev.cdpesqui,7,4))
                   gncpdev.cdbanchq = INT(SUBSTR(crapdev.cdpesqui,4,3))
                   gncpdev.cdagechq = INT(SUBSTR(crapdev.cdpesqui,7,4))
                   gncpdev.nrctachq = DEC(SUBSTR(crapdev.cdpesqui,12,12))
                   gncpdev.nrcheque = INT(SUBSTR(crapdev.cdpesqui,25,6))
                   gncpdev.nrddigv2 = INT(SUBSTR(crapdev.cdpesqui,11,1))
                   gncpdev.nrddigv3 = INT(SUBSTR(crapdev.cdpesqui,31,1))
                   gncpdev.cdcmpchq = INT(SUBSTR(crapdev.cdpesqui,1,3))
                   gncpdev.cdtipchq = INT(SUBSTR(crapdev.cdpesqui,148,3))
                   gncpdev.nrddigv1 = INT(SUBSTR(crapdev.cdpesqui,24,1))
                   gncpdev.vlcheque = DEC(SUBSTR(crapdev.cdpesqui,34,17))
                                      / 100
                   /* VIACON - gravar conta nova */
                   gncpdev.nrdconta = IF aux_nrdconta_tco > 0 THEN
                                         crapdev.nrdconta
                                      ELSE INT(SUBSTR(crapdev.cdpesqui,12,9))
                   gncpdev.nmarquiv = aux_nmarquiv
                   gncpdev.cdoperad = par_cdoperad
                   gncpdev.hrtransa = TIME
                   gncpdev.cdtipreg = 1
                   gncpdev.flgconci = NO
                   gncpdev.nrseqarq = aux_nrsequen
                   gncpdev.cdcritic = 0
                   gncpdev.cdalinea = crapdev.cdalinea
                   gncpdev.cdperdev = IF par_cddevolu = 6 THEN
                                           1
                                      ELSE 2. /* 1-Noturna / 2-Diurna */

            VALIDATE gncpdev.

            NEXT.
        END.
        ELSE DO:
            /* VIACON - ler conta na coop nova */
            FIND crapass WHERE crapass.cdcooper = par_cdcooper
                           AND crapass.nrdconta = crapdev.nrdconta
                           NO-LOCK NO-ERROR.
        
            IF  AVAIL crapass THEN DO:
                FIND craptip WHERE craptip.cdcooper = par_cdcooper
                               AND craptip.cdtipcta = crapass.cdtipcta
                               NO-LOCK NO-ERROR.
                
                IF  AVAIL craptip THEN
                    aux_dstipcta = craptip.dstipcta.
                ELSE
                    aux_dstipcta = "NAO ENCONTRADO".
            END.
            ELSE
                ASSIGN aux_dstipcta = "NAO ENCONTRADO".
       
            CREATE tt-relchdv.
            ASSIGN tt-relchdv.nrdconta = crapass.nrdconta
                   tt-relchdv.nmprimtl = crapass.nmprimtl
                   tt-relchdv.cdpesqui = crapdev.cdpesqui
                   tt-relchdv.nrcheque = crapdev.nrcheque
                   tt-relchdv.vllanmto = crapdev.vllanmto
                   tt-relchdv.cdalinea = crapdev.cdalinea
                   tt-relchdv.cdagenci = crapass.cdagenci
                   tt-relchdv.cdoperad = crapdev.cdoperad
                   tt-relchdv.dstipcta = aux_dstipcta.
        END.

        IF  crapdev.cdpesqui = "" THEN 
        DO:
            /* VIACON - ler com o numero da conta cheque e agencia do 
            cheque se for conta incorporada */

            /* Se aux_nrdconta_tco > 0 eh incorporada */
            IF aux_nrdconta_tco > 0 THEN
            DO:
                FIND LAST gncpchq WHERE 
                    gncpchq.cdcooper = par_cdcooper       AND
                    gncpchq.dtmvtolt = par_dtmvtoan     AND
                    gncpchq.cdbanchq = crapcop.cdbcoctl AND
                    gncpchq.cdagechq = aux_cdagectl     AND
                    gncpchq.nrctachq = aux_nrdconta_tco AND
                    gncpchq.nrcheque = crapdev.nrcheque AND
                   (gncpchq.cdtipreg = 3                OR
                    gncpchq.cdtipreg = 4)               AND
                    gncpchq.vlcheque = crapdev.vllanmto
                    NO-LOCK NO-ERROR.
            END.
            ELSE

            FIND LAST gncpchq WHERE 
                      gncpchq.cdcooper = par_cdcooper                AND 
                      gncpchq.dtmvtolt = par_dtmvtoan                AND 
                      gncpchq.cdbanchq = crapcop.cdbcoctl            AND 
                      gncpchq.cdagechq = crapcop.cdagectl            AND 
                      gncpchq.nrctachq = crapdev.nrdconta            AND 
                      gncpchq.nrcheque = crapdev.nrcheque            AND 
                      (gncpchq.cdtipreg = 3 OR gncpchq.cdtipreg = 4) AND 
                      gncpchq.vlcheque = crapdev.vllanmto
                      NO-LOCK NO-ERROR.

            IF  NOT AVAIL gncpchq THEN 
            DO:
                ASSIGN tt-relchdv.dsorigem = "Caixa"
                       aux_totqtcax = aux_totqtcax + 1
                       aux_totvlcax = aux_totvlcax +
                                      crapdev.vllanmto
                                      aux_totalqtd = aux_totqtcax + aux_totqtnot +
                                                     aux_totqtdiu + aux_totqtdes
                                      aux_totalvlr = aux_totvlcax + aux_totvlnot +
                                                     aux_totvldiu + aux_totvldes.

                NEXT.
            END.
        END.
        ELSE
            IF  crapdev.cdpesqui = "TCO" THEN DO: /* Contas transferidas */
                /* Tabela de contas transferidas entre cooperativas */
                FIND craptco WHERE craptco.cdcopant = crapdev.cdcooper
                               AND craptco.nrctaant = crapdev.nrdconta
                               AND craptco.tpctatrf = 1
                               AND craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.

                IF  NOT AVAIL craptco THEN
                    NEXT.
                     
                FIND LAST gncpchq WHERE gncpchq.cdcooper = craptco.cdcooper
                                    AND gncpchq.dtmvtolt = par_dtmvtoan
                                    AND gncpchq.cdbanchq = crapcop.cdbcoctl
                                    AND gncpchq.cdagechq = crapcop.cdagectl
                                    AND gncpchq.nrctachq = craptco.nrctaant
                                    AND gncpchq.nrcheque = crapdev.nrcheque
                                    AND gncpchq.cdtipreg = 4
                                    AND gncpchq.vlcheque = crapdev.vllanmto
                                    NO-LOCK NO-ERROR.
                
                IF  NOT AVAIL gncpchq THEN DO:
                    FIND LAST gncpchq WHERE gncpchq.cdcooper = craptco.cdcopant
                                        AND gncpchq.dtmvtolt = par_dtmvtoan
                                        AND gncpchq.cdbanchq = crapcop.cdbcoctl
                                        AND gncpchq.cdagechq = crapcop.cdagectl
                                        AND gncpchq.nrctachq = craptco.nrctaant
                                        AND gncpchq.nrcheque = crapdev.nrcheque
                                        AND gncpchq.cdtipreg = 3
                                        AND gncpchq.vlcheque = crapdev.vllanmto
                                        NO-LOCK NO-ERROR.
                    
                    IF  NOT AVAILABLE gncpchq THEN DO:
                        ASSIGN tt-relchdv.dsorigem = "Caixa"
                                      aux_totqtcax = aux_totqtcax + 1
                                      aux_totvlcax = aux_totvlcax +
                                                     crapdev.vllanmto
                                      aux_totalqtd = aux_totqtcax + 
                                                     aux_totqtnot +
                                                     aux_totqtdiu + 
                                                     aux_totqtdes
                                      aux_totalvlr = aux_totvlcax + 
                                                     aux_totvlnot +
                                                     aux_totvldiu + 
                                                     aux_totvldes.
                        NEXT.
                    END.    
                END.
            END.

        IF  crapdev.cdpesqui <> ""    AND                          
            crapdev.cdpesqui <> "TCO" THEN
            ASSIGN aux_dsorigem = "Custod/Descto"
                   aux_totqtdes = aux_totqtdes + 1                
                   aux_totvldes = aux_totvldes + crapdev.vllanmto.
        ELSE DO:
            CASE crapdev.indevarq:
                WHEN 1 THEN ASSIGN aux_dsorigem = "Arq. Noturno"
                                   aux_totqtnot = aux_totqtnot + 1
                                   aux_totvlnot = aux_totvlnot +
                                                  crapdev.vllanmto.
           
                WHEN 2 THEN DO: 
                    ASSIGN aux_dsorigem = "Arq. Diurno"
                               aux_totqtdiu = aux_totqtdiu + 1
                               aux_totvldiu = aux_totvldiu +
                                              crapdev.vllanmto.
                END.
            END CASE.     
        END.

        ASSIGN aux_totalqtd = aux_totqtcax + aux_totqtnot + 
                              aux_totqtdiu + aux_totqtdes
               aux_totalvlr = aux_totvlcax + aux_totvlnot + 
                              aux_totvldiu + aux_totvldes.
     
        tt-relchdv.dsorigem = aux_dsorigem.
       
        IF  crapdev.cdpesqui <> ""    AND
            crapdev.cdpesqui <> "TCO" THEN
            NEXT.

        IF  par_cddevolu = 4 THEN DO:
            IF  crapdev.indevarq <> 2 OR 
                crapdev.vllanmto < par_valorvlb THEN
                NEXT.
        END.
        ELSE
        IF  par_cddevolu = 5 THEN DO:
            IF  crapdev.indevarq <> 2 THEN
                NEXT.
            END.
        ELSE
        IF  crapdev.indevarq <> 1 THEN
            NEXT.
           
        ASSIGN aux_contador = aux_contador + 1.
       
        IF  AVAIL gncpchq THEN DO:
            IF  flg_devolbcb = FALSE THEN DO:
                OUTPUT STREAM str_2 TO VALUE(aux_dscooper + "arq/" +
                                             aux_nmarquiv).
 
                PUT STREAM str_2
                    FILL("0",47)     FORMAT "x(47)"
                    "CEL605"
                    crapage.cdcomchq FORMAT "999"
                    "0001"
                    crapcop.cdbcoctl FORMAT "999"
                    crapcop.nrdivctl FORMAT "9"   /* DV */
                    "1"              /* Ind. Remes */
                    aux_dtmovime     FORMAT "x(08)"
                    FILL(" ",77)     FORMAT "x(77)"
                    "0000000001"
                    SKIP.
                         
                    ASSIGN flg_devolbcb = TRUE.
            END.
                
            IF  gncpchq.dtmvtolt < par_dtmvtoan THEN
                aux_cdcmpchq = INT(SUBSTR(gncpchq.dsidenti,01,3)).
            ELSE
                aux_cdcmpchq = INT(SUBSTR(gncpchq.dsidenti,79,3)).
                
            IF  par_cddevolu = 4 THEN DO:
                aux_cdtipdoc = 36.

                ASSIGN aux_cdbandep = INT(SUBSTR(gncpchq.dsidenti,56,3))
                       aux_cdagedep = INT(SUBSTR(gncpchq.dsidenti,63,4)).
                             
                FIND crapagb WHERE crapagb.cddbanco = aux_cdbandep 
                               AND crapagb.cdageban = aux_cdagedep
                               NO-LOCK NO-ERROR.
    
                IF  AVAIL crapagb  THEN DO:
                    FIND LAST crapfsf WHERE crapfsf.cdcidade = crapagb.cdcidade 
                                        AND crapfsf.dtferiad = par_dtmvtolt
                                        NO-LOCK NO-ERROR.
                
                    IF  AVAIL crapfsf THEN
                        aux_cdtipdoc = 38.
                END.
                                  
                aux_linhadet = SUBSTR(gncpchq.dsidenti,1,53)
                             + STRING(crapdev.cdalinea,"99")
                             + SUBSTR(gncpchq.dsidenti,56,23)
                             + STRING(aux_cdcmpchq,"999")
                             + SUBSTR(gncpchq.dsidenti,82,66)
                             + STRING(aux_cdtipdoc,"999")
                             + STRING(aux_nrsequen,"9999999999").
    
                PUT STREAM str_2
                    aux_linhadet FORMAT "x(160)".
    
                PUT STREAM str_2
                    SKIP.
            END.
            ELSE DO:
                aux_linhadet = SUBSTR(gncpchq.dsidenti,1,53)
                             + STRING(crapdev.cdalinea,"99")
                             + SUBSTR(gncpchq.dsidenti,56,23)
                             + STRING(aux_cdcmpchq,"999")
                             + SUBSTR(gncpchq.dsidenti,82,69)
                             + STRING(aux_nrsequen,"9999999999").
    
                PUT STREAM str_2
                    aux_linhadet FORMAT "x(160)".
    
                PUT STREAM str_2
                    SKIP.
            END.
                
            ASSIGN aux_nrsequen = aux_nrsequen + 1
                   aux_vldtotal = aux_vldtotal + crapdev.vllanmto.
                
            IF  crapdev.cdpesqui = "TCO" THEN DO: /* Contas transferidas */
            
                FIND craptco WHERE craptco.cdcopant = par_cdcooper
                               AND craptco.nrctaant = crapdev.nrdconta
                               AND craptco.tpctatrf = 1
                               AND craptco.flgativo = TRUE
                               NO-LOCK NO-ERROR.
    
                IF  AVAIL craptco THEN
                    ASSIGN aux_cdcooper = craptco.cdcooper
                           aux_nrdconta = craptco.nrdconta.
                ELSE
                    ASSIGN aux_cdcooper = par_cdcooper
                           aux_nrdconta = crapdev.nrdconta.
            END.
            ELSE
                ASSIGN aux_cdcooper = par_cdcooper
                       aux_nrdconta = crapdev.nrdconta.
            
            /* CRIACAO da GNCPCHQ */
            CREATE gncpdev.
            ASSIGN gncpdev.cdcooper = aux_cdcooper
                   gncpdev.cdagenci = gncpchq.cdagenci
                   gncpdev.dtmvtolt = DATE(INT(SUBSTR(gncpchq.dsidenti,86,2)),
                                           INT(SUBSTR(gncpchq.dsidenti,88,2)),
                                           INT(SUBSTR(gncpchq.dsidenti,82,4)))
                   gncpdev.cdagectl = DEC(SUBSTR(gncpchq.dsidenti,7,4))
                   gncpdev.cdbanchq = INT(SUBSTR(gncpchq.dsidenti,4,3))
                   gncpdev.cdagechq = INT(SUBSTR(gncpchq.dsidenti,7,4))
                   gncpdev.nrctachq = DEC(SUBSTR(gncpchq.dsidenti,12,12))
                   gncpdev.nrcheque = INT(SUBSTR(gncpchq.dsidenti,25,6))
                   gncpdev.nrddigv2 = INT(SUBSTR(gncpchq.dsidenti,11,1))
                   gncpdev.nrddigv3 = INT(SUBSTR(gncpchq.dsidenti,31,1))
                   gncpdev.cdcmpchq = INT(SUBSTR(gncpchq.dsidenti,1,3))
                   gncpdev.cdtipchq = INT(SUBSTR(gncpchq.dsidenti,148,3))
                   gncpdev.nrddigv1 = INT(SUBSTR(gncpchq.dsidenti,24,1))
                   gncpdev.vlcheque = DEC(SUBSTR(gncpchq.dsidenti,34,17))
                                      / 100
                   /* VIACON - gravar numero da nova conta */
                   gncpdev.nrdconta = IF aux_nrdconta_tco > 0 THEN 
                                          crapdev.nrdconta
                                      ELSE INT(SUBSTR(gncpchq.dsidenti,12,12))
                   gncpdev.nmarquiv = aux_nmarquiv
                   gncpdev.cdoperad = par_cdoperad
                   gncpdev.hrtransa = TIME
                   gncpdev.cdtipreg = 1
                   gncpdev.flgconci = NO
                   gncpdev.nrseqarq = aux_nrsequen
                   gncpdev.cdcritic = 0
                   gncpdev.cdalinea = crapdev.cdalinea
                   gncpdev.cdperdev = IF par_cddevolu = 6 THEN
                                           1
                                      ELSE
                                           2. /* 1-Noturna / 2-Diurna */

            VALIDATE gncpdev.
        END.
    END. /* Fim do FOR EACH crapdev */

    IF  flg_devolbcb = TRUE THEN DO:

        PUT STREAM str_2
            FILL("9",47)         FORMAT "x(47)"
            "CEL605"
            crapage.cdcomchq     FORMAT "999"
            "0001"
            crapcop.cdbcoctl     FORMAT "999" /*BANCO*/
            crapcop.nrdivctl     FORMAT "9"   /* DV  */
            "1"
            aux_dtmovime         FORMAT "x(08)"
            (aux_vldtotal * 100) FORMAT "99999999999999999"
            FILL(" ",60)         FORMAT "x(60)"
            aux_nrsequen         FORMAT "9999999999"
            SKIP.

        OUTPUT STREAM str_2 CLOSE.

        UNIX SILENT VALUE("ux2dos " + aux_dscooper + "arq/" + aux_nmarquiv +
                          " > /micros/" + crapcop.dsdircop + "/abbc/" +
                          aux_nmarquiv).
                              
        UNIX SILENT VALUE("mv " + aux_dscooper + "arq/" + aux_nmarquiv + 
                          " " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                          "_" + STRING(TIME,"99999") + " 2>/dev/null").

        /* Gerar log dos arquivos */
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                          " Cooperativa: " + STRING(par_cdcooper) +
                          " Executado os comandos: " + 
                          "  UX2DOS " + aux_dscooper + "arq/" + 
                             aux_nmarquiv + " para /micros/" + 
                          crapcop.dsdircop + "/abbc/" + aux_nmarquiv +
                          " e mover " + aux_dscooper + "arq/" + aux_nmarquiv + 
                          " para " + aux_dscooper + "salvar/" + aux_nmarquiv + 
                          "_" + STRING(TIME,"99999") +
                          " >> log/proc_batch.log").
    END.

    /* VIACON - O relatorio contera informacao de contas da cooperativa e contas incorporadas */
    FOR EACH tt-relchdv
        BREAK BY tt-relchdv.nrdconta:

        IF  FIRST (tt-relchdv.nrdconta) THEN DO:
            DISPLAY STREAM str_1 par_dtmvtolt WITH FRAME f_relacao.
            DISPLAY STREAM str_1 WITH FRAME f_cabec.
        END.

        DISPLAY STREAM str_1
                tt-relchdv.nrdconta   tt-relchdv.nmprimtl
                tt-relchdv.dstipcta   tt-relchdv.nrcheque
                tt-relchdv.vllanmto   tt-relchdv.cdalinea
                tt-relchdv.cdagenci   tt-relchdv.cdoperad
                tt-relchdv.dsorigem   tt-relchdv.cdpesqui   
                WITH FRAME f_todos_cecred.

        DOWN STREAM str_1
               WITH FRAME f_todos_cecred.

        IF  LAST (tt-relchdv.nrdconta) THEN
            DISPLAY STREAM str_1
                    aux_totqtcax   aux_totvlcax   aux_totqtdiu
                    aux_totvldiu   aux_totqtnot   aux_totvlnot
                    aux_totqtdes   aux_totvldes   aux_totqtrej
                    aux_totvlrej   aux_totalqtd   aux_totalvlr
                    WITH FRAME f_totais.
    END.

    OUTPUT STREAM str_1 CLOSE.

    /*  Salvar copia relatorio para "/rlnsv"  */
    UNIX SILENT VALUE("cp " + aux_dscooper + aux_nmarqchq + " " + 
                      aux_dscooper + "rlnsv").

    UNIX SILENT VALUE("ux2dos " + aux_dscooper + aux_nmarqchq + " > /micros/" + 
                      crapcop.dsdircop + "/devolu/" + aux_nmarqdev).

    /* Gerar log dos arquivos */
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                      " Cooperativa: " + STRING(par_cdcooper) +
                      " Executado os comandos: " + 
                      " Copiar arquivo " + aux_nmarqchq + " para rlnsv" +
                      " e UX2DOS " + aux_dscooper + aux_nmarqchq + 
                      " para /micros/" + crapcop.dsdircop + 
                      "/devolu/" + aux_nmarqdev +
                      " >> log/proc_batch.log").

    /* Tratamento para Migracao especifico
    da AltoVale ou Conta migrada da Acredi */
    IF  par_cdcooper = 1 OR
        par_cdcooper = 2 THEN DO:
        RUN sistema/generico/procedures/b1wgen0011.p 
            PERSISTENT SET h-b1wgen0011.

        IF  VALID-HANDLE(h-b1wgen0011) THEN DO:
            RUN converte_arquivo IN h-b1wgen0011(INPUT par_cdcooper,
                                                 INPUT aux_dscooper + 
                                                       aux_nmarqchq,
                                                 INPUT aux_nmarqdev).

            RUN enviar_email_completo IN h-b1wgen0011
                                     (INPUT par_cdcooper,
                                      INPUT "crps264",
                                      INPUT "cpd@cecred.coop.br",
                                      INPUT 
                                      "suporte@viacredi.coop.br",
                                      INPUT "Relatorio de Devolucoes " + 
                                            "Cheques CECRED",
                                      INPUT "",
                                      INPUT aux_nmarqdev,
                                      INPUT "",
                                      INPUT FALSE).

            DELETE PROCEDURE h-b1wgen0011.
        END.
    END.

   /* Antiga chamada de imprim_unif.p
      
    ASSIGN aux_nmformul = "132col"
           glb_nmarqimp = aux_dscooper + aux_nmarqchq
           glb_nrcopias = 1.

    RUN fontes/imprim_unif.p (INPUT p-cdcooper).*/
   
    IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
        RUN sistema/generico/procedures/b1wgen0024.p
        PERSISTENT SET h-b1wgen0024.
    
    RUN gera-arquivo-intranet IN h-b1wgen0024
                             (INPUT par_cdcooper,
                              INPUT crapage.cdagenci,
                              INPUT par_dtmvtolt,
                              INPUT aux_nmarquiv,
                              INPUT "132col",
                              OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0024) THEN
        DELETE PROCEDURE h-b1wgen0011.

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE envia_arquivo_xml:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_ispbdebt AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_ispbcred AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrcheque AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                               NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdlegado AS INTE                               NO-UNDO.

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_textoxml AS CHAR                          EXTENT 31    NO-UNDO.
    DEF VAR aux_nrctrlif AS CHAR                                       NO-UNDO.
    DEF VAR aux_dsarqenv AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmarqxml AS CHAR                                       NO-UNDO.
    DEF VAR aux_dtmvtolt AS CHAR                                       NO-UNDO.
    DEF VAR aux_nmlogspb AS CHAR                                       NO-UNDO.

    /* Arquivo gerado para o envio */
    ASSIGN aux_nmarqxml = "/usr/coop/" + crapcop.dsdircop
                        + "/salvar/msgenv_cecred_"
                        + STRING(YEAR(par_dtmvtolt),"9999")
                        + STRING(MONTH(par_dtmvtolt),"99")
                        + STRING(DAY(par_dtmvtolt),"99")
                        + STRING(ETIME,"9999999999") + ".xml"
           /* Arquivo de log - tela LOGSPB*/
           aux_nmlogspb = "/usr/coop/" + crapcop.dsdircop + "/log/"
                        + "mqcecred_envio"
                        + STRING(par_dtmvtolt,"999999") + ".log"
            aux_nmarquiv = SUBSTRING(TRIM(aux_nmarqxml),
                           R-INDEX(aux_nmarqxml,"/") + 1)
            /* 3-identifica ROC650, assim como
            1-TED e 2-TEC em outros programas */  
            aux_nrctrlif = "3" + SUBSTRING(STRING(YEAR(par_dtmvtolt)),3)
                         + STRING(MONTH(par_dtmvtolt),"99")
                         + STRING(DAY(par_dtmvtolt),"99")
                         + STRING(crapcop.cdagectl,"9999")
                         + STRING(ETIME,"99999999")
            aux_dtmvtolt = STRING(YEAR(par_dtmvtolt), "9999") + "-"
                         + STRING(MONTH(par_dtmvtolt), "99") + "-"
                         + STRING(DAY(par_dtmvtolt), "99").

    /* HEADER - mensagens STR e PAG */
    ASSIGN aux_textoxml[1] = "<SISMSG>"
           aux_textoxml[2] = "<SEGCAB>" 
           aux_textoxml[3] = "<CD_LEGADO>" + STRING(par_cdlegado) + 
                           "</CD_LEGADO>"
           aux_textoxml[4] = "<TP_MANUT>" + "I" + "</TP_MANUT>" /* Inclusao */
           aux_textoxml[5] = "<CD_STATUS>" + "D" + "</CD_STATUS>"  
           aux_textoxml[6] = "<NR_OPERACAO>" + aux_nrctrlif + 
                           "</NR_OPERACAO>"
           aux_textoxml[7] = "<FL_DEB_CRED>" + "D" + "</FL_DEB_CRED>"
           aux_textoxml[8] = "</SEGCAB>".

    /* BODY  - Mensagem STR0004
    Descrição: destinado à IF requisitar transferência de recursos entre
               instituições financeiras resultantes de operações de sua
               responsabilidade e de terceiros. */

    ASSIGN aux_textoxml[9]  = "<STR0004>"
           aux_textoxml[10] = "<CodMsg>" + "STR0004" + "</CodMsg>"      
           aux_textoxml[11] = "<NumCtrlIF>" + aux_nrctrlif +
                              "</NumCtrlIF>"
           aux_textoxml[12] = "<ISPBIFDebtd>" + 
                              SUBSTR(STRING(par_ispbdebt,"99999999999999"),1,8)
                              + "</ISPBIFDebtd>"
           aux_textoxml[13] = "<ISPBIFCredtd>" + 
                              STRING(par_ispbcred,"99999999")
                              + "</ISPBIFCredtd>"
           aux_textoxml[14] = "<AgCredtd>" + "</AgCredtd>"

           /* Liquidacao Bilateral */
           aux_textoxml[15] = "<FinlddIF>" + "52" + "</FinlddIF>"
           aux_textoxml[16] = "<CodIdentdTransf>" + "</CodIdentdTransf>"
           aux_textoxml[17] = "<VlrLanc>" + STRING(par_vllanmto) +
                              "</VlrLanc>"
           aux_textoxml[18] = "<Hist>"+ "Cheque VLB n. "
                              + TRIM(STRING(par_nrcheque, "zzz,zz9,9"))
                              + "</Hist>"
           aux_textoxml[19] = "<NivelPref>" + "</NivelPref>"
           aux_textoxml[20] = "<DtMovto>" + aux_dtmvtolt
                              + "</DtMovto>"
           aux_textoxml[21] = "</STR0004>"
           aux_textoxml[22] = "</SISMSG>".

    /* F az  uma copia do XML de
    envio para o diretorio salvar */
    OUTPUT STREAM str_1 TO VALUE (aux_nmarqxml).

    /* Cria o arquivo */
    DO  aux_contador = 1 TO 23:

        IF  aux_textoxml[aux_contador] = ""   THEN
            NEXT.

        PUT STREAM str_1 UNFORMATTED aux_textoxml[aux_contador].
        /* String que recebe a mensagem enviada por buffer */
        ASSIGN aux_dsarqenv = aux_dsarqenv
                            + aux_textoxml[aux_contador].
    END.

    OUTPUT STREAM str_1 CLOSE.

    /* Com o comando SUDO pois para conecta no MQ
    através do script o usuário precisa ser ROOT */
    UNIX SILENT VALUE ("/usr/bin/sudo /usr/local/cecred/bin/mqcecred_envia.pl"
                        + " --msg='" + aux_dsarqenv + "'")
                        + " --coop='" + STRING(par_cdcooper) + "'"
                        + " --arq='" + aux_nmarqxml + "'").
     
    /* Gerar log dos arquivos */
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                      " Cooperativa: " + STRING(par_cdcooper) +
                      " Enviar arquivo via MQ: " + aux_nmarqxml +
                      " Mensagem: " + aux_dsarqenv +
                      " >> log/proc_batch.log").

    /* Cria registro de Debito */
    CREATE gnmvcen.
    ASSIGN gnmvcen.cdagectl = crapcop.cdagectl
           gnmvcen.dtmvtolt = par_dtmvtolt
           gnmvcen.dsmensag = "STR0004"
           gnmvcen.dsdebcre = "D" /*Debito em Conta*/
           gnmvcen.vllanmto = par_vllanmto.
    VALIDATE gnmvcen.

    /* Logar envio 
    *****************************************************************
    * Cuidar ao mecher no log pois os espacamentos e formats estao  *
    * ajustados para que a tela LogSPB pegue os dados com SUBSTRING * 
    *****************************************************************/
    UNIX SILENT VALUE ("echo " + '"' + 
       STRING(par_dtmvtolt,"99/99/9999") + " - " +
       STRING(TIME,"HH:MM:SS") + " - " + STRING("crps264","x(10)") +
       " - ENVIADA OK         --> "  + 
       "Arquivo " + STRING(aux_nmarquiv, "x(40)") +
       ". Evento: " + STRING("STR0004", "x(9)") + 
       ", Numero Controle: " + STRING(aux_nrctrlif, "x(20)") +
       ", Hora: " + STRING(TIME,"HH:MM:SS") +
       ", Valor: " + STRING(par_vllanmto,"zzz,zzz,zz9.99") +
       ", Banco Remet.: " + STRING(crapcop.cdbcoctl,"zz9") + "," + 
       STRING("", "x(136)") + 
       "Banco Dest.: " + STRING(par_cdbanchq,"zz9") +  "," + 
       STRING("", "x(136)") + 
       "ISPB IF Creditada: " + STRING(par_ispbcred,"99999999")  +   
       '"' + " >> " + aux_nmlogspb). 

    
    RUN sistema/generico/procedures/b1wgen0050.p 
        PERSISTENT SET h-b1wgen0050.
                                       
    IF  VALID-HANDLE (h-b1wgen0050)  THEN DO:
        RUN grava-log-ted IN h-b1wgen0050 (INPUT par_cdcooper,
                                           INPUT TODAY,
                                           INPUT TIME,
                                           INPUT 1, /* Ayllos */
                                           INPUT "crps264",
                                           INPUT 1, /*Enviada OK*/
                                           INPUT aux_nmarquiv,
                                           INPUT "STR0004",
                                           INPUT aux_nrctrlif,
                                           INPUT par_vllanmto, /*Valor*/
                                           INPUT crapcop.cdbcoctl, /*085*/
                                           INPUT crapcop.cdagectl, 
                                           INPUT par_nrdconta, /* Cta Coop*/
                                           INPUT "", /* Nome Cooperado, */
                                           INPUT 0,  /* CPF Cooperado*/
                                           INPUT par_cdbanchq, /*Banco*/
                                           INPUT 0, /* par_cdagenbc, */
                                           INPUT "", /* par_nrcctrcb, */
                                           INPUT "", /* par_nmpesrcb, */
                                           INPUT 0,
                                           INPUT "", /* par_cdidtran, */
                                           INPUT "",
                                           INPUT 0, /*PA origem*/
                                           INPUT 0, /*Caixa origem */
                                           INPUT "1", /* operador */
                                           INPUT 0,   /* ISPB */
                                           INPUT 0).  /* sem crise */
       
        DELETE PROCEDURE h-b1wgen0050.
    END.

    RETURN "OK".            

END PROCEDURE.

/******************************************************************************/

PROCEDURE marcar_cheque_devolu:

    /* Se  passou  da  hora  limite  cadastrada, o  sistema
    exigira a senha do coordenador para marcar os cheques */

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_dsbccxlt AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DECI                               NO-UNDO.

    DEF OUTPUT PARAM ret_pedsenha AS LOGICAL                           NO-UNDO.
    DEF OUTPUT PARAM ret_execucao AS LOGICAL                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgsenha AS LOGICAL                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN ret_pedsenha  = FALSE.

    IF  par_dsbccxlt = "CECRED" THEN DO:
        
        DO WHILE TRUE:
        
            /* Validar ultimo horario para devolucao */
            RUN verifica_hora_execucao(INPUT par_cdcooper,
                                       INPUT par_dtmvtolt,
                                       INPUT 6,
                                       OUTPUT ret_execucao,
                                       OUTPUT TABLE tt-erro).
        
            IF  ret_execucao THEN DO:
                ASSIGN ret_pedsenha  = TRUE /* Exigira a senha ao usuario */
                       aux_cdcritic = 0
                       aux_dscritic = "Hora limite para marcar cheques " +
                                      "foi ultrapassada!".
               
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "OK".
            END.
            ELSE
                LEAVE.

        END. /* Fim DO WHILE TRUE */
    END.
    ELSE
    DO:
        CASE tt-lancto.cdbanchq:
            WHEN   1  THEN DO:
                /* B.BRASIL */
                ASSIGN ret_pedsenha = FALSE /* Nao exigira a senha ao usuario */
                       aux_cdcritic = 0
                       aux_dscritic = "Efetue a devolucao pelo " +
                                      "Gerenciador Financeiro.".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.
            WHEN 756  THEN DO:
                /* BANCOOB */
                ASSIGN ret_pedsenha = FALSE /* Nao exigira a senha ao usuario */
                       aux_cdcritic = 0
                       aux_dscritic = "Efetue a devolucao pela " +
                                      "Intranet Bancoob.".
                RETURN "NOK".
            END.
        END CASE.
    END. /* end else */

    RETURN "OK".

END PROCEDURE.

/******************************************************************************/

PROCEDURE verifica_hora_execucao:

    /* Parametro de entrada:                                                 */
    /* 1 Hr Ini | 2 Hr Fim | 3 Hr Ini | 4 Hr Fim | 5 Hr Ini | 6 Hr Fim       */

    /* Verifica se a hora de execucao atual eh maior que a hora gravada      */
    /* nos parametros da craptab                                             */
    /* YES = Maior que o parametro                                           */
    /* NO  = Menor que o parametro                                           */

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_posicao  AS INTE                               NO-UNDO.

    DEF OUTPUT PARAM ret_execucao AS LOGICAL                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper
                   AND craptab.nmsistem = "CRED"
                   AND craptab.tptabela = "GENERI"
                   AND craptab.cdempres = 0
                   AND craptab.cdacesso = "HRTRDEVOLU"
                   AND craptab.tpregist = 0
                   NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craptab THEN DO:
        ASSIGN aux_cdcritic = 55
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.
    ELSE DO:
        IF  TIME >= INT(ENTRY(par_posicao,craptab.dstextab,";")) THEN
            ret_execucao = YES.
        ELSE
            ret_execucao = NO.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE verifica_incorporacao:

    DEF INPUT  PARAM par_cdcooper  AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrdconta  AS INT                               NO-UNDO.
    DEF INPUT  PARAM par_nrcheque  LIKE crapdev.nrcheque                NO-UNDO. 
    DEF OUTPUT PARAM par_cdcooptco LIKE craptco.cdcooper                NO-UNDO.
    DEF OUTPUT PARAM par_contatco  LIKE crapdev.nrdconta                NO-UNDO.
    DEF OUTPUT PARAM par_cdagectl  LIKE crabcop.cdagectl                NO-UNDO.

    DEF VAR aux_cdagechq          AS INTE                              NO-UNDO. 

    ASSIGN par_contatco = 0. /* Se retornar 0 nao eh conta incorporada */

    FIND craptco WHERE craptco.cdcooper = par_cdcooper     AND
                       craptco.nrdconta = par_nrdconta     AND
                       craptco.tpctatrf = 1                AND
                       craptco.flgativo = TRUE
                       NO-LOCK NO-ERROR.

    IF AVAILABLE craptco THEN 
    DO:
        IF par_cdcooper = 1 THEN
            aux_cdagechq = 103.
        ELSE
            aux_cdagechq = 114.

        FIND crapfdc WHERE crapfdc.cdcooper = par_cdcooper      AND
                           crapfdc.cdbanchq = 085               AND
                           crapfdc.cdagechq = aux_cdagechq      AND 
                           crapfdc.nrctachq = craptco.nrctaant  AND
                           crapfdc.nrcheque = INT(SUBSTR(STRING(par_nrcheque,"9999999"),1,6))
                           USE-INDEX crapfdc1
                           NO-LOCK NO-ERROR NO-WAIT.

        IF AVAIL(crapfdc) THEN 
        DO:
            ASSIGN par_contatco  = craptco.nrctaant
                   par_cdcooptco = craptco.cdcopant.

            FIND FIRST crabcop 
                 WHERE crabcop.cdcooper = craptco.cdcopant
                 NO-LOCK NO-ERROR.

            ASSIGN par_cdagectl =  crabcop.cdagectl.
        END.
    END.

END PROCEDURE.

PROCEDURE verifica-aplicacoes:
    DEF INPUT PARAMETER par_cdcooper AS INT                   NO-UNDO.
    DEF INPUT PARAMETER par_cdagenci AS INT                   NO-UNDO.
    DEF INPUT PARAMETER par_nmdatela AS CHAR                  NO-UNDO.
    DEF INPUT PARAMETER par_nrdconta AS DEC                   NO-UNDO.
    DEF INPUT PARAMETER par_dtmvtolt AS DATE                  NO-UNDO.
    
    DEF OUTPUT PARAMETER par_vlsldtot AS DEC                  NO-UNDO.
    DEF OUTPUT PARAMETER par_vlsldapl AS DEC                  NO-UNDO.
    DEF OUTPUT PARAMETER par_vlsldprp AS DEC                  NO-UNDO.
    DEF OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEF VAR aux_vlsldtot AS DECI                              NO-UNDO.
    DEF VAR aux_vltotrda AS DECI                              NO-UNDO.
    DEF VAR aux_vltotrpp AS DECI                              NO-UNDO.    
    DEF VAR aux_vlsldapl AS DECI                              NO-UNDO.
    DEF VAR aux_vlsldrgt AS DECI                              NO-UNDO.

    /** Saldo das aplicacoes **/
    IF  NOT VALID-HANDLE(h-b1wgen0081) THEN
        RUN sistema/generico/procedures/b1wgen0081.p 
            PERSISTENT SET h-b1wgen0081.
   
    IF  VALID-HANDLE(h-b1wgen0081)  THEN
        DO:
            ASSIGN aux_vlsldtot = 0
                   aux_vltotrda = 0
                   aux_vltotrpp = 0.                   
            
            RUN obtem-dados-aplicacoes IN h-b1wgen0081
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT 1,
                                       INPUT 1,
                                       INPUT par_nmdatela,
                                       INPUT 1,
                                       INPUT par_nrdconta,
                                       INPUT 1,
                                       INPUT 0,
                                       INPUT par_nmdatela,
                                       INPUT FALSE,
                                       INPUT ?,
                                       INPUT ?,
                                       OUTPUT aux_vlsldtot,
                                       OUTPUT TABLE tt-saldo-rdca,
                                       OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE <> "OK"  THEN
                DO:
                    IF VALID-HANDLE(h-b1wgen0081) THEN
                        DELETE OBJECT h-b1wgen0081.
                    
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Erro nos dados das aplicacoes.".                       
                    
                END.                  

            ASSIGN aux_vlsldapl = aux_vlsldtot.
            
            IF  VALID-HANDLE(h-b1wgen0081) THEN
                DELETE OBJECT h-b1wgen0081.
        END.
        
     
    DO WHILE TRUE:
    /*Busca Saldo Novas Aplicacoes*/
       
       { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
        RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
          aux_handproc = PROC-HANDLE NO-ERROR
                                  (INPUT par_cdcooper, /* Código da Cooperativa */
                                   INPUT "1",            /* Código do Operador */
                                   INPUT par_nmdatela, /* Nome da Tela */
                                   INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                   INPUT par_nrdconta, /* Número da Conta */
                                   INPUT 1,            /* Titular da Conta */
                                   INPUT 0,            /* Número da Aplicação / Parâmetro Opcional */
                                   INPUT par_dtmvtolt, /* Data de Movimento */
                                   INPUT 0,            /* Código do Produto */
                                   INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                   INPUT 0,            /* Identificador de Log (0 – Não / 1 – Sim) */
                                  OUTPUT 0,            /* Saldo Total da Aplicação */
                                  OUTPUT 0,            /* Saldo Total para Resgate */
                                  OUTPUT 0,            /* Código da crítica */
                                  OUTPUT "").          /* Descrição da crítica */
        
        CLOSE STORED-PROC pc_busca_saldo_aplicacoes
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic = 0
               aux_dscritic = ""
               aux_vlsldtot = 0
               aux_vlsldrgt = 0
               aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
                               WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
               aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
                               WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
               aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
                               WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
               aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
                               WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

        IF  aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            DO:
                IF  aux_dscritic = "" THEN
                    DO:
                       FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                          NO-LOCK NO-ERROR.
                    
                       IF AVAIL crapcri THEN
                          ASSIGN aux_dscritic = crapcri.dscritic.
                    
                    END.                    
            END.
            
        LEAVE.
    END.
    /*Fim Busca Saldo Novas Aplicacoes*/            
        
    RUN sistema/generico/procedures/b1wgen0006.p 
        PERSISTENT SET h-b1wgen0006.

    RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT '1',
                                           INPUT par_nmdatela,
                                           INPUT 1, /* Ayllos */
                                           INPUT par_nrdconta,
                                           INPUT 1, /* Titular */
                                           INPUT 0, /* Todos os Contratos*/
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtolt,
                                           INPUT 1, /*inprocess*/
                                           INPUT "DEVOLU",
                                           INPUT FALSE,
                                           OUTPUT aux_vltotrpp,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-dados-rpp).
                                           
    IF  RETURN-VALUE <> "OK"  THEN
        DO:
            IF  VALID-HANDLE(h-b1wgen0006) THEN
                DELETE OBJECT h-b1wgen0006.
            
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN aux_dscritic = "Erro nos dados das aplicacoes.".                    
            
        END.       
      
    IF  VALID-HANDLE(h-b1wgen0006) THEN
        DELETE OBJECT h-b1wgen0006.  
                                
    ASSIGN par_vlsldtot = aux_vltotrpp + aux_vlsldapl + aux_vlsldrgt
           par_vlsldapl = aux_vlsldapl + aux_vlsldrgt
           par_vlsldprp = aux_vltotrpp.
        
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".  
  
END PROCEDURE.

PROCEDURE altera-alinea:
    
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.    
    DEF INPUT PARAM par_cdbanchq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdagechq AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_nrctachq LIKE crapass.nrdconta                 NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdalinea AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                               NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.    
    
    DO  WHILE TRUE:    
                                                  
        FIND FIRST crapdev WHERE crapdev.cdcooper = par_cdcooper
                             AND crapdev.cdbanchq = par_cdbanchq
                             AND crapdev.cdagechq = par_cdagechq
                             AND crapdev.nrctachq = par_nrctachq
                             AND crapdev.nrcheque = par_nrdocmto
                             AND crapdev.cdhistor <> 46
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
        IF  AVAILABLE crapdev THEN        
            ASSIGN crapdev.cdalinea = par_cdalinea.
        
        LEAVE.
    END.
    
    IF  aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.

/******************************************************************************/
