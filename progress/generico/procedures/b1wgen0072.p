/*.............................................................................

    Programa: b1wgen0072.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Maio/2010                   Ultima atualizacao: 11/08/2017

    Objetivo  : Tranformacao BO tela CONTAS - RESPONSAVEL LEGAL

    Alteracoes: 12/08/2010 - Ajuste na validacao de UF (David).
    
                30/08/2010 - Ajuste na procedure Busca_Dados_Cto para buscar
                             somente pelo numero da conta e nao pelo CPF
                             (David).
                             
                22/09/2010 - Adicionado tratamento para conta 'pai' 
                             ou 'filha' (Gabriel - DB1).
                             
                20/12/2010 - Adicionado parametros na chamada do procedure
                             Replica_Dados para tratamento do log e erros
                             da validação na replicação (Gabriel - DB1).
                             
                21/03/2011 - Nao validar numero da conta do responsavel quando
                             for replicacao de dados (David).
                             
                15/04/2011 - Incluida validação de CEP existente. (André - DB1)
                
                16/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano).
                            
                18/03/2013 - Incluido a chamada para a procedure alerta_fraude
                             na procedure Grava_Dados (Adriano).
                             
                15/07/2013 - Incluido verificacao de conta encerrada na
                             procedure Valida_Dados. (Fabricio)
   
                19/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James).
                             
                30/09/2013 - Incluido campo crapcrl.flgimpri para inclusao de
                             Resp. Legal (Jean Michel).             
                             
                23/10/2013 - Alterada condicao para ser possivel a remocao de 
                             responsavel legal na mesma conta. (Reinert)
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)

                28/05/2014 - Alterado para não carregar mais o cdestcvl da 
                             crapass na tt-crapcrl (Douglas - Chamado 131253)
                             
                02/07/2014 - Alterada validacao de CEP dentro da funcao Valida_Dados
                             para nao consistir os dados numa exclusao
                             (Carlos Rafael Tanholi - Chamado 172112)
                             
                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 
                             0 - menor/maior. (Carlos)
                             
                20/02/2015 - Incluir validacao na PROCEDURE Busca_Dados_Cto para
                             tt-crapcrl (Lucas R. #251394)
                             
                21/07/2015 - Reformulacao cadastral (Gabriel-RKAM).             
                
                18/11/2015 - #325096 Retirada a validacao de CEP no momento da
                             exclusao do responsavel legal (Carlos)
                
                19/02/2016 - #394757 - Incluido tratamento para quando o parametro
                             par_dtdenasc vier nulo na rotina valida_dados
                             (Heitor - RKAM)
                
                19/02/2016 - #400612 - Nao estava permitindo excluir um responsavel
                             menor de idade. Essa validacao foi retirada nos casos de
                             exclusao de responsavel legal (Heitor - RKAM)
                
                22/02/2016 - #403060 - Nao estava permitindo excluir um responsavel
                             que nao possuia o campo Naturalidade preenchido. Validacao
                             removida para exclusao (Heitor - RKAM)
                
                28/04/2016 - Removida (IF cddopcao <> "E") validacoes desnecessarias no momento da exclusao
                             do responsavel legal, para atender o chamado 430472. (Kelvin)
                
                13/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)

                20/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)                

                31/07/2017 - Alterado leitura da CRAPNAT pela CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)    
                
                11/08/2017 - Incluído criacao do registro na tabela crapdoc com tipo do documento 51.
                             Projeto 339 - CRM. (Lombardi)	           
 .............................................................................*/

DEF STREAM str_1.

{ sistema/generico/includes/b1wgen0072tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                     NO-UNDO.
                         
DEF DATASET DATA FOR Relacionamento.

DEF VAR aux_idorigem AS INT                                         NO-UNDO.
&SCOPED-DEFINE GET-MSG ERROR-STATUS:GET-MESSAGE(1)

FUNCTION ValidaCpf  RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ) FORWARD.

FUNCTION BuscaIdade RETURNS INTEGER 
    ( INPUT par_dtnascto AS DATE,
      INPUT par_dtmvtolt AS DATE ) FORWARD.

