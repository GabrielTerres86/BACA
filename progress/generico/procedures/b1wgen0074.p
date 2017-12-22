/*.............................................................................

    Programa: b1wgen0074.p
    Autor   : Jose Luis Marchezoni (DB1)
    Data    : Maio/2010                   Ultima atualizacao: 13/12/2017

    Objetivo  : Tranformacao BO tela CONTAS - CONTA CORRENTE

    Alteracoes: 28/07/2010 - Permitir somente Banco 085 para emissao de cheques
                             (Guilherme).
                            - Ajuste para exclusao de titulares (David).
                            
                02/08/2010 - Alterar par_cdagenci para par_cdagepac nas 
                             leituras e updates da base (David).            
                             
                23/08/2010 - Ajuste na leitura da crapalt na procedure
                             Busca_Dados (David).
                
                30/08/2010 - Incluido caminho completo na gravacao dos arquivos
                             de log (Elton).
                             
                05/10/2010 - Nao permitir alterar o PAC da conta para contas
                             do PAC 5 da Coop 2. - Transferencia de PAC
                             (Irlan)
                             
                29/11/2010 - Habilitar opcao Solicitacao/Reativacao ITG para 
                             o pedido de reativacao da conta ITG a cada tres 
                             dias uteis, se a reativacao nao for efetuada
                             com sucesso (David).
                            
                22/12/2010 - Customizaçao da rotina de exclusao de titulares
                             (Gabriel - DB1).
                             
                23/02/2011 - Calculando um dia a mais para reativar a 
                             ITG (Magui).
                             
                06/09/2011 - Adicionado condicao de critica em procedure
                             Valida_Dados_Encerra quando verificado cartao
                             BB (Jorge).     
                             
                21/10/2011 - Validar se data de início da residencia esta
                             cadastrada quando o operador efetuar a solicitacao
                             de uma conta itg (Adriano).
                             
                11/04/2012 - Alterado as procedures abaixo para utilizar a nova
                             tabela (crapcrl - responsavel legal):
                             - Valida_Dados_Altera
                             - Grava_Dados_Exclui
                             - Critica_Cadastro_PF
                             (Adriano).                             
                             
                26/04/2012 - Alteracao na procedure Valida_Dados_Altera.
                             (David Kruger).
                
                07/11/2012 - Incluido bloqueio de usuario para encerramento
                             de conta itg e reativamento (Tiago).
                             
                12/11/2012 - Retirar matches dos find/for each (Gabriel).     
                
                10/12/2012 - Incluido restricao no bloqueio de transf. de pac
                             referente aos pacs da Viacredi p/ Alto Vale
                             (David Kruger).    
                             
                08/02/2013 - Incluir campo flgrestr em tt-conta-corr,
                             Incluir parametro flgrestr em procedure grava_dados
                             e procedure grava_dados_altera (Lucas R.)    
                             
                20/03/2013 - Incluido a chamada da procedure alerta_fraude
                             na procedure Grava_Dados (Adriano).   
                             
                12/06/2013 - Consorcio (Gabriel).           
                
                03/07/2013 - Ajuste na procedure Grava_Dados para que,
                             quando for alterado o PA (Orgao pagador), seja
                             solicitada a alteracao do mesmo, junto ao 
                             SICREDI (Adriano).
                             
                23/08/2013 - Retirar campos crabass.dsnatstl, crabass.dsnatttl
                             e validar de uf naturalidade foi informada (David).
                             
                05/09/2013 - Gravar registro na crapdoc, quando tipo de conta
                             for alterado (Jean Michel).
                
                12/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                             a escrita será PA (Guilherme Gielow)         
                                
                                21/11/2013 - Adicionado chamada da procedure 'proc_gerar_log'
                             ao excluir titulares da conta corrente. (Reinert)    
                             
                02/12/2013 - Incluido bloqueio de usuario para encerramento
                             e reativacao de conta itg - Migracao 
                             Acredicop - Viacredi (Tiago).
                             
                05/12/2013 - Incluido condicao para bloquear tranferencia entre
                             PAs migrados Acredicop apos dia 10/12/2013
                             (Tiago).
                             
                03/01/2014 - Criticas de busca de crapage alteradas de 15 para 
                             962 (Carlos)
                             
                19/02/2014 - Alterar crapdoc.tpdocmto = 12 por 
                             crapdoc.tpdocmto = 7 (Lucas R.)
                             
                05/03/2014 - Incluso VALIDATE (Daniel).
                
                28/04/2014 - Ajuste para buscar a sequence do banco Oracle
                             para a tabela crapneg. (James)
               
                28/05/2014 - Inclusao do campo Libera Credito Pre Aprovado 
                             'flgcrdpa' (Jaison) 
                                     
                                18/06/2014 - Exclusao do uso da tabela crapcar
                            (Tiago Castro - Tiago RKAM)

                10/07/2014 - Alterações para criticar propostas de cart. cred. 
                             em aberto durante exclusão de titulares
                             (Lucas Lunelli - Projeto Bancoob).
                                                     
                28/08/2014 - Incluir tt-conta-corr.dscadpos - Projeto Cadastro 
                             Positivo (Lucas R./Thiago Rodrigues).
                             
                11/09/2014 - Tratar bloqueio na rotina bloqueia-opcao devido a 
                             migraçao das cooperativas Concredi e credimilsul
                             (Odirlei/AMcom).
                             
                23/10/2014 - Removida a crítica exigindo cadastro de contato
                             de acordo com SD.205276 - Lunelli
                             
                19/12/2014 - Ajuste na rotina Grava_Dados para tratar contas
                             de beneficiarios com conta migrada - 
                             SD 228692 (Adriano).
                             
                21/01/2015 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)
                            
                23/03/2015 - Ajuste na rotina Grava_Dados para utilizar as
                             rotinas do INSS - SICREDI converitdas para o
                             PLSQL
                             (Adriano).

                29/05/2015 - Retirado verificacao se existe cheque fora na 
                             procedure Valida_Dados_Encerra para que seja 
                             possivel encerrar cta itg - SD278830 (Tiago).                            
                                                                              
                17/07/2015 - #302366 Existem registros de crapcje que pertencem
                             a crapttl que tiveram seus estados civis alterados
                             antes da correcao que faz a exclusao do conjuge 
                             quando o estado civil nao permite ter um. Nestes 
                             casos, eh sugerida a exclusao do crapcje (Carlos).

                11/08/2015 - Gravacao do novo campo indserma na tabela crapass
                             correspondente a tela CONTAS, OPCAO Conta Corrente                             
                             (Projeto 218 - Melhorias Tarifas (Carlos Rafael Tanholi)
                  
                27/10/2015 - Inclusao de novo campo para a tela CONTAS,
                             crapass.idastcjt (Jean Michel) 
                             
                07/12/2015 - Ajuste para deixar alterar normalmente o PA de
                             cooperados que possuem beneficios com status
                             de "Aguardando atualização."
                             (Adriano).     
                
                17/12/2015 - Remocao da pendencia do documento de ficha cadastral
                             no DigiDoc conforme solicitado na melhoria 114.  
                             SD 372880 (Kelvin)        
                             
                22/12/2015 - Ajuste na data de abertura da conta
                             Chamado 373200 (Heitor - RKAM)

                01/04/2016 - Retiradas consistências para exclusão de ITG na
							               Credimilsul - SD 417127 (Rodrigo)

                12/01/2016 - Remoção da manutenção do campo flgcrdpa e cdoplcpa
                             (Anderson).

                13/04/2016 - Ajustado a validacao das informacoes de cooperativa e
                             conta que recebemos na busca de informacoes do 
                             beneficiario do INSS, comparados com a conta que 
                             estamos alterando na tela CONTAS. A validacao deve ser 
                             coop E conta iguais, ao inves de coop OU conta iguais.
                             (Douglas - Chamado 418424)
                21/03/2016 - Inclusao campos consulta boa vista.
                             PRJ207 - Esteira (Odirlei/AMcom)    


	              01/08/2016 - Nao deixar alterar PA caso o processo do BI ainda
				                     estiver em execucao (Andrino - Chamado 495821)
                     
                11/11/2016 - #511290 Correcao de como o sistema verifica se eh
                             abertura de conta ou mudanca do tipo da mesma, 
                             para solicitar talao de cheque para o cooperado 
                             (Carlos)
				       
				        02/12/2016 - Tratamento bloqueio solicitacao conta ITG
				                     (Incorporacao Transposul). (Fabricio)

                19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                             PRJ339 - CRM (Odirlei-AMcom)  
                             
				        20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
                            crapass, crapttl, crapjur 
                            (Adriano - P339).

                19/06/2017 - Ajuste para inclusao do novo tipo de situacao da conta
                             "Desligamento por determinação do BACEN" 
							               (Jonata - RKAM P364).			

                21/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                             PRJ339 - CRM (Odirlei-AMcom)

                13/09/2017 - Tratamento temporario para nao permitir solicitacao
                             ou encerramento de conta ITG devido a migracao do BB.
                             (Jaison/Elton - M459)

                21/09/2017 - Sempre que houver a exclusao de titulares da Conta 
                             Corrente as pendencias registradas para ele devem ser 
                             baixadas do relatório 620_cadastro (Lucas Ranghetti #746857).
                16/10/2017 - Remocao de Tratamento temporario para nao permitir solicitacao
                             ou encerramento de conta ITG devido a migracao do BB.
                             (Jaison/Elton - M459)

				        14/11/2017 - Ajuste para nao permitir alterar situacao da conta quando 
				                     ja estiver com situacao = 4
							               (Jonata - RKAM P364).		

                13/12/2017 - Alterado procedure grava-dados, colocado envio de email
                             quando conta for encerrada por demissao e possuir convenio
                             CDC, Prj. 402 (Jean Michel).
                             
.............................................................................*/

/*............................. DEFINICOES ..................................*/
{ sistema/generico/includes/b1wgen0074tt.i &TT-LOG=SIM }
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/gera_log.i}
{ sistema/generico/includes/gera_erro.i}
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.

/** Nao pode quebrar linha no comando abaixo **/
&SCOPED-DEFINE VERIFICA-ERRO IF ERROR-STATUS:ERROR THEN aux_dscritic = aux_dscritic + ERROR-STATUS:GET-MESSAGE(1).

FUNCTION CriticaCadastro RETURNS LOGICAL 
    ( INPUT par_cdcooper AS INTE,
      INPUT par_nrdconta AS INTE,
      INPUT par_nrdcaixa AS INTE,
      INPUT par_cdagenci AS INTE,
      INPUT par_dtmvtolt AS DATE,
      INPUT par_cdoperad AS CHAR ) FORWARD.
                                 
/*............................. PROCEDURES ..................................*/
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtcalsol AS DATE                                    NO-UNDO.
    DEF VAR aux_dtcalrea AS DATE                                    NO-UNDO.
    DEF VAR aux_diauteis AS INTE                                    NO-UNDO.


    DEF OUTPUT PARAM TABLE FOR tt-conta-corr.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Busca dados da Conta Corrente"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-conta-corr.
        EMPTY TEMP-TABLE tt-erro.   

        /* pesquisa o associado */
        FOR FIRST crapass FIELDS(nrdconta cdagenci cdtipcta cdbcochq cdsitdct 
                                 tpavsdeb tpextcta cdsecext nrdctitg 
                                 flgiddep dtcnsspc dtcnsscr dtdsdspc 
                                 dtmvtolt dtelimin dtabtcct dtdemiss inadimpl 
                                 inlbacen inpessoa flgctitg flgrestr nrctacns
                                 incadpos indserma idastcjt dtdscore dsdscore)
                           WHERE crapass.cdcooper = par_cdcooper AND 
                                crapass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Busca.
            END.
            
        /*** Procura registro do primeiro titular ***/
        IF  crapass.inpessoa = 1   THEN /* so pessoa fisica */
            DO:
               /* Cadastro Titular Pessoa Fisica */
               IF  NOT CAN-FIND(crapttl WHERE 
                                        crapttl.cdcooper = par_cdcooper AND
                                        crapttl.nrdconta = par_nrdconta AND
                                        crapttl.idseqttl = 1) THEN
                   DO:
                      ASSIGN aux_cdcritic = 821.
                      LEAVE Busca.
                   END.
            END.
        ELSE
            DO:
               /* Cadastro Juridico */
               IF  NOT CAN-FIND(crapjur WHERE 
                                        crapjur.cdcooper = par_cdcooper AND
                                        crapjur.nrdconta = par_nrdconta) THEN
                   DO:
                      ASSIGN aux_cdcritic = 564.
                      LEAVE Busca.
                   END.
            END.

        CREATE tt-conta-corr.
        ASSIGN 
            tt-conta-corr.cdagepac = crapass.cdagenci
            tt-conta-corr.cdtipcta = crapass.cdtipcta
            tt-conta-corr.cdbcochq = crapass.cdbcochq
            tt-conta-corr.cdsitdct = crapass.cdsitdct
            tt-conta-corr.tpavsdeb = crapass.tpavsdeb
            tt-conta-corr.tpextcta = crapass.tpextcta
            tt-conta-corr.cdsecext = crapass.cdsecext
            tt-conta-corr.nrdctitg = crapass.nrdctitg
            tt-conta-corr.flgiddep = crapass.flgiddep
            tt-conta-corr.dtcnsspc = crapass.dtcnsspc
            tt-conta-corr.dtcnsscr = crapass.dtcnsscr
            tt-conta-corr.dtdsdspc = crapass.dtdsdspc
            tt-conta-corr.dtabtcoo = crapass.dtmvtolt
            tt-conta-corr.dtelimin = crapass.dtelimin
            tt-conta-corr.dtabtcct = crapass.dtabtcct
            tt-conta-corr.dtdemiss = crapass.dtdemiss
            tt-conta-corr.inadimpl = crapass.inadimpl
            tt-conta-corr.inlbacen = crapass.inlbacen
            tt-conta-corr.cdbcoitg = 1
            tt-conta-corr.btaltera = YES
            tt-conta-corr.btencitg = YES
            tt-conta-corr.flgctitg = crapass.flgctitg
            tt-conta-corr.flgtitul = NO
            tt-conta-corr.inpessoa = crapass.inpessoa
            tt-conta-corr.nrdrowid = ROWID(crapass)
            tt-conta-corr.flgrestr = crapass.flgrestr
            tt-conta-corr.nrctacns = crapass.nrctacns
            tt-conta-corr.indserma = crapass.indserma
            tt-conta-corr.idastcjt = crapass.idastcjt
            tt-conta-corr.dtdscore = crapass.dtdscore
            tt-conta-corr.dsdscore = crapass.dsdscore.    

        CASE crapass.incadpos:
            WHEN 3 THEN ASSIGN tt-conta-corr.dscadpos = "Cancelado".
            WHEN 2 THEN ASSIGN tt-conta-corr.dscadpos = "Autorizado".
            OTHERWISE ASSIGN tt-conta-corr.dscadpos = "Nao Autorizado".
        END CASE.            

        /* definir a situacao do ITG */
        IF  crapass.flgctitg = 2   THEN
            ASSIGN tt-conta-corr.dssititg = "Ativa".
        ELSE
        IF  crapass.flgctitg = 3   THEN
            ASSIGN tt-conta-corr.dssititg = "Inativa".
        ELSE
        IF  tt-conta-corr.nrdctitg <> ""   THEN
            ASSIGN tt-conta-corr.dssititg = "Em Proc".

        /* agencia ITG  */
        FOR FIRST crapcop FIELDS(cdagedbb
                                 cdbcoctl)
                          WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
            ASSIGN tt-conta-corr.cdagedbb = crapcop.cdagedbb
                   tt-conta-corr.cdbcoctl = crapcop.cdbcoctl.
        END.

        /* Verifica Se Tipo de Conta Individual e possui mais de um Titular */
        IF  crapass.inpessoa = 1 THEN  /* Pessoa Fisica  */
            DO:
               FOR LAST crapttl FIELDS(idseqttl)
                                WHERE crapttl.cdcooper = par_cdcooper AND
                                      crapttl.nrdconta = par_nrdconta 
                                      NO-LOCK:

                 IF  CAN-DO("01,02,07,08,09,12,13,18",
                            STRING(crapass.cdtipcta,"99")) AND
                     crapttl.idseqttl > 1 THEN
                     ASSIGN tt-conta-corr.flgtitul = TRUE.
               END.
            END. 

        /* Definir a situacao dos botoes */
        IF  crapass.inpessoa = 1 AND par_idseqttl <> 1 THEN
            DO: /* Demais titulares */
               ASSIGN
                   tt-conta-corr.btaltera = NO  /* 1 */
                   tt-conta-corr.btencitg = NO  /* 2 */
                   tt-conta-corr.btexcttl = NO  /* 3 */
                   tt-conta-corr.btsolitg = NO. /* 4 */
            END.
        ELSE
            DO:
                ASSIGN 
                   tt-conta-corr.btexcttl = tt-conta-corr.flgtitul
                   tt-conta-corr.btsolitg = NO.

                ASSIGN aux_dtcalrea = 01/01/2000. /* Data qualquer */

                /* Buscar data da ultima reativacao de ITG */
                FOR EACH crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                                       crapalt.nrdconta = par_nrdconta 
                                       NO-LOCK BREAK BY crapalt.dtaltera:

                    IF   crapalt.dsaltera MATCHES "*reativacao conta-itg*" THEN
                         ASSIGN aux_dtcalrea = crapalt.dtaltera.

                END.        

                ASSIGN aux_diauteis = 0.

                /* Calcular o terceiro dia util apos a ultima reativacao de ITG */
                DO  WHILE aux_diauteis <= 2:

                    aux_dtcalrea = aux_dtcalrea + 1.
                    IF  CAN-DO("2,3,4,5,6,",STRING(WEEKDAY(aux_dtcalrea))) AND
                        NOT CAN-FIND(crapfer WHERE
                                     crapfer.cdcooper = par_cdcooper       AND
                                     crapfer.dtferiad = aux_dtcalrea)      THEN
                        DO:
                            ASSIGN aux_diauteis = aux_diauteis + 1.
                            NEXT.
                        END.
                   
                END.  /*  Fim do DO WHILE TRUE  */

                ASSIGN aux_dtcalsol = 01/01/2000. /* Data qualquer */

                /* Buscar data da ultima solicitacao de ITG */
                FOR EACH crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                                       crapalt.nrdconta = par_nrdconta 
                                       NO-LOCK BREAK BY crapalt.dtaltera:

                    IF  crapalt.dsaltera MATCHES "*solicitacao conta-itg*" THEN
                        ASSIGN aux_dtcalsol = crapalt.dtaltera. 

                END.

                ASSIGN aux_diauteis = 0.

                /* Calcular o terceiro dia util apos a ultima solicitacao de ITG */
                DO  WHILE aux_diauteis <= 2:

                    aux_dtcalsol = aux_dtcalsol + 1.
                    IF  CAN-DO("2,3,4,5,6,",STRING(WEEKDAY(aux_dtcalsol))) AND
                        NOT CAN-FIND(crapfer WHERE
                                     crapfer.cdcooper = par_cdcooper       AND
                                     crapfer.dtferiad = aux_dtcalsol)      THEN
                        DO:
                            ASSIGN aux_diauteis = aux_diauteis + 1.
                            NEXT.
                        END.

                END.  /*  Fim do DO WHILE TRUE  */

                IF (CAN-DO("08,09,10,11",STRING(crapass.cdtipcta,"99")) AND
                    crapass.flgctitg > 2)                               
                    OR
                    /*********************************************************/
                    /** Se passou tres dias uteis da ultima solicitacao ou  **/
                    /** reativacao e a flag ainda estiver Em Proc(Enviado), **/
                    /** deixa solicitar/reativar novamente.                 **/
                    /*********************************************************/
                   (crapass.flgctitg = 1                                AND
                    par_dtmvtolt > aux_dtcalsol)                        
                    OR 
                   (crapass.flgctitg = 0                                AND
                    crapass.nrdctitg <> ""                              AND
                    par_dtmvtolt > aux_dtcalrea)                        THEN
                    ASSIGN tt-conta-corr.btsolitg = YES.
            END.

        /* nao mostrar o botao de excluir titulares quando nao houver mais
           que um titular na conta */
        IF  NOT CAN-FIND(FIRST crapttl WHERE 
                                       crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl > 1) THEN
            ASSIGN tt-conta-corr.btexcttl = NO.
/*
        /* Tratamento temporario para nao permitir solicitacao
           ou encerramento de conta ITG devido a migracao do BB */
        IF  (CAN-DO ("6,12", STRING(par_cdcooper)) AND /* Credifiesc / Crevisc */
             par_dtmvtolt >= 10/18/2017 AND par_dtmvtolt <= 10/24/2017)  OR
            (CAN-DO ("2,16", STRING(par_cdcooper)) AND /* Acredicoop / Alto Vale */
             par_dtmvtolt >= 10/19/2017 AND par_dtmvtolt <= 10/25/2017)  OR
            (CAN-DO ("8,9,11", STRING(par_cdcooper)) AND /* Credelesc / Transpocred / Credifoz */
             par_dtmvtolt >= 10/20/2017 AND par_dtmvtolt <= 10/26/2017)  OR
            (CAN-DO ("5,7,10", STRING(par_cdcooper)) AND /* Acentra / Credcrea / Credicomin */
             par_dtmvtolt >= 10/23/2017 AND par_dtmvtolt <= 10/27/2017)  OR
            (par_cdcooper = 1 AND /* Viacredi */
             par_dtmvtolt >= 10/24/2017 AND par_dtmvtolt <= 10/30/2017)  THEN
            DO:
               ASSIGN tt-conta-corr.btencitg = NO
                      tt-conta-corr.btsolitg = NO.
            END.
