/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+--------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                  |
  +-------------------------------------+--------------------------------------+
  | Busca_Dados                         | CADA0001.pc_busca_dados_58           |
  | Busca_Dados_id                      | CADA0001.pc_busca_dados_id_58        |
  | Busca_Dados_Cto                     | CADA0001.pc_busca_dados_cto_58       |
  | Busca_Dados_Ass                     | CADA0001.pc_busca_dados_ass_58       |
  +-------------------------------------+--------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

    Programa: b1wgen0058.p
    Autor   : Jose Luis (DB1)
    Data    : Marco/2010                   Ultima atualizacao: 03/11/2017

    Objetivo  : Tranformacao BO tela CONTAS - PROCURADORES/REPRESENTANTES

    Alteracoes: 12/08/2010 - Ajuste na validacao de UF (David).
    
                15/09/2010 - Adaptacao para PF (Jose Luis - DB1)
                 
                15/10/2010 - Validacao para nao permitir eliminacao de
                             representante/procurador se o mesmo esta 
                             relacionado com uma conta juridica e possui
                             cartao de credito ativo (GATI - Eder)
                             
                15/04/2011 - Validacao de CEP existente. (André - DB1)
                
                11/08/2011 - Incluir procedures/tratamentos p/ Grupo Economico
                             grava_grupo_economico
                             busca_perc_socio
                             exclui_grupo_economico
                           - Validacao de rendimentos na Valida_Dados
                             (Guilherme).
                             
                14/10/2011 - Validacao dos campos par_vloutren e par_dsoutren
                             na Valida_Dados.
                             Gravacao dos campos par_vloutren e par_dsoutren
                             na crapavt, procedure Grava_Dados. (Fabricio)
                             
                26/10/2011 - Criado procedure valida_percentual_societario.
                             (Fabricio)
                             
                23/11/2011 - Removido os 6(seis) campos de tipo de rendimento
                             e valor dos rendimentos, inerentes ao frame de
                             outros rendimentos da tela de procuradores(PJ). 
                             (Fabricio).
                             
                16/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                            (Adriano). 
                            
                05/10/2012 - Ajuste na procedure busca_dados_cto para nao
                             verificar se procurador em questao jah esta
                             cadastrado ou nao. Posto "PROCURADORES/FISICA" nas
                             condicoes onde eh tratado o "PROCURADOR" e 
                             "Representante/Procurador". Corrigido validacao
                             dos procuradores na procedure valida_inclui
                             (Adriano).

                14/12/2012 - Implementado log para tela LOGTEL das operacoes
                             inclusao, alteracao e exclusao (Tiago).
                             
                02/04/2013 - Incluido a chamada da procedure alerta_fraude
                             dentro da procedure Grava_Dados (Adriano).
                             
                05/06/2013 - Remover procedures grava_grupo_economico e
                             exclui_grupo_economico (Lucas R.)
                             
                24/06/2013 - Inclusao da opçao de poderes (Jean Michel).
                
                19/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James).
                             
                23/08/2013 - Substituir campo crapass.dsnatura pelo campo
                             crapttl.dsnatura (David).
                
                04/10/2013 - Inclusao de registro na crapdoc quando há alteraçoes
                             de CPF, No e Tipo de Documento na procedure Grava_Dados
                             (Jean Michel). 
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge) 
                
                16/04/2014 - Ajustes para gerar pendencia na crapdoc, troca de
                             condicoes e tipos de documentos (Lucas R)
                             
                29/04/2014 - Incluir filtro de pessoa fisica na validacao 
                             de emancipacao (Jaison - SF: 152091)
                             
                15/05/2014 - Ajustes gerais em ajuste acima. 
                             (Jorge/Guilherme) - Emergencial

                30/05/2014 - Alterado a busca do estado civil de crapass para crapttl
                             (Douglas - Chamado 131253)
                             
                06/06/2014 - Alterado "Valida_Dados" para nao validar o CPF quando estiver excluindo.
                             Exitem procuradores com CPF zerado e nao está permitindo exclui-los.
                             (Douglas - Chamado 134639)
                             
                08/07/2014 - #176156 Correcao da exclusao de representantes/procuradores 
                             para criticar quando o cpf nao estiver preenchido. (Carlos)
                                             
                10/11/2014 - Permitido que seja tirado o poder de assinatura
                             em conjunto E de forma isolada; procedure
                             Grava_Dados_Poderes. (Chamado 158762) - (Fabricio)
                        
                09/02/2015 - Incluir regra para nao permitir que representantes sejam 
                             excluídos, caso possuam cartao Bancoob, com a situaçao 
                             1 - Aprovado ou 2 - Solicitado. ( Renato - Supero )
                
                27/03/2015 - Ao excluir um representante é validado se existe cartoes bradescos vinculados
                             a ele, porém nao estava sendo validado se era cartao bradesco, 
                             isso é, qualquer cartao era considerado como bradesco. SD - 269861 (Kelvin)
                    
                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM). 

                03/11/2015 - Inclusao de novo poder na function ListaPoderes (Jean Michel).
                
                05/11/2015 - Inclusao de tratamentos para exclusao de cooperados,
                             PRJ 131 - Ass. Conjunta (Jean Michel).
                             
                10/11/2015 - Inclusao de tratamentos na Busca_Dados para verificar,
                             se o representante é responsável legal pelo acesso aos
                             canais de autoatendimento e SAC PRJ 131 - Ass. Conjunta
                             (Jean Michel).
		
				 13/11/2015 - Na procedure Exclui_Dados, incluir tambem a exclusao da crapdoc.
                             (Lucas Ranghetti #331404)
                             
                 26/11/2015 - Inclusao da procedure valida_responsaveis para o Prj.
                              Assinatura Conjunta (Jean Michel). 
                              
                 17/12/2015 - Inclusao do tratamento de critica no FiltroBusca.
                             (Jonathan - RKAM).           

                 01/07/2016 - Ajustes para quando um procurador que nao tinha conta
				              na cooperativa passar a ter se for incluido poderes
							  para ele nao duplicar as informaçoes no cartao de 
							  assinatura (Tiago/Thiago SD438834)

	             25/08/2016 - Ajustes na procedure valida_responsaveis, SD 510426 (Jean Michel).

				 22/03/2017 - Ajustes na procedure valida_responsaveis, para nao considerar quando 
				              a regra do poder 10 quando a exigencia de assinatura estiver com nao 
							  SD 630546 (Rafael Monteiro).

				 28/03/2017 - Realizado ajuste para que quando filtrar procurador pelo CPF, busque
							  apenas contas ativas, coforme solicitado no chamado 566363. (Kelvin)

                18/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
							  
				 26/04/2017 - Ajustado o problema que não carregava os procuradores na tela contas,
							  conforme solicitado no chamado 659095. (Kelvin)	

                17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)

                31/07/2017 - Alterado leitura da CRAPNAT pela CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)               

				28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
							 CH, RE, PP E CT. (PRJ339 - Reinert)

                20/09/2017 - Alterado validacao naturalidade CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)  

				21/09/2017 - Ajuste para utilizar o for first para validar a naturalidade
				             (Adriano - SD 761431)

				16/10/2017 - Ajuste para validar a porcentagem de societário também na tela matric. (PRJ339 - Kelvin).
                              
                03/11/2017 - Correcao no carregamento de bens para procurador na tela CONTAS.
							 Busca_Dados_Ass SD 778432. (Carlos Rafael Tanholi).
.....................................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0058tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfcto AS DECI                                           NO-UNDO.
DEF VAR aux_msgdolog AS CHAR                                           NO-UNDO.
DEF VAR aux_ctdpoder AS INT                                            NO-UNDO.

DEF VAR aux_flgisola AS CHAR                                           NO-UNDO.
DEF VAR aux_flgconju AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                        NO-UNDO.

FUNCTION ValidaUf      RETURNS LOGICAL 
    ( INPUT par_cdufdavt AS CHARACTER ) FORWARD.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL
    ( INPUT  par_nrcpfcgc AS DECIMAL,
      OUTPUT par_cdcritic AS INTEGER ) FORWARD.

FUNCTION CarregaCpfCnpj RETURNS DECIMAL
    ( INPUT par_cdcpfcgc AS CHARACTER ) FORWARD.

FUNCTION ListaPoderes RETURNS CHAR 
    ( OUTPUT par_listapod AS CHAR ) FORWARD.

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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapavt.
    DEF OUTPUT PARAM TABLE FOR tt-bens.
	DEF OUTPUT PARAM par_qtminast AS INTE							NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados do Representante/Procurador"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno  = "NOK".
          
    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-crapavt.
        EMPTY TEMP-TABLE tt-erro.   

        FiltroBusca: DO ON ERROR UNDO FiltroBusca, LEAVE FiltroBusca:     

            IF par_nrdrowid <> ? THEN
               DO:  
                    RUN Busca_Dados_Id
                        ( INPUT par_cdcooper,
                          INPUT par_nrdconta,
                          INPUT par_nrdrowid,
                          INPUT par_cddopcao,
                         OUTPUT aux_cdcritic,
                         OUTPUT aux_dscritic ) NO-ERROR.

                    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                        LEAVE FiltroBusca.
                    
                    FIND FIRST tt-crapavt NO-LOCK NO-ERROR.

                    IF  ERROR-STATUS:ERROR THEN
                        DO:
                           ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                           LEAVE FiltroBusca.
                        END.
                END.
            ELSE

               IF par_nrdctato <> 0 OR par_nrcpfcto <> 0 THEN
                  DO:
                      RUN Busca_Dados_Cto
                          ( INPUT par_cdcooper,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT par_nrdctato,
                            INPUT par_nrcpfcto,
                            INPUT par_cddopcao,
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic ) NO-ERROR.

                  IF ERROR-STATUS:ERROR THEN
                     DO:
                        ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                        LEAVE FiltroBusca.
                     END.

                  END.
        END.

        IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
           LEAVE Busca.

        IF par_cddopcao <> "C" THEN
           LEAVE Busca.
        
        /* se encontrou registros na pesquisa [C], nao e preciso o for each */
        IF TEMP-TABLE tt-crapavt:HAS-RECORDS THEN
            LEAVE Busca.

        /* Verificacao de tipo de conta e se exige assinatura conjunta JMD */
        FOR FIRST crapass FIELDS(inpessoa idastcjt qtminast) WHERE crapass.cdcooper = par_cdcooper
                                                               AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
        IF NOT AVAILABLE crapass then
          DO:
            ASSIGN aux_dscritic = "009 - Associado nao cadastrado.".
            UNDO Busca, LEAVE Busca.
          END.
        
		ASSIGN par_qtminast = crapass.qtminast.
		 
        /* Carrega a lista de procuradores */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 6 /*procurad*/ AND
                               crapavt.nrdconta = par_nrdconta   AND
                               crapavt.nrctremp = par_idseqttl   
                               NO-LOCK:
            
            RUN Busca_Dados_Id ( INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT ROWID(crapavt),
                                 INPUT par_cddopcao,
                                 OUTPUT aux_cdcritic,
                                 OUTPUT aux_dscritic ).
        
            IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
             UNDO Busca, LEAVE Busca.
             
            FIND LAST tt-crapavt.
    
            /* PRJ 131 - Assinatura Conjunta */
            IF crapass.idastcjt = 1 THEN
                DO: /* Assinatura Conjunta */
				
                  FOR FIRST crappod FIELDS(flgconju) 
                                    WHERE crappod.cdcooper = crapavt.cdcooper AND
                                          crappod.nrdconta = crapavt.nrdconta AND
                                          crappod.nrctapro = crapavt.nrdctato AND
                                          crappod.nrcpfpro = crapavt.nrcpfcgc AND
                                          crappod.cddpoder = 10               and
                                          crappod.flgconju = TRUE NO-LOCK. END.
    
                  IF AVAILABLE crappod  THEN
                    ASSIGN tt-crapavt.idrspleg = 1.
                  ELSE
                     ASSIGN tt-crapavt.idrspleg = 0.
                END.
            ELSE
                DO:
				
                  FOR FIRST crapsnh FIELDS(cdcooper) WHERE crapsnh.cdcooper = crapavt.cdcooper AND
                                                           crapsnh.nrdconta = crapavt.nrdconta AND
                                                           crapsnh.idseqttl = 1                AND
                                                           crapsnh.tpdsenha = 1                AND
                                                           crapsnh.nrcpfcgc = crapavt.nrcpfcgc NO-LOCK. END.
                  IF AVAILABLE crapsnh THEN
                    ASSIGN tt-crapavt.idrspleg = 1.
                  ELSE
                    ASSIGN tt-crapavt.idrspleg = 0.
                    
              END.
        /* Fim PRJ 131 - Assinatura Conjunta */
            
     END. /* FOR EACH crapavt ... */

    LEAVE Busca.

    END.
    
    IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,           
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
    ELSE 
       ASSIGN aux_retorno = "OK".
       
    IF par_flgerlog AND par_cddopcao = "C" THEN
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

