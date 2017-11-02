/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  |   ValidaNome                    | GENE0005.fn_valida_nome           |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   
*******************************************************************************/

/*.............................................................................

    Programa: b1wgen0055.p
    Autor   : Jose Luis (DB1)
    Data    : Janeiro/2010                   Ultima atualizacao: 13/10/2017

    Objetivo  : Tranformacao BO tela CONTAS - Pessoa Fisica

    Alteracoes: 12/08/2010 - Ajuste na validacao de UF (David)
    
                13/09/2010 - Replicar dados p/ 1o. Titular (Jose Luis, DB1)
                
                22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                          
                20/12/2010 -  Replica dados cadastrais onde o titular é
                              cônjuge (Gabriel - DB1).
                              
                21/03/2011 - Inserida a procedure ValidaNome (Henrique).
                
                25/07/2011 - Verificado estado civil do segundo titular para
                             criar conjuge sem informacoes(crapcje); isso
                             quando o mesmo nao for 1 titular de nenhuma conta
                             e quando seu vinculo de relacionamento com o 
                             1 titular da conta na qual ele esta sendo inserido
                             nao for de conjuge ou companheiro(a). (Fabricio)
                             
                11/11/2011 - Ajustes rotina identificacao PF (David).     
                
                10/04/2012 - Ajustes referente ao projeto GP - Socios Menores
                             (Adriano).
                             
                18/03/2013 - Incluido a chamada da procedure alerta_fraude
                             dentro da procedure Grava_Dados (Adriano).
                             
                26/03/2013 - Comentado o "IF par_nrctattl <> 0 AND 
                             par_idseqttl <> 1 THEN LEAVE Valida"
                             pois não estava deixando validar os
                             outros campos (Daniele).
                             
                26/07/2013 - Retirado campos brapass.dsnatura, crapass.dsnatstl,
                             crapass.dsnatttl (Reinert).
                          
                09/08/2013 - Incluido verificacao de alteracao na tela Identificacao
                             (Jean Michel).
                             
                12/08/2013 - Incluido parametro cdufnatu na grava_dados e 
                             valida_dados. (Reinert)
                    
                16/08/2013 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "grava_dados" (James). 
                             
                13/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)   
                
                17/01/2014 - Incluido verificação de opção para criação de
                             registros na crapdoc (Jean Michel)                 
                             
                21/02/2014 - Alterado o local do estado civil, da crapass para
                             a crapttl (Carlos)
                             
                29/04/2014 - Incluir filtro de pessoa fisica na validacao 
                             de emancipacao (Jaison - SF: 152091)
                             
                16/06/2014 - Incluir validacao de estado civil para crapdoc
                             Softdesk 161305 (Lucas R.)
                             
                12/11/2014 - Atualizar a conta do conjuge na alteracao dos
                             titulares (chamado 179787) (Andrino-RKAM)
                             
                23/01/2015 - foi alterado a procedure Grava_alteracao pois 
                             estava sendo utilizado filtro de titular fixo.
                             foi passado o titular vindo da tela. (Kelvin - SD 246451)
                
                02/02/2015 - Ajuste na Grava_alteracao, para usar o numero da conta
                             do buffer brapttl no insert da crapcje, pois o registro antes
                             utilizado as vezes não não era encontrado, gerando erro para o
                             cooperado. SD 249427(Odirlei-AMcom)             
                             
                05/03/2015 - Incluir condicao para o campo que o campo 
                            crapttl.flgimpri so mude para true se for inclusao
                            (Lucas R. #158978)
                            
                17/03/2015 - Voltar a versão alterada para o chamado 246451,
                             alteração esta causando problema alterando as informações
                             do titular errado (Odirlei-Amcom)
                                         
                09/04/2015 - Retirada a validacao para o grau escolar na consulta
                             dos dados (Lucas R. #273701)
                             
                27/05/2015 - Incluir validacao da crapdoc para que o tipo 4(estado civil)
                             apenas grave registro se cooperado nao for solteiro.
                             (Lucas Ranghetti #287169)
                             
                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM) 
                
                09/11/2015 - Ajustado problemas com conjuge quando excluia
                             o conjuge na conta principal nao excluia das
                             demais contas onde o dono da conta era
                             segundo titular SD#343700 (Tiago)
                
                17/12/2015 - Remocao da pendencia do documento de ficha cadastral
                             no DigiDoc conforme solicitado na melhoria 114.  
                             SD 372880 (Kelvin)  
                             
                17/02/2016 - Conversão da function ValidaNome para PL/SQL
                             (Jean Michel)      
                             
                09/11/2015 - Alterando este fonte a partir de hj, qlqr coisa
                             entrar em contato SD#343700 (Tiago)
                             
                16/03/2016 - Incluir validacao para nao criar crapdoc para pessoa juridica
                             tipos(1,2,4,5) (Lucas Ranghetti #391492)

                09/09/2016 - Adicionar validacao para o relacionamento com o primeiro titular
                             cdgraupr = 0 e for segundo titular (Lucas Ranghetti #500760)

                16/11/2016 - Criar ttl como nao politicamente exposto ao inves
                             de pendente (Tiago/Thiago SD532690).

				19/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

                             
                19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)               
                             
                17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)                
                             
                31/07/2017 - Alterado leitura da CRAPNAT pela CRAPMUN.
                             PRJ339 - CRM (Odirlei-AMcom)               
                             
				28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
							 CH, RE, PP E CT. (PRJ339 - Reinert)
		        
                             
                09/10/2017 - Incluido rotina para ao cadastrar cooperado carregar dados
                             da pessoa do cadastro unificado, para completar o cadastro com dados
                             que nao estao na tela. PRJ339 - CRM (Odirlei-AMcom)
.............................................................................*/



/*................................ DEFINICOES ...............................*/
{ sistema/generico/includes/b1wgen0055tt.i &TT-LOG=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/b1wgen0072tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.
DEF VAR h-b1wgen0052b AS HANDLE                                        NO-UNDO.

FUNCTION BuscaUltimoTtl  RETURNS INTEGER
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER ) FORWARD.

FUNCTION ValidaCpf RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ) FORWARD.

FUNCTION CriticaNome RETURNS LOGICAL 
    (  INPUT par_nomecrit AS CHARACTER,
      OUTPUT aux_cddcriti AS INTEGER ) FORWARD.

FUNCTION ValidaNome RETURN LOGICAL
    (  INPUT par_nomedttl AS CHAR,
       INPUT par_inpessoa AS INTE,
      OUTPUT par_dscritic AS CHAR) FORWARD.

/*................................. PROCEDURES ..............................*/
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
    DEF  INPUT PARAM par_cdgraupr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados-fis.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_nrdeanos AS INT                                     NO-UNDO.
    DEF VAR aux_nrdmeses AS INT                                     NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
	DEF VAR aux_nrcpfstl LIKE crapttl.nrcpfcgc                      NO-UNDO.
	DEF VAR aux_nrcpfttl LIKE crapttl.nrcpfcgc                      NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados da Identificacao"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_retorno = "NOK"
           aux_nrdeanos = 0
           aux_nrdmeses = 0
           aux_dsdidade = "".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-dados-fis.
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crapass FIELDS(qtfoltal nrdctitg nrcpfcgc dtnasctl inpessoa)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta NO-LOCK:

        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.

	    IF crapass.inpessoa = 1 THEN
		   DO:
		      FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
								     crapttl.nrdconta = crapass.nrdconta AND
									 crapttl.idseqttl > 1
									 NO-LOCK:


			     IF crapttl.idseqttl = 2 THEN
				    ASSIGN aux_nrcpfstl = crapttl.nrcpfcgc.
				 ELSE IF crapttl.idseqttl = 3 THEN
				    ASSIGN aux_nrcpfttl = crapttl.nrcpfcgc.

			  END.

		   END.
		   
        CASE par_cddopcao:
            WHEN "I" THEN DO:
                
                IF  BuscaUltimoTtl(par_cdcooper,par_nrdconta) > 4 THEN
                    DO:
                       ASSIGN aux_dscritic = "Limite maximo de 4 titulares " + 
                                             "por conta atingido.".
                       LEAVE Busca.
                    END.
                
                IF  NOT CAN-DO("1,2,3,4,6",STRING(par_cdgraupr,"9")) AND 
                    par_idseqttl <> 1 THEN
                    DO:
                       ASSIGN aux_cdcritic = 23.
                       LEAVE Busca.
                    END.

                IF  NOT ValidaCpf(par_nrcpfcgc) THEN
                    DO:
                       ASSIGN aux_cdcritic = 27.
                       LEAVE Busca.
                    END.

                RUN Busca_Inclusao
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_cdgraupr,
                      INPUT DEC(par_nrcpfcgc),
                      INPUT crapass.nrcpfcgc,
                      INPUT aux_nrcpfstl,
                      INPUT aux_nrcpfttl,
                      INPUT crapass.qtfoltal,
                      INPUT crapass.nrdctitg,
                     OUTPUT par_msgconta,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).

                IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                    UNDO Busca, LEAVE Busca.
            END.
            WHEN "A" THEN DO:
                IF  NOT CAN-DO("1,2,3,4,6",STRING(par_cdgraupr,"9")) AND 
                    par_idseqttl <> 1 THEN
                    DO:
                       ASSIGN aux_cdcritic = 23.
                       LEAVE Busca.
                    END.

                IF  NOT ValidaCpf(par_nrcpfcgc) THEN
                    DO:
                       ASSIGN aux_cdcritic = 27.
                       LEAVE Busca.
                    END.

                FOR FIRST crapttl FIELDS(nrcpfcgc)
                                  WHERE crapttl.cdcooper = par_cdcooper AND 
                                        crapttl.nrdconta = par_nrdconta AND
                                        crapttl.idseqttl = par_idseqttl 
                                        NO-LOCK:
                END.

                IF  NOT AVAILABLE crapttl THEN
                    DO:
                       ASSIGN aux_dscritic = "Titular nao encontrado.".
                       LEAVE Busca.
                    END.

                RUN Busca_Alteracao
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_cdgraupr,
                      INPUT DEC(par_nrcpfcgc),
                      INPUT crapass.nrcpfcgc,
                      INPUT aux_nrcpfstl,
                      INPUT aux_nrcpfttl,
                      INPUT crapttl.nrcpfcgc,
                      INPUT crapass.qtfoltal,
                      INPUT crapass.nrdctitg,
                     OUTPUT par_msgconta,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).

                IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                    UNDO Busca, LEAVE Busca.
            END.
            WHEN "C" THEN DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND 
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.idseqttl = par_idseqttl
                                   NO-LOCK NO-ERROR.

                IF  AVAILABLE crapttl THEN
                    DO:
                       ASSIGN 
                           par_nrcpfcgc = STRING(crapttl.nrcpfcgc)
                           par_cdgraupr = crapttl.cdgraupr.

                       RUN Atualiza_Campos 
                           ( INPUT par_cdgraupr,
                             INPUT crapass.qtfoltal,
                             INPUT crapass.nrdctitg,
                             INPUT 0,
                             BUFFER crapttl,
                            OUTPUT par_msgconta,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic ).

                       IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                           UNDO Busca, LEAVE Busca.
                    END.
            END.
            OTHERWISE DO:
                ASSIGN aux_dscritic = "A opcao deve ser [C]=Consulta, [A]=" +
                                      "Alteracao ou [I]=Inclusao.".
                UNDO Busca, LEAVE Busca.
            END.
        END CASE.

        FIND FIRST tt-dados-fis NO-ERROR.

        IF  AVAILABLE tt-dados-fis THEN
            DO:
               IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                  RUN sistema/generico/procedures/b1wgen9999.p
                      PERSISTENT SET h-b1wgen9999.
               
               /* validar pela procedure generica do b1wgen9999.p */
               RUN idade IN h-b1wgen9999 ( INPUT tt-dados-fis.dtnasttl,
                                           INPUT TODAY,
                                           OUTPUT aux_nrdeanos,
                                           OUTPUT aux_nrdmeses,
                                           OUTPUT aux_dsdidade ).
               
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE PROCEDURE h-b1wgen9999.

               ASSIGN tt-dados-fis.nrcpfcgc = DEC(par_nrcpfcgc)
                      tt-dados-fis.cdgraupr = par_cdgraupr
                      tt-dados-fis.nrdeanos = aux_nrdeanos.
                      

               IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                   RUN sistema/generico/procedures/b1wgen0060.p 
                       PERSISTENT SET h-b1wgen0060.

               DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                                INPUT tt-dados-fis.cdsitcpf, 
                                OUTPUT tt-dados-fis.dssitcpf,
                                OUTPUT aux_dscritic).
    
               DYNAMIC-FUNCTION("BuscaParentesco"  IN h-b1wgen0060, 
                                INPUT tt-dados-fis.cdgraupr, 
                                OUTPUT tt-dados-fis.dsgraupr,
                                OUTPUT aux_dscritic).
    
               DYNAMIC-FUNCTION("BuscaTipoNacion"  IN h-b1wgen0060, 
                                INPUT tt-dados-fis.tpnacion, 
                                INPUT "restpnac",
                                OUTPUT tt-dados-fis.destpnac,
                                OUTPUT aux_dscritic).
    
               IF  tt-dados-fis.destpnac = "NAO CADASTRADO" THEN
                   ASSIGN tt-dados-fis.destpnac = "DESCONHECIDA".
    
               DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060, 
                                INPUT tt-dados-fis.inhabmen, 
                                OUTPUT tt-dados-fis.dshabmen,
                                OUTPUT aux_dscritic).
    
               DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060, 
                                INPUT tt-dados-fis.cdestcvl, "dsestcvl",
                                OUTPUT tt-dados-fis.dsestcvl,
                                OUTPUT aux_dscritic).
    
               DYNAMIC-FUNCTION("BuscaGrauEscolar" IN h-b1wgen0060, 
                                INPUT tt-dados-fis.grescola, 
                                OUTPUT tt-dados-fis.dsescola,
                                OUTPUT aux_dscritic).
    
               DYNAMIC-FUNCTION("BuscaFormacao"    IN h-b1wgen0060, 
                                INPUT tt-dados-fis.cdfrmttl, 
                                OUTPUT tt-dados-fis.rsfrmttl,
                                OUTPUT aux_dscritic).

               ASSIGN aux_dscritic = "".
            END.

        LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_retorno = "OK".
    
    IF  par_flgerlog THEN
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