*/
        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        /* PAC */
        DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-conta-corr.cdagepac,
                         INPUT "nmextage",
                        OUTPUT tt-conta-corr.dsagepac,
                        OUTPUT aux_dscritic).

        /* Tipo da Conta */
        DYNAMIC-FUNCTION("BuscaTipoConta" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-conta-corr.cdtipcta,
                        OUTPUT tt-conta-corr.dstipcta,
                        OUTPUT aux_dscritic).

        /* Situacao da conta */
        DYNAMIC-FUNCTION("BuscaSituacaoConta" IN h-b1wgen0060,
                         INPUT tt-conta-corr.cdsitdct,
                         OUTPUT tt-conta-corr.dssitdct,
                         OUTPUT aux_dscritic).

        /* Destino/Secao de extrato */
        DYNAMIC-FUNCTION("BuscaDestExt" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT tt-conta-corr.cdagepac,
                         INPUT tt-conta-corr.cdsecext,
                        OUTPUT tt-conta-corr.dssecext,
                        OUTPUT aux_dscritic).

        /* Tipo Emissao de Aviso */
        DYNAMIC-FUNCTION("BuscaTipoAviso" IN h-b1wgen0060,
                          INPUT tt-conta-corr.tpavsdeb,
                         OUTPUT tt-conta-corr.dsavsdeb,
                         OUTPUT aux_dscritic).

        /* Tipo de extrato de conta */
        DYNAMIC-FUNCTION("BuscaTipoExtrato" IN h-b1wgen0060,
                          INPUT tt-conta-corr.tpextcta,
                         OUTPUT tt-conta-corr.dsextcta,
                         OUTPUT aux_dscritic).

        ASSIGN aux_dscritic = "".

        LEAVE Busca.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE 
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND par_cddopcao = "C" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK" THEN YES ELSE NO),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Verifica_Exclusao_Titulares:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO. 
    
    DEF OUTPUT PARAM par_tipconfi AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconfi AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-critica-excl-titulares.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-critica-excl-titulares.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Verifica exclusao de titulares da conta corrente."
           aux_cdcritic = 0   
           aux_dscritic = ""
           par_tipconfi = 0
           par_msgconfi = "".

    FOR FIRST crapass FIELDS(cdtipcta inpessoa) 
                      WHERE crapass.cdcooper = par_cdcooper AND 
                            crapass.nrdconta = par_nrdconta NO-LOCK.
    END.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl, 
                                    INPUT par_nmdatela, 
                                    INPUT par_nrdconta, 
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    /* Se mudou o tipo de conta de CONJUNTA para INDIVIDUAL, retorna    
       pergunta se o operador deseja excluir os titulares (exceto o 1o) */
    IF  crapass.inpessoa = 1   /* Fisica */                      AND
        NOT CAN-DO("3,4,6,10,11,14,15,17",STRING(par_cdtipcta))  AND
        CAN-DO("3,4,6,10,11,14,15,17",STRING(crapass.cdtipcta))  THEN
        DO:
            /* Procura propostas de Cartão de Crédito ativas dos Titulares */
            FOR EACH crapttl WHERE crapttl.cdcooper = crapass.cdcooper 
                               AND crapttl.nrdconta = crapass.nrdconta
                               AND crapttl.idseqttl > 1 NO-LOCK,
               FIRST crawcrd WHERE crawcrd.cdcooper = crapttl.cdcooper 
                               AND crawcrd.nrdconta = crapttl.nrdconta
                               AND crawcrd.nrcpftit = crapttl.nrcpfcgc
                               AND (crawcrd.cdadmcrd >= 10
                               AND  crawcrd.cdadmcrd <= 80) NO-LOCK:
            END.

            IF  AVAIL crawcrd THEN
                DO:
                    CREATE tt-critica-excl-titulares.
                    ASSIGN tt-critica-excl-titulares.tipconfi = 3
                           tt-critica-excl-titulares.cdcritic = 0
                           tt-critica-excl-titulares.dscritic = "Titulares possuem cartoes Bancoob. " +
                                                                    "Verificar situacao no SipagNET.".
                END.

            IF  CAN-FIND(FIRST crapneg WHERE 
                               crapneg.cdcooper = par_cdcooper           AND
                               crapneg.nrdconta = par_nrdconta           AND
                               crapneg.cdhisest = 1                      AND
                               CAN-DO("12,13", STRING(crapneg.cdobserv)) AND
                               crapneg.dtfimest = ?                      AND
                               crapneg.idseqttl <> 1 NO-LOCK)  THEN
                DO:
                    ASSIGN aux_cdcritic = 720
                           aux_dscritic = "".
                        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,           
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl, 
                                            INPUT par_nmdatela, 
                                            INPUT par_nrdconta, 
                                           OUTPUT aux_nrdrowid).
        
                    RETURN "NOK".
                END.
                
            ASSIGN par_tipconfi = 1
                   par_msgconfi = "ATENCAO! TODOS os titulares (exceto o 1o)" +
                                  " serao apagados. ".
        END.
    
    RETURN "OK".

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
    DEF  INPUT PARAM par_tpevento AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcochq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpavsdeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inadimpl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inlbacen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdsdspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgexclu AS LOG                            NO-UNDO.
    
    DEF OUTPUT PARAM par_flgcreca AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_tipconfi AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconfi AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    ASSIGN
        aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
        aux_dstransa = "Valida dados da Conta Corrente"
        aux_dscritic = ""
        aux_cdcritic = 0
        aux_returnvl = "NOK".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.
                
        CASE par_tpevento:
            WHEN "A" THEN DO: /* ALTERA */
                RUN Valida_Dados_Altera
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_cdoperad,
                      INPUT par_nrdconta,
                      INPUT par_dtmvtolt,
                      INPUT par_cdtipcta,
                      INPUT par_cdbcochq,
                      INPUT par_tpextcta,
                      INPUT par_cdagepac,
                      INPUT par_cdsitdct,
                      INPUT par_cdsecext, 
                      INPUT par_tpavsdeb,
                      INPUT par_inadimpl,
                      INPUT par_inlbacen,
                      INPUT par_dtdsdspc,
                      INPUT par_flgexclu,
                     OUTPUT par_flgcreca,
                     OUTPUT par_tipconfi,
                     OUTPUT par_msgconfi,
                     OUTPUT par_nmdcampo,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
            WHEN "E" THEN DO: /* ENCERRA ITG */
                
				IF par_cdcooper <> 17 THEN
				DO:
                RUN bloqueia-opcao(INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdconta,
                                   INPUT par_dtmvtolt).

                IF  RETURN-VALUE = "NOK" THEN
                    DO:
                        ASSIGN aux_dscritic = "Opcao indisponivel. Motivo: Transferencia do PA."
                               aux_cdcritic = 0.
                    END.
                ELSE
                    DO: 
						IF par_cdcooper <> 15 THEN
						DO:
							RUN Valida_Dados_Encerra(INPUT par_cdcooper,
                              INPUT par_nrdconta,
                             OUTPUT par_nmdcampo,
                             OUTPUT par_tipconfi,
                             OUTPUT par_msgconfi,
                             OUTPUT aux_cdcritic,
													 OUTPUT aux_dscritic).
                    END.
            END.
            END.
			    ELSE
			    DO:
					RUN Valida_Dados_Encerra(INPUT par_cdcooper,
									         INPUT par_nrdconta,
											OUTPUT par_nmdcampo,
											OUTPUT par_tipconfi,
											OUTPUT par_msgconfi,
											OUTPUT aux_cdcritic,
											OUTPUT aux_dscritic).
			    END.
            END.
            
            WHEN "X" THEN DO: /* EXCLUI TITULARES */
                RUN Valida_Dados_Exclui
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                     OUTPUT par_flgcreca,
                     OUTPUT par_tipconfi,
                     OUTPUT par_msgconfi,
                     OUTPUT par_nmdcampo,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ).
            END.
            WHEN "S" THEN DO: /* SOLICITA ITG */
                
                RUN bloqueia-opcao(INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdconta,
                                   INPUT par_dtmvtolt).

                IF  RETURN-VALUE = "NOK" THEN
                    DO:
                        ASSIGN aux_dscritic = "Opcao indisponivel. Motivo: Transferencia do PA."
                               aux_cdcritic = 0.
                    END.
                ELSE
                    DO: 
                        RUN Valida_Dados_Solicita
                            ( INPUT par_cdcooper,
                              INPUT par_nrdconta,
                             OUTPUT par_nmdcampo,
                             OUTPUT par_msgconfi,
                             OUTPUT aux_cdcritic,
                             OUTPUT aux_dscritic ).
                    END.
            END.
            OTHERWISE 
                ASSIGN aux_dscritic = "O Tipo de Evento de validacao deve " +
                                      "ser (A)-Alteracao, (E)-Encerrar ITG" +
                                      ", (X)-Excluir Titulares ou (S)-Soli" +
                                      "citar ITG". 
        END CASE.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            LEAVE Valida.

        /* se nao voltou com a confirmacao deve buscar a descricao da conf. */
        IF  par_msgconfi = "" THEN
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                   RUN sistema/generico/procedures/b1wgen0060.p
                       PERSISTENT SET h-b1wgen0060.

               ASSIGN par_msgconfi = DYNAMIC-FUNCTION("BuscaCritica"
                                                      IN h-b1wgen0060, 78).

               IF  par_msgconfi = "" THEN
                   ASSIGN par_msgconfi = "078 - Confirma a operacao? (S/N)".
            END.

        LEAVE Valida.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_returnvl = "OK".

    IF  par_flgerlog AND aux_returnvl <> "OK" THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF aux_returnvl = "OK" 
                                   THEN TRUE ELSE FALSE),
                            INPUT par_idseqttl, 
                            INPUT par_nmdatela, 
                            INPUT par_nrdconta, 
                           OUTPUT aux_nrdrowid).

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Dados_Altera:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcochq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpavsdeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inadimpl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inlbacen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdsdspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgexclu AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_flgcreca AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_tipconfi AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_dsresult AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dstextab AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtseqttl AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.

        
    ASSIGN 
        par_dscritic = "Erro ao validar os dados (ALTERACAO)".
        aux_returnvl = "NOK".
    
    ValidaAltera: DO ON ERROR UNDO ValidaAltera, LEAVE ValidaAltera:

        FOR FIRST crapcop FIELDS(cdagedbb cdagebcb cdbcoctl cdagectl)
                                 WHERE crapcop.cdcooper = par_cdcooper NO-LOCK:
        END.
      
        IF  NOT AVAILABLE crapcop THEN
            DO:
               ASSIGN par_cdcritic = 651
                      par_nmdcampo = "cdagepac".
               LEAVE ValidaAltera.
            END.

        FOR FIRST crapass FIELDS(cdcooper nrdconta inpessoa cdagenci inadimpl 
                                 inlbacen cdsitdct flgctitg nrdctitg cdtipcta 
                                 cdbcochq vllimcre dtdsdspc dtdemiss)
                          WHERE crapass.cdcooper = par_cdcooper AND
                                crapass.nrdconta = par_nrdconta 
                                NO-LOCK:
        END.

        IF  NOT AVAILABLE crapass THEN
            DO:
               ASSIGN par_cdcritic = 9
                      par_nmdcampo = "cdagepac".

               LEAVE ValidaAltera.

            END.

        IF  par_cdcooper = 1      AND
            par_nrdconta < 90000  AND
            CAN-DO ("7,33,38,60,62,66", STRING(par_cdagepac)) THEN
            DO:  
               ASSIGN   par_dscritic = "PA nao permitido. " +
                                       "Transferencia do PA!".
               LEAVE ValidaAltera.

            END.

        /*  Conta Total de Titulares para Pessoa Fisica   */
        IF  crapass.inpessoa = 1 THEN
            DO:
               /* Se operador confirmou a exclusao dos titulares, exceto 1.o */
               IF  par_flgexclu  THEN
                   ASSIGN aux_qtseqttl = 1.
               ELSE
                   DO:
                      ASSIGN aux_qtseqttl = 0.

                      FOR EACH crapttl FIELDS(idseqttl)
                                       WHERE crapttl.cdcooper = par_cdcooper AND
                                             crapttl.nrdconta = par_nrdconta 
                                             NO-LOCK:

                          ASSIGN aux_qtseqttl = aux_qtseqttl + 1.

                      END.
                   END.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        /* Mudou o PAC */
        IF  par_cdagepac <> crapass.cdagenci THEN
            DO:
               /* Bloqueio devido transf. PAC 5 da Acredicoop para Viacredi
                 E transf. de Pac 7,33,38,60,62,66  da Viacredi para Alto Vale
                */
               IF   (par_cdcooper = 2        AND 
                    (crapass.cdagenci = 5    OR 
                     par_cdagepac = 5))   
                                             OR
                    (par_cdcooper = 1        AND
                    ((crapass.cdagenci = 7   OR
                      crapass.cdagenci = 33  OR
                      crapass.cdagenci = 38  OR
                      crapass.cdagenci = 60  OR
                      crapass.cdagenci = 62  OR
                      crapass.cdagenci = 66) OR
                    (par_cdagepac = 7        OR
                     par_cdagepac = 33       OR
                     par_cdagepac = 38       OR
                     par_cdagepac = 60       OR
                     par_cdagepac = 62       OR
                     par_cdagepac = 66))) 
                                                OR
                   /*Migracao Acredicop*/
                    (par_cdcooper = 2           AND 
                     par_dtmvtolt >= 12/10/2013 AND
                    ((crapass.cdagenci = 2      OR
                      crapass.cdagenci = 4      OR
                      crapass.cdagenci = 6      OR
                      crapass.cdagenci = 7      OR
                      crapass.cdagenci = 11)    OR
                     (par_cdagepac = 2          OR
                      par_cdagepac = 4          OR
                      par_cdagepac = 6          OR
                      par_cdagepac = 7          OR
                      par_cdagepac = 11)))      THEN

                    DO:
                        ASSIGN par_dscritic = "Alteracao nao permitida. " +
                                              "Transferencia do PA!"
                               par_nmdcampo = "cdagepac".
                                 
                        LEAVE ValidaAltera.
                    END.
                /* ********************************************************* */  
               DYNAMIC-FUNCTION("BuscaPac" IN h-b1wgen0060,
                                 INPUT par_cdcooper,
                                 INPUT par_cdagepac,
                                 INPUT "nmextage",
                                 OUTPUT aux_dsresult,
                                 OUTPUT par_dscritic).

               IF  par_dscritic <> "" THEN
                   DO:  
                      ASSIGN par_nmdcampo = "cdagepac".

                      LEAVE ValidaAltera.

                   END.
            END.
         
        IF  par_cdtipcta <> crapass.cdtipcta  THEN
            DO:
               DYNAMIC-FUNCTION("BuscaTipoConta" IN h-b1wgen0060,
                                INPUT par_cdcooper,
                                INPUT par_cdtipcta,
                               OUTPUT aux_dsresult,
                               OUTPUT par_dscritic).

               IF  par_dscritic <> "" THEN
                   DO:  
                      ASSIGN par_nmdcampo = "cdtipcta".

                      LEAVE ValidaAltera.

                   END.                  
            END.

        IF  par_cdsitdct <> crapass.cdsitdct  THEN
            DO:
               /* validar a situacao da conta */
               DYNAMIC-FUNCTION("BuscaSituacaoConta" IN h-b1wgen0060,
                                  INPUT par_cdsitdct,
                                 OUTPUT aux_dsresult,
                                 OUTPUT par_dscritic).
        
               IF  par_dscritic <> "" THEN
                   DO:  
                      ASSIGN par_nmdcampo = "cdsitdct".

                      LEAVE ValidaAltera.

                   END.				   
				   
				/*Se for demissao BACEN, deve informar que nao ha reversao ao prosseguir 
				  com a alteracao da situacao para 8 (Processo demissa BACEN)*/
				IF par_cdsitdct = 8 THEN 
				   ASSIGN par_tipconfi = 3 
                          par_msgconfi = "Esta alteração será irreversível.".
				
				IF crapass.cdsitdct = 8 THEN
				   DO:
				      ASSIGN par_dscritic = "Conta em processo de demissao BACEN."
					         par_nmdcampo = "cdsitdct".

                      LEAVE ValidaAltera.
				   
				   END.   
				ELSE IF crapass.cdsitdct = 4 THEN
				   DO:
				      ASSIGN par_dscritic = "Conta ja encerrada por demissao."
					         par_nmdcampo = "cdsitdct".

                      LEAVE ValidaAltera.

				   END.

            END.

        /*  Mudou o tipo de conta  */
        IF  par_cdtipcta <> crapass.cdtipcta THEN
            DO:                                                
               FOR FIRST craptip WHERE craptip.cdcooper = par_cdcooper AND
                                       craptip.cdtipcta = par_cdtipcta 
                                       NO-LOCK:

               END.

               IF  NOT AVAIL craptip  THEN
                   DO:
                      ASSIGN par_cdcritic = 17
                             par_nmdcampo = "cdtipcta".

                      LEAVE ValidaAltera.

                   END.

               /* Tipo de conta desailitado a partir da 
                  utilizacao da IF CECRED */
               IF  par_cdtipcta >= 12  AND
                   par_cdtipcta <= 15  THEN
                   DO:
                   ASSIGN par_cdcritic = 17
                              par_nmdcampo = "cdtipcta".
                   
                       LEAVE ValidaAltera.
                   
                   END.
               
               IF (par_cdtipcta = 1    OR  /* Normal              */
                   par_cdtipcta = 2    OR  /* Especial            */
                   par_cdtipcta = 7    OR  /* Conta aplicac indiv */
                   par_cdtipcta = 8    OR  /* Normal convenio     */
                   par_cdtipcta = 9    OR  /* Especial convenio   */
                   par_cdtipcta = 12   OR  /* Normal Itg          */
                   par_cdtipcta = 13   OR  /* Especial Itg        */
                   par_cdtipcta = 18)  AND /* Cta aplic indiv Itg */
                   aux_qtseqttl > 1    THEN
                   DO:
                   ASSIGN par_cdcritic = 17
                             par_nmdcampo = "cdtipcta".

                      LEAVE ValidaAltera.

                   END.

               IF (par_cdtipcta = 3   OR  /* Normal Conjunta        */
                   par_cdtipcta = 4   OR  /* Especial Conjunta      */
                   par_cdtipcta = 6   OR  /* Cta aplicacao Conjunta */
                   par_cdtipcta = 10  OR  /* Normal conv Conjunta   */
                   par_cdtipcta = 11  OR  /* Espec conv Conjunta    */
                   par_cdtipcta = 14  OR  /* Normal Itg Conjunta    */
                   par_cdtipcta = 15  OR  /* Especial Itg Conjunta  */
                   par_cdtipcta = 17) AND /* Cta aplic Conjunta Itg */
                   aux_qtseqttl = 1   THEN
                   DO:
                   ASSIGN par_cdcritic = 832
                             par_nmdcampo = "cdtipcta".
                      
                      LEAVE ValidaAltera.

                   END.

               /* Mudando para Conta Integracao */
               IF  par_cdtipcta >= 12 AND par_cdtipcta <= 18  THEN
                   DO:
                      /* Elimin. anteriorm. CI */
                      IF  crapass.flgctitg = 3 AND crapass.nrdctitg <> " " THEN
                          DO:
                             FOR EACH crapalt WHERE
                                      crapalt.cdcooper = par_cdcooper   AND
                                      crapalt.nrdconta = par_nrdconta   AND
                                      crapalt.flgctitg <> 2             NO-LOCK:
                                 
                                 IF   crapalt.dsaltera MATCHES
                                                  "*exclusao conta-itg*"   THEN
                                      DO:
                                         ASSIGN par_cdcritic = 219
                                                par_nmdcampo = "cdtipcta".
                                     
                                         LEAVE ValidaAltera.
                                     
                                      END.
                             END.
                          END.
                      
                      /* Nao pode mudar pra CI pois nao existe a agencia do
                         do BB cadastrado na cadcop */
                      IF  crapcop.cdagedbb = 0 THEN
                          DO:
                             ASSIGN par_dscritic = "ATENCAO! Agencia do " +
                                                   "Banco do Brasil nao " +
                                                   "cadastrada."
                                    par_nmdcampo = "cdtipcta".

                             LEAVE ValidaAltera.

                          END.
                   END.

               IF  par_cdtipcta     <  8   AND /* Mudando-Nao Cta Integracao */
                   crapass.cdtipcta >= 8   AND /* Ant.Conta Integr e Bancoob */
                   crapass.cdtipcta <= 18  AND
                 ((crapass.nrdctitg <> " " AND /* ITG cadastrada ou enviada  */
                   crapass.flgctitg = 2)   OR
                   crapass.flgctitg = 1)   THEN
                   DO:
                      ASSIGN par_cdcritic = 17
                             par_nmdcampo = "cdtipcta".

                      LEAVE ValidaAltera.

                   END.

               /* Nao pode mudar para conta convenio se nao tiver
                  cadastrada a agencia do BANCOOB na CADCOP */
               /* Considerar o banco da central - projeto nova COMPE */
               IF  par_cdtipcta > 7 AND par_cdtipcta < 12 THEN
                   DO:
                      /* Bancoob */
                      IF  par_cdbcochq = 756 AND crapcop.cdagebcb = 0  THEN
                          DO:
                             ASSIGN par_dscritic = "ATENCAO! Agencia do " +
                                                   "BANCOOB nao cadastrada."
                                    par_nmdcampo = "cdtipcta".

                             LEAVE ValidaAltera.

                          END.
                      ELSE
                      /* COMPE CECRED */
                      IF  par_cdbcochq = crapcop.cdbcoctl  AND
                          crapcop.cdagectl = 0             THEN
                          DO:
                             ASSIGN par_dscritic = "ATENCAO! Agencia da IF " +
                                                   "CECRED nao cadastrada."
                                    par_nmdcampo = "cdtipcta".

                             LEAVE ValidaAltera.

                          END.
                   END.

               IF  par_cdsitdct = 1 AND   /* NORMAL - COM TALAO */
                  (par_cdtipcta = 1 OR par_cdtipcta = 2 OR
                   par_cdtipcta = 3 OR par_cdtipcta = 4) THEN
                   DO:
                      ASSIGN par_cdcritic = 18
                             par_nmdcampo = "cdsitdct".

                      LEAVE ValidaAltera.

                   END.

               IF  par_cdtipcta = 02 OR par_cdtipcta = 04 OR
                   par_cdtipcta = 09 OR par_cdtipcta = 11 OR
                   par_cdtipcta = 13 OR par_cdtipcta = 15 THEN
                   DO:
                      IF  crapass.vllimcre = 0 THEN
                          DO:
                             ASSIGN par_cdcritic = 105
                                    par_nmdcampo = "cdtipcta".

                             LEAVE ValidaAltera.

                          END.
                   END.
               ELSE
                   IF  crapass.vllimcre > 0 THEN
                       DO:
                          ASSIGN par_cdcritic = 106
                                 par_nmdcampo = "cdtipcta".

                          LEAVE ValidaAltera.

                       END.

               FOR FIRST craptab FIELDS(dstextab)
                                 WHERE craptab.cdcooper = par_cdcooper AND
                                       craptab.nmsistem = "CRED"       AND
                                       craptab.tptabela = "CONFIG"     AND
                                       craptab.cdempres = par_cdcooper AND
                                       craptab.cdacesso = "CONVTALOES" AND
                                       craptab.tpregist = 1        
                                       NO-LOCK:
               END.

               IF  NOT AVAILABLE craptab THEN
                   ASSIGN aux_dstextab = "0".
               ELSE
                   ASSIGN aux_dstextab = craptab.dstextab.

               IF (par_cdtipcta >= 1 AND par_cdtipcta <= 4) AND
                   aux_dstextab <> "001" THEN
                   DO:
                      ASSIGN par_cdcritic = 17
                             par_nmdcampo = "cdtipcta".

                      LEAVE ValidaAltera.

                   END.
        END.

        /*  Mudou a situacao da conta  */
        IF  par_cdsitdct <> crapass.cdsitdct   THEN
            DO:
                IF  par_cdsitdct = 6  AND /* NORMAL - SEM TALAO */
                   (par_cdtipcta = 5  OR par_cdtipcta = 6  OR
                    par_cdtipcta = 7  OR par_cdtipcta = 17 OR
                    par_cdtipcta = 18) THEN
                    DO:
                       ASSIGN par_cdcritic = 18
                              par_nmdcampo = "cdsitdct".

                       LEAVE ValidaAltera.

                    END.

                IF  crapass.cdsitdct = 4  THEN
                    DO:
                       IF  crapass.cdsitdct <> par_cdsitdct   THEN
                           DO:
                              ASSIGN par_cdcritic = 75
                                     par_nmdcampo = "cdsitdct".

                              LEAVE ValidaAltera.

                           END.
                    END.
                ELSE
                    IF  par_cdsitdct = 4 THEN
                        DO:
                           ASSIGN par_cdcritic = 76
                                  par_nmdcampo = "cdsitdct".

                           LEAVE ValidaAltera.

                        END.
            END.

        IF  par_cdbcochq <> crapcop.cdbcoctl  AND
            CAN-DO("8,9,10,11",TRIM(STRING(par_cdtipcta)))  THEN
            DO:
                ASSIGN par_dscritic = "Banco de emissao de cheque deve ser " +
                                      STRING(crapcop.cdbcoctl,"999") +
                                      ". Favor pressionar <ENTER>"
                       par_nmdcampo = "cdtipcta".

                LEAVE ValidaAltera.

            END.
        
        /* Fixo crapcop.cdbcoctl *****************************************
        /* proceder a Validacao do tipo da conta */
        IF  CAN-DO("12,13,14,15",TRIM(STRING(par_cdtipcta))) THEN
            DO:
               IF  par_cdbcochq <> 1  THEN
                   DO:
                      ASSIGN par_dscritic = "Banco nao confere. Deve ser 1."
                             par_nmdcampo = "cdbcochq".
                      LEAVE ValidaAltera.
                   END.
            END.
        ELSE
            DO:
               IF  par_cdbcochq = 0 THEN
                   DO:
                      ASSIGN par_dscritic = "Banco nao confere. Devera ser " +
                                            "informado o codigo do banco."
                             par_nmdcampo = "cdbcochq".
                      LEAVE ValidaAltera.
                   END.

               IF  par_cdtipcta >= 8 AND par_cdtipcta <= 11 THEN
                   DO:
                      /* PAC */
                      FOR FIRST crapage FIELDS(cdcomchq cdagenci)
                          WHERE crapage.cdcooper = par_cdcooper AND
                                crapage.cdagenci = par_cdagepac NO-LOCK:
                      END.

                      IF  NOT AVAILABLE crapage THEN
                          DO:
                             ASSIGN par_cdcritic = 15
                                    par_nmdcampo = "cdagepac".
                             LEAVE ValidaAltera.
                          END.

                      /* Nao permitir IF CECRED para compe 86 e 33 */
                      IF  par_cdbcochq = crapcop.cdbcoctl AND
                         (crapage.cdcomchq = 86 OR crapage.cdcomchq = 33) THEN
                          DO:
                             ASSIGN par_dscritic = "Compe " +
                                            STRING(crapage.cdcomchq)     +
                                            " referente ao PAC "         +
                                            STRING(crapage.cdagenci)     +
                                            " nao permitida para banco " +
                                            STRING(crapcop.cdbcoctl)     + "."
                                    par_nmdcampo = "cdbcochq".
                             LEAVE ValidaAltera.
                          END.

                      IF  par_cdbcochq <> 756 AND
                          par_cdbcochq <> crapcop.cdbcoctl THEN
                          DO:
                              IF  crapcop.cdbcoctl <> 0 THEN
                                  par_dscritic = "Banco nao confere. " +
                                                 "Deve ser 756 ou " +
                                                 STRING(crapcop.cdbcoctl,"999")
                                                 + ".".
                              ELSE
                                  par_dscritic = "Banco nao confere. Deve " +
                                                 "ser 756.".

                              ASSIGN par_nmdcampo = "cdbcochq".
                              LEAVE ValidaAltera.
                          END.
                   END.
            END.
        ********************************************************************/

        /* O associado esta no SPC ou no CCF, exige situacao da conta <> 1 */
        IF (par_inadimpl = 1 OR par_inlbacen = 1) AND
           (par_cdsitdct = 1 OR par_cdsitdct = 6) THEN
            DO:
               ASSIGN par_dscritic = "Situacao invalida. Cooperado no SPC/CCF."
                      par_nmdcampo = "cdsitdct".

               LEAVE ValidaAltera.

            END.

        /* No SPC pela COOP */ /* Indicador de SPC com Nao */
        IF  par_dtdsdspc <> ? AND par_inadimpl = 0 THEN
            DO:
               ASSIGN par_cdcritic = 13
                      par_nmdcampo = "dtdsdspc".

               LEAVE ValidaAltera.

            END.
        
        /* Tipo Emissao de Aviso */
        DYNAMIC-FUNCTION("BuscaTipoAviso" IN h-b1wgen0060,
                          INPUT par_tpavsdeb,
                         OUTPUT aux_dsresult,
                         OUTPUT par_dscritic).

        IF  par_dscritic <> "" THEN
            DO:
               ASSIGN par_nmdcampo = "tpavsdeb".

               LEAVE ValidaAltera.

            END.

        /* Tipo de extrato de conta */
        DYNAMIC-FUNCTION("BuscaTipoExtrato" IN h-b1wgen0060,
                          INPUT par_tpextcta,
                         OUTPUT aux_dsresult,
                         OUTPUT par_dscritic).

        IF  par_dscritic <> "" THEN
            DO:
               ASSIGN par_nmdcampo = "tpextcta".

               LEAVE ValidaAltera.

            END.
        
            /* Destino/Secao de extrato */
        DYNAMIC-FUNCTION("BuscaDestExt" IN h-b1wgen0060,
                         INPUT par_cdcooper,
                         INPUT par_cdagepac,
                         INPUT par_cdsecext,
                        OUTPUT aux_dsresult,
                        OUTPUT par_dscritic).
      
        IF  par_dscritic <> "" THEN
            DO:
               ASSIGN par_nmdcampo = "cdsecext".

               LEAVE ValidaAltera.

            END.

        /* Valida o tipo de extrato */
        IF  par_tpextcta > 0                                      AND 
           (CAN-DO("00,05,06,07,17,18",STRING(par_cdtipcta,"99")) OR   
            crapass.dtdemiss <> ? OR crapass.cdsitdct <> 1)       THEN
             DO:
                ASSIGN par_cdcritic = 572
                       par_nmdcampo = "tpextcta".

                LEAVE ValidaAltera.

             END.
        
        /* Verifica maioridade somente para pessoa fisica */
        IF  crapass.inpessoa = 1  THEN
            DO:
               FOR FIRST crapttl FIELDS(dtnasttl nrdconta idseqttl 
                                        cdcooper inhabmen nrcpfcgc)
                                 WHERE crapttl.cdcooper = par_cdcooper AND
                                       crapttl.nrdconta = par_nrdconta AND
                                       crapttl.idseqttl = 1 
                                       NO-LOCK:
               END.

               IF  NOT AVAILABLE crapttl THEN
                   DO:
                      ASSIGN par_cdcritic = 821
                             par_nmdcampo = "cdagepac".

                      LEAVE ValidaAltera.

                   END.

               RUN Busca_Idade
                  ( INPUT crapttl.dtnasttl,
                    INPUT par_dtmvtolt,
                   OUTPUT aux_nrdeanos ).
               
               IF (aux_nrdeanos < 18 AND crapttl.inhabmen = 0)  OR
                   crapttl.inhabmen = 2 THEN
                   DO: 
                      IF NOT CAN-FIND(FIRST crapcrl WHERE 
                                crapcrl.cdcooper = crapttl.cdcooper         AND
                                crapcrl.nrctamen = crapttl.nrdconta         AND
                                crapcrl.nrcpfmen = (IF crapttl.nrdconta = 0 THEN
                                                       crapttl.nrcpfcgc 
                                                    ELSE 
                                                       0)                   AND
                                crapcrl.idseqmen = crapttl.idseqttl)        THEN
                         DO:
                            ASSIGN par_dscritic = "Falta Cadastrar o Respon" +
                                                  "savel Legal."
                                   par_nmdcampo = "cdagepac".

                            LEAVE ValidaAltera.

                         END.
                   END.
            END.

        IF  par_cdtipcta <> crapass.cdtipcta  THEN
            DO:
               /**********************************************************/
               /** Se mudou o tipo de conta de CONJUNTA para INDIVIDUAL **/
               /** pede para apagar os titulares (exceto o 1o)          **/
               /**********************************************************/
               IF  crapass.inpessoa = 1  THEN  /* Fisica */
                   DO:
                      IF  par_flgexclu  THEN
                          ASSIGN par_flgcreca = TRUE.
                      ELSE
                      IF  NOT CAN-DO("3,4,6,10,11,14,15,17",
                                     TRIM(STRING(par_cdtipcta))) AND
                          CAN-DO("3,4,6,10,11,14,15,17",
                                 TRIM(STRING(crapass.cdtipcta))) THEN
                          ASSIGN par_flgcreca = TRUE
                                 par_tipconfi = 1 /* EXCLUSAO DE TITULARES */
                                 par_msgconfi = "ATENCAO! TODOS os titulares " +
                                                "(exceto o 1o) serao apagados.".
                   END.

               IF  par_cdtipcta >= 8  THEN
                   DO:  
                      /* IMPRESSAO DAS CRITICAS */
                      IF  CriticaCadastro( INPUT par_cdcooper,
                                           INPUT par_nrdconta,
                                           INPUT 1,
                                           INPUT par_cdagenci,
                                           INPUT par_dtmvtolt,
                                           INPUT par_cdoperad ) THEN
                          ASSIGN par_tipconfi = 2. 
                   END.
            END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaAltera.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.
    
    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Dados_Encerra:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_tipconfi AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    
    DEF BUFFER crabass FOR crapass.

    ASSIGN 
        par_dscritic = "Erro ao validar os dados (ENCERRA ITG)".
        aux_returnvl = "NOK".

    ValidaEncerra: DO ON ERROR UNDO ValidaEncerra, LEAVE ValidaEncerra:

        FOR FIRST crabass FIELDS(cdcooper nrdconta nrdctitg flgctitg cdtipcta)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.
    
        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_cdcritic = 9.
               LEAVE ValidaEncerra.
            END.

        IF  crabass.nrdctitg = "" THEN
            DO:
               ASSIGN par_cdcritic = 597.
               LEAVE ValidaEncerra.
            END.

        IF  crabass.cdtipcta < 8 THEN
            DO:
               ASSIGN par_dscritic = "TIPO DE CONTA ERRADO - SOMENTE TIPO > 7 ".
               LEAVE ValidaEncerra.
            END.

        /* Verifica se a conta esta ativa */
        IF  crabass.flgctitg <> 2 THEN
            DO:
               ASSIGN par_cdcritic = 860.
               LEAVE ValidaEncerra.
            END.

        /* Verifica se existe cheque fora*/
        FOR EACH crapfdc FIELDS(cdbanchq nrctachq cdagechq nrdctabb
                                nrcheque nrdigchq)
                         WHERE crapfdc.cdcooper  = crabass.cdcooper AND
                               crapfdc.nrdconta  = crabass.nrdconta AND 
                               crapfdc.cdbanchq  = 1                AND
                               crapfdc.nrdctitg <> ?                AND
                               crapfdc.dtretchq <> ?                AND
                               crapfdc.dtliqchq = ?                 AND
                               crapfdc.incheque = 0                 NO-LOCK:

            ASSIGN par_tipconfi = 1
                   par_msgconfi = "ATENCAO! Associado com cheques no CCF.".
                   par_dscritic = "EXISTE CHEQUE FORA - IMPOSSIVEL ENCERRAR".
                   LEAVE ValidaEncerra.
        END.


        /* Verifica se existe cheque em arquivo */
        IF  CAN-FIND(FIRST crapfdc WHERE 
                                   crapfdc.cdcooper = crabass.cdcooper AND
                                   crapfdc.nrdconta = crabass.nrdconta AND
                                   crapfdc.nrdctitg = crabass.nrdctitg AND
                                   crapfdc.dtemschq <> ?               AND
                                   crapfdc.dtretchq = ?) THEN  
            DO:
               par_dscritic = "EXISTEM CHEQUES EM ARQUIVO - IMPOSSIVEL " + 
                              "ENCERRAR".
               LEAVE ValidaEncerra.
            END.

        /* Verifica se existe pedido fora */
        IF  CAN-FIND(FIRST crapfdc WHERE 
                                   crapfdc.cdcooper = crabass.cdcooper AND
                                   crapfdc.nrdconta = crabass.nrdconta AND
                                   crapfdc.nrdctitg = crabass.nrdctitg AND
                                   crapfdc.dtemschq = ?) THEN
            DO:
               par_dscritic = "EXISTE PEDIDOS DE CHEQUE - IMPOSSIVEL ENCERRAR".
               LEAVE ValidaEncerra.
            END.

        /* Verifica se existe requisicao fora */
        IF  CAN-FIND(FIRST crapreq WHERE 
                                   crapreq.cdcooper  = crabass.cdcooper    AND
                                   crapreq.nrdconta  = crabass.nrdconta    AND
                                   (crapreq.insitreq  = 1 OR
                                    crapreq.insitreq  = 4 OR
                                    crapreq.insitreq  = 5)                 AND
                                   crapreq.cdtipcta > 11 /*Req.Conta ITG*/ AND 
                                   crapreq.qtreqtal > 0) THEN
            DO: 
               par_dscritic = "EXISTEM REQUISICOES DE CHEQUES - IMPOSSIVEL " + 
                              "ENCERRAR".
               LEAVE ValidaEncerra.
            END.

        /* Verifica se existe Cartao BB */ 
        FIND FIRST crawcrd WHERE   crawcrd.cdcooper = crabass.cdcooper AND
                                   crawcrd.nrdconta = crabass.nrdconta AND
                                   (crawcrd.insitcrd = 0 OR 
                                    crawcrd.insitcrd = 1 OR 
                                    crawcrd.insitcrd = 4 OR
                                    crawcrd.insitcrd = 5)              AND
                                   (crawcrd.cdadmcrd >= 83 AND 
                                    crawcrd.cdadmcrd <= 88) NO-LOCK NO-ERROR.
        IF AVAIL crawcrd THEN
            DO:
                IF crawcrd.insitcrd = 0 OR crawcrd.insitcrd = 1 THEN
                    par_dscritic = "EXISTE CARTAO BB SOLICITADO - " + 
                                   "IMPOSSIVEL ENCERRAR".
                ELSE  /* insitcrd = 4 ou 5 */
                    par_dscritic = "Necessario ENCERRAR cartoes BB. " + 
                                   "Verificar lancto futuro dos cartoes.".
                LEAVE ValidaEncerra.
            END.

        ASSIGN par_dscritic = "".

        LEAVE ValidaEncerra.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Dados_Exclui:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_flgcreca AS LOG                            NO-UNDO.
    DEF OUTPUT PARAM par_tipconfi AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    
    ASSIGN 
        par_dscritic = "Erro ao validar os dados (EXCLUI TITULARES)".
        aux_returnvl = "NOK".

    ValidaExclui: DO ON ERROR UNDO ValidaExclui, LEAVE ValidaExclui:

        ASSIGN par_flgcreca = FALSE
               par_tipconfi = 1 /* EXCLUSAO DE TITULARES */
               par_msgconfi = "ATENCAO! TODOS os titulares " +
                              "(exceto o 1o) serao apagados." .

        ASSIGN par_dscritic = "".

        LEAVE ValidaExclui.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Valida_Dados_Solicita:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpendass AS INTE                                    NO-UNDO.
    
    
    ASSIGN 
        par_dscritic = "Erro ao validar os dados (SOLICITA/REATIVA ITG)".
        aux_returnvl = "NOK".

    ValidaSolicita: DO ON ERROR UNDO ValidaSolicita, LEAVE ValidaSolicita:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN par_dscritic = "Associado nao cadastrado.".
                LEAVE ValidaSolicita.
            END.

        ASSIGN aux_tpendass = IF crapass.inpessoa = 1 THEN 10 ELSE 9.

        FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                crapenc.nrdconta = par_nrdconta AND
                                crapenc.idseqttl = 1            AND
                                crapenc.tpendass = aux_tpendass 
                                NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapenc  THEN
            DO:
                ASSIGN par_dscritic = "Cooperado sem endereco cadastrado.".
                LEAVE ValidaSolicita.
            END.

        IF crapenc.dtinires = ? THEN
           DO:
              ASSIGN par_dscritic =  "Inicio de Residencia nao informado. " + 
                                     "Verifique rotina ENDERECO.".
              LEAVE ValidaSolicita.
           
           END.

        IF  NOT CAN-FIND(FIRST crapdne 
                         WHERE crapdne.nrceplog = crapenc.nrcepend)  OR 
            NOT CAN-FIND(FIRST crapdne
                         WHERE crapdne.nrceplog = crapenc.nrcepend  
                           AND (TRIM(crapenc.dsendere) MATCHES 
                               ("*" + TRIM(crapdne.nmextlog) + "*")
                            OR TRIM(crapenc.dsendere) MATCHES
                               ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
            DO:
                ASSIGN par_dscritic = "CEP/Endereco nao conferem, efetuar " +
                                      "revisao cadastral.".
                LEAVE ValidaSolicita.
            END.

        ASSIGN par_msgconfi = ""
               par_dscritic = "".

        LEAVE ValidaSolicita.
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
    DEF  INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_tpevento AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgcreca AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcochq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgiddep AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_tpavsdeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnsscr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnsspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdsdspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inadimpl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inlbacen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgexclu AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_flgrestr AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_indserma AS LOG                            NO-UNDO.
	DEF  INPUT PARAM par_idastcjt AS INTE							NO-UNDO.
	
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsrotina AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdorgant AS INT                                     NO-UNDO.
    DEF VAR aux_cdageant AS INT                                     NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0110 AS HANDLE                                  NO-UNDO.
    
    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO. 
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                           ELSE IF par_cddopcao = "I" THEN
                                "Inclui" ELSE "Altera") + 
                          " dados da Conta Corrente"
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsrotina = ""
           aux_returnvl = "NOK"
           aux_nmarqimp = ""
           aux_nmarqpdf = ""
           aux_cdorgant = 0
           aux_nmdcampo = ""
           aux_cdageant = 0.


    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        EMPTY TEMP-TABLE tt-erro.   
                     
        ContadorAss: DO  aux_contador = 1 TO 10:

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                               crapass.nrdconta = par_nrdconta 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE crapass THEN
                DO:
                    IF  LOCKED(crapass) THEN
                        DO:
                           IF  aux_contador = 10 THEN
                               DO:
                                  ASSIGN aux_cdcritic = 72.
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
                           ASSIGN aux_cdcritic = 9.
                           LEAVE ContadorAss.
                        END.
                END.
            ELSE 
                LEAVE ContadorAss.
        END.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        EMPTY TEMP-TABLE tt-conta-corr-ant.
        EMPTY TEMP-TABLE tt-conta-corr-atl.

        CREATE tt-conta-corr-ant.
        BUFFER-COPY crapass TO tt-conta-corr-ant.

        ASSIGN aux_cdageant = crapass.cdagenci.

        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                           crapttl.nrdconta = par_nrdconta AND
                           crapttl.idseqttl = par_idseqttl
                           NO-LOCK NO-ERROR.

        { sistema/generico/includes/b1wgenalog.i }

        CASE par_tpevento:
            WHEN "A" THEN DO: /* ALTERA */
                RUN Grava_Dados_Altera
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT par_cdagenci,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,  
                      INPUT par_idorigem,
                      INPUT par_nrdcaixa,
                      INPUT par_nmdatela,					  
                      INPUT 2, /*tpaltera*/
                      INPUT par_cdtipcta,  
                      INPUT par_cdsitdct,  
                      INPUT par_cdsecext,  
                      INPUT par_tpextcta,  
                      INPUT par_cdagepac,  
                      INPUT par_cdbcochq,  
                      INPUT par_flgiddep,  
                      INPUT par_tpavsdeb,  
                      INPUT par_dtcnsscr,  
                      INPUT par_dtcnsspc,  
                      INPUT par_dtdsdspc,  
                      INPUT par_inadimpl,  
                      INPUT par_inlbacen,
                      INPUT par_flgrestr,
                      INPUT par_indserma,
					  INPUT par_idastcjt,
                      BUFFER crapass,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ) NO-ERROR.   
                 
                {&VERIFICA-ERRO}
                
                /* obteve informacao durante a alteracao que eh preciso
                   excluir os demais titulares */
                IF  RETURN-VALUE = "OK" AND par_flgexclu THEN
                    DO: 
                       RUN Grava_Dados_Exclui
                           ( INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT aux_dsorigem,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,  
                             INPUT par_dtmvtolt,
                             INPUT par_flgcreca,
                             BUFFER crapass,
                            OUTPUT aux_cdcritic,
                            OUTPUT aux_dscritic ) NO-ERROR.
    
                       {&VERIFICA-ERRO}
                    END.
            END.
            WHEN "E" THEN DO: /* ENCERRA ITG */
                RUN Grava_Dados_Encerra
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,  
                      INPUT par_cdoperad,  
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      BUFFER crapass,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ) NO-ERROR.

                {&VERIFICA-ERRO}
            END.
            WHEN "X" THEN DO: /* EXCLUI TITULARES */
                RUN Grava_Dados_Exclui
                    ( INPUT par_cdcooper,
                      INPUT par_cdoperad,
                      INPUT aux_dsorigem,
                      INPUT par_nmdatela,
                      INPUT par_nrdconta,  
                      INPUT par_dtmvtolt,
                      INPUT par_flgcreca,
                      BUFFER crapass,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ) NO-ERROR.

                {&VERIFICA-ERRO}
            END.
            WHEN "S" THEN DO: /* SOLICITA ITG */
                RUN Grava_Dados_Solicita
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,  
                      INPUT par_cdoperad,  
                      INPUT par_dtmvtolt,
                      INPUT 2,
                      BUFFER crapass,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic ) NO-ERROR.

                {&VERIFICA-ERRO}
            END.
            OTHERWISE 
                ASSIGN aux_dscritic = "O Tipo de Evento de gravacao deve "  +
                                      "ser (A)-Alteracao, (E)-Encerrar ITG" +
                                      ", (X)-Excluir Titulares ou (S)-Soli" +
                                      "citar ITG". 
        END CASE.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.
        
        CREATE tt-conta-corr-atl.
        BUFFER-COPY crapass TO tt-conta-corr-atl.

        { sistema/generico/includes/b1wgenllog.i }

        /*Se o processo do BI ainda estiver rodando, nao pode-se alterar o PA */
        IF aux_cdageant <> crapass.cdagenci THEN 
          DO:
          FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
          IF AVAIL crapdat THEN
             IF crapdat.inprocbi = 2 THEN 
                DO:
                  ASSIGN aux_dscritic = "Processo do BI ainda em execucao. Alteracao de PA nao permitida!".
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,          /** Sequencia **/
                                  INPUT 0,
                                  INPUT-OUTPUT aux_dscritic).
                            
                  UNDO Grava, LEAVE Grava.
                END.
          END.

        /*Se a troca de PA ocorrer com sucesso entao, se for pessoa fisica, 
          sera enviado uma solicitacao ao SICREDI de alteracao do orgao 
          pagador de todos os beneficios do cpf em questao. Caso ocorra algum
          erro durante a consulta do benefício ou, na alteraçao deste, a 
          transacao sera desfeita para que a alteracao do PA nao seja 
          efetuada.*/
        IF aux_cdageant <> crapass.cdagenci AND 
           crapass.inpessoa = 1             THEN
           DO:   
              /* Busca todos os beneficios do cpf em questao */
              FOR EACH crapdbi WHERE crapdbi.nrcpfcgc = crapass.nrcpfcgc
                                     NO-LOCK:

                  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 

                  /* Efetuar a chamada da rotina Oracle */ 
                  RUN STORED-PROCEDURE pc_solic_consulta_benef_car
                      aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, 
                                                          INPUT par_cdagenci, 
                                                          INPUT par_nrdcaixa, 
                                                          INPUT par_idorigem, 
                                                          INPUT par_dtmvtolt, 
                                                          INPUT par_nmdatela, 
                                                          INPUT par_cdoperad, 
                                                          INPUT par_cddopcao, 
                                                          INPUT crapdbi.nrcpfcgc,
                                                          INPUT crapdbi.nrrecben,
                                                          OUTPUT "",  /*Nome do Campo*/
                                                          OUTPUT "", /*Saida OK/NOK*/
                                                          OUTPUT ?, /*Tabela Beneficiarios*/
                                                          OUTPUT 0, /*Codigo da critica*/
                                                          OUTPUT ""). /*Descricao da critica*/
                  
                  /* Fechar o procedimento para buscarmos o resultado */ 
                  CLOSE STORED-PROC pc_solic_consulta_benef_car
                         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                  
                  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                  /* Busca possíveis erros */ 
                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = ""
                         aux_cdcritic = pc_solic_consulta_benef_car.pr_cdcritic 
                                        WHEN pc_solic_consulta_benef_car.pr_cdcritic <> ?
                         aux_dscritic = pc_solic_consulta_benef_car.pr_dscritic 
                                        WHEN pc_solic_consulta_benef_car.pr_dscritic <> ?.
                  
                  IF aux_cdcritic <> 0  OR
                     aux_dscritic <> "" THEN
                     DO:
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,          /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                   
                        UNDO Grava, LEAVE Grava.
                   
                     END.
                   
                  EMPTY TEMP-TABLE tt-dados-beneficiario.

                  /*Leitura do XML de retorno da proc e criacao dos registros na tt-beneficiario
                   para visualizacao dos registros na tela */
                   
                  /* Buscar o XML na tabela de retorno da procedure Progress */ 
                  ASSIGN xml_req = pc_solic_consulta_benef_car.pr_clob_ret. 
                      
                  /* Efetuar a leitura do XML*/ 
                  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
                  PUT-STRING(ponteiro_xml,1) = xml_req. 
                  
                  /* Inicializando objetos para leitura do XML */ 
                  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
                  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
                  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
                  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
                  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
                  
                  IF ponteiro_xml <> ? THEN
                     DO:
                        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
                     
                        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
                     
                           xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                     
                           IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                              NEXT. 
                           
                           IF xRoot2:NUM-CHILDREN > 0 THEN
                             CREATE tt-dados-beneficiario.
                     
                           DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                               
                              xRoot2:GET-CHILD(xField,aux_cont).
                                  
                              IF xField:SUBTYPE <> "ELEMENT" THEN 
                                 NEXT. 
                              
                              xField:GET-CHILD(xText,1).
                  
                              ASSIGN tt-dados-beneficiario.idbenefi = INT(xText:NODE-VALUE) WHEN xField:NAME = "idbenefi".
                              ASSIGN tt-dados-beneficiario.dtdcadas = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdcadas".
                              ASSIGN tt-dados-beneficiario.nmbenefi = xText:NODE-VALUE WHEN xField:NAME = "nmbenefi".
                              ASSIGN tt-dados-beneficiario.dtdnasci = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdnasci".
                              ASSIGN tt-dados-beneficiario.tpdosexo = xText:NODE-VALUE WHEN xField:NAME = "tpdosexo".
                              ASSIGN tt-dados-beneficiario.dtutirec = INT(xText:NODE-VALUE) WHEN xField:NAME = "dtutirec".
                              ASSIGN tt-dados-beneficiario.dscsitua = xText:NODE-VALUE WHEN xField:NAME = "dscsitua".
                              ASSIGN tt-dados-beneficiario.dtdvenci = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdvenci".
                              ASSIGN tt-dados-beneficiario.dtcompvi = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtcompvi".
                              ASSIGN tt-dados-beneficiario.tpdpagto = xText:NODE-VALUE WHEN xField:NAME = "tpdpagto".
                              ASSIGN tt-dados-beneficiario.cdorgins = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdorgins".
                              ASSIGN tt-dados-beneficiario.nomdamae = xText:NODE-VALUE WHEN xField:NAME = "nomdamae".
                              ASSIGN tt-dados-beneficiario.nrdddtfc = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdddtfc".
                              ASSIGN tt-dados-beneficiario.nrtelefo = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrtelefo".
                              ASSIGN tt-dados-beneficiario.nrrecben = DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrrecben".
                              ASSIGN tt-dados-beneficiario.tpnrbene = xText:NODE-VALUE WHEN xField:NAME = "tpnrbene".
                              ASSIGN tt-dados-beneficiario.cdcooper = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcooper".
                              ASSIGN tt-dados-beneficiario.cdcopsic = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdcopsic".
                              ASSIGN tt-dados-beneficiario.nruniate = INT(xText:NODE-VALUE) WHEN xField:NAME = "nruniate".
                              ASSIGN tt-dados-beneficiario.nrcepend = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrcepend".
                              ASSIGN tt-dados-beneficiario.dsendere = xText:NODE-VALUE WHEN xField:NAME = "dsendere".
                              ASSIGN tt-dados-beneficiario.nrendere = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrendere".
                              ASSIGN tt-dados-beneficiario.nmbairro = xText:NODE-VALUE WHEN xField:NAME = "nmbairro".
                              ASSIGN tt-dados-beneficiario.nmcidade = xText:NODE-VALUE WHEN xField:NAME = "nmcidade".
                              ASSIGN tt-dados-beneficiario.cdufende = xText:NODE-VALUE WHEN xField:NAME = "cdufende".
                              ASSIGN tt-dados-beneficiario.nrcpfcgc = xText:NODE-VALUE WHEN xField:NAME = "nrcpfcgc".
                              ASSIGN tt-dados-beneficiario.resdesde = DATE(xText:NODE-VALUE) WHEN xField:NAME = "resdesde".
                              ASSIGN tt-dados-beneficiario.dscespec = xText:NODE-VALUE WHEN xField:NAME = "dscespec".
                              ASSIGN tt-dados-beneficiario.nrdconta = xText:NODE-VALUE WHEN xField:NAME = "nrdconta".
                              ASSIGN tt-dados-beneficiario.digdacta = xText:NODE-VALUE WHEN xField:NAME = "digdacta".
                              ASSIGN tt-dados-beneficiario.nmprocur = xText:NODE-VALUE WHEN xField:NAME = "nmprocur".
                              ASSIGN tt-dados-beneficiario.cdagesic = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagesic".
                              ASSIGN tt-dados-beneficiario.cdagepac = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagepac".
                              ASSIGN tt-dados-beneficiario.nrdocpro = xText:NODE-VALUE WHEN xField:NAME = "nrdocpro".
                              ASSIGN tt-dados-beneficiario.nmresage = xText:NODE-VALUE WHEN xField:NAME = "nmresage".
                              ASSIGN tt-dados-beneficiario.razaosoc = xText:NODE-VALUE WHEN xField:NAME = "razaosoc".
                              ASSIGN tt-dados-beneficiario.nmextttl = xText:NODE-VALUE WHEN xField:NAME = "nmextttl".
                              ASSIGN tt-dados-beneficiario.idseqttl = INT(xText:NODE-VALUE) WHEN xField:NAME = "idseqttl".
                              ASSIGN tt-dados-beneficiario.copvalid = INT(xText:NODE-VALUE) WHEN xField:NAME = "copvalid".
                              ASSIGN tt-dados-beneficiario.nrcpfttl = DEC(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfttl".
                              ASSIGN tt-dados-beneficiario.dsendttl = xText:NODE-VALUE WHEN xField:NAME = "dsendttl".
                              ASSIGN tt-dados-beneficiario.nrendttl = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrendttl".
                              ASSIGN tt-dados-beneficiario.nrcepttl = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrcepttl".
                              ASSIGN tt-dados-beneficiario.nmbaittl = xText:NODE-VALUE WHEN xField:NAME = "nmbaittl".
                              ASSIGN tt-dados-beneficiario.nmcidttl = xText:NODE-VALUE WHEN xField:NAME = "nmcidttl".
                              ASSIGN tt-dados-beneficiario.ufendttl = xText:NODE-VALUE WHEN xField:NAME = "ufendttl".
                              ASSIGN tt-dados-beneficiario.nrdddttl = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdddttl".
                              ASSIGN tt-dados-beneficiario.nrtelttl = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrtelttl".
                              ASSIGN tt-dados-beneficiario.stacadas = xText:NODE-VALUE WHEN xField:NAME = "stacadas".
                                             
                           END. 
                            
                        END.
                     
                        SET-SIZE(ponteiro_xml) = 0. 
                  
                     END.
                     
                  /*Elimina os objetos criados*/
                  DELETE OBJECT xDoc. 
                  DELETE OBJECT xRoot. 
                  DELETE OBJECT xRoot2. 
                  DELETE OBJECT xField. 
                  DELETE OBJECT xText.
                  
                  FIND FIRST tt-dados-beneficiario NO-LOCK NO-ERROR.
                  
                  IF NOT AVAIL tt-dados-beneficiario THEN
                     LEAVE.
                  
                  /*Foi acorado com a area de compensacao que se for solicitado
                    a troca de PA para um cooperado, no qual seu beneficio
                    esteja com status de "Aguardando atualizacao", iremos
                    ignorar a troca de PA deste beneficio em questao e deixar
                    atualizar o PA da conta do cooperado normalmente. Mesmo
                    que fique divergente ao SICREDI.*/
                  IF CAPS(tt-dados-beneficiario.stacadas) MATCHES "*AGUARDANDO*" THEN
                     NEXT.

                  /*Busca o orgao pagador anterior*/
                  FIND crapage WHERE crapage.cdcooper = crapass.cdcooper AND
                                     crapage.cdagenci = aux_cdageant
                                     NO-LOCK NO-ERROR.
                  
                  IF NOT AVAIL crapage  THEN
                     DO:
                         ASSIGN aux_cdcritic = 962.
                         LEAVE.
                  
                     END.

                  ASSIGN aux_cdorgant = crapage.cdorgins.
                  
                  /*
                  O SICREDI alterou apenas a cooperativa dos beneficiarios migrados
                  deixando estes, com a conta da concredi. Desta forma, foi necessario
                  realizar a verificacao abaixo para contornar a situacao
                  ate que o SICREDI efetue o cadastro para a nova conta.
                  1 - 201 775431
                  2 - 202 775448
                  Verifica se eh um OP da Concredi migrado para Viacredi*/
                  IF INT(tt-dados-beneficiario.cdorgins) = 775431 OR 
                     INT(tt-dados-beneficiario.cdorgins) = 775448 THEN
                     DO: 
                        /*Verifica se o beneficiario eh um cooperado migrado da Concredi
                          para Viacredi.*/
                        FIND FIRST craptco 
                             WHERE (craptco.cdcopant = 4                        AND
                                    craptco.nrctaant = INT(tt-dados-beneficiario.nrdconta) AND
                                    craptco.tpctatrf = 1                        AND
                                    craptco.cdcooper = 1                        AND
                                    craptco.flgativo = TRUE)                    OR
                                   (craptco.cdcopant = 4                        AND
                                    craptco.nrdconta = int(tt-dados-beneficiario.nrdconta) AND
                                    craptco.tpctatrf = 1                        AND
                                    craptco.cdcooper = 1                        AND
                                    craptco.flgativo = TRUE)                
                                    NO-LOCK NO-ERROR.
                  
                        IF AVAIL craptco THEN
                           DO:
                              /*Se o beneficio nao for da Coop/PA/Conta em questao entao, 
                                despreza.*/
                              IF craptco.cdcooper <> crapass.cdcooper           OR
                                 tt-dados-beneficiario.cdorgins <> aux_cdorgant OR
                                 craptco.nrdconta <> crapass.nrdconta THEN
                                 NEXT.
                           END.
                        ELSE
                           /*Se o beneficio nao for da Coop/PA/Conta em questao entao, 
                             despreza.*/
                           IF tt-dados-beneficiario.cdcooper <> crapass.cdcooper      OR
                              tt-dados-beneficiario.cdorgins <> aux_cdorgant          OR
                              INT(tt-dados-beneficiario.nrdconta) <> crapass.nrdconta THEN
                              NEXT.
                  
                     END.
                  ELSE
                     /*Se o NB for da mesma cooperativa e mesma conta entao, efetua
                       a troca de OP do NB independente do OP que o mesmo esteja
                       cadastrado no SICREDI.*/
                     IF tt-dados-beneficiario.cdcooper = crapass.cdcooper      AND
                        INT(tt-dados-beneficiario.nrdconta) = crapass.nrdconta THEN
                        DO:  
                           /*Busca o orgao pagador atual*/
                           FIND crapage WHERE crapage.cdcooper = crapass.cdcooper AND
                                              crapage.cdagenci = crapass.cdagenci
                                              NO-LOCK NO-ERROR.
                           
                           IF NOT AVAIL crapage THEN
                              DO:
                                  ASSIGN aux_cdcritic = 962.
                                  LEAVE.
                           
                              END.
                           
                           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl}}
                               
                           /* Efetuar a chamada da rotina Oracle para efetuar a troca
                              de OP dos beneficios pertencentes ao cooperado em questao.
                              
                              OBS.: Se nao for possivel alterar o OP por qualquer
                                    motivo, seja regra de negocio ou erro, nao iremos 
                                    abortar o processo de gravacao dos dados mesmo que o cooperado
                                    passe a estar em outro PA/OP e o seu beneficio continue
                                    com PA/OP antigo.
                                    Isto foi acordado entre TI e COMPE.*/ 
                           
                           /* Efetuar a chamada da rotina Oracle */ 
                           RUN STORED-PROCEDURE pc_solic_troca_op_cc_car 
                                     aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                                                          INPUT par_cdagenci,
                                                                          INPUT par_nrdcaixa,
                                                                          INPUT par_idorigem,
                                                                          INPUT par_nmdatela,
                                                                          INPUT STRING(par_dtmvtolt,"99/99/9999"),
                                                                          INPUT par_cdoperad,
                                                                          INPUT par_cddopcao,
                                                                          INPUT crapage.cdorgins,
                                                                          INPUT aux_cdorgant,
                                                                          INPUT crapdbi.nrrecben,
                                                                          INPUT tt-dados-beneficiario.tpnrbene,
                                                                          INPUT tt-dados-beneficiario.tpdpagto,
                                                                          INPUT tt-dados-beneficiario.dscsitua,
                                                                          INPUT crapass.nrdconta,
                                                                          INPUT 0, /*nrctaant*/
                                                                          INPUT crapage.cdagenci,
                                                                          INPUT tt-dados-beneficiario.idbenefi,
                                                                          INPUT crapdbi.nrcpfcgc,
                                                                          INPUT crapdbi.nrcpfcgc,
                                                                          INPUT tt-dados-beneficiario.idseqttl,
                                                                          INPUT tt-dados-beneficiario.nmbairro,
                                                                          INPUT tt-dados-beneficiario.nrcepend,
                                                                          INPUT tt-dados-beneficiario.dsendere,
                                                                          INPUT tt-dados-beneficiario.nrendere,
                                                                          INPUT tt-dados-beneficiario.nmcidade,
                                                                          INPUT tt-dados-beneficiario.cdufende,
                                                                          INPUT tt-dados-beneficiario.cdagesic,
                                                                          INPUT tt-dados-beneficiario.nmbenefi,
                                                                          INPUT (IF tt-dados-beneficiario.dtcompvi = ? THEN
                                                                                    ""
                                                                                 ELSE
                                                                                    STRING(tt-dados-beneficiario.dtcompvi)),
                                                                          INPUT tt-dados-beneficiario.nrdddtfc,
                                                                          INPUT tt-dados-beneficiario.nrtelefo,
                                                                          INPUT (IF tt-dados-beneficiario.tpdosexo = "MASCULINO" THEN 
                                                                                    1
                                                                                 ELSE
                                                                                    2),
                                                                          INPUT tt-dados-beneficiario.nomdamae,
                                                                          INPUT INT(par_flgerlog),
                                                                          INPUT "", /*dsiduser*/
                                                                          OUTPUT "", /*nmarqimp*/
                                                                          OUTPUT "", /*nmarqpdf*/
                                                                          OUTPUT 0, /*Código da crítica*/
                                                                          OUTPUT "", /*Descrição da crítica*/
                                                                          OUTPUT "", /*Nome do Campo*/
                                                                          OUTPUT ""). /*Saida OK/NOK*/
                           
                           
                           /* Fechar o procedimento para buscarmos o resultado */ 
                           CLOSE STORED-PROC pc_solic_troca_op_cc_car
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                           
                           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                           
                           /* Busca possíveis erros */ 
                           ASSIGN aux_cdcritic = 0
                                  aux_dscritic = ""
                                  aux_cdcritic = pc_solic_troca_op_cc_car.pr_cdcritic 
                                                 WHEN pc_solic_troca_op_cc_car.pr_cdcritic <> ?
                                  aux_dscritic = pc_solic_troca_op_cc_car.pr_dscritic 
                                                 WHEN pc_solic_troca_op_cc_car.pr_dscritic <> ?.
                           
                           IF aux_cdcritic <> 0  OR
                              aux_dscritic <> "" THEN
                              DO:
                                 RUN gera_erro (INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT 1,          /** Sequencia **/
                                                INPUT aux_cdcritic,
                                                INPUT-OUTPUT aux_dscritic).
                            
                                 UNDO Grava, LEAVE Grava.
                            
                              END.

                        END. /*Fim IF troca OP*/

              END. /*Fim for each crapdbi*/
                   
              IF aux_cdcritic <> 0  OR 
                 aux_dscritic <> "" THEN
                 UNDO Grava, LEAVE Grava.
              
           END. /*Fim IF troca de PA*/
        
        ASSIGN aux_returnvl = "OK".

        LEAVE Grava.

    END.
    
    IF  AVAILABLE crapass  THEN
        FIND CURRENT crapass NO-LOCK NO-ERROR.

    RELEASE crapass.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
           ASSIGN aux_returnvl = "NOK".

           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,           
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).
        END.

    IF aux_returnvl = "OK" THEN
       DO:
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
             
                ASSIGN aux_returnvl = "NOK".
             
             END.

          ASSIGN aux_dsrotina = "Alteracao na conta corrente do "           +
                                STRING(par_idseqttl) + "o titular da conta "+
                                STRING(crapass.nrdconta,"zzzz,zzz,9")       +
                                " - CPF/CNPJ "                              +
                                (IF crapass.inpessoa = 1 THEN 
                                    STRING((STRING(crapass.nrcpfcgc,
                                            "99999999999")),"xxx.xxx.xxx-xx")
                                 ELSE
                                    STRING((STRING(crapass.nrcpfcgc,
                                                   "99999999999999")),
                                                   "xx.xxx.xxx/xxxx-xx")).

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
                                            INPUT par_idseqttl,
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 31,    /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).
         
          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE h-b1wgen0110.
         
          IF RETURN-VALUE <> "OK" THEN
             DO:  
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
                IF NOT AVAIL tt-erro THEN
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
                ELSE
                   ASSIGN aux_dscritic = tt-erro.dscritic.
                 
                ASSIGN aux_returnvl = "NOK".
         
             END.

       END.

    IF  par_flgerlog THEN
        RUN proc_gerar_log_tab
            ( INPUT par_cdcooper,
              INPUT par_cdoperad,
              INPUT aux_dscritic,
              INPUT aux_dsorigem,
              INPUT aux_dstransa,
              INPUT (IF aux_returnvl = "OK" THEN TRUE ELSE FALSE),
              INPUT par_idseqttl,
              INPUT par_nmdatela,
              INPUT par_nrdconta,
              INPUT YES,
              INPUT BUFFER tt-conta-corr-ant:HANDLE,
              INPUT BUFFER tt-conta-corr-atl:HANDLE ).

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Grava_Dados_Altera:

    /* Logica extraida da procedure atualiza_dados */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
	DEF  INPUT PARAM par_nmdatela AS CHAR							NO-UNDO.
    DEF  INPUT PARAM par_tpaltera AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsecext AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagepac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdbcochq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgiddep AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_tpavsdeb AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnsscr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnsspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdsdspc AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inadimpl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inlbacen AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgrestr AS LOG                            NO-UNDO.
    DEF  INPUT PARAM par_indserma AS LOG                            NO-UNDO.
	DEF  INPUT PARAM par_idastcjt AS INTE							NO-UNDO.
	
    DEF PARAM BUFFER crabass FOR crapass.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_ctdpoder AS INTE                                    NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER brapttl FOR crapttl.
    DEF BUFFER crabreq FOR crapreq.
    DEF BUFFER crabavs FOR crapavs.
    DEF BUFFER crabrda FOR craprda.
    DEF BUFFER crabrpp FOR craprpp.
    DEF BUFFER crabext FOR crapext.
    
    ASSIGN aux_returnvl = "NOK".
    

    GravaAltera: DO TRANSACTION
        ON ERROR  UNDO GravaAltera, LEAVE GravaAltera
        ON QUIT   UNDO GravaAltera, LEAVE GravaAltera
        ON STOP   UNDO GravaAltera, LEAVE GravaAltera
        ON ENDKEY UNDO GravaAltera, LEAVE GravaAltera:

        IF NOT AVAILABLE crabass THEN
           DO:
              ASSIGN par_dscritic = "Buffer da tabela de Associados nao " + 
                                    "esta disponivel.".
              LEAVE GravaAltera.
           END.

         /* Chamado 373200 */
        IF par_cdtipcta <> 5 THEN
          IF crabass.dtabtcct = ? THEN
            ASSIGN crabass.dtabtcct = par_dtmvtolt.

        /* Se estiver alterando o tipo de conta ou estiver cadastrando ... */
        IF par_cdtipcta <> crabass.cdtipcta   OR
           crabass.dtinsori = par_dtmvtolt    THEN
           DO:  
                /* Removido a criação da doc conforme solicitado no chamado 372880*/
                /*ContadorDoc7: DO aux_contador = 1 TO 10:
                
                   FIND crapdoc WHERE crapdoc.cdcooper = par_cdcooper AND
                                      crapdoc.nrdconta = par_nrdconta AND
                                      crapdoc.tpdocmto = 7            AND
                                      crapdoc.dtmvtolt = par_dtmvtolt AND
                                      crapdoc.idseqttl = 1
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
                                        NEXT ContadorDoc7.
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
                                         crapdoc.idseqttl = 1.
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
                END.*/
                 

              /* Mudando para Conta Integracao */
              IF par_cdtipcta >= 12 AND par_cdtipcta <= 18  THEN
                 DO:
                    /* solicitar_itg */
                    RUN Grava_Dados_Solicita(INPUT par_cdcooper,
                                             INPUT par_nrdconta,  
                                             INPUT par_cdoperad,  
                                             INPUT par_dtmvtolt,
                                             INPUT 2,
                                             BUFFER crabass,
                                             OUTPUT par_cdcritic,
                                             OUTPUT par_dscritic ) NO-ERROR.
                  
                    IF par_cdcritic <> 0 OR par_dscritic <> "" THEN
                       UNDO GravaAltera, LEAVE GravaAltera.

                    {&VERIFICA-ERRO}

                 END.

              FOR EACH crapreq WHERE crapreq.cdcooper = par_cdcooper AND
                                     crapreq.cdagenci = par_cdagepac AND
                                     crapreq.nrdconta = par_nrdconta AND
                                     /* nao processadas */
                                     CAN-DO("1,4,5",STRING(crapreq.insitreq))
                                     NO-LOCK:

                  ContadorReq: DO aux_contador = 1 TO 10:

                      FIND crabreq WHERE ROWID(crabreq) = ROWID(crapreq)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabreq THEN
                         DO:
                            IF LOCKED(crabreq) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 341.
                                        LEAVE ContadorReq.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorReq.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorReq.

                  END. /* ContadorReq */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  IF crabass.cdtipcta > 11 AND crabass.nrdctitg = "" THEN
                     DELETE crabreq.
                  ELSE
                     /* So atualiza o tipo se forem contas com talao */
                     IF  par_cdtipcta > 7 THEN
                         ASSIGN crabreq.cdtipcta = par_cdtipcta.

              END. /*  Fim do FOR EACH  */

              /* Caso nao tenha conta integracao ativa e esteja mudando o 
                 tipo de conta para os tipos BANCOOB, cria uma requisicao */
              IF crabass.flgctitg <> 2                    AND /* Ativa */
                 (par_cdtipcta = 08 OR par_cdtipcta = 09  OR
                  par_cdtipcta = 10 OR par_cdtipcta = 11) THEN
                  DO:
                     FIND FIRST crapreq WHERE
                                        crapreq.cdcooper = par_cdcooper AND
                                        crapreq.cdagenci = par_cdagepac AND
                                        crapreq.nrdconta = par_nrdconta AND
                                        crapreq.cdtipcta = par_cdtipcta AND
                                        /* nao processadas */
                                        CAN-DO("1,4,5",
                                               STRING(crapreq.insitreq))
                                        NO-LOCK NO-ERROR.

                     IF NOT AVAILABLE crapreq THEN
                        DO:
                           /************  CRIA  A  REQUISICAO  ***********/
                           DO aux_contador = 1 TO 10:

                              FIND craptrq WHERE
                                   craptrq.cdcooper = par_cdcooper AND
                                   craptrq.tprequis = 1            AND
                                   craptrq.cdagelot = par_cdagepac AND
                                   craptrq.nrdolote = 10000
                                   USE-INDEX craptrq1 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                              IF NOT AVAILABLE craptrq   THEN
                                 IF LOCKED craptrq   THEN
                                    DO:
                                        IF aux_contador = 10 THEN
                                           DO:
                                              ASSIGN par_cdcritic = 341.
                                              LEAVE.
                                           END.
                                        ELSE 
                                           DO:
                                               PAUSE 1 NO-MESSAGE.
                                               NEXT.
                                           END.
                                    END.
                                 ELSE
                                    DO:
                                       CREATE craptrq.
                                       ASSIGN craptrq.cdagelot = par_cdagepac
                                              craptrq.nrdolote = 10000
                                              craptrq.tprequis = 1
                                              craptrq.cdcooper = par_cdcooper.
                                       VALIDATE craptrq.

                                     END.

                              LEAVE.

                           END.  /*  Fim do DO ... TO  */

                           IF par_cdcritic <> 0  THEN
                              UNDO GravaAltera, LEAVE GravaAltera.

                           CREATE crapreq.
                           ASSIGN crapreq.nrseqdig = craptrq.nrseqdig + 1
                                  crapreq.nrdconta = par_nrdconta
                                  crapreq.cdtipcta = par_cdtipcta
                                  crapreq.nrdctabb = par_nrdconta
                                  crapreq.cdagelot = craptrq.cdagelot
                                  crapreq.nrdolote = craptrq.nrdolote
                                  crapreq.cdagenci = par_cdagepac
                                  crapreq.nrinichq = 0
                                  crapreq.insitreq = 1 /* Normal */
                                  crapreq.nrfinchq = 0
                                  crapreq.dtmvtolt = par_dtmvtolt
                                  crapreq.tprequis = 1
                                  crapreq.cdcooper = par_cdcooper
                                  crapreq.qtreqtal = 1
                                  craptrq.nrseqdig = crapreq.nrseqdig
                                  craptrq.qtinforq = craptrq.qtinforq + 1
                                  craptrq.qtcomprq = craptrq.qtcomprq + 1
                                  craptrq.qtinfotl = craptrq.qtinfotl + 1
                                  craptrq.qtcomptl = craptrq.qtcomptl + 1.
                           VALIDATE crapreq.

                        END.

                  END.

              ContadorAct: DO aux_contador = 1 TO 10:

                  FIND crapact WHERE crapact.cdcooper = par_cdcooper AND
                                     crapact.nrdconta = par_nrdconta AND
                                     crapact.dtalttct = par_dtmvtolt
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                  IF NOT AVAILABLE crapact THEN
                     DO:
                         IF LOCKED(crapact) THEN
                            DO:
                               IF aux_contador = 10 THEN
                                  DO: 
                                     ASSIGN par_cdcritic = 72.
                                     LEAVE ContadorAct.
                                  END.
                               ELSE 
                                  DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT ContadorAct.
                                  END.

                            END.
                         ELSE 
                            DO:
                               CREATE crapact.
                               ASSIGN crapact.nrdconta = par_nrdconta
                                      crapact.dtalttct = par_dtmvtolt
                                      crapact.cdtctant = crabass.cdtipcta
                                      crapact.cdtctatu = par_cdtipcta
                                      crabass.dtatipct = par_dtmvtolt
                                      crapact.cdcooper = par_cdcooper.
                               VALIDATE crapact.

                               LEAVE ContadorAct.

                            END.

                     END.
                  ELSE 
                     DO:
                        ASSIGN crapact.cdtctatu = par_cdtipcta.

                        IF  crapact.cdtctant = crapact.cdtctatu THEN
                            DELETE crapact.

                        LEAVE ContadorAct.

                     END.

              END. /* ContadorAct */

              IF par_cdcritic <> 0 THEN
                 UNDO GravaAltera, LEAVE GravaAltera.

              ContadorNeg: DO aux_contador = 1 TO 10:

                  FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                                     crapneg.nrdconta = par_nrdconta AND
                                     crapneg.dtiniest = par_dtmvtolt AND
                                     crapneg.cdhisest = 2 USE-INDEX crapneg2 
                                     EXCLUSIVE-LOCK NO-WAIT NO-ERROR.

                  IF NOT AVAILABLE crapneg THEN
                     DO:
                         IF LOCKED(crapneg) THEN
                            DO:
                               IF aux_contador = 10 THEN
                                  DO: 
                                     ASSIGN par_cdcritic = 72.
                                     LEAVE ContadorNeg.
                                  END.
                               ELSE 
                                  DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT ContadorNeg.
                                  END.

                            END.
                         ELSE 
                            DO:
                                /* Busca a proxima sequencia do campo CRAPNEG.NRSEQDIG */
                            	RUN STORED-PROCEDURE pc_sequence_progress
                            	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
                            										,INPUT "NRSEQDIG"
                            										,INPUT STRING(par_cdcooper) + ";" + STRING(par_nrdconta)
                            										,INPUT "N"
                            										,"").
                            	
                            	CLOSE STORED-PROC pc_sequence_progress
                            	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                            			  
                            	ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                            						  WHEN pc_sequence_progress.pr_sequence <> ?.

                               CREATE crapneg.
                               ASSIGN crapneg.cdhisest = 2
                                      crapneg.cdobserv = 0
                                      crapneg.dtiniest = par_dtmvtolt
                                      crapneg.nrdconta = par_nrdconta
                                      crapneg.nrdctabb = 0
                                      crapneg.nrdocmto = 0
                                      crapneg.nrseqdig = aux_nrseqdig
                                      crapneg.qtdiaest = 0
                                      crapneg.vlestour = 0
                                      crapneg.vllimcre = crabass.vllimcre
                                      crapneg.cdtctant = crabass.cdtipcta
                                      crapneg.cdtctatu = par_cdtipcta
                                      crapneg.dtfimest = ?
                                      crapneg.cdoperad = par_cdoperad
                                      crapneg.cdbanchq = 0
                                      crapneg.cdagechq = 0
                                      crapneg.nrctachq = 0
                                      crapneg.cdcooper = par_cdcooper.
                               VALIDATE crapneg.
                                      
                               LEAVE ContadorNeg.

                            END.

                     END.
                  ELSE 
                     DO:
                        ASSIGN crapneg.cdtctatu = par_cdtipcta.
    
                        IF crapneg.cdtctant = crapneg.cdtctatu THEN
                           DELETE crapneg.

                        LEAVE ContadorNeg.

                     END.

              END. /* ContadorNeg */

              IF par_cdcritic <> 0 THEN
                 UNDO GravaAltera, LEAVE GravaAltera.

           END.

        IF par_cdsitdct <> crabass.cdsitdct THEN
           DO:
		   
		      IF par_cdsitdct = 8 THEN
			     DO:
				    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl}}
                               
				   /* Efetuar a chamada da rotina Oracle */ 
				   RUN STORED-PROCEDURE pc_efetuar_desligamento_bacen 
							 aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
																  INPUT par_nrdconta,
																  INPUT par_idorigem,
																  INPUT par_cdoperad,
																  INPUT par_nrdcaixa,
																  INPUT par_nmdatela,
																  INPUT par_cdagenci,
																  OUTPUT 0, /*Código da crítica*/
																  OUTPUT "", /*Descrição da crítica*/
																  OUTPUT "", /*Nome do Campo*/
																  OUTPUT ""). /*Saida OK/NOK*/
				   				   
				   /* Fechar o procedimento para buscarmos o resultado */ 
				   CLOSE STORED-PROC pc_efetuar_desligamento_bacen
						  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
				   
				   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
				   
				   /* Busca possíveis erros */ 
				   ASSIGN par_cdcritic = 0
						  par_dscritic = ""
						  par_cdcritic = pc_efetuar_desligamento_bacen.pr_cdcritic 
										 WHEN pc_efetuar_desligamento_bacen.pr_cdcritic <> ?
						  par_dscritic = pc_efetuar_desligamento_bacen.pr_dscritic 
										 WHEN pc_efetuar_desligamento_bacen.pr_dscritic <> ?.
				   
				   IF par_cdcritic <> 0  OR
					  par_dscritic <> "" THEN
					  DO:	 
					
						 UNDO GravaAltera, LEAVE GravaAltera.
					
					  END.
				 
				 END.
			  
              ASSIGN crabass.dtasitct = par_dtmvtolt.

              ContadorNeg: DO aux_contador = 1 TO 10:

                  FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                                     crapneg.nrdconta = par_nrdconta AND
                                     crapneg.dtiniest = par_dtmvtolt AND
                                     crapneg.cdhisest = 3 USE-INDEX crapneg2 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                  IF NOT AVAILABLE crapneg THEN
                     DO:
                         IF LOCKED(crapneg) THEN
                            DO:
                               IF aux_contador = 10 THEN
                                  DO:               
                                     ASSIGN par_cdcritic = 72.
                                     LEAVE ContadorNeg.
                                  END.
                               ELSE 
                                  DO:
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT ContadorNeg.
                                  END.

                            END.
                         ELSE 
                            DO:
                                /* Busca a proxima sequencia do campo CRAPNEG.NRSEQDIG */
                            	RUN STORED-PROCEDURE pc_sequence_progress
                            	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
                            										,INPUT "NRSEQDIG"
                            										,INPUT STRING(par_cdcooper) + ";" + STRING(par_nrdconta)
                            										,INPUT "N"
                            										,"").
                            	
                            	CLOSE STORED-PROC pc_sequence_progress
                            	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                            			  
                            	ASSIGN aux_nrseqdig = INTE(pc_sequence_progress.pr_sequence)
                            						  WHEN pc_sequence_progress.pr_sequence <> ?.

                               CREATE crapneg.
                               ASSIGN crapneg.cdhisest = 3
                                      crapneg.cdobserv = 0
                                      crapneg.dtiniest = par_dtmvtolt
                                      crapneg.nrdconta = par_nrdconta
                                      crapneg.nrdctabb = 0
                                      crapneg.nrdocmto = 0
                                      crapneg.nrseqdig = aux_nrseqdig
                                      crapneg.qtdiaest = 0
                                      crapneg.vlestour = 0
                                      crapneg.vllimcre = crabass.vllimcre
                                      crapneg.cdtctant = crabass.cdsitdct
                                      crapneg.cdtctatu = par_cdsitdct
                                      crapneg.dtfimest = ?
                                      crapneg.cdoperad = par_cdoperad
                                      crapneg.cdbanchq = 0
                                      crapneg.cdagechq = 0
                                      crapneg.nrctachq = 0
                                      crapneg.cdcooper = par_cdcooper.
                               VALIDATE crapneg.

                               LEAVE ContadorNeg.

                            END.

                     END.
                  ELSE 
                     DO:
                        ASSIGN crapneg.cdtctatu = crabass.cdsitdct.
    
                        IF crapneg.cdtctant = crapneg.cdtctatu THEN
                           DELETE crapneg.

                        LEAVE ContadorNeg.

                     END.

              END. /* ContadorNeg */

              IF par_cdcritic <> 0 THEN
                 UNDO GravaAltera, LEAVE GravaAltera.

           END.

        /* Sessao de Extrato  */
        IF crabass.cdsecext <> par_cdsecext THEN
           DO:
              FOR EACH crapavs WHERE crapavs.cdcooper = par_cdcooper AND
                                     crapavs.nrdconta = par_nrdconta 
                                     NO-LOCK:

                  ContadorAvs: DO aux_contador = 1 TO 10:

                      FIND crabavs WHERE ROWID(crabavs) = ROWID(crapavs)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabavs THEN
                         DO:
                            IF LOCKED(crabavs) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorAvs.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorAvs.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorAvs.

                  END. /* ContadorAvs */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabavs.cdsecext = par_cdsecext.

                  RELEASE crabavs.

              END.

              /*  Para aplicacoes RDCA */
              FOR EACH craprda WHERE craprda.cdcooper = par_cdcooper AND
                                     craprda.nrdconta = par_nrdconta 
                                     NO-LOCK:

                  ContadorRda: DO aux_contador = 1 TO 10:

                      FIND crabrda WHERE ROWID(crabrda) = ROWID(craprda)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabrda THEN
                         DO:
                            IF LOCKED(crabrda) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorRda.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorRda.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorRda.

                  END. /* ContadorRda */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabrda.cdsecext = par_cdsecext.

                  RELEASE crabrda.

              END.

              /*  Para poupanca programada */
              FOR EACH craprpp WHERE craprpp.cdcooper = par_cdcooper AND
                                     craprpp.nrdconta = par_nrdconta 
                                     NO-LOCK:

                  ContadorRpp: DO aux_contador = 1 TO 10:

                      FIND crabrpp WHERE ROWID(crabrpp) = ROWID(craprpp)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabrpp THEN
                         DO:
                            IF LOCKED(crabrpp) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorRpp.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorRpp.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorRpp.

                  END. /* ContadorRpp */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabrpp.cdsecext = par_cdsecext.

                  RELEASE crabrpp.

              END.

           END.

        /* Mudou o tipo de extrato da conta */
        IF par_tpextcta <> crabass.tpextcta THEN
           IF crabass.tpextcta = 1 THEN
              DO:
                 ContadorSld: DO aux_contador = 1 TO 10:

                    FIND crapsld WHERE crapsld.cdcooper = par_cdcooper AND
                                       crapsld.nrdconta = par_nrdconta
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF NOT AVAILABLE crapsld THEN
                       DO:
                          IF LOCKED crapsld THEN
                             DO:
                                IF aux_contador = 10 THEN
                                   DO:
                                      ASSIGN par_cdcritic = 72.
                                      LEAVE ContadorSld.
                                   END.
                                ELSE
                                   DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT ContadorSld.
                                   END.

                             END.
                          ELSE
                             DO:
                                ASSIGN par_cdcritic = 10.
                                LEAVE ContadorSld.
                             END.

                       END.
                    ELSE
                       LEAVE ContadorSld.

                 END.  /*  Fim do ContadorSld DO .. TO  */

                 IF  par_cdcritic <> 0 THEN
                    UNDO GravaAltera, LEAVE GravaAltera.

                 ASSIGN crapsld.vlsdanes = crapsld.vlsdmesa
                        crapsld.dtsdanes = DATE(MONTH(par_dtmvtolt),01,
                                                YEAR(par_dtmvtolt))
                        crapsld.dtsdanes = crapsld.dtsdanes - 1.

              END.

        /* Mudou o PAC  */
        IF par_cdagepac <> crabass.cdagenci THEN
           DO:
              /* Altera agencia das requisicoes */
              FOR EACH crapreq WHERE crapreq.cdcooper = crabass.cdcooper AND
                                     crapreq.cdagenci = crabass.cdagenci AND
                                     crapreq.nrdconta = crabass.nrdconta
                                     NO-LOCK:

                  ContadorReq: DO aux_contador = 1 TO 10:

                      FIND crabreq WHERE ROWID(crabreq) = ROWID(crapreq)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabreq THEN
                         DO:
                            IF LOCKED(crabreq) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorReq.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorReq.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorReq.

                  END. /* ContadorReq */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabreq.cdagenci = par_cdagepac.

                  RELEASE crabreq.

              END.

              /* Altera agencia dos extratos solicitados */
              FOR EACH crapext WHERE crapext.cdcooper = crabass.cdcooper AND
                                     crapext.cdagenci = crabass.cdagenci AND
                                     crapext.nrdconta = crabass.nrdconta
                                     NO-LOCK:

                  ContadorExt: DO aux_contador = 1 TO 10:

                      FIND crabext WHERE ROWID(crabext) = ROWID(crapext)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabext THEN
                         DO:
                            IF LOCKED(crabext) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorExt.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorExt.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorExt.

                  END. /* ContadorExt */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabext.cdagenci = par_cdagepac.

                  RELEASE crabext.

              END.

              /* Altera agencia para aviso de debitos */
              FOR EACH crapavs WHERE crapavs.cdcooper = crabass.cdcooper AND
                                     crapavs.nrdconta = crabass.nrdconta
                                     NO-LOCK:

                  ContadorAvs: DO aux_contador = 1 TO 10:

                      FIND crabavs WHERE ROWID(crabavs) = ROWID(crapavs)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabavs THEN
                         DO:
                            IF LOCKED(crabavs) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorAvs.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorAvs.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorAvs.

                  END. /* ContadorAvs */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabavs.cdagenci = par_cdagepac.

                  RELEASE crabavs.

              END.

              /* Altera agencia para aplicoes rdca */
              FOR EACH craprda WHERE craprda.cdcooper = crabass.cdcooper AND
                                     craprda.nrdconta = crabass.nrdconta
                                     NO-LOCK:

                  ContadorRda: DO aux_contador = 1 TO 10:

                      FIND crabrda WHERE ROWID(crabrda) = ROWID(craprda)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabrda THEN
                         DO:
                            IF LOCKED(crabrda) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorRda.
                                     END.
                                  ELSE 
                                     
                                      DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorRda.
                                     END.
                               END.

                         END.
                      ELSE 
                         LEAVE ContadorRda.

                  END. /* ContadorRda */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabrda.cdageass = par_cdagepac.

                  RELEASE crabrda.

              END.

              /* Altera agencia para poupancas programadas */
              FOR EACH craprpp WHERE craprpp.cdcooper = crabass.cdcooper AND
                                     craprpp.nrdconta = crabass.nrdconta
                                     NO-LOCK:

                  ContadorRpp: DO aux_contador = 1 TO 10:

                      FIND crabrpp WHERE ROWID(crabrpp) = ROWID(craprpp)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE crabrpp THEN
                         DO:
                            IF LOCKED(crabrpp) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorRpp.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorRpp.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorRpp.

                  END. /* ContadorRpp */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  ASSIGN crabrpp.cdageass = par_cdagepac.

                  RELEASE crabrpp.

              END.
                                     END.

        IF crabass.cdbcochq <> par_cdbcochq THEN
           DO:
               ContadorAlt: DO aux_contador = 1 TO 10:
    
                   FIND crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                                      crapalt.nrdconta = par_nrdconta AND
                                      crapalt.dtaltera = par_dtmvtolt 
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                   IF NOT AVAILABLE crapalt THEN
                      DO:
                         IF LOCKED(crapalt) THEN
                            DO:
                               IF aux_contador = 10 THEN
                                  DO:
                                     ASSIGN par_cdcritic = 72.
                                     LEAVE ContadorAlt.
                                  END.
                               ELSE 
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT ContadorAlt.
                                  END.

                            END.
                         ELSE 
                            DO:
                               CREATE crapalt.

                               ASSIGN crapalt.nrdconta = par_nrdconta
                                      crapalt.dtaltera = par_dtmvtolt
                                      crapalt.tpaltera = par_tpaltera
                                      crapalt.cdcooper = par_cdcooper.
                               VALIDATE crapalt.
                            END.

                      END.
                   ELSE
                      LEAVE ContadorAlt.

               END.

               IF par_cdcritic <> 0 THEN
                  UNDO GravaAltera, LEAVE GravaAltera.
    
               /* Alteracao banco do cheque */
               ASSIGN log_nmdcampo = "bco.emis.cheq".
    
               IF NOT CAN-DO(crapalt.dsaltera,"bco.emis.cheq") THEN
                  DO:
                      ASSIGN crapalt.cdoperad = par_cdoperad
                             crapalt.dsaltera = crapalt.dsaltera + 
                                                log_nmdcampo + ","
                             crapalt.tpaltera = (IF crapalt.tpaltera = 0 THEN 
                                                    2
                                                 ELSE 
                                                    crapalt.tpaltera) 
                             NO-ERROR.
    
                      IF ERROR-STATUS:ERROR THEN
                         DO:
                            ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
                            UNDO GravaAltera, LEAVE GravaAltera.

                         END.

                  END.

           END.

        IF par_dscritic <> "" OR par_cdcritic <> 0 THEN
           UNDO GravaAltera, LEAVE GravaAltera.

        IF NOT AVAILABLE crabass THEN
           DO:
              ASSIGN par_dscritic = "Associado indisponivel para atualizacao".
              UNDO GravaAltera, LEAVE GravaAltera.
           END.

        IF  par_idastcjt = 1 THEN
            DO:
                FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND
                                       crapavt.nrdconta = par_nrdconta AND
                                       crapavt.tpctrato = 6 NO-LOCK:
    
                    FOR FIRST crappod WHERE crappod.cdcooper = crapavt.cdcooper AND
                                            crappod.nrdconta = crapavt.nrdconta AND
                                            crappod.nrcpfpro = crapavt.nrcpfcgc and
                                            crappod.nrctapro = crapavt.nrdctato NO-LOCK. END.
                                
                    IF  NOT AVAIL crappod  THEN
                        DO:
                            ASSIGN aux_ctdpoder = 1.

                            DO WHILE aux_ctdpoder <= 10:
                                     
                                CREATE crappod.
                                ASSIGN crappod.cdcooper = crapavt.cdcooper
                                       crappod.nrctapro = crapavt.nrdctato
                                       crappod.nrcpfpro = crapavt.nrcpfcgc
                                       crappod.cddpoder = aux_ctdpoder
                                       crappod.flgconju = NO
                                       crappod.flgisola = NO
                                       crappod.nrdconta = crapavt.nrdconta.
                                VALIDATE crappod.

                                ASSIGN aux_ctdpoder = aux_ctdpoder + 1.

                            END.
                        END.
                                    
                END.
            END.

        IF  par_idastcjt <> crabass.idastcjt  THEN
            DO:
                /* Eliminar todas as senhas e letras do(s) representante(s) legal(is)  */
                /* Ignorar titularidade 1 que está reservada para letras de magnéticos */
        		FOR EACH crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                       crapsnh.nrdconta = par_nrdconta AND
                                      (crapsnh.tpdsenha = 1            OR  /* Internet */
                                      (crapsnh.tpdsenha = 3            AND /* Letras   */
                                       crapsnh.idseqttl > 1))
        							   EXCLUSIVE-LOCK:
        
                   /* Deletar Historico de senhas do Representante Legal */
                   FOR EACH craphsh WHERE craphsh.cdcooper = crapsnh.cdcooper AND
                                          craphsh.nrdconta = crapsnh.nrdconta AND
                                          craphsh.idseqttl = crapsnh.idseqttl AND
                                          craphsh.tpdsenha = crapsnh.tpdsenha EXCLUSIVE-LOCK:
                 
                       DELETE craphsh.
                 
                   END.
        
                   DELETE crapsnh.
        
                END.
                
                FOR EACH crappod WHERE crappod.cdcooper = par_cdcooper AND
        							   crappod.nrdconta = par_nrdconta AND
        							   crappod.cddpoder = 10           AND
        							   crappod.flgconju = TRUE         
        							   EXCLUSIVE-LOCK:
            
                    IF  crappod.flgconju  THEN
                        DO:
                            ASSIGN crappod.flgconju = FALSE.
        
                            /* Indicar que cartao de assinatura deve ser impresso */
                            FOR FIRST crapavt WHERE crapavt.cdcooper = crappod.cdcooper AND
                                                    crapavt.tpctrato = 6                AND
                                                    crapavt.nrdconta = crappod.nrdconta AND
                                                    crapavt.nrdctato = crappod.nrctapro AND
                                                    crapavt.nrcpfcgc = crappod.nrcpfpro
                                                    EXCLUSIVE-LOCK. 
        
                                ASSIGN crapavt.flgimpri = TRUE.        
        
                            END.
                        END.
                    
        		END.
        
                ASSIGN crapass.idimprtr = 0.

            END.
		/* Fim da limpeza referente assinatura conjunta */
        
        ASSIGN crabass.cdagenci = par_cdagepac
               crabass.dtultalt = par_dtmvtolt
               crabass.cdtipcta = par_cdtipcta
               crabass.cdbcochq = par_cdbcochq
               crabass.cdsitdct = par_cdsitdct
			   crabass.flgiddep = par_flgiddep
               crabass.tpavsdeb = par_tpavsdeb
               crabass.tpextcta = par_tpextcta
               crabass.cdsecext = par_cdsecext
               crabass.dtcnsscr = par_dtcnsscr
               crabass.dtcnsspc = par_dtcnsspc
               crabass.dtdsdspc = par_dtdsdspc
               crabass.inadimpl = par_inadimpl
               crabass.inlbacen = par_inlbacen 
               crabass.flgrestr = par_flgrestr 
               crabass.indserma = par_indserma
			   crabass.idastcjt = par_idastcjt
               NO-ERROR.

        IF ERROR-STATUS:ERROR THEN
           DO:
              ASSIGN par_dscritic = ERROR-STATUS:GET-MESSAGE(1).
              UNDO GravaAltera, LEAVE GravaAltera.
           END.

        ASSIGN crabass.indnivel = 3.

        IF crabass.inpessoa = 1 THEN
           DO:
              FOR EACH crabttl WHERE crabttl.cdcooper = par_cdcooper AND
                                     crabttl.nrdconta = par_nrdconta 
                                     NO-LOCK:

                  ContadorTtl: DO aux_contador = 1 TO 10:

                      FIND brapttl WHERE ROWID(brapttl) = ROWID(crabttl)
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                      IF NOT AVAILABLE brapttl THEN
                         DO:
                            IF LOCKED(brapttl) THEN
                               DO:
                                  IF aux_contador = 10 THEN
                                     DO:
                                        ASSIGN par_cdcritic = 341.
                                        LEAVE ContadorTtl.
                                     END.
                                  ELSE 
                                     DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT ContadorTtl.
                                     END.

                               END.

                         END.
                      ELSE 
                         LEAVE ContadorTtl.

                  END. /* ContadorTtl */

                  IF par_cdcritic <> 0 THEN
                     UNDO GravaAltera, LEAVE GravaAltera.

                  IF brapttl.indnivel <> 4 THEN
                     ASSIGN brapttl.indnivel = 4.

                  RELEASE brapttl.

              END.

           END.

        ASSIGN aux_returnvl = "OK"
               par_cdcritic = 0
               par_dscritic = "".

        LEAVE GravaAltera.

    END.

    IF par_dscritic <> "" OR par_cdcritic <> 0 THEN
       ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Grava_Dados_Solicita:

    /* Logica extraida da procedure solicita_itg */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaltera AS INTE                           NO-UNDO.

    DEF PARAM BUFFER crabass FOR crapass.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_returnvl = "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    GravaSolicita: DO TRANSACTION
        ON ERROR  UNDO GravaSolicita, LEAVE GravaSolicita
        ON QUIT   UNDO GravaSolicita, LEAVE GravaSolicita
        ON STOP   UNDO GravaSolicita, LEAVE GravaSolicita
        ON ENDKEY UNDO GravaSolicita, LEAVE GravaSolicita:

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_dscritic = "Buffer da tabela de Associados nao " + 
                                     "esta disponivel.".
               LEAVE GravaSolicita.
            END.

        ContadorAlt: DO aux_contador = 1 TO 10:

            FIND crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                               crapalt.nrdconta = par_nrdconta AND
                               crapalt.dtaltera = par_dtmvtolt 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE crapalt THEN
                DO:
                   IF  LOCKED(crapalt) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 ASSIGN par_cdcritic = 72.
                                 LEAVE ContadorAlt.
                              END.
                          ELSE 
                              DO:
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT ContadorAlt.
                              END.
                       END.
                   ELSE 
                       DO:
                          CREATE crapalt.
                          ASSIGN crapalt.nrdconta = par_nrdconta
                                 crapalt.dtaltera = par_dtmvtolt
                                 crapalt.tpaltera = par_tpaltera
                                 crapalt.cdcooper = par_cdcooper.
                          VALIDATE crapalt.

                          LEAVE ContadorAlt.
                       END.
                END.
            ELSE
                LEAVE ContadorAlt.
        END.

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO GravaSolicita, LEAVE GravaSolicita.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        IF  NOT DYNAMIC-FUNCTION("BuscaOperador" IN h-b1wgen0060,
                                  INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                 OUTPUT aux_nmoperad,
                                 OUTPUT par_dscritic) THEN
            UNDO GravaSolicita, LEAVE GravaSolicita.

        IF  crabass.nrdctitg <> " " THEN 
            DO:
               IF  crabass.flgctitg = 2 THEN  /* Ja tem ITG. cadastrada */ 
                   DO:
                      ASSIGN log_nmdcampo = "tipo cta,".

                      IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                          ASSIGN 
                             crapalt.flgctitg = 2  /* ok  */ 
                             crapalt.cdoperad = par_cdoperad
                             crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo
                             crapalt.tpaltera = IF crapalt.tpaltera = 0
                                                THEN 2 ELSE crapalt.tpaltera.
                   END.
               ELSE                                           
                   DO:
                      ASSIGN log_nmdcampo = "reativacao conta-itg" + "(" +
                                            STRING(log_nrdctitg) + ")" + 
                                            "- ope." + par_cdoperad + ",".

                      IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                          ASSIGN 
                             crapalt.flgctitg = 0
                             crapalt.cdoperad = par_cdoperad
                             crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo
                             crapalt.tpaltera = IF crapalt.tpaltera = 0
                                                THEN 2 ELSE crapalt.tpaltera.

                      UNIX SILENT VALUE
                          ("echo " + STRING(par_dtmvtolt,"99/99/9999")    +
                           " "     + STRING(TIME,"HH:MM:SS")+ "' --> '"   +
                           " Operador " + par_cdoperad      + " - "       +
                           aux_nmoperad + " Reativou a conta integracao " +
                           STRING(crabass.nrdctitg,"9.999.999-X")         +
                           " - Conta/DV "                                 + 
                           STRING(crabass.nrdconta,"zzzz,zzz,9")          +
                           " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/contas.log").

                      ASSIGN crabass.flgctitg = 0.
                   END.
            END.
        ELSE
            DO:
               ASSIGN log_nmdcampo = "solicitacao conta-itg,".

               IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
                   ASSIGN 
                       crapalt.flgctitg = 0
                       crapalt.cdoperad = par_cdoperad
                       crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo
                       crapalt.tpaltera = IF crapalt.tpaltera = 0
                                          THEN 2 ELSE crapalt.tpaltera.

               UNIX SILENT VALUE
                   ("echo " + STRING(par_dtmvtolt,"99/99/9999")    +
                    " "     + STRING(TIME,"HH:MM:SS")+ "' --> '"   +
                    " Operador " + par_cdoperad      + " - "       +
                    aux_nmoperad + " Solicitou conta integracao "  +
                    " - Conta/DV "                                 +
                    STRING(crabass.nrdconta,"zzzz,zzz,9")          + 
                    " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                             "/log/contas.log").

               ASSIGN crabass.flgctitg = 0.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE GravaSolicita.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Grava_Dados_Exclui:

    /* Logica extraida da procedure exclusao_titulares */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsorigem AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcreca AS LOG                            NO-UNDO.

    DEF PARAM BUFFER crabass FOR crapass.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_idseqttl AS INTE                                    NO-UNDO.
    DEF VAR aux_dstransa AS CHAR                                    NO-UNDO.

    DEF BUFFER crabttl FOR crapttl.
    DEF BUFFER brapttl FOR crapttl.
    DEF BUFFER crabdep FOR crapdep.
    DEF BUFFER crabavt FOR crapavt.
    DEF BUFFER crabbem FOR crapbem.
    DEF BUFFER crabtfc FOR craptfc.
    DEF BUFFER crabcem FOR crapcem.
    DEF BUFFER crabcra FOR crapcra.
    DEF BUFFER crabcrl FOR crapcrl.
    DEF BUFFER crabdoc FOR crapdoc.

    ASSIGN aux_returnvl = "NOK".

    GravaExclui: DO TRANSACTION
        ON ERROR  UNDO GravaExclui, LEAVE GravaExclui
        ON QUIT   UNDO GravaExclui, LEAVE GravaExclui
        ON STOP   UNDO GravaExclui, LEAVE GravaExclui
        ON ENDKEY UNDO GravaExclui, LEAVE GravaExclui:

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_dscritic = "Buffer da tabela de Associados nao " + 
                                     "esta disponivel.".
               LEAVE GravaExclui.
            END.

        /*  Elimina os titulares (exceto o 1o)  */
        FOR EACH crabttl WHERE crabttl.cdcooper = crabass.cdcooper AND
                               crabttl.nrdconta = crabass.nrdconta AND
                               crabttl.idseqttl > 1 NO-LOCK:

            ASSIGN aux_idseqttl = crabttl.idseqttl
                   aux_dstransa = "Remove tit. " + STRING(aux_idseqttl) + 
                                  " " + SUBSTRING(crapttl.nmextttl, 1, 46).

            /*  Se encontrar critica 552 NAO gera novas criticas
                para nao "atropelar" as inclusoes/exclusoes */
            IF  par_flgcreca THEN
                DO:
                   FIND FIRST crapeca WHERE 
                              crapeca.cdcooper = crabttl.cdcooper AND
                              crapeca.nrdconta = crabttl.nrdconta AND
                              crapeca.tparquiv = 552 NO-LOCK NO-ERROR.
                                                
                   IF  NOT AVAILABLE crapeca AND crapass.nrdctitg <> "" THEN
                       DO:
                          /* Exclusao do titular no BB */
                          CREATE crapeca.
                          ASSIGN 
                              crapeca.nrdconta = crabttl.nrdconta
                              crapeca.dscritic = "EFETUANDO EXCLUSAO SEG. " +
                                                 "TITULAR"
                              crapeca.tparquiv = 552
                              crapeca.cdcooper = crabttl.cdcooper
                              crapeca.dtretarq = par_dtmvtolt
                              crapeca.idseqttl = crabttl.idseqttl
                              crapeca.nrseqarq = 0
                              crapeca.nrdcampo = 0.
                          VALIDATE crapeca.
                       END.
                END.
                        
            /*  Exclusao do conjuge */
            ContadorCje: DO aux_contador = 1 TO 10:

                FIND crapcje WHERE crapcje.cdcooper = crabttl.cdcooper AND
                                   crapcje.nrdconta = crabttl.nrdconta AND
                                   crapcje.idseqttl = crabttl.idseqttl
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
                    END.
                ELSE 
                    DO:
                       DELETE crapcje.
                       LEAVE ContadorCje.
                    END.
            END. /* ContadorCje */

            IF  par_cdcritic <> 0 THEN
                UNDO GravaExclui, LEAVE GravaExclui.
            
            /* Exclusao do Endereço Residencial */
            ContadorEndres: DO aux_contador = 1 TO 10:
                
                /** Dados Residencias **/
                FIND LAST crapenc WHERE crapenc.cdcooper = crabttl.cdcooper AND
                                        crapenc.nrdconta = crabttl.nrdconta AND
                                        crapenc.idseqttl = crabttl.idseqttl AND
                                        crapenc.tpendass = 10
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF  NOT AVAILABLE crapenc  THEN
                    DO:
                        IF  LOCKED crapenc  THEN
                            DO:
                                IF  aux_contador = 10  THEN
                                    DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorEndres.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                            END.
                        
                    END.
                ELSE
                    DO:
                       /*Deleta Registro*/
                       DELETE crapenc.
                       LEAVE ContadorEndres.
                    END.
        
                LEAVE.
        
            END. /** Fim ContadorEndres **/

            IF  par_cdcritic <> 0 THEN
                UNDO GravaExclui, LEAVE GravaExclui.

            /* Exclusao do Endereço Comercial */
            ContadorEndcom: DO aux_contador = 1 TO 10:
                
                /** Dados End. Comercial **/
                FIND LAST crapenc WHERE crapenc.cdcooper = crabttl.cdcooper AND
                                        crapenc.nrdconta = crabttl.nrdconta AND
                                        crapenc.idseqttl = crabttl.idseqttl AND
                                        crapenc.tpendass = 9
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF  NOT AVAILABLE crapenc  THEN
                    DO:
                        IF  LOCKED crapenc  THEN
                            DO:
                                IF  aux_contador = 10  THEN
                                    DO:
                                        ASSIGN par_cdcritic = 72.
                                        LEAVE ContadorEndcom.
                                    END.
                                ELSE
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT.
                                    END.
                            END.
                        
                    END.
                ELSE
                    DO:
                       /*Deleta Registro*/
                       DELETE crapenc.
                       LEAVE ContadorEndcom.
                    END.
        
                LEAVE.
        
            END. /** Fim ContadorEndcom **/

            IF  par_cdcritic <> 0 THEN
                UNDO GravaExclui, LEAVE GravaExclui.

            /*  Exclusao dos Bens  */
            FOR EACH crapbem WHERE crapbem.cdcooper = crabttl.cdcooper AND
                                   crapbem.nrdconta = crabttl.nrdconta AND
                                   crapbem.idseqttl = crabttl.idseqttl NO-LOCK:
            
                ContadorBens: DO aux_contador = 1 TO 10:

                    FIND crabbem WHERE ROWID(crabbem) = ROWID(crapbem)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabbem THEN
                        DO:
                           IF  LOCKED(crabbem) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorBens.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorBens.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabbem.
                           LEAVE ContadorBens.
                        END.
                END. /* ContadorBens */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH crapbem  */

            /*  Exclusao dos Telefones  */
            FOR EACH craptfc WHERE craptfc.cdcooper = crabttl.cdcooper AND
                                   craptfc.nrdconta = crabttl.nrdconta AND
                                   craptfc.idseqttl = crabttl.idseqttl NO-LOCK:
            
                ContadorTel: DO aux_contador = 1 TO 10:

                    FIND crabtfc WHERE ROWID(crabtfc) = ROWID(craptfc)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabtfc THEN
                        DO:
                           IF  LOCKED(crabtfc) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorTel.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorTel.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabtfc.
                           LEAVE ContadorTel.
                        END.
                END. /* ContadorTel */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH craptfc  */

            /* Exclusao dos E-mails  */
            FOR EACH crapcem WHERE crapcem.cdcooper = crabttl.cdcooper AND
                                   crapcem.nrdconta = crabttl.nrdconta AND
                                   crapcem.idseqttl = crabttl.idseqttl NO-LOCK:
            
                ContadorEmail: DO aux_contador = 1 TO 10:

                    FIND crabcem WHERE ROWID(crabcem) = ROWID(crapcem)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabcem THEN
                        DO:
                           IF  LOCKED(crabcem) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorEmail.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorEmail.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabcem.
                           LEAVE ContadorEmail.
                        END.
                END. /* ContadorEmail */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH crapcem  */

            /* Exclusao dos Resp. Legais  */
            FOR EACH crapcrl 
                     WHERE crapcrl.cdcooper = crabttl.cdcooper         AND
                           crapcrl.nrctamen = crabttl.nrdconta         AND
                           crapcrl.nrcpfmen = (IF crabttl.nrdconta = 0 THEN 
                                                  crabttl.nrcpfcgc 
                                               ELSE 
                                                  0)                   AND
                           crapcrl.idseqmen = crabttl.idseqttl 
                           NO-LOCK:
            
                ContadorResp: DO aux_contador = 1 TO 10:

                    FIND crabcrl WHERE ROWID(crabcrl) = ROWID(crapcrl)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabcrl THEN
                        DO:
                           IF  LOCKED(crabcrl) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorResp.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorResp.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO: 
                           DELETE crabcrl.
                           LEAVE ContadorResp.
                        END.
                END. /* ContadorResp */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.

            END. /* FOR EACH crapcrl */

            /* Exclusao dos Procuradores  */
            FOR EACH crapavt WHERE crapavt.cdcooper = crabttl.cdcooper AND
                                   crapavt.nrdconta = crabttl.nrdconta AND
                                   crapavt.nrctremp = crabttl.idseqttl AND
                                   crapavt.tpctrato = 6 /*proc*/  NO-LOCK:
            
                ContadorProc: DO aux_contador = 1 TO 10:

                    FIND crabavt WHERE ROWID(crabavt) = ROWID(crapavt)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabavt THEN
                        DO:
                           IF  LOCKED(crabavt) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorProc.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorProc.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabavt.
                           LEAVE ContadorProc.
                        END.
                END. /* ContadorProc */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH crapavt */

            /* Exclusao dos Informativos  */
            FOR EACH crapcra WHERE crapcra.cdcooper = crabttl.cdcooper AND
                                   crapcra.nrdconta = crabttl.nrdconta AND
                                   crapcra.idseqttl = crabttl.idseqttl NO-LOCK:
            
                ContadorInf: DO aux_contador = 1 TO 10:

                    FIND crabcra WHERE ROWID(crabcra) = ROWID(crapcra)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabcra THEN
                        DO:
                           IF  LOCKED(crabcra) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorInf.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorInf.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabcra.
                           LEAVE ContadorInf.
                        END.
                END. /* ContadorInf */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH crapcra */
            
            /*  Exclusao dos dependentes  */
            FOR EACH crapdep WHERE crapdep.cdcooper = crabttl.cdcooper AND
                                   crapdep.nrdconta = crabttl.nrdconta AND
                                   crapdep.idseqdep = crabttl.idseqttl NO-LOCK:

                ContadorDep: DO aux_contador = 1 TO 10:

                    FIND crabdep WHERE ROWID(crabdep) = ROWID(crapdep)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabdep THEN
                        DO:
                           IF  LOCKED(crabdep) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorDep.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorDep.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabdep.
                           LEAVE ContadorDep.
                        END.
                END. /* ContadorDep */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH crapdep  */
                                 
            /* Exclui os contatos dos titulares */
            FOR EACH crapavt WHERE crapavt.cdcooper = crabttl.cdcooper AND
                                   crapavt.nrdconta = crabttl.nrdconta AND
                                   crapavt.tpctrato = 5 /* Contato */  AND
                                   crapavt.nrctremp = crabttl.idseqttl
                                   NO-LOCK:

                ContadorAvt: DO aux_contador = 1 TO 10:

                    FIND crabavt WHERE ROWID(crabavt) = ROWID(crapavt)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabavt THEN
                        DO:
                           IF  LOCKED(crabavt) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorAvt.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorAvt.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabavt.
                           LEAVE ContadorAvt.
                        END.
                END. /* ContadorAvt */

                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.
            END. /* FOR EACH crapavt  */
            
            /* Atualizar pendencias dos titulares secundarios da conta */
            FOR EACH crapdoc WHERE crapdoc.cdcooper = crabttl.cdcooper 
                               AND crapdoc.nrdconta = crabttl.nrdconta
                               AND crapdoc.idseqttl = crabttl.idseqttl
                               AND crapdoc.flgdigit = FALSE
                               NO-LOCK:
                               
                ContadorDoc: DO aux_contador = 1 TO 10:
                
                  FIND crabdoc WHERE ROWID(crabdoc) = ROWID(crapdoc)
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF  NOT AVAILABLE crabdoc THEN
                        DO:
                           IF  LOCKED(crabdoc) THEN
                               DO:
                                  IF  aux_contador = 10 THEN
                                      DO:
                                         ASSIGN par_cdcritic = 72.
                                         LEAVE ContadorDoc.
                                      END.
                                  ELSE 
                                      DO:
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT ContadorDoc.
                                      END.
                               END.
                        END.
                    ELSE 
                        DO:
                           DELETE crabdoc.
                           LEAVE ContadorDoc.
                        END.
                
                END. /* ContadorDoc */
                
                IF  par_cdcritic <> 0 THEN
                    UNDO GravaExclui, LEAVE GravaExclui.                               
            END.
            
            ContadorTtl: DO aux_contador = 1 TO 10:

                FIND brapttl WHERE ROWID(brapttl) = ROWID(crabttl)
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE brapttl THEN
                    DO:
                       IF  LOCKED(brapttl) THEN
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
                    END.
                ELSE 
                    LEAVE ContadorTtl.
            END. /* ContadorTtl */

            IF  par_cdcritic <> 0 THEN
                UNDO GravaExclui, LEAVE GravaExclui.

            DELETE brapttl.

            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT par_dsorigem,
                                INPUT aux_dstransa,
                                INPUT YES,
                                INPUT aux_idseqttl, 
                                INPUT par_nmdatela,
                                INPUT par_nrdconta, 
                               OUTPUT aux_nrdrowid).
        END.

        ASSIGN aux_returnvl = "OK".

        LEAVE GravaExclui.
    END.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Grava_Dados_Encerra:

    /* Logica extraida da procedure encerra_itg */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpaltera AS INTE                           NO-UNDO.

    DEF PARAM BUFFER crabass FOR crapass.
    
    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_returnvl = "NOK".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    GravaEncerra: DO TRANSACTION
        ON ERROR  UNDO GravaEncerra, LEAVE GravaEncerra
        ON QUIT   UNDO GravaEncerra, LEAVE GravaEncerra
        ON STOP   UNDO GravaEncerra, LEAVE GravaEncerra
        ON ENDKEY UNDO GravaEncerra, LEAVE GravaEncerra:

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN par_dscritic = "Buffer da tabela de Associados nao " + 
                                     "esta disponivel.".
               LEAVE GravaEncerra.
            END.

        ContadorAlt: DO aux_contador = 1 TO 10:

            FIND crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                               crapalt.nrdconta = par_nrdconta AND
                               crapalt.dtaltera = par_dtmvtolt 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
            IF  NOT AVAILABLE crapalt THEN
                DO:
                   IF  LOCKED(crapalt) THEN
                       DO:
                          IF  aux_contador = 10 THEN
                              DO:
                                 ASSIGN par_cdcritic = 72.
                                 LEAVE ContadorAlt.
                              END.
                          ELSE 
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT ContadorAlt.
                              END.
                       END.
                   ELSE 
                       DO:
                          CREATE crapalt.
                          ASSIGN crapalt.nrdconta = par_nrdconta
                                 crapalt.dtaltera = par_dtmvtolt
                                 crapalt.tpaltera = par_tpaltera
                                 crapalt.cdcooper = par_cdcooper.
                          VALIDATE crapalt.
                       END.
                END.
            ELSE
                LEAVE ContadorAlt.
        END.

        IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
            UNDO GravaEncerra, LEAVE GravaEncerra.

        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
            RUN sistema/generico/procedures/b1wgen0060.p
                PERSISTENT SET h-b1wgen0060.

        IF  NOT DYNAMIC-FUNCTION("BuscaOperador" IN h-b1wgen0060,
                                  INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                 OUTPUT aux_nmoperad,
                                 OUTPUT par_dscritic) THEN
            UNDO GravaEncerra, LEAVE GravaEncerra.

        /* Exclusao da Conta Integracao */ 
        ASSIGN log_nmdcampo = "exclusao conta-itg" + "(" + 
                              STRING(crabass.nrdctitg) + ")" +
                              "- ope." + par_cdoperad.
    
        IF  NOT CAN-DO(crapalt.dsaltera,log_nmdcampo) THEN
            ASSIGN 
                crapalt.flgctitg = 0
                crapalt.cdoperad = par_cdoperad
                crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo + ","
                crapalt.tpaltera = IF crapalt.tpaltera = 0 THEN 2 
                                   ELSE crapalt.tpaltera.

        IF  crabass.cdsitdct <> 4 AND crabass.cdtipcta > 11 THEN
            ASSIGN crapass.cdsitdct = 6.
        
        IF  crabass.cdtipcta > 11 THEN 
            ASSIGN crabass.cdtipcta = crabass.cdtipcta - 11.
               
        ASSIGN crabass.flgctitg = 3.
        
        UNIX SILENT VALUE
            ("echo " + STRING(par_dtmvtolt,"99/99/9999")  + " "     + 
             STRING(TIME,"HH:MM:SS")+ "' --> ' Operador "           + 
             par_cdoperad + " - "   + aux_nmoperad                  + 
             " Encerrou a conta integracao "                        +
             STRING(crabass.nrdctitg,"9.999.999-X")                 + 
             " - Conta/DV " + STRING(crabass.nrdconta,"zzzz,zzz,9") + 
             " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/contas.log").

        ASSIGN aux_returnvl = "OK".

        LEAVE GravaEncerra.
    END.

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE OBJECT h-b1wgen0060.

    IF  par_dscritic <> "" OR par_cdcritic <> 0 THEN
        ASSIGN aux_returnvl = "NOK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Busca_Titulares:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-titulares.

    DEF BUFFER crabttl FOR crapttl.

    BuscaTtl: DO ON ERROR UNDO BuscaTtl, LEAVE BuscaTtl:
        EMPTY TEMP-TABLE tt-titulares.

        FOR EACH crabttl FIELDS(idseqttl nmextttl)
                         WHERE crabttl.cdcooper = par_cdcooper AND
                               crabttl.nrdconta = par_nrdconta AND
                               crabttl.idseqttl > 1 NO-LOCK:

            CREATE tt-titulares.
            ASSIGN
                tt-titulares.idseqttl = crabttl.idseqttl
                tt-titulares.nmextttl = crabttl.nmextttl.
        END.
        
        LEAVE BuscaTtl.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Critica_Cadastro:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
                                                                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-cabec.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-cadas.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-ident.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-filia.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-ender.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-comer.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-telef.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-conju.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-ctato.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-respo.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-ctcor.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-regis.                              
    DEF OUTPUT PARAM TABLE FOR tt-critica-procu.                              
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER crabcop FOR crapcop.
    DEF BUFFER crabass FOR crapass.
    DEF BUFFER crabope FOR crapope.

    ASSIGN aux_returnvl = "NOK".

    Critica: DO ON ERROR UNDO Critica, LEAVE Critica:
        EMPTY TEMP-TABLE tt-erro.          
        EMPTY TEMP-TABLE tt-critica-cabec. 
        EMPTY TEMP-TABLE tt-critica-cadas.
        EMPTY TEMP-TABLE tt-critica-ident.
        EMPTY TEMP-TABLE tt-critica-filia.
        EMPTY TEMP-TABLE tt-critica-ender.
        EMPTY TEMP-TABLE tt-critica-comer.
        EMPTY TEMP-TABLE tt-critica-telef.
        EMPTY TEMP-TABLE tt-critica-conju.
        EMPTY TEMP-TABLE tt-critica-ctato.
        EMPTY TEMP-TABLE tt-critica-respo.
        EMPTY TEMP-TABLE tt-critica-ctcor.
        EMPTY TEMP-TABLE tt-critica-regis.
        EMPTY TEMP-TABLE tt-critica-procu.

        FOR FIRST crabcop FIELDS(nmextcop)
                          WHERE crabcop.cdcooper = par_cdcooper NO-LOCK:
        END.

        IF  NOT AVAILABLE crabcop THEN
            DO:
               ASSIGN aux_cdcritic = 651.
               LEAVE Critica.
            END.

        FOR FIRST crabass FIELDS(nrdconta nmprimtl inpessoa qtfoltal 
                                 cdtipcta cdsitdct dtcnscpf cdsitcpf)
                          WHERE crabass.cdcooper = par_cdcooper AND
                                crabass.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabass THEN
            DO:
               ASSIGN aux_cdcritic = 9.
               LEAVE Critica.
            END.

        FOR FIRST crabope FIELDS(nmoperad)
                          WHERE crabope.cdcooper = par_cdcooper AND
                                crabope.cdoperad = par_cdoperad NO-LOCK:
        END.

        IF  NOT AVAILABLE crabope THEN
            DO:
               ASSIGN aux_cdcritic = 67.
               LEAVE Critica.
            END.
        
        CREATE tt-critica-cabec.
        ASSIGN
            tt-critica-cabec.nmextcop = crabcop.nmextcop
            tt-critica-cabec.nrdconta = TRIM(STRING(crabass.nrdconta,
                                                    "zzzz,zzz,9"))
            tt-critica-cabec.nmprimtl = crabass.nmprimtl
            tt-critica-cabec.cdoperad = par_cdoperad
            tt-critica-cabec.nmoperad = TRIM(par_cdoperad) + " - " + 
                                        crabope.nmoperad
            tt-critica-cabec.inpessoa = crabass.inpessoa
            tt-critica-cabec.dtmvtolt = par_dtmvtolt.

        CASE tt-critica-cabec.inpessoa:
            WHEN 1 THEN DO:
                RUN Critica_Cadastro_Pf
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT crabass.qtfoltal,
                      INPUT crabass.cdtipcta,
                      INPUT crabass.cdsitdct,
                      INPUT par_dtmvtolt,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-critica-cadas ) NO-ERROR.

                IF  ERROR-STATUS:ERROR THEN
                    ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
            END.
            OTHERWISE DO:
                RUN Critica_Cadastro_Pj
                    ( INPUT par_cdcooper,
                      INPUT par_nrdconta,
                      INPUT crabass.dtcnscpf,
                      INPUT crabass.cdsitcpf,
                      INPUT crabass.qtfoltal,
                      INPUT crabass.cdtipcta,
                      INPUT crabass.cdsitdct,
                     OUTPUT aux_cdcritic,
                     OUTPUT aux_dscritic,
                     OUTPUT TABLE tt-critica-cadas ).
            END.
        END CASE.

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            LEAVE Critica.

        LEAVE Critica.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,           
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Critica_Cadastro_Pf:
  
    /* Logica extraida do fontes/critica_cadastro_fisica.p */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-critica-cadas.

    DEF VAR aux_nmdatela AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgconju AS LOG                                     NO-UNDO.
    DEF VAR aux_flgnrcto AS LOG                                     NO-UNDO.
    DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER craxttl FOR crapttl.
    DEF BUFFER crabenc FOR crapenc.
    DEF BUFFER crabtfc FOR craptfc.
    DEF BUFFER crabcje FOR crapcje.
    DEF BUFFER crabavt FOR crapavt.
    DEF BUFFER crabcrl FOR crapcrl.

    &SCOPED-DEFINE TT-IDENT TEMP-TABLE tt-critica-ident:HANDLE
    &SCOPED-DEFINE TT-FILIA TEMP-TABLE tt-critica-filia:HANDLE
    &SCOPED-DEFINE TT-ENDER TEMP-TABLE tt-critica-ender:HANDLE
    &SCOPED-DEFINE TT-COMER TEMP-TABLE tt-critica-comer:HANDLE
    &SCOPED-DEFINE TT-TELEF TEMP-TABLE tt-critica-telef:HANDLE
    &SCOPED-DEFINE TT-CONJU TEMP-TABLE tt-critica-conju:HANDLE
    &SCOPED-DEFINE TT-CTATO TEMP-TABLE tt-critica-ctato:HANDLE
    &SCOPED-DEFINE TT-RESPO TEMP-TABLE tt-critica-respo:HANDLE
    &SCOPED-DEFINE TT-CTCOR TEMP-TABLE tt-critica-ctcor:HANDLE
    
    ASSIGN aux_returnvl = "NOK".

    CriticaPf: DO ON ERROR UNDO CriticaPf, LEAVE CriticaPf:

        FOR EACH craxttl FIELDS(cdcooper idseqttl nrdconta nmextttl nrcpfcgc 
                                dtcnscpf cdsitcpf tpdocttl nrdocttl idorgexp 
                                cdufdttl dtemdttl dtnasttl cdsexotl tpnacion 
                                cdnacion dsnatura inhabmen dthabmen cdgraupr 
                                cdestcvl grescola nmtalttl nmmaettl nmpaittl 
                                cdnatopc cdocpttl tpcttrab cdempres nmextemp 
                                dsproftl cdnvlcgo cdfrmttl cdufnatu)
                         WHERE craxttl.cdcooper = par_cdcooper AND
                               craxttl.nrdconta = par_nrdconta NO-LOCK:
            
            ASSIGN aux_nmdatela = "IDENTIFICACAO".

            IF  craxttl.nmextttl = ""  THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Nome", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.nrcpfcgc = 0 OR craxttl.nrcpfcgc = ? THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "CPF", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.dtcnscpf = ? THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Data Consulta CPF", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdsitcpf = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Situacao CPF", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.tpdocttl = "" THEN 
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Tipo Documento", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.nrdocttl = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Documento", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.idorgexp = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Orgao Emissor do Documento",
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdufdttl = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "UF do Documento", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.dtemdttl = ? THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Data Emissao do Documento", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.dtnasttl = ? THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Data Nascimento", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdsexotl = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Sexo", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.tpnacion = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Tipo Nacionalidade", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdnacion = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Nacionalidade", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.dsnatura  = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Naturalidade", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdufnatu  = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "UF Naturalidade", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.inhabmen = 1 AND craxttl.dthabmen = ? THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Data de Emancipacao", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.idseqttl <> 1 AND craxttl.cdgraupr = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Parentesco", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdestcvl = 0 THEN  
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Estado Civil", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.grescola = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Escolaridade", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.nmtalttl = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Nome no Talao", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.idseqttl = 1 AND par_qtfoltal = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Folhas Talao", 
                      INPUT {&TT-IDENT} ).

            IF  craxttl.cdfrmttl <> 0 THEN
                DO:
                   IF  NOT CAN-FIND(gncdfrm WHERE 
                                    gncdfrm.cdfrmttl = craxttl.cdfrmttl) THEN
                       RUN Trata_Critica
                           ( INPUT craxttl.idseqttl,
                             INPUT "Curso Superior Invalido", 
                             INPUT {&TT-IDENT} ).
                END.

            IF  craxttl.grescola >= 5 AND craxttl.cdfrmttl = 0 THEN
                DO:
                   RUN Trata_Critica
                       ( INPUT craxttl.idseqttl,
                         INPUT "Curso Superior Invalido", 
                         INPUT {&TT-IDENT} ).
                END.

            IF  craxttl.grescola >= 5 AND craxttl.cdfrmttl = 0 THEN
                DO:
                   RUN Trata_Critica
                       ( craxttl.idseqttl,
                         "Escolaridade Errada (Curso Superior Cadastrado)", 
                         {&TT-IDENT} ).
                END.

            ASSIGN aux_nmdatela = "FILIACAO".

            IF  craxttl.nmmaettl = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Nome da Mae", 
                      INPUT {&TT-FILIA} ).

            IF  CAPS(craxttl.nmmaettl) = CAPS(craxttl.nmpaittl) THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Filiacao Errada", 
                      INPUT {&TT-FILIA} ).

            IF  NOT CAN-FIND(FIRST crabenc WHERE 
                             crabenc.cdcooper = craxttl.cdcooper AND
                             crabenc.nrdconta = craxttl.nrdconta AND
                             crabenc.idseqttl = craxttl.idseqttl) THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Falta Cadastrar Endereco", 
                      INPUT {&TT-ENDER} ).

            IF  craxttl.cdnatopc = 0 THEN 
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Natureza da Ocupacao", 
                      INPUT {&TT-COMER} ).

            IF  craxttl.cdocpttl = 0 THEN
                RUN Trata_Critica
                   ( INPUT craxttl.idseqttl,
                     INPUT "Ocupacao", 
                     INPUT {&TT-COMER} ).

            IF  craxttl.tpcttrab = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Tp.Ctr.Trab.", 
                      INPUT {&TT-COMER} ).

            IF  craxttl.tpcttrab <> 3 AND craxttl.cdempres = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Empresa", 
                      INPUT {&TT-COMER} ).

            IF  craxttl.tpcttrab <> 3 AND craxttl.nmextemp = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Nome da Empresa", 
                      INPUT {&TT-COMER} ).

            IF  craxttl.tpcttrab <> 3 AND craxttl.dsproftl = "" THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Funcao na Empresa", 
                      INPUT {&TT-COMER} ).

            IF  craxttl.tpcttrab <> 3 AND craxttl.cdnvlcgo = 0 THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Nivel de Cargo na Empresa", 
                      INPUT {&TT-COMER} ).

            ASSIGN aux_nmdatela = "TELEFONES".

            IF  NOT CAN-FIND(FIRST crabtfc WHERE 
                             crabtfc.cdcooper = craxttl.cdcooper AND
                             crabtfc.nrdconta = craxttl.nrdconta AND
                             crabtfc.idseqttl = craxttl.idseqttl) THEN
                RUN Trata_Critica
                    ( INPUT craxttl.idseqttl,
                      INPUT "Falta Cadastrar Telefone", 
                      INPUT {&TT-TELEF} ).

            IF  craxttl.tpcttrab <> 3   THEN
                DO:
                   IF  NOT CAN-FIND(FIRST crabtfc WHERE 
                                    crabtfc.cdcooper = craxttl.cdcooper AND
                                    crabtfc.nrdconta = craxttl.nrdconta AND
                                    crabtfc.idseqttl = craxttl.idseqttl AND
                                    crabtfc.tptelefo = 3) THEN
                       RUN Trata_Critica
                           ( INPUT craxttl.idseqttl,
                             INPUT "Falta Cadastrar Telefone Comercial", 
                             INPUT {&TT-TELEF} ).
                END.

            /* Existem registros de crapcje que pertencem a crapttl que
            tiveram seus estados civis alterados antes da correcao que faz 
            a exclusao do conjuge quando o estado civil nao permite ter um.
            Nestes casos, eh sugerida a exclusao do crapcje. */
            ASSIGN aux_flgconju = CAN-FIND(crabcje WHERE 
                                        crabcje.cdcooper = craxttl.cdcooper AND
                                        crabcje.nrdconta = craxttl.nrdconta AND
                                        crabcje.idseqttl = craxttl.idseqttl).
                               
            IF  craxttl.cdestcvl <> 1 AND    /* SOLTEIRO */
                craxttl.cdestcvl <> 5 AND    /* VIUVO */
                craxttl.cdestcvl <> 6 AND    /* SEPARADO */
                craxttl.cdestcvl <> 7 THEN  /* DIVORCIADO */
                DO:
                    IF  NOT aux_flgconju THEN
                        RUN Trata_Critica
                            ( INPUT craxttl.idseqttl,
                              INPUT "Falta Cadastrar Dados Conjuge", 
                              INPUT {&TT-CONJU} ).
                END.
            ELSE
                IF  aux_flgconju THEN
                    RUN Trata_Critica
                        ( INPUT craxttl.idseqttl,
                          INPUT "Estado Civil NAO PERMITE Conjuge", 
                          INPUT {&TT-CONJU} ).

            ASSIGN aux_flgnrcto = (IF craxttl.idseqttl <> 1 THEN YES ELSE NO).
            
            Contato: FOR EACH crabavt FIELDS(nrdctato)
                              WHERE crabavt.cdcooper = craxttl.cdcooper AND
                                    crabavt.tpctrato = 5 /*contatos*/   AND
                                    crabavt.nrdconta = craxttl.nrdconta AND
                                    crabavt.nrctremp = craxttl.idseqttl 
                                    NO-LOCK:

                IF  crabavt.nrdctato <> 0 THEN
                    DO:
                        ASSIGN aux_flgnrcto = YES.
                        LEAVE Contato.
                    END.

            END.            

            /* Por hora, somente a Viacredi não irá exigir o contato. A area de canais 
               está verificando com as demais cooperativas. Por este motivo está 
               fixo Viacredi, e não fizemos um parametro */
            IF  NOT aux_flgnrcto  AND
                par_cdcooper <> 1 THEN
                RUN Trata_Critica
                   ( INPUT craxttl.idseqttl,
                     INPUT "Falta Cadastrar Contato", 
                     INPUT {&TT-CTATO} ).

            RUN Busca_Idade
               ( INPUT craxttl.dtnasttl, 
                 INPUT par_dtmvtolt,
                OUTPUT aux_nrdeanos ).

            IF  (aux_nrdeanos < 18 AND craxttl.inhabmen = 0) OR
                craxttl.inhabmen = 2  THEN
                DO:                            
                   IF  NOT CAN-FIND(FIRST crabcrl WHERE
                                crabcrl.cdcooper = craxttl.cdcooper         AND
                                crabcrl.nrctamen = craxttl.nrdconta         AND
                                crabcrl.nrcpfmen = (IF craxttl.nrdconta = 0 THEN
                                                       craxttl.nrcpfcgc 
                                                    ELSE 
                                                       0)                   AND
                                crabcrl.idseqmen = craxttl.idseqttl)        THEN

                       RUN Trata_Critica
                           ( INPUT craxttl.idseqttl,
                             INPUT "Falta Cadastrar Responsavel Legal", 
                             INPUT {&TT-RESPO} ).

                END.

            IF  craxttl.idseqttl = 1 THEN
                DO:
                   IF  par_cdtipcta = 0 THEN  
                       RUN Trata_Critica
                           ( INPUT craxttl.idseqttl,
                             INPUT "Tipo da conta-corrente",
                             INPUT {&TT-CTCOR} ).

                   IF  par_cdsitdct = 0 THEN
                       RUN Trata_Critica
                           ( INPUT craxttl.idseqttl,
                             INPUT "Situacao da conta-corrente",
                             INPUT {&TT-CTCOR} ).
                END.
        END.

        LEAVE CriticaPf.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Critica_Cadastro_Pj:

    /* Logica extraida do fontes/critica_cadastro_juridica.p */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcnscpf AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitcpf AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtfoltal AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-critica-cadas.

    DEF VAR aux_returnvl AS CHAR                                    NO-UNDO.

    DEF BUFFER crabjur FOR crapjur.
    DEF BUFFER crabavt FOR crapavt.

    &SCOPED-DEFINE TT-IDENT TEMP-TABLE tt-critica-ident:HANDLE
    &SCOPED-DEFINE TT-ENDER TEMP-TABLE tt-critica-ender:HANDLE
    &SCOPED-DEFINE TT-RESPO TEMP-TABLE tt-critica-respo:HANDLE
    &SCOPED-DEFINE TT-CTCOR TEMP-TABLE tt-critica-ctcor:HANDLE
    &SCOPED-DEFINE TT-REGIS TEMP-TABLE tt-critica-regis:HANDLE    
    &SCOPED-DEFINE TT-PROCU TEMP-TABLE tt-critica-procu:HANDLE    
        
    ASSIGN aux_returnvl = "NOK".

    CriticaPj: DO ON ERROR UNDO CriticaPj, LEAVE CriticaPj:

        FOR FIRST crabjur FIELDS(nmfansia natjurid dtiniatv cdrmativ nmtalttl 
                                 cdseteco vlfatano vlcaprea dtregemp nrregemp
                                 orregemp )
                          WHERE crabjur.cdcooper = par_cdcooper AND 
                                crabjur.nrdconta = par_nrdconta NO-LOCK:
        END.

        IF  NOT AVAILABLE crabjur THEN
            DO:
               ASSIGN par_cdcritic = 564.
               LEAVE CriticaPj.
            END.

        IF  par_dtcnscpf = ? THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Data Consulta CPF", 
                  INPUT {&TT-IDENT} ).

        IF  par_cdsitcpf = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Situacao Consulta CPF",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.nmfansia = "" THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Nome Fantasia",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.natjurid = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Natureza Juridica",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.dtiniatv = ? THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Data Inicio Atividades",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.cdrmativ = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Ramo de Atividades",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.nmtalttl = "" THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Nome Talao",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.cdseteco = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Setor Economico", 
                  INPUT {&TT-IDENT}  ).

        IF  par_qtfoltal = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Qtd. Folhas no Talao",
                  INPUT {&TT-IDENT}  ).

        IF  crabjur.vlfatano = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Valor Faturamento Ano",
                  INPUT {&TT-REGIS} ).

        IF  crabjur.vlcaprea = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Valor Capital Realizado",
                  INPUT {&TT-REGIS} ).

        IF  crabjur.dtregemp = ? THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Data do Registro da Empresa",
                  INPUT {&TT-REGIS} ).

        IF  crabjur.nrregemp = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Numero do Registro da Empresa",
                  INPUT {&TT-REGIS} ).

        IF  crabjur.orregemp = "" THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Orgao de Registro",
                  INPUT {&TT-REGIS} ).

        FOR FIRST crabavt FIELDS(nrcpfcgc nmdavali tpdocava nrdocava idorgexp
                                 cdufddoc dtemddoc dtnascto cdnacion dsnatura 
                                 nrcepend dsendres nmbairro nmcidade cdufresd 
                                 nmmaecto dsproftl dtvalida)
                          WHERE crabavt.cdcooper = par_cdcooper   AND
                                crabavt.tpctrato = 6 /*juridica*/ AND
                                crabavt.nrdconta = par_nrdconta   AND
                                crabavt.nrdctato = 0 NO-LOCK:

            IF  crabavt.nrcpfcgc = 0 THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "CPF do Rrepresentante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.nmdavali = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Nome do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.tpdocava = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Tipo de Documento do Representante",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.nrdocava = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Documento do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.idorgexp = 0 THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Orgao Emissor do Documento",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.cdufddoc = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Estado onde o Documento foi Emitido",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.dtemddoc = ?  THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Data de Emissao do Documento",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.dtnascto = ?  THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Data de Nascimento do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.cdnacion = 0 THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Nacionalidade do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.dsnatura = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Naturalidade do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.nrcepend = 0  THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "CEP do Endereco do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.dsendres[1] = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Endereco do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.nmbairro = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Nome do Bairro",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.nmcidade = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Nome da Cidade",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.cdufresd = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Estado do Endereco",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.nmmaecto = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Nome da Mae do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.dsproftl = "" THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Cargo do Representante/Procurador",
                      INPUT {&TT-PROCU} ).

            IF  crabavt.dtvalida = ? THEN
                RUN Trata_Critica
                    ( INPUT 0,
                      INPUT "Data de Vigencia",
                      INPUT {&TT-PROCU} ).
        END.

        /* Endereco Comercial */
        IF  NOT CAN-FIND(FIRST crapenc WHERE
                         crapenc.cdcooper = par_cdcooper AND
                         crapenc.nrdconta = par_nrdconta AND
                         crapenc.idseqttl = 1            AND
                         crapenc.cdseqinc = 1            AND
                         crapenc.tpendass = 9)          THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Falta Registro de Endereco",
                  INPUT {&TT-ENDER} ).

        IF  par_cdtipcta = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Tipo da conta-corrente",
                  INPUT {&TT-CTCOR} ).

        IF  par_cdsitdct = 0 THEN
            RUN Trata_Critica
                ( INPUT 0,
                  INPUT "Situacao da conta-corrente",
                  INPUT {&TT-CTCOR} ).

        LEAVE CriticaPj.
    END.

    IF  par_dscritic = "" AND par_cdcritic = 0 THEN
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE.