PROCEDURE Busca_Dados_Id:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabavt FOR crapavt.
    DEF BUFFER craeavt FOR crapavt.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    DEF VAR aux_rowidepa AS ROWID                                   NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_fltemcrd AS INT                                     NO-UNDO.

    ASSIGN aux_retorno = "NOK".
    
    BuscaId: DO ON ERROR UNDO BuscaId, LEAVE BuscaId:
        EMPTY TEMP-TABLE tt-erro.
        FIND crabavt WHERE ROWID(crabavt) = par_nrdrowid NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crabavt THEN
            DO:
               ASSIGN par_dscritic = "Representante/Procurador nao encontrado".
               LEAVE BuscaId.
            END.
    
       /* Verifica se ha mais de um procurador pra poder excluir */
       IF  par_cddopcao = "E" AND 
           CAN-FIND(FIRST crapass WHERE
                          crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta AND
                          crapass.inpessoa > 1 NO-LOCK) THEN
           DO:
              IF  NOT CAN-FIND(FIRST craeavt WHERE
                               craeavt.cdcooper = par_cdcooper   AND
                               craeavt.tpctrato = 6 /*juridica*/ AND
                               craeavt.nrdconta = par_nrdconta   AND
                               ROWID(craeavt)  <> par_nrdrowid   NO-LOCK) 
                  AND 
                  NOT CAN-FIND(FIRST crapepa WHERE
                               crapepa.cdcooper = par_cdcooper AND
                               crapepa.nrdconta = par_nrdconta NO-LOCK) THEN
                  DO:
                     FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                        crapjur.nrdconta = par_nrdconta 
                                        NO-LOCK NO-ERROR.
              
                     IF AVAIL crapjur THEN
                        DO:
                           FIND gncdntj WHERE 
                                        gncdntj.cdnatjur = crapjur.natjurid AND
                                        gncdntj.flgprsoc = TRUE 
                                        NO-LOCK NO-ERROR.
              
                           IF AVAIL gncdntj THEN
                              DO: 
                                 ASSIGN par_dscritic = "Deve existir pelo " + 
                                                       "menos um "          +
                                                       "representante/"     + 
                                                       "procurador". 
                              
                                 LEAVE BuscaId.
                              
                              END.
              
                        END.
                     
                  END.
           END.
       
       /*********************************************************************************
       ** Verificar e indicar no registro se o representante possui cartao e conforme
       ** a situaçao dos mesmos seta o indicado, conforme abaixo:
       ** 1 - Se representante possui cartao liberado, em uso e cancelado
       ** 2 - Se representante possui cartao aprovado e solicitado
       *********************************************************************************/

       /* Seta variável para zero */
       ASSIGN aux_fltemcrd = 0.

       /* Validar cartoes bancoob em situaçao de liberado, em uso e cancelado */
       FIND FIRST crawcrd WHERE crawcrd.cdcooper = crabavt.cdcooper     AND
                                crawcrd.nrdconta = crabavt.nrdconta     AND
                                crawcrd.nrcpftit = crabavt.nrcpfcgc AND
                               (crawcrd.cdadmcrd >= 10              AND
                                crawcrd.cdadmcrd <= 80         )    AND
                               (crawcrd.insitcrd = 3   /* liberado */  OR 
                                crawcrd.insitcrd = 4   /* em uso */    OR 
                                crawcrd.insitcrd = 5   /* cancelado */ )  
                                NO-LOCK NO-ERROR.
            
       /* Se encontrar cartao de crédito */
       IF AVAIL crawcrd THEN
         DO:
             ASSIGN aux_fltemcrd = 1.
         END. 
                
       /* Validar cartoes bancoob em situaçao de aprovado e solicitado */
       FIND FIRST crawcrd WHERE crawcrd.cdcooper = crabavt.cdcooper     AND
                                crawcrd.nrdconta = crabavt.nrdconta     AND
                                crawcrd.nrcpftit = crabavt.nrcpfcgc AND
                               (crawcrd.cdadmcrd >= 10              AND
                                crawcrd.cdadmcrd <= 80         )    AND
                               (crawcrd.insitcrd = 1   /* aprovado */  OR 
                                crawcrd.insitcrd = 2   /* solicitado */    )  
                                NO-LOCK NO-ERROR.
            
       /* Se encontrar cartao de crédito */
       IF AVAIL crawcrd THEN
         DO:
             ASSIGN aux_fltemcrd = 2.
         END. 
       /****************************************************************************/

              /* Se for associado, pega os dados da crapass */
       IF  crabavt.nrdctato <> 0 THEN
           DO:
              RUN Busca_Dados_Ass
                  ( INPUT crabavt.cdcooper,
                    INPUT crabavt.nrdconta,
                    INPUT crabavt.nrctremp,
                    INPUT crabavt.nrdctato,
                   OUTPUT par_cdcritic,
                   OUTPUT par_dscritic ).
           END.

       ELSE 
           DO:
            
              CREATE tt-crapavt.
              BUFFER-COPY crabavt TO tt-crapavt 
                  ASSIGN tt-crapavt.cddconta = "0"
                         tt-crapavt.nrdrowid = ROWID(crabavt)
                         tt-crapavt.rowidavt = ROWID(crabavt)
                         tt-crapavt.vledvmto = crabavt.vledvmto
                         tt-crapavt.cdcpfcgc = STRING(STRING(crabavt.nrcpfcgc,
                                                    "99999999999"),
                                                    "xxx.xxx.xxx-xx") NO-ERROR.

              IF  ERROR-STATUS:ERROR THEN
                  DO:
                     ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                     LEAVE BuscaId.
                  END.

              /* Buscar a Nacionalidade */
              FOR FIRST crapnac FIELDS(dsnacion)
                                WHERE crapnac.cdnacion = crabavt.cdnacion
                                      NO-LOCK:

                  ASSIGN tt-crapavt.dsnacion = crapnac.dsnacion.

              END. 

              /* Retornar orgao expedidor */
              IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                    RUN sistema/generico/procedures/b1wgen0052b.p 
                        PERSISTENT SET h-b1wgen0052b.

              ASSIGN tt-crapavt.cdoeddoc = "".
              RUN busca_org_expedidor IN h-b1wgen0052b 
                                 ( INPUT crabavt.idorgexp,
                                  OUTPUT tt-crapavt.cdoeddoc,
                                  OUTPUT aux_cdcritic, 
                                  OUTPUT aux_dscritic).

              DELETE PROCEDURE h-b1wgen0052b.   

              IF  RETURN-VALUE = "NOK" THEN
              DO:
                  ASSIGN tt-crapavt.cdoeddoc = 'NAO CADAST'.
              END.

               IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                  RUN sistema/generico/procedures/b1wgen9999.p
                      PERSISTENT SET h-b1wgen9999.
               
               /* validar pela procedure generica do b1wgen9999.p */
               RUN idade IN h-b1wgen9999 ( INPUT crabavt.dtnascto,
                                           INPUT TODAY,
                                           OUTPUT tt-crapavt.nrdeanos,
                                           OUTPUT aux_nrdmeses,
                                           OUTPUT aux_dsdidade ).
               
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE PROCEDURE h-b1wgen9999.

              IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                  RUN sistema/generico/procedures/b1wgen0060.p 
                      PERSISTENT SET h-b1wgen0060.

              DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060, 
                               INPUT crabavt.inhabmen, 
                               OUTPUT tt-crapavt.dshabmen,
                               OUTPUT aux_dscritic).

              aux_dscritic = "".

              DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                             INPUT tt-crapavt.cdestcvl,
                             INPUT "dsestcvl",
                             OUTPUT tt-crapavt.dsestcvl,
                             OUTPUT aux_dscritic).

              aux_dscritic = "".

              IF  VALID-HANDLE(h-b1wgen0060) THEN
                  DELETE OBJECT h-b1wgen0060.
    
              IF tt-crapavt.dtvalida = 12/31/9999 THEN
                 ASSIGN tt-crapavt.dsvalida = "INDETERMI.".
              ELSE 
                 ASSIGN tt-crapavt.dsvalida = STRING(tt-crapavt.dtvalida,
                                                     "99/99/9999").

              DO aux_contador = 1 TO 6:
                  IF tt-crapavt.dsrelbem[aux_contador] = ""   THEN
                     NEXT.

                  CREATE tt-bens.

                  ASSIGN tt-bens.dsrelbem = tt-crapavt.dsrelbem[aux_contador]
                         tt-bens.persemon = tt-crapavt.persemon[aux_contador]
                         tt-bens.qtprebem = tt-crapavt.qtprebem[aux_contador]
                         tt-bens.vlprebem = tt-crapavt.vlprebem[aux_contador]
                         tt-bens.vlrdobem = tt-crapavt.vlrdobem[aux_contador]
                         tt-bens.cdsequen = aux_contador
                         tt-bens.nrdrowid = ROWID(crabavt)
                         tt-bens.cddopcao = par_cddopcao
                         tt-bens.cpfdoben = STRING(tt-crapavt.nrcpfcgc).
              END.
           END.
           
       FIND LAST tt-crapavt.

       IF AVAILABLE tt-crapavt THEN
        DO:
           ASSIGN tt-crapavt.dtadmsoc = crabavt.dtadmsoc
                 tt-crapavt.cddopcao = par_cddopcao
                 tt-crapavt.fltemcrd = aux_fltemcrd.
        END.
          

       LEAVE BuscaId.

    END.

    IF par_dscritic = "" AND par_cdcritic = 0 THEN
       ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Cto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabavt FOR crapavt.

    ASSIGN aux_retorno = "NOK".

    BuscaCto: DO ON ERROR UNDO BuscaCto, LEAVE BuscaCto:

        EMPTY TEMP-TABLE tt-erro.

        /* se pessoa fisica, verifica se tem algum titular com o CPF informado */
        IF  CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta AND
                                   crapass.inpessoa = 1) AND
            CAN-FIND(FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                         crapttl.nrdconta = par_nrdconta AND
                                         crapttl.nrcpfcgc = par_nrcpfcto) THEN
            DO:
                ASSIGN par_dscritic = "Titular da conta nao " +
                                      "pode ser procurador.".
                LEAVE BuscaCto.
            END.
                                
        /* efetua a busca tanto por nr da conta como por cpf */
        IF  par_nrdctato <> 0  THEN
            FOR FIRST crabass FIELDS(cdcooper nrdconta nrcpfcgc inpessoa dtdemiss)
                              WHERE crabass.cdcooper = par_cdcooper AND
                                    crabass.nrdconta = par_nrdctato NO-LOCK:
            END.
        ELSE
        IF  par_nrcpfcto <> 0  THEN
            FOR FIRST crabass FIELDS(cdcooper nrdconta nrcpfcgc inpessoa dtdemiss)
                              WHERE crabass.cdcooper = par_cdcooper AND
                                    crabass.nrcpfcgc = par_nrcpfcto AND 
									crabass.dtdemiss = ? NO-LOCK:
            END.
            
        IF  NOT AVAILABLE crabass THEN
            DO:
               IF  par_nrdctato <> 0 THEN
                   ASSIGN par_cdcritic = 9.
               LEAVE BuscaCto.
            END.
		ELSE
			DO:
				IF  par_nrdctato <> 0 AND 
				    crabass.dtdemiss <> ? THEN
					DO:
						ASSIGN par_cdcritic = 64.
               LEAVE BuscaCto.
            END.
            END.

        IF  par_nrdconta = crabass.nrdconta  THEN
            DO:
                ASSIGN par_dscritic = "Titular da conta nao " +
                                      "pode ser procurador.".
                LEAVE BuscaCto.
            END.
                                        
        /* somente pessoa fisica */
        IF  crabass.inpessoa <> 1 THEN 
            DO:
               ASSIGN par_cdcritic = 833.
               LEAVE BuscaCto.
            END.

        RUN Busca_Dados_Ass
            ( INPUT crabass.cdcooper,
              INPUT par_nrdconta,
              INPUT par_idseqttl,
              INPUT crabass.nrdconta,
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ).

        LEAVE BuscaCto.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Ass:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
   /* DEFINE VARIABLE aux_tpdrendi LIKE crapavt.tpdrendi    NO-UNDO.
    DEFINE VARIABLE aux_vldrendi LIKE crapavt.vldrendi    NO-UNDO.*/

    DEF VAR aux_dsdrendi AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.

    DEF BUFFER crabavt FOR crapavt.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabenc FOR crapenc.

    ASSIGN aux_retorno = "NOK".
    
    BuscaAss: DO ON ERROR UNDO BuscaAss, LEAVE BuscaAss:

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        FOR FIRST crabass FIELDS(cdcooper nrdconta nrcpfcgc nmprimtl tpdocptl 
                                 nrdocptl idorgexp cdufdptl dtemdptl dsproftl 
                                 dtnasctl cdsexotl cdnacion inpessoa)
                           WHERE crabass.cdcooper = par_cdcooper AND
                                 crabass.nrdconta = par_nrdctato 
                                 NO-LOCK,

            FIRST crabttl FIELDS(nmmaettl nmpaittl tpdrendi vldrendi dthabmen
                                 inhabmen idseqttl dsnatura cdestcvl)
                           WHERE crabttl.cdcooper = crabass.cdcooper AND
                                 crabttl.nrdconta = crabass.nrdconta AND
                                 crabttl.idseqttl = 1 
                                 NO-LOCK:

            FOR FIRST crabenc FIELDS(nrcepend dsendere nrendere complend
                                     nmbairro nmcidade cdufende nrcxapst)
                              WHERE crabenc.cdcooper = crabass.cdcooper AND
                                    crabenc.nrdconta = crabass.nrdconta AND
                                    crabenc.idseqttl = 1                AND
                                    crabenc.cdseqinc = 1                AND
                                    crabenc.tpendass = 10           
                                    NO-LOCK:

            END.

            IF  NOT AVAILABLE crabenc THEN
                DO:
                   ASSIGN par_dscritic = "Endereco nao cadastrado.".
                   LEAVE BuscaAss.
                END.
                
            CREATE tt-crapavt.
            ASSIGN tt-crapavt.cddconta = TRIM(STRING(crabass.nrdconta,
                                                     "zzzz,zzz,9"))
                   tt-crapavt.cdcooper    = crabass.cdcooper
                   tt-crapavt.nrdconta    = par_nrdconta
                   tt-crapavt.nrcpfcgc    = crabass.nrcpfcgc
                   tt-crapavt.nmdavali    = crabass.nmprimtl
                   tt-crapavt.tpdocava    = crabass.tpdocptl
                   tt-crapavt.nrdocava    = crabass.nrdocptl
                   tt-crapavt.cdufddoc    = crabass.cdufdptl
                   tt-crapavt.dtemddoc    = crabass.dtemdptl
                   tt-crapavt.dtnascto    = crabass.dtnasctl
                   tt-crapavt.cdsexcto    = crabass.cdsexotl
                   tt-crapavt.cdestcvl    = crabttl.cdestcvl
                   tt-crapavt.cdnacion    = crabass.cdnacion
                   tt-crapavt.dsnatura    = crabttl.dsnatura
                   tt-crapavt.nmmaecto    = crabttl.nmmaettl
                   tt-crapavt.nmpaicto    = crabttl.nmpaittl
                   tt-crapavt.nrcepend    = crabenc.nrcepend
                   tt-crapavt.dsendres[1] = crabenc.dsendere
                   tt-crapavt.nrendere    = crabenc.nrendere
                   tt-crapavt.complend    = crabenc.complend
                   tt-crapavt.nmbairro    = crabenc.nmbairro
                   tt-crapavt.nmcidade    = crabenc.nmcidade
                   tt-crapavt.cdufresd    = crabenc.cdufende
                   tt-crapavt.nrcxapst    = crabenc.nrcxapst
                   tt-crapavt.nrdctato    = crabass.nrdconta
                   tt-crapavt.cdcpfcgc    = STRING(STRING(crabass.nrcpfcgc,
                                                          "99999999999"),
                                                   "xxx.xxx.xxx-xx") 
                   tt-crapavt.inhabmen    = crabttl.inhabmen
                   tt-crapavt.dthabmen    = crabttl.dthabmen 
                   tt-crapavt.nrctremp    = crabttl.idseqttl
                   tt-crapavt.tpctrato    = 6 /*Procuradores*/
                   NO-ERROR.

                   /* Buscar a Nacionalidade */
                   FOR FIRST crapnac FIELDS(dsnacion)
                                     WHERE crapnac.cdnacion = crabass.cdnacion
                                           NO-LOCK:

                       ASSIGN tt-crapavt.dsnacion = crapnac.dsnacion.

                   END.

            IF  ERROR-STATUS:ERROR THEN
                DO:
                   ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                   UNDO BuscaAss, LEAVE BuscaAss.
                END.

            /* Retornar orgao expedidor */
            IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                RUN sistema/generico/procedures/b1wgen0052b.p 
                    PERSISTENT SET h-b1wgen0052b.

            ASSIGN tt-crapavt.cdoeddoc = "".
            RUN busca_org_expedidor IN h-b1wgen0052b 
                               (INPUT crabass.idorgexp,
                                OUTPUT tt-crapavt.cdoeddoc,
                                OUTPUT par_cdcritic, 
                                OUTPUT par_dscritic).

            DELETE PROCEDURE h-b1wgen0052b.   

            IF  RETURN-VALUE = "NOK" THEN
            DO:
                UNDO BuscaAss, LEAVE BuscaAss.
            END.    

            IF NOT VALID-HANDLE(h-b1wgen9999) THEN
               RUN sistema/generico/procedures/b1wgen9999.p
                   PERSISTENT SET h-b1wgen9999.
            
            /* validar pela procedure generica do b1wgen9999.p */
            RUN idade IN h-b1wgen9999 ( INPUT crabass.dtnasctl,
                                        INPUT TODAY,
                                        OUTPUT tt-crapavt.nrdeanos,
                                        OUTPUT aux_nrdmeses,
                                        OUTPUT aux_dsdidade ).
            
            IF VALID-HANDLE(h-b1wgen9999) THEN
               DELETE PROCEDURE h-b1wgen9999.


            /* Valor do endividamento */
            FOR EACH crapsdv FIELDS(vldsaldo tpdsaldo)
                              WHERE crapsdv.cdcooper = crabass.cdcooper AND
                                    crapsdv.nrdconta = crabass.nrdconta AND
                                    CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo)) 
                                    NO-LOCK:

                ACCUMULATE crapsdv.vldsaldo (TOTAL).

            END.

            ASSIGN tt-crapavt.vledvmto = ACCUM TOTAL crapsdv.vldsaldo.
            
            /* Primeiro bem do cooperado */
            FOR FIRST crapbem FIELDS(dsrelbem)
                               WHERE crapbem.cdcooper = crabass.cdcooper AND
                                     crapbem.nrdconta = crabass.nrdconta AND
                                     crapbem.idseqttl = 1 
                                     NO-LOCK:

                ASSIGN tt-crapavt.dsrelbem[1] = crapbem.dsrelbem.

            END.

            FOR FIRST crabavt FIELDS(dtvalida dsproftl persocio flgdepec
                                     vloutren dsoutren)
                              WHERE crabavt.cdcooper = crabass.cdcooper AND
                                    crabavt.tpctrato = 6 /* jur */      AND
                                    crabavt.nrdconta = par_nrdconta     AND
                                    crabavt.nrctremp = par_idseqttl     AND
                                    crabavt.nrcpfcgc = crabass.nrcpfcgc 
                                    NO-LOCK:

                ASSIGN tt-crapavt.nrdrowid = ROWID(crabavt)
                       tt-crapavt.rowidavt = ROWID(crabavt)
                       tt-crapavt.dtvalida = crabavt.dtvalida
                       tt-crapavt.dsproftl = crabavt.dsproftl
                       tt-crapavt.persocio = crabavt.persocio
                       tt-crapavt.flgdepec = crabavt.flgdepec
                       tt-crapavt.vloutren = crabavt.vloutren
                       tt-crapavt.dsoutren = crabavt.dsoutren.
            
                IF  tt-crapavt.dtvalida = 12/31/9999 THEN
                    ASSIGN tt-crapavt.dsvalida = "INDETERMI.".
                ELSE 
                    ASSIGN tt-crapavt.dsvalida = STRING(tt-crapavt.dtvalida,
                                                        "99/99/9999").
            END.

            DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060, 
                             INPUT tt-crapavt.inhabmen, 
                             OUTPUT tt-crapavt.dshabmen,
                             OUTPUT aux_dscritic).

            DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                             INPUT tt-crapavt.cdestcvl,
                             INPUT "dsestcvl",
                             OUTPUT tt-crapavt.dsestcvl,
                             OUTPUT aux_dscritic).

            ASSIGN aux_contador = 1.

            FOR EACH crapbem WHERE crapbem.cdcooper = tt-crapavt.cdcooper AND
                                   crapbem.nrdconta = tt-crapavt.nrdctato AND
								   crapbem.idseqttl = 1 
                                   NO-LOCK:
                ASSIGN tt-crapavt.dsrelbem[aux_contador] = crapbem.dsrelbem
                       tt-crapavt.dsrelbem[aux_contador] = crapbem.dsrelbem
                       tt-crapavt.persemon[aux_contador] = crapbem.persemon
                       tt-crapavt.qtprebem[aux_contador] = crapbem.qtprebem
                       tt-crapavt.vlprebem[aux_contador] = crapbem.vlprebem
                       tt-crapavt.vlrdobem[aux_contador] = crapbem.vlrdobem
                       aux_contador                      = aux_contador + 1.

                IF  aux_contador = 6 THEN
                    LEAVE.
            END.
        END.

        LEAVE BuscaAss.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_retorno = "OK".

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Dados_Bens:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsequen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcto AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-bens.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Bens do representante/procurador"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-bens.
        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcto).
        

        FOR EACH crapavt FIELDS(dsrelbem persemon qtprebem vlprebem 
                                vlrdobem nrcpfcgc)
                         WHERE crapavt.cdcooper = par_cdcooper   AND
                               crapavt.tpctrato = 6 /*juridica*/ AND
                               crapavt.nrctremp = par_idseqttl   AND
                               crapavt.nrdconta = par_nrdconta   AND 
                               (IF aux_nrcpfcto <> 0 
                                THEN crapavt.nrcpfcgc = aux_nrcpfcto 
                                ELSE TRUE) AND
                               (IF par_nrdctato <> 0 
                                THEN crapavt.nrdctato = par_nrdctato
                                ELSE TRUE) NO-LOCK:

            DO aux_contador = 1 TO 6:

               IF  crapavt.dsrelbem[aux_contador] = "" THEN
                   NEXT.

               IF  par_cdsequen <> 0 AND (par_cdsequen <> aux_contador) THEN
                   NEXT.
           
               CREATE tt-bens.
               ASSIGN tt-bens.dsrelbem = crapavt.dsrelbem[aux_contador]
                      tt-bens.persemon = crapavt.persemon[aux_contador]
                      tt-bens.qtprebem = crapavt.qtprebem[aux_contador]
                      tt-bens.vlprebem = crapavt.vlprebem[aux_contador]
                      tt-bens.vlrdobem = crapavt.vlrdobem[aux_contador]
                      tt-bens.cdsequen = aux_contador
                      tt-bens.cddopcao = "C"
                      tt-bens.nrdrowid = ROWID(crapavt)
                      tt-bens.cpfdoben = STRING(crapavt.nrcpfcgc).

            END.

        END. /* for each crapavt */
        
        LEAVE Busca.
    END.
    
    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,           
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.
    ELSE 
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK"
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

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
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocava AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocava AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoeddoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufddoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemddoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexcto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaecto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaicto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsrelbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtvalida AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmsoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_persocio AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgdepec AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_vloutren AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsoutren AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_verrespo AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_permalte AS LOG                            NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-bens.
    DEF  INPUT PARAM TABLE FOR tt-resp.
    DEF  INPUT PARAM TABLE FOR tt-crapavt-b.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nrdeanos AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_nrdmeses AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_dsdidade AS CHAR                           NO-UNDO.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0056 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
 
    DEF VAR aux_flagdsnh AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgcarta AS LOGI                                    NO-UNDO.
    DEF VAR aux_dsprofan AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO.
    DEF VAR aux_rowidavt AS ROWID                                   NO-UNDO.
    DEF VAR aux_cdsexcto AS CHAR                                    NO-UNDO.
    DEF VAR aux_bensdavt AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdebens AS INTE                                    NO-UNDO.
    DEF VAR tot_persocio AS DECI                                    NO-UNDO.
    DEF VAR tab_persocio AS DECI                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_idorgexp AS INTE                                    NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados do Representante/Procurador"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno = "NOK"
           aux_nmdcampo = "" .


    IF par_cddopcao = "PI" THEN
       DO:
          IF  VALID-HANDLE(h-b1wgen9999) THEN
              DELETE OBJECT h-b1wgen9999.
          
          RUN sistema/generico/procedures/b1wgen9999.p
              PERSISTENT SET h-b1wgen9999.
          
          /* validar pela procedure generica do b1wgen9999.p */
          RUN idade IN h-b1wgen9999 ( INPUT par_dtnascto,
                                      INPUT par_dtmvtolt,
                                      OUTPUT par_nrdeanos,
                                      OUTPUT par_nrdmeses,
                                      OUTPUT par_dsdidade ).
       
           /* Seleciona o tipo de pessoa: PF/PJ */
           FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                              crapass.nrdconta = par_nrdconta 
                              NO-LOCK.
           
           ASSIGN aux_inpessoa = crapass.inpessoa.

           /* Sera realizada a validacao de emancipacao apenas para pessoas
              que tiverem o estado civil diferente dos apresentados na 
              condicao abaixo. Quando casado, a pessoa é automaticamente 
              emancipada.*/
           IF aux_inpessoa = 1 AND 
              par_inhabmen = 1 AND
              NOT CAN-DO("2,3,4,5,6,7,8,9,11",STRING(par_cdestcvl)) AND
              (par_nrdeanos < 16 OR par_nrdeanos > 17) THEN
              DO:
                  ASSIGN aux_dscritic = "Para emancipacao e necessario " + 
                                        "ter entre 16 e 18 anos.".

                  IF  VALID-HANDLE(h-b1wgen9999) THEN
                      DELETE OBJECT h-b1wgen9999.

                   
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).

                  RETURN "NOK".

              END.
          
          IF  VALID-HANDLE(h-b1wgen9999) THEN
              DELETE OBJECT h-b1wgen9999.
       
          RETURN "OK".

       END.

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        
        EMPTY TEMP-TABLE tt-erro.

        ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).

        IF   par_cddopcao <> "E"                                                OR
                (par_cddopcao = "E" AND aux_nrcpfcto <> 0)        THEN
                IF  NOT ValidaCpfCnpj(aux_nrcpfcto,OUTPUT aux_cdcritic) THEN
                LEAVE Valida.

        FOR FIRST crapavt FIELDS(dsproftl) 
                          WHERE crapavt.cdcooper = par_cdcooper AND 
                                crapavt.tpctrato = 6 /* jur */  AND
                                crapavt.nrdconta = par_nrdconta AND
                                crapavt.nrctremp = par_idseqttl AND
                                crapavt.nrcpfcgc = aux_nrcpfcto 
                                NO-LOCK:
        
            ASSIGN aux_dsprofan = crapavt.dsproftl
                   aux_rowidavt = ROWID(crapavt).

        END.
        
        CASE par_cddopcao:
            WHEN "I" THEN DO:

                RUN Valida_Inclui
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_nrdctato,
                      INPUT aux_nrcpfcto,
                      INPUT par_nmrotina,
                      INPUT TABLE tt-crapavt-b,
                      INPUT par_idorigem,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
            WHEN "A" THEN DO:

                RUN Valida_Altera
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT aux_nrcpfcto,
                      INPUT aux_dsprofan,
                      INPUT par_dsproftl,
                      INPUT aux_rowidavt,
                      INPUT par_nmrotina,
                      INPUT TABLE tt-crapavt-b,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
            WHEN "E" THEN DO:

                RUN Valida_Exclui
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_nrdctato,
                      INPUT aux_nrcpfcto,
                      INPUT par_nmrotina,
                      INPUT TABLE tt-crapavt-b,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
        END CASE.

        IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
            LEAVE Valida.

        IF  par_cddopcao = "E" THEN
            LEAVE Valida.

        RUN Busca_Idade (INPUT par_dtnascto,
                         INPUT par_dtmvtolt,
                         OUTPUT aux_nrdeanos).

        IF CAN-DO("2,3,4,8,9,11",STRING(par_cdestcvl)) AND
           par_inhabmen = 0                            AND
           par_dthabmen = ?                            AND 
           aux_nrdeanos < 18                           THEN
           DO:
               ASSIGN aux_dscritic = "Resp. Legal e data de emancipacao " + 
                                     "invalidos para estado civil.".

               LEAVE Valida.

           END.

        /* Validacoes realizadas na tela -> INICIO  */
        IF  aux_nrcpfcto = 0 OR  par_nrcpfcgc = ""  THEN
            DO:
               aux_dscritic = "375 - O campo 'CPF' deve ser preenchido.".
               LEAVE Valida.
            END.

        IF  par_nmdavali = "" THEN
            DO:
               aux_dscritic = "375 - O campo 'Nome' deve ser preenchido.".
               LEAVE Valida.
            END.

        IF  par_dtnascto = ? THEN
            DO:
               ASSIGN aux_dscritic = "375 - Data de Nascimento deve ser " + 
                                     "preenchida.".
               LEAVE Valida.
            END.

        IF  par_dtnascto > par_dtmvtolt THEN
            DO:
               ASSIGN aux_dscritic = "Data de Nascimento deve ser " + 
                                     "menor que a data atual.".
               LEAVE Valida.
            END.

        IF  LOOKUP(par_tpdocava,"CI,CN,CH,RE,PP,CT") = 0 THEN
            DO:
               ASSIGN aux_cdcritic = 21.
               LEAVE Valida.
            END.

        IF  par_nrdocava = "" THEN
            DO:
               ASSIGN aux_cdcritic = 22.
               LEAVE Valida.
            END.

        IF  par_cdoeddoc = "" THEN
            DO:
               aux_dscritic = "375 - O campo 'Org.Emi.' deve ser preenchido.".
               LEAVE Valida.
            END.

        /* Identificar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_idorgexp = 0.
        RUN identifica_org_expedidor IN h-b1wgen0052b 
                           (INPUT par_cdoeddoc,
                            OUTPUT aux_idorgexp,
                            OUTPUT aux_cdcritic, 
                            OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            LEAVE Valida.
        END.                

        IF  NOT ValidaUf(par_cdufddoc) THEN
            DO:
               ASSIGN aux_cdcritic = 33.
               LEAVE Valida.
            END.

        IF  par_dtemddoc = ?  THEN
            DO:
               ASSIGN aux_dscritic = "Data de Emissao docto deve ser " + 
                                     "preenchida.".
               LEAVE Valida.
            END.

        IF  par_dtemddoc > par_dtmvtolt THEN
            DO:
               ASSIGN aux_dscritic = "Data de Emissao docto deve ser " + 
                                     "menor que a data atual.".
               LEAVE Valida.
            END.

        IF  par_dtemddoc < par_dtnascto THEN
            DO:
               ASSIGN aux_dscritic = "Data de Emissao docto deve ser " + 
                                     "maior que a data de nascimento.".
               LEAVE Valida.
            END.

        IF  par_inhabmen = 1 AND par_dthabmen = ? THEN
            DO:
               ASSIGN aux_dscritic = "E necessario preencher a data da " +
                                     "emancipacao".
               LEAVE Valida.

            END.

        IF par_inhabmen = 0   AND 
           par_cdestcvl <> 1  AND
           par_cdestcvl <> 12 AND 
           aux_nrdeanos < 18  THEN
           DO:
              IF par_dthabmen = ? THEN
                 DO:
                    ASSIGN aux_dscritic = "Estado Civil obriga ser " + 
                                          "Emancipado.".
           
                    LEAVE Valida.

                 END.

           END.
        ELSE 
           /* Habilitacao - Responsab. Legal */
           IF par_inhabmen <> 1 AND par_dthabmen <> ? THEN
              DO: 
                 ASSIGN aux_dscritic = "Data da emancipacao nao pode " + 
                                       "ser preenchida.".

                 LEAVE Valida.

              END.

        IF  par_inhabmen > 2 THEN
            DO:
              ASSIGN aux_dscritic = "Responsab. Legal invalida.".

              LEAVE Valida.
            END.

        IF  par_dthabmen < par_dtnascto THEN
            DO:
               ASSIGN aux_dscritic = "Data da emancipacao menor que a data " +
                                     "de nascimento.".
                                  
               LEAVE Valida.
            END.

        IF par_dthabmen > par_dtmvtolt THEN
           DO:
              ASSIGN aux_dscritic = "Data da emancipacao maior que a data " + 
                                    "atual.".

              LEAVE.
           END.

        CASE par_cdsexcto:

            WHEN '1' THEN ASSIGN aux_cdsexcto = "M".
            WHEN '2' THEN ASSIGN aux_cdsexcto = "F".
            OTHERWISE ASSIGN aux_cdsexcto = par_cdsexcto.

        END CASE.
        
        IF  LOOKUP(aux_cdsexcto,"M,F") = 0 THEN
            DO:
                ASSIGN aux_dscritic = "Sexo deve ser (M)asculino ou " + 
                                      "(F)eminino.".
                LEAVE Valida.
            END.

        IF  NOT CAN-FIND(gnetcvl WHERE gnetcvl.cdestcvl = par_cdestcvl) THEN
            DO:
               ASSIGN aux_dscritic = "Estado Civil nao cadastrado.".
               LEAVE Valida.
            END.

        IF  NOT CAN-FIND(crapnac WHERE crapnac.cdnacion = par_cdnacion) THEN
            DO:
               ASSIGN aux_cdcritic = 28.
               LEAVE Valida.
            END.

	    FOR FIRST crapmun FIELDS(dscidade) 
		    WHERE crapmun.dscidade = par_dsnatura
			      NO-LOCK:
												  
        END.				

        IF  NOT AVAIL crapmun     AND 
            par_cdufddoc <> "EX"  THEN
            DO:
               ASSIGN aux_cdcritic = 29.
               LEAVE Valida.
            END.

        IF  par_nrdctato = 0  THEN
            DO:
                IF  par_nrcepend = 0 THEN
                    DO:
                       ASSIGN aux_cdcritic = 34.
                       LEAVE Valida.
                    END.
                ELSE
                IF  NOT CAN-FIND(FIRST crapdne 
                                 WHERE crapdne.nrceplog = par_nrcepend)  THEN
                    DO:
                        ASSIGN aux_dscritic = "CEP nao cadastrado.".
                        LEAVE Valida.
                    END.
        
                IF  par_dsendere = "" THEN
                    DO:
                       ASSIGN aux_cdcritic = 31.
                       LEAVE Valida.
                    END.
        
                IF  par_nmbairro = "" THEN
                    DO:
                       ASSIGN aux_cdcritic = 47.
                       LEAVE Valida.
                    END.
        
                IF  par_nmcidade = "" THEN
                    DO:
                       ASSIGN aux_cdcritic = 32.
                       LEAVE Valida.
                    END.
        
                IF  NOT ValidaUf(par_cdufende) THEN
                    DO:
                       ASSIGN aux_cdcritic = 33.
                       LEAVE Valida.
                    END.
        
                IF  NOT CAN-FIND(FIRST crapdne
                                 WHERE crapdne.nrceplog = par_nrcepend AND 
                                       (TRIM(par_dsendere) MATCHES 
                                       ("*" + TRIM(crapdne.nmextlog) + "*") OR
                                       TRIM(par_dsendere) MATCHES
                                       ("*" + TRIM(crapdne.nmreslog) + "*"))) 
                    THEN
                    DO:
                        ASSIGN aux_dscritic = "Endereco nao pertence ao CEP.".
                        LEAVE Valida.
                    END.
            END.

        IF  par_nmmaecto = "" THEN
            DO:
               ASSIGN aux_dscritic = "375 - O campo 'Nome da Mae' deve " + 
                                     "ser preenchido.".
               LEAVE Valida.
            END.

        IF  par_dtvalida = ?  THEN
            DO:
               ASSIGN aux_dscritic = "A data de Vigencia deve ser " + 
                                     "preenchida.".
               LEAVE Valida.
            END.

        IF  par_dtvalida < par_dtmvtolt THEN
            DO:
               ASSIGN aux_dscritic = "A data de Vigencia deve ser maior " + 
                                     "que a data atual.".
               LEAVE Valida.
            END.

        /* Verifica se o que foi digitado sao somente numeros */
        IF   par_nrdctato = 0 THEN
             DO:
                IF  NOT ValidaCpfCnpj(aux_nrcpfcto,OUTPUT aux_cdcritic) THEN
                    LEAVE Valida.
             END.

        RUN Busca_Idade (INPUT par_dtnascto,
                         INPUT par_dtmvtolt,
                         OUTPUT aux_nrdeanos).

        IF par_nrdctato <> 0  THEN
           DO:
              FOR FIRST crapttl FIELD(inhabmen)
                                WHERE crapttl.cdcooper = par_cdcooper AND
                                      crapttl.nrdconta = par_nrdctato AND
                                      crapttl.idseqttl = 1 NO-LOCK:

                  /* Seleciona o tipo de pessoa: PF/PJ */
                  FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = par_nrdctato 
                                     NO-LOCK.
                  ASSIGN aux_inpessoa = crapass.inpessoa.

                  /* Sera realizada a validacao de emancipacao apenas para 
                     pessoas que tiverem o estado civil diferente dos 
                     apresentados na condicao abaixo. Quando casado, a 
                     pessoa é automaticamente emancipada.*/
                  IF aux_inpessoa = 1 AND 
                     crapttl.inhabmen = 1 AND 
                     NOT CAN-DO("2,3,4,5,6,7,8,9,11",STRING(par_cdestcvl)) AND
                     (aux_nrdeanos < 16 OR aux_nrdeanos > 17) THEN
                     DO:
                        ASSIGN aux_dscritic = "Para emancipacao e necessario " +
                                              "ter entre 16 e 18.".
                        LEAVE Valida.

                     END.
                  ELSE
                     IF crapttl.inhabmen = 0                 AND
                        aux_nrdeanos < 18                    AND
                        par_nmrotina = "PROCURADORES_FISICA" THEN
                        DO:
                            ASSIGN aux_dscritic = "Nao permitido procurador " +
                                                  "menor de 18 anos.".
                            LEAVE Valida.

                        END.
                     ELSE
                        IF crapttl.inhabmen = 2                 AND 
                           par_nmrotina = "PROCURADORES_FISICA" THEN
                           DO:
                              ASSIGN aux_dscritic = "Responsab. Legal nao " +
                                                    "permitida para procurador.".
                              LEAVE Valida.

                           END.

              END.
           END.
        ELSE
           DO:
              /* Seleciona o tipo de pessoa: PF/PJ */
              FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                 crapass.nrdconta = par_nrdconta 
                                 NO-LOCK.
              ASSIGN aux_inpessoa = crapass.inpessoa.

              /* Sera realizada a validacao de emancipacao apenas para pessoas
                 que tiverem o estado civil diferente dos apresentados na
                 condicao abaixo. Quando casado, a pessoa é automaticamente
                 emancipada.*/
              IF aux_inpessoa = 1 AND 
                 par_inhabmen = 1 AND
                 NOT CAN-DO("2,3,4,5,6,7,8,9,11",STRING(par_cdestcvl)) AND
                 (aux_nrdeanos < 16 OR aux_nrdeanos > 17) THEN
                 DO: 
                    ASSIGN aux_dscritic = "Para emancipacao e necessario " +
                                          "ter entre 16 e 18.".
                    LEAVE Valida.

                 END.
              ELSE
                 IF par_inhabmen = 0                     AND
                    aux_nrdeanos < 18                    AND
                    par_nmrotina = "PROCURADORES_FISICA" THEN
                    DO: 
                        ASSIGN aux_dscritic = "Nao permitido procurador " +
                                              "menor de 18 anos.".
                        LEAVE Valida.

                    END.
                 ELSE 
                    IF par_inhabmen = 2                     AND 
                       par_nmrotina = "PROCURADORES_FISICA" THEN
                       DO: 
                          ASSIGN aux_dscritic = "Responsab. Legal nao " +
                                                "permitida para procurador.".
                          LEAVE Valida.

                       END.

           END.        
                
        /* Task 365, Procurador p/ PF - Jose Luis (DB1) */
        IF  CAN-FIND(FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                         crapass.nrdconta = par_nrdconta AND
                                         crapass.inpessoa > 1)           THEN
            DO:
               IF  NOT CAN-DO(
                  "SOCIO/PROPRIETARIO,DIRETOR/ADMINISTRADOR,PROCURADOR," +
                  "SOCIO COTISTA,SOCIO ADMINISTRADOR,SINDICO,"           + 
                  "TESOUREIRO,ADMINISTRADOR",par_dsproftl)  THEN
                   DO:
                       ASSIGN aux_dscritic = "O Cargo esta preenchido incorretamente.".
                       LEAVE Valida.
                   END.

               /* Se socio validar data de admissao a empresa*/
               IF   par_dsproftl = "SOCIO/PROPRIETARIO" AND par_dtadmsoc = ? THEN
                    DO:
                       ASSIGN aux_dscritic = "Informe a data da admissao na empresa.".
                       LEAVE Valida.
                    END.
        
               IF  par_dtadmsoc <> ?  THEN
                   DO:
                      IF (par_dtadmsoc > par_dtmvtolt) OR 
                          YEAR(par_dtadmsoc) < 1000 THEN
                          DO:
                             ASSIGN aux_dscritic =  "Data da admissao do socio na " + 
                                                    "empresa esta incorreta.".
                             LEAVE Valida.
                          END.
                   END.

               ASSIGN aux_flagdsnh = FALSE
                      aux_flgcarta = FALSE.
               
               IF  par_dsproftl  = "SOCIO/PROPRIETARIO" AND
                   aux_dsprofan <> "SOCIO/PROPRIETARIO" THEN
                   DO:            
                      FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                               crapsnh.nrdconta = par_nrdconta AND
                                               crapsnh.tpdsenha = 1            AND
                                               crapsnh.cdsitsnh = 1            
                                               NO-LOCK NO-ERROR.
               
                      IF  AVAILABLE crapsnh     AND
                         (crapsnh.vllimtrf > 0  OR
                          crapsnh.vllimpgo > 0) THEN
                          ASSIGN aux_flagdsnh = TRUE.
                      
                      Carta: FOR FIRST crapcrm FIELDS(cdsitcar)
                                 WHERE crapcrm.cdcooper = par_cdcooper AND
                                       crapcrm.nrdconta = par_nrdconta 
                                       NO-LOCK:
               
                          IF  crapcrm.cdsitcar = 2 THEN
                              DO:
                                  ASSIGN aux_flgcarta = TRUE.
                                  LEAVE Carta.
                              END.
                      END.
                      
                      IF  aux_flagdsnh OR aux_flgcarta THEN
                          par_msgalert = "Na inclusao de um novo SOCIO/"   +
                                         "PROPRIETARIO a internet/cartao " + 
                                         "magnetico serao bloqueados.".
                   END.
            END.

        /*
          Validar os percentuais societarios
        */
        IF  par_dsproftl = "Socio/Proprietario" AND par_persocio = 0  THEN
        DO:
           ASSIGN aux_dscritic = "% Societ. obrigatorio quando cargo " + 
                                 "for SOCIO/PROPRIETARIO.".
           LEAVE Valida.
        END.

        IF  par_persocio > 100  THEN
        DO:
           ASSIGN 
               aux_dscritic = "% Societ. nao deve ultrapassar 100%.".
           LEAVE Valida.
        END.

        RUN busca_perc_socio (INPUT par_cdcooper,
                              INPUT par_dsproftl,
                              INPUT par_persocio,
                              OUTPUT tab_persocio,
                              OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK"  THEN
        DO:
            FIND LAST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                aux_dscritic = tt-erro.dscritic.
            ELSE
                aux_dscritic = "Nao foi possivel encontrar % societario - TAB036".
            LEAVE Valida.
        END.
            
        /* alimenta o percentual da conta em questao */
        ASSIGN tot_persocio = par_persocio.
        
        
	    /* procuradores da conta */
	    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper   AND
	 	 					   crapavt.tpctrato = 6 /*procurad*/ AND
							   crapavt.nrdconta = par_nrdconta   AND
							   crapavt.nrctremp = par_idseqttl   
							   NO-LOCK:
		   /* despreza a conta em questao pois ja alimentou no variavel tot_persocio */
		   /* IF  crapavt.nrdctato = par_nrdctato  THEN 
			    NEXT. */
	   
		    IF  crapavt.nrcpfcgc = aux_nrcpfcto  THEN 
			    NEXT.
	   
	   
		    ASSIGN tot_persocio = tot_persocio + crapavt.persocio.
	   
	    END.

        IF par_nmrotina <> "PROCURADORES"             AND
           par_nmrotina <> "PROCURADORES_FISICA"       AND
           par_nmrotina <> "Representante/Procurador"  THEN
           DO:
              /* procuradores da conta */
               FOR EACH tt-crapavt-b WHERE
                                     tt-crapavt-b.cdcooper = par_cdcooper   AND
                                     tt-crapavt-b.tpctrato = 6 /*procurad*/ AND
                                     tt-crapavt-b.nrdconta = par_nrdconta   AND
                                     tt-crapavt-b.nrctremp = par_idseqttl   
                                     NO-LOCK:

                   IF tt-crapavt-b.nrcpfcgc = aux_nrcpfcto  THEN 
                      NEXT.
               
                   ASSIGN tot_persocio = tot_persocio + 
                                         tt-crapavt-b.persocio.
               
               END.

           END.

        /* empresas quem tem participacao na empresa */
        FOR EACH crapepa WHERE crapepa.cdcooper = par_cdcooper AND
                               crapepa.nrdconta = par_nrdconta   
                               NO-LOCK:

            ASSIGN tot_persocio = tot_persocio + crapepa.persocio.

        END.

        IF  tot_persocio > 100  THEN
        DO:
           ASSIGN 
               aux_dscritic = "% Societ. total nao deve ultrapassar 100%.".
           LEAVE Valida.
        END.
        
        /* validar os bens */
        IF NOT VALID-HANDLE(h-b1wgen0056) THEN
           RUN sistema/generico/procedures/b1wgen0056.p 
               PERSISTENT SET h-b1wgen0056.

        ASSIGN aux_nrdebens = 0.

        /* Realizar a validacao dos bens */
        FOR EACH tt-bens BY tt-bens.cdsequen:

            IF  aux_nrdebens > 6 THEN
                DO:
                   ASSIGN aux_dscritic = "Limite no cadastramento de bens " + 
                                         "atingido! Maximo 6 bens.".

                   IF VALID-HANDLE(h-b1wgen0056) THEN
                      DELETE OBJECT h-b1wgen0056.

                   LEAVE Valida.

                END.

            RUN Valida-Dados IN h-b1wgen0056
                ( INPUT par_cdcooper,
                  INPUT par_cdagenci,
                  INPUT par_nrdcaixa,
                  INPUT par_nrdconta,
                  INPUT par_idorigem,
                  INPUT par_nmdatela,
                  INPUT par_idseqttl,
                  INPUT par_cdoperad,
                  INPUT par_cddopcao,
                  INPUT tt-bens.dsrelbem,
                  INPUT tt-bens.persemon,
                  INPUT tt-bens.qtprebem,
                  INPUT tt-bens.vlprebem,
                  INPUT tt-bens.vlrdobem,
                  INPUT tt-bens.cdsequen,
                 OUTPUT TABLE tt-erro ).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                   IF VALID-HANDLE(h-b1wgen0056) THEN
                      DELETE OBJECT h-b1wgen0056.
                   
                   LEAVE Valida.

                END.

            ASSIGN aux_nrdebens = aux_nrdebens + 1.

        END.
        
        IF VALID-HANDLE(h-b1wgen0056) THEN
           DELETE OBJECT h-b1wgen0056.

        /* Valida se foi informado o valor e o referente, com relacao a outras
           fontes de renda do socio, no caso de socio/proprietario que nao
           depende economicamente.*/

        IF NOT par_flgdepec             AND 
           par_persocio >= tab_persocio AND 
           par_persocio > 0             AND 
          (par_vloutren = 0             OR 
           par_dsoutren = "")           THEN
        DO:
            ASSIGN aux_dscritic = "Outras fontes de renda do socio devem " +
                                  "ser informadas quando nao ha depend. econ.".

            LEAVE Valida.

        END.
        
        IF par_verrespo = TRUE THEN
           DO:
              IF NOT VALID-HANDLE(h-b1wgen0072) THEN
                 RUN sistema/generico/procedures/b1wgen0072.p 
                     PERSISTENT SET h-b1wgen0072.
              
              /*Busca todos os responsaveis do procurador em questao*/
              FOR EACH tt-resp WHERE 
                       tt-resp.cdcooper = par_cdcooper AND 
                       tt-resp.nrctamen = par_nrdctato AND 
                       tt-resp.nrcpfmen = (IF par_nrdctato = 0 THEN 
                                                    DEC(REPLACE(REPLACE(
                                                    par_nrcpfcgc, ".",""), 
                                                    "-",""))
                                                 ELSE 
                                                    0) 
                       NO-LOCK:

                  RUN Valida_Dados IN h-b1wgen0072 
                                         (INPUT par_cdcooper,    
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_idorigem,
                                          INPUT par_nrdctato,
                                          INPUT tt-resp.idseqmen,
                                          INPUT YES,
                                          INPUT tt-resp.nrdrowid,
                                          INPUT par_dtmvtolt,
                                          INPUT tt-resp.cddopcao,
                                          INPUT tt-resp.nrdconta,
                                          INPUT tt-resp.nrcpfcgc,
                                          INPUT tt-resp.nmrespon,
                                          INPUT tt-resp.tpdeiden,
                                          INPUT tt-resp.nridenti,
                                          INPUT tt-resp.dsorgemi,
                                          INPUT tt-resp.cdufiden,
                                          INPUT tt-resp.dtemiden,
                                          INPUT tt-resp.dtnascin,
                                          INPUT tt-resp.cddosexo,
                                          INPUT tt-resp.cdestciv,
                                          INPUT tt-resp.cdnacion,
                                          INPUT tt-resp.dsnatura,
                                          INPUT tt-resp.cdcepres,
                                          INPUT tt-resp.dsendres,
                                          INPUT tt-resp.dsbaires,
                                          INPUT tt-resp.dscidres,
                                          INPUT tt-resp.dsdufres,
                                          INPUT tt-resp.nmmaersp,
                                          INPUT NO,         
                                          INPUT aux_nrcpfcto,
                                          INPUT "PROCURADORES",
                                          INPUT par_dtnascto,
                                          INPUT par_inhabmen,
                                          INPUT par_permalte,
                                          INPUT TABLE tt-resp,
                                          OUTPUT aux_nmdcampo,
                                          OUTPUT TABLE tt-erro).
             
                  IF RETURN-VALUE <> "OK" THEN
                     DO:
                        IF VALID-HANDLE(h-b1wgen0072) THEN
                           DELETE PROCEDURE(h-b1wgen0072).
                      
                        UNDO Valida, LEAVE Valida.
             
                     END.
             
              END.
              
              IF NOT CAN-FIND(FIRST tt-resp WHERE
                     tt-resp.nrctamen = par_nrdctato              AND 
                     tt-resp.nrcpfmen = (IF par_nrdctato = 0      THEN 
                                                  DEC(REPLACE(REPLACE(
                                                  par_nrcpfcgc, ".",""), 
                                                  "-",""))
                                               ELSE 
                                                  0)                    AND
                     tt-resp.cdcooper = par_cdcooper              AND
                     tt-resp.nrctamen = par_nrdctato      
                     NO-LOCK)                                           AND 
               ((par_inhabmen = 0   AND
                 aux_nrdeanos < 18) OR
                 par_inhabmen = 2  ) THEN
              DO: 
                 ASSIGN aux_dscritic = "Deve existir pelo menos um " +
                                       "responsavel legal.".

                 IF VALID-HANDLE(h-b1wgen0072) THEN
                    DELETE PROCEDURE(h-b1wgen0072).

                 LEAVE Valida.

              END.
             
              IF VALID-HANDLE(h-b1wgen0072) THEN
                 DELETE PROCEDURE(h-b1wgen0072).

           END.

        LEAVE Valida.

    END.
    
    IF  VALID-HANDLE(h-b1wgen0056) THEN
        DELETE OBJECT h-b1wgen0056.

    IF  VALID-HANDLE(h-b1wgen0072) THEN
        DELETE OBJECT h-b1wgen0072.

    IF  (aux_dscritic <> ""         OR 
         aux_cdcritic <> 0)         AND 
         NOT CAN-FIND(LAST tt-erro) THEN
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,           
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).

    IF NOT CAN-FIND(LAST tt-erro) THEN
        ASSIGN aux_retorno = "OK".

    IF  par_flgerlog AND aux_retorno <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_retorno = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                            OUTPUT aux_nrdrowid).

    
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Valida_Inclui:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                     NO-UNDO. 
    DEF  INPUT PARAM TABLE FOR tt-crapavt-b.
    DEF  INPUT PARAM par_idorigem AS INT                      NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_flgcarta AS LOG                               NO-UNDO.

    DEF BUFFER crabass FOR crapass.
    DEF BUFFER b-tt-crapavt1 FOR tt-crapavt-b.
    
    ASSIGN par_dscritic = "Erro na validacao dos dados".
           aux_returnvl = "NOK".

    &SCOPED-DEFINE CPF-AVT STRING(STRING(tt-crapavt-b.nrcpfcgc,"99999999999"),"999.999.999-99")
     

    ValidaI: DO ON ERROR UNDO ValidaI, LEAVE ValidaI:
          
        IF par_nmrotina = "PROCURADORES"             OR
           par_nmrotina = "Representante/Procurador" OR 
           par_nmrotina = "PROCURADORES_FISICA"      THEN
           DO:
              /* Busca se o procurador ja foi cadastrado - CPF */
              IF par_nrcpfcgc <> 0 THEN
                 DO:
                    IF CAN-FIND(FIRST crapavt WHERE 
                                crapavt.cdcooper = par_cdcooper AND
                                crapavt.tpctrato = 6 /* jur */  AND
                                crapavt.nrdconta = par_nrdconta AND
                                crapavt.nrctremp = par_idseqttl AND
                                crapavt.nrcpfcgc = par_nrcpfcgc) THEN
                       DO:
                          ASSIGN par_dscritic = "Procurador ja cadastrado " +
                                                "para o associado.".
                          LEAVE ValidaI.
                       END.
              
                    FOR FIRST crabass FIELDS(nrdconta inpessoa)
                                      WHERE crabass.cdcooper = par_cdcooper AND
                                            crabass.nrcpfcgc = par_nrcpfcgc 
                                            NO-LOCK:

                    END.

                 END.
              
              /* Busca se o procurador ja foi cadastrado - NR.DA CONTA */
              IF par_nrdctato <> 0 THEN
                 DO:
                    IF CAN-FIND(FIRST crapavt WHERE 
                                crapavt.cdcooper = par_cdcooper AND
                                crapavt.tpctrato = 6 /* jur */  AND
                                crapavt.nrdconta = par_nrdconta AND
                                crapavt.nrctremp = par_idseqttl AND
                                crapavt.nrdctato = par_nrdctato) THEN
                       DO:
                          ASSIGN par_dscritic = "Procurador ja cadastrado " +
                                                "para o associado.".
                          LEAVE ValidaI.

                       END.
              
                    FOR FIRST crabass FIELDS(nrdconta inpessoa)
                                      WHERE crabass.cdcooper = par_cdcooper AND
                                            crabass.nrdconta = par_nrdctato 
                                            NO-LOCK:

                    END.

                 END.

           END.
        ELSE
           DO:
              FOR EACH tt-crapavt-b WHERE tt-crapavt-b.deletado = NO   AND 
                                          tt-crapavt-b.cddopcao <> "C" 
                                          NO-LOCK:
                  
                  IF tt-crapavt-b.cddopcao = "E" THEN
                     NEXT.

                  IF CAN-FIND(FIRST crapavt WHERE                     
                         crapavt.cdcooper = par_cdcooper           AND
                         crapavt.tpctrato = 6 /* jur */            AND
                         crapavt.nrdconta = par_nrdconta           AND
                         crapavt.nrctremp = 0                      AND
                         crapavt.nrcpfcgc = tt-crapavt-b.nrcpfcgc  AND
                         ROWID(crapavt)  <> tt-crapavt-b.rowidavt) AND 
                     tt-crapavt-b.cddopcao <> "A"                  THEN
                     DO:     
                        /* procura por um registro que esteje deletado apenas 
                           na memoria */
                        IF NOT CAN-FIND(FIRST b-tt-crapavt1 WHERE
                             b-tt-crapavt1.nrcpfcgc = tt-crapavt-b.nrcpfcgc AND
                             b-tt-crapavt1.deletado = YES)                 THEN
                        DO:
                           ASSIGN par_dscritic = "Procurador com CPF " + 
                                                {&CPF-AVT} + " ja cadastrado" +
                                                 " para o associado.".
                           
                           LEAVE ValidaI.
                  
                        END.
                  
                     END.
                     
                  IF CAN-FIND(FIRST b-tt-crapavt1 WHERE
                         b-tt-crapavt1.nrcpfcgc = tt-crapavt-b.nrcpfcgc    AND
                         b-tt-crapavt1.deletado = NO                       AND
                        (ROWID(b-tt-crapavt1)   <> ROWID(tt-crapavt-b)     OR
                         b-tt-crapavt1.rowidavt <> tt-crapavt-b.rowidavt)) AND 
                         tt-crapavt-b.cddopcao <> "A"                     THEN
                     DO:
                        ASSIGN par_dscritic = "Ja existe Procurador " + 
                                              "cadastrado " +
                                              "com o CPF " + {&CPF-AVT}.

                        LEAVE ValidaI.
                  
                     END.

              END.
              
              IF par_idorigem = 5 THEN
                 DO:
                    IF CAN-FIND(FIRST tt-crapavt-b WHERE 
                                      tt-crapavt-b.nrdconta = par_nrdconta AND
                                      (IF par_nrdctato = 0 THEN 
                                          tt-crapavt-b.nrcpfcgc = par_nrcpfcgc
                                       ELSE
                                          TRUE)                            AND
                                      tt-crapavt-b.nrdctato = par_nrdctato AND
                                      tt-crapavt-b.cddopcao <> "E"         AND
                                      tt-crapavt-b.deletado = NO) THEN
                       DO:
                           ASSIGN par_dscritic = "Procurador ja cadastrado " +
                                                      "para o associado.".
                           LEAVE ValidaI.

                       END.
                    
                    FOR FIRST crabass FIELDS(nrdconta inpessoa)
                                      WHERE crabass.cdcooper = par_cdcooper AND
                                            crabass.nrcpfcgc = par_nrcpfcgc 
                                            NO-LOCK:
                    
                    END.

                 END.

           END.


        IF AVAILABLE crabass  THEN
           DO: 
              IF  par_nrdconta = crabass.nrdconta  THEN
                  DO:
                     ASSIGN par_dscritic = "Titular da conta nao " +
                                           "pode ser procurador.".
                     LEAVE ValidaI.
                  END.
                                               
              /* somente pessoa fisica */
              IF  crabass.inpessoa <> 1 THEN 
                  DO:
                     ASSIGN par_cdcritic = 833.
                     LEAVE ValidaI.
                  END.
           END.                   

        /* se pessoa fisica, verifica se tem algum titular com o CPF informado */
        IF  CAN-FIND(crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta AND
                                   crapass.inpessoa = 1) AND
            CAN-FIND(FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                         crapttl.nrdconta = par_nrdconta AND
                                         crapttl.nrcpfcgc = par_nrcpfcgc) THEN
            DO:
                ASSIGN par_dscritic = "Titular da conta nao " +
                                      "pode ser procurador.".
                LEAVE ValidaI.

            END.
        
        ASSIGN par_dscritic = "".

        LEAVE ValidaI.

    END.
    
    IF par_dscritic = "" AND par_cdcritic = 0 THEN
       ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Altera:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_dsprofan AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_rowidavt AS ROWID                    NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-crapavt-b.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.

    ASSIGN par_dscritic = "Erro na validacao dos dados".
           aux_returnvl = "NOK".

    ValidaA: DO ON ERROR UNDO ValidaA, LEAVE ValidaA:

        /* Se for pessoa fisica, nao validar alteracao */
        IF  CAN-FIND(FIRST crapass WHERE 
                           crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta AND
                           crapass.inpessoa = 1)  THEN
            DO:
               ASSIGN par_dscritic = "".
               LEAVE ValidaA.

            END.

        IF (par_nmrotina = "PROCURADORES"         OR 
            par_nmrotina = "PROCURADORES_FISICA"  OR
            par_nmrotina = "Representante/Procurador") AND
            par_dsproftl <> par_dsprofan               AND
            par_dsprofan = "SOCIO/PROPRIETARIO"        THEN
            DO:
               IF  NOT CAN-FIND(FIRST crapavt NO-LOCK WHERE
                           crapavt.cdcooper = par_cdcooper         AND
                           crapavt.tpctrato = 6 /*juridica*/       AND
                           crapavt.nrdconta = par_nrdconta         AND
                           crapavt.dsproftl = "SOCIO/PROPRIETARIO" AND
                           ROWID(crapavt)  <> par_rowidavt) AND 
                   NOT CAN-FIND(FIRST crapepa WHERE
                         crapepa.cdcooper = par_cdcooper AND
                         crapepa.nrdconta = par_nrdconta) THEN
                   DO: 
                      FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                         crapjur.nrdconta = par_nrdconta 
                                         NO-LOCK NO-ERROR.

                      IF AVAIL crapjur THEN
                         DO:
                            FIND gncdntj WHERE 
                                         gncdntj.cdnatjur = crapjur.natjurid AND
                                         gncdntj.flgprsoc = TRUE 
                                         NO-LOCK NO-ERROR.

                            IF AVAIL gncdntj THEN
                               DO: 
                                  ASSIGN par_dscritic = "Deve existir pelo " + 
                                                        "menos um " +
                                                     "representante/procurador".

                                  LEAVE ValidaA.

                               END.

                         END.

                      FOR EACH crapcrm FIELDS(cdsitcar) WHERE
                               crapcrm.cdcooper = par_cdcooper AND
                               crapcrm.nrdconta = par_nrdconta
                               NO-LOCK:

                         IF  crapcrm.cdsitcar = 2 THEN /* ATIVO */
                             DO:
                                ASSIGN par_dscritic = "Deve existir pelo menos"
                                                   + " um SOCIO/PROPRIETARIO.".
                                LEAVE ValidaA.

                             END.

                      END.

                      FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                             AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
                      IF NOT AVAILABLE crapass THEN
                        DO:
                          ASSIGN par_dscritic = "Associado nao cadastrado.".
                          LEAVE ValidaA.
                        END.
          
                      IF crapass.idastcjt = 1 THEN /* Exige assinatura conjunta */
                        DO:
                          FOR FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                  crappod.nrdconta = par_nrdconta AND
                                                  crappod.cddpoder = 10           AND
                                                  crappod.flgconju = TRUE 
                                                  NO-LOCK. END.
                          IF AVAIL crappod  THEN
                            DO:
                              ASSIGN par_dscritic = "Deve existir pelo menos" +
                                                         " um SOCIO/PROPRIETARIO.".
                              LEAVE ValidaA.
                            END.
                        END.
                      ELSE
                        DO:
                          FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper     AND
                                                   crapsnh.nrdconta = par_nrdconta     AND
                                                   crapsnh.tpdsenha = 1 /* Internet */ AND
                                                   crapsnh.idseqttl = 1                AND
                                                   crapsnh.cdsitsnh = 1 NO-LOCK NO-ERROR.
                                         
                          IF  AVAILABLE crapsnh     AND
                            (crapsnh.vllimtrf > 0  OR
                             crapsnh.vllimpgo > 0) THEN
                             DO:
                                 ASSIGN par_dscritic = "Deve existir pelo menos" +
                                                       " um SOCIO/PROPRIETARIO.".
                                 LEAVE ValidaA.
                             END.
                        END.
                      
                   END.
            END.
        ELSE
           DO:
            IF  par_dsproftl <> par_dsprofan         AND
                par_dsprofan = "SOCIO/PROPRIETARIO"  THEN
                DO: 
                    IF NOT CAN-FIND(FIRST tt-crapavt-b NO-LOCK WHERE
                           tt-crapavt-b.cdcooper = par_cdcooper         AND
                           tt-crapavt-b.nrdconta = par_nrdconta         AND
                           tt-crapavt-b.dsproftl = "SOCIO/PROPRIETARIO" AND
                           ROWID(tt-crapavt-b)  <> par_rowidavt)        AND 
                       NOT CAN-FIND(FIRST crapepa WHERE
                           crapepa.cdcooper = par_cdcooper              AND
                           crapepa.nrdconta = par_nrdconta)             THEN
                       DO:
                          
                          FOR EACH crapcrm FIELDS(cdsitcar) WHERE
                                   crapcrm.cdcooper = par_cdcooper AND
                                   crapcrm.nrdconta = par_nrdconta
                                   NO-LOCK:
                       
                             IF crapcrm.cdsitcar = 2 THEN /* ATIVO */
                                DO:
                                   ASSIGN par_dscritic = "Deve existir pelo" + 
                                                         " menos um "        +  
                                                         "SOCIO/PROPRIETARIO.".
                                   LEAVE ValidaA.

                                END.

                          END.

                          FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                             AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
                          IF NOT AVAILABLE crapass THEN
                            DO:
                              ASSIGN par_dscritic = "Associado nao cadastrado.".
                              LEAVE ValidaA.
                            END.
              
                          IF crapass.idastcjt = 1 THEN /* Exige assinatura conjunta */
                            DO:
                              FOR FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                      crappod.nrdconta = par_nrdconta AND
                                                      crappod.cddpoder = 10           AND
                                                      crappod.flgconju = TRUE 
                                                      NO-LOCK. END.
                              IF AVAIL crappod  THEN
                                DO:
                                  ASSIGN par_dscritic = "Deve existir pelo menos" +
                                                             " um SOCIO/PROPRIETARIO.".
                                  LEAVE ValidaA.
                                END.
                            END.
                          ELSE
                            DO:
                              /* Internet (Transf/Pagamentos) Ativa */
                              FIND FIRST crapsnh WHERE
                                    crapsnh.cdcooper = par_cdcooper AND
                                    crapsnh.nrdconta = par_nrdconta AND
                                    crapsnh.idseqttl = 1            AND
                                    crapsnh.tpdsenha = 1            AND
                                    crapsnh.cdsitsnh = 1
                                    NO-LOCK NO-ERROR.
                            
                              IF  AVAILABLE crapsnh      AND
                                 (crapsnh.vllimtrf > 0   OR
                                  crapsnh.vllimpgo > 0)  THEN
                                  DO: 
                                     ASSIGN par_dscritic = "Deve existir pelo" + 
                                                           " menos um " + 
                                                           "SOCIO/PROPRIETARIO.".
                                     LEAVE ValidaA.
                                  END.
                            END.

                       END.

                END.

           END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaA.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Exclui:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-crapavt-b.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_flagdsnh AS LOG                               NO-UNDO.
    DEF VAR aux_flgcarta AS LOG                               NO-UNDO.
    DEF VAR aux_rowidavt AS ROWID                             NO-UNDO.

    DEF BUFFER btt-crapavt FOR tt-crapavt-b.

    ASSIGN par_dscritic = "Erro na validacao dos dados".
           aux_returnvl = "NOK".

    ValidaE: DO ON ERROR UNDO ValidaE, LEAVE ValidaE:
        
        /* Se for pessoa fisica, nao validar exclusao */
        IF  CAN-FIND(FIRST crapass WHERE 
                           crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta AND
                           crapass.inpessoa = 1)  THEN
            DO:
               ASSIGN par_dscritic = "".

               LEAVE ValidaE.
            END.

        IF  CAN-FIND(FIRST crapass WHERE
                           crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta AND
                           crapass.nrcpfppt = par_nrcpfcgc AND 
                           crapass.nrcpfppt <> 0 NO-LOCK) THEN
            DO:
               ASSIGN par_dscritic = "Nao pode ser excluido o " +
                                     "representante/procurador" +
                                     " se ele for preposto.".
               LEAVE ValidaE.
            END.
            
        FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                             AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
        IF NOT AVAILABLE crapass THEN
          DO:
            ASSIGN par_dscritic = "Associado nao cadastrado.".
            LEAVE ValidaE.
          END.
        
        IF crapass.idastcjt = 1 THEN /* Exige assinatura conjunta */
          DO:
            FOR FIRST crappod WHERE crappod.cdcooper = par_cdcooper
                                AND crappod.nrdconta = par_nrdconta
                                AND crappod.nrctapro = par_nrdctato
                                AND crappod.nrcpfpro = par_nrcpfcgc
                                AND crappod.cddpoder = 10 NO-LOCK. END.
                                
            IF AVAILABLE crappod AND crappod.flgconju THEN
              DO:
                ASSIGN par_dscritic = "Nao pode ser excluido responsavel por " +
                                         "assinatura conjunta.".
                LEAVE ValidaE.
              END.
          END.
        ELSE    
          DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper     AND
                                     crapsnh.nrdconta = par_nrdconta     AND
                                     crapsnh.tpdsenha = 1 /* Internet */ AND
                                     crapsnh.idseqttl = 1                AND
                                     crapsnh.nrcpfcgc = par_nrcpfcgc     AND
                                     crapsnh.cdsitsnh = 1                
                                     NO-LOCK NO-ERROR.

            IF  AVAILABLE crapsnh     AND
               (crapsnh.vllimtrf > 0  OR
                crapsnh.vllimpgo > 0) THEN
                DO:
                   ASSIGN par_dscritic = "Nao pode ser excluido o " +
                                         "representante/procurador " + 
                                         "se ele for preposto.".
                   LEAVE ValidaE.

                END.
          END. 
       
        IF par_nmrotina = "PROCURADORES"             OR
           par_nmrotina = "PROCURADORES_FISICA"      OR
           par_nmrotina = "Representante/Procurador" THEN
           DO:
              FOR FIRST crapavt FIELDS(nrcpfcgc)
                                WHERE crapavt.cdcooper = par_cdcooper AND
                                      crapavt.tpctrato = 6 /* jur */  AND
                                      crapavt.nrdconta = par_nrdconta AND
                                      crapavt.nrctremp = par_idseqttl AND
                                      (IF par_nrdctato <> 0 THEN
                                          crapavt.nrdctato = par_nrdctato
                                       ELSE 
                                          crapavt.nrcpfcgc = par_nrcpfcgc) 
                                       NO-LOCK:

                  ASSIGN aux_rowidavt = ROWID(crapavt).

              END.

              /* Verifica se ha mais de um procurador p/ poder excluir */
              IF  NOT CAN-FIND(FIRST crapavt WHERE
                               crapavt.cdcooper = par_cdcooper  AND
                               crapavt.tpctrato = 6 /*jur*/     AND
                               crapavt.nrdconta = par_nrdconta  AND
                               ROWID(crapavt)  <> aux_rowidavt) AND
                  NOT CAN-FIND(FIRST crapepa WHERE
                               crapepa.cdcooper = par_cdcooper  AND
                               crapepa.nrdconta = par_nrdconta) THEN
                  DO:

                     FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                        crapjur.nrdconta = par_nrdconta 
                                        NO-LOCK NO-ERROR.
              
                     IF AVAIL crapjur THEN
                        DO:
                           FIND gncdntj WHERE 
                                        gncdntj.cdnatjur = crapjur.natjurid AND
                                        gncdntj.flgprsoc = TRUE 
                                        NO-LOCK NO-ERROR.
              
                           IF AVAIL gncdntj THEN
                              DO: 
                                 ASSIGN par_dscritic = "Deve existir pelo " + 
                                                       "menos um " +
                                                    "representante/procurador".
                              
                                 LEAVE ValidaE.
                              
                              END.
              
                        END.
                        
                  END.
              
              /* verifica se ha um socio proprietario,se houver verifica 
                 se eh o unico */
              IF  CAN-FIND(FIRST crapavt NO-LOCK WHERE
                                 crapavt.cdcooper = par_cdcooper         AND
                                 crapavt.tpctrato = 6 /*juridica*/       AND
                                 crapavt.nrdconta = par_nrdconta) THEN
              DO:
                 /* Verifica se eh o unico socio/proprietario p/ poder excluir */
                 IF  NOT CAN-FIND(FIRST crapavt NO-LOCK WHERE
                                  crapavt.cdcooper = par_cdcooper         AND
                                  crapavt.tpctrato = 6 /*juridica*/       AND
                                  crapavt.nrdconta = par_nrdconta         AND
                                  crapavt.dsproftl = "SOCIO/PROPRIETARIO" AND
                                  ROWID(crapavt)  <> aux_rowidavt) AND
                     NOT CAN-FIND(FIRST crapepa WHERE
                                        crapepa.cdcooper = par_cdcooper AND
                                        crapepa.nrdconta = par_nrdconta NO-LOCK) THEN
                     DO:
                        ASSIGN aux_flagdsnh = FALSE
                               aux_flgcarta = FALSE.
                        
                        FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                             AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
                        IF NOT AVAILABLE crapass THEN
                           DO:
                              ASSIGN par_dscritic = "Associado nao cadastrado.".
                              LEAVE ValidaE.
                           END.
                          
                        IF crapass.idastcjt = 1 THEN  /* Exige assinatura conjunta */
                           DO:
                              FOR FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                      crappod.nrdconta = par_nrdconta AND
                                                      crappod.cddpoder = 10           AND
                                                      crappod.flgconju = TRUE 
                                                      NO-LOCK. END.
                              IF AVAILABLE crappod THEN
                                 ASSIGN aux_flagdsnh = TRUE.
                           END.
                        ELSE
                           DO:
                              FIND FIRST crapsnh WHERE 
                                         crapsnh.cdcooper = par_cdcooper     AND
                                         crapsnh.nrdconta = par_nrdconta     AND
                                         crapsnh.tpdsenha = 1 /* Internet */ AND
                                         crapsnh.idseqttl = 1                AND
                                         crapsnh.cdsitsnh = 1                
                                         NO-LOCK NO-ERROR.
                              
                              IF  AVAILABLE crapsnh     AND
                                 (crapsnh.vllimtrf > 0  OR
                                  crapsnh.vllimpgo > 0) THEN
                                  ASSIGN aux_flagdsnh = TRUE.
                           END.

                        FOR EACH crapcrm WHERE
                                 crapcrm.cdcooper = par_cdcooper AND
                                 crapcrm.nrdconta = par_nrdconta 
                                 NO-LOCK:
              
                            IF crapcrm.cdsitcar = 2   THEN /* ATIVO */     
                               DO:
                                   ASSIGN aux_flgcarta = TRUE.
                                   LEAVE.

                               END.

                        END.
              
                        IF aux_flagdsnh OR aux_flgcarta  THEN
                           DO:
                              ASSIGN par_dscritic = "Deve existir pelo menos um" +
                                                    " SOCIO/PROPRIETARIO.".
                              LEAVE ValidaE.
                           END.    

                     END.

              END.

           END.
        ELSE
           DO: 
              FOR FIRST btt-crapavt FIELDS(nrcpfcgc)
                                WHERE btt-crapavt.cdcooper = par_cdcooper AND
                                      btt-crapavt.nrdconta = par_nrdconta AND
                                      btt-crapavt.nrdctato = par_nrdctato AND
                                      btt-crapavt.nrcpfcgc = par_nrcpfcgc 
                                      NO-LOCK:
                  
                  ASSIGN aux_rowidavt = ROWID(btt-crapavt).

              END.

              IF NOT CAN-FIND(FIRST tt-crapavt-b WHERE
                                    tt-crapavt-b.deletado = NO    AND
                                    tt-crapavt-b.cddopcao <> "E") AND 
                 NOT CAN-FIND(FIRST crapepa WHERE
                               crapepa.cdcooper = par_cdcooper    AND
                               crapepa.nrdconta = par_nrdconta)   THEN
                 DO:
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                       crapjur.nrdconta = par_nrdconta 
                                       NO-LOCK NO-ERROR.

                    IF AVAIL crapjur THEN
                       DO: 
                          FIND gncdntj WHERE 
                                       gncdntj.cdnatjur = crapjur.natjurid AND
                                       gncdntj.flgprsoc = TRUE 
                                       NO-LOCK NO-ERROR.

                          IF AVAIL gncdntj THEN
                             DO: 
                                ASSIGN par_dscritic = "Deve existir pelo "    +
                                                      "menos um representante"+
                                                      "/procurador!".
          
                                LEAVE ValidaE.
                             
                             END.
          
                       END.
          
                 END.

              /* verifica se ha um socio proprietario,se houver verifica 
                 se eh o unico */
              IF  CAN-FIND(FIRST tt-crapavt-b WHERE
                                 tt-crapavt-b.cdcooper = par_cdcooper    AND
                                 tt-crapavt-b.tpctrato = 6               AND
                                 tt-crapavt-b.nrdconta = par_nrdconta   
                                 NO-LOCK)                                THEN
              DO: 
                 /*Verifica se eh o unico socio/proprietario p/ poder excluir*/
                 IF  NOT CAN-FIND(FIRST tt-crapavt-b  WHERE
                         tt-crapavt-b.cdcooper = par_cdcooper         AND
                         tt-crapavt-b.tpctrato = 6                    AND
                         tt-crapavt-b.nrdconta = par_nrdconta         AND
                         tt-crapavt-b.dsproftl = "SOCIO/PROPRIETARIO" AND
                         ROWID(tt-crapavt-b)  <> aux_rowidavt         
                         NO-LOCK)                                     AND
                     NOT CAN-FIND(FIRST crapepa WHERE
                                        crapepa.cdcooper = par_cdcooper AND
                                        crapepa.nrdconta = par_nrdconta 
                                        NO-LOCK)                        THEN
                     DO: 
                        ASSIGN aux_flagdsnh = FALSE
                               aux_flgcarta = FALSE.

                        FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                             AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
                        IF NOT AVAILABLE crapass THEN
                           DO:
                             ASSIGN par_dscritic = "Associado nao cadastrado.".
                             LEAVE ValidaE.
                           END.
                          
                        IF crapass.idastcjt = 1 THEN  /* Exige assinatura conjunta */
                           DO:
                             FOR FIRST crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                     crappod.nrdconta = par_nrdconta AND
                                                     crappod.cddpoder = 10           AND
                                                     crappod.flgconju = TRUE 
                                                     NO-LOCK. END.
                             IF AVAILABLE crappod THEN
                                ASSIGN aux_flagdsnh = TRUE.
                           END.
                        ELSE
                           DO:
                             FIND FIRST crapsnh WHERE 
                                        crapsnh.cdcooper = par_cdcooper     AND
                                        crapsnh.nrdconta = par_nrdconta     AND
                                        crapsnh.tpdsenha = 1 /* Internet */ AND
                                        crapsnh.idseqttl = 1                AND
                                        crapsnh.cdsitsnh = 1                
                                        NO-LOCK NO-ERROR.
                             
                             IF  AVAILABLE crapsnh     AND
                                (crapsnh.vllimtrf > 0  OR
                                 crapsnh.vllimpgo > 0) THEN
                                 ASSIGN aux_flagdsnh = TRUE.
                           END.

                        FOR EACH crapcrm WHERE
                                 crapcrm.cdcooper = par_cdcooper AND
                                 crapcrm.nrdconta = par_nrdconta 
                                 NO-LOCK:

                            IF crapcrm.cdsitcar = 2   THEN /* ATIVO */     
                               DO:
                                   ASSIGN aux_flgcarta = TRUE.
                                   LEAVE.
                               END.

                        END.

                        IF aux_flagdsnh OR aux_flgcarta  THEN
                           DO:
                              ASSIGN par_dscritic = "Deve existir pelo menos um" +
                                                    " SOCIO/PROPRIETARIO.".
                              LEAVE ValidaE.

                           END.    

                     END.

              END.


           END.

        IF  par_nrcpfcgc <> 0 THEN
            DO:
                /* Verifica se representante/procurador eh representante de cartao 
                   de credito desta conta e se o mesmo eh titular de cartao ativo */
                FOR EACH craphcj WHERE craphcj.cdcooper = par_cdcooper  AND
                                       craphcj.nrdconta = par_nrdconta  AND
                                      (craphcj.nrcpfpri = par_nrcpfcgc  OR
                                       craphcj.nrcpfseg = par_nrcpfcgc  OR
                                       craphcj.nrcpfter = par_nrcpfcgc)   
                                       NO-LOCK,
        
                   FIRST crawcrd WHERE crawcrd.cdcooper = craphcj.cdcooper    AND
                                       crawcrd.nrdconta = craphcj.nrdconta    AND
                                       crawcrd.cdadmcrd = 3                   AND  
                                      (crawcrd.insitcrd = 0   /* estudo */    OR 
                                       crawcrd.insitcrd = 1   /* aprov */     OR 
                                       crawcrd.insitcrd = 2   /* solic */     OR 
                                       crawcrd.insitcrd = 3   /* liberado */  OR 
                                       crawcrd.insitcrd = 4   /* em uso */ )  
                                       NO-LOCK:
                                       
                    ASSIGN par_dscritic = "Representante com cartao de credito.".
                    LEAVE ValidaE.
        
                END.
            
            END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaE.

    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE grava_logtel:

    DEF INPUT PARAM par_cdcooper    LIKE    crapass.cdcooper    NO-UNDO.
    DEF INPUT PARAM par_cdoperad    LIKE    crapope.cdoperad    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                NO-UNDO.
    DEF INPUT PARAM par_msgdolog    AS      CHAR                NO-UNDO.


    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                       NO-LOCK NO-ERROR.
           
    IF  NOT AVAIL(crapcop) THEN
        RETURN "NOK".

    UNIX SILENT VALUE 
        ("echo "      +   STRING(par_dtmvtolt,"99/99/9999")     +
         " "          +   STRING(TIME,"HH:MM:SS")               +
         " --'> ' Operador "  + par_cdoperad + " - "            +
         par_msgdolog                                           +
         " >> /usr/coop/" + TRIM(crapcop.dsdircop)              +
         "/log/contas.log").
           
    RETURN "OK".
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
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdctato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocava AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocava AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdoeddoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufddoc AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtemddoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsexcto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacion AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmmaecto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmpaicto AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsrelbem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtvalida AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsproftl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtadmsoc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_persocio AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgdepec AS LOGICAL                        NO-UNDO.
    DEF  INPUT PARAM par_vloutren AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsoutren AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inhabmen AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dthabmen AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmrotina AS CHAR                           NO-UNDO.
    
    DEF  INPUT PARAM TABLE FOR tt-bens.
    DEF  INPUT PARAM TABLE FOR tt-resp.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
                         
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabcrm FOR crapcrm.
    DEF BUFFER crabsnh FOR crapsnh.
    DEF BUFFER b-crapavt FOR crapavt.

    DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_dsprofan AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgfirst AS LOG                                     NO-UNDO.
    DEF VAR aux_flgtroca AS LOG                                     NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdadant AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdadatu AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdsitsnh AS CHAR 
        EXTENT 4 INIT ["Inativo","Ativo","Bloqueado","Cancelado"]   NO-UNDO.
    DEF VAR aux_rowidavt AS ROWID                                   NO-UNDO.
    DEF VAR aux_bensdavt AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdsexcto AS INTE                                    NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpatlcad AS INTE                                    NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INT                                     NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_idorgexp AS INT                                     NO-UNDO. 

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF par_cddopcao = "I" THEN 
                              "Inclusao" 
                           ELSE 
                              IF  par_cddopcao = "A" THEN 
                                  "Alteracao"
                              ELSE 
                                  "Exclusao") + " de Representante/Procurador"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno  = "NOK"
           aux_nmdcampo = ""
           aux_dsrotina = ""
           aux_inpessoa = 0
           aux_stsnrcal = FALSE.
    
    EMPTY TEMP-TABLE tt-erro.

    IF par_cddopcao = "I" THEN
       DO:  
           ContadorDoc9: DO TRANSACTION ON ENDKEY UNDO ContadorDoc9, LEAVE ContadorDoc9
                           ON ERROR  UNDO ContadorDoc9, LEAVE ContadorDoc9
                           ON STOP   UNDO ContadorDoc9, LEAVE ContadorDoc9: DO aux_contador = 1 TO 10:
    
                                FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                                   crapdoc.nrdconta = par_nrdconta AND
                                                   crapdoc.tpdocmto = 9            AND
                                                   crapdoc.dtmvtolt = par_dtmvtolt AND
                                                   crapdoc.idseqttl = par_idseqttl
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                                IF NOT AVAILABLE crapdoc THEN
                                    DO:
                                        IF LOCKED(crapdoc) THEN
                                            DO:
                                                IF aux_contador = 10 THEN
                                                    DO:
                                                        ASSIGN aux_cdcritic = 341.
                                                        LEAVE ContadorDoc9.
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
                                                       crapdoc.tpdocmto = 9
                                                       crapdoc.idseqttl = par_idseqttl.
                                                VALIDATE crapdoc.        
                                                LEAVE ContadorDoc9.
                                            END.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN crapdoc.flgdigit = FALSE
                                               crapdoc.dtmvtolt = par_dtmvtolt.
                
                                        LEAVE ContadorDoc9.
                                    END.
                            END.
                        END.

            ContadorDoc6: DO TRANSACTION ON ENDKEY UNDO ContadorDoc6, LEAVE ContadorDoc6
                           ON ERROR  UNDO ContadorDoc6, LEAVE ContadorDoc6
                           ON STOP   UNDO ContadorDoc6, LEAVE ContadorDoc6: DO aux_contador = 1 TO 10:
    
                            FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                               crapdoc.nrdconta = par_nrdconta AND
                                               crapdoc.tpdocmto = 6            AND
                                               crapdoc.dtmvtolt = par_dtmvtolt AND
                                               crapdoc.idseqttl = par_idseqttl
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                            IF NOT AVAILABLE crapdoc THEN
                                DO:
                                    IF LOCKED(crapdoc) THEN
                                        DO:
                                            IF aux_contador = 10 THEN
                                                DO:
                                                    ASSIGN aux_cdcritic = 341.
                                                    LEAVE ContadorDoc6.
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
                                                   crapdoc.tpdocmto = 6
                                                   crapdoc.idseqttl = par_idseqttl.
                                            VALIDATE crapdoc.        
                                            LEAVE ContadorDoc6.
                                        END.
                                END.
                            ELSE
                                DO:
                                    ASSIGN crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt.
            
                                    LEAVE ContadorDoc6.
                                END.
                        END.
                    END.

           ContadorDoc7: DO TRANSACTION ON ENDKEY UNDO ContadorDoc7, LEAVE ContadorDoc7
                           ON ERROR  UNDO ContadorDoc7, LEAVE ContadorDoc7
                           ON STOP   UNDO ContadorDoc7, LEAVE ContadorDoc7: DO aux_contador = 1 TO 10:
    
                            FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                               crapdoc.nrdconta = par_nrdconta AND
                                               crapdoc.tpdocmto = 7            AND
                                               crapdoc.dtmvtolt = par_dtmvtolt AND
                                               crapdoc.idseqttl = par_idseqttl
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                            IF NOT AVAILABLE crapdoc THEN
                                DO:
                                    IF LOCKED(crapdoc) THEN
                                        DO:
                                            IF aux_contador = 10 THEN
                                                DO:
                                                    ASSIGN aux_cdcritic = 341.
                                                    LEAVE ContadorDoc7.
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
                                                   crapdoc.tpdocmto = 7
                                                   crapdoc.idseqttl = par_idseqttl.
                                            VALIDATE crapdoc.        
                                            LEAVE ContadorDoc7.
                                        END.
                                END.
                            ELSE
                                DO:
                                    ASSIGN crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt.
            
                                    LEAVE ContadorDoc7.
                                END.
                        END.
                    END.

           IF par_nmrotina = "Representante/Procurador" THEN
                ASSIGN aux_msgdolog = "Incluiu na conta " + 
                                    STRING(par_nrdconta) +
                                    " Representante/Procurador conta "      + 
                                    STRING(par_nrdctato) + " CPF "          +
                                    STRING(par_nrcpfcgc) + ", Vigencia "    +
                                    STRING(par_dtvalida) + ", Cargo "       +
                                    par_dsproftl + ", Admissao "    +
                                    STRING(par_dtadmsoc) + ", %Societario " +
                                    STRING(par_persocio,"z99.99")   + 
                                    ", Dependencia economica ".

                    
           ELSE
              ASSIGN aux_msgdolog = "Incluiu na conta " + 
                                    STRING(par_nrdconta) +
                                    " Representante/Procurador conta "      + 
                                    STRING(par_nrdctato) + " CPF "          +
                                    STRING(par_nrcpfcgc) + ", Vigencia "    +
                                    STRING(par_dtvalida).

           IF par_flgdepec = YES THEN
              ASSIGN aux_msgdolog = aux_msgdolog + "SIM".
           ELSE
              ASSIGN aux_msgdolog = aux_msgdolog + "NAO".
           
           RUN grava_logtel(INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT aux_msgdolog). 

       END.
    ELSE
       DO:
          IF par_cddopcao = "A" THEN
             DO: 
                 ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).

                 FIND b-crapavt 
                      WHERE b-crapavt.cdcooper = par_cdcooper AND
                            b-crapavt.tpctrato = 6            AND
                            b-crapavt.nrdconta = par_nrdconta AND
                            b-crapavt.nrctremp = par_idseqttl AND
                            b-crapavt.nrcpfcgc = aux_nrcpfcto
                            NO-LOCK NO-ERROR.

                 IF AVAIL(b-crapavt) THEN
                    DO: 
                       ASSIGN aux_msgdolog = "Alterou na conta "               +
                                            STRING(par_nrdconta)               +
                                            " Representante/Procurador conta " +
                                            STRING(par_nrdctato) + " CPF " +
                                            STRING(par_nrcpfcgc). 
                           
                       ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).                       
                       
                       IF par_dtvalida <> b-crapavt.dtvalida OR
                          par_tpdocava <> b-crapavt.tpdocava OR
                          par_nrdocava <> b-crapavt.nrdocava OR
                          aux_nrcpfcto <> b-crapavt.nrcpfcgc THEN
                          DO:    
                               ContadorDoc9: DO TRANSACTION ON ENDKEY UNDO ContadorDoc9, LEAVE ContadorDoc9
                               ON ERROR  UNDO ContadorDoc9, LEAVE ContadorDoc9
                               ON STOP   UNDO ContadorDoc9, LEAVE ContadorDoc9: DO aux_contador = 1 TO 10:
        
                                    FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                                       crapdoc.nrdconta = par_nrdconta AND
                                                       crapdoc.tpdocmto = 9            AND
                                                       crapdoc.dtmvtolt = par_dtmvtolt AND
                                                       crapdoc.idseqttl = par_idseqttl
                                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                                    IF NOT AVAILABLE crapdoc THEN
                                        DO:
                                            IF LOCKED(crapdoc) THEN
                                                DO:
                                                    IF aux_contador = 10 THEN
                                                        DO:
                                                            ASSIGN aux_cdcritic = 341.
                                                            LEAVE ContadorDoc9.
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
                                                           crapdoc.tpdocmto = 9
                                                           crapdoc.idseqttl = par_idseqttl.
                                                    VALIDATE crapdoc.        
                                                    LEAVE ContadorDoc9.
                                                END.
                                        END.
                                    ELSE
                                        DO:
                                            ASSIGN crapdoc.flgdigit = FALSE
                                                   crapdoc.dtmvtolt = par_dtmvtolt.
                    
                                            LEAVE ContadorDoc9.
                                        END.
                                END.
                            END.

                            ASSIGN aux_msgdolog = aux_msgdolog + 
                                                   ", Vigencia de "           +
                                                   STRING(b-crapavt.dtvalida) +
                                                   " para "                   +
                                                   STRING(par_dtvalida).  
                          END.

                       IF par_dsproftl <> b-crapavt.dsproftl THEN
                          DO:
                             ASSIGN aux_msgdolog = aux_msgdolog       + 
                                                   ", Cargo de "      +
                                                   b-crapavt.dsproftl +
                                                   " para "           +
                                                   par_dsproftl.
                                    
                          END.

                       IF par_persocio <> b-crapavt.persocio THEN
                          DO:
                             ASSIGN aux_msgdolog = aux_msgdolog   + 
                                     ", %Societario de "          +
                              STRING(b-crapavt.persocio,"z99.99") +      
                                    " para "                      +
                                  STRING(par_persocio,"z99.99").
                               
                          END.

                       IF par_flgdepec <> b-crapavt.flgdepec THEN
                          DO:
                             ASSIGN aux_msgdolog = aux_msgdolog     + 
                                                   ", Dependencia " + 
                                                   "economica de ".

                             IF b-crapavt.flgdepec = YES THEN
                                ASSIGN aux_msgdolog = aux_msgdolog + "SIM".
                             ELSE
                                ASSIGN aux_msgdolog = aux_msgdolog + "NAO".

                             ASSIGN aux_msgdolog = aux_msgdolog + " para ".
                             
                             IF par_flgdepec = YES THEN
                                ASSIGN aux_msgdolog = aux_msgdolog + "SIM".
                             ELSE
                                ASSIGN aux_msgdolog = aux_msgdolog + "NAO".
                              
                          END.

                       IF par_dtadmsoc <> b-crapavt.dtadmsoc THEN
                          DO:
                             ASSIGN aux_msgdolog = aux_msgdolog + 
                                                   ", Admissao de " +
                                                   STRING(b-crapavt.dtadmsoc) +
                                                   " para "                   +
                                                   STRING(par_dtadmsoc).

                          END.

                       RUN grava_logtel(INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT par_dtmvtolt,
                                        INPUT aux_msgdolog). 

                    END.

             END.

       END.
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).

        ASSIGN aux_dsprofan = ""
               aux_flgtroca = NO.

        FOR FIRST crapavt FIELDS(dsproftl)
                          WHERE crapavt.cdcooper = par_cdcooper AND
                                crapavt.tpctrato = 6 /* jur */  AND
                                crapavt.nrdconta = par_nrdconta AND
                                crapavt.nrctremp = par_idseqttl AND
                                crapavt.nrcpfcgc = aux_nrcpfcto 
                                NO-LOCK:

            ASSIGN aux_dsprofan = crapavt.dsproftl.

        END.

        IF par_cddopcao = "I" THEN
           ASSIGN aux_dsprofan = "".

        FOR FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK. END.

        IF  NOT AVAIL crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                UNDO Grava, LEAVE Grava.
            END.

        /* Se for pessoa juridica, bloqueia internet e magneticos */
        IF crapass.inpessoa > 1                 AND
           par_dsproftl  = "SOCIO/PROPRIETARIO" AND
           aux_dsprofan <> "SOCIO/PROPRIETARIO" THEN
           DO:
              FOR EACH crapcrm WHERE crapcrm.cdcooper = par_cdcooper AND
                                     crapcrm.nrdconta = par_nrdconta
                                     NO-LOCK:

                  ASSIGN aux_dscritic = ""
                         aux_cdcritic = 0
                         aux_flgfirst = YES.

                  ContadorCrm: DO aux_contador = 1 TO 10:

                      FIND crabcrm WHERE ROWID(crabcrm) = ROWID(crapcrm) 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabcrm THEN
                         DO:
                            IF LOCKED crabcrm  THEN
                               DO:
                                  IF aux_contador = 10  THEN
                                     DO:
                                         ASSIGN aux_cdcritic = 341.
                                         LEAVE ContadorCrm.
                                     END.
                                  ELSE
                                     DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorCrm.
                                     END.
                               END.
                            ELSE
                               DO:
                                  aux_dscritic = "Registro do Cartao Mag" +
                                                 "netico nao encontrado.".
                                  LEAVE ContadorCrm.
                               END.
                         END.
                      ELSE
                         DO:
                            IF crabcrm.cdsitcar = 2 AND aux_flgfirst THEN
                               DO:
                                  /* LOG DO BLOQUEIO DO CARTAO MAGNETICO */
                                  RUN proc_gerar_log 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdoperad,
                                       INPUT aux_dscritic,
                                       INPUT aux_dsorigem,
                                       INPUT "Cartao Magnetico - Bloqueio",
                                       INPUT TRUE,
                                       INPUT par_idseqttl, 
                                       INPUT par_nmdatela, 
                                       INPUT par_nrdconta, 
                                      OUTPUT aux_nrdrowid).
    
                                  ASSIGN aux_nmdcampo = "nrcartao"
                                        aux_dsdadant = STRING(crabcrm.nrcartao)
                                        aux_dsdadatu = "".
    
                                  RUN proc_gerar_log_item
                                      (INPUT aux_nrdrowid,
                                       INPUT aux_nmdcampo,
                                       INPUT aux_dsdadant,
                                       INPUT aux_dsdadatu).
    
                                  ASSIGN crabcrm.dtcancel = par_dtmvtolt
                                         crabcrm.cdsitcar = 4
                                         aux_flgfirst     = FALSE.
                               END.

                            LEAVE ContadorCrm.
                         END.
                  END.

                  IF aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
                     UNDO Grava, LEAVE Grava.

                  RELEASE crabcrm.

              END. /* FOR EACH crapcrm. */

              /*************/
              FOR EACH crabsnh WHERE crabsnh.cdcooper = par_cdcooper AND
                                     crabsnh.nrdconta = par_nrdconta AND
                                     crabsnh.tpdsenha = 1            AND
                                     crabsnh.cdsitsnh = 1 NO-LOCK:
                  
                Contador: DO aux_contador = 1 TO 10:

                    FIND FIRST crapsnh WHERE ROWID(crapsnh) = ROWID(crabsnh) EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF NOT AVAILABLE crapsnh THEN
                       DO:
                           IF LOCKED crapsnh  THEN
                              DO:
                                  IF  aux_contador = 10  THEN
                                      DO:
                                          ASSIGN aux_cdcritic = 77.
                                          LEAVE Contador.
                                      END.
                                  ELSE
                                      DO:
                                          PAUSE 1 NO-MESSAGE.
                                          NEXT Contador.
                                      END.
                              END.
                           ELSE
                             LEAVE Contador.
                       END.

                    LEAVE Contador.
                END.

                IF  aux_dscritic <> "" OR aux_cdcritic <> 0  THEN
                    UNDO Grava, LEAVE Grava.

                IF  AVAILABLE crapsnh AND 
                    (crapsnh.vllimtrf > 0 OR crapsnh.vllimpgo > 0) THEN 
                    DO:
                        ASSIGN crapsnh.cdsitsnh = 2
                               crapsnh.dtaltsit = par_dtmvtolt
                               crapsnh.cdoperad = par_cdoperad
                               crapsnh.nrcpfcgc = 0 WHEN crapass.idastcjt = 0
                               aux_flgtroca     = YES.

                        VALIDATE crapsnh.
      
                        /* LOG DO BLOQUEIO DA INTERNET */
                        RUN proc_gerar_log 
                            (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT aux_dscritic,
                             INPUT aux_dsorigem,
                             INPUT "Internet - Bloqueio",
                             INPUT TRUE,
                             INPUT par_idseqttl, 
                             INPUT par_nmdatela, 
                             INPUT par_nrdconta, 
                            OUTPUT aux_nrdrowid).
      
                        IF   par_cddopcao = "I" THEN
                             ASSIGN 
                               aux_nmdcampo = "Inclusao de SOCIO/PROP"
                               aux_dsdadant = ""
                               aux_dsdadatu = "".
                        ELSE ASSIGN
                               aux_nmdcampo = "Bloqueio"
                               aux_dsdadant = STRING(crapsnh.cdsitsnh,"9") + 
                                              " - " +
                                              aux_cdsitsnh[crapsnh.cdsitsnh + 1]
                               aux_dsdadatu = "2" + " - " + aux_cdsitsnh[2 + 1].
      
                        RUN proc_gerar_log_item
                            (INPUT aux_nrdrowid,
                             INPUT aux_nmdcampo,
                             INPUT aux_dsdadant,
                             INPUT aux_dsdadatu).

                        IF crapsnh.nrcpfcgc > 0 THEN
                           RUN proc_gerar_log_item
                              (INPUT aux_nrdrowid,
                               INPUT "CPF Representante",
                               INPUT "",
                               INPUT STRING(STRING(crapsnh.nrcpfcgc,"99999999999"),"xxx.xxx.xxx-xx")).
                    END.
             END. /*FOR EACH crabsnh*/
             /***********/
        END.

        Contador: DO aux_contador = 1 TO 10:

           FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                              crapavt.tpctrato = 6 /* jur */  AND
                              crapavt.nrdconta = par_nrdconta AND
                              crapavt.nrctremp = par_idseqttl AND
                              crapavt.nrcpfcgc = aux_nrcpfcto
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crapavt THEN
              DO:
                 IF LOCKED crapavt  THEN
                    DO:
                       ASSIGN aux_dscritic = "Cadastro de Representante/" +
                                             "Procurador esta sendo "     + 
                                             "alterado em outra estacao".
                       PAUSE 1 NO-MESSAGE.
                       NEXT Contador.
                    END.
                 ELSE
                    DO:
                       IF par_cddopcao = "A" THEN
                          DO:
                             ASSIGN aux_dscritic = "Cadastro de Representante"+
                                                 "/Procurador nao encontrado.".
                             LEAVE Contador.
                          END.
                       ELSE 
                          DO:
                             CREATE crapavt.
                             ASSIGN crapavt.cdcooper = par_cdcooper
                                    crapavt.tpctrato = 6 /*juridica*/
                                    crapavt.nrdconta = par_nrdconta
                                    crapavt.nrctremp = par_idseqttl
                                    crapavt.nrdctato = par_nrdctato
                                    crapavt.dtmvtolt = par_dtmvtolt
                                    crapavt.nrcpfcgc = aux_nrcpfcto
                                    crapavt.flgimpri = TRUE.
                             VALIDATE crapavt.
                             LEAVE Contador.

                          END.

                    END.

              END.
           ELSE
              DO:
                  ASSIGN aux_dscritic = ""
                         aux_cdcritic = 0.
    
                  LEAVE Contador.
              END.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        /* preparar p/ registro do log de alteracao */
        CREATE tt-crapavt-ant.

        IF  par_cddopcao <> "I" THEN
            DO:
                BUFFER-COPY crapavt TO tt-crapavt-ant.
                IF  par_dtvalida <> crapavt.dtvalida THEN
                    ASSIGN crapavt.idmsgvct = 0.
            END.            
        
        ASSIGN crapavt.dtvalida = par_dtvalida
               crapavt.dsproftl = UPPER(par_dsproftl)
               crapavt.dtadmsoc = par_dtadmsoc
               crapavt.flgdepec = par_flgdepec
               crapavt.persocio = par_persocio
               crapavt.vloutren = par_vloutren
               crapavt.dsoutren = TRIM(par_dsoutren)
               crapavt.flgimpri = TRUE.
        
        CASE par_cdsexcto:
            WHEN "M" THEN ASSIGN aux_cdsexcto = 1.
            WHEN "F" THEN ASSIGN aux_cdsexcto = 2.
            OTHERWISE ASSIGN aux_cdsexcto = INTEGER(par_cdsexcto).
        END CASE.

        
        /* Identificar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_idorgexp = 0.
        RUN identifica_org_expedidor IN h-b1wgen0052b 
                           (INPUT UPPER(par_cdoeddoc),
                            OUTPUT aux_idorgexp,
                            OUTPUT aux_cdcritic, 
                            OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            UNDO Grava, LEAVE Grava.
        END.


        IF  par_nrdctato = 0 THEN
            DO:
               ASSIGN crapavt.nmdavali    = UPPER(par_nmdavali)
                      crapavt.tpdocava    = par_tpdocava
                      crapavt.nrdocava    = par_nrdocava
                      crapavt.idorgexp    = aux_idorgexp
                      crapavt.cdufddoc    = UPPER(par_cdufddoc)
                      crapavt.dsproftl    = UPPER(par_dsproftl)
                      crapavt.dtemddoc    = par_dtemddoc
                      crapavt.dtnascto    = par_dtnascto
                      crapavt.cdsexcto    = aux_cdsexcto
                      crapavt.cdestcvl    = par_cdestcvl
                      crapavt.cdnacion    = par_cdnacion
                      crapavt.dsnatura    = UPPER(par_dsnatura)
                      crapavt.nrcepend    = par_nrcepend
                      crapavt.dsendres[1] = UPPER(par_dsendere)
                      crapavt.nrendere    = par_nrendere
                      crapavt.complend    = UPPER(par_complend)
                      crapavt.nmbairro    = UPPER(par_nmbairro)
                      crapavt.nmcidade    = UPPER(par_nmcidade)
                      crapavt.cdufresd    = UPPER(par_cdufende)
                      crapavt.nrcxapst    = par_nrcxapst
                      crapavt.vledvmto    = par_vledvmto
                      crapavt.nmmaecto    = UPPER(par_nmmaecto)
                      crapavt.nmpaicto    = UPPER(par_nmpaicto)
                      crapavt.inhabmen    = par_inhabmen
                      crapavt.dthabmen    = par_dthabmen NO-ERROR.

               IF  ERROR-STATUS:ERROR THEN
                   DO:
                      ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                      UNDO Grava, LEAVE Grava.
                   END.

               /* atualizar os dados dos bens */
               ASSIGN crapavt.dsrelbem = ""
                      crapavt.persemon = 0 
                      crapavt.qtprebem = 0 
                      crapavt.vlprebem = 0 
                      crapavt.vlrdobem = 0
                      aux_dscritic     = ""
                      aux_contador     = 0.

               /* Realizar a gravacao dos bens */
               FOR EACH tt-bens:

                   ASSIGN aux_contador = aux_contador + 1
                          crapavt.dsrelbem[aux_contador] = CAPS(tt-bens.dsrelbem)
                          crapavt.persemon[aux_contador] = tt-bens.persemon
                          crapavt.qtprebem[aux_contador] = tt-bens.qtprebem
                          crapavt.vlprebem[aux_contador] = tt-bens.vlprebem
                          crapavt.vlrdobem[aux_contador] = tt-bens.vlrdobem.

                   IF  ERROR-STATUS:ERROR THEN
                       DO:
                          aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                          UNDO Grava, LEAVE Grava.
                       END.

               END.

            END.
        ELSE
        DO:
            Contador: DO aux_contador = 1 TO 10:

                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdctato AND
                                   crapttl.idseqttl = 1 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF NOT AVAILABLE crapttl THEN
                   DO:
                      IF LOCKED crapttl  THEN
                         DO:
                            ASSIGN aux_dscritic = "Cadastro de titular" +
                                                  "esta sendo alterado " +
                                                  "em outra estacao".
                            PAUSE 1 NO-MESSAGE.
                            NEXT Contador.
                         END.
                      ELSE
                         DO:
                             ASSIGN aux_dscritic = "Cadastro de titular " +
                                                   "nao encontrado".
                             PAUSE 1 NO-MESSAGE.
                             NEXT Contador.
                         END.
                   END.
                ELSE
                   DO:
                       ASSIGN aux_dscritic = ""
                              aux_cdcritic = 0.

                       LEAVE Contador.

                   END.

            END.

            IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
               UNDO Grava, LEAVE Grava.


        END.


        CREATE tt-crapavt-atl.

        IF  par_cddopcao <> "E" THEN
            BUFFER-COPY crapavt TO tt-crapavt-atl.


        IF NOT VALID-HANDLE(h-b1wgen0072) THEN
           RUN sistema/generico/procedures/b1wgen0072.p 
               PERSISTENT SET h-b1wgen0072.
        
        FOR EACH tt-resp WHERE tt-resp.cddopcao <> "C" NO-LOCK:

            RUN Grava_Dados IN h-b1wgen0072
                            (INPUT par_cdcooper,
                             INPUT 0,
                             INPUT 0,
                             INPUT par_cdoperad,
                             INPUT par_nmdatela,
                             INPUT 1,
                             INPUT tt-resp.nrctamen,
                             INPUT tt-resp.idseqmen,
                             INPUT YES,
                             INPUT tt-resp.nrdrowid,
                             INPUT par_dtmvtolt,
                             INPUT tt-resp.cddopcao,
                             INPUT tt-resp.nrdconta,
                             INPUT (IF tt-resp.nrdconta = 0 THEN
                                       tt-resp.nrcpfcgc
                                    ELSE
                                       0),
                             INPUT tt-resp.nmrespon,
                             INPUT tt-resp.tpdeiden,
                             INPUT tt-resp.nridenti,
                             INPUT tt-resp.dsorgemi,
                             INPUT tt-resp.cdufiden,
                             INPUT tt-resp.dtemiden,
                             INPUT tt-resp.dtnascin,
                             INPUT tt-resp.cddosexo,
                             INPUT tt-resp.cdestciv,
                             INPUT tt-resp.cdnacion,
                             INPUT tt-resp.dsnatura,
                             INPUT INT(tt-resp.cdcepres),
                             INPUT tt-resp.dsendres,
                             INPUT tt-resp.dsbaires,
                             INPUT tt-resp.dscidres,
                             INPUT tt-resp.nrendres,
                             INPUT tt-resp.dsdufres,
                             INPUT tt-resp.dscomres,
                             INPUT tt-resp.nrcxpost,
                             INPUT tt-resp.nmmaersp,
                             INPUT tt-resp.nmpairsp,
                             INPUT (IF tt-resp.nrctamen = 0 THEN 
                                       tt-resp.nrcpfmen
                                    ELSE
                                       0),
                             INPUT tt-resp.cdrlcrsp,
                             INPUT "Identificacao",
                             OUTPUT aux_msgalert,
                             OUTPUT aux_tpatlcad,
                             OUTPUT aux_msgatcad, 
                             OUTPUT aux_chavealt, 
                             OUTPUT TABLE tt-erro).

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  IF VALID-HANDLE(h-b1wgen0072) THEN
                     DELETE PROCEDURE(h-b1wgen0072).

                  UNDO Grava, LEAVE Grava.

               END.

        END.

        IF VALID-HANDLE(h-b1wgen0072) THEN
           DELETE PROCEDURE(h-b1wgen0072).

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
                 
        IF VALID-HANDLE(h-b1wgen0168) THEN
           DELETE PROCEDURE(h-b1wgen0168).

        IF RETURN-VALUE <> "OK" THEN
           UNDO Grava, LEAVE Grava.
        /* FIM - Atualizar os dados da tabela crapcyb */
        
        ASSIGN aux_retorno = "OK".

        LEAVE Grava.

    END.

    RELEASE crabcrm.
    RELEASE crapsnh. 
    RELEASE crapavt.

    
    IF (aux_dscritic <> "" OR aux_cdcritic <> 0) AND
        NOT CAN-FIND(LAST tt-erro) THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.

    IF NOT CAN-FIND(LAST tt-erro) THEN
       ASSIGN aux_retorno = "OK".

    IF aux_retorno = "OK"  AND 
       par_cddopcao <> "E" THEN
       Cad_Restritivo:
       DO WHILE TRUE:

          FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta
                             NO-LOCK NO-ERROR.

          IF NOT AVAIL crapass THEN
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

          IF NOT VALID-HANDLE(h-b1wgen9999) THEN
             RUN sistema/generico/procedures/b1wgen9999.p
                 PERSISTENT SET h-b1wgen9999.


          RUN valida-cpf-cnpj IN h-b1wgen9999(INPUT CarregaCpfCnpj(par_nrcpfcgc),
                                              OUTPUT aux_stsnrcal,
                                              OUTPUT aux_inpessoa).
                                              
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

          /*Monta a mensagem da rotina para envio no email*/
          IF crapass.inpessoa = 1 THEN
             DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.idseqttl = par_idseqttl 
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapttl THEN
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
                  
                ASSIGN aux_dsrotina = "Inclusao/alteracao do Rep/Procurador " +
                                      "conta "                                +
                                      STRING(par_nrdctato,"zzzz,zzz,9")       +
                                      " - CPF/CNPJ " + 
                                     (IF aux_inpessoa = 1 THEN
                                         STRING((STRING(CarregaCpfCnpj(
                                              par_nrcpfcgc),"99999999999")),
                                                            "xxx.xxx.xxx-xx")
                                      ELSE
                                         STRING((STRING(crapass.nrcpfcgc,
                                                  "99999999999999")),
                                                  "xx.xxx.xxx/xxxx-xx"))      +
                                      " no " + STRING(par_idseqttl)           +
                                      "o titular da conta "                   +
                                      STRING(crapttl.nrdconta,"zzzz,zzz,9")   +
                                      " - CPF/CNPJ "                          +
                                      STRING((STRING(crapttl.nrcpfcgc,
                                             "99999999999")),"xxx.xxx.xxx-xx").

             END.
          ELSE
             ASSIGN aux_dsrotina = "Inclusao/alteracao do "               +
                                   "Rep/Procurador conta "                +
                                   STRING(par_nrdctato,"zzzz,zzz,9")      +
                                   " - CPF/CNPJ " + 
                                  (IF aux_inpessoa = 1 THEN
                                      STRING((STRING(CarregaCpfCnpj(
                                             par_nrcpfcgc),"99999999999")),
                                             "xxx.xxx.xxx-xx")        
                                   ELSE
                                      STRING((STRING(crapass.nrcpfcgc,
                                               "99999999999999")),
                                               "xx.xxx.xxx/xxxx-xx"))     +
                                   " na conta "                           +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9")  +
                                   " - CPF/CNPJ "                         +
                                   STRING((STRING(crapass.nrcpfcgc,
                                           "99999999999999")),
                                           "xx.xxx.xxx/xxxx-xx").
                                  

          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p
                 PERSISTENT SET h-b1wgen0110.
          

          /*Verifica se o associado esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT (IF crapass.inpessoa = 1 THEN
                                                      crapttl.nrcpfcgc
                                                   ELSE
                                                      crapass.nrcpfcgc), 
                                            INPUT (IF crapass.inpessoa = 1 THEN
                                                      crapttl.nrdconta
                                                   ELSE
                                                      crapass.nrdconta),
                                            INPUT par_idseqttl,
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 29,    /*cdoperac*/
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
          
          /*Verifica se o Rep/Procurador esta no cadastro restritivo. Se 
            estiver, sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT CarregaCpfCnpj(par_nrcpfcgc),
                                            INPUT par_nrdctato,
                                            INPUT 1,     /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 29,    /*cdoperac*/
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


    IF par_flgerlog THEN
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
             INPUT BUFFER tt-crapavt-ant:HANDLE,
             INPUT BUFFER tt-crapavt-atl:HANDLE ).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Exclui_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgcarta AS LOG                                     NO-UNDO.
    DEF VAR aux_qtdavali AS INT                                     NO-UNDO.
    DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpatlcad AS INT                                     NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                    NO-UNDO.   
    DEF VAR aux_cdorgexp AS CHAR                                    NO-UNDO.   

    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.

    DEF BUFFER b-crapavt1 FOR crapavt.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Exclusao de Representante/Procurador"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno = "NOK"
           aux_qtdavali = 0.