PROCEDURE Busca_Inclusao:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdgraupr AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfass AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfstl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfttl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                     NO-UNDO.

    DEF OUTPUT PARAM par_msgconta AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_dtaltera AS DATE                              NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                              NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER craxttl FOR crapttl.

    ASSIGN 
        par_dscritic = "Erro na busca dos dados".
        aux_returnvl = "NOK".

        
    BuscaI: DO ON ERROR UNDO BuscaI, LEAVE BuscaI:

        /** Verifica se ja existe conjuge para o primeiro titular **/
        IF  par_cdgraupr = 1 OR par_cdgraupr = 4  THEN
            DO:
               IF  CAN-FIND(FIRST crabttl WHERE 
                            crabttl.cdcooper = par_cdcooper  AND
                            crabttl.nrdconta = par_nrdconta  AND
                            (crabttl.cdgraupr = 1 OR 
                             crabttl.cdgraupr = 4)            AND
                            crabttl.idseqttl <> par_idseqttl) THEN
                   DO:   
                      ASSIGN par_dscritic = "Ja existe um CONJUGE para esta " +
                                            "conta!".
                      LEAVE BuscaI.
                   END.
            END.

        IF  par_nrcpfcgc = par_nrcpfass  OR
            par_nrcpfcgc = par_nrcpfstl  OR   /* Segundo titular */
            par_nrcpfcgc = par_nrcpfttl  THEN /* Terceiro titular */
            DO:
               ASSIGN par_dscritic = "CPF deve ser diferente dos demais " + 
                                     "titulares.".
               LEAVE BuscaI.
            END.

        /** Busca conta ativa mais atual do cooperado **/ 
        ASSIGN aux_dtaltera = 01/01/0001
               aux_nrdconta = 0.
        
        FOR EACH crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                               crabttl.nrcpfcgc = par_nrcpfcgc AND
                               crabttl.idseqttl = 1  NO-LOCK, 
            FIRST crabass  WHERE crabass.cdcooper = crabttl.cdcooper AND
                                 crabass.nrdconta = crabttl.nrdconta AND
                                 crabass.dtdemiss = ?  NO-LOCK:

            /** Ignora conta aplicacao **/
            IF  CAN-DO("6,7,17,18",STRING(crabass.cdtipcta))  THEN 
                NEXT.
            
            FIND LAST crapalt WHERE 
                      crapalt.cdcooper = crabass.cdcooper AND
                      crapalt.nrdconta = crabass.nrdconta 
                      NO-LOCK NO-ERROR.
            
            IF  AVAIL crapalt THEN
                DO:   
                    IF  crapalt.dtaltera > aux_dtaltera THEN
                        DO:  
                            ASSIGN aux_nrdconta = crapalt.nrdconta
                                   aux_dtaltera = crapalt.dtaltera.
                        END.
                END.
            ELSE
                IF  aux_nrdconta = 0 THEN
                    DO: 
                        ASSIGN aux_nrdconta = crabass.nrdconta.
                    END.
             
        END.   

        FIND crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                           crabttl.nrcpfcgc = par_nrcpfcgc AND
                           crabttl.idseqttl = 1            AND
                           crabttl.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crabttl THEN
            DO:
               IF  par_cdgraupr = 1 OR par_cdgraupr = 4  THEN
                   DO:
                      FIND craxttl WHERE 
                                   craxttl.cdcooper = par_cdcooper AND
                                   craxttl.nrdconta = par_nrdconta AND
                                   craxttl.idseqttl = 1 NO-LOCK NO-ERROR.
    
                      IF  AVAILABLE craxttl THEN
                          DO:
                             IF  craxttl.cdestcvl = 2  OR /* COM. UNIVERSAL */
                                 craxttl.cdestcvl = 3  OR /* COM PARCIAL    */
                                 craxttl.cdestcvl = 4  OR /* SEP DE BENS    */
                                 craxttl.cdestcvl = 8  OR /* CAS REG TOTAL  */
                                 craxttl.cdestcvl = 9  OR /* REG. MISTO/ESPE*/
                                 craxttl.cdestcvl = 11 OR /* PAR.FIN AQUESTO*/
                                 craxttl.cdestcvl = 12 THEN /* UNIAO ESTAVEL*/
                                 DO:
                                    /** Verifica estado civil do cooperado **/
                                    IF  crabttl.cdestcvl = 2  OR 
                                        crabttl.cdestcvl = 3  OR 
                                        crabttl.cdestcvl = 4  OR 
                                        crabttl.cdestcvl = 8  OR 
                                        crabttl.cdestcvl = 9  OR 
                                        crabttl.cdestcvl = 11 OR 
                                        crabttl.cdestcvl = 12 THEN.
                                    ELSE
                                        DO:
                                           par_dscritic = "Estado civil da " +
                                                          "conta deste CPF " +
                                                          "nao permite ser " +
                                                          "conjuge.".
                                           LEAVE BuscaI.
                                        END.
                                 END.
                             ELSE 
                                DO:
                                   par_dscritic = "Estado civil do primeiro " +
                                                  "titular nao permite " + 
                                                  "conjuge.".
                                   LEAVE BuscaI.
                                END.
                          END.
                   END.
                   
               RUN Atualiza_Campos 
                   ( INPUT par_cdgraupr,
                     INPUT par_qtfoltal,
                     INPUT par_nrdctitg,
                     INPUT crabttl.nrdconta,
                     BUFFER crabttl,
                    OUTPUT par_msgconta,
                    OUTPUT par_cdcritic,
                    OUTPUT par_dscritic ).

               IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                   LEAVE BuscaI.
            END.
        ELSE
            DO:
               IF  par_cdgraupr = 1 OR par_cdgraupr = 4 THEN 
                   DO:   
                      FIND crapcje WHERE crapcje.cdcooper = par_cdcooper AND
                                         crapcje.nrdconta = par_nrdconta AND
                                         crapcje.idseqttl = 1            AND
                                         crapcje.nrcpfcjg = par_nrcpfcgc
                                         NO-LOCK NO-ERROR.
               
                      /*** Verifica se conjuge do 1 titular tem o mesmo
                           CPF que foi digitado e pega as informacoes ***/
                      IF  AVAILABLE crapcje AND par_idseqttl <> 1 THEN
                          DO: 
                             CREATE tt-dados-fis.
                             ASSIGN 
                                 tt-dados-fis.dspessoa = "FISICA"
                                 tt-dados-fis.nrcpfcgc = crapcje.nrcpfcjg
                                 tt-dados-fis.cdgraupr = par_cdgraupr 
                                 tt-dados-fis.nmextttl = crapcje.nmconjug
                                 tt-dados-fis.tpdocttl = crapcje.tpdoccje
                                 tt-dados-fis.nrdocttl = crapcje.nrdoccje
                                 tt-dados-fis.cdufdttl = crapcje.cdufdcje
                                 tt-dados-fis.dtemdttl = crapcje.dtemdcje 
                                 tt-dados-fis.dtnasttl = crapcje.dtnasccj 
                                 tt-dados-fis.grescola = crapcje.grescola 
                                 tt-dados-fis.cdfrmttl = crapcje.cdfrmttl
                                 tt-dados-fis.cdnatopc = crapcje.cdnatopc
                                 tt-dados-fis.cdocpttl = crapcje.cdocpcje 
                                 tt-dados-fis.tpcttrab = crapcje.tpcttrab
                                 tt-dados-fis.nmextemp = crapcje.nmextemp
                                 tt-dados-fis.nrcpfemp = crapcje.nrdocnpj 
                                 tt-dados-fis.dsproftl = crapcje.dsproftl
                                 tt-dados-fis.cdnvlcgo = crapcje.cdnvlcgo
                                 tt-dados-fis.cdturnos = crapcje.cdturnos
                                 tt-dados-fis.dtadmemp = crapcje.dtadmemp
                                 tt-dados-fis.vlsalari = crapcje.vlsalari 
                                 NO-ERROR.

                             IF  ERROR-STATUS:ERROR THEN 
                                 DO:
                                    aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                    UNDO BuscaI, LEAVE BuscaI.
                                 END.

                            /* Retornar orgao expedidor */
                            IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                                RUN sistema/generico/procedures/b1wgen0052b.p 
                                    PERSISTENT SET h-b1wgen0052b.

                            ASSIGN tt-dados-fis.cdoedttl = "".
                            RUN busca_org_expedidor IN h-b1wgen0052b 
                                               ( INPUT crapcje.idorgexp,
                                                OUTPUT tt-dados-fis.cdoedttl,
                                                OUTPUT aux_cdcritic, 
                                                OUTPUT aux_dscritic).

                            DELETE PROCEDURE h-b1wgen0052b.   

                            IF  RETURN-VALUE = "NOK" THEN
                            DO:
                                UNDO BuscaI, LEAVE BuscaI.                               
                            END.

                          END. /* AVAILABLE crapcje AND par_idseqttl <> 1  */

                   END. /* par_cdgraupr = 1 OR par_cdgraupr = 4  */

            END. /* ELSE AVAILABLE crabttl  */

        ASSIGN par_dscritic = "".

        LEAVE BuscaI.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Busca_Alteracao:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdgraupr AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfass AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfstl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfttl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpftit AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                     NO-UNDO.

    DEF OUTPUT PARAM par_msgconta AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_dtaltera AS DATE                              NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                              NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER craxttl FOR crapttl.
    DEF BUFFER crabass FOR crapass.

    ASSIGN par_dscritic = "Erro na busca dos dados".
           aux_returnvl = "NOK".

    BuscaA: DO ON ERROR UNDO BuscaA, LEAVE BuscaA:
       
        /** Verifica se ja existe conjuge para o primeiro titular **/
        IF  par_cdgraupr = 1 OR par_cdgraupr = 4  THEN
            DO:
               IF  CAN-FIND(FIRST crabttl WHERE 
                            crabttl.cdcooper = par_cdcooper  AND
                            crabttl.nrdconta = par_nrdconta  AND
                            (crabttl.cdgraupr = 1 OR 
                             crabttl.cdgraupr = 4)            AND
                            crabttl.idseqttl <> par_idseqttl) THEN
                   DO:   
                      ASSIGN par_dscritic = "Ja existe um CONJUGE para esta " +
                                            "conta!".
                      LEAVE BuscaA.
                   END.
            END.

        /** Busca conta ativa mais atual do cooperado **/ 
        ASSIGN aux_dtaltera = 01/01/0001. 
               aux_nrdconta = 0.
                  

        FOR EACH crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                               crabttl.nrcpfcgc = par_nrcpfcgc AND
                               crabttl.idseqttl = 1  
                               NO-LOCK, 
            
            FIRST crabass  WHERE crabass.cdcooper = crabttl.cdcooper AND
                                 crabass.nrdconta = crabttl.nrdconta AND
                                 crabass.dtdemiss = ?  
                                 NO-LOCK:
                               
            /** Ignora conta aplicacao **/
            IF  CAN-DO("6,7,17,18",STRING(crabass.cdtipcta))  THEN
                NEXT.
            
            FIND LAST crapalt WHERE 
                      crapalt.cdcooper = crabass.cdcooper AND
                      crapalt.nrdconta = crabass.nrdconta 
                      NO-LOCK NO-ERROR.
            
            IF  AVAIL crapalt THEN
                DO:   
                    IF  crapalt.dtaltera > aux_dtaltera THEN
                        DO:  
                            ASSIGN aux_nrdconta = crapalt.nrdconta
                                   aux_dtaltera = crapalt.dtaltera.
                        END.
                END.
            ELSE
                IF  aux_nrdconta = 0 THEN
                    ASSIGN aux_nrdconta = crabass.nrdconta.
              
        END.

        FIND crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                           crabttl.nrcpfcgc = par_nrcpfcgc AND
                           crabttl.idseqttl = 1            AND
                           crabttl.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crabttl AND par_idseqttl <> 1 THEN
            DO:       
               IF  par_nrcpfcgc = par_nrcpfass OR
                   par_nrcpfcgc = par_nrcpfstl OR   /*Seg.tit.*/
                   par_nrcpfcgc = par_nrcpfttl THEN /*Ter.tit.*/
                   DO:
                      IF  par_nrcpfcgc <> par_nrcpftit THEN
                          DO:   
                             ASSIGN par_dscritic = "CPF deve ser diferente " +
                                                   "dos demais titulares.".
                             LEAVE BuscaA.
                         END.
                   END.
               ELSE
                   DO:
                      /* sera aplicado qdo houver alteracao no segundo ou 
                         terceiro titular, a comparacao sera feita com o 
                         quarto titular pois os demais cpf's estao na 
                         tabela crapass [cpfstl e cpfttl] */
                      IF  CAN-FIND(FIRST crabttl WHERE
                                   crabttl.cdcooper = par_cdcooper  AND
                                   crabttl.nrdconta = par_nrdconta  AND
                                   crabttl.nrcpfcgc = par_nrcpfcgc  AND
                                   crabttl.idseqttl <> par_idseqttl) THEN
                          DO:
                             ASSIGN par_dscritic = "CPF deve ser diferente " +
                                                   "dos demais titulares.".
                             LEAVE BuscaA.
                          END.
                   END.
        
               /*** Verifica se titular pode ter conjuge ***/
               IF  par_cdgraupr = 1 OR par_cdgraupr = 4  THEN
                   DO:  
                      FIND craxttl WHERE craxttl.cdcooper = par_cdcooper AND
                                         craxttl.nrdconta = par_nrdconta AND
                                         craxttl.idseqttl = 1 
                                         NO-LOCK NO-ERROR.

                      IF  AVAILABLE craxttl THEN
                          DO:
                             IF  craxttl.cdestcvl = 2  OR /* COM. UNIVERSAL */
                                 craxttl.cdestcvl = 3  OR /* COM PARCIAL    */
                                 craxttl.cdestcvl = 4  OR /* SEP DE BENS    */
                                 craxttl.cdestcvl = 8  OR /* CAS REG TOTAL  */
                                 craxttl.cdestcvl = 9  OR /* REG. MISTO/ESPE*/
                                 craxttl.cdestcvl = 11 OR /* PAR.FIN AQUESTO*/
                                 craxttl.cdestcvl = 12 THEN /* UNIAO ESTAVEL*/
                                 DO:
                                    /** Verifica estado civil do cooperado **/
                                    IF  crabttl.cdestcvl = 2  OR 
                                        crabttl.cdestcvl = 3  OR 
                                        crabttl.cdestcvl = 4  OR 
                                        crabttl.cdestcvl = 8  OR 
                                        crabttl.cdestcvl = 9  OR 
                                        crabttl.cdestcvl = 11 OR 
                                        crabttl.cdestcvl = 12 THEN.
                                    ELSE
                                        DO:
                                           par_dscritic = "Estado civil do " + 
                                                          "cooperado deste " + 
                                                          "CPF nao permite " + 
                                                          "ser conjuge.".
                                           LEAVE BuscaA.
                                        END.
                                 END.
                             ELSE 
                                DO:
                                   par_dscritic = "Estado civil do primeiro " +
                                                  "titular nao permite " + 
                                                  "conjuge.".
                                   LEAVE BuscaA.
                                END.
                          END.
                   END.
               
               /* Obtem registro de titularidade do coooperado */
               FIND craxttl WHERE craxttl.cdcooper = par_cdcooper AND 
                                  craxttl.nrdconta = par_nrdconta AND
                                  craxttl.idseqttl = par_idseqttl
                                  NO-LOCK NO-ERROR.
               
               IF  AVAILABLE craxttl                AND 
                   craxttl.nrcpfcgc = par_nrcpfcgc  THEN
                   DO:   
                       RUN Atualiza_Campos 
                         ( INPUT par_cdgraupr,
                           INPUT par_qtfoltal,
                           INPUT par_nrdctitg,
                           INPUT crabttl.nrdconta,
                           BUFFER craxttl,
                          OUTPUT par_msgconta,
                          OUTPUT par_cdcritic,
                          OUTPUT par_dscritic ).
    
                       IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                           LEAVE BuscaA.
                   END.
               ELSE
                   DO:    
                       RUN Atualiza_Campos 
                         ( INPUT par_cdgraupr,
                           INPUT par_qtfoltal,
                           INPUT par_nrdctitg,
                           INPUT crabttl.nrdconta,
                           BUFFER crabttl,
                          OUTPUT par_msgconta,
                          OUTPUT par_cdcritic,
                          OUTPUT par_dscritic ).
    
                       IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                           LEAVE BuscaA.
                   END.
            END.     /** Fim Avail crabttl **/
        ELSE
            DO:          
               FIND crabttl WHERE crabttl.cdcooper = par_cdcooper AND 
                                  crabttl.nrdconta = par_nrdconta AND
                                  crabttl.idseqttl = par_idseqttl
                                  NO-LOCK NO-ERROR.

               IF  AVAILABLE crabttl THEN
                   DO: 
                      RUN Atualiza_Campos 
                          ( INPUT par_cdgraupr,
                            INPUT par_qtfoltal,
                            INPUT par_nrdctitg,
                            INPUT 0,
                            BUFFER crabttl,
                           OUTPUT par_msgconta,
                           OUTPUT par_cdcritic,
                           OUTPUT par_dscritic ).
    
                      IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                          LEAVE BuscaA.
                   END.
            END.

        ASSIGN par_dscritic = "".

        LEAVE BuscaA.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Atualiza_Campos:

    DEF  INPUT PARAM par_cdgraupr AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdctitg AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_nrctamsg AS INTE                     NO-UNDO.

    DEF  PARAM BUFFER brapttl FOR crapttl.

    DEF OUTPUT PARAM par_msgconta AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.

    ASSIGN par_dscritic = "Erro na atualizacao dos campos".
           aux_returnvl = "NOK".

    Campos: DO ON ERROR UNDO Campos, LEAVE Campos:
        
        CREATE tt-dados-fis.
        ASSIGN tt-dados-fis.inpessoa = 1
               tt-dados-fis.dspessoa = "FISICA"
               tt-dados-fis.cdgraupr = par_cdgraupr.

        
        /* Buscar nacionalidade */
        FIND FIRST crapnac
             WHERE crapnac.cdnacion = brapttl.cdnacion
             NO-LOCK NO-ERROR.
        
        /* Grau escolar */
        ASSIGN tt-dados-fis.grescola = brapttl.grescola.
       
        ASSIGN tt-dados-fis.nrctattl = brapttl.nrdconta 
               tt-dados-fis.nmextttl = brapttl.nmextttl
               tt-dados-fis.dtcnscpf = brapttl.dtcnscpf   
               tt-dados-fis.cdsitcpf = brapttl.cdsitcpf   
               tt-dados-fis.cdsexotl = brapttl.cdsexotl
               tt-dados-fis.tpdocttl = brapttl.tpdocttl
               tt-dados-fis.nrdocttl = brapttl.nrdocttl  
               tt-dados-fis.cdufdttl = brapttl.cdufdttl
               tt-dados-fis.dtemdttl = brapttl.dtemdttl  
               tt-dados-fis.dtnasttl = brapttl.dtnasttl  
               tt-dados-fis.tpnacion = brapttl.tpnacion  
               tt-dados-fis.cdnacion = brapttl.cdnacion  
               tt-dados-fis.dsnacion = crapnac.dsnacion  
               tt-dados-fis.dsnatura = brapttl.dsnatura
               tt-dados-fis.cdufnatu = brapttl.cdufnatu
               tt-dados-fis.inhabmen = brapttl.inhabmen  
               tt-dados-fis.dthabmen = brapttl.dthabmen  
               tt-dados-fis.cdestcvl = brapttl.cdestcvl  
               tt-dados-fis.cdfrmttl = brapttl.cdfrmttl
               tt-dados-fis.nmtalttl = brapttl.nmtalttl
               tt-dados-fis.cdnatopc = brapttl.cdnatopc
               tt-dados-fis.cdocpttl = brapttl.cdocpttl 
               tt-dados-fis.tpcttrab = brapttl.tpcttrab
               tt-dados-fis.nmextemp = brapttl.nmextemp
               tt-dados-fis.nrcpfemp = brapttl.nrcpfemp 
               tt-dados-fis.dsproftl = brapttl.dsproftl
               tt-dados-fis.cdnvlcgo = brapttl.cdnvlcgo
               tt-dados-fis.cdturnos = brapttl.cdturnos
               tt-dados-fis.dtadmemp = brapttl.dtadmemp
               tt-dados-fis.vlsalari = brapttl.vlsalari             
               tt-dados-fis.qtfoltal = par_qtfoltal NO-ERROR.

        IF  tt-dados-fis.cdsexotl = 0 THEN
            ASSIGN tt-dados-fis.cdsexotl = 1.
        
        IF  par_nrctamsg > 0  THEN
            ASSIGN par_msgconta = "Dados deste titular somente podem ser " +
                                  "alterados na conta: " + 
                                  TRIM(STRING(par_nrctamsg,"zzzz,zzz,9"))
                   tt-dados-fis.nrctattl = par_nrctamsg.               

        /* Retornar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN tt-dados-fis.cdoedttl = "".
        RUN busca_org_expedidor IN h-b1wgen0052b 
                           ( INPUT brapttl.idorgexp,
                            OUTPUT tt-dados-fis.cdoedttl,
                            OUTPUT par_cdcritic, 
                            OUTPUT par_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
            tt-dados-fis.cdoedttl = 'NAO CADAST.'.
        END.        
        
        ASSIGN par_dscritic = "".

        LEAVE Campos.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

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
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cdgraupr LIKE crapttl.cdgraupr             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdoedttl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasttl LIKE crapttl.dtnasttl             NO-UNDO.
    DEF  INPUT PARAM par_nmtalttl LIKE crapttl.nmtalttl             NO-UNDO.
    DEF  INPUT PARAM par_inhabmen LIKE crapttl.inhabmen             NO-UNDO.
    DEF  INPUT PARAM par_cdfrmttl LIKE crapttl.cdfrmttl             NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal LIKE crapass.qtfoltal             NO-UNDO.
    DEF  INPUT PARAM par_nmextttl LIKE crapttl.nmextttl             NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf LIKE crapttl.dtcnscpf             NO-UNDO.
    DEF  INPUT PARAM par_tpdocttl LIKE crapttl.tpdocttl             NO-UNDO.
    DEF  INPUT PARAM par_cdufdttl LIKE crapttl.cdufdttl             NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl LIKE crapttl.cdsexotl             NO-UNDO.
    DEF  INPUT PARAM par_cdnacion LIKE crapttl.cdnacion             NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl LIKE crapttl.cdestcvl             NO-UNDO.
    DEF  INPUT PARAM par_grescola LIKE crapttl.grescola             NO-UNDO.
    DEF  INPUT PARAM par_inpessoa LIKE crapttl.inpessoa             NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf LIKE crapttl.cdsitcpf             NO-UNDO.
    DEF  INPUT PARAM par_nrdocttl LIKE crapttl.nrdocttl             NO-UNDO.
    DEF  INPUT PARAM par_dtemdttl LIKE crapttl.dtemdttl             NO-UNDO.
    DEF  INPUT PARAM par_tpnacion LIKE crapttl.tpnacion             NO-UNDO.
    DEF  INPUT PARAM par_dsnatura LIKE crapttl.dsnatura             NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu LIKE crapttl.cdufnatu             NO-UNDO.
    DEF  INPUT PARAM par_dthabmen LIKE crapttl.dthabmen             NO-UNDO.
    DEF  INPUT PARAM par_nmcertif AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdnatopc LIKE crapttl.cdnatopc             NO-UNDO.
    DEF  INPUT PARAM par_cdocpttl LIKE crapttl.cdocpttl             NO-UNDO.
    DEF  INPUT PARAM par_tpcttrab LIKE crapttl.tpcttrab             NO-UNDO.
    DEF  INPUT PARAM par_nmextemp LIKE crapttl.nmextemp             NO-UNDO.
    DEF  INPUT PARAM par_nrcpfemp LIKE crapttl.nrcpfemp             NO-UNDO.
    DEF  INPUT PARAM par_dsproftl LIKE crapttl.dsproftl             NO-UNDO.
    DEF  INPUT PARAM par_cdnvlcgo LIKE crapttl.cdnvlcgo             NO-UNDO.
    DEF  INPUT PARAM par_cdturnos LIKE crapttl.cdturnos             NO-UNDO.
    DEF  INPUT PARAM par_dtadmemp LIKE crapttl.dtadmemp             NO-UNDO.
    DEF  INPUT PARAM par_vlsalari LIKE crapttl.vlsalari             NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-resp.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
                                                                    
    DEF OUTPUT PARAM TABLE FOR tt-erro.                             
                                                                    
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTEGER                                 NO-UNDO.
    DEF VAR aux_contadoc AS INT                                     NO-UNDO.
    DEF VAR aux_rowidass AS ROWID                                   NO-UNDO.
    DEF VAR aux_rowidttl AS ROWID                                   NO-UNDO.
    DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0072 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_msgconta AS CHARACTER                               NO-UNDO.
    DEF VAR aux_msgalert AS CHARACTER                               NO-UNDO.
    DEF VAR aux_dsrotina AS CHARACTER                               NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_cdorgexp AS CHARACTER                               NO-UNDO. 
    DEF VAR aux_idorgexp AS INT                                     NO-UNDO. 


    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF  par_cddopcao = "I" THEN
                               "Incluir" 
                           ELSE 
                              "Alterar") + 
                          " dados da Identificacao"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsrotina = ""
           aux_retorno  = "NOK".

    EMPTY TEMP-TABLE tt-erro.

    Grava: DO TRANSACTION 
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:
        
        /* se for inclusao e nao houver o nr. da sequencia (web) */
        IF  par_cddopcao = "I" OR par_idseqttl = 0 THEN
           
            ASSIGN par_idseqttl = BuscaUltimoTtl(par_cdcooper,par_nrdconta).
        
        IF  par_cddopcao = "I" THEN
            DO:
                /* Gerar pendencia de CPF */
                IF  par_inpessoa = 1 THEN
                RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                            INPUT par_nrdconta, 
                                            INPUT par_dtmvtolt, 
                                            INPUT 1, 
                                            INPUT par_idseqttl,
                                           OUTPUT aux_cdcritic).

                /* Gerar pendencia de carteira de identificacao */
                IF  par_inpessoa = 1 THEN
                RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                            INPUT par_nrdconta, 
                                            INPUT par_dtmvtolt, 
                                            INPUT 2, 
                                            INPUT par_idseqttl,
                                           OUTPUT aux_cdcritic).

                /* Gerar pendencia de comprovante de endereço */
                RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                            INPUT par_nrdconta, 
                                            INPUT par_dtmvtolt, 
                                            INPUT 3, 
                                            INPUT par_idseqttl,
                                           OUTPUT aux_cdcritic).

                /* Gerar pendencia de estado civil */
                IF  CAN-DO("2,3,4,8,9,11,12", STRING(par_cdestcvl)) AND
                    par_inpessoa = 1 THEN
                    RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                                INPUT par_nrdconta, 
                                                INPUT par_dtmvtolt, 
                                                INPUT 4, 
                                                INPUT par_idseqttl,
                                               OUTPUT aux_cdcritic).
                
                /* Gerar pendencia de comprovante de renda */
                IF  par_inpessoa = 1 THEN
                RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                            INPUT par_nrdconta, 
                                            INPUT par_dtmvtolt, 
                                            INPUT 5,
                                            INPUT par_idseqttl,
                                           OUTPUT aux_cdcritic).

                /* Gerar pendencia de cartao assinatura */
                RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                            INPUT par_nrdconta, 
                                            INPUT par_dtmvtolt, 
                                            INPUT 6,
                                            INPUT par_idseqttl,
                                           OUTPUT aux_cdcritic).

                /* Removido a criação da doc conforme solicitado no chamado 372880*/
               /* RUN cria_pendencia_digidoc( INPUT par_cdcooper, 
                                            INPUT par_nrdconta, 
                                            INPUT par_dtmvtolt, 
                                            INPUT 7, 
                                            INPUT par_idseqttl,
                                           OUTPUT aux_cdcritic).*/
            END. /* Fim da inclusao */

        ContadorAss: DO aux_contador = 1 TO 10:


            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapass THEN
                DO:
                   IF  LOCKED(crapass) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 aux_dscritic = "Associado sendo alterado " +
                                                "em outra estacao".
                                 LEAVE ContadorAss.
                              END.
                          ELSE 
                              DO: 
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorAss.
                              END.
                       END.
                   ELSE 
                       DO:
                          ASSIGN aux_dscritic = "Associado nao cadastrado" .
                          LEAVE ContadorAss.
                       END.
                END.
            ELSE 
                LEAVE ContadorAss.
        END.
                                          

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        ContadorTtl: DO aux_contador = 1 TO 10:
        
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapttl THEN
                DO:
                   IF  LOCKED(crapttl) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 aux_dscritic = "Titular sendo alterado " +
                                                "em outra estacao".
                                 LEAVE ContadorTtl.
                              END.
                          ELSE 
                              DO: 
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorTtl.
                              END.
                       END.
                   ELSE 
                       DO:
                          CREATE crapttl.

                          ASSIGN crapttl.cdcooper = par_cdcooper
                                 crapttl.nrdconta = par_nrdconta
                                 crapttl.idseqttl = par_idseqttl
                                 crapttl.inpessoa = 1
                                 crapttl.inpolexp = 0. /*0-Nao Politicamente exposto*/
                                 
                          /* Chamar rotina para retornar dados de pessoa para complementar cadastro do titular */
                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                          RUN STORED-PROCEDURE pc_busca_crapttl_compl 
                                aux_handproc = PROC-HANDLE NO-ERROR
                                                 (  INPUT par_nrcpfcgc  /* pr_nrcpfcgc   */
                                                   ,OUTPUT 0   /* pr_cdnatopc   */
                                                   ,OUTPUT 0   /* pr_cdocpttl   */   
                                                   ,OUTPUT 0   /* pr_tpcttrab   */   
                                                   ,OUTPUT ""  /* pr_nmextemp   */   
                                                   ,OUTPUT 0   /* pr_nrcpfemp   */   
                                                   ,OUTPUT ?   /* pr_dtadmemp   */
                                                   ,OUTPUT ""  /* pr_dsproftl   */
                                                   ,OUTPUT 0   /* pr_cdnvlcgo   */
                                                   ,OUTPUT 0   /* pr_vlsalari   */
                                                   ,OUTPUT 0   /* pr_cdturnos   */
                                                   ,OUTPUT ""  /* pr_dsjusren   */
                                                   ,OUTPUT ?   /* pr_dtatutel   */
                                                   ,OUTPUT 0   /* pr_cdgraupr   */
												                           ,OUTPUT 0   /* pr_cdfrmttl   */
                                                   ,OUTPUT 0   /* pr_tpdrendi##1*/
                                                   ,OUTPUT 0   /* pr_vldrendi##1*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##2*/
                                                   ,OUTPUT 0   /* pr_vldrendi##2*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##3*/
                                                   ,OUTPUT 0   /* pr_vldrendi##3*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##4*/
                                                   ,OUTPUT 0   /* pr_vldrendi##4*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##5*/
                                                   ,OUTPUT 0   /* pr_vldrendi##5*/
                                                   ,OUTPUT 0   /* pr_tpdrendi##6*/
                                                   ,OUTPUT 0   /* pr_vldrendi##6*/
                                                   ,OUTPUT ""  /* pr_nmpaittl   */
                                                   ,OUTPUT ""  /* pr_nmmaettl   */
                                                   ,OUTPUT ""). /* pr_dscritic   */

                            CLOSE STORED-PROC pc_busca_crapttl_compl 
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                            ASSIGN crapttl.cdnatopc = pc_busca_crapttl_compl.pr_cdnatopc 
                                                      WHEN pc_busca_crapttl_compl.pr_cdnatopc <> ?
                                   crapttl.cdocpttl = pc_busca_crapttl_compl.pr_cdocpttl 
                                                      WHEN pc_busca_crapttl_compl.pr_cdocpttl <> ? 
                                   crapttl.tpcttrab = pc_busca_crapttl_compl.pr_tpcttrab 
                                                      WHEN pc_busca_crapttl_compl.pr_tpcttrab <> ? 
                                   crapttl.nmextemp = pc_busca_crapttl_compl.pr_nmextemp 
                                                      WHEN pc_busca_crapttl_compl.pr_nmextemp <> ? 
                                   crapttl.nrcpfemp = pc_busca_crapttl_compl.pr_nrcpfemp 
                                                      WHEN pc_busca_crapttl_compl.pr_nrcpfemp <> ? 
                                   crapttl.dtadmemp = pc_busca_crapttl_compl.pr_dtadmemp 
                                                      WHEN pc_busca_crapttl_compl.pr_dtadmemp <> ? 
                                   crapttl.dsproftl = pc_busca_crapttl_compl.pr_dsproftl 
                                                      WHEN pc_busca_crapttl_compl.pr_dsproftl <> ?                                    
                                   crapttl.cdnvlcgo = pc_busca_crapttl_compl.pr_cdnvlcgo 
                                                      WHEN pc_busca_crapttl_compl.pr_cdnvlcgo <> ? 
                                   crapttl.vlsalari = pc_busca_crapttl_compl.pr_vlsalari 
                                                      WHEN pc_busca_crapttl_compl.pr_vlsalari <> ? 
                                   crapttl.cdturnos = pc_busca_crapttl_compl.pr_cdturnos 
                                                      WHEN pc_busca_crapttl_compl.pr_cdturnos <> ? 
                                   crapttl.dsjusren = pc_busca_crapttl_compl.pr_dsjusren 
                                                      WHEN pc_busca_crapttl_compl.pr_dsjusren <> ? 
                                   crapttl.dtatutel = pc_busca_crapttl_compl.pr_dtatutel 
                                                      WHEN pc_busca_crapttl_compl.pr_dtatutel <> ?
                                   crapttl.grescola = pc_busca_crapttl_compl.pr_cdgraupr 
                                                      WHEN pc_busca_crapttl_compl.pr_cdgraupr <> ? 
                                   crapttl.cdfrmttl = pc_busca_crapttl_compl.pr_cdfrmttl 
                                                      WHEN pc_busca_crapttl_compl.pr_cdfrmttl <> ?
                                   crapttl.nmpaittl = pc_busca_crapttl_compl.pr_nmpaittl 
                                                      WHEN pc_busca_crapttl_compl.pr_nmpaittl <> ?
                                   crapttl.nmmaettl = pc_busca_crapttl_compl.pr_nmmaettl 
                                                      WHEN pc_busca_crapttl_compl.pr_nmmaettl <> ?.
                                                      
                            ASSIGN crapttl.tpdrendi[1] = pc_busca_crapttl_compl.pr_tpdrendi##1 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##1 <> ?
                                   crapttl.vldrendi[1] = pc_busca_crapttl_compl.pr_vldrendi##1 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##1 <> ?
                                   crapttl.tpdrendi[2] = pc_busca_crapttl_compl.pr_tpdrendi##2 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##2 <> ?                                                         
                                   crapttl.vldrendi[2] = pc_busca_crapttl_compl.pr_vldrendi##2
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##2 <> ?                                                        
                                   crapttl.tpdrendi[3] = pc_busca_crapttl_compl.pr_tpdrendi##3
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##3 <> ?
                                   crapttl.vldrendi[3] = pc_busca_crapttl_compl.pr_vldrendi##3 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##3 <> ?                                                         
                                   crapttl.tpdrendi[4] = pc_busca_crapttl_compl.pr_tpdrendi##4
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##4 <> ?
                                   crapttl.vldrendi[4] = pc_busca_crapttl_compl.pr_vldrendi##4
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##4 <> ?
                                   crapttl.tpdrendi[5] = pc_busca_crapttl_compl.pr_tpdrendi##5 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##5 <> ?
                                   crapttl.vldrendi[5] = pc_busca_crapttl_compl.pr_vldrendi##5 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##5 <> ?
                                   crapttl.tpdrendi[6] = pc_busca_crapttl_compl.pr_tpdrendi##6 
                                                         WHEN pc_busca_crapttl_compl.pr_tpdrendi##6 <> ?
                                   crapttl.vldrendi[6] = pc_busca_crapttl_compl.pr_vldrendi##6 
                                                         WHEN pc_busca_crapttl_compl.pr_vldrendi##6 <> ?.

                          /* setar na inclusao para garantir dados do cadastro unificado
                             visto que na inclusao nao possui estas informaçoes*/       
                          IF par_cdnatopc = 0 THEN 
                             ASSIGN par_cdnatopc = crapttl.cdnatopc.
                          IF par_cdocpttl = 0 THEN 
                             ASSIGN par_cdocpttl = crapttl.cdocpttl.
                          IF par_tpcttrab = 0 THEN   
                             ASSIGN par_tpcttrab = crapttl.tpcttrab.                             
                          IF par_nmextemp = "" THEN   
                             ASSIGN par_nmextemp = crapttl.nmextemp. 
                          IF par_nrcpfemp = 0 THEN   
                             ASSIGN par_nrcpfemp = crapttl.nrcpfemp. 
                          IF par_dsproftl = "" THEN   
                             ASSIGN par_dsproftl = crapttl.dsproftl. 
                          IF par_cdnvlcgo = 0 THEN   
                             ASSIGN par_cdnvlcgo = crapttl.cdnvlcgo. 
                          IF par_cdturnos = 0 THEN   
                             ASSIGN par_cdturnos = crapttl.cdturnos. 
                          IF par_dtadmemp = ? THEN   
                             ASSIGN par_dtadmemp = crapttl.dtadmemp. 
                          IF par_vlsalari = 0 THEN   
                             ASSIGN par_vlsalari = crapttl.vlsalari. 
                             
                             
                             
                             
                             
                             
                          LEAVE ContadorTtl.
                       END.
                END.
            ELSE 
                LEAVE ContadorTtl.
        END.
                                                        

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        ASSIGN aux_rowidass = ROWID(crapass)
               aux_rowidttl = ROWID(crapttl).

        EMPTY TEMP-TABLE tt-dados-fis-ant.
        EMPTY TEMP-TABLE tt-dados-fis-atl.

        CREATE tt-dados-fis-ant.
        
        IF  par_cddopcao <> "I" THEN
            
            ASSIGN
                tt-dados-fis-ant.nrctattl = crapttl.nrdconta
                tt-dados-fis-ant.idseqttl = crapttl.idseqttl
                tt-dados-fis-ant.cdgraupr = crapttl.cdgraupr
                tt-dados-fis-ant.nrcpfcgc = crapttl.nrcpfcgc
                tt-dados-fis-ant.dtnasttl = crapttl.dtnasttl
                tt-dados-fis-ant.inhabmen = crapttl.inhabmen
                tt-dados-fis-ant.cdfrmttl = crapttl.cdfrmttl
                tt-dados-fis-ant.nmtalttl = crapttl.nmtalttl
                tt-dados-fis-ant.qtfoltal = crapass.qtfoltal
                tt-dados-fis-ant.nmextttl = crapttl.nmextttl
                tt-dados-fis-ant.dtcnscpf = crapttl.dtcnscpf
                tt-dados-fis-ant.tpdocttl = crapttl.tpdocttl
                tt-dados-fis-ant.cdufdttl = crapttl.cdufdttl
                tt-dados-fis-ant.cdsexotl = crapttl.cdsexotl
                tt-dados-fis-ant.cdnacion = crapttl.cdnacion
                tt-dados-fis-ant.cdestcvl = crapttl.cdestcvl
                tt-dados-fis-ant.grescola = crapttl.grescola
                tt-dados-fis-ant.inpessoa = crapttl.inpessoa
                tt-dados-fis-ant.cdsitcpf = crapttl.cdsitcpf
                tt-dados-fis-ant.nrdocttl = crapttl.nrdocttl
                tt-dados-fis-ant.dtemdttl = crapttl.dtemdttl
                tt-dados-fis-ant.tpnacion = crapttl.tpnacion
                tt-dados-fis-ant.dsnatura = crapttl.dsnatura
                tt-dados-fis-ant.cdufnatu = crapttl.cdufnatu
                tt-dados-fis-ant.dthabmen = crapttl.dthabmen
                tt-dados-fis-ant.cdnatopc = crapttl.cdnatopc
                tt-dados-fis-ant.cdocpttl = crapttl.cdocpttl
                tt-dados-fis-ant.tpcttrab = crapttl.tpcttrab
                tt-dados-fis-ant.nmextemp = crapttl.nmextemp
                tt-dados-fis-ant.nrcpfemp = crapttl.nrcpfemp
                tt-dados-fis-ant.dsproftl = crapttl.dsproftl
                tt-dados-fis-ant.cdnvlcgo = crapttl.cdnvlcgo
                tt-dados-fis-ant.cdturnos = crapttl.cdturnos
                tt-dados-fis-ant.dtadmemp = crapttl.dtadmemp
                tt-dados-fis-ant.cdnatopc = crapttl.cdnatopc
                tt-dados-fis-ant.cdocpttl = crapttl.cdocpttl
                tt-dados-fis-ant.tpcttrab = crapttl.tpcttrab
                tt-dados-fis-ant.nmextemp = crapttl.nmextemp
                tt-dados-fis-ant.nrcpfemp = crapttl.nrcpfemp
                tt-dados-fis-ant.dsproftl = crapttl.dsproftl
                tt-dados-fis-ant.cdnvlcgo = crapttl.cdnvlcgo
                
                tt-dados-fis-ant.vlsalari = crapttl.vlsalari.
        
                /* Retornar orgao expedidor */
                IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
                    RUN sistema/generico/procedures/b1wgen0052b.p 
                        PERSISTENT SET h-b1wgen0052b.

                ASSIGN aux_cdorgexp = "".
                RUN busca_org_expedidor IN h-b1wgen0052b 
                                   ( INPUT crapttl.idorgexp,
                                    OUTPUT aux_cdorgexp,
                                    OUTPUT aux_cdcritic, 
                                    OUTPUT aux_dscritic).

                DELETE PROCEDURE h-b1wgen0052b.   
                ASSIGN tt-dados-fis-ant.cdoedttl = aux_cdorgexp. 
        
        IF  par_inpessoa = 1 THEN
            DO:            
        IF par_tpdocttl <> crapttl.tpdocttl OR
           par_nrdocttl <> crapttl.nrdocttl OR
           par_cdufdttl <> crapttl.cdufdttl OR 
           par_cdoedttl <> aux_cdorgexp     OR
           par_dtemdttl <> crapttl.dtemdttl THEN
            DO:
                ContadorDoc2: DO aux_contador = 1 TO 10:
    
                    FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                       crapdoc.nrdconta = par_nrdconta AND
                                       crapdoc.tpdocmto = 2            AND
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
                                            LEAVE ContadorDoc2.
                                        END.
                                    ELSE 
                                        DO: 
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT ContadorDoc2.
                                        END.
                                END.
                            ELSE
                                DO:
                                    
                                    CREATE crapdoc.
                                    ASSIGN crapdoc.cdcooper = par_cdcooper
                                           crapdoc.nrdconta = par_nrdconta
                                           crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt
                                           crapdoc.tpdocmto = 2
                                           crapdoc.idseqttl = par_idseqttl.
                                    VALIDATE crapdoc.        
                                    LEAVE ContadorDoc2.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN crapdoc.flgdigit = FALSE
                                   crapdoc.dtmvtolt = par_dtmvtolt.

                            LEAVE ContadorDoc2.
                        END.
                END. /* LEAVE ContadorDoc2. */
                
            END. /* If par_tpdocttl <> crapttl.tpdocttl */
        
        IF aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        IF par_cdestcvl <> crapttl.cdestcvl AND par_cdestcvl <> 1 THEN
            DO:
            
                ContadorDoc4: DO aux_contador = 1 TO 10:
    
                    FIND FIRST crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                       crapdoc.nrdconta = par_nrdconta AND
                                       crapdoc.tpdocmto = 4            AND
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
                                            LEAVE ContadorDoc4.
                                        END.
                                    ELSE 
                                        DO: 
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT ContadorDoc4.
                                        END.
                                END.
                            ELSE
                                DO:
                                    
                                    CREATE crapdoc.
                                    ASSIGN crapdoc.cdcooper = par_cdcooper
                                           crapdoc.nrdconta = par_nrdconta
                                           crapdoc.flgdigit = FALSE
                                           crapdoc.dtmvtolt = par_dtmvtolt
                                           crapdoc.idseqttl = par_idseqttl
                                           crapdoc.tpdocmto = 4.
                                    VALIDATE crapdoc.
                                    LEAVE ContadorDoc4.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN crapdoc.flgdigit = FALSE
                                   crapdoc.dtmvtolt = par_dtmvtolt.

                            LEAVE ContadorDoc4.
                        END.
                END. /* LEAVE ContadorDoc4. */                

            END. /* IF par_cdestcvl <> crapttl.cdestcvl */
            END. /* inpessoa = 1 */

        IF aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        IF  par_cddopcao <> "I" THEN
            DO:
               { sistema/generico/includes/b1wgenalog.i }
            END.
        
        IF  par_idseqttl = 1 THEN
            ASSIGN crapass.qtfoltal = par_qtfoltal.

        
        /* Identificar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_idorgexp = 0.
        RUN identifica_org_expedidor IN h-b1wgen0052b 
                           ( INPUT par_cdoedttl,
                            OUTPUT aux_idorgexp,
                            OUTPUT aux_cdcritic, 
                            OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   
        IF  RETURN-VALUE = "NOK" THEN
        DO:
            UNDO Grava, LEAVE Grava.
        END.
        

        ASSIGN crapttl.cdgraupr = par_cdgraupr
               crapttl.nrcpfcgc = par_nrcpfcgc
               crapttl.nmextttl = CAPS(par_nmextttl)
               crapttl.dtcnscpf = par_dtcnscpf
               crapttl.cdsitcpf = par_cdsitcpf
               crapttl.tpdocttl = CAPS(par_tpdocttl)
               crapttl.nrdocttl = par_nrdocttl
               crapttl.idorgexp = aux_idorgexp 
               crapttl.cdufdttl = CAPS(par_cdufdttl)
               crapttl.dtemdttl = par_dtemdttl
               crapttl.dtnasttl = par_dtnasttl
               crapttl.cdsexotl = par_cdsexotl
               crapttl.tpnacion = par_tpnacion
               crapttl.cdnacion = par_cdnacion
               crapttl.dsnatura = CAPS(par_dsnatura)
               crapttl.cdufnatu = CAPS(par_cdufnatu)
               crapttl.inhabmen = par_inhabmen
               crapttl.dthabmen = par_dthabmen
               crapttl.cdestcvl = par_cdestcvl
               crapttl.grescola = par_grescola
               crapttl.cdfrmttl = par_cdfrmttl
               crapttl.nmtalttl = CAPS(par_nmtalttl)
               crapttl.cdnatopc = par_cdnatopc
               crapttl.cdocpttl = par_cdocpttl
               crapttl.tpcttrab = par_tpcttrab
               crapttl.nmextemp = par_nmextemp
               crapttl.nrcpfemp = par_nrcpfemp
               crapttl.dsproftl = par_dsproftl
               crapttl.cdnvlcgo = par_cdnvlcgo
               crapttl.cdturnos = par_cdturnos
               crapttl.dtadmemp = par_dtadmemp
               crapttl.vlsalari = par_vlsalari
               crapttl.inpessoa = par_inpessoa
               crapttl.flgimpri = TRUE WHEN par_cddopcao = "I"
               NO-ERROR.
        
        IF  ERROR-STATUS:ERROR THEN
            DO:
               ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
               UNDO Grava, LEAVE Grava.
            END.

        IF  crapttl.inpessoa <> 1 THEN 
            ASSIGN crapttl.inpessoa = 1.

        VALIDATE crapttl.

        /* ----- Inicio das verificacoes extraidas do contas_dados.p ------- */
        CASE par_cddopcao:
            WHEN "I" THEN DO:

                RUN Grava_Inclusao(INPUT par_nrcpfcgc,
                                   INPUT par_cddopcao,
                                   INPUT par_grescola,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_dtmvtolt,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_idorigem,
                                   INPUT par_flgerlog,
                                   BUFFER crapttl,
                                   OUTPUT aux_cdcritic,
                                   OUTPUT aux_dscritic ).
                
                IF  aux_cdcritic <> 0 OR  aux_dscritic <> "" THEN
                    UNDO Grava, LEAVE Grava.
                
            END.

            WHEN "A" THEN DO:

                RUN Grava_Alteracao(INPUT par_nrcpfcgc,
                                    INPUT par_cddopcao,
                                    INPUT par_grescola,
                                    INPUT par_qtfoltal,
                                    BUFFER crapass,
                                    BUFFER crapttl,
                                    OUTPUT aux_cdcritic,
                                    OUTPUT aux_dscritic ). 
                
                IF  aux_cdcritic <> 0 OR  aux_dscritic <> "" THEN
                    UNDO Grava, LEAVE Grava.
                
            END.
            OTHERWISE DO:
                ASSIGN aux_dscritic = "Opcao deve ser [I]=Inclusao ou [A]=" +
                                      "Alteracao".

                UNDO Grava, LEAVE Grava.
            END.
        END CASE.
        

        CREATE tt-dados-fis-atl.

        ASSIGN tt-dados-fis-atl.nrctattl = crapttl.nrdconta
               tt-dados-fis-atl.idseqttl = crapttl.idseqttl
               tt-dados-fis-atl.cdgraupr = crapttl.cdgraupr
               tt-dados-fis-atl.nrcpfcgc = crapttl.nrcpfcgc
               tt-dados-fis-atl.dtnasttl = crapttl.dtnasttl
               tt-dados-fis-atl.inhabmen = crapttl.inhabmen
               tt-dados-fis-atl.cdfrmttl = crapttl.cdfrmttl
               tt-dados-fis-atl.nmtalttl = crapttl.nmtalttl
               tt-dados-fis-atl.qtfoltal = crapass.qtfoltal
               tt-dados-fis-atl.nmextttl = crapttl.nmextttl
               tt-dados-fis-atl.dtcnscpf = crapttl.dtcnscpf
               tt-dados-fis-atl.tpdocttl = crapttl.tpdocttl
               tt-dados-fis-atl.cdufdttl = crapttl.cdufdttl
               tt-dados-fis-atl.cdsexotl = crapttl.cdsexotl
               tt-dados-fis-atl.cdnacion = crapttl.cdnacion
               tt-dados-fis-atl.cdestcvl = crapttl.cdestcvl
               tt-dados-fis-atl.grescola = crapttl.grescola
               tt-dados-fis-atl.inpessoa = crapttl.inpessoa
               tt-dados-fis-atl.cdsitcpf = crapttl.cdsitcpf
               tt-dados-fis-atl.nrdocttl = crapttl.nrdocttl
               tt-dados-fis-atl.dtemdttl = crapttl.dtemdttl
               tt-dados-fis-atl.tpnacion = crapttl.tpnacion
               tt-dados-fis-atl.dsnatura = crapttl.dsnatura
               tt-dados-fis-atl.cdufnatu = crapttl.cdufnatu
               tt-dados-fis-atl.dthabmen = crapttl.dthabmen
               tt-dados-fis-atl.cdnatopc = crapttl.cdnatopc
               tt-dados-fis-atl.cdocpttl = crapttl.cdocpttl
               tt-dados-fis-atl.tpcttrab = crapttl.tpcttrab
               tt-dados-fis-atl.nmextemp = crapttl.nmextemp
               tt-dados-fis-atl.nrcpfemp = crapttl.nrcpfemp
               tt-dados-fis-atl.dsproftl = crapttl.dsproftl
               tt-dados-fis-atl.cdnvlcgo = crapttl.cdnvlcgo
               tt-dados-fis-atl.cdturnos = crapttl.cdturnos
               tt-dados-fis-atl.dtadmemp = crapttl.dtadmemp
               tt-dados-fis-atl.cdnatopc = crapttl.cdnatopc
               tt-dados-fis-atl.cdocpttl = crapttl.cdocpttl
               tt-dados-fis-atl.tpcttrab = crapttl.tpcttrab
               tt-dados-fis-atl.nmextemp = crapttl.nmextemp
               tt-dados-fis-atl.nrcpfemp = crapttl.nrcpfemp
               tt-dados-fis-atl.dsproftl = crapttl.dsproftl
               tt-dados-fis-atl.cdnvlcgo = crapttl.cdnvlcgo
               tt-dados-fis-atl.vlsalari = crapttl.vlsalari.

        /* Retornar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_cdorgexp = "".
        RUN busca_org_expedidor IN h-b1wgen0052b 
                           ( INPUT crapttl.idorgexp,
                            OUTPUT aux_cdorgexp,
                            OUTPUT aux_cdcritic, 
                            OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   
        ASSIGN tt-dados-fis-atl.cdoedttl = aux_cdorgexp.        

        IF  par_cddopcao <> "I" THEN
            DO:
               FIND crapttl WHERE ROWID(crapttl) = aux_rowidttl 
                                  NO-LOCK NO-ERROR.

               { sistema/generico/includes/b1wgenllog.i }
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p 
                PERSISTENT SET h-b1wgen0060.

        IF  par_idseqttl = 1  THEN
            DO:
                /*Alteração (Gabriel/DB1)*/
                IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                    RUN sistema/generico/procedures/b1wgen0077.p 
                        PERSISTENT SET h-b1wgen0077.
            
                RUN Revisao_Cadastral IN h-b1wgen0077
                  ( INPUT par_cdcooper,
                    INPUT par_nrcpfcgc,
                    INPUT par_nrdconta,
                   OUTPUT par_msgalert ).

                IF  VALID-HANDLE(h-b1wgen0077) THEN
                    DELETE OBJECT h-b1wgen0077.
            END.


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

    RELEASE crapass.
    RELEASE crapttl.
        
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                        
    RUN STORED-PROCEDURE pc_marca_replica_ayllos 
      aux_handproc = PROC-HANDLE NO-ERROR
               (INPUT par_cdcooper,  
                INPUT par_nrdconta,
                INPUT par_idseqttl,
               OUTPUT "").

    CLOSE STORED-PROC pc_marca_replica_ayllos 
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }		
    
        
    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  VALID-HANDLE(h-b1wgen0072) THEN
        DELETE OBJECT h-b1wgen0072.

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF (aux_dscritic <> "" OR aux_cdcritic <> 0) AND
        NOT CAN-FIND(LAST tt-erro) THEN 
        DO:
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
        END.

    IF NOT CAN-FIND(LAST tt-erro) THEN
       ASSIGN aux_retorno = "OK".

    IF aux_retorno = "OK" THEN
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

          /*Monta a mensagem da rotina para envio no e-mail*/
          IF par_cddopcao = "I" THEN
             ASSIGN aux_dsrotina = "Inclusao do " + STRING(par_idseqttl) +
                                   "º titular conta "                    +
                                   STRING(par_nrdconta,"zzzz,zzz,9")     +
                                   " - CPF/CNPJ "                        + 
                                   STRING((STRING(par_nrcpfcgc,
                                                  "99999999999")),
                                                  "xxx.xxx.xxx-xx")      +
                                   " na conta "                          +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9") +
                                   " - CPF/CNPJ "                        +
                                   STRING((STRING(crapass.nrcpfcgc,
                                                  "99999999999")),
                                                  "xxx.xxx.xxx-xx").

          ELSE
             ASSIGN aux_dsrotina = "Alteracao da identificacao do "      +
                                   STRING(par_idseqttl)                  +
                                   "º titular conta "                    +
                                   STRING(par_nrdconta,"zzzz,zzz,9")     +
                                   " - CPF/CNPJ "                        +
                                   STRING((STRING(par_nrcpfcgc,
                                                  "99999999999")),
                                                  "xxx.xxx.xxx-xx")      +
                                   " na conta "                          +
                                   STRING(crapass.nrdconta,"zzzz,zzz,9") +
                                   " - CPF/CNPJ "                        +
                                   STRING((STRING(crapass.nrcpfcgc,
                                                  "99999999999")),
                                                  "xxx.xxx.xxx-xx").

          
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
                                            INPUT crapass.nrcpfcgc, 
                                            INPUT crapass.nrdconta, 
                                            INPUT 1,     /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 27,    /*cdoperac*/
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

          IF par_cddopcao = "A" AND 
             par_idseqttl = 1   THEN
             DO:
                IF VALID-HANDLE(h-b1wgen0110) THEN
                   DELETE PROCEDURE(h-b1wgen0110).

                LEAVE Cad_Restritivo.

             END.
           

          /*Verifica se o novo titular esta no cadastro restritivo. Se estiver,
            sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT par_nrcpfcgc,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 27, /*cdoperac*/
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
              INPUT BUFFER tt-dados-fis-ant:HANDLE,
              INPUT BUFFER tt-dados-fis-atl:HANDLE ).

              
    RETURN aux_retorno.