PROCEDURE Trata_Critica:

    /* rotina generica para popular a temp-table de criticas */

    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_hdtabela AS HANDLE                         NO-UNDO.

    DEF VAR h-buffertt AS HANDLE                                    NO-UNDO.

    Critica: DO TRANSACTION
        ON ERROR  UNDO Critica, LEAVE Critica
        ON QUIT   UNDO Critica, LEAVE Critica
        ON STOP   UNDO Critica, LEAVE Critica
        ON ENDKEY UNDO Critica, LEAVE Critica:

        /* o PRIVATE-DATA recebeu o nome da tela na include de temp-table's */
        CREATE tt-critica-cadas.
        ASSIGN
            tt-critica-cadas.idseqttl = par_idseqttl
            tt-critica-cadas.nmdcampo = par_nmdcampo
            tt-critica-cadas.nmdatela = par_hdtabela:PRIVATE-DATA.

        /* grava a informacao na tabela correspondente a tela */
        CREATE BUFFER h-buffertt FOR TABLE par_hdtabela.
        h-buffertt:BUFFER-CREATE().
        h-buffertt:BUFFER-FIELD("idseqttl"):BUFFER-VALUE = par_idseqttl.
        h-buffertt:BUFFER-FIELD("nmdcampo"):BUFFER-VALUE = par_nmdcampo.

    END.

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