Exclui: DO TRANSACTION
       ON ERROR  UNDO Exclui, LEAVE Exclui
       ON QUIT   UNDO Exclui, LEAVE Exclui
       ON STOP   UNDO Exclui, LEAVE Exclui
       ON ENDKEY UNDO Exclui, LEAVE Exclui:

       EMPTY TEMP-TABLE tt-erro.
       
       ASSIGN aux_nrcpfcto = CarregaCpfCnpj(par_nrcpfcgc).
       
       
       Contador: DO aux_contador = 1 TO 10:
            
           /* Exclusao de Poderes */
           FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
                                crappod.nrdconta = par_nrdconta AND
                                crappod.nrcpfpro = aux_nrcpfcto
                                EXCLUSIVE-LOCK:
               DELETE crappod.
           
           END.
           /* Fim Exclusao de Poderes */ 

           FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                              crapavt.tpctrato = 6 /* jur */  AND
                              crapavt.nrdconta = par_nrdconta AND
                              crapavt.nrctremp = par_idseqttl AND
                              crapavt.nrcpfcgc = aux_nrcpfcto
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF NOT AVAILABLE crapavt THEN
              DO:
                 IF LOCKED crapavt  THEN
                    DO:
                       aux_dscritic = "Cadastro de Representante/"     +
                                      "Procurador esta sendo alterado " +
                                      "em outra estacao".
                       PAUSE 1 NO-MESSAGE.
                       NEXT Contador.
                    END.
                 ELSE
                    DO:
                        aux_dscritic = "Cadastro de Representante/"     +
                                       "Procurador nao foi encontrado.".
                        LEAVE Contador.
                    END.
              END.
      
           ASSIGN aux_dscritic = ""
                  aux_cdcritic = 0.

           LEAVE Contador.

       END.

       IF aux_dscritic <> "" OR 
          aux_cdcritic <> 0  THEN
          UNDO Exclui, LEAVE Exclui.

       FOR FIRST crapass FIELDS(idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                             AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
        
       IF NOT AVAILABLE crapass THEN
         DO:
           ASSIGN aux_dscritic = "Associado nao cadastrado.".
           LEAVE Exclui.
         END.
          
       IF crapass.idastcjt = 1 THEN DO:
         /* Deletar Senha da Internet e Letras de Seguranca do Representante Legal */
          FOR FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper     AND
                                  crapsnh.nrdconta = par_nrdconta     AND
                                 (crapsnh.tpdsenha = 1 /* INTERNET */ OR
                                  crapsnh.tpdsenha = 3 /* LETRAS */)  AND
                                  crapsnh.nrcpfcgc = aux_nrcpfcto EXCLUSIVE-LOCK: 
              
              /* Deletar Historico de senhas do Representante Legal */
              FOR EACH craphsh WHERE craphsh.cdcooper = crapsnh.cdcooper AND
                                     craphsh.nrdconta = crapsnh.nrdconta AND
                                     craphsh.idseqttl = crapsnh.idseqttl AND
                                     craphsh.tpdsenha = crapsnh.tpdsenha EXCLUSIVE-LOCK:

                  DELETE craphsh.

              END.

              DELETE crapsnh.

          END.
        END.

       /*Soh serao deletados os resp. legal de procuradores que nao sao 
         associados e que estejam relacionados a apenas um cooperado.*/
       FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrcpfcgc = aux_nrcpfcto
                                NO-LOCK NO-ERROR.

       IF NOT AVAIL crapass THEN
          DO: 
             FOR EACH b-crapavt1 WHERE b-crapavt1.cdcooper = par_cdcooper AND
                                       b-crapavt1.tpctrato = 6            AND
                                       b-crapavt1.nrctremp = par_idseqttl AND
                                       b-crapavt1.nrcpfcgc = aux_nrcpfcto
                                       NO-LOCK:
                 
                 ASSIGN aux_qtdavali = aux_qtdavali + 1.
             
             END.           

             IF aux_qtdavali <= 1 THEN
                DO:
                   FOR EACH crapcrl WHERE 
                            crapcrl.cdcooper = crapavt.cdcooper         AND
                            crapcrl.nrctamen = crapavt.nrdctato         AND
                            crapcrl.nrcpfmen = (IF crapavt.nrdctato = 0 THEN
                                                   crapavt.nrcpfcgc
                                                ELSE
                                                   0)                   AND
                            crapcrl.idseqmen = crapavt.nrctremp
                            NO-LOCK:
                     
                       /* Retornar orgao expedidor */
                       IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                              RUN sistema/generico/procedures/b1wgen0052b.p 
                                  PERSISTENT SET h-b1wgen0052b.

                       ASSIGN aux_cdorgexp = "".
                       RUN busca_org_expedidor IN h-b1wgen0052b 
                                             ( INPUT crapcrl.idorgexp,
                                              OUTPUT aux_cdorgexp,
                                              OUTPUT aux_cdcritic, 
                                              OUTPUT aux_dscritic).

                       DELETE PROCEDURE h-b1wgen0052b.   

                       IF  RETURN-VALUE = "NOK" THEN
                       DO:
                           UNDO Exclui, LEAVE Exclui.
                       END.                         
                     
                       IF NOT VALID-HANDLE(h-b1wgen0072) THEN
                          RUN sistema/generico/procedures/b1wgen0072.p
                          PERSISTENT SET h-b1wgen0072.

                       RUN Grava_Dados IN h-b1wgen0072 
                                           (INPUT par_cdcooper,
                                            INPUT 0,
                                            INPUT 0,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT 1,
                                            INPUT crapavt.nrdctato,
                                            INPUT crapavt.nrctremp,
                                            INPUT FALSE,
                                            INPUT ?,
                                            INPUT TODAY,
                                            INPUT "E",
                                            INPUT crapcrl.nrdconta,
                                            INPUT crapcrl.nrcpfcgc,
                                            INPUT crapcrl.nmrespon,
                                            INPUT crapcrl.tpdeiden,
                                            INPUT crapcrl.nridenti,
                                            INPUT aux_cdorgexp,
                                            INPUT crapcrl.cdufiden,
                                            INPUT crapcrl.dtemiden,
                                            INPUT crapcrl.dtnascin,
                                            INPUT crapcrl.cddosexo,
                                            INPUT crapcrl.cdestciv,
                                            INPUT crapcrl.cdnacion,
                                            INPUT crapcrl.dsnatura,
                                            INPUT crapcrl.cdcepres,
                                            INPUT crapcrl.dsendres,
                                            INPUT crapcrl.dsbaires,
                                            INPUT crapcrl.dscidres,
                                            INPUT crapcrl.nrendres,
                                            INPUT crapcrl.dsdufres,
                                            INPUT crapcrl.dscomres,
                                            INPUT crapcrl.nrcxpost,
                                            INPUT crapcrl.nmmaersp,
                                            INPUT crapcrl.nmpairsp,
                                            INPUT crapavt.nrcpfcgc,
                                            INPUT crapcrl.cdrlcrsp,
                                            INPUT "PROC_RESP",
                                            OUTPUT aux_msgalert,
                                            OUTPUT aux_tpatlcad,
                                            OUTPUT aux_msgatcad, 
                                            OUTPUT aux_chavealt, 
                                            OUTPUT TABLE tt-erro) NO-ERROR.

                       IF VALID-HANDLE(h-b1wgen0072) THEN
                          DELETE OBJECT h-b1wgen0072.

                       IF RETURN-VALUE <> "OK" THEN
                          UNDO Exclui, LEAVE Exclui.

                   END.
                
                END.

          END.

       EMPTY TEMP-TABLE tt-crapavt-ant.
       EMPTY TEMP-TABLE tt-crapavt-atl.

       CREATE tt-crapavt-ant.
       BUFFER-COPY crapavt TO tt-crapavt-ant.
      
       ASSIGN aux_msgdolog = "Excluiu na conta " + 
                            STRING(par_nrdconta) +
                            " Representante/Procurador conta "      + 
                            STRING(crapavt.nrdctato) + " CPF "          +
                            STRING(par_nrcpfcgc).                    

       FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper 
                                NO-LOCK NO-ERROR.

       RUN grava_logtel(INPUT par_cdcooper,
                        INPUT par_cdoperad,
                        INPUT crapdat.dtmvtolt,
                        INPUT aux_msgdolog). 

       DELETE crapavt.
       CREATE tt-crapavt-atl.

       /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
       IF NOT VALID-HANDLE(h-b1wgen0168) THEN
          RUN sistema/generico/procedures/b1wgen0168.p
              PERSISTENT SET h-b1wgen0168.
                 
       EMPTY TEMP-TABLE tt-crapcyb.

       CREATE tt-crapcyb.
       ASSIGN tt-crapcyb.cdcooper = par_cdcooper
              tt-crapcyb.nrdconta = par_nrdconta
              tt-crapcyb.dtmancad = crapdat.dtmvtolt.

       RUN atualiza_data_manutencao_cadastro
           IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic ).
                 
       IF VALID-HANDLE(h-b1wgen0168) THEN
          DELETE PROCEDURE(h-b1wgen0168).

       IF RETURN-VALUE <> "OK" THEN
          UNDO Exclui, LEAVE Exclui.
       /* FIM - Atualizar os dados da tabela crapcyb */

       ASSIGN aux_retorno = "OK".

       LEAVE Exclui.

    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_retorno = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
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
              INPUT BUFFER tt-crapavt-ant:HANDLE,
              INPUT BUFFER tt-crapavt-atl:HANDLE).

    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Busca_Idade:

    DEF  INPUT PARAM par_dtnascto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdeanos AS INTE                           NO-UNDO.

    DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN idade IN h-b1wgen9999
         ( INPUT par_dtnascto,
           INPUT par_dtmvtolt,
          OUTPUT par_nrdeanos,
          OUTPUT aux_nrdmeses,
          OUTPUT aux_dsdidade ).

    DELETE PROCEDURE h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Verifica_Bloqueio:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsprofat AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsprofan AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.

    DEF VAR aux_flgcarta AS LOG                                     NO-UNDO.
    DEF VAR aux_flagdsnh AS LOG                                     NO-UNDO.

    IF (par_dsprofat = "SOCIO/PROPRIETARIO" AND 
        par_dsprofan  <> "SOCIO/PROPRIETARIO") THEN
        DO:   
           FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                    crapsnh.nrdconta = par_nrdconta AND
                                    crapsnh.tpdsenha = 1            AND
                                    crapsnh.cdsitsnh = 1
                                    NO-LOCK NO-ERROR.

           IF  AVAILABLE crapsnh     AND
              (crapsnh.vllimtrf > 0  OR
               crapsnh.vllimpgo > 0) THEN
               ASSIGN aux_flagdsnh = TRUE.

           FOR EACH crapcrm WHERE 
                    crapcrm.cdcooper = par_cdcooper AND
                    crapcrm.nrdconta = par_nrdconta
                    NO-LOCK:

               IF  crapcrm.cdsitcar = 2  THEN /* ATIVO */
                   DO:
                      ASSIGN aux_flgcarta = TRUE.
                      LEAVE.
                   END.
           END.           

           IF  aux_flagdsnh OR aux_flgcarta THEN
               ASSIGN 
                   par_msgalert = "Na inclusao de um novo SOCIO/PROPRIETARIO" +
                                  " a internet/cartao magnetico serao " + 
                                  "bloqueados.".
        END.