/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cpfprocu AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtdenasc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_permalte AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_menorida AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapcrl.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcpfcto AS DEC                                     NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados do Responsavel Legal"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno  = "NOK"
           aux_nrcpfcto = 0.
    

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapcrl.
        EMPTY TEMP-TABLE tt-erro.

        IF (par_nmrotina = "Representante/Procurador" OR
            par_nmrotina = "MATRIC")                  AND
            par_permalte = FALSE                      THEN
            DO:
               IF par_nrdconta <> 0 THEN
                  DO:
                     ASSIGN aux_dscritic = "Alteracoes devem ser realizadas " +
                                           "na tela CONTAS.".
                     LEAVE Busca.
           
                  END.
             
            END.

        IF par_nrdconta <> 0 THEN
           DO: 
              /* verifica se eh menor de idade */
              FOR FIRST crapttl FIELDS(dtnasttl inhabmen)
                                WHERE crapttl.cdcooper = par_cdcooper AND
                                      crapttl.nrdconta = par_nrdconta AND
                                      crapttl.idseqttl = par_idseqttl 
                                      NO-LOCK:
             
                  IF (par_dtdenasc = crapttl.dtnasttl OR par_dtdenasc = ? ) AND
                      par_nmrotina = "RESPONSAVEL LEGAL" THEN
                     DO:    
                        IF (crapttl.inhabmen = 0                            AND
                           BuscaIdade(crapttl.dtnasttl,par_dtmvtolt) >= 18) OR
                           crapttl.inhabmen = 1                             THEN
                           ASSIGN par_menorida = NO.
                        ELSE
                           ASSIGN par_menorida = YES.

                     END.
                  ELSE
                     DO:
                        IF (par_cdhabmen = 0                             AND
                            BuscaIdade(par_dtdenasc,par_dtmvtolt) >= 18) OR
                            par_cdhabmen = 1                             THEN
                            ASSIGN par_menorida = NO.
                        ELSE
                            ASSIGN par_menorida = YES.
                      
                     END.

              END.
              
              IF NOT AVAIL crapttl THEN
                 DO:  
                    IF (par_cdhabmen = 0                             AND
                        BuscaIdade(par_dtdenasc,par_dtmvtolt) >= 18) OR
                        par_cdhabmen = 1                             THEN
                        ASSIGN par_menorida = NO.
                    ELSE
                        ASSIGN par_menorida = YES.

              END.

           END.
        ELSE
           DO:
              IF (par_cdhabmen = 0                             AND
                  BuscaIdade(par_dtdenasc,par_dtmvtolt) >= 18) OR
                  par_cdhabmen = 1                             THEN
                  ASSIGN par_menorida = NO.
              ELSE
                  ASSIGN par_menorida = YES.

           END.

        CASE par_cddopcao:

            WHEN "E" THEN DO:
                /* Verifica se ha mais de um responsavel pra poder
                   excluir e permite que um maior de idade possa
                   excluir todos os responsaveis */
               IF NOT CAN-FIND(FIRST crapcrl WHERE 
                               crapcrl.cdcooper = par_cdcooper         AND
                               crapcrl.nrctamen = par_nrdconta         AND
                               crapcrl.nrcpfmen = (IF par_nrdconta = 0 THEN
                                                      par_cpfprocu
                                                   ELSE
                                                      0)               AND
                               crapcrl.idseqmen = par_idseqttl         AND
                               ROWID(crapcrl) <> par_nrdrowid)         AND
                   par_menorida = TRUE                                 THEN
                   DO:                    
                      ASSIGN aux_dscritic = "Deve existir pelo menos um " +
                                            "responsavel legal.".
                      LEAVE Busca.
               
                   END.
                
            END.

        END CASE.

        FiltroBusca: DO ON ERROR UNDO FiltroBusca, LEAVE FiltroBusca:

            IF par_nrdrowid <> ? THEN
               DO:  
                   RUN Busca_Dados_Id ( INPUT par_cdcooper,
                                        INPUT par_nrdrowid,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cddopcao,
                                        INPUT par_nmrotina,
                                       OUTPUT aux_cdcritic,
                                       OUTPUT aux_dscritic ).

                   LEAVE Busca.

               END.
            ELSE  
               IF par_nrdctato <> 0 OR par_nrcpfcto <> 0  THEN
                  DO:
                     /* validar o cpf antes de fazer a busca */
                     IF NOT ValidaCpf(STRING(par_nrcpfcto)) AND 
                        par_nrcpfcto <> 0                   THEN
                        DO: 
                           ASSIGN aux_dscritic = "O CPF informado esta " + 
                                                 "incorreto.".
                           LEAVE Busca.

                        END.
                      
                      RUN Busca_Dados_Cto ( INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_nrdctato,
                                            INPUT par_nrcpfcto,
                                            INPUT par_dtmvtolt,
                                            INPUT par_cddopcao,
                                            INPUT par_cpfprocu,
                                            INPUT TRUE,
                                            INPUT par_nmrotina,
                                           OUTPUT aux_cdcritic,
                                           OUTPUT aux_dscritic ).
                      
                      LEAVE Busca.

                  END.

        END.
        
        IF aux_cdcritic <> 0  OR 
           aux_dscritic <> "" THEN
           LEAVE Busca.

        /* processar a busca/listagem */
        IF par_cddopcao <> "C" THEN
           LEAVE Busca.

        FOR EACH crapcrl WHERE  crapcrl.cdcooper = par_cdcooper         AND
                                crapcrl.nrctamen = par_nrdconta         AND
                                crapcrl.nrcpfmen = (IF par_nrdconta = 0 THEN 
                                                       par_cpfprocu
                                                    ELSE
                                                       0)               AND
                                crapcrl.idseqmen = par_idseqttl 
                                NO-LOCK:
            

            IF crapcrl.nrdconta <> 0 THEN
               DO: 
                   RUN Busca_Dados_Cto ( INPUT crapcrl.cdcooper,
                                         INPUT crapcrl.nrctamen,
                                         INPUT crapcrl.idseqmen,
                                         INPUT crapcrl.nrdconta,
                                         INPUT crapcrl.nrcpfcgc,
                                         INPUT par_dtmvtolt,
                                         INPUT par_cddopcao,
                                         INPUT crapcrl.nrcpfmen,
                                         INPUT FALSE,
                                         INPUT par_nmrotina,
                                         OUTPUT aux_cdcritic,
                                         OUTPUT aux_dscritic ). 

               END.
            ELSE
               DO: 
                   CREATE tt-crapcrl.
                   ASSIGN tt-crapcrl.cdcooper = crapcrl.cdcooper
                          tt-crapcrl.nrctamen = crapcrl.nrctamen
                          tt-crapcrl.nrcpfmen = crapcrl.nrcpfmen
                          tt-crapcrl.idseqmen = crapcrl.idseqmen
                          tt-crapcrl.nrdconta = crapcrl.nrdconta
                          tt-crapcrl.nrcpfcgc = crapcrl.nrcpfcgc
                          
                          tt-crapcrl.nmrespon = crapcrl.nmrespon
                          tt-crapcrl.nridenti = crapcrl.nridenti
                          tt-crapcrl.tpdeiden = crapcrl.tpdeiden
                                                                
                          tt-crapcrl.cdufiden = crapcrl.cdufiden
                          tt-crapcrl.dtemiden = crapcrl.dtemiden
                          tt-crapcrl.dtnascin = crapcrl.dtnascin
                          tt-crapcrl.cddosexo = crapcrl.cddosexo
                          tt-crapcrl.cdestciv = crapcrl.cdestciv
                          tt-crapcrl.cdnacion = crapcrl.cdnacion
                          tt-crapcrl.dsnatura = crapcrl.dsnatura
                          tt-crapcrl.cdcepres = crapcrl.cdcepres
                          tt-crapcrl.dsendres = crapcrl.dsendres
                          tt-crapcrl.nrendres = crapcrl.nrendres
                          tt-crapcrl.dscomres = crapcrl.dscomres
                          tt-crapcrl.dsbaires = crapcrl.dsbaires
                          tt-crapcrl.nrcxpost = crapcrl.nrcxpost
                          tt-crapcrl.dscidres = crapcrl.dscidres
                          tt-crapcrl.dsdufres = crapcrl.dsdufres
                          tt-crapcrl.nmpairsp = crapcrl.nmpairsp
                          tt-crapcrl.nmmaersp = crapcrl.nmmaersp.
                          
                   /* Buscar a Nacionalidade */
                   FOR FIRST crapnac FIELDS(dsnacion)
                                     WHERE crapnac.cdnacion = crapcrl.cdnacion
                                           NO-LOCK:

                       ASSIGN tt-crapcrl.dsnacion = crapnac.dsnacion.

                   END.		
                   
                   /* Retornar orgao expedidor */
                   IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                      RUN sistema/generico/procedures/b1wgen0052b.p 
                          PERSISTENT SET h-b1wgen0052b.

                   ASSIGN tt-crapcrl.dsorgemi = "".
                   RUN busca_org_expedidor IN h-b1wgen0052b 
                                     ( INPUT crapcrl.idorgexp,
                                      OUTPUT tt-crapcrl.dsorgemi,
                                      OUTPUT aux_cdcritic, 
                                      OUTPUT aux_dscritic).

                   DELETE PROCEDURE h-b1wgen0052b.   

                   IF  RETURN-VALUE = "NOK" THEN
                   DO:
                      tt-crapcrl.dsorgemi = 'NAO CADAST'.
                   END.
                  
                   /* Estado civil */
                   FOR FIRST gnetcvl FIELDS(rsestcvl)
                             WHERE gnetcvl.cdestcvl = tt-crapcrl.cdestciv 
                             NO-LOCK:
        
                       ASSIGN tt-crapcrl.dsestcvl = gnetcvl.rsestcvl.

                   END.
                    
               END.
            
            ASSIGN tt-crapcrl.cdrlcrsp = crapcrl.cdrlcrsp
                   tt-crapcrl.nrdrowid = ROWID(crapcrl)
                   tt-crapcrl.deletado = FALSE
                   tt-crapcrl.cddopcao = "C".
            

        END.
        
        /*Alteração: Busco o CPF para usa como parametro na Busca_Conta*/
        FOR FIRST crapttl FIELDS(nrcpfcgc) 
                          WHERE crapttl.cdcooper = par_cdcooper AND 
                                crapttl.nrdconta = par_nrdconta AND 
                                crapttl.idseqttl = par_idseqttl 
                                NO-LOCK:

            ASSIGN aux_nrcpfcto = crapttl.nrcpfcgc.
        
        END.

        /*Alteração:  Rotina para controle/replicacao entre contas */
        IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
            RUN sistema/generico/procedures/b1wgen0077.p 
                PERSISTENT SET h-b1wgen0077.
       
        RUN Busca_Conta IN h-b1wgen0077 ( INPUT par_cdcooper,
                                          INPUT par_nrdconta,
                                          INPUT aux_nrcpfcto,
                                          INPUT par_idseqttl,
                                         OUTPUT aux_nrdconta,
                                         OUTPUT par_msgconta,
                                         OUTPUT aux_cdcritic,
                                         OUTPUT aux_dscritic ).
        
        IF  VALID-HANDLE(h-b1wgen0077) THEN
            DELETE OBJECT h-b1wgen0077.
        
        LEAVE Busca.

    END.
    
    IF VALID-HANDLE(h-b1wgen0077) THEN
       DELETE OBJECT h-b1wgen0077.

    IF aux_dscritic <> "" OR 
       aux_cdcritic <> 0  THEN
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,           
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    ELSE 
       ASSIGN aux_retorno = "OK".

    IF par_flgerlog       AND 
       par_cddopcao = "C" THEN
       RUN proc_gerar_log (INPUT par_cdcooper,
                           INPUT par_cdoperad,
                           INPUT aux_dscritic,
                           INPUT aux_dsorigem,
                           INPUT aux_dstransa,
                           INPUT (IF aux_retorno = "OK" THEN 
                                     TRUE 
                                  ELSE 
                                     FALSE),
                           INPUT par_idseqttl, 
                           INPUT par_nmdatela, 
                           INPUT par_nrdconta, 
                          OUTPUT aux_nrdrowid).

   RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Id:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_flgcadas AS LOG                                     NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapcrl WHERE ROWID(crapcrl) = par_nrdrowid 
                                NO-LOCK.
            
        END.

        IF NOT AVAILABLE crapcrl THEN
           DO:
              ASSIGN par_dscritic = "Responsavel legal nao encontrado.".
              LEAVE Busca.

           END.

        IF crapcrl.nrdconta = 0   THEN
           DO: 
              CREATE tt-crapcrl.
                     
              BUFFER-COPY crapcrl TO tt-crapcrl.

              ASSIGN tt-crapcrl.cddopcao = par_cddopcao.
              
              /* Buscar a Nacionalidade */
              FOR FIRST crapnac FIELDS(dsnacion)
                                WHERE crapnac.cdnacion = tt-crapcrl.cdnacion
                                      NO-LOCK:

                  ASSIGN tt-crapcrl.dsnacion = crapnac.dsnacion.

              END.

              /* Estado civil */
              FOR FIRST gnetcvl FIELDS(rsestcvl)
                                WHERE gnetcvl.cdestcvl = tt-crapcrl.cdestciv
                                NO-LOCK:

                  ASSIGN tt-crapcrl.dsestcvl = gnetcvl.rsestcvl.

              END.
              
              /* Retornar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

              ASSIGN tt-crapcrl.dsorgemi = "".
              RUN busca_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT tt-crapcrl.idorgexp,
                                  OUTPUT tt-crapcrl.dsorgemi,
                                  OUTPUT par_cdcritic, 
                                  OUTPUT par_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.   

              IF  RETURN-VALUE = "NOK" THEN
              DO:
                  tt-crapcrl.dsorgemi = 'NAO CADAST.'.
              END.
              

           END.
        ELSE 
           DO:
              RUN Busca_Dados_Cto ( INPUT crapcrl.cdcooper,
                                    INPUT crapcrl.nrctamen,
                                    INPUT crapcrl.idseqmen,
                                    INPUT crapcrl.nrdconta,
                                    INPUT crapcrl.nrcpfcgc,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cddopcao,
                                    INPUT crapcrl.nrcpfmen,
                                    INPUT TRUE,
                                    INPUT par_nmrotina,
                                   OUTPUT par_cdcritic,
                                   OUTPUT par_dscritic ).

              ASSIGN tt-crapcrl.cdrlcrsp = crapcrl.cdrlcrsp.

           END.

        LEAVE Busca.

    END.

    IF par_dscritic = "" AND par_cdcritic = 0 THEN
       ASSIGN aux_retorno = "OK".
                         
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Cto: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfprocu AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_verconta AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_flgsuces AS LOG                                     NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.

    ASSIGN aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        EMPTY TEMP-TABLE tt-erro.

        IF par_verconta = TRUE THEN /*nao pode ser a mesma conta dos ass*/
           IF (par_nrdctato <> 0           AND 
               par_nrdconta <> 0)          AND
               par_cddopcao <> "E"         AND
               par_nrdctato = par_nrdconta THEN
               DO:
                  ASSIGN par_cdcritic = 121.
                  LEAVE Busca.

               END.

        /* efetua a busca tanto por nr da conta como por cpf */
        IF par_nrdctato <> 0  THEN
           FOR FIRST crabass FIELDS(inpessoa cdtipcta dtdemiss nrdconta 
                                    cdcooper nrcpfcgc)
                             WHERE crabass.cdcooper = par_cdcooper AND
                                   crabass.nrdconta = par_nrdctato 
                                   NO-LOCK:
           END.
        ELSE
        IF par_nrcpfcto <> 0 THEN 
           FOR FIRST crabass FIELDS(inpessoa cdtipcta dtdemiss nrdconta 
                                    cdcooper nrcpfcgc)
                             WHERE crabass.cdcooper = par_cdcooper AND
                                   crabass.nrcpfcgc = par_nrcpfcto 
                                   NO-LOCK:
           END.


        IF NOT AVAILABLE crabass THEN
           DO: 
              IF par_nrdctato <> 0 THEN
                 ASSIGN par_cdcritic = 9.
              ELSE
                IF (par_nrcpfcto <> 0           AND 
                    par_cpfprocu <> 0)          AND
                    par_nrcpfcto = par_cpfprocu THEN
                    ASSIGN par_dscritic = "CPF do Responsavel deve " +
                                          "ser diferente do CPF "    + 
                                          "Repres./Procurador.".

              LEAVE Busca.

           END.
             
        IF crabass.inpessoa <> 1 THEN
           DO:
              ASSIGN par_cdcritic = 833.
              LEAVE Busca.
           END.

        ASSIGN aux_flgsuces = TRUE.
        
        IF crabass.cdtipcta >= 12 THEN
           FOR EACH crabttl FIELDS(indnivel) 
                            WHERE crabttl.cdcooper = crabass.cdcooper AND
                                  crabttl.nrdconta = crabass.nrdconta 
                                  NO-LOCK:

               IF crabttl.indnivel <> 4 THEN
                  ASSIGN aux_flgsuces = FALSE.

           END.

        IF NOT aux_flgsuces                 AND
           crabass.dtdemiss = ?             AND
           crabass.nrdconta <> par_nrdctato THEN
           DO:
              ASSIGN par_cdcritic = 830.
              LEAVE Busca.

           END.
           
        /* Se responsavel legal ja estiver criado, nao criara novamente */
        FIND FIRST tt-crapcrl WHERE tt-crapcrl.cdcooper = crabass.cdcooper AND
                                    tt-crapcrl.nrdconta = par_nrdctato
                                    NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL tt-crapcrl THEN
            DO: 
                CREATE tt-crapcrl.
                ASSIGN tt-crapcrl.cdcooper = crabass.cdcooper
                       tt-crapcrl.nrctamen = par_nrdconta
                       tt-crapcrl.nrcpfmen = par_cpfprocu
                       tt-crapcrl.nrdconta = par_nrdctato
                       tt-crapcrl.nrcpfcgc = crabass.nrcpfcgc
                       tt-crapcrl.idseqmen = par_nrctremp
                       tt-crapcrl.cddopcao = par_cddopcao. 
            END.
        
        /* 1o. Titular */
        FOR FIRST crabttl FIELDS(nmextttl nrdocttl idorgexp dtemdttl dtnasttl 
                                 cdsexotl cdestcvl cdnacion dsnatura nmpaittl 
                                 nmmaettl tpdocttl cdufdttl)
                          WHERE crabttl.cdcooper = crabass.cdcooper AND
                                crabttl.nrdconta = crabass.nrdconta AND
                                crabttl.idseqttl = 1 
                                NO-LOCK:

            ASSIGN tt-crapcrl.nmrespon = crabttl.nmextttl
                   tt-crapcrl.nridenti = crabttl.nrdocttl
                   tt-crapcrl.cdufiden = crabttl.cdufdttl
                   tt-crapcrl.dtemiden = crabttl.dtemdttl
                   tt-crapcrl.dtnascin = crabttl.dtnasttl
                   tt-crapcrl.cddosexo = crabttl.cdsexotl
                   tt-crapcrl.cdestciv = crabttl.cdestcvl
                   tt-crapcrl.cdnacion = crabttl.cdnacion
                   tt-crapcrl.dsnatura = crabttl.dsnatura
                   tt-crapcrl.nmpairsp = crabttl.nmpaittl
                   tt-crapcrl.nmmaersp = crabttl.nmmaettl
                   tt-crapcrl.tpdeiden = crabttl.tpdocttl.

            /* Buscar a Nacionalidade */
            FOR FIRST crapnac FIELDS(dsnacion)
                              WHERE crapnac.cdnacion = crabttl.cdnacion
                                    NO-LOCK:

                ASSIGN tt-crapcrl.dsnacion = crapnac.dsnacion.

            END.   

            /* Retornar orgao expedidor */
            IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                RUN sistema/generico/procedures/b1wgen0052b.p 
                    PERSISTENT SET h-b1wgen0052b.

            ASSIGN tt-crapcrl.dsorgemi = "".
            RUN busca_org_expedidor IN h-b1wgen0052b 
                               ( INPUT crabttl.idorgexp,
                                OUTPUT tt-crapcrl.dsorgemi,
                                OUTPUT par_cdcritic, 
                                OUTPUT par_dscritic).

            DELETE PROCEDURE h-b1wgen0052b.   

            IF  RETURN-VALUE = "NOK" THEN
            DO:
                ASSIGN tt-crapcrl.dsorgemi = 'NAO CADAST.'.
            END.

            /* validar a idade */
            IF  BuscaIdade(crabttl.dtnasttl,par_dtmvtolt) < 18
            AND par_cddopcao <> "E" THEN
               DO:
                  IF par_nrdctato <> 0 THEN
                     DO:
                         ASSIGN par_cdcritic = 585.
                         UNDO Busca, LEAVE Busca.

                     END.
                  ELSE
                     IF par_nrcpfcto <> 0 THEN
                        DO:
                            ASSIGN par_cdcritic = 806.
                            UNDO Busca, LEAVE Busca.

                        END.

               END.            
            
        END.
        
        /* Endereco */
        FOR FIRST crapenc FIELDS(nrcepend dsendere nrendere complend nmbairro 
                                 nmcidade cdufende nrcxapst)
                          WHERE crapenc.cdcooper = crabass.cdcooper AND
                                crapenc.nrdconta = crabass.nrdconta AND
                                crapenc.idseqttl = 1                AND
                                crapenc.cdseqinc = 1                AND
                                crapenc.tpendass = 10 /*Residencial*/ 
                                NO-LOCK:

            ASSIGN tt-crapcrl.nrendres = crapenc.nrendere
                   tt-crapcrl.dscomres = crapenc.complend
                   tt-crapcrl.cdcepres = crapenc.nrcepend
                   tt-crapcrl.dsendres = crapenc.dsendere
                   tt-crapcrl.dsbaires = crapenc.nmbairro
                   tt-crapcrl.dscidres = crapenc.nmcidade
                   tt-crapcrl.dsdufres = crapenc.cdufende
                   tt-crapcrl.nrcxpost = crapenc.nrcxapst.

        END.
        
        /* Estado civil */
        FOR FIRST gnetcvl FIELDS(rsestcvl)
                          WHERE gnetcvl.cdestcvl = tt-crapcrl.cdestciv 
                          NO-LOCK:
        
            ASSIGN tt-crapcrl.dsestcvl = gnetcvl.rsestcvl.

        END.
        
        IF par_nmrotina = "RESPONSAVEL LEGAL" THEN
           DO:
              /* verificar se o resp.legal ja esta cadastrado */
              IF  CAN-FIND(FIRST crapcrl WHERE                              
                                 crapcrl.cdcooper = par_cdcooper  AND 
                                 crapcrl.nrctamen = par_nrdconta  AND       
                                 crapcrl.nrcpfmen = par_cpfprocu  AND
                                 crapcrl.idseqmen = par_nrctremp  AND
                                 crapcrl.nrdconta = par_nrdctato  AND
                                 crapcrl.nrcpfcgc = par_nrcpfcto) AND  
                  par_cddopcao = "I" THEN
                  DO:
                     ASSIGN par_dscritic = "Responsavel legal ja cadastrado.".
                     LEAVE Busca.
              
                  END.

           END.

        LEAVE Busca.

    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Dados:

  DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
  DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_nrcpfcto AS DEC                            NO-UNDO.
  DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_tpdocava AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nrdocava AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_cdoeddoc AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_cdufddoc AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dtemddoc AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_cdsexcto AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
  DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_nmmaecto AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_flgrepli AS LOG                            NO-UNDO.
  DEF  INPUT PARAM par_cpfprocu AS DEC                            NO-UNDO.
  DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.
  DEF  INPUT PARAM par_dtdenasc AS DATE                           NO-UNDO.
  DEF  INPUT PARAM par_cdhabmen AS INT                            NO-UNDO.
  DEF  INPUT PARAM par_permalte AS LOG                            NO-UNDO.
  DEF  INPUT PARAM TABLE FOR tt-cratcrl.

  DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.

  DEF VAR aux_menorida AS LOG                                     NO-UNDO.
  DEF VAR aux_idorgexp AS INT                                     NO-UNDO.

  DEF BUFFER b-tt-cratcrl FOR tt-cratcrl.
  
  &SCOPED-DEFINE CPF-RESP STRING(STRING(par_nrcpfcto,"99999999999"),"999.999.999-99")

  ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
         aux_dstransa = "Valida dados do Responsavel Legal"
         aux_dscritic = ""
         aux_cdcritic = 0
         aux_retorno = "NOK".

  Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

      EMPTY TEMP-TABLE tt-erro.

             IF par_nrdconta <> 0 THEN
                DO:
            /* verifica se eh menor de idade */
            FOR FIRST crapttl FIELDS(dtnasttl inhabmen)
                              WHERE crapttl.cdcooper = par_cdcooper AND
                                    crapttl.nrdconta = par_nrdconta AND
                                    crapttl.idseqttl = par_idseqttl 
                                    NO-LOCK:
           
                IF (par_dtdenasc = crapttl.dtnasttl OR par_dtdenasc = ?)    AND
                   par_nmrotina = "RESPONSAVEL LEGAL" THEN
                   DO:    
                      IF (crapttl.inhabmen = 0                            AND
                         BuscaIdade(crapttl.dtnasttl,par_dtmvtolt) >= 18) OR
                         crapttl.inhabmen = 1                             THEN
                         ASSIGN aux_menorida = NO.
                      ELSE
                          ASSIGN aux_menorida = YES.

                   END.
                ELSE
                   DO:
                      IF (par_cdhabmen = 0                             AND
                          BuscaIdade(par_dtdenasc,par_dtmvtolt) >= 18) OR
                          par_cdhabmen = 1                             THEN
                          ASSIGN aux_menorida = NO.
                      ELSE
                          ASSIGN aux_menorida = YES.
                    
                   END.

            END.

            IF NOT AVAIL crapttl THEN
               DO: 
                  IF (par_cdhabmen = 0                             AND
                      BuscaIdade(par_dtdenasc,par_dtmvtolt) >= 18) OR
                      par_cdhabmen = 1                             THEN
                      ASSIGN aux_menorida = NO.
                  ELSE
                      ASSIGN aux_menorida = YES.

            END.

         END.
      ELSE
         DO: 
         
            IF (par_cdhabmen = 0                             AND
                BuscaIdade(par_dtdenasc,par_dtmvtolt) >= 18) OR
                par_cdhabmen = 1                             THEN
                ASSIGN aux_menorida = NO.
            ELSE
                ASSIGN aux_menorida = YES.
             
         END.
            
      
      IF (par_nmrotina = "PROCURADORES_FISICA"        OR
          par_nmrotina = "PROCURADORES"               OR
          par_nmrotina = "Representante/Procurador" ) AND
          par_permalte = FALSE                        THEN
          DO: 
             IF par_nrdconta <> 0 THEN
                DO:
                   ASSIGN aux_dscritic = "Alteracoes devem ser realizadas " +
                                         "na tela CONTAS.".
                   LEAVE Valida.
      
                END.
          
             IF par_cddopcao <> "E" THEN        
                DO:
         
                   IF par_nrdctato = 0 AND par_cddopcao <> "I" THEN
                      DO:
                         /* validar a idade */
                         IF  BuscaIdade(par_dtnascto,par_dtmvtolt) < 18 AND 
                             par_cddopcao <> "E" THEN
                             DO:
                                ASSIGN par_nmdcampo = "dtnascto"
                                       aux_cdcritic = 585.
                        
                                LEAVE Valida.
                              END.
                          /*Valida o cpf */
                         IF  NOT ValidaCpf(STRING(par_nrcpfcto)) THEN
         DO: 
                                ASSIGN par_nmdcampo = "nrdctato"
                                       aux_dscritic = "O CPF informado esta incorreto.".
                                
             LEAVE Valida.

         END.
                      END.

      /* nao pode ter no mesmo nr. da conta do associado */
      IF NOT par_flgrepli            AND 
        (par_nrdctato <> 0           AND 
         par_nrdconta <> 0)          AND
         par_cddopcao <> "E"         AND
         par_nrdctato = par_nrdconta THEN
         DO:
            ASSIGN aux_cdcritic = 121.
            LEAVE Valida.
         END.  

      /* validar o nome do resp. legal */
      IF par_nmdavali = "" THEN
         DO:
            ASSIGN par_nmdcampo = "nmdavali"
                   aux_dscritic = "O nome do responsavel legal deve ser " +
                                  "informado.".
            LEAVE Valida.
         END.

      /* verifica se a conta esta encerrada */
      IF CAN-FIND(FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                      crapass.nrdconta = par_nrdctato AND
                                      crapass.dtelimin <> ?) THEN
      DO:
          ASSIGN par_nmdcampo = "dtelimin"
                 aux_cdcritic = 64.
          LEAVE Valida.
      END.

                   
                   
      /* tipo de documento */
      IF  LOOKUP(par_tpdocava,"CI,CH,CP,CT") = 0 THEN
          DO:
             ASSIGN par_nmdcampo = "tpdocava"
                    aux_cdcritic = 21.
             LEAVE Valida.
          END.



      /* orgao emissor do documento */
      IF  par_cdoeddoc = "" THEN
          DO:
             ASSIGN par_nmdcampo = "cdoeddoc"
                    aux_dscritic = "O orgao emissor do documento deve " +
                                   "ser informado.".
             LEAVE Valida.
          END.

      /* Identificar orgao expedidor */
      IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
          RUN sistema/generico/procedures/b1wgen0052b.p 
              PERSISTENT SET h-b1wgen0052b.

      ASSIGN aux_idorgexp = 0.
      RUN identifica_org_expedidor IN h-b1wgen0052b 
                         ( INPUT par_cdoeddoc,
                          OUTPUT aux_idorgexp,
                          OUTPUT aux_cdcritic, 
                          OUTPUT aux_dscritic).

      DELETE PROCEDURE h-b1wgen0052b.   

      IF  RETURN-VALUE = "NOK" THEN
      DO:
          LEAVE Valida.
      END.    

      /* unidade da federacao emissora do documento */
      IF  LOOKUP(par_cdufddoc,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                              "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                              "RS,RO,RR,SC,SP,SE,TO,EX") = 0 THEN
          DO:
             ASSIGN par_nmdcampo = "cdufddoc"
                    aux_cdcritic = 33.
                           LEAVE Valida.
                       END. 
                   
                   /* nr. do documento */
                   IF  par_nrdocava  = "" THEN
                       DO:
                          ASSIGN par_nmdcampo = "nrdocava"
                                 aux_cdcritic = 22.  

             LEAVE Valida.

          END.

      /* validar a data de emissao do documento */
      IF  par_dtemddoc = ? THEN
          DO:
             ASSIGN par_nmdcampo = "dtemddoc"
                    aux_cdcritic = 13.
             LEAVE Valida.
          END.

      /* validar a data de nascimento */
      IF  par_dtnascto = ? THEN
          DO:
             ASSIGN par_nmdcampo = "dtnascto"
                    aux_cdcritic = 13.
             LEAVE Valida.
          END.

      IF  par_dtemddoc > par_dtmvtolt THEN
          DO:
             ASSIGN par_nmdcampo = "dtemddoc"
                    aux_dscritic = "A data de emissao do documento nao " +
                                   "pode ser maior que a data do sistema.".
             LEAVE Valida.
          END.

      /* validar a data de nascimento */
      IF  par_dtnascto > par_dtmvtolt THEN
          DO:
             ASSIGN par_nmdcampo = "dtnascto"
                    aux_dscritic = "A data de nascimento nao pode ser " +
                                   "maior que a data do sistema.".
             LEAVE Valida.
          END.

      /* validar a idade */
                   IF  BuscaIdade(par_dtnascto,par_dtmvtolt) < 18 AND 
                       par_cddopcao <> "E"                       THEN
          DO:
             ASSIGN par_nmdcampo = "dtnascto"
                    aux_cdcritic = 585.
             LEAVE Valida.
          END.

      /* validar o sexo, 1=M e 2=F */
      IF  par_cdsexcto <> 1 AND 
          par_cdsexcto <> 2 THEN
          DO:
             ASSIGN par_nmdcampo = "cdsexcto"
                    aux_dscritic = "O campo Sexo deve ser (M) ou (F).".
             LEAVE Valida.
          END.

      /* validar o estado civil */
      IF  NOT CAN-FIND(gnetcvl WHERE gnetcvl.cdestcvl = par_cdestcvl) THEN
          DO:
             ASSIGN par_nmdcampo = "cdestcvl"
                    aux_cdcritic = 35.
             LEAVE Valida.
          END.

      /* validar a nacionalidade */
      IF  NOT CAN-FIND(crapnac WHERE crapnac.cdnacion = par_cdnacion) THEN
          DO:
             ASSIGN par_nmdcampo = "dsnacion"
                    aux_cdcritic = 28.
             LEAVE Valida.
          END.

      /* validar a naturalidade */
      IF  NOT CAN-FIND(crapmun WHERE crapmun.dscidade = par_dsnatura  AND 
                                     crapmun.cdestado = par_cdufddoc) AND 
          par_cdufddoc <> "EX"                                        AND 
          par_cddopcao <> "E"                                         THEN
          DO:
             ASSIGN par_nmdcampo = "dsnatura"
                    aux_cdcritic = 29.
             LEAVE Valida.
          END.

      IF  par_nrdctato = 0  THEN
          DO:
              /* validar o endereco */
              IF  par_dsendere = "" THEN
                  DO:
                     ASSIGN par_nmdcampo = "dsendere"
                            aux_cdcritic = 31.
                     LEAVE Valida.
                  END.
      
              /* validar o bairro */
              IF  par_nmbairro = "" THEN
                  DO:
                     ASSIGN par_nmdcampo = "nmbairro"
                            aux_cdcritic = 47.
                     LEAVE Valida.
                  END.
      
              /* validar a cidade */
              IF  par_nmcidade = "" THEN
                  DO:
                     ASSIGN par_nmdcampo = "nmcidade"
                            aux_cdcritic = 32.
                     LEAVE Valida.
                  END.
      
              /* unidade da federacao da cidade do endereco */
              IF  LOOKUP(par_cdufende,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                                      "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                                      "RS,RO,RR,SC,SP,SE,TO,EX") = 0 THEN
                  DO:
                     ASSIGN par_nmdcampo = "cdufende"
                            aux_dscritic = "Unidade da Federacao do " + 
                                           "endereco esta incorreta.".
                     LEAVE Valida.
                  END.
      
              IF par_cddopcao <> "E" THEN
                DO:
                    /* validar o nr do cep */
                    IF  par_nrcepend = 0 THEN
                      DO:
                         ASSIGN par_nmdcampo = "nrcepend"
                                aux_cdcritic = 34.
                    
                         LEAVE Valida.
                      END.
                                ELSE IF  NOT CAN-FIND(FIRST crapdne 
                                   WHERE crapdne.nrceplog = par_nrcepend)  THEN
                      DO:
                          ASSIGN par_nmdcampo = "nrcepend"
                                 aux_dscritic = "CEP nao cadastrado.".
                    
                          LEAVE Valida.
                      END.
                    IF  NOT CAN-FIND(FIRST crapdne
                                     WHERE crapdne.nrceplog = par_nrcepend  
                                       AND (TRIM(par_dsendere) MATCHES 
                                           ("*" + TRIM(crapdne.nmextlog) + "*")
                                        OR TRIM(par_dsendere) MATCHES
                                                       ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
                            DO:
                              ASSIGN aux_dscritic = "Endereco nao pertence ao CEP."
                                     par_nmdcampo = "nrcepend".
                              LEAVE Valida.
                            END.
                END.
                        END.

                

      /* validar o nome da mae */
      IF  par_nmmaecto = "" THEN
          DO:
             ASSIGN par_nmdcampo = "nmmaecto"
                    aux_dscritic = "O nome da mae deve ser informado.".
                            LEAVE Valida.
                        END.
                
                END.
         
          END.

      IF par_cddopcao = "DT" THEN
         DO: 
             ASSIGN aux_retorno = "OK".
             LEAVE Valida.

          END.
      
      IF (par_idorigem <> 5                    AND
          par_nmrotina = "RESPONSAVEL LEGAL")   OR
         (par_idorigem = 5                     AND 
          par_nmrotina = "RESPONSAVEL LEGAL")  THEN
         DO:
            IF par_cddopcao = "I" THEN
               DO:
                  IF CAN-FIND(crapcrl 
                              WHERE crapcrl.cdcooper = par_cdcooper         AND 
                                    crapcrl.nrctamen = par_nrdconta         AND
                                    crapcrl.nrcpfmen = (IF par_nrdconta = 0 THEN
                                                           par_cpfprocu
                                                        ELSE 
                                                           0)               AND 
                                    crapcrl.idseqmen = par_idseqttl         AND
                                    crapcrl.nrdconta = par_nrdctato         AND
                                    crapcrl.nrcpfcgc = (IF par_nrdctato = 0 THEN 
                                                           par_nrcpfcto
                                                        ELSE
                                                           0))              THEN
                     DO:
                         ASSIGN aux_dscritic = "Responsavel ja cadastrado " +
                                               "para o titular.".
                         LEAVE Valida.
            
                     END.
            
               END.
            
            IF par_cddopcao = "E" THEN
               DO:
                   /* Verifica se ha mais de um responsavel pra poder
                     excluir e permite que um maior de idade possa
                     excluir todos os responsaveis */
                  IF NOT (par_flgrepli) AND /*Se não foi chamado da replicacao*/
                     NOT CAN-FIND(FIRST crapcrl WHERE
                                  crapcrl.cdcooper = par_cdcooper          AND
                                  crapcrl.nrctamen = par_nrdconta          AND
                                  crapcrl.nrcpfmen = (IF par_nrdconta = 0  THEN 
                                                         par_cpfprocu
                                                      ELSE
                                                         0)                AND
                                  crapcrl.idseqmen = par_idseqttl          AND
                                  ROWID(crapcrl)  <> par_nrdrowid NO-LOCK) AND
                     aux_menorida = YES THEN
                     DO: 
                        ASSIGN aux_dscritic = "Deve existir pelo menos um " +
                                              "responsavel legal.".
                        LEAVE Valida.

                     END.
            
                  LEAVE Valida.
            
               END.

         END.
      ELSE
         DO: 
            IF par_cddopcao = "C" OR 
               par_cddopcao = "A" THEN
               LEAVE Valida.
            
            FIND FIRST tt-cratcrl WHERE 
                       tt-cratcrl.cdcooper = par_cdcooper     AND
                       tt-cratcrl.nrctamen = par_nrdconta     AND
                      (IF par_nrdconta = 0 THEN
                          tt-cratcrl.nrcpfmen = par_cpfprocu
                       ELSE
                          TRUE)                               AND
                       tt-cratcrl.idseqmen = par_idseqttl     AND
                       tt-cratcrl.nrdconta = par_nrdctato     AND
                       tt-cratcrl.cddopcao = "C"              
                       NO-LOCK NO-ERROR.
                   

            IF AVAIL tt-cratcrl THEN
               DO: 
                  ASSIGN aux_dscritic = "Responsavel legal ja cadastrado.".
                  
                  LEAVE Valida.

               END.
            ELSE
               DO:
                  IF par_nrdctato <> 0 THEN
                     DO: 
                         FOR EACH tt-cratcrl WHERE 
                                  tt-cratcrl.cdcooper = par_cdcooper    AND
                                  tt-cratcrl.nrctamen = par_nrdconta    AND
                                 (IF par_nrdconta = 0 THEN
                                     tt-cratcrl.nrcpfmen = par_cpfprocu
                                  ELSE
                                     TRUE)                              AND
                                  tt-cratcrl.idseqmen = par_idseqttl    AND
                                  tt-cratcrl.nrdconta = par_nrdctato    AND
                                  tt-cratcrl.cddopcao = "I"      
                                  NO-LOCK:

                             FIND FIRST b-tt-cratcrl WHERE 
                                  b-tt-cratcrl.cdcooper = par_cdcooper    AND
                                  b-tt-cratcrl.nrctamen = par_nrdconta    AND
                                 (IF par_nrdconta = 0 THEN
                                     b-tt-cratcrl.nrcpfmen = par_cpfprocu
                                  ELSE
                                     TRUE)                                AND
                                  b-tt-cratcrl.idseqmen = par_idseqttl    AND
                                  b-tt-cratcrl.nrdconta = par_nrdctato    AND
                                  b-tt-cratcrl.cddopcao = "I"             AND
                                  ROWID(b-tt-cratcrl) <> ROWID(tt-cratcrl)
                                  NO-LOCK NO-ERROR.
                                   
                             IF AVAIL b-tt-cratcrl THEN
                                DO: 
                                   ASSIGN aux_dscritic = "Responsavel legal " + 
                                                         "ja cadastrado.".
                                   
                                   LEAVE Valida.
                                   
                                END. 

                         END.

                     END.
                  ELSE
                     DO:
                        FOR EACH b-tt-cratcrl WHERE
                                 b-tt-cratcrl.cdcooper = par_cdcooper    AND
                                 b-tt-cratcrl.nrctamen = par_nrdconta    AND
                                 b-tt-cratcrl.nrcpfmen = par_cpfprocu    AND
                                 b-tt-cratcrl.idseqmen = par_idseqttl    AND
                                 b-tt-cratcrl.nrdconta = par_nrdctato    AND
                                (IF par_nrdctato = 0 THEN 
                                    b-tt-cratcrl.nrcpfcgc = par_nrcpfcto
                                 ELSE
                                    TRUE)                                AND
                                 b-tt-cratcrl.cddopcao = "I"                  
                                 NO-LOCK:

                            FIND FIRST tt-cratcrl WHERE 
                                 tt-cratcrl.cdcooper = par_cdcooper    AND
                                 tt-cratcrl.nrctamen = par_nrdconta    AND
                                (IF par_nrdconta = 0 THEN
                                    tt-cratcrl.nrcpfmen = par_cpfprocu
                                 ELSE
                                    TRUE) AND
                                 tt-cratcrl.idseqmen = par_idseqttl    AND
                                 tt-cratcrl.nrdconta = par_nrdctato    AND
                                (IF par_nrdctato = 0 THEN
                                    tt-cratcrl.nrcpfcgc = par_nrcpfcto
                                 ELSE
                                    TRUE)                              AND
                                 tt-cratcrl.cddopcao = "I"             AND
                                 ROWID(tt-cratcrl) <> ROWID(b-tt-cratcrl)
                                 NO-LOCK NO-ERROR.
                               
                             IF AVAIL tt-cratcrl THEN
                                DO: 
                                   ASSIGN aux_dscritic = "Responsavel legal " +
                                                         "ja cadastrado.".
                                   
                                   LEAVE Valida.
                                   
                                END. 
                        
                        END. 

                     END.

               END.

            FOR EACH tt-cratcrl WHERE
                     tt-cratcrl.nrctamen = par_nrdconta         AND
                     tt-cratcrl.nrcpfmen = (IF par_nrdconta = 0 THEN 
                                               par_cpfprocu
                                            ELSE 
                                              0 )               AND 
                     tt-cratcrl.nrdconta = par_nrdctato         AND
                     tt-cratcrl.cddopcao <> "C"                    
                     NO-LOCK:

                IF CAN-FIND(FIRST b-tt-cratcrl WHERE
                       b-tt-cratcrl.nrctamen = tt-cratcrl.nrctamen         AND
                       b-tt-cratcrl.nrcpfmen = (IF tt-cratcrl.nrctamen = 0 THEN
                                                   tt-cratcrl.nrcpfmen
                                                ELSE
                                                   0)                      AND
                       b-tt-cratcrl.nrdconta = tt-cratcrl.nrdconta         AND
                       b-tt-cratcrl.nrcpfcgc = tt-cratcrl.nrcpfcgc         AND
                       b-tt-cratcrl.deletado = NO                          AND
                      (ROWID(b-tt-cratcrl)   <> ROWID(tt-cratcrl)          OR
                       b-tt-cratcrl.nrdrowid <> tt-cratcrl.nrdrowid))      AND 
                    tt-cratcrl.cddopcao <> "A"                             AND
                    tt-cratcrl.cddopcao <> "E"                             THEN
                    DO:
                       ASSIGN aux_dscritic = "Ja existe Responsavel Legal" +
                                             " cadastrado " +
                                             "com o CPF " + {&CPF-RESP}.
                       LEAVE Valida.
                
                    END.

            END.

            /* Verifica se ha mais de um responsavel pra poder
             excluir e permite que um maior de idade possa
             excluir todos os responsaveis */
            IF NOT (par_flgrepli) AND /*Se não foi chamado da replicacao*/
               NOT CAN-FIND(FIRST tt-cratcrl WHERE 
                                  tt-cratcrl.deletado = NO     AND
                                  tt-cratcrl.cddopcao <> "E")  AND
               aux_menorida = YES                              AND 
               par_cddopcao = "E"                              THEN
               DO: 
                  ASSIGN aux_dscritic = "Cooperado menor de idade. " + 
                                        "Obrigatorio Responsavel Legal".
                  
                  LEAVE Valida.
          
               END.
            
         END.

      LEAVE Valida.

  END.

  IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
      RUN gera_erro (INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT 1,           
                     INPUT aux_cdcritic,
                     INPUT-OUTPUT aux_dscritic).
  ELSE 
      ASSIGN aux_retorno = "OK".

  IF  par_flgerlog AND aux_retorno <> "OK" THEN
      RUN proc_gerar_log (INPUT par_cdcooper,
                          INPUT par_cdoperad,
                          INPUT aux_dscritic,
                          INPUT aux_dsorigem,
                          INPUT aux_dstransa,
                          INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
                          INPUT par_idseqttl, 
                          INPUT par_nmdatela, 
                          INPUT par_nrdconta, 
                         OUTPUT aux_nrdrowid).

  RETURN aux_retorno.

END PROCEDURE.


PROCEDURE Grava_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocava AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocava AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoeddoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufddoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemddoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexcto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaecto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaicto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfprocu AS DEC                            NO-UNDO.
    DEF  INPUT PARAM par_cdrlcrsp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEFINE BUFFER bcrapttl FOR crapttl.
    DEFINE BUFFER b-crapcrl1 FOR crapcrl.
    DEFINE BUFFER b-crapass1 FOR crapass.
    
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_flgerlog AS LOG                                     NO-UNDO.
    DEF VAR aux_ctrldele AS LOG INIT FALSE                          NO-UNDO.
    DEF VAR aux_qtddeavt AS INT                                     NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INT                                     NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_idorgexp AS INT                                     NO-UNDO.
    

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF par_cddopcao = "E" THEN 
                              "Exclui" 
                           ELSE 
                              IF par_cddopcao = "I" THEN
                                 "Inclui" 
                              ELSE 
                                 "Altera") + " dados do Responsavel Legal"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno  = "NOK"
           aux_flgerlog = par_flgerlog
           par_flgerlog = (IF par_nmrotina = "PROCURADORES" THEN
                              FALSE
                           ELSE
                              aux_flgerlog)
           aux_qtddeavt = 0
           aux_dsrotina = "".
     
    EMPTY TEMP-TABLE tt-erro.  

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        ContadorCrl: DO aux_contador = 1 TO 10:

            FIND crapcrl WHERE crapcrl.cdcooper = par_cdcooper         AND
                               crapcrl.nrctamen = par_nrdconta         AND
                               crapcrl.nrcpfmen = (IF par_nrdconta = 0 THEN 
                                                      par_cpfprocu
                                                   ELSE
                                                      0)               AND
                               crapcrl.idseqmen = par_idseqttl         AND
                               crapcrl.nrdconta = par_nrdctato         AND
                               crapcrl.nrcpfcgc = (IF par_nrdctato = 0 THEN 
                                                      par_nrcpfcto
                                                   ELSE
                                                      0)
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF NOT AVAILABLE crapcrl THEN
               DO:
                  IF LOCKED(crapcrl) THEN
                     DO:
                        IF aux_contador = 10 THEN
                           DO:
                              ASSIGN aux_cdcritic = 341.
                              LEAVE ContadorCrl.

                           END.
                        ELSE 
                           DO:
                               PAUSE 1 NO-MESSAGE.
                               NEXT ContadorCrl.

                           END.
                     END.
                  ELSE 
                     DO: 
                        IF par_cddopcao = "I" THEN
                           DO: 
                              CREATE crapcrl.

                              ASSIGN crapcrl.cdcooper = par_cdcooper
                                     crapcrl.nrctamen = par_nrdconta
                                     crapcrl.nrcpfmen = (IF par_nrdconta = 0 THEN 
                                                            par_cpfprocu
                                                         ELSE
                                                            0)
                                     crapcrl.idseqmen = par_idseqttl 
                                     crapcrl.nrdconta = par_nrdctato 
                                     crapcrl.nrcpfcgc = (IF par_nrdctato = 0 THEN 
                                                            par_nrcpfcto
                                                         ELSE
                                                            0)
                                    crapcrl.dtmvtolt  = par_dtmvtolt
                                    crapcrl.flgimpri  = TRUE.
                              VALIDATE crapcrl.
                              LEAVE ContadorCrl.

                           END.
                        ELSE 
                           IF par_nmrotina <> "RESPONSAVEL LEGAL" AND 
                              par_cddopcao = "A"                  THEN
                              DO:
                                 CREATE crapcrl.

                                 ASSIGN crapcrl.cdcooper = par_cdcooper
                                        crapcrl.nrctamen = par_nrdconta
                                        crapcrl.nrcpfmen = par_cpfprocu
                                        crapcrl.idseqmen = par_idseqttl 
                                        crapcrl.nrdconta = par_nrdctato 
                                        crapcrl.nrcpfcgc = par_nrcpfcto
                                        crapcrl.flgimpri = TRUE.
                                 VALIDATE crapcrl.

                                 LEAVE ContadorCrl.

                              END.
                           ELSE
                              IF par_nmrotina <> "RESPONSAVEL LEGAL" AND 
                                 par_cddopcao = "E"                  THEN
                                 DO:    
                                    ASSIGN aux_ctrldele = TRUE. 
                                 END.
                              ELSE
                                 DO:
                                    aux_dscritic = "Dados do Responsavel Legal " +
                                                   "nao foram encontrados.".
                                    LEAVE ContadorCrl.
                                  
                                 END.

                     END.
               END.
            ELSE 
               LEAVE ContadorCrl.

        END.
        
        IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.

        IF par_nmrotina = "RESPONSAVEL LEGAL" AND 
           CAN-DO("A,I", par_cddopcao)        THEN DO:
            
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl
                               NO-LOCK NO-ERROR.
            IF NOT AVAILABLE crapttl THEN 
               DO:
                 aux_dscritic = "Erro ao consultar titular.".
               END.
            ELSE 
              DO:
                ContadorDoc: DO aux_contador = 1 TO 10:
        
                          FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                                   crapdoc.nrdconta = par_nrdconta AND
                                                   crapdoc.tpdocmto = 51           AND
                                                   crapdoc.dtmvtolt = par_dtmvtolt AND
                                                   crapdoc.idseqttl = par_idseqttl AND 
                                                   crapdoc.nrcpfcgc = crapttl.nrcpfcgc
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
                          IF NOT AVAILABLE crapdoc THEN
                              DO:
                                  IF LOCKED(crapdoc) THEN
                                      DO:
                                          IF aux_contador = 10 THEN
                                              DO:
                                                  ASSIGN aux_cdcritic = 341.
                                                  LEAVE ContadorDoc.
                                              END.
                                          ELSE 
                                              DO: 
                                                  PAUSE 1 NO-MESSAGE.
                                                  NEXT.
                                              END.
                                      END.
                                  ELSE
                                      DO: 
                                          CREATE crapdoc.
                                          ASSIGN crapdoc.cdcooper = par_cdcooper
                                                 crapdoc.nrdconta = par_nrdconta
                                                 crapdoc.flgdigit = FALSE
                                                 crapdoc.dtmvtolt = par_dtmvtolt
                                                 crapdoc.tpdocmto = 51
                                                 crapdoc.idseqttl = par_idseqttl
                                                 crapdoc.nrcpfcgc = crapttl.nrcpfcgc.
                                          VALIDATE crapdoc.        
                                          LEAVE ContadorDoc.
                                      END.
                              END.
                          ELSE
                              DO:
                                  ASSIGN crapdoc.flgdigit = FALSE
                                         crapdoc.dtmvtolt = par_dtmvtolt.
          
                                  LEAVE ContadorDoc.
                              END.
                      END.
                  END.
        END.
        
        IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
           UNDO Grava, LEAVE Grava.

        EMPTY TEMP-TABLE tt-crapcrl-ant.
        EMPTY TEMP-TABLE tt-crapcrl-atl.
        
        IF aux_ctrldele = TRUE THEN
          DO:
             ASSIGN aux_retorno = "OK".
          
             LEAVE Grava.

          END.

        CREATE tt-crapcrl-ant.

        IF par_cddopcao <> "I" THEN
           BUFFER-COPY crapcrl TO tt-crapcrl-ant.

        CASE par_cddopcao:
            WHEN "E" THEN DO:
                 DELETE crapcrl.
                 RELEASE crapenc. 

            END.
            WHEN "A" THEN DO:

                /* Um responsavel que abriu uma nova conta */
                IF  par_nrdctato <> 0 THEN
                    ASSIGN crapcrl.nrdconta = par_nrdctato
                           crapcrl.flgimpri = TRUE.
            END.
            WHEN "I" THEN DO:
                /* Endereco */
                FIND crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                   crapenc.nrdconta = par_nrdctato AND
                                   crapenc.idseqttl = 1            AND
                                   crapenc.cdseqinc = 1            AND
                                   crapenc.tpendass = 10 /*Residencial*/
                                   NO-LOCK NO-ERROR.
            END.
            OTHERWISE DO:
                ASSIGN aux_dscritic = "Opcao deve ser (I=Incluir) (A=Alterar)" 
                                      + " ou (E=Excluir).".
                UNDO Grava, LEAVE Grava.
            END.

        END CASE.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
        
        IF  AVAIL(crapass)    AND 
            par_flgerlog      AND
            par_nrdconta <> 0 THEN  
            DO:
                { sistema/generico/includes/b1wgenalog.i }

            END.
                
        /* Se nao for associado ou esta demitido guarda os dados */
        IF par_nrdctato = 0    AND 
           par_cddopcao <> "E" THEN
           DO: 
           
              /* Identificar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                  RUN sistema/generico/procedures/b1wgen0052b.p 
                      PERSISTENT SET h-b1wgen0052b.

              ASSIGN aux_idorgexp = 0.
              RUN identifica_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT par_cdoeddoc,
                                  OUTPUT aux_idorgexp,
                                  OUTPUT aux_cdcritic, 
                                  OUTPUT aux_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.   

              IF  RETURN-VALUE = "NOK" THEN
              DO:
                  UNDO Grava, LEAVE Grava.
              END.    
           
           
              ASSIGN crapcrl.nmrespon = UPPER(par_nmdavali)
                     crapcrl.tpdeiden = UPPER(par_tpdocava)
                     crapcrl.nridenti = par_nrdocava
                     crapcrl.idorgexp = aux_idorgexp
                     crapcrl.cdufiden = UPPER(par_cdufddoc)
                     crapcrl.dtemiden = par_dtemddoc
                     crapcrl.dtnascin = par_dtnascto
                     crapcrl.cddosexo = par_cdsexcto 
                     crapcrl.cdestciv = par_cdestcvl
                     crapcrl.cdnacion = par_cdnacion
                     crapcrl.dsnatura = UPPER(par_dsnatura)
                     crapcrl.cdcepres = par_nrcepend
                     crapcrl.dsendres = UPPER(par_dsendere)
                     crapcrl.nrendres = par_nrendere
                     crapcrl.dscomres = UPPER(par_complend)
                     crapcrl.dsbaires = UPPER(par_nmbairro)
                     crapcrl.dscidres = UPPER(par_nmcidade)
                     crapcrl.dsdufres = UPPER(par_cdufende)
                     crapcrl.nrcxpost = par_nrcxapst
                     crapcrl.nmmaersp = UPPER(par_nmmaecto)
                     crapcrl.nmpairsp = UPPER(par_nmpaicto).

           END.

        CREATE tt-crapcrl-atl.

        IF  par_cddopcao <> "E" THEN
            DO:
                ASSIGN crapcrl.cdrlcrsp = par_cdrlcrsp.

                BUFFER-COPY crapcrl TO tt-crapcrl-atl.
            END.

        IF  AVAIL(crapass)    AND
            par_flgerlog      AND 
            par_nrdconta <> 0 THEN 
            DO:  
                { sistema/generico/includes/b1wgenllog.i }
                
            END.

        /* Realiza a replicacao dos dados p/as contas relacionadas ao coop. */
        IF  par_idseqttl = 1        AND 
            par_nmdatela = "CONTAS" THEN 
            DO:
                
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
  
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "RESPONSAVEL",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ).

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.

               IF  RETURN-VALUE <> "OK" THEN
                   UNDO Grava, LEAVE Grava.

               FIND FIRST bcrapttl WHERE bcrapttl.cdcooper = par_cdcooper AND
                                         bcrapttl.nrdconta = par_nrdconta AND
                                         bcrapttl.idseqttl = par_idseqttl
                                         NO-ERROR.
    
               IF AVAILABLE bcrapttl THEN DO:
                    
                   IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                       RUN sistema/generico/procedures/b1wgen0077.p
                           PERSISTENT SET h-b1wgen0077.
                   
                   RUN Revisao_Cadastral IN h-b1wgen0077
                     ( INPUT par_cdcooper,
                       INPUT bcrapttl.nrcpfcgc,
                       INPUT par_nrdconta,
                      OUTPUT par_msgalert ).
                   
                   IF  VALID-HANDLE(h-b1wgen0077) THEN
                       DELETE OBJECT h-b1wgen0077. 

               END.

            END.

        /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
        IF NOT VALID-HANDLE(h-b1wgen0168) THEN
           RUN sistema/generico/procedures/b1wgen0168.p
               PERSISTENT SET h-b1wgen0168.
                 
        EMPTY TEMP-TABLE tt-crapcyb.

        CREATE tt-crapcyb.
        ASSIGN tt-crapcyb.cdcooper = par_cdcooper
               tt-crapcyb.nrdconta = par_nrdconta
               tt-crapcyb.dtmancad = par_dtmvtolt.

        RUN atualiza_data_manutencao_cadastro
            IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic).
                 
        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.
        /* FIM - Atualizar os dados da tabela crapcyb */
         
        ASSIGN aux_retorno = "OK".
           
        LEAVE Grava.

    END.

    IF VALID-HANDLE(h-b1wgen0077) THEN
       DELETE OBJECT h-b1wgen0077.

    IF VALID-HANDLE(h-b1wgen0168) THEN
       DELETE PROCEDURE(h-b1wgen0168).

    RELEASE crapcrl.
    

    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,           
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    ELSE 
       ASSIGN aux_retorno = "OK".
                               
    IF aux_retorno = "OK"  AND 
       par_cddopcao <> "E" AND par_cddopcao <> "A" THEN
       
       Cad_Restritivo:
       DO WHILE TRUE:

          IF par_nrdctato <> 0 THEN
             DO:

                FIND b-crapass1 WHERE b-crapass1.cdcooper = par_cdcooper AND
                                      b-crapass1.nrdconta = par_nrdctato
                                      NO-LOCK NO-ERROR.

                IF NOT AVAIL b-crapass1 THEN
                   DO:
                      ASSIGN aux_cdcritic = 9.
                            
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
              
                      ASSIGN aux_retorno = "NOK".
              
                      LEAVE Cad_Restritivo.

                   END.

             END.

          IF par_nrcpfcto <> 0 THEN
             DO:
                IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                   RUN sistema/generico/procedures/b1wgen9999.p 
                       PERSISTENT SET h-b1wgen9999.

                RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT par_nrcpfcto,
                                                    OUTPUT aux_inpessoa,
                                                    OUTPUT aux_stsnrcal).

                IF VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE PROCEDURE h-b1wgen9999.

                IF NOT aux_stsnrcal THEN
                   DO:
                      ASSIGN aux_cdcritic = 9.

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
              
                      ASSIGN aux_retorno = "NOK".
              
                      LEAVE Cad_Restritivo.

                   END.

             END.

          /*Monta a mensagem da rotina para envio no e-mail*/
          ASSIGN aux_dsrotina = "Inclusao/alteracao "                        +
                                "do Responsavel Legal conta "                +
                               (IF AVAIL b-crapass1 THEN 
                                   STRING(b-crapass1.nrdconta,"zzzz,zzz,9")  +
                                   " - CPF/CNPJ "                            +
                                   (IF b-crapass1.inpessoa = 1 THEN
                                       STRING((STRING(b-crapass1.nrcpfcgc,
                                                      "99999999999")),
                                                      "xxx.xxx.xxx-xx")
                                    ELSE
                                       STRING((STRING(b-crapass1.nrcpfcgc,
                                                     "99999999999999")),
                                                     "xx.xxx.xxx/xxxx-xx"))
                                 ELSE
                                    STRING(par_nrdctato,"zzzz,zzz,9")        +
                                    " - CPF/CNPJ "                           +
                                   (IF aux_inpessoa = 1 THEN
                                       STRING((STRING(par_nrcpfcto,
                                                      "99999999999")),
                                                      "xxx.xxx.xxx-xx")
                                    ELSE
                                       STRING((STRING(par_nrcpfcto,
                                                     "99999999999999")),
                                                     "xx.xxx.xxx/xxxx-xx"))) +
                                   
                                   " na conta "                      +
                                   STRING(par_nrdconta,"zzzz,zzz,9") +
                                   " CPF/CNPJ "                      +  
                                   STRING((STRING(par_cpfprocu, "99999999999")),
                                        "xxx.xxx.xxx-xx").
                           
          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p
                 PERSISTENT SET h-b1wgen0110.
          
          /*Verifica se o associado esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          IF par_cddopcao <> "I" THEN
          DO:
              RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_dtmvtolt,
                                                INPUT par_idorigem,
                                                INPUT (IF par_nrdconta <> 0 AND AVAIL bcrapttl THEN 
                                                     bcrapttl.nrcpfcgc
                                                 ELSE
                                                     par_cpfprocu), 
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT FALSE, /*nao bloq. operacao*/
                                                INPUT 26, /*cdoperac*/
                                                INPUT aux_dsrotina,
                                                OUTPUT TABLE tt-erro).
    
              IF RETURN-VALUE <> "OK" THEN
                 DO:
                    IF VALID-HANDLE(h-b1wgen0110) THEN
                       DELETE PROCEDURE(h-b1wgen0110).
              
                    IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                       DO:
                          ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                                "cadastro restritivo.".
                          
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1, /*sequencia*/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
              
                       END.
              
                    ASSIGN aux_retorno = "NOK".
    
                    LEAVE Cad_Restritivo.
              
                 END.
          END.

          /*Verifica se o Resp.Legal esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT (IF AVAIL b-crapass1 THEN 
                                                      b-crapass1.nrcpfcgc
                                                   ELSE
                                                      par_nrcpfcto),
                                            INPUT (IF AVAIL b-crapass1 THEN 
                                                      b-crapass1.nrdconta
                                                   ELSE
                                                      par_nrdctato),
                                            INPUT 1, /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 26, /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).

          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE(h-b1wgen0110).
          
          IF RETURN-VALUE <> "OK" THEN
             DO:
                IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                      ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                            "cadastro restritivo.".
                      
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT 1, /*sequencia*/
                                     INPUT aux_cdcritic,
                                     INPUT-OUTPUT aux_dscritic).
          
                   END.
          
                ASSIGN aux_retorno = "NOK".

                LEAVE Cad_Restritivo.
          
             END.            

          LEAVE Cad_Restritivo.

       END.                      
       
    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_retorno = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl,
              INPUT par_nmdatela,
              INPUT par_nrdconta,
              INPUT YES,
              INPUT BUFFER tt-crapcrl-ant:HANDLE,
              INPUT BUFFER tt-crapcrl-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.