PROCEDURE Gera_Conta_Consorcio:

   DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM par_nrctacns AS INTE                            NO-UNDO.

   DEF VAR aux_flgtrans         AS LOGI                             NO-UNDO.


   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_cdcritic = 0
          aux_dscritic = "".

   Gera_Conta:
   DO TRANSACTION ON ERROR UNDO, LEAVE:
   
      DO aux_contador = 1 TO 10:
      
          FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                             crapass.nrdconta = par_nrdconta
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAIL crapass   THEN
               IF   LOCKED crapass THEN
                    DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        aux_cdcritic = 55.
                        LEAVE.
                    END.

          ASSIGN aux_cdcritic = 0.
          LEAVE.

      END.

      IF   aux_cdcritic <> 0   THEN
           UNDO Gera_Conta, LEAVE Gera_conta.

      IF   crapass.nrctacns <> 0   THEN
           DO:
               ASSIGN aux_dscritic = "Conta Consorcio ja foi gerada.".
               UNDO Gera_Conta, LEAVE Gera_conta.
           END.
      
      DO aux_contador = 1 TO 10:
       
          FIND gnsequt WHERE gnsequt.cdsequtl = 2 
               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
          IF   NOT AVAIL gnsequt   THEN
               IF   LOCKED gnsequt   THEN
                    DO:
                        aux_cdcritic = 77.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        CREATE gnsequt.
                        ASSIGN gnsequt.cdsequtl = 2
                               gnsequt.vlsequtl = 0.
                        VALIDATE gnsequt.
                    END.

          ASSIGN aux_cdcritic = 0.
          LEAVE.

      END.

      IF   aux_cdcritic <> 0   THEN
           UNDO Gera_Conta, LEAVE Gera_conta.
                 
      ASSIGN gnsequt.vlsequtl = gnsequt.vlsequtl + 1.

      ASSIGN crapass.nrctacns = gnsequt.vlsequtl * 10 
             par_nrctacns     = crapass.nrctacns.
                          
      RELEASE gnsequt.
      RELEASE crapass.
      
      Contador_alt:
      DO aux_contador = 1 TO 10:

         FIND crapalt WHERE crapalt.cdcooper = par_cdcooper AND
                            crapalt.nrdconta = par_nrdconta AND
                            crapalt.dtaltera = par_dtmvtolt 
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
         IF   NOT AVAILABLE crapalt THEN
              DO:
                  IF   LOCKED(crapalt) THEN
                       DO:
                          IF   aux_contador = 10 THEN
                               DO:
                                   ASSIGN aux_cdcritic = 72.
                                   LEAVE Contador_alt.
                               END.
                          ELSE 
                               PAUSE 1 NO-MESSAGE.
                       END.
                  ELSE 
                       DO:
                           CREATE crapalt.
                           ASSIGN crapalt.nrdconta = par_nrdconta
                                  crapalt.dtaltera = par_dtmvtolt
                                  crapalt.tpaltera = 2
                                  crapalt.cdcooper = par_cdcooper.
                           VALIDATE crapalt.

                           LEAVE Contador_alt.
                       END.
              END.
         ELSE
              LEAVE Contador_alt.
      END.

      IF  aux_cdcritic <> 0 THEN 
          UNDO Gera_Conta, LEAVE Gera_conta.

      ASSIGN log_nmdcampo = "solicitacao Conta Consorcio,".

      ASSIGN crapalt.cdoperad = par_cdoperad
             crapalt.dsaltera = crapalt.dsaltera + log_nmdcampo.
             
      ASSIGN aux_flgtrans = TRUE.
   END.

   IF   NOT aux_flgtrans   THEN
        DO: 
            IF   aux_cdcritic = 0   AND
                 aux_dscritic = ""  THEN
                 ASSIGN aux_dscritic = "Nao foi possivel concluir a operacao.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).       
            RETURN "NOK".
        END.
       
   RETURN "OK".