END.

PROCEDURE Grava_Bens:
    
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfcto AS DECIMAL     NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-bens.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_retorno = "NOK".

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava 
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                           crapavt.tpctrato = 6 /* jur */  AND
                           crapavt.nrdconta = par_nrdconta AND
                           crapavt.nrctremp = par_idseqttl AND
                           crapavt.nrcpfcgc = par_nrcpfcto
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        ASSIGN aux_contador = 0.

        FOR EACH tt-bens:
            ASSIGN
                aux_contador = aux_contador + 1
                crapavt.dsrelbem[aux_contador] = CAPS(tt-bens.dsrelbem)
                crapavt.persemon[aux_contador] = tt-bens.persemon
                crapavt.qtprebem[aux_contador] = tt-bens.vlrdobem
                crapavt.vlprebem[aux_contador] = tt-bens.vlrdobem
                crapavt.vlrdobem[aux_contador] = tt-bens.vlrdobem.

            IF  ERROR-STATUS:ERROR THEN
                DO:
                   aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                   UNDO Grava, LEAVE Grava.
                END.
        END.

        ASSIGN aux_retorno = "OK".

        LEAVE Grava.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            ASSIGN aux_retorno = "NOK".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,           
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.

    RETURN aux_retorno.

END PROCEDURE.