END PROCEDURE.

PROCEDURE Grava_Inclusao:

    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_grescola AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                     NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                      NO-UNDO.

    DEF  PARAM BUFFER brapttl FOR crapttl.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_dtaltera AS DATE                              NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                              NO-UNDO.
    DEF VAR aux_contador AS INTE                              NO-UNDO.

    DEF VAR h-b1wgen0077 AS HANDLE                            NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER craxttl FOR crapttl.
    DEF BUFFER crabass FOR crapass.

    ASSIGN 
        par_dscritic = "Erro na Inclusao dos dados".
        aux_returnvl = "NOK".
    
    Inclusao: DO ON ERROR UNDO Inclusao, LEAVE Inclusao:

        /** Busca conta ativa mais atual do cooperado **/ 
        ASSIGN 
            aux_dtaltera = 01/01/0001
            aux_nrdconta = 0.
        
        FOR EACH crabttl WHERE crabttl.cdcooper = brapttl.cdcooper AND
                               crabttl.nrcpfcgc = par_nrcpfcgc     AND
                               crabttl.idseqttl = 1  NO-LOCK, 
            FIRST crabass  WHERE crabass.cdcooper = crabttl.cdcooper AND
                                 crabass.nrdconta = crabttl.nrdconta AND
                                 crabass.dtdemiss = ?  NO-LOCK:
                               
            /** Ignora conta aplicacao **/
            IF  CAN-DO("6,7,17,18",STRING(crabass.cdtipcta))  THEN
                NEXT.
            
            FIND LAST crapalt WHERE 
                      crapalt.cdcooper = crabass.cdcooper AND
                      crapalt.nrdconta = crabass.nrdconta 
                      NO-LOCK NO-ERROR.
            
            IF  AVAIL crapalt THEN
                DO:   
                    IF  crapalt.dtaltera > aux_dtaltera THEN
                        DO:  
                            ASSIGN aux_nrdconta = crapalt.nrdconta
                                   aux_dtaltera = crapalt.dtaltera.
                        END.
                END.
            ELSE
                IF  aux_nrdconta = 0 THEN
                    ASSIGN aux_nrdconta = crabass.nrdconta.
                
        END.        
        
        FIND crabttl WHERE crabttl.cdcooper = brapttl.cdcooper AND
                           crabttl.nrcpfcgc = par_nrcpfcgc     AND
                           crabttl.idseqttl = 1                AND
                           crabttl.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crabttl THEN
            DO:
                
               IF  brapttl.cdgraupr = 1 OR brapttl.cdgraupr = 4  THEN
                   DO:
                      /** Verifica se estado civil do 1 titular permite
                          conjuge **/
                      FIND craxttl WHERE 
                                   craxttl.cdcooper = brapttl.cdcooper AND
                                   craxttl.nrdconta = brapttl.nrdconta AND
                                   craxttl.idseqttl = 1 
                                   NO-LOCK NO-ERROR.

                      IF  AVAILABLE craxttl THEN
                          DO:
                             IF  craxttl.cdestcvl = 2  OR /* COMUNHAO UNIV. */
                                 craxttl.cdestcvl = 3  OR /* COMUNHAO PARC  */
                                 craxttl.cdestcvl = 4  OR /* SEP. DE BENS   */
                                 craxttl.cdestcvl = 8  OR /* CAS REG TOTAL  */
                                 craxttl.cdestcvl = 9  OR /* REG.MISTO/ESPEC.*/
                                 craxttl.cdestcvl = 11 OR /* PART.FINAL AQUES*/
                                 craxttl.cdestcvl = 12 THEN /* UNIAO ESTAVEL */
                                 DO:
                                     /* Verifica estado civil do cooperado */
                                    IF  crabttl.cdestcvl = 2  OR 
                                        crabttl.cdestcvl = 3  OR 
                                        crabttl.cdestcvl = 4  OR 
                                        crabttl.cdestcvl = 8  OR 
                                        crabttl.cdestcvl = 9  OR 
                                        crabttl.cdestcvl = 11 OR 
                                        crabttl.cdestcvl = 12 THEN 
                                        DO:
                                           RUN Atualiza_Conjuge
                                               ( INPUT brapttl.cdcooper,
                                                 INPUT brapttl.nrdconta,
                                                 INPUT brapttl.idseqttl,
                                                 INPUT par_cddopcao,
                                                 INPUT par_grescola,
                                                 INPUT YES,
                                                 BUFFER crabttl,
                                                OUTPUT par_cdcritic,
                                                OUTPUT par_dscritic ).

                                           IF  par_cdcritic <> 0 OR 
                                               par_dscritic <> "" THEN
                                               UNDO Inclusao, LEAVE Inclusao.
                                        END.
                                 END.
                          END.
                   END.
               ELSE
                   DO:
                      IF  crabttl.cdestcvl = 2  OR 
                          crabttl.cdestcvl = 3  OR 
                          crabttl.cdestcvl = 4  OR 
                          crabttl.cdestcvl = 8  OR 
                          crabttl.cdestcvl = 9  OR 
                          crabttl.cdestcvl = 11 OR 
                          crabttl.cdestcvl = 12 THEN
                          DO:
                             /* Cria conjuge sem informacoes */ 
                             ContadorCje: DO aux_contador = 1 TO 10:
    
                                 FIND crapcje WHERE
                                      crapcje.cdcooper = brapttl.cdcooper AND
                                      crapcje.nrdconta = brapttl.nrdconta AND
                                      crapcje.idseqttl = brapttl.idseqttl 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                                 IF  NOT AVAILABLE crapcje THEN
                                     DO:
                                        IF  LOCKED(crapcje) THEN
                                            DO:
                                                IF  aux_contador = 10 THEN
                                                    DO:
                                                       par_cdcritic = 72.
                                                       LEAVE ContadorCje.
                                                    END.
                                                ELSE 
                                                    DO: 
                                                       PAUSE 1 NO-MESSAGE.
                                                       NEXT ContadorCje.
                                                    END.
                                            END.
                                        ELSE 
                                            DO:
                                               CREATE crapcje.
                                               ASSIGN 
                                               crapcje.cdcooper = 
                                                   brapttl.cdcooper
                                               crapcje.nrdconta = 
                                                   brapttl.nrdconta
                                               crapcje.idseqttl = 
                                                   brapttl.idseqttl.
                                               VALIDATE crapcje.
                                               LEAVE ContadorCje.
                                            END.
                                     END.
                                 ELSE
                                     LEAVE ContadorCje.
                             END. /* ContadorCje */
    
                             IF  par_cdcritic <> 0 THEN
                                 UNDO Inclusao, LEAVE Inclusao.
                          END.
                   END.
            END.
        ELSE
            DO:
               IF  brapttl.cdgraupr = 1 OR brapttl.cdgraupr = 4  THEN
                   DO: 
                      /** Nao existe conta na cooperativa 
                          onde CPF informado seje de 1 titular  **/

                      RUN Atualiza_Conjuge
                          ( INPUT brapttl.cdcooper,
                            INPUT brapttl.nrdconta,
                            INPUT brapttl.idseqttl,
                            INPUT par_cddopcao,
                            INPUT par_grescola,
                            INPUT FALSE,
                            BUFFER brapttl,
                           OUTPUT par_cdcritic,
                           OUTPUT par_dscritic ).

                      IF  par_cdcritic <> 0 OR par_dscritic <> "" THEN
                          UNDO Inclusao, LEAVE Inclusao.
                   END.                  
               ELSE 
                   IF brapttl.cdestcvl = 2  OR 
                      brapttl.cdestcvl = 3  OR 
                      brapttl.cdestcvl = 4  OR 
                      brapttl.cdestcvl = 8  OR 
                      brapttl.cdestcvl = 9  OR 
                      brapttl.cdestcvl = 11 OR 
                      brapttl.cdestcvl = 12 THEN 
                   DO:
                      /* Cria conjuge sem informacoes */ 
                      ContadorCje: DO aux_contador = 1 TO 10:
    
                          FIND crapcje WHERE
                               crapcje.cdcooper = brapttl.cdcooper AND
                               crapcje.nrdconta = brapttl.nrdconta AND
                               crapcje.idseqttl = brapttl.idseqttl 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                          IF  NOT AVAILABLE crapcje THEN
                              DO:
                                 IF  LOCKED(crapcje) THEN
                                     DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                par_cdcritic = 72.
                                                LEAVE ContadorCje.
                                             END.
                                         ELSE 
                                             DO: 
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT ContadorCje.
                                             END.
                                     END.
                                 ELSE 
                                     DO:
                                        CREATE crapcje.
                                        ASSIGN 
                                           crapcje.cdcooper = brapttl.cdcooper
                                           crapcje.nrdconta = brapttl.nrdconta
                                           crapcje.idseqttl = brapttl.idseqttl.
                                        VALIDATE crapcje.
                                        LEAVE ContadorCje.
                                     END.
                              END.
                          ELSE
                              LEAVE ContadorCje.
                      END. /* ContadorCje */
    
                       IF  par_cdcritic <> 0 THEN
                           UNDO Inclusao, LEAVE Inclusao.
                   END.
            END.
        
        /*Alteração (Gabriel/DB1)*/
        IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
            RUN sistema/generico/procedures/b1wgen0077.p 
                PERSISTENT SET h-b1wgen0077.
        
        RUN Recebe_Dados IN h-b1wgen0077
            ( INPUT brapttl.cdcooper,
              INPUT brapttl.nrdconta,
              INPUT par_nrcpfcgc,
              INPUT brapttl.idseqttl,
              INPUT par_cdoperad,
              INPUT par_nmdatela,
              INPUT par_dtmvtolt,
              INPUT par_cdagenci,
              INPUT par_nrdcaixa, 
              INPUT par_idorigem,
              INPUT FALSE, /*par_flgerlog*/
             OUTPUT par_cdcritic,
             OUTPUT par_dscritic ) .

        IF  VALID-HANDLE(h-b1wgen0077) THEN
            DELETE OBJECT h-b1wgen0077.
        
        IF  RETURN-VALUE <> "OK" THEN
            UNDO Inclusao, LEAVE Inclusao.
        
        ASSIGN 
            par_cdcritic = 0 
            par_dscritic = ""
            aux_returnvl = "OK".

        LEAVE Inclusao.
    END.
    
    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    RELEASE crabttl.
    RELEASE craxttl.
    RELEASE crabass.
    RELEASE crapcje.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".
    
    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Grava_Alteracao:

    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_grescola AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                     NO-UNDO.
    DEF  PARAM BUFFER brapass FOR crapass.
    DEF  PARAM BUFFER brapttl FOR crapttl.

    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.
    DEF VAR aux_dtaltera AS DATE                              NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                              NO-UNDO.
    DEF VAR aux_contador AS INTE                              NO-UNDO.
    DEF VAR aux_contado2 AS INTEGER                           NO-UNDO.
    DEF VAR vr_cdcooper  LIKE   crapcop.cdcooper              NO-UNDO.
    DEF VAR vr_nrdconta  LIKE   crapass.nrdconta              NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER crafttl FOR crapttl.
    DEF BUFFER craxttl FOR crapttl.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabcje FOR crapcje.
    DEF BUFFER craxcje FOR crapcje.
       
    ASSIGN 
        par_dscritic = "Erro na Alteracao dos dados".
        aux_returnvl = "NOK".
   
    Alteracao: DO ON ERROR UNDO Alteracao, LEAVE Alteracao:
        /*** Busca conta ativa mais atual do cooperado ***/
        ASSIGN 
            aux_dtaltera = 01/01/0001
            aux_nrdconta = 0.
                                                  
        /* verificar se o cpf é informado é titular principal em alguma conta
        */
        FOR EACH crabttl WHERE crabttl.cdcooper = brapttl.cdcooper AND
                               crabttl.nrcpfcgc = par_nrcpfcgc     AND     
                               crabttl.idseqttl = 1 
                               NO-LOCK, 
            
            FIRST crabass  WHERE crabass.cdcooper = crabttl.cdcooper AND
                                 crabass.nrdconta = crabttl.nrdconta AND
                                 crabass.dtdemiss = ?  
                                 NO-LOCK:
                               
            /** Ignora conta aplicacao **/
            IF  CAN-DO( "6,7,17,18",STRING(crabass.cdtipcta))  THEN
                NEXT.

            FIND LAST crapalt WHERE 
                      crapalt.cdcooper = crabass.cdcooper AND
                      crapalt.nrdconta = crabass.nrdconta 
                      NO-LOCK NO-ERROR.
            
            IF  AVAIL crapalt THEN
                DO:   
                    IF  crapalt.dtaltera > aux_dtaltera THEN
                        DO:  
                            ASSIGN  aux_nrdconta = crapalt.nrdconta
                                    aux_dtaltera = crapalt.dtaltera.
                        END.
                END.
            ELSE
                IF  aux_nrdconta = 0 THEN
                    ASSIGN aux_nrdconta = crabass.nrdconta.
                 
        END.        
        
        
        FIND crabttl WHERE crabttl.cdcooper = brapttl.cdcooper AND
                           crabttl.nrcpfcgc = par_nrcpfcgc     AND
                           crabttl.idseqttl = 1                AND
                           crabttl.nrdconta = aux_nrdconta
                           NO-LOCK NO-ERROR.
        
        IF  AVAILABLE crabttl AND brapttl.idseqttl <> 1 THEN
            DO: 
               /*** Verifica se titular pode ter conjuge ***/
               IF  brapttl.cdgraupr = 1 OR brapttl.cdgraupr = 4 THEN
                   DO:
                      
                      FIND craxttl WHERE 
                                   craxttl.cdcooper = brapttl.cdcooper AND
                                   craxttl.nrdconta = brapttl.nrdconta AND
                                   craxttl.idseqttl = 1 
                                   NO-LOCK NO-ERROR.
                      
                      IF  AVAILABLE craxttl THEN
                          DO:
                             IF  craxttl.cdestcvl = 2  OR /* COMUNHAO UNIVER */
                                 craxttl.cdestcvl = 3  OR /* COMUNHAO PARCIAL*/
                                 craxttl.cdestcvl = 4  OR /* SEPAR.DE BENS   */
                                 craxttl.cdestcvl = 8  OR /* CAS REG.TOTAL   */
                                 craxttl.cdestcvl = 9  OR /* REG.MISTO/ESPEC.*/
                                 craxttl.cdestcvl = 11 OR /* PART.FINAL AQUES*/
                                 craxttl.cdestcvl = 12 THEN /* UNIAO ESTAVEL */
                                 DO:
                                    /* Verifica estado civil do cooperado */
                                    IF  crabttl.cdestcvl = 2  OR 
                                        crabttl.cdestcvl = 3  OR 
                                        crabttl.cdestcvl = 4  OR 
                                        crabttl.cdestcvl = 8  OR 
                                        crabttl.cdestcvl = 9  OR 
                                        crabttl.cdestcvl = 11 OR 
                                        crabttl.cdestcvl = 12 THEN 
                                        DO:
                                            RUN Atualiza_Conjuge
                                                ( INPUT brapttl.cdcooper,
                                                  INPUT brapttl.nrdconta,
                                                  INPUT brapttl.idseqttl,
                                                  INPUT par_cddopcao,
                                                  INPUT par_grescola,
                                                  INPUT TRUE,
                                                  BUFFER crabttl,
                                                 OUTPUT par_cdcritic,
                                                 OUTPUT par_dscritic ).

                                            IF par_cdcritic <> 0 OR 
                                               par_dscritic <> "" THEN
                                               UNDO Alteracao, LEAVE Alteracao.
                                        END.
                                 END.
                          END. /* AVAILABLE craxttl */
                   END.
               ELSE  
                   DO: 
                       
                      /** Exclui conjuge do titular caso seje CONJUGE do
                          1 titular e parentesco tenha sido alterado. **/

                      ContadorCje: DO aux_contador = 1 TO 10:
    
                          FIND crapcje WHERE  
                                       crapcje.cdcooper = brapttl.cdcooper AND
                                       crapcje.nrdconta = brapttl.nrdconta AND
                                       crapcje.idseqttl = brapttl.idseqttl 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                          IF  NOT AVAILABLE crapcje THEN
                              DO:
                                 IF  LOCKED(crapcje) THEN
                                     DO:
                                        IF  aux_contador = 10 THEN
                                            DO:
                                               ASSIGN par_cdcritic = 72.
                                               LEAVE ContadorCje.
                                            END.
                                        ELSE 
                                            DO: 
                                               PAUSE 1 NO-MESSAGE.
                                               NEXT ContadorCje.
                                            END.
                                     END.
                                 ELSE 
                                     LEAVE ContadorCje.
                              END.
                          ELSE
                              LEAVE ContadorCje.
                      END.
    
                      IF  par_cdcritic <> 0 THEN
                          UNDO Alteracao, LEAVE Alteracao.
                        
                      IF  AVAILABLE crapcje AND 
                          crapcje.nrctacje = brapttl.nrdconta THEN
                          DELETE crapcje.
                   END.   
            END.     /** Fim Avail crabttl **/
        
        IF  brapttl.cdgraupr = 1 OR brapttl.cdgraupr = 4  THEN
            DO:
               
               ContadorCje: DO aux_contador = 1 TO 10:

                   FIND crapcje WHERE crapcje.cdcooper = brapttl.cdcooper AND
                                      crapcje.nrdconta = brapttl.nrdconta AND
                                      crapcje.idseqttl = 1 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                   IF  NOT AVAILABLE crapcje THEN
                       DO:
                          IF  LOCKED(crapcje) THEN
                              DO:
                                 IF  aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorCje.
                                     END.
                                 ELSE 
                                     DO: 
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorCje.
                                     END.
                              END.
                          ELSE 
                              LEAVE ContadorCje.
                       END.
                   ELSE
                       LEAVE ContadorCje.
               END.
               
               IF  par_cdcritic <> 0 THEN
                   UNDO Alteracao, LEAVE Alteracao.
               
               IF  AVAILABLE crapcje THEN
                   DO:
                      ASSIGN
                                              /* guardar o nrdconta no qual o cpf/cnpj é titular 
                                                 principal, caso exista, senao salvar 0 */ 
                          crapcje.nrctacje = (IF AVAILABLE crabttl THEN crabttl.nrdconta
                                              ELSE 0)
                          crapcje.nrcpfcjg = DEC(par_nrcpfcgc)
                          crapcje.nmconjug = CAPS(brapttl.nmextttl)
                          crapcje.tpdoccje = CAPS(brapttl.tpdocttl)
                          crapcje.nrdoccje = CAPS(brapttl.nrdocttl)
                          crapcje.idorgexp = brapttl.idorgexp
                          crapcje.cdufdcje = CAPS(brapttl.cdufdttl)
                          crapcje.dtemdcje = brapttl.dtemdttl
                          crapcje.dtnasccj = brapttl.dtnasttl
                          crapcje.grescola = brapttl.grescola
                          crapcje.cdfrmttl = brapttl.cdfrmttl
                          crapcje.cdnatopc = brapttl.cdnatopc
                          crapcje.cdocpcje = brapttl.cdocpttl
                          crapcje.tpcttrab = brapttl.tpcttrab
                          crapcje.nmextemp = brapttl.nmextemp
                          crapcje.nrdocnpj = brapttl.nrcpfemp
                          crapcje.dsproftl = brapttl.dsproftl
                          crapcje.cdnvlcgo = brapttl.cdnvlcgo
                          crapcje.cdturnos = brapttl.cdturnos
                          crapcje.dtadmemp = brapttl.dtadmemp
                          crapcje.vlsalari = brapttl.vlsalari.
                   END.
               
               FIND craxttl WHERE craxttl.cdcooper = brapttl.cdcooper AND
                                  craxttl.nrdconta = brapttl.nrdconta AND
                                  craxttl.idseqttl = 1 
                                  NO-LOCK NO-ERROR.

               IF  AVAILABLE craxttl THEN
                   DO:
                      IF  craxttl.cdestcvl = 1 OR   /* SOLTEIRO */
                          craxttl.cdestcvl = 5 OR   /* VIUVO */
                          craxttl.cdestcvl = 6 OR   /* SEPARADO */
                          craxttl.cdestcvl = 7 THEN /* DIVORCIADO*/
                          DO:
                             ASSIGN
                                 par_dscritic = "Estado civil do primeiro " +
                                                "titular nao permite conjuge.".
                             UNDO Alteracao, LEAVE Alteracao.
                          END.
                   
                      ContadorCje: DO aux_contador = 1 TO 10:

                          FIND crapcje WHERE 
                                       crapcje.cdcooper = craxttl.cdcooper AND
                                       crapcje.nrdconta = craxttl.nrdconta AND
                                       crapcje.idseqttl = brapttl.idseqttl
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF  NOT AVAILABLE crapcje THEN
                              DO:
                                 IF  LOCKED(crapcje) THEN
                                     DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                ASSIGN par_cdcritic = 72.
                                                LEAVE ContadorCje.
                                             END.
                                         ELSE 
                                             DO: 
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT ContadorCje.
                                             END.
                                     END.
                                 ELSE 
                                     LEAVE ContadorCje.
                              END.
                          ELSE
                              LEAVE ContadorCje.
                      END.

                      IF  par_cdcritic <> 0 THEN
                          UNDO Alteracao, LEAVE Alteracao.

                      IF  AVAILABLE crapcje THEN
                          DO:
                          
                             ASSIGN
                                 crapcje.nrctacje = craxttl.nrdconta
                                 crapcje.nrcpfcjg = craxttl.nrcpfcgc
                                 crapcje.nmconjug = CAPS(craxttl.nmextttl)
                                 crapcje.tpdoccje = CAPS(craxttl.tpdocttl)
                                 crapcje.nrdoccje = CAPS(craxttl.nrdocttl)
                                 crapcje.idorgexp = craxttl.idorgexp
                                 crapcje.cdufdcje = CAPS(craxttl.cdufdttl)
                                 crapcje.dtemdcje = craxttl.dtemdttl
                                 crapcje.dtnasccj = craxttl.dtnasttl
                                 crapcje.grescola = craxttl.grescola
                                 crapcje.cdfrmttl = craxttl.cdfrmttl
                                 crapcje.cdnatopc = craxttl.cdnatopc
                                 crapcje.cdocpcje = craxttl.cdocpttl
                                 crapcje.tpcttrab = craxttl.tpcttrab
                                 crapcje.nmextemp = craxttl.nmextemp
                                 crapcje.nrdocnpj = craxttl.nrcpfemp
                                 crapcje.dsproftl = craxttl.dsproftl
                                 crapcje.cdnvlcgo = craxttl.cdnvlcgo
                                 crapcje.cdturnos = craxttl.cdturnos
                                 crapcje.dtadmemp = craxttl.dtadmemp
                                 crapcje.vlsalari = craxttl.vlsalari.
                          END.
                   END.
            
            END.
        ELSE
            DO:
               
               /** Exclui conjuge do titular caso parentesco que
                   antes era CONJUGE tenha sido alterado **/
               ContadorCje: DO aux_contador = 1 TO 10:
               
                   FIND crapcje WHERE crapcje.cdcooper = brapttl.cdcooper AND
                                      crapcje.nrdconta = brapttl.nrdconta AND
                                      crapcje.idseqttl = brapttl.idseqttl
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
               
                   IF  NOT AVAILABLE crapcje THEN
                       DO:
                          IF  LOCKED(crapcje) THEN
                              DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorCje.
                                      END.
                                  ELSE 
                                      DO: 
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorCje.
                                      END.
                              END.
                          ELSE 
                              LEAVE ContadorCje.
                       END.
                   ELSE
                       LEAVE ContadorCje.
               END.
               
               IF  par_cdcritic <> 0 THEN
                   UNDO Alteracao, LEAVE Alteracao.

               IF  AVAIL crapcje AND crapcje.nrctacje = brapttl.nrdconta THEN
                   DELETE crapcje.
            END.
        
        ContadorCje: DO aux_contador = 1 TO 10:
            
            FIND crapcje WHERE crapcje.cdcooper = brapttl.cdcooper AND
                               crapcje.nrdconta = brapttl.nrdconta AND
                               crapcje.idseqttl = brapttl.idseqttl
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcje THEN
                DO:
                   IF  LOCKED(crapcje) THEN
                       DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                  ASSIGN par_cdcritic = 72.
                                  LEAVE ContadorCje.
                               END.
                           ELSE 
                               DO: 
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorCje.
                               END.
                       END.
                   ELSE 
                       LEAVE ContadorCje.
                END.
            ELSE
                LEAVE ContadorCje.
        END.

        IF  par_cdcritic <> 0 THEN
            UNDO Alteracao, LEAVE Alteracao.
        
        IF  brapttl.cdestcvl = 1   OR    /* SOLTEIRO */
            brapttl.cdestcvl = 5   OR    /* VIUVO */
            brapttl.cdestcvl = 6   OR    /* SEPARADO */
            brapttl.cdestcvl = 7   THEN  /* DIVORCIADO */
            DO: 
                IF  AVAILABLE crapcje THEN
                    DELETE crapcje.
            END.
        ELSE
            DO:
               /** Se parentesco for 1 ou 4 cria conjuge com
                   informacoes do 1 titular senao cria conjuge 
                   sem informacoes    **/
               IF  brapttl.cdgraupr <> 1 AND brapttl.cdgraupr <> 4  THEN
                   DO:
                      IF  NOT AVAILABLE crapcje THEN
                          DO:
                              CREATE crapcje.
                              ASSIGN 
                                  crapcje.cdcooper = brapttl.cdcooper
                                  crapcje.nrdconta = brapttl.nrdconta
                                  crapcje.idseqttl = brapttl.idseqttl.
                              VALIDATE crapcje.
                          END.
                   END.
               ELSE
                   DO: 
                      FIND craxttl WHERE 
                                   craxttl.cdcooper = brapttl.cdcooper AND
                                   craxttl.nrdconta = brapttl.nrdconta AND
                                   craxttl.idseqttl = 1 
                                   NO-LOCK NO-ERROR.
                      
                      /** Cria conjuge do titular atual com
                          informacoes do 1 titular **/
                      IF  AVAILABLE craxttl THEN
                          DO:
                             IF  NOT AVAILABLE crapcje THEN
                                 DO:
                                   
                                    CREATE crapcje.
                                    ASSIGN
                                        crapcje.cdcooper = brapttl.cdcooper
                                        crapcje.nrdconta = craxttl.nrdconta
                                        crapcje.idseqttl = brapttl.idseqttl.
                                 END.
                             
                             ASSIGN  
                                 crapcje.cdcooper = brapttl.cdcooper
                                 crapcje.nrdconta = craxttl.nrdconta
                                 crapcje.nrctacje = craxttl.nrdconta 
                                 crapcje.nrcpfcjg = craxttl.nrcpfcgc
                                 crapcje.idseqttl = brapttl.idseqttl
                                 crapcje.nmconjug = CAPS(craxttl.nmextttl)
                                 crapcje.tpdoccje = CAPS(craxttl.tpdocttl)
                                 crapcje.nrdoccje = CAPS(craxttl.nrdocttl)
                                 crapcje.idorgexp = craxttl.idorgexp
                                 crapcje.cdufdcje = CAPS(craxttl.cdufdttl)
                                 crapcje.dtemdcje = craxttl.dtemdttl
                                 crapcje.dtnasccj = craxttl.dtnasttl
                                 crapcje.grescola = craxttl.grescola
                                 crapcje.cdfrmttl = craxttl.cdfrmttl
                                 crapcje.cdnatopc = craxttl.cdnatopc
                                 crapcje.cdocpcje = craxttl.cdocpttl
                                 crapcje.tpcttrab = craxttl.tpcttrab
                                 crapcje.nmextemp = craxttl.nmextemp
                                 crapcje.nrdocnpj = craxttl.nrcpfemp
                                 crapcje.dsproftl = craxttl.dsproftl
                                 crapcje.cdnvlcgo = craxttl.cdnvlcgo
                                 crapcje.cdturnos = craxttl.cdturnos
                                 crapcje.dtadmemp = craxttl.dtadmemp
                                 crapcje.vlsalari = craxttl.vlsalari.
                             VALIDATE crapcje.
                          END.
                   END.
            END.
        
        /* Se for o 1o titular, atualiza a documentacao,
           dados do conjuge, naturalidade, nacionalidade, sexo, nasc. e 
           folhas do talao na crapass */
        IF  brapttl.idseqttl = 1   THEN
            DO:
               ASSIGN 
                   brapass.dtcnscpf = brapttl.dtcnscpf
                   brapass.cdsitcpf = brapttl.cdsitcpf
                   brapass.tpdocptl = brapttl.tpdocttl
                   brapass.nrdocptl = brapttl.nrdocttl
                   brapass.idorgexp = brapttl.idorgexp 
                   brapass.cdufdptl = brapttl.cdufdttl
                   brapass.dtemdptl = brapttl.dtemdttl
                   brapass.cdnacion = brapttl.cdnacion    
                   /* Retirado campo brapass.dsnatura */       
                   brapass.cdsexotl = brapttl.cdsexotl
                   brapass.dtnasctl = brapttl.dtnasttl
                   brapass.qtfoltal = par_qtfoltal.

               /* Atualiza os dados do conjuge */
               IF   brapttl.cdestcvl = 1   OR    /* SOLTEIRO */
                    brapttl.cdestcvl = 5   OR    /* VIUVO */
                    brapttl.cdestcvl = 6   OR    /* SEPARADO */
                    brapttl.cdestcvl = 7   THEN  /* DIVORCIADO */                    
               RELEASE crabttl. 
                                          
               /** Ignora replicacao para conta aplicacao **/
               IF  NOT CAN-DO("6,7,17,18",STRING(brapass.cdtipcta))  THEN
                   DO:
                       /** Atualiza titulares de outras contas onde cpf seja o
                           mesmo do primeiro titular desta conta.         **/
                       FOR EACH crabttl WHERE 
                                crabttl.cdcooper = brapttl.cdcooper AND
                                crabttl.idseqttl <> 1               AND
                                crabttl.nrcpfcgc = brapttl.nrcpfcgc NO-LOCK:
                           
                           ContadorTtl: DO aux_contador = 1 TO 10:
        
                               FIND crafttl WHERE ROWID(crafttl) = ROWID(crabttl)
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                               IF  NOT AVAILABLE crafttl THEN
                                   DO:
                                      IF  LOCKED(crafttl) THEN
                                          DO:
                                              IF  aux_contador = 10 THEN
                                                  DO:
                                                     ASSIGN par_cdcritic = 72.
                                                     LEAVE ContadorTtl.
                                                  END.
                                              ELSE 
                                                  DO: 
                                                     PAUSE 1 NO-MESSAGE.
                                                     NEXT ContadorTtl.
                                                  END.
                                          END.
                                      ELSE 
                                          LEAVE ContadorTtl.
                                   END.
                               ELSE
                                   DO:
                                      ASSIGN  
                                          crafttl.nmextttl = brapttl.nmextttl
                                          crafttl.dtcnscpf = brapttl.dtcnscpf   
                                          crafttl.cdsitcpf = brapttl.cdsitcpf   
                                          crafttl.tpdocttl = brapttl.tpdocttl
                                          crafttl.nrdocttl = brapttl.nrdocttl  
                                          crafttl.idorgexp = brapttl.idorgexp  
                                          crafttl.cdufdttl = brapttl.cdufdttl
                                          crafttl.dtemdttl = brapttl.dtemdttl  
                                          crafttl.dtnasttl = brapttl.dtnasttl
                                          crafttl.cdsexotl = brapttl.cdsexotl  
                                          crafttl.tpnacion = brapttl.tpnacion  
                                          crafttl.cdnacion = brapttl.cdnacion  
                                          crafttl.dsnatura = brapttl.dsnatura
                                          crafttl.cdufnatu = brapttl.cdufnatu
                                          crafttl.inhabmen = brapttl.inhabmen  
                                          crafttl.dthabmen = brapttl.dthabmen  
                                          crafttl.cdestcvl = brapttl.cdestcvl  
                                          crafttl.grescola = brapttl.grescola
                                          crafttl.cdfrmttl = brapttl.cdfrmttl
                                          crafttl.nmtalttl = brapttl.nmtalttl.
                                          
                                      ContadorCje1: DO aux_contado2 = 1 TO 10:
    
                                          FIND crapcje WHERE crapcje.cdcooper = crabttl.cdcooper AND
                                                             crapcje.nrdconta = crabttl.nrdconta AND
                                                             crapcje.idseqttl = crabttl.idseqttl
                                                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                        
                                          IF  NOT AVAILABLE crapcje THEN
                                              DO:
                                                 IF  LOCKED(crapcje) THEN
                                                     DO:
                                                         IF  aux_contado2 = 10 THEN
                                                             DO:
                                                                ASSIGN par_cdcritic = 72.
                                                                LEAVE ContadorCje1.
                                                             END.
                                                         ELSE 
                                                             DO: 
                                                                PAUSE 1 NO-MESSAGE.
                                                                NEXT ContadorCje1.
                                                             END.
                                                     END.
                                                 ELSE 
                                                     LEAVE ContadorCje1.
                                              END.
                                          ELSE
                                              DO:
                                                  
                                                  DELETE crapcje.
                                                  RELEASE crapcje.
                                                  
                                                  LEAVE ContadorCje1.
                                              END.                   
                                      END.

                                      IF  par_cdcritic <> 0 THEN
                                          UNDO Alteracao, LEAVE Alteracao.
                                      


                                      LEAVE ContadorTtl.
                                   END.
                                   
                           END. /* ContadorTtl */
        
                           RELEASE crafttl.

        
                           IF  par_cdcritic <> 0 THEN
                               UNDO Alteracao, LEAVE Alteracao.
                       END.
                
                       /*******************************************************/
                       
                       FOR EACH crabcje WHERE
                                crabcje.cdcooper  = brapttl.cdcooper AND
                                crabcje.nrcpfcjg  = brapttl.nrcpfcgc 
                                NO-LOCK:
                           
                           ContadorRepli: DO aux_contador = 1 TO 10:
                            
                               FIND crapcje WHERE ROWID(crapcje) = ROWID(crabcje)
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                               IF  NOT AVAILABLE crapcje THEN
                                   DO:
                                      IF  LOCKED(crapcje) THEN
                                          DO:
                                              IF  aux_contador = 10 THEN
                                                  DO:
                                                     ASSIGN par_cdcritic = 72.
                                                     LEAVE ContadorRepli.
                                                  END.
                                              ELSE 
                                                  DO: 
                                                     PAUSE 1 NO-MESSAGE.
                                                     NEXT ContadorRepli.
                                                  END.
                                          END.
                                      ELSE 
                                          LEAVE ContadorRepli.
                                   END.
                               ELSE
                                   DO: 

                                       ASSIGN
                                           crapcje.nmconjug = CAPS(brapttl.nmextttl)
                                           crapcje.tpdoccje = CAPS(brapttl.tpdocttl)
                                           crapcje.nrdoccje = CAPS(brapttl.nrdocttl)
                                           crapcje.idorgexp = brapttl.idorgexp
                                           crapcje.cdufdcje = CAPS(brapttl.cdufdttl)
                                           crapcje.dtemdcje = brapttl.dtemdttl
                                           crapcje.dtnasccj = brapttl.dtnasttl
                                           crapcje.grescola = brapttl.grescola
                                           crapcje.cdfrmttl = brapttl.cdfrmttl
                                           crapcje.cdnatopc = brapttl.cdnatopc
                                           crapcje.cdocpcje = brapttl.cdocpttl
                                           crapcje.tpcttrab = brapttl.tpcttrab
                                           crapcje.nmextemp = brapttl.nmextemp
                                           crapcje.nrdocnpj = brapttl.nrcpfemp
                                           crapcje.dsproftl = brapttl.dsproftl
                                           crapcje.cdnvlcgo = brapttl.cdnvlcgo
                                           crapcje.cdturnos = brapttl.cdturnos
                                           crapcje.dtadmemp = brapttl.dtadmemp
                                           crapcje.vlsalari = brapttl.vlsalari.
        
                                      LEAVE ContadorRepli.
                                   END.
                                   
                           END. /* ContadorRepli */
                            
                           RELEASE crapcje.
        
                           IF  par_cdcritic <> 0 THEN
                               UNDO Alteracao, LEAVE Alteracao.
                       END.                                    
                       
                   END.
               /*******************************************************/
               
            END.
        
        ASSIGN 
            par_dscritic = ""
            aux_returnvl = "OK".

        LEAVE Alteracao.
    END.
    
    RELEASE crabttl.
    RELEASE crafttl.
    RELEASE craxttl.
    RELEASE crabass.
    RELEASE crapcje.
    
    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Atualiza_Conjuge:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_grescola AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_flgexist AS LOG                      NO-UNDO.

    DEF PARAM BUFFER brapttl FOR crapttl.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_contador AS INTE                              NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.

    DEF BUFFER craxttl FOR crapttl.

    Conjuge: DO TRANSACTION
        ON ERROR  UNDO Conjuge, LEAVE Conjuge
        ON QUIT   UNDO Conjuge, LEAVE Conjuge
        ON STOP   UNDO Conjuge, LEAVE Conjuge
        ON ENDKEY UNDO Conjuge, LEAVE Conjuge:

        ContadorCje: DO aux_contador = 1 TO 10:

            FIND crapcje WHERE crapcje.cdcooper = par_cdcooper AND
                               crapcje.nrdconta = par_nrdconta AND
                               crapcje.idseqttl = 1 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapcje THEN
                DO:
                   IF  LOCKED(crapcje) THEN
                       DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                  ASSIGN par_cdcritic = 72.
                                  LEAVE ContadorCje.
                               END.
                           ELSE 
                               DO: 
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorCje.
                               END.
                       END.
                   ELSE 
                       LEAVE ContadorCje.
                END.
            ELSE
                LEAVE ContadorCje.
        END.

        IF  par_cdcritic <> 0 THEN
            UNDO Conjuge, LEAVE Conjuge.

        IF  AVAILABLE crapcje THEN
            DO:   
                ASSIGN  
                    crapcje.nrctacje = IF par_flgexist = FALSE THEN 0 
                                       ELSE brapttl.nrdconta
                    crapcje.nrcpfcjg = brapttl.nrcpfcgc
                    crapcje.nmconjug = CAPS(brapttl.nmextttl)  
                    crapcje.tpdoccje = CAPS(brapttl.tpdocttl)  
                    crapcje.nrdoccje = CAPS(brapttl.nrdocttl)
                    crapcje.idorgexp = brapttl.idorgexp
                    crapcje.cdufdcje = CAPS(brapttl.cdufdttl)
                    crapcje.dtemdcje = brapttl.dtemdttl
                    crapcje.dtnasccj = brapttl.dtnasttl
                    crapcje.grescola = par_grescola 
                    crapcje.cdfrmttl = brapttl.cdfrmttl
                    crapcje.cdnatopc = brapttl.cdnatopc
                    crapcje.cdocpcje = brapttl.cdocpttl
                    crapcje.tpcttrab = brapttl.tpcttrab
                    crapcje.nmextemp = brapttl.nmextemp
                    crapcje.nrdocnpj = brapttl.nrcpfemp
                    crapcje.dsproftl = brapttl.dsproftl
                    crapcje.cdnvlcgo = brapttl.cdnvlcgo
                    crapcje.cdturnos = brapttl.cdturnos
                    crapcje.dtadmemp = brapttl.dtadmemp
                    crapcje.vlsalari = brapttl.vlsalari NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    DO:
                       ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                       UNDO Conjuge, LEAVE Conjuge.
                    END.
            END.

        FIND craxttl WHERE craxttl.cdcooper = par_cdcooper AND
                           craxttl.nrdconta = par_nrdconta AND
                           craxttl.idseqttl = 1 
                           NO-LOCK NO-ERROR.

        IF  AVAILABLE craxttl THEN
            DO:       
               IF  par_cddopcao = "I" THEN  /** Novo titular **/
                   DO:  
                      ContadorCje: DO aux_contador = 1 TO 10:

                          FIND crapcje WHERE
                                       crapcje.cdcooper = par_cdcooper     AND
                                       crapcje.nrdconta = craxttl.nrdconta AND
                                       crapcje.idseqttl = par_idseqttl
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                          IF  NOT AVAILABLE crapcje THEN
                              DO:
                                 IF  LOCKED(crapcje) THEN
                                     DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                ASSIGN par_cdcritic = 72.
                                                LEAVE ContadorCje.
                                             END.
                                         ELSE 
                                             DO: 
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT ContadorCje.
                                             END.
                                     END.
                                 ELSE 
                                     DO:
                                        CREATE crapcje.
                                        LEAVE ContadorCje.
                                     END.
                                     
                              END.
                          ELSE
                              LEAVE ContadorCje.
                      END.
    
                      IF  par_cdcritic <> 0 THEN
                          UNDO Conjuge, LEAVE Conjuge.

                      ASSIGN 
                          crapcje.cdcooper = par_cdcooper
                          crapcje.nrdconta = craxttl.nrdconta
                          crapcje.nrctacje = craxttl.nrdconta 
                          crapcje.nrcpfcjg = craxttl.nrcpfcgc
                          crapcje.idseqttl = par_idseqttl
                          crapcje.nmconjug = CAPS(craxttl.nmextttl)  
                          crapcje.tpdoccje = CAPS(craxttl.tpdocttl)  
                          crapcje.nrdoccje = CAPS(craxttl.nrdocttl)
                          crapcje.idorgexp = craxttl.idorgexp
                          crapcje.cdufdcje = CAPS(craxttl.cdufdttl)
                          crapcje.dtemdcje = craxttl.dtemdttl
                          crapcje.dtnasccj = craxttl.dtnasttl
                          crapcje.grescola = craxttl.grescola
                          crapcje.cdfrmttl = craxttl.cdfrmttl
                          crapcje.cdnatopc = craxttl.cdnatopc
                          crapcje.cdocpcje = craxttl.cdocpttl
                          crapcje.tpcttrab = craxttl.tpcttrab
                          crapcje.nmextemp = craxttl.nmextemp
                          crapcje.nrdocnpj = craxttl.nrcpfemp
                          crapcje.dsproftl = craxttl.dsproftl
                          crapcje.cdnvlcgo = craxttl.cdnvlcgo
                          crapcje.cdturnos = craxttl.cdturnos
                          crapcje.dtadmemp = craxttl.dtadmemp
                          crapcje.vlsalari = craxttl.vlsalari NO-ERROR.

                      IF  ERROR-STATUS:ERROR THEN
                          DO:
                             ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                             UNDO Conjuge, LEAVE Conjuge.
                          END.
                      VALIDATE crapcje.  
                   END.  /*** Fim novo titular "aux_flgnvttl" ***/
               ELSE
                   DO:  
                      ContadorCje: DO aux_contador = 1 TO 10:
                      
                          FIND crapcje WHERE 
                                       crapcje.cdcooper = par_cdcooper     AND
                                       crapcje.nrdconta = craxttl.nrdconta AND
                                       crapcje.idseqttl = par_idseqttl 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
                          IF  NOT AVAILABLE crapcje THEN
                              DO:
                                 IF  LOCKED(crapcje) THEN
                                     DO:
                                         IF  aux_contador = 10 THEN
                                             DO:
                                                ASSIGN par_cdcritic = 72.
                                                LEAVE ContadorCje.
                                             END.
                                         ELSE 
                                             DO: 
                                                PAUSE 1 NO-MESSAGE.
                                                NEXT ContadorCje.
                                             END.
                                     END.
                                 ELSE 
                                     LEAVE ContadorCje.
                              END.
                          ELSE
                              LEAVE ContadorCje.
                      END.
                      
                      IF  par_cdcritic <> 0 THEN
                       UNDO Conjuge, LEAVE Conjuge.

                      IF AVAIL crapcje THEN 
                         DO: 
                            ASSIGN crapcje.nrctacje = craxttl.nrdconta 
                                   crapcje.nrcpfcjg = craxttl.nrcpfcgc
                                   crapcje.nmconjug = CAPS(craxttl.nmextttl)  
                                   crapcje.tpdoccje = CAPS(craxttl.tpdocttl)  
                                   crapcje.nrdoccje = CAPS(craxttl.nrdocttl)
                                   crapcje.idorgexp = craxttl.idorgexp
                                   crapcje.cdufdcje = CAPS(craxttl.cdufdttl)
                                   crapcje.dtemdcje = craxttl.dtemdttl
                                   crapcje.dtnasccj = craxttl.dtnasttl
                                   crapcje.grescola = craxttl.grescola
                                   crapcje.cdfrmttl = craxttl.cdfrmttl
                                   crapcje.cdnatopc = craxttl.cdnatopc
                                   crapcje.cdocpcje = craxttl.cdocpttl
                                   crapcje.tpcttrab = craxttl.tpcttrab
                                   crapcje.nmextemp = craxttl.nmextemp
                                   crapcje.nrdocnpj = craxttl.nrcpfemp
                                   crapcje.dsproftl = craxttl.dsproftl
                                   crapcje.cdnvlcgo = craxttl.cdnvlcgo
                                   crapcje.cdturnos = craxttl.cdturnos
                                   crapcje.dtadmemp = craxttl.dtadmemp
                                   crapcje.vlsalari = craxttl.vlsalari 
                                   NO-ERROR.

                            IF  ERROR-STATUS:ERROR THEN
                                DO:
                                   par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                                   UNDO Conjuge, LEAVE Conjuge.
                                END.
                         END.
                   END.
            END.  

        ASSIGN 
            par_dscritic = ""
            aux_returnvl = "OK".

        LEAVE Conjuge.
    END.

    RELEASE crapcje.
    
    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".
    
    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                      NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                     NO-UNDO.
    DEF  INPUT PARAM par_cdgraupr LIKE crapttl.cdgraupr       NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_nmextttl LIKE crapttl.nmextttl       NO-UNDO.
    DEF  INPUT PARAM par_nrctattl LIKE crapttl.nrdconta       NO-UNDO.
    DEF  INPUT PARAM par_inpessoa LIKE crapttl.inpessoa       NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf LIKE crapttl.dtcnscpf       NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf LIKE crapttl.cdsitcpf       NO-UNDO.
    DEF  INPUT PARAM par_tpdocttl LIKE crapttl.tpdocttl       NO-UNDO.
    DEF  INPUT PARAM par_nrdocttl LIKE crapttl.nrdocttl       NO-UNDO.
    DEF  INPUT PARAM par_cdoedttl AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_cdufdttl LIKE crapttl.cdufdttl       NO-UNDO.
    DEF  INPUT PARAM par_dtemdttl LIKE crapttl.dtemdttl       NO-UNDO.
    DEF  INPUT PARAM par_dtnasttl LIKE crapttl.dtnasttl       NO-UNDO.
    DEF  INPUT PARAM par_cdsexotl LIKE crapttl.cdsexotl       NO-UNDO.
    DEF  INPUT PARAM par_tpnacion LIKE crapttl.tpnacion       NO-UNDO.
    DEF  INPUT PARAM par_cdnacion LIKE crapttl.cdnacion       NO-UNDO.
    DEF  INPUT PARAM par_dsnatura LIKE crapttl.dsnatura       NO-UNDO.
    DEF  INPUT PARAM par_cdufnatu LIKE crapttl.cdufnatu       NO-UNDO.
    DEF  INPUT PARAM par_inhabmen LIKE crapttl.inhabmen       NO-UNDO.
    DEF  INPUT PARAM par_dthabmen LIKE crapttl.dthabmen       NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl LIKE crapttl.cdestcvl       NO-UNDO.
    DEF  INPUT PARAM par_grescola LIKE crapttl.grescola       NO-UNDO.
    DEF  INPUT PARAM par_cdfrmttl LIKE crapttl.cdfrmttl       NO-UNDO.
    DEF  INPUT PARAM par_nmcertif AS CHAR                     NO-UNDO.
    DEF  INPUT PARAM par_nmtalttl LIKE crapttl.nmtalttl       NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal LIKE crapass.qtfoltal       NO-UNDO.
    DEF  INPUT PARAM par_verrespo AS LOG                      NO-UNDO.
    DEF  INPUT PARAM par_permalte AS LOG                      NO-UNDO.
    DEF  INPUT  PARAM TABLE FOR tt-resp.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.               
    DEF OUTPUT PARAM par_nrdeanos AS INT                      NO-UNDO.
    DEF OUTPUT PARAM par_nrdmeses AS INT                      NO-UNDO.
    DEF OUTPUT PARAM par_dsdidade AS CHAR                     NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                            NO-UNDO.
    DEF VAR aux_nrdeanos AS INTE                              NO-UNDO.
    DEF VAR aux_nrdmeses AS INTE                              NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                              NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                              NO-UNDO.
    DEF VAR aux_dtcadass AS DATE                              NO-UNDO.
    DEF VAR aux_geraerro AS LOG                               NO-UNDO.
	DEF VAR aux_nrcpfstl LIKE crapttl.nrcpfcgc				  NO-UNDO.
	DEF VAR aux_nrcpfttl LIKE crapttl.nrcpfcgc				  NO-UNDO.

    DEF VAR aux_idorgexp AS INT                               NO-UNDO.

    DEF VAR h-b1wgen0072 AS HANDLE                            NO-UNDO.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar dados da Identificacao"
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_retorno  = "NOK"
           aux_geraerro = FALSE.

     IF par_cddopcao = "PI" THEN
        DO:
           IF  VALID-HANDLE(h-b1wgen9999) THEN
               DELETE OBJECT h-b1wgen9999.
           
           RUN sistema/generico/procedures/b1wgen9999.p
               PERSISTENT SET h-b1wgen9999.
           
           /* validar pela procedure generica do b1wgen9999.p */
           RUN idade IN h-b1wgen9999 ( INPUT par_dtnasttl,
                                       INPUT par_dtmvtolt,
                                       OUTPUT par_nrdeanos,
                                       OUTPUT par_nrdmeses,
                                       OUTPUT par_dsdidade ).
           
           /* Sera realizada a validacao de emancipacao apenas para pessoas
             que tiverem o estado civil diferente dos apresentados na 
             condicao abaixo. Quando casado, a pessoa é automaticamente 
             emancipada.*/
           IF par_inpessoa = 1 AND 
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

           IF VALID-HANDLE(h-b1wgen9999) THEN
              DELETE OBJECT h-b1wgen9999.
           
           RETURN "OK".

        END.

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:

        EMPTY TEMP-TABLE tt-erro.

        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE OBJECT h-b1wgen9999.
           
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-b1wgen9999.
        
        /* validar pela procedure generica do b1wgen9999.p */
        RUN idade IN h-b1wgen9999 ( INPUT par_dtnasttl,
                                    INPUT par_dtmvtolt,
                                    OUTPUT aux_nrdeanos,
                                    OUTPUT aux_nrdmeses,
                                    OUTPUT aux_dsdidade ).

        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE OBJECT h-b1wgen9999.
        
        IF CAN-DO("2,3,4,8,9,11",STRING(par_cdestcvl)) AND
           par_inhabmen = 0                            AND
           par_dthabmen = ?                            AND 
           aux_nrdeanos < 18                           THEN
           DO:
               ASSIGN aux_dscritic = "Resp. Legal e data de emancipacao " + 
                                     "invalidos para estado civil.".

               LEAVE Valida.

           END.

        IF par_inhabmen = 1 THEN
           DO: 
               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE OBJECT h-b1wgen9999.
           
               RUN sistema/generico/procedures/b1wgen9999.p
                   PERSISTENT SET h-b1wgen9999.
           
               /* validar pela procedure generica do b1wgen9999.p */
               RUN idade IN h-b1wgen9999 ( INPUT par_dtnasttl,
                                           INPUT par_dtmvtolt,
                                           OUTPUT aux_nrdeanos,
                                           OUTPUT aux_nrdmeses,
                                           OUTPUT aux_dsdidade ).
               
               /* Sera realizada a validacao de emancipacao apenas para pessoas
                  que tiverem o estado civil diferente dos apresentados na 
                  condicao abaixo. Quando casado, a pessoa é automaticamente 
                  emancipada.*/
               IF par_inpessoa = 1 AND 
                  NOT CAN-DO("2,3,4,5,6,7,8,9,11",STRING(par_cdestcvl)) AND
                  (aux_nrdeanos < 16 OR aux_nrdeanos > 17) THEN
                  DO:
                      ASSIGN aux_dscritic = "Para emancipacao e necessario " + 
                                            "ter entre 16 e 18 anos.".

                      IF  VALID-HANDLE(h-b1wgen9999) THEN
                          DELETE OBJECT h-b1wgen9999.

                      LEAVE Valida.

                  END.

               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE OBJECT h-b1wgen9999.

           END.         

        IF par_inhabmen = 0 OR
           par_inhabmen = 2 THEN
           DO:
               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE OBJECT h-b1wgen9999.
           
               RUN sistema/generico/procedures/b1wgen9999.p
                   PERSISTENT SET h-b1wgen9999.
           
               /* validar pela procedure generica do b1wgen9999.p */
               RUN idade IN h-b1wgen9999 ( INPUT par_dtnasttl,
                                           INPUT par_dtmvtolt,
                                           OUTPUT par_nrdeanos,
                                           OUTPUT par_nrdmeses,
                                           OUTPUT par_dsdidade ).

               IF  VALID-HANDLE(h-b1wgen9999) THEN
                   DELETE OBJECT h-b1wgen9999.

           END.         

           
        IF  par_idseqttl > 4 THEN
            DO:
               ASSIGN aux_dscritic = "Sequencia do titular incorreta".
               LEAVE Valida.
            END.

        IF  NOT CAN-DO("1,2,3,4,6",STRING(par_cdgraupr,"9")) AND 
            (par_idseqttl = 1 AND par_cdgraupr <> 0)          THEN 
            DO:
               ASSIGN par_nmdcampo = "cdgraupr"
                      aux_cdcritic = 23.

               LEAVE Valida.
            END.
        
        IF  NOT CAN-DO("1,2,3,4,6",STRING(par_cdgraupr,"9")) AND 
            par_idseqttl <> 1 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdgraupr"
                   aux_cdcritic = 23.
               LEAVE Valida.
            END.
                
        
        /* Validar o cpf */
        IF  par_nrcpfcgc = "" THEN
            DO:
               ASSIGN par_nmdcampo = "nrcpfcgc"
                      aux_cdcritic = 27.

               LEAVE Valida.
            END.

        IF  NOT ValidaCpf(par_nrcpfcgc) THEN
            DO:
               ASSIGN par_nmdcampo = "nrcpfcgc"
                      aux_cdcritic = 27.

               LEAVE Valida.
            END.
        
        aux_nrcpfcgc = DEC(REPLACE(REPLACE(par_nrcpfcgc,".",""),"-","")).
        
        FOR FIRST crapass FIELDS(nrcpfcgc dtmvtolt inpessoa)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta 
                                NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Valida.

            END.
        ELSE
            ASSIGN aux_dtcadass = crapass.dtmvtolt.

		IF crapass.inpessoa = 1 THEN
		   DO:
		      FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
								     crapttl.nrdconta = crapass.nrdconta AND
									 crapttl.idseqttl > 1
									 NO-LOCK:


			     IF crapttl.idseqttl = 2 THEN
				    ASSIGN aux_nrcpfstl = crapttl.nrcpfcgc.
				 ELSE IF crapttl.idseqttl = 3 THEN
				    ASSIGN aux_nrcpfttl = crapttl.nrcpfcgc.

			  END.

		   END.

        /* Validacoes conforme a OPERACAO */
        CASE par_cddopcao:
            WHEN "I" THEN DO:
                IF  BuscaUltimoTtl(par_cdcooper,par_nrdconta) > 4 THEN
                    DO:
                       ASSIGN aux_dscritic = "Limite maximo de 4 titulares " + 
                                             "por conta atingido.".
                       LEAVE Valida.
                    END.

                RUN Valida_Inclusao
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_cdgraupr,
                      INPUT DEC(aux_nrcpfcgc),
                      INPUT crapass.nrcpfcgc,
                      INPUT aux_nrcpfstl,
                      INPUT aux_nrcpfttl,
                      INPUT par_cdestcvl,
                     OUTPUT par_nmdcampo,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).

                IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                    UNDO Valida, LEAVE Valida.
            END.
            WHEN "A" THEN DO:
                FOR FIRST crapttl FIELDS(nrcpfcgc)
                                  WHERE crapttl.cdcooper = par_cdcooper AND
                                        crapttl.nrdconta = par_nrdconta AND
                                        crapttl.idseqttl = par_idseqttl
                                        NO-LOCK:
                END.

                IF  NOT AVAILABLE crapttl THEN
                    DO:
                       ASSIGN aux_dscritic = "Titular nao cadastrado.".
                       LEAVE Valida.
                    END.
              
        
                RUN Valida_Alteracao
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_idseqttl,
                      INPUT par_cdgraupr,
                      INPUT DEC(aux_nrcpfcgc),
                      INPUT crapass.nrcpfcgc,
                      INPUT aux_nrcpfstl,
                      INPUT aux_nrcpfttl,
                      INPUT crapttl.nrcpfcgc,
                      INPUT par_cdestcvl,
                     OUTPUT par_nmdcampo,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).

                IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                    UNDO Valida, LEAVE Valida.

            END.
            OTHERWISE DO:

              

                ASSIGN aux_dscritic = "A opcao deve ser [A]=Alteracao ou " + 
                                      "[I]=Inclusao.".

                UNDO Valida, LEAVE Valida.

            END.
        END CASE.
                IF  NOT ValidaNome( INPUT par_nmextttl,
                            INPUT par_inpessoa,
                           OUTPUT aux_dscritic ) THEN
            DO:
               ASSIGN par_nmdcampo = "nmextttl"
                      aux_cdcritic = 0.
               LEAVE Valida.        
            END.
         
          /*IF par_nrctattl <> 0 AND par_idseqttl <> 1 THEN
            LEAVE Valida. */
         

        /* Titular */
        IF par_nmextttl = "" THEN 
           DO:
              ASSIGN par_nmdcampo = "nmextttl"
                     aux_cdcritic = 375.

              LEAVE Valida.
           END.

        /* Titular - critica dos caracteres */
        IF NOT CriticaNome(par_nmextttl,OUTPUT aux_cdcritic) THEN
           DO:
              ASSIGN par_nmdcampo = "nmextttl".
              LEAVE Valida.
           END.

                         
        /* Consulta do cpf */
        IF par_dtcnscpf > par_dtmvtolt OR
           par_dtcnscpf < aux_dtcadass OR
           par_dtcnscpf = ?                THEN
           DO:
              ASSIGN par_nmdcampo = "dtcnscpf"
                     aux_dscritic = "Data consulta do CPF incorreta.".

              LEAVE Valida.
           END.

        /* validar o tipo de documento */
        IF LOOKUP(par_tpdocttl,"CI,CN,CH,RE,PP,CT") = 0 THEN
           DO:
              ASSIGN par_nmdcampo = "tpdocttl"
                     aux_cdcritic = 21.

              LEAVE Valida.
           END.

        /* Numero do Documento */
        IF par_nrdocttl = "" THEN
           DO:
              ASSIGN par_nmdcampo = "nrdocttl"
                     aux_cdcritic = 22.

              LEAVE Valida. 
           END.

        /* Org.Emi. */
        IF par_cdoedttl = "" THEN 
           DO:
              ASSIGN par_nmdcampo = "cdoedttl"
                     aux_cdcritic = 375. 

              LEAVE Valida.
           END.

        /* Identificar orgao expedidor */
        IF  NOT VALID-HANDLE(h-b1wgen0052b) THEN
            RUN sistema/generico/procedures/b1wgen0052b.p 
                PERSISTENT SET h-b1wgen0052b.

        ASSIGN aux_idorgexp = 0.
        RUN identifica_org_expedidor IN h-b1wgen0052b 
                           ( INPUT par_cdoedttl,
                            OUTPUT aux_idorgexp,
                            OUTPUT aux_cdcritic, 
                            OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wgen0052b.   

        IF  RETURN-VALUE = "NOK" THEN
        DO:
              ASSIGN par_nmdcampo = "cdoedttl".
              LEAVE Valida.
           END.

        IF NOT CriticaNome(par_cdoedttl,OUTPUT aux_cdcritic) THEN
           LEAVE Valida.

        /* validar a UF */
        IF LOOKUP(par_cdufdttl,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                               "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                               "RS,RO,RR,SC,SP,SE,TO,EX") = 0 THEN
           DO:                                         
              ASSIGN par_nmdcampo = "cdufdttl"
                     aux_cdcritic = 33.

              LEAVE Valida.
           END.

        /* Data Emi. */
        IF par_dtemdttl = ?  THEN 
           DO:
              ASSIGN par_nmdcampo = "dtemdttl"
                     aux_cdcritic = 13.

              LEAVE Valida.
           END.

        /* Data Emi. */
        IF par_dtemdttl > par_dtmvtolt THEN 
           DO:
              ASSIGN par_nmdcampo = "dtemdttl"
                     aux_cdcritic = 13.

              LEAVE Valida.
           END.

        /* validar a data de nascimento */
        IF par_dtnasttl = ? THEN
           DO:
              ASSIGN aux_dscritic = "Data de nascimento invalida".
              LEAVE Valida.
           END.
        


        IF par_dtnasttl > par_dtmvtolt THEN
           DO:
              ASSIGN par_nmdcampo = "dtnasttl"
                     aux_cdcritic = 13.

              LEAVE Valida.
           END.

        /* validar o sexo */
        IF par_cdsexotl <> 1 AND par_cdsexotl <> 2 THEN
           DO:
              ASSIGN aux_dscritic = "Sexo deve ser 'M' ou 'F'".
              LEAVE Valida.
           END.

        /* validar o tipo de nacionalidade */
        IF NOT CAN-FIND(gntpnac WHERE 
                        gntpnac.tpnacion = par_tpnacion NO-LOCK) THEN
           DO:
              ASSIGN par_nmdcampo = "tpnacion"
                     aux_dscritic = "Tipo da Nacionalidade nao cadastrada".
              

              LEAVE Valida.
           END.

        /* validar a nacionalidade */
        IF NOT CAN-FIND(FIRST crapnac WHERE 
                        crapnac.cdnacion = par_cdnacion NO-LOCK) THEN
           DO:
              ASSIGN par_nmdcampo = "cdnacion"
                     aux_cdcritic = 28.

              LEAVE Valida.
           END.
           
        /* Valida UF */
        IF LOOKUP(par_cdufnatu,"AC,AL,AP,AM,BA,CE,DF,ES,GO,MA," +
                               "MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN," +
                               "RS,RO,RR,SC,SP,SE,TO,EX") = 0 THEN
           DO:
              ASSIGN par_nmdcampo = "cdufnatu"
                     aux_cdcritic = 33.

              LEAVE Valida.
           END.

        /* validar a naturalidade */
        IF   par_cdufnatu <> "EX" THEN
             DO:
                 FIND FIRST crapmun WHERE crapmun.dscidade = par_dsnatura AND 
                                          crapmun.cdestado = par_cdufnatu 
                                          NO-LOCK NO-ERROR.
             
                 IF   NOT AVAIL crapmun   THEN
                      DO:
                          ASSIGN par_nmdcampo = "cdufnatu"
                                 aux_dscritic = 
                              "Naturalidade nao cadastrada ou " + 
                              "U.F nao corresponde a cidade informada.".
                          LEAVE Valida.
                      END.
             END.

        /* Habilitacao - Responsab. Legal */
        IF par_inhabmen > 2 THEN
           DO:
              ASSIGN par_nmdcampo = "inhabmen"
                     aux_dscritic = "Responsab. Legal invalida.".

              LEAVE Valida.
           END.

        IF par_inhabmen = 1 AND par_dthabmen = ? THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     aux_dscritic = "E necessario preencher a data da " +
                                    "emancipacao".
              LEAVE Valida.
           END.
       /*
        IF par_inhabmen <> 1 AND par_dthabmen <> ? THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     aux_dscritic = "Data da emancipacao nao pode " + 
                                    "ser preenchida.".
              LEAVE Valida.
           END.
        */
        IF par_dthabmen < par_dtnasttl THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     aux_dscritic = "Data da emancipacao menor que a data " + 
                                    "de nascimento.".
              LEAVE Valida.
           END.

        IF par_dthabmen > par_dtmvtolt  THEN
           DO:
              ASSIGN par_nmdcampo = "dthabmen"
                     aux_dscritic = "Data da emancipacao maior que a data " + 
                                    "atual.".
              LEAVE Valida.
           END.

        /* validar o estado civil */
        IF NOT CAN-FIND(gnetcvl WHERE gnetcvl.cdestcvl = par_cdestcvl) THEN
           DO:
              ASSIGN par_nmdcampo = "cdestcvl"
                     aux_cdcritic = 35.

              LEAVE Valida.
           END.

        /* validar o grau escolar */
        /*
        IF  NOT CAN-FIND(gngresc WHERE gngresc.grescola = par_grescola) AND 
            par_grescola <> 0 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "grescola"
                   aux_cdcritic = 825.
               LEAVE Valida.
            END.
        */    

        IF par_grescola < 5 AND par_cdfrmttl <> 0 THEN
           DO:
              ASSIGN par_nmdcampo = "grescola"
                     aux_dscritic = "Escolaridade incorreta.".

              LEAVE Valida.
           END.

        IF par_grescola >= 5 AND par_cdfrmttl = 0 THEN
           DO:
              ASSIGN par_nmdcampo = "cdfrmttl"
                     aux_dscritic = "Codigo de formacao nao cadastrado.".

              LEAVE Valida.
           END.

        /* Validar a formacao */
        IF NOT CAN-FIND(gncdfrm WHERE gncdfrm.cdfrmttl = par_cdfrmttl) THEN
           DO:
              ASSIGN par_nmdcampo = "cdfrmttl"
                     aux_cdcritic = 826.

              LEAVE Valida.
           END.

        IF (par_qtfoltal <> 10 AND par_qtfoltal <> 20) AND 
            par_idseqttl = 1 THEN
            DO:
               ASSIGN par_nmdcampo = "qtfoltal"
                      aux_dscritic = "Quantidade de folhas do talao de " +
                                     "cheques deve se 10 ou 20.".
               LEAVE Valida.
            END.

        IF par_nmtalttl = "" THEN
           DO:
              ASSIGN par_nmdcampo = "nmtalttl"
                     aux_dscritic = "Nome que aparecera no talao de cheques " + 
                                    "deve ser informado.".
              LEAVE Valida.
           END.

        IF NOT CriticaNome(INPUT par_nmtalttl,OUTPUT aux_cdcritic) THEN
           DO:
               ASSIGN par_nmdcampo = "nmtalttl".
               LEAVE Valida.
           END.

        IF NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p
               PERSISTENT SET h-b1wgen9999.

        /* validar pela procedure generica do b1wgen9999.p */
        RUN idade IN h-b1wgen9999 ( INPUT par_dtnasttl,
                                    INPUT par_dtmvtolt,
                                    OUTPUT aux_nrdeanos,
                                    OUTPUT aux_nrdmeses,
                                    OUTPUT aux_dsdidade ).

        IF VALID-HANDLE(h-b1wgen9999) THEN
           DELETE PROCEDURE(h-b1wgen9999).

        IF par_inhabmen = 0   AND
           par_cdestcvl <> 1  AND
           par_cdestcvl <> 12 AND 
           aux_nrdeanos < 18  THEN
           DO:
              IF par_dthabmen = ? THEN 
                 DO:
                    ASSIGN par_nmdcampo = "dthabmen"
                           aux_dscritic = "Estado Civil obriga ser Emancipado.".
                    
                    LEAVE Valida.

                 END.

           END.
        ELSE
           IF par_inhabmen <> 1 AND par_dthabmen <> ? THEN
              DO:
                 ASSIGN par_nmdcampo = "dthabmen"
                        aux_dscritic = "Data da emancipacao nao pode " + 
                                       "ser preenchida.".

                 LEAVE Valida.

              END.
           
        IF par_verrespo = TRUE THEN
           DO:
               IF NOT VALID-HANDLE(h-b1wgen0072) THEN
                  RUN sistema/generico/procedures/b1wgen0072.p 
                      PERSISTENT SET h-b1wgen0072.
               
               FOR EACH tt-resp NO-LOCK:

                   RUN Valida_Dados IN h-b1wgen0072 
                                          (INPUT par_cdcooper,    
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT tt-resp.nrctamen,
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
                                           INPUT tt-resp.nrcpfmen,
                                           INPUT "Identificacao",
                                           INPUT par_dtnasttl,
                                           INPUT par_inhabmen,
                                           INPUT par_permalte,
                                           INPUT TABLE tt-resp,
                                           OUTPUT par_nmdcampo,
                                           OUTPUT TABLE tt-erro).

                   IF RETURN-VALUE <> "OK" THEN
                      DO:
                         IF VALID-HANDLE(h-b1wgen0072) THEN
                            DELETE PROCEDURE(h-b1wgen0072).
                       
                         ASSIGN aux_geraerro = TRUE.
                         UNDO Valida, LEAVE Valida.

                      END.

               END.  

               IF NOT CAN-FIND(FIRST tt-resp WHERE
                                     tt-resp.cdcooper = par_cdcooper AND
                                     tt-resp.nrctamen = par_nrdconta     
                                     NO-LOCK)                              THEN
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

        IF aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
           UNDO Valida, LEAVE Valida.

        LEAVE Valida.    

    END.

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE OBJECT h-b1wgen9999.

    IF aux_geraerro = FALSE THEN
       IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN 
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
       ELSE 
          ASSIGN aux_retorno = "OK".

    IF  aux_retorno <> "OK" AND par_flgerlog THEN
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

PROCEDURE Valida_Inclusao:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdgraupr AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfass AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfstl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfttl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                     NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.

    ASSIGN 
        par_dscritic = "Erro na validacao dos dados - Inclusao".
        aux_returnvl = "NOK".

    ValidaI: DO ON ERROR UNDO ValidaI, LEAVE ValidaI:

        IF  NOT CAN-DO("1,2,3,4,6",STRING(par_cdgraupr,"9")) AND 
            par_idseqttl <> 1 THEN
            DO:
               ASSIGN 
                   par_nmdcampo = "cdgraupr"
                   par_cdcritic = 23.
               LEAVE ValidaI.
            END.

        /** Verifica se ja existe conjuge para o primeiro titular **/
        IF  par_cdgraupr = 1 OR par_cdgraupr = 4  THEN
            DO:
               IF  CAN-FIND(FIRST crabttl WHERE 
                            crabttl.cdcooper = par_cdcooper  AND
                            crabttl.nrdconta = par_nrdconta  AND
                            (crabttl.cdgraupr = 1 OR 
                             crabttl.cdgraupr = 4)           AND
                            crabttl.idseqttl <> par_idseqttl) THEN
                   DO:   
                      ASSIGN 
                          par_nmdcampo = "cdgraupr"
                          par_dscritic = "Ja existe um CONJUGE para esta " +
                                         "conta!".
                      LEAVE ValidaI.
                   END.
            END.

        IF  par_nrcpfcgc = par_nrcpfass  OR
            par_nrcpfcgc = par_nrcpfstl  OR   /* Segundo titular */
            par_nrcpfcgc = par_nrcpfttl  THEN /* Terceiro titular */
            DO:
               ASSIGN 
                   par_nmdcampo = "nrcpfcgc"
                   par_dscritic = "CPF deve ser diferente dos demais " + 
                                  "titulares.".
               LEAVE ValidaI.
            END.

        IF  par_idseqttl > 1 THEN
            DO:
               /** Verifica se estado civil do 1 titular permite conjuge **/
               FOR FIRST crabttl FIELDS(cdestcvl)
                                 WHERE crabttl.cdcooper = par_cdcooper AND
                                       crabttl.nrdconta = par_nrdconta AND
                                       crabttl.idseqttl = 1 NO-LOCK:

                   /* CONJUGE - COMPANHEIRO(A) */
                   IF  (par_cdgraupr = 1 OR par_cdgraupr = 4)  AND     
                       (crabttl.cdestcvl = 1  OR   /* SOLTEIRO  */
                        crabttl.cdestcvl = 5  OR   /* VIUVO      */
                        crabttl.cdestcvl = 6  OR   /* SEPARADO   */
                        crabttl.cdestcvl = 7) THEN /* DIVORCIADO */
                        DO:
                           ASSIGN 
                               par_nmdcampo = "cdestcvl"
                               par_dscritic = "Estado civil do primeiro " + 
                                              "titular nao permite conjuge.".
                           LEAVE ValidaI.
                       END.
               END.

               /* CONJUGE - COMPANHEIRO(A) */
               IF (par_cdgraupr = 1  OR par_cdgraupr = 4) AND
                  (par_cdestcvl = 1  OR   /* SOLTEIRO   */
                   par_cdestcvl = 5  OR   /* VIUVO      */
                   par_cdestcvl = 6  OR   /* SEPARADO   */
                   par_cdestcvl = 7) THEN /* DIVORCIADO */
                   DO:
                      ASSIGN 
                          par_nmdcampo = "cdestcvl"
                          par_dscritic = "Estado civil diverge dos demais " +
                                         "dados.".
                      LEAVE ValidaI.
                   END.
            END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaI.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Alteracao:

    DEF  INPUT PARAM par_cdcooper AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_cdgraupr AS INTE                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfass AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfstl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpfttl AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_nrcpftit AS DECI                     NO-UNDO.
    DEF  INPUT PARAM par_cdestcvl AS INTE                     NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                     NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                     NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                              NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.

    ASSIGN 
        par_dscritic = "Erro na validacao dos dados - Alteracao".
        aux_returnvl = "NOK".
        

    ValidaA: DO ON ERROR UNDO ValidaA, LEAVE ValidaA:

        /** Verifica se ja existe conjuge para o primeiro titular **/
        IF  par_cdgraupr = 1 OR par_cdgraupr = 4 THEN
            DO:
               IF  CAN-FIND(FIRST crabttl WHERE 
                            crabttl.cdcooper = par_cdcooper  AND
                            crabttl.nrdconta = par_nrdconta  AND
                            (crabttl.cdgraupr = 1 OR 
                             crabttl.cdgraupr = 4)            AND
                            crabttl.idseqttl <> par_idseqttl) THEN
                   DO:   
                      ASSIGN par_dscritic = "Ja existe um CONJUGE para esta " +
                                            "conta!".
                      LEAVE ValidaA.
                   END.
            END.

        IF  par_nrcpfcgc = par_nrcpfass OR
            par_nrcpfcgc = par_nrcpfstl OR   /* Segundo titular */
            par_nrcpfcgc = par_nrcpfttl THEN /* Terceiro titular */
            DO:
               IF  par_nrcpfcgc <> par_nrcpftit THEN
                   DO:
                      ASSIGN par_dscritic = "CPF deve ser diferente dos " + 
                                            "demais titulares.".
                      LEAVE ValidaA.
                   END.
            END.
        ELSE
            DO:
               /* sera aplicado qdo houver alteracao no segundo ou terceiro
                  titular, a comparacao sera feita c/ o quarto titular pois
                  os demais cpf's estao na tabela crapass [cpfstl e cpfttl] */
               IF  CAN-FIND(FIRST crabttl WHERE
                            crabttl.cdcooper = par_cdcooper  AND
                            crabttl.nrdconta = par_nrdconta  AND
                            crabttl.nrcpfcgc = par_nrcpfcgc  AND
                            crabttl.idseqttl <> par_idseqttl) THEN
                   DO:
                      ASSIGN par_dscritic = "CPF deve ser diferente dos " +
                                            "demais titulares.".
                      LEAVE ValidaA.
                   END.
            END.

        IF  par_idseqttl > 1 THEN
            DO:
               /* CONJUGE - COMPANHEIRO(A)*/
               IF (par_cdgraupr = 1  OR  par_cdgraupr = 4) AND 
                  (par_cdestcvl = 1  OR   /* SOLTEIRO   */
                   par_cdestcvl = 5  OR   /* VIUVO      */
                   par_cdestcvl = 6  OR   /* SEPARADO   */
                   par_cdestcvl = 7) THEN /* DIVORCIADO */
                   DO:
                      ASSIGN 
                          par_nmdcampo = "cdgraupr"
                          par_dscritic = "Estado civil diverge dos " + 
                                         "demais dados.".
                     

                      LEAVE ValidaA.
                  END.
            END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaA.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

/* Criar as pendencias do digidoc */
PROCEDURE cria_pendencia_digidoc:

    DEF INPUT  PARAM par_cdcooper AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                        NO-UNDO.
    DEF INPUT  PARAM par_tpdocmto AS INTE                        NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                        NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                        NO-UNDO.

    DEF VAR aux_contador AS INTEGER                              NO-UNDO.

    ContadorDoc: DO aux_contador = 1 TO 10:  

        FIND FIRST crapdoc WHERE 
                   crapdoc.cdcooper = par_cdcooper AND
                   crapdoc.nrdconta = par_nrdconta AND
                   crapdoc.tpdocmto = par_tpdocmto AND
                   crapdoc.dtmvtolt = par_dtmvtolt AND
                   crapdoc.idseqttl = par_idseqttl 
                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
           
           
       IF  NOT AVAILABLE crapdoc THEN
           DO:
                IF  LOCKED(crapdoc) THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                ASSIGN aux_cdcritic = 341.
                                LEAVE ContadorDoc.
                            END.
                        ELSE 
                            DO: 
                                PAUSE 1 NO-MESSAGE.
                                NEXT ContadorDoc.
                            END.
                    END.
                ELSE
                    DO:
                        CREATE crapdoc.
                        ASSIGN crapdoc.cdcooper = par_cdcooper
                               crapdoc.nrdconta = par_nrdconta
                               crapdoc.flgdigit = FALSE
                               crapdoc.dtmvtolt = par_dtmvtolt
                               crapdoc.tpdocmto = par_tpdocmto
                               crapdoc.idseqttl = par_idseqttl.
                        VALIDATE crapdoc.
                    END.
           END.
       ELSE
           DO:
               ASSIGN crapdoc.flgdigit = FALSE.
               LEAVE ContadorDoc.
           END.
    END.

    IF  aux_cdcritic <> 0 THEN
        ASSIGN par_cdcritic = aux_cdcritic.

END PROCEDURE.

/*................................. FUNCTIONS ...............................*/
FUNCTION BuscaUltimoTtl RETURNS INTEGER
    ( INPUT par_cdcooper AS INTEGER,
      INPUT par_nrdconta AS INTEGER ):

    DEFINE BUFFER bcrapttl FOR crapttl.

    FOR LAST bcrapttl FIELDS(idseqttl) 
                      WHERE bcrapttl.cdcooper = par_cdcooper AND
                            bcrapttl.nrdconta = par_nrdconta NO-LOCK
                      BY bcrapttl.idseqttl:

        RETURN (bcrapttl.idseqttl + 1).
    END.

    RETURN 0.
END.

FUNCTION CriticaNome RETURNS LOGICAL 
    ( INPUT par_nomecrit AS CHARACTER,
     OUTPUT aux_cddcriti AS INTEGER ):

    DEFINE VARIABLE h-critnome AS HANDLE      NO-UNDO.

    IF  NOT VALID-HANDLE(h-critnome) THEN
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-critnome.

    RUN Critica_Nome IN h-critnome
        ( INPUT par_nomecrit,
         OUTPUT aux_cddcriti ).

    IF  VALID-HANDLE(h-critnome) THEN
        DELETE OBJECT h-critnome.

    RETURN (aux_cddcriti = 0).
        
END FUNCTION.

FUNCTION ValidaCpf RETURNS LOGICAL 
    ( INPUT par_nrcpfcgc AS CHARACTER ):

    DEFINE VARIABLE h-validacpf  AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_stsnrcal AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER     NO-UNDO.

    /* Se houve erro na conversao para DEC, faz a critica */
    DEC(par_nrcpfcgc) NO-ERROR.

    IF  ERROR-STATUS:ERROR THEN
        RETURN FALSE.

    IF  par_nrcpfcgc = "" OR DEC(par_nrcpfcgc) = 0 THEN
        RETURN FALSE.

    IF  NOT VALID-HANDLE(h-validacpf) THEN
        RUN sistema/generico/procedures/b1wgen9999.p
            PERSISTENT SET h-validacpf.

    RUN valida-cpf-cnpj IN h-validacpf (INPUT par_nrcpfcgc,
                                         OUTPUT aux_stsnrcal,
                                         OUTPUT aux_inpessoa).

    IF  VALID-HANDLE(h-validacpf) THEN
        DELETE OBJECT h-validacpf.

    RETURN aux_stsnrcal.
        
END FUNCTION.

FUNCTION ValidaNome RETURN LOGICAL
    (  INPUT par_nomedttl AS CHAR,     
       INPUT par_inpessoa AS INTE,       
      OUTPUT par_dscritic AS CHAR) :

    DEF VAR aux_listachr AS CHAR            NO-UNDO.
    DEF VAR aux_listanum AS CHAR            NO-UNDO.
    DEF VAR aux_nrextent AS HANDLE EXTENT   NO-UNDO.
    DEF VAR aux_nrextnum AS HANDLE EXTENT   NO-UNDO.
    DEF VAR aux_contador AS INTE            NO-UNDO.

    /* Verificacoes para o nome */
    ASSIGN aux_listachr = "=,%,&,#,+,?,',','.',/,;,[,],!,@,$,(,),*,|,\,:,<,>," +
                          "~{,~},~,"
           aux_listanum = "0,1,2,3,4,5,6,7,8,9".

    EXTENT(aux_nrextent) = NUM-ENTRIES(aux_listachr).

    DO aux_contador = 1 TO EXTENT(aux_nrextent):
        IF  INDEX(par_nomedttl,ENTRY(aux_contador,aux_listachr)) <> 0 THEN
            DO:
               ASSIGN par_dscritic = "O Caracter " + TRIM(ENTRY(aux_contador,
                                                                aux_listachr))
                                     + " nao e permitido! " +
                                     "Caracteres invalidos: " +
                                     "=%&#+?',./;][!@$()*|\:<>{}".
               RETURN FALSE.
            END.
    END.
 
    IF  par_inpessoa = 1 THEN
        DO:
           
            EXTENT(aux_nrextnum) = NUM-ENTRIES(aux_listanum).
            
            DO aux_contador = 1 TO EXTENT(aux_nrextnum):
                IF  INDEX(par_nomedttl,ENTRY(aux_contador,aux_listanum)) <> 0 THEN
                    DO:
                        ASSIGN par_dscritic = "Nao sao permitidos numeros no nome" +
                                              " do titular".
                        RETURN FALSE.
                    END.
            END.
        END.

    RETURN TRUE.

END FUNCTION.