END PROCEDURE.


/*............................... FUNCIONS ..................................*/

FUNCTION CriticaCadastro RETURNS LOGICAL 
    ( INPUT par_cdcooper AS INTE,
      INPUT par_nrdconta AS INTE,
      INPUT par_nrdcaixa AS INTE,
      INPUT par_cdagenci AS INTE,
      INPUT par_dtmvtolt AS DATE,
      INPUT par_cdoperad AS CHAR ):

    RUN Critica_Cadastro
        ( INPUT par_cdcooper,
          INPUT par_nrdconta,
          INPUT par_nrdcaixa,
          INPUT par_cdagenci,
          INPUT par_dtmvtolt,
          INPUT par_cdoperad,
         OUTPUT TABLE tt-critica-cabec,                              
         OUTPUT TABLE tt-critica-cadas,                              
         OUTPUT TABLE tt-critica-ident,                              
         OUTPUT TABLE tt-critica-filia,                              
         OUTPUT TABLE tt-critica-ender,                              
         OUTPUT TABLE tt-critica-comer,                              
         OUTPUT TABLE tt-critica-telef,                              
         OUTPUT TABLE tt-critica-conju,                              
         OUTPUT TABLE tt-critica-ctato,                              
         OUTPUT TABLE tt-critica-respo,                              
         OUTPUT TABLE tt-critica-ctcor,                              
         OUTPUT TABLE tt-critica-regis,                              
         OUTPUT TABLE tt-critica-procu,                              
         OUTPUT TABLE tt-erro ) .
    
    IF  TEMP-TABLE tt-critica-cadas:HAS-RECORDS THEN
        RETURN TRUE.
    ELSE 
        RETURN FALSE.