/* Buscar parametro de percentual de socio para o GE */
PROCEDURE busca_perc_socio:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsproftl AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_persocio AS DECIMAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER opt_persocio AS DECIMAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE aux_persocio AS DECIMAL     NO-UNDO.
        
    EMPTY TEMP-TABLE tt-erro.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "PROVISAOCL"   AND
                       craptab.tpregist = 999
                       NO-LOCK NO-ERROR.

    IF NOT AVAIL craptab THEN
    DO:
        ASSIGN aux_dscritic = "Tabela percentual de " +
                              "socio nao econtrada.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,           
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    ASSIGN opt_persocio = DEC(SUBSTR(craptab.dstextab,28,6)).

    IF  opt_persocio = 0 AND (par_persocio > 0 OR 
                              par_dsproftl = "SOCIO/PROPRIETARIO") THEN
    DO:
        ASSIGN aux_dscritic = "Percentual de " +
                              "socio invalido. Utilize TAB036.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,           
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".
END.

PROCEDURE valida_percentual_societario:

    DEF INPUT PARAM par_cdcooper AS INT NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    IF CAN-FIND(FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper
                                AND crapavt.nrdconta = par_nrdconta
                                AND crapavt.tpctrato = 6
                                AND crapavt.dsproftl = "SOCIO/PROPRIETARIO"
                                AND crapavt.persocio = 0) THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,           
                       INPUT 942,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.