/*............................. FUNCTIONS ...................................*/
FUNCTION ValidaCpf RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER     NO-UNDO.

    /* Se houve erro na conversao para DEC, faz a critica */
    DEC(par_nrcpfcgc) NO-ERROR.
    
    IF   ERROR-STATUS:ERROR   THEN
         RETURN FALSE.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT par_nrcpfcgc,
                                         OUTPUT aux_stsnrcal,
                                         OUTPUT aux_inpessoa).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN aux_stsnrcal.
        
END FUNCTION.

FUNCTION BuscaIdade RETURNS INTEGER 
    ( INPUT par_dtnascto AS DATE,
      INPUT par_dtmvtolt AS DATE ):

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrdeanos AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrdmeses AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dsdidade AS CHARACTER   NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN idade IN h-b1wgen9999 (INPUT par_dtnascto,
                               INPUT par_dtmvtolt,
                               OUTPUT aux_nrdeanos,
                               OUTPUT aux_nrdmeses,
                               OUTPUT aux_dsdidade).

    DELETE OBJECT h-b1wgen9999.

    RETURN aux_nrdeanos.

END FUNCTION.

PROCEDURE BuscaResponsavelLegal:

    DEF  INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                               NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                               NO-UNDO.
    DEF  INPUT PARAM par_cdrlcrsp AS INTE                               NO-UNDO.
    DEF  INPUT PARAM par_dsrlcrsp AS CHAR                               NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR Relacionamento. 

    DEF VAR xml_req AS LONGCHAR                                         NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE Relacionamento.


    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_rlc_rsp_legal 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdrlcrsp, 
                          INPUT par_dsrlcrsp,   
                          OUTPUT "",
                          OUTPUT 0,               
                          OUTPUT "").

    CLOSE STORED-PROC pc_busca_rlc_rsp_legal 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.   

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_busca_rlc_rsp_legal.pr_cdcritic 
                          WHEN pc_busca_rlc_rsp_legal.pr_cdcritic <> ?
           aux_dscritic = pc_busca_rlc_rsp_legal.pr_dscritic 
                          WHEN pc_busca_rlc_rsp_legal.pr_dscritic <> ?

           xml_req      = pc_busca_rlc_rsp_legal.pr_retxml
                          WHEN pc_busca_rlc_rsp_legal.pr_retxml <> ? .  

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /*sequencia*/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).             
         
             RETURN "NOK".             
         END.

    /* Substituir a TAG <inf> pela <Relacionamento> para o Progress se achar */
    ASSIGN xml_req = REPLACE(xml_req,"inf>","Relacionamento>").

    /* Devolver na TEMP-TABLE Relacionamento os registros retornados */
    DATASET DATA:READ-XML("longchar",   /* SourceType             */
                          xml_req,      /* XML                    */
                          "append",     /* ReadMode               */
                          ?,            /* SchemaLocation         */
                          ?,            /* OverrideDefaultMapping */
                          ?,            /* FieldTypeMapping       */
                          ?).           /* VerifySchemaMode       */

    /* Remover no's sem informacao */
    FOR EACH Relacionamento:
        IF    Relacionamento.cdrelacionamento = 0   THEN
              DELETE Relacionamento.
    END.
     
    RETURN "OK".

END PROCEDURE.



/* ........................................................................ */ 