END FUNCTION.


PROCEDURE bloqueia-opcao:

    DEF INPUT PARAM par_cdcooper    LIKE    crapcop.cdcooper            NO-UNDO.
    DEF INPUT PARAM par_cdagenci    LIKE    crapass.cdagenci            NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapass.nrdconta            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt    AS      DATE                        NO-UNDO.
                       
    DEF BUFFER crabass FOR crapass.


    FIND crabass WHERE crabass.cdcooper = par_cdcooper AND
                       crabass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF  AVAIL(crabass) THEN
        DO:

            /*Migracao Viacredi -> Altovale*/        
            IF  crabass.cdcooper = 1          AND
                par_dtmvtolt >= 12/11/2012     AND 
               (crabass.cdagenci = 07 OR
                crabass.cdagenci = 33 OR
                crabass.cdagenci = 38 OR
                crabass.cdagenci = 60 OR
                crabass.cdagenci = 62 OR
                crabass.cdagenci = 66) THEN
                RETURN "NOK".

            /*Migracao Acredicop -> Viacredi*/
            IF  crabass.cdcooper = 2           AND
                par_dtmvtolt >= 12/16/2013     AND 
               (crabass.cdagenci = 02 OR
                crabass.cdagenci = 04 OR
                crabass.cdagenci = 06 OR
                crabass.cdagenci = 07 OR
                crabass.cdagenci = 11) THEN
                RETURN "NOK".

            /*Migracao Concredi -> Viacredi*/
            IF  crabass.cdcooper = 4        AND
                par_dtmvtolt >= 11/12/2014  THEN
                RETURN "NOK".
                
            /*Migracao Credimilsul -> SCRCRED
            IF  crabass.cdcooper = 15        AND
                par_dtmvtolt >= 11/07/2014  THEN
                RETURN "NOK".
			*/

			/*Migracao Transulcred -> Transpocred*/
            IF  crabass.cdcooper = 17        AND
                par_dtmvtolt >= 12/12/2016  THEN
                RETURN "NOK".
        END.
    ELSE
        RETURN "NOK".

    RETURN "OK".
END PROCEDURE.