/**/
PROCEDURE Busca_Dados_Poderes:

    DEF INPUT PARAM par_cdcooper    AS INT NO-UNDO.
    DEF INPUT PARAM par_tpctrato    AS INT NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS INT NO-UNDO.
    DEF INPUT PARAM par_nrdctpro    AS INT NO-UNDO.
    DEF INPUT PARAM par_cpfprocu    AS DEC NO-UNDO.
    DEF INPUT PARAM par_cdagenci    AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa    AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad    AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdatela    AS CHAR NO-UNDO.
    DEF INPUT PARAM par_idorigem    AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS DATE NO-UNDO.
    DEF INPUT PARAM par_idseqttl    AS INT  NO-UNDO.
    DEF OUTPUT PARAM aux_inpessoa   AS INT NO-UNDO.
    DEF OUTPUT PARAM aux_idastcjt   AS INT NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crappod.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_lstpoder AS CHAR NO-UNDO.
    
    EMPTY TEMP-TABLE tt-crappod.
    EMPTY TEMP-TABLE tt-erro.
     
    FIND FIRST crapass NO-LOCK WHERE crapass.cdcooper = par_cdcooper
                                 AND crapass.nrdconta = par_nrdconta.

    IF AVAIL crapass THEN
        ASSIGN aux_inpessoa = crapass.inpessoa
               aux_idastcjt = crapass.idastcjt.

    DYNAMIC-FUNCTION("ListaPoderes", OUTPUT aux_lstpoder).

    Busca:  DO TRANSACTION
            ON ERROR  UNDO Busca, LEAVE Busca
            ON QUIT   UNDO Busca, LEAVE Busca
            ON STOP   UNDO Busca, LEAVE Busca
            ON ENDKEY UNDO Busca, LEAVE Busca:
                
                aux_ctdpoder = 1.
                Contador: 
                        DO aux_contador = 1 TO 10:
                            
                            FIND crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                               crapavt.tpctrato = par_tpctrato AND
                                               crapavt.nrdconta = par_nrdconta AND
                                               crapavt.nrdctato = par_nrdctpro AND
                                               crapavt.nrcpfcgc = par_cpfprocu
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            
                            IF NOT AVAIL crapavt THEN
                               DO:  
                                  IF LOCKED crapavt THEN
                                     DO:
                                        IF aux_contador < 10 THEN
                                          NEXT.
                                        ELSE
                                          DO:
                                            aux_dscritic = "Procurador nao encontrado".
                                            LEAVE Contador.
                                          END.
                                     END.
                                  ELSE
                                    DO:
                                      aux_dscritic = "Procurador nao encontrado".
                                      LEAVE Contador.
                                    END.
                               END.
                             
                            IF  par_nrdctpro > 0 THEN
                            DO:
                                FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND 
                                                       crappod.nrdconta = par_nrdconta AND
                                                       crappod.nrctapro = 0            AND
                                                       crappod.nrcpfpro = par_cpfprocu EXCLUSIVE-LOCK:
                                    DELETE crappod.
                                END.
                            END.
                             
                            FIND crappod WHERE crappod.cdcooper = par_cdcooper AND 
                                               crappod.nrdconta = par_nrdconta AND
                                               crappod.nrctapro = par_nrdctpro AND
                                               crappod.nrcpfpro = par_cpfprocu AND
                                               crappod.cddpoder = 1 NO-LOCK NO-ERROR.            
                            
                            IF AVAIL crappod THEN
                               DO:
                                    
                                  FOR EACH crappod WHERE crappod.cdcooper = crapavt.cdcooper AND
                                                         crappod.nrdconta = crapavt.nrdconta AND
                                                         crappod.nrctapro = crapavt.nrdctato AND
                                                         crappod.nrcpfpro = crapavt.nrcpfcgc NO-LOCK:
                                      CREATE tt-crappod.
                                       
                                      ASSIGN tt-crappod.cdcooper = crappod.cdcooper
                                             tt-crappod.nrctapro = crappod.nrctapro
                                             tt-crappod.nrcpfpro = crappod.nrcpfpro
                                             tt-crappod.cddpoder = crappod.cddpoder
                                             tt-crappod.flgconju = crappod.flgconju
                                             tt-crappod.flgisola = crappod.flgisola
                                             tt-crappod.nrdconta = crappod.nrdconta
                                             tt-crappod.dsoutpod = crappod.dsoutpod.
                                  
                                  END.
                                  LEAVE Contador.
                               END.
                            ELSE
                              DO:
                                 aux_dstransa = "Insere poderes Representante/Procurador".
        
                                 RUN proc_gerar_log (INPUT par_cdcooper,
                                                     INPUT par_cdoperad,
                                                     INPUT "",
                                                     INPUT aux_dsorigem,
                                                     INPUT aux_dstransa,
                                                     INPUT TRUE,
                                                     INPUT par_idseqttl,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                     OUTPUT aux_nrdrowid).
                            
                                 DO WHILE aux_ctdpoder <= 10:
                                     
                                    CREATE crappod.
                                    ASSIGN crappod.cdcooper = par_cdcooper
                                           crappod.nrctapro = par_nrdctpro
                                           crappod.nrcpfpro = par_cpfprocu
                                           crappod.cddpoder = aux_ctdpoder
                                           crappod.flgconju = NO
                                           crappod.flgisola = NO
                                           crappod.nrdconta = par_nrdconta.
                                    VALIDATE crappod.
                        
                                    CREATE tt-crappod.
                                
                                    ASSIGN tt-crappod.cdcooper = par_cdcooper
                                           tt-crappod.nrctapro = crappod.nrctapro
                                           tt-crappod.nrcpfpro = crappod.nrcpfpro
                                           tt-crappod.cddpoder = crappod.cddpoder
                                           tt-crappod.flgconju = crappod.flgconju
                                           tt-crappod.flgisola = crappod.flgisola
                                           tt-crappod.nrdconta = crappod.nrdconta
                                           tt-crappod.dsoutpod = crappod.dsoutpod
                                           aux_ctdpoder = aux_ctdpoder + 1.
                                     
                                    IF crappod.flgconju = NO THEN
                                       aux_flgconju = "Nao".
                                    ELSE
                                       aux_flgconju = "Sim".
        
                                    IF crappod.flgisola = NO THEN
                                       aux_flgisola = "Nao".
                                    ELSE
                                       aux_flgisola = "Sim".
        
                               
                                    IF crappod.cddpoder <> 9 THEN
                                       DO:
                                          RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                  INPUT ENTRY(crappod.cddpoder,aux_lstpoder,",") + " Isolado" ,
                                                                  INPUT "",                     
                                                                  INPUT aux_flgisola).
                
                                          RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                  INPUT ENTRY(crappod.cddpoder,aux_lstpoder,",") + " Em Conjunto" ,
                                                                  INPUT "",
                                                                  INPUT aux_flgconju).
                                       END.
                                    ELSE
                                        DO:
                                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                    INPUT ENTRY(crappod.cddpoder,aux_lstpoder,","),
                                                                    INPUT "",
                                                                    INPUT "").   
                                        END.
                              END.
        
                            ASSIGN crapavt.flgimpri = TRUE.
                            /**/
                            LEAVE Contador.
                        END.
                        
                        IF aux_dscritic <> "" THEN DO:
                            UNDO Busca, LEAVE Busca.
                        END.
                    END.
        
        END.
        
        FIND CURRENT crapavt NO-LOCK NO-ERROR.
        FIND CURRENT tt-crappod NO-LOCK NO-ERROR.
        FIND CURRENT crappod NO-LOCK NO-ERROR.
        
        IF  aux_dscritic <> "" THEN
            DO:
                aux_dscritic = "Procurador nao encontrado".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,           
                               INPUT 0,
                               INPUT-OUTPUT aux_dscritic).
    
                RETURN "NOK".
            END.
            ELSE DO:
                RETURN "OK".
            END.

END PROCEDURE.

PROCEDURE Grava_Dados_Poderes:

    DEF INPUT PARAM par_cdcooper    AS INT NO-UNDO.
    DEF INPUT PARAM par_nrdctato    AS INT NO-UNDO.
    DEF INPUT PARAM par_nrdconta    AS INT NO-UNDO.
    DEF INPUT PARAM par_nrcpfcgc    AS DEC NO-UNDO.
    
    DEF  INPUT PARAM par_cdagenci   AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa   AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdoperad   AS CHAR NO-UNDO.
    DEF  INPUT PARAM par_nmdatela   AS CHAR NO-UNDO.
    DEF  INPUT PARAM par_idorigem   AS INTE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt   AS DATE NO-UNDO.
    DEF  INPUT PARAM par_idseqttl   AS INT  NO-UNDO.
    
    DEF INPUT PARAM TABLE FOR tt-crappod.
    
    DEF OUTPUT PARAM TABLE FOR tt-crappod.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
   
    DEF VAR aux_cdcritic AS INTE INIT 0  NO-UNDO.
    DEF VAR aux_dscritic AS CHAR INIT "" NO-UNDO.
    DEF VAR aux_antflgis AS CHAR         NO-UNDO.
    DEF VAR aux_antflgco AS CHAR         NO-UNDO.
    DEF VAR aux_lstpoder AS CHAR         NO-UNDO.
    DEF VAR aux_codpoder AS INT          NO-UNDO.

    DEF VAR h-b1wgen0015 AS HANDLE       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    DYNAMIC-FUNCTION("ListaPoderes", OUTPUT aux_lstpoder).
    
    Grava:  DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:
        
            FOR EACH tt-crappod:
                
                IF tt-crappod.cddpoder <> 9 THEN
                        DO:
                        
                        Contador: 
                        DO aux_contador = 1 TO 10: 
                                FIND crappod WHERE crappod.cdcooper = par_cdcooper AND
                                                   crappod.nrctapro = par_nrdctato AND
                                                   crappod.nrdconta = par_nrdconta AND
                                                   crappod.nrcpfpro = par_nrcpfcgc AND
                                                   crappod.cddpoder = tt-crappod.cddpoder
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                                IF NOT AVAIL crappod THEN
                                    DO:
                                        IF LOCKED crappod THEN
                                            DO:
                                                    IF aux_contador < 10 THEN
                                                            NEXT.
                                                    ELSE
                                                            DO: 
                                                                    aux_dscritic = "Procurador nao encontrado".
                                                                    LEAVE Contador.
                                                            END.
                                            END.
                                        ELSE
                                            DO:
                                                    aux_dscritic = "Procurador nao encontrado".
                                                    LEAVE Contador.
                                            END.
                                    END.
                               
                                IF  (crappod.flgconju <> tt-crappod.flgconju OR
                                    crappod.flgisola <> tt-crappod.flgisola) THEN
                                    DO: 
                                        /* PRJ ASS CONJUNTA JMD*/
                                         IF tt-crappod.cddpoder = 10 THEN
                                            DO: 
                                                
                                                FOR FIRST crapass FIELDS(inpessoa idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                                                                              AND crapass.nrdconta = par_nrdconta EXCLUSIVE-LOCK. END.
                                                                      
                                                IF AVAIL crapass THEN
                                                    DO:
                                                        IF crapass.inpessoa = 2                    AND 
                                                           crapass.idastcjt = 1                    AND 
                                                           crappod.flgconju <> tt-crappod.flgconju THEN
                                                           ASSIGN crapass.idimprtr = 1.
                                                    END.
                                                                                          
                                                IF crappod.flgconju = NO AND tt-crappod.flgconju = YES THEN
                                                    DO:
                                                        /*CHAMADA PLSQL*/
                                                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                                                        
                                                        /* Efetuar a chamada da rotina Oracle */ 
                                                        RUN STORED-PROCEDURE pc_inicia_senha_ass_conj
                                                              aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, 
                                                                                                  INPUT par_nrdconta,
                                                                                                  INPUT par_nrcpfcgc,
                                                                                                  INPUT par_cdoperad,
                                                                                                  OUTPUT 0,   /*Codigo da critica*/
                                                                                                  OUTPUT ""). /*Descricao da critica*/
                                                          
                                                          /* Fechar o procedimento para buscarmos o resultado */ 
                                                          CLOSE STORED-PROC pc_inicia_senha_ass_conj
                                                                 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                                          
                                                          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                                        
                                                          /* Busca possíveis erros */ 
                                                          ASSIGN aux_cdcritic = 0
                                                                 aux_dscritic = ""
                                                                 aux_cdcritic = pc_inicia_senha_ass_conj.pr_cdcritic 
                                                                                WHEN pc_inicia_senha_ass_conj.pr_cdcritic <> ?
                                                                 aux_dscritic = pc_inicia_senha_ass_conj.pr_dscritic 
                                                                                WHEN pc_inicia_senha_ass_conj.pr_dscritic <> ?.
                                                                
                                                          IF aux_cdcritic <> 0  OR
                                                             (aux_dscritic <> "" AND aux_dscritic <> ?) THEN
                                                             UNDO Grava, LEAVE Grava.
                                                    END.
                                                ELSE IF crappod.flgconju = YES AND tt-crappod.flgconju = NO THEN
                                                    DO: 
                                                        FOR FIRST crapsnh WHERE crapsnh.cdcooper = crappod.cdcooper AND
                                                                                crapsnh.nrdconta = crappod.nrdconta AND
                                                                                crapsnh.tpdsenha = 1 /* INTERNET */ AND
                                                                                crapsnh.nrcpfcgc = crappod.nrcpfpro NO-LOCK. END.
                                                        
                                                        IF AVAIL crapsnh THEN
                                                            DO:
                                                                IF  NOT VALID-HANDLE(h-b1wgen0015) THEN
                                                                  RUN sistema/generico/procedures/b1wgen0015.p 
                                                                      PERSISTENT SET h-b1wgen0015.
                                                
                                                                RUN cancelar-senha-internet IN h-b1wgen0015 (INPUT crapsnh.cdcooper,
                                                                                                             INPUT par_cdagenci,
                                                                                                             INPUT 0, /* Caixa */
                                                                                                             INPUT par_cdoperad,
                                                                                                             INPUT par_nmdatela,
                                                                                                             INPUT par_idorigem,
                                                                                                             INPUT crapsnh.nrdconta,
                                                                                                             INPUT crapsnh.idseqttl,
                                                                                                             INPUT par_dtmvtolt,
                                                                                                             INPUT 3, /* Confirmaçao 3 */
                                                                                                             INPUT FALSE, /* Log */
                                                                                                            OUTPUT TABLE tt-msg-confirma,
                                                                                                            OUTPUT TABLE tt-erro).
                
                                                                IF VALID-HANDLE(h-b1wgen0015) THEN
                                                                  DELETE OBJECT h-b1wgen0015.
                
                                                                IF RETURN-VALUE <> "OK"  THEN
                                                                  DO:
                                                                    UNDO Grava, LEAVE Grava.
                                                                  END.
                                                            END.
                                                    END.
                                            END.    
                                        /* FIM PRJ ASS CONJUNTA */
                                        IF ((tt-crappod.flgconju <> tt-crappod.flgisola) OR 
                                            (tt-crappod.flgconju = FALSE AND 
                                             tt-crappod.flgisola = FALSE)) THEN
                                            DO:
                                                aux_dstransa = "Alteracao poderes Representante/Procurador".
        
                                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                                    INPUT par_cdoperad,
                                                                    INPUT "",
                                                                    INPUT aux_dsorigem,
                                                                    INPUT aux_dstransa,
                                                                    INPUT TRUE,
                                                                    INPUT par_idseqttl,
                                                                    INPUT par_nmdatela,
                                                                    INPUT par_nrdconta,
                                                                    OUTPUT aux_nrdrowid).
                                                
                                                IF crappod.flgconju <> tt-crappod.flgconju THEN
                                                    DO:
                                                        IF tt-crappod.flgconju = NO THEN
                                                            aux_flgconju = "Nao".
                                                        ELSE 
                                                            aux_flgconju = "Sim".
                    
                                                        IF crappod.flgconju = NO THEN
                                                            aux_antflgco = "Nao".
                                                        ELSE 
                                                            aux_antflgco = "Sim".
                    
                                                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                                INPUT ENTRY(crappod.cddpoder,aux_lstpoder,",") + " Em Conjunto" ,
                                                                                INPUT aux_antflgco,
                                                                                INPUT aux_flgconju).
                                                    END.
                            
                                                IF crappod.flgisola <> tt-crappod.flgisola THEN
                                                    DO:
                                                        IF tt-crappod.flgisola = NO THEN
                                                            aux_flgisola = "Nao".
                                                        ELSE
                                                            aux_flgisola = "Sim".
                                                
                                                        IF crappod.flgisola = NO THEN
                                                            aux_antflgis = "Nao".
                                                        ELSE 
                                                            aux_antflgis = "Sim".
                    
                                                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                                INPUT ENTRY(crappod.cddpoder,aux_lstpoder,",") + " Isolado" ,
                                                                                INPUT aux_antflgis,
                                                                                INPUT aux_flgisola).
                                                    END.
                                                
                                                ASSIGN crappod.flgisola = tt-crappod.flgisola
                                                       crappod.flgconju = tt-crappod.flgconju.

                                                FIND crapavt WHERE crapavt.cdcooper = crappod.cdcooper AND
                                                                   crapavt.tpctrato = 6 AND
                                                                   crapavt.nrdconta = crappod.nrdconta AND
                                                                   crapavt.nrdctato = crappod.nrctapro AND
                                                                   crapavt.nrcpfcgc = par_nrcpfcgc
                                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                
                                                ASSIGN crapavt.flgimpri = TRUE. 

                                                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                        INPUT "CPF Representate/Procurador" ,
                                                                        INPUT "",
                                                                        INPUT STRING(crapavt.nrcpfcgc)).

                                                IF crapavt.nrdctato <> 0 THEN
                                                    DO:
                                                        FIND FIRST crapass WHERE crapass.cdcooper = crappod.cdcooper
                                                                             AND crapass.nrdconta = crapavt.nrdctato NO-LOCK NO-WAIT NO-ERROR.
                
                                                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                                INPUT "Nome Representate/Procurador" ,
                                                                                INPUT "",
                                                                                INPUT STRING(crapass.nmprimtl)).    
                                                    END.
                                                ELSE
                                                    DO:
                                                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                                INPUT "Nome Representate/Procurador" ,
                                                                                INPUT "",
                                                                                INPUT STRING(crapavt.nmdavali)).    
                                                    END.
                                            END.
                                    END.
                            END.    
                        
                                IF aux_dscritic <> "" THEN DO:
                                   UNDO Grava, LEAVE Grava.
                                END.  
                        END.
                ELSE DO:
                    Contador:
                        DO aux_contador = 1 TO 10:
                                
                            FIND crappod WHERE crappod.cdcooper = par_cdcooper AND
                                               crappod.nrctapro = par_nrdctato AND
                                               crappod.nrdconta = par_nrdconta AND
                                               crappod.nrcpfpro = par_nrcpfcgc AND
                                               crappod.cddpoder = tt-crappod.cddpoder
                                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                            IF NOT AVAIL crappod THEN DO:
                                IF LOCKED crappod THEN DO:
                                    IF aux_contador < 10 THEN
                                        NEXT.
                                    ELSE DO:
                                        aux_dscritic = "Procurador nao encontrado".
                                        LEAVE Contador.
                                    END.
                                END.
                                ELSE DO:
                                    aux_dscritic = "Procurador nao encontrado".
                                    LEAVE Contador.
                                END.
                            END.

                            
                                                    
                                IF crappod.dsoutpod <> tt-crappod.dsoutpod THEN
                                    DO:
                               
                                        aux_dstransa = "Alteracao outros poderes Representante/Procurador".
                                
        
                                        RUN proc_gerar_log (INPUT par_cdcooper,
                                                            INPUT par_cdoperad,
                                                            INPUT "",
                                                            INPUT aux_dsorigem,
                                                            INPUT aux_dstransa,
                                                            INPUT TRUE,
                                                            INPUT par_idseqttl,
                                                            INPUT par_nmdatela,
                                                            INPUT par_nrdconta,
                                                            OUTPUT aux_nrdrowid).

                                        IF tt-crappod.dsoutpod <> "####" THEN
                                            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                    INPUT ENTRY(crappod.cddpoder,aux_lstpoder,",") ,
                                                                    INPUT crappod.dsoutpod,
                                                                    INPUT tt-crappod.dsoutpod).
                                  
                                    END.                                             
                                
                                ASSIGN crappod.dsoutpod = tt-crappod.dsoutpod.

                                FIND crapavt WHERE crapavt.cdcooper = crappod.cdcooper AND
                                                   crapavt.tpctrato = 6 AND
                                                   crapavt.nrdconta = crappod.nrdconta AND
                                                   crapavt.nrdctato = crappod.nrctapro AND
                                                   crapavt.nrcpfcgc = par_nrcpfcgc
                                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                                ASSIGN crapavt.flgimpri = TRUE.     

                                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                        INPUT "CPF Representate/Procurador" ,
                                                        INPUT "",
                                                        INPUT STRING(crapavt.nrcpfcgc)).

                                IF crapavt.nrdctato <> 0 THEN
                                    DO:
                                        FIND FIRST crapass WHERE crapass.cdcooper = crappod.cdcooper
                                                             AND crapass.nrdconta = crapavt.nrdctato NO-LOCK NO-WAIT NO-ERROR.
    
                                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                INPUT "Nome Representate/Procurador" ,
                                                                INPUT "",
                                                                INPUT STRING(crapass.nmprimtl)).    
                                    END.
                                ELSE
                                    DO:
                                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                                INPUT "Nome Representate/Procurador" ,
                                                                INPUT "",
                                                                INPUT STRING(crapavt.nmdavali)).    
                                    END.
                                
                            LEAVE Contador.
                        END.
                END.
                
            END. /*foreach*/ 
            
            ContadorDoc6: DO aux_contador = 1 TO 10:
    
                FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                   crapdoc.nrdconta = par_nrdconta AND
                                   crapdoc.tpdocmto = 6            AND
                                   crapdoc.dtmvtolt = par_dtmvtolt AND
                                   crapdoc.idseqttl = par_idseqttl
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF NOT AVAILABLE crapdoc THEN
                    DO:
                        IF LOCKED(crapdoc) THEN
                            DO:
                                IF aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        LEAVE ContadorDoc6.
                                    END.
                                ELSE 
                                    DO: 
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorDoc6.
                                    END.
                            END.
                        ELSE
                            DO: 
                                CREATE crapdoc.
                                ASSIGN crapdoc.cdcooper = par_cdcooper
                                       crapdoc.nrdconta = par_nrdconta
                                       crapdoc.flgdigit = FALSE
                                       crapdoc.dtmvtolt = par_dtmvtolt
                                       crapdoc.tpdocmto = 6
                                       crapdoc.idseqttl = par_idseqttl.
                                VALIDATE crapdoc.        
                                LEAVE ContadorDoc6.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN crapdoc.flgdigit = FALSE
                               crapdoc.dtmvtolt = par_dtmvtolt.

                        LEAVE ContadorDoc6.
                    END.
            END.

        END. /*transaction*/

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci, /* cdagenci */
                       INPUT par_nrdcaixa, /* nrdcaixa */
                       INPUT 1, /* nrsequen */          
                       INPUT aux_cdcritic, /* cdcritic */
                       INPUT-OUTPUT aux_dscritic).
                       
        RETURN "NOK".
    END.
        
    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_responsavel_legal:

    DEF INPUT PARAM par_cdcooper  AS INT NO-UNDO.
    DEF INPUT PARAM par_nrdconta  AS INT NO-UNDO.
    DEF INPUT PARAM par_cdagenci  AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa  AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdoperad  AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmdatela  AS CHAR NO-UNDO.
    DEF INPUT PARAM par_idorigem  AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt  AS DATE NO-UNDO.
    DEF OUTPUT PARAM par_contador AS INT NO-UNDO.
    
    ASSIGN par_contador = 0.

    FOR EACH crapcrl WHERE cdcooper = par_cdcooper AND
                           nrctamen = par_nrdconta NO-LOCK:
        ASSIGN par_contador = par_contador + 1.

    END.

    RETURN "OK".

END PROCEDURE.
/*................................. FUNCTIONS ...............................*/
FUNCTION ValidaContato RETURNS LOGICAL:

END FUNCTION.

FUNCTION ValidaUf RETURNS LOGICAL
    ( INPUT par_cdufdavt AS CHARACTER ):

    RETURN (LOOKUP(par_cdufdavt,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                                "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                                "RS,RO,RR,SC,SP,SE,TO,EX") <> 0).

END FUNCTION.

FUNCTION ValidaCpfCnpj RETURNS LOGICAL
    ( INPUT  par_nrcpfcgc AS DECIMAL,
      OUTPUT par_cdcritic AS INTEGER ):

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_stsnrcal AS LOG                                     NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        RUN sistema/generico/procedures/b1wgen9999.p 
            PERSISTENT SET h-b1wgen9999.

    RUN valida-cpf-cnpj IN h-b1wgen9999
        ( INPUT par_nrcpfcgc,
         OUTPUT aux_stsnrcal,
         OUTPUT aux_inpessoa ).

     IF  NOT aux_stsnrcal   THEN
         ASSIGN par_cdcritic = 27.
     ELSE
     IF  aux_inpessoa <> 1   THEN
         ASSIGN par_cdcritic = 833.

    DELETE PROCEDURE h-b1wgen9999.

    RETURN (par_cdcritic = 0).

END FUNCTION.

FUNCTION CarregaCpfCnpj RETURNS DECIMAL
    ( INPUT par_cdcpfcgc AS CHARACTER ):

    RETURN DEC(REPLACE(REPLACE(REPLACE(par_cdcpfcgc,".",""),"-",""),"/","")).

END FUNCTION.

FUNCTION ListaPoderes RETURNS CHAR
    ( OUTPUT par_listapod AS CHAR ):
    
    par_listapod = "Emitir Cheques,Endossar Cheques," + 
                    "Autorizar Debitos,Requisitar Taloes," +
                    "Assinar Contratos de Emprst/Financ," +
                    "Substabelecer,Receber,Passar Recibo," +
                    "Outros Poderes,Assinar Operacao Autoatendimento".
    
    
END FUNCTION.

PROCEDURE valida_responsaveis:

  DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.
  DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
  DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
  DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.    
  DEF  INPUT PARAM par_idorigem AS INTE NO-UNDO.
  DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO.
  DEF  INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
  DEF  INPUT PARAM par_dscpfcgc AS CHAR NO-UNDO.
  DEF  INPUT PARAM par_flgconju AS CHAR NO-UNDO.
  DEF  INPUT PARAM par_qtminast AS INTE NO-UNDO.
  DEF OUTPUT PARAM par_flgpende AS INTE NO-UNDO.
  DEF OUTPUT PARAM TABLE FOR tt-erro.
 
  EMPTY TEMP-TABLE tt-erro.
    
  DEF VAR aux_nrcpfcgc AS INT INIT 0 NO-UNDO.
  DEF VAR aux_contador AS INT INIT 0 NO-UNDO.
  DEF VAR aux_contarep AS INT INIT 0 NO-UNDO.
    
  DEF VAR aux_dscpfcgc AS CHAR INIT "" NO-UNDO.
  DEF VAR aux_dscpftel AS CHAR INIT "" NO-UNDO.

  DEF VAR aux_flgretir AS LOGI INIT FALSE NO-UNDO.
  DEF VAR aux_flgreadi as LOGI INIT FALSE NO-UNDO.
  
  ASSIGN par_flgpende = 0
		 aux_dscpftel = REPLACE(par_dscpfcgc,"#",",").
    
  /* Busca CPF dos Representantes atuais */
  FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper
                     AND crappod.nrdconta = par_nrdconta
                     AND crappod.cddpoder = 10
                     AND crappod.flgconju = TRUE NO-LOCK:

    IF TRIM(aux_dscpfcgc) <> ? AND TRIM(aux_dscpfcgc) <> "" THEN
		  ASSIGN aux_dscpfcgc = aux_dscpfcgc + ",".

    ASSIGN aux_dscpfcgc = aux_dscpfcgc + STRING(crappod.nrcpfpro).

  END.
  
  IF par_nmdatela = "ATENDA" THEN
    DO:
      /* Verifica se esta excluindo representantes */
      RepresentantesExcluir: DO aux_contador = 1 TO NUM-ENTRIES(aux_dscpfcgc,','):
      IF NOT CAN-DO(aux_dscpftel,STRING(ENTRY(aux_contador,aux_dscpfcgc,','))) THEN
        ASSIGN aux_flgretir = TRUE.		
      END.
      
      RepresentantesAdicionar: DO aux_contador = 1 TO NUM-ENTRIES(aux_dscpftel,','):
      IF NOT CAN-DO(aux_dscpfcgc,STRING(ENTRY(aux_contador,aux_dscpftel,','))) THEN
        ASSIGN aux_flgreadi = TRUE.		
      END.
    END.
  ELSE IF par_nmdatela = "CONTAS" THEN
    DO:
      /* Verifica se esta incluindo/excluindo representantes */
      FOR FIRST crappod FIELDS(flgconju) WHERE crappod.cdcooper = par_cdcooper
                                           AND crappod.nrdconta = par_nrdconta
                                           AND crappod.nrcpfpro = DEC(par_dscpfcgc)
                                           AND crappod.cddpoder = 10  NO-LOCK. END.	

      IF AVAILABLE crappod THEN
        DO:
          IF (LOGICAL(par_flgconju) <> crappod.flgconju) AND LOGICAL(par_flgconju) THEN
            DO:
              ASSIGN aux_flgreadi = TRUE.
            END.
          ELSE IF LOGICAL(par_flgconju) <> crappod.flgconju THEN
            DO:
              ASSIGN aux_flgretir = TRUE.
            END.
        END.
    END.
     
	Contador: DO aux_contador = 1 TO NUM-ENTRIES(par_dscpfcgc,'#'):

	FOR FIRST tbgen_trans_pend FIELDS(cdcooper) WHERE tbgen_trans_pend.cdcooper             = par_cdcooper 
                                                AND tbgen_trans_pend.nrdconta			         = par_nrdconta
                                                AND (tbgen_trans_pend.idsituacao_transacao = 1 OR 
                                                   tbgen_trans_pend.idsituacao_transacao   = 5) NO-LOCK. END.	
   
	IF AVAILABLE tbgen_trans_pend THEN
		DO:		
			ASSIGN par_flgpende = 1.
		END.

	FOR FIRST crapavt FIELDS(cdcooper nrdconta) WHERE crapavt.cdcooper = par_cdcooper
													AND crapavt.nrdconta = par_nrdconta
													AND crapavt.nrcpfcgc = DEC(ENTRY(aux_contador,par_dscpfcgc,'#')) NO-LOCK. END.

	IF AVAILABLE crapavt THEN
		DO:
			ASSIGN aux_contarep = aux_contarep + 1.
			NEXT.
		END.
	ELSE
		DO:
			RUN gera_erro (INPUT par_cdcooper,
							INPUT par_cdagenci,
							INPUT par_nrdcaixa,
							INPUT 1,           
							INPUT "Responsavel Inexistente.",
							INPUT-OUTPUT aux_dscritic).

			RETURN "NOK".
		END.
	END. /* CONTADOR */
		  
	IF par_nmdatela = "CONTAS" THEN
		DO:
			FOR FIRST crapass FIELDS(qtminast idastcjt) WHERE crapass.cdcooper = par_cdcooper
                                           AND crapass.nrdconta = par_nrdconta NO-LOCK. END.
												 
			IF AVAILABLE crapass AND crapass.qtminast >= 2 AND crapass.idastcjt = 1 THEN
				DO:
					ASSIGN aux_contarep = 0.

					FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper
									   AND crappod.nrdconta = par_nrdconta
									   AND crappod.cddpoder = 10 NO-LOCK:
									 /*AND crappod.flgconju = TRUE NO-LOCK:*/
				
						ASSIGN aux_contarep = aux_contarep + 1.

					END.
	
					FOR FIRST crappod FIELDS(flgconju) WHERE crappod.cdcooper = par_cdcooper
														 AND crappod.nrdconta = par_nrdconta
														 AND crappod.nrcpfpro = DEC(ENTRY(1,par_dscpfcgc,'#'))
														 AND crappod.cddpoder = 10  NO-LOCK. END.	

					IF AVAILABLE crappod THEN
						DO:
							IF LOGICAL(par_flgconju) <> crappod.flgconju THEN
								DO:
									IF LOGICAL(par_flgconju) then
										ASSIGN aux_contarep = aux_contarep + 1.
									ELSE
										ASSIGN aux_contarep = aux_contarep - 1.	
								END.
						END.
					ELSE
						DO:
					
							EMPTY TEMP-TABLE tt-erro.
							CREATE tt-erro.
							ASSIGN tt-erro.dscritic = "Registro de poder nao encontrado.".
					
							RETURN "NOK".
						END.
				
			
					IF crapass.qtminast > aux_contarep THEN
						DO:
							EMPTY TEMP-TABLE tt-erro.
							CREATE tt-erro.
							ASSIGN tt-erro.dscritic = "A quantidade minima de assinaturas nao pode ser superior a quantidade de responsaveis selecionados para assinatura conjunta.".

							RETURN "NOK".
						END.
				END. /*IF AVAIL CRAPASS */
			ELSE IF NOT AVAIL crapass THEN
				DO:
					EMPTY TEMP-TABLE tt-erro.
					CREATE tt-erro.
					ASSIGN tt-erro.dscritic = "Cooperado Inexistente.".
								   
					RETURN "NOK".
				END.
		END.
	ELSE /* ATENDA */
		DO:	
			IF par_qtminast < 2 THEN
				DO:
					EMPTY TEMP-TABLE tt-erro.
					CREATE tt-erro.
					ASSIGN tt-erro.dscritic = "A quantidade minima de assinaturas deve ser maior ou igual a 2.".

					RETURN "NOK".
				END.
			ELSE IF par_qtminast > aux_contarep THEN
				DO:
					EMPTY TEMP-TABLE tt-erro.
					CREATE tt-erro.
					ASSIGN tt-erro.dscritic = "A quantidade minima de assinaturas nao pode ser superior a quantidade de responsaveis selecionados para assinatura conjunta.".

					RETURN "NOK".
				END.
		END.
	
	IF aux_flgretir AND par_flgpende = 1 THEN
	DO:
		ASSIGN par_flgpende = 0.
		/*Há transaçoes pendentes de aprovaçao. Deseja alterar os responsáveis pela assinatura?*/
	END.
  ELSE IF aux_flgretir AND par_flgpende = 0 THEN
    DO:
		ASSIGN par_flgpende = 1.
		/* Deseja alterar os responsáveis pela assinatura? */
	END.
  ELSE IF NOT aux_flgretir AND NOT aux_flgreadi THEN
    DO:
		ASSIGN par_flgpende = 1.
		/* Deseja alterar os responsáveis pela assinatura? */
	END.
  ELSE IF aux_flgreadi THEN
    DO:
		ASSIGN par_flgpende = 2.
		/* Revise as senhas de acesso a Conta Online para os novos responsáveis. Deseja alterar as permissoes de assinatura? */
	END.
    
  RETURN "OK".

END PROCEDURE.

PROCEDURE grava_resp_ass_conjunta:
    DEF  INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS CHAR NO-UNDO.
    DEF  INPUT PARAM par_responsa AS CHAR NO-UNDO.
	DEF  INPUT PARAM par_qtminast AS INTE NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
 
    DEF VAR aux_poderres AS CHAR NO-UNDO.
    DEF VAR aux_contares AS INT  NO-UNDO.
    DEF VAR aux_qtminast AS INT  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    Contador: DO aux_contares = 1 TO NUM-ENTRIES(par_responsa,'#'):
            
        ASSIGN aux_poderres = ENTRY(aux_contares,par_responsa,"#").

        EMPTY TEMP-TABLE tt-crappod.
        
        CREATE tt-crappod.
        ASSIGN tt-crappod.cdcooper = INT(par_cdcooper) 
               tt-crappod.nrctapro = INT(ENTRY(1,aux_poderres,","))
               tt-crappod.nrcpfpro = DEC(ENTRY(2,aux_poderres,","))
               tt-crappod.cddpoder = 10
               tt-crappod.flgconju = LOGICAL(ENTRY(3,aux_poderres,","))
               tt-crappod.flgisola = LOGICAL(ENTRY(4,aux_poderres,","))
               tt-crappod.nrdconta = INT(par_nrdconta).
        
        RUN Grava_Dados_Poderes(INPUT par_cdcooper,
                                INPUT INT(ENTRY(1,aux_poderres,",")),
                                INPUT INT(par_nrdconta),
                                INPUT DEC(ENTRY(2,aux_poderres,",")),
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_nmdatela,
                                INPUT par_idorigem,
                                INPUT par_dtmvtolt,
                                INPUT par_idseqttl,
                                INPUT TABLE tt-crappod,
                                OUTPUT TABLE tt-crappod,
                                OUTPUT TABLE tt-erro) NO-ERROR.
            
        IF  RETURN-VALUE = "NOK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                IF  NOT AVAILABLE tt-erro  THEN
                    DO:
                        CREATE tt-erro.
                        ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a operacao.".
                    END.

                RETURN "NOK".
            END.
         
    END.
   
	FOR FIRST crapass FIELDS(qtminast) WHERE crapass.cdcooper = par_cdcooper
								         AND crapass.nrdconta = par_nrdconta EXCLUSIVE-LOCK. END.

    IF AVAIL crapass THEN
		DO:
			IF crapass.qtminast <> par_qtminast THEN
				DO:
					ASSIGN aux_qtminast = crapass.qtminast
						   crapass.qtminast = par_qtminast
						   aux_dstransa = "Alteracao Quantidade Minima de Assinaturas Conjunta"
						   aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).
					
					VALIDATE crapass.

					RUN proc_gerar_log (INPUT par_cdcooper,
										INPUT par_cdoperad,
										INPUT "",
										INPUT aux_dsorigem,
										INPUT aux_dstransa,
										INPUT TRUE,
										INPUT par_idseqttl,
										INPUT par_nmdatela,
										INPUT par_nrdconta,
									   OUTPUT aux_nrdrowid).
                                        
					RUN proc_gerar_log_item(INPUT aux_nrdrowid,
											INPUT "Quantidade Minima de Assinaturas Conjunta",
											INPUT aux_qtminast,
											INPUT par_qtminast).
				END.
		END.
	ELSE
		DO:
			FIND FIRST tt-erro NO-LOCK NO-ERROR NO-WAIT.
        
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
					CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a operacao.".
                END.
				
            RETURN "NOK".
		END.

    RETURN "OK".

END PROCEDURE.
