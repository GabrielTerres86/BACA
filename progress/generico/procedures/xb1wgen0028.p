/*............................................................................

   Programa: xb1wgen0028.p
   Autor   : Guilherme
   Data    : Marco/2008                        Ultima atualizacao: 29/07/2015

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Ocorrencias (b1wgen0028.p)

   Alteracoes: 03/09/2008 - Implementar solicitacao de 2 via de senha (David).
   
               23/12/2008 - Adicionado variavel dtvalchr (Guilherme).
               
               26/12/2008 - Nao permitir solicitacao de 2via se o cartao nao
                            foi entregue ainda (David).
                            
               22/04/2009 - Incluir procedures verifica_acesso_alterar e
                            verifica_acesso_cancblq (David).             

               30/07/2010 - Retornar mensagem de alerta na procedure 
                            desfaz_cancblq_cartao (David).
                            
               28/10/2010 - Adaptacao para PJ (David).             
               
               25/11/2010 - Inclusão temporariamente do parametro flgliber
                            (Transferencia do PAC5 Acredi) (Irlan)
                            
               22/03/2011 - Adicionado procedures de opcao de encerramento
                            de cartao de credito (Jorge).
                            
               27/04/2011 - CEP integrado. Inclusão de parametros adicionais
                            nrender, complen, nrcxaps para avalistas em: 
                            cadastra_novo_cartao, altera_limcred_cartao, 
                            efetua_entrega2via_cartao, renova_cartao, 
                            grava_dados_habilitacao. (André - DB1)

               15/07/2011 - Inclusao da procedure extrato_cartao_bradesco
                            Impressao do Extrato Cecred Visa em PDF
                           (Guilherme/Supero)
                           
               12/09/2011 - Incluida procedure busca-cartao (Henrique).
               
               14/11/2011 - Ajuste na procedure busca-cartao (Adriano).
               
               20/04/2012 - Incluido procedure gera_impressao_contrato_bb.
                            (David Kruger). 
                            
               10/07/2012 - Incluído passagem de parâmetro nmextttl na procedure
                            "cadastra_novo_cartao" (Guilherme Maba).
                            
               05/12/2012 - Incluido novo parametro na verifica_acesso_2via
                            (David Kruger).
                            
               01/04/2013 - Ajuste na procedure valida_nova_proposta para 
                            incluir os parametros aux_idorigem, aux_nmdatela, 
                            aux_cdoperad na chamada da valida_nova_proposta
                            (Adriano). 
                            
               03/04/2013 - Inclusão de novas procedures p/ tratamento de
                            cartoes bancoob (Jean Michel). 
                            
               20/05/2014 - Inclusao da procedure "valida_entrega_cartao_bancoob".
                            (James)             
                            
               18/06/2014 - Inclusao do parametro aux_tpdpagto na procedure
                            cadastra_novo_cartao (Jean Michel).
                            
               28/07/2014 - Ajuste em adicionar param de cdagenci e nrdcaixa 
                            em proc. grava_dados_habilitacao.
                            (Jorge/Gielow) - SD 156112          
                            
               21/08/2014 - Incluso parametro inpessoa na procedure valida_dados_cartao 
                           (Daniel) - SoftDesk  188116   
                                                   
                           24/09/2014 - Incluir parametro nmempres na chamada da cadastra_novo_cartao
                                                        (Renato - Supero) - SD 204631
                            
               02/10/2014 - Incluso parametro aux_bthabipj na procedure carrega_dados_inclusao 
                             (Vanessa) 
                             
               09/04/2015 - #272659 Adicionado alerta para bloqueio de cartão BB (Carlos)
               
               23/06/2015 - Inclusao procedure "grava_dados_cartao_nao_gerado".
                            (James)
                            
               29/07/215 - Inclusao procedure "verifica_acesso_tela_taa". (James)             
                           
                           06/12/2016 - P341-Automatização BACENJUD - Alterar a passagem 
                                        da descrição do departamento como parametro e 
                                                        passar o código (Renato Darosci)           
              
               29/03/2018 - Ajustes na proc valida_nova_proposta pra retornar flag
                            aux_solcoord e sempre retornar a temp-table erro.
                            PRJ366 (Lombardi).
               
			   12/12/2018 - Adicionado campo flgprovi e criado Procedure para validar a assinatura da senha TA Online (Anderson-Alan Supero P432)

............................................................................ */


DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_nrcrcard AS DECI                                           NO-UNDO.
DEF VAR aux_nrcrcard2 AS DECI                                          NO-UNDO.
DEF VAR aux_nrctr2vi AS DECI                                           NO-UNDO.
DEF VAR aux_nrctrcrd AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_indposic AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_dsgraupr AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsadmcrd AS CHAR                                           NO-UNDO.
DEF VAR aux_cdadmcrd AS INTE                                           NO-UNDO.
DEF VAR aux_dscartao AS CHAR                                           NO-UNDO.
DEF VAR aux_vllimpro AS DECI                                           NO-UNDO.
DEF VAR aux_dddebito AS INTE                                           NO-UNDO.
DEF VAR aux_dtnasccr AS DATE                                           NO-UNDO.
DEF VAR aux_nrdoccrd AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcpf AS CHAR                                           NO-UNDO.
DEF VAR aux_nmextttl AS CHAR                                           NO-UNDO.
DEF VAR aux_nmtitcrd AS CHAR                                           NO-UNDO.
DEF VAR aux_nmempres AS CHAR                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalcon AS DECI                                           NO-UNDO.
DEF VAR aux_vloutras AS DECI                                           NO-UNDO.
DEF VAR aux_vlalugue AS DECI                                           NO-UNDO.
DEF VAR aux_flgimpnp AS LOGI                                           NO-UNDO.
DEF VAR aux_vllimdeb AS DECI                                           NO-UNDO.
DEF VAR aux_vllimcrd AS DECI                                           NO-UNDO.
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.
DEF VAR aux_dtvalida AS CHAR                                           NO-UNDO.
DEF VAR aux_dtrenova AS DATE                                           NO-UNDO.
DEF VAR aux_cdmotivo AS INTE                                           NO-UNDO.
DEF VAR aux_idimpres AS INTE                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI                                           NO-UNDO.
DEF VAR aux_dslinha1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinha2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinha3 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdestin AS CHAR                                           NO-UNDO.
DEF VAR aux_dscontat AS CHAR                                           NO-UNDO.
DEF VAR aux_dsemprp2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmot2vi AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_nrctaava AS INTE                                           NO-UNDO.
DEF VAR aux_flgadmbb AS LOGI                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfrep AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnasctl AS DATE                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_vllimglb AS DECI                                           NO-UNDO.
DEF VAR aux_flgativo AS LOGI                                           NO-UNDO.
DEF VAR aux_nrcpfpri AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfseg AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfter AS DECI                                           NO-UNDO.
DEF VAR aux_nmpespri AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpesseg AS CHAR                                           NO-UNDO.
DEF VAR aux_nmpester AS CHAR                                           NO-UNDO.
DEF VAR aux_dtnaspri AS DATE                                           NO-UNDO.
DEF VAR aux_dtnasseg AS DATE                                           NO-UNDO.
DEF VAR aux_dtnaster AS DATE                                           NO-UNDO.
DEF VAR aux_flgimp2v AS LOGI                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dsrepinc AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctrhcj AS INTE                                           NO-UNDO.
DEF VAR aux_nrrepinc AS DECI                                           NO-UNDO.
DEF VAR aux_represen AS CHAR                                           NO-UNDO.
DEF VAR aux_cpfrepre AS CHAR EXTENT 3                                  NO-UNDO.
DEF VAR aux_repsolic AS CHAR                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_bfexiste AS LOGI                                           NO-UNDO.
DEF VAR aux_nmabrevi AS LOGI                                           NO-UNDO.
DEF VAR aux_tipopesq AS INTE                                           NO-UNDO.
DEF VAR aux_codaadmi AS INTE                                           NO-UNDO.
DEF VAR aux_codnadmi AS INTE                                           NO-UNDO.
DEF VAR aux_tpdpagto AS INTE                                           NO-UNDO.
DEF VAR aux_tpenvcrd AS INTE                                           NO-UNDO.
DEF VAR aux_bthabipj AS INTE                                           NO-UNDO.

DEF VAR aux_nrctaav1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcpfav1 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav1 AS DECI                                           NO-UNDO.
DEF VAR aux_nmdaval1 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcjav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_tdccjav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_doccjav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende1av1 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende2av1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_emailav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidav1 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufava1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcepav1 AS INTE                                           NO-UNDO.

DEF VAR aux_nrctaav2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepav2 AS INTE                                           NO-UNDO.
DEF VAR aux_nmdaval2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tdccjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_doccjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende1av2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende2av2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_emailav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufava2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfav2 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav2 AS DECI                                           NO-UNDO.
DEF VAR aux_flgliber AS LOGI                                           NO-UNDO.
DEF VAR aux_dtassele AS DATE                                           NO-UNDO.
DEF VAR aux_dsvlrprm AS CHAR                                           NO-UNDO.

DEF VAR aux_nrender1 AS INTE                                           NO-UNDO.
DEF VAR aux_complen1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrender2 AS INTE                                           NO-UNDO.
DEF VAR aux_complen2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps2 AS INTE                                           NO-UNDO.

DEF VAR aux_dtvctini AS DATE                                           NO-UNDO.
DEF VAR aux_dtvctfim AS DATE                                           NO-UNDO.

DEF VAR aux_nrregist AS INT                                            NO-UNDO.
DEF VAR aux_nriniseq AS INT                                            NO-UNDO.
DEF VAR aux_qtregist AS INT                                            NO-UNDO.
DEF VAR aux_flgpagin AS LOG                                            NO-UNDO.
DEF VAR aux_cddepart AS INTE                                           NO-UNDO.
DEF VAR aux_flag2via AS LOG                                            NO-UNDO.
DEF VAR aux_nrcctitg  LIKE crawcrd.nrcctitg                            NO-UNDO.
DEF VAR aux_nrcctitg2 LIKE crawcrd.nrcctitg                            NO-UNDO.
DEF VAR aux_inacetaa  LIKE crapcrd.inacetaa                            NO-UNDO.
DEF VAR aux_dssentaa  LIKE crapcrd.dssentaa                            NO-UNDO.
DEF VAR aux_dssencfm  LIKE crapcrd.dssentaa                            NO-UNDO.
DEF VAR aux_dssennov AS CHAR                                           NO-UNDO.
DEF VAR aux_dssencon AS CHAR                                           NO-UNDO.
DEF VAR aux_flgcadas AS CHAR                                           NO-UNDO.
DEF VAR aux_dsrepres AS CHAR                                           NO-UNDO.
DEF VAR aux_flgdebit AS LOG                                            NO-UNDO.
DEF VAR aux_flpurcrd AS LOG                                            NO-UNDO.

DEF VAR aux_solcoord AS INT                                            NO-UNDO.

DEF VAR aux_cddsenha AS INT                                            NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:
            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrcrcard" THEN aux_nrcrcard = DECI(tt-param.valorCampo).
            WHEN "nrcrcard2" THEN aux_nrcrcard2 = DECI(tt-param.valorCampo).
            WHEN "nrctrcrd" THEN aux_nrctrcrd = INTE(tt-param.valorCampo).
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "indposic" THEN aux_indposic = INTE(tt-param.valorCampo).
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.           
            WHEN "dsgraupr" THEN aux_dsgraupr = tt-param.valorCampo.
            WHEN "nmprimtl" THEN aux_nmprimtl = tt-param.valorCampo.
            WHEN "nmextttl" THEN aux_nmextttl = tt-param.valorCampo.
            WHEN "nmtitcrd" THEN aux_nmtitcrd = tt-param.valorCampo.
            WHEN "nmempres" THEN aux_nmempres = tt-param.valorCampo.
            WHEN "nrcpfcpf" THEN aux_nrcpfcpf = tt-param.valorCampo.
            WHEN "dsadmcrd" THEN aux_dsadmcrd = tt-param.valorCampo.
            WHEN "cdadmcrd" THEN aux_cdadmcrd = INTE(tt-param.valorCampo).
            WHEN "dscartao" THEN aux_dscartao = tt-param.valorCampo.
            WHEN "vllimpro" THEN aux_vllimpro = DECI(tt-param.valorCampo).
            WHEN "dddebito" THEN aux_dddebito = INTE(tt-param.valorCampo).
            WHEN "dtnasccr" THEN aux_dtnasccr = DATE(tt-param.valorCampo).
            WHEN "nrdoccrd" THEN aux_nrdoccrd = tt-param.valorCampo.
            WHEN "flgimpnp" THEN aux_flgimpnp = LOGICAL(tt-param.valorCampo).
            WHEN "vlalugue" THEN aux_vlalugue = DECI(tt-param.valorCampo).
            WHEN "vloutras" THEN aux_vloutras = DECI(tt-param.valorCampo).
            WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
            WHEN "vlsalcon" THEN aux_vlsalcon = DECI(tt-param.valorCampo).
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).            
            WHEN "dtvalida" THEN aux_dtvalida = tt-param.valorCampo.
            WHEN "vllimdeb" THEN aux_vllimdeb = DECI(tt-param.valorCampo).
            WHEN "vllimcrd" THEN aux_vllimcrd = DECI(tt-param.valorCampo).
            WHEN "dtrenova" THEN aux_dtrenova = DATE(tt-param.valorCampo).
            WHEN "cdmotivo" THEN aux_cdmotivo = INTE(tt-param.valorCampo).
            WHEN "idimpres" THEN aux_idimpres = INTE(tt-param.valorCampo).
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "dslinha1" THEN aux_dslinha1 = tt-param.valorCampo.
            WHEN "dslinha2" THEN aux_dslinha2 = tt-param.valorCampo.
            WHEN "dslinha3" THEN aux_dslinha3 = tt-param.valorCampo.
            WHEN "dsdestin" THEN aux_dsdestin = tt-param.valorCampo.
            WHEN "dscontat" THEN aux_dscontat = tt-param.valorCampo.
            WHEN "dsemprp2" THEN aux_dsemprp2 = tt-param.valorCampo.
            WHEN "dsmot2vi" THEN aux_dsmot2vi = tt-param.valorCampo.
            WHEN "nrctaava" THEN aux_nrctaava = INTE(tt-param.valorCampo).
            WHEN "nrcpfrep" THEN aux_nrcpfrep = tt-param.valorCampo.
            WHEN "vllimglb" THEN aux_vllimglb = DECI(tt-param.valorCampo).
            WHEN "flgativo" THEN aux_flgativo = LOGICAL(tt-param.valorCampo).
            WHEN "nrcpfpri" THEN aux_nrcpfpri = DECI(tt-param.valorCampo).
            WHEN "nrcpfseg" THEN aux_nrcpfseg = DECI(tt-param.valorCampo).
            WHEN "nrcpfter" THEN aux_nrcpfter = DECI(tt-param.valorCampo).
            WHEN "nmpespri" THEN aux_nmpespri = tt-param.valorCampo.
            WHEN "nmpesseg" THEN aux_nmpesseg = tt-param.valorCampo.
            WHEN "nmpester" THEN aux_nmpester = tt-param.valorCampo.
            WHEN "dtnaspri" THEN aux_dtnaspri = DATE(tt-param.valorCampo).
            WHEN "dtnasseg" THEN aux_dtnasseg = DATE(tt-param.valorCampo).
            WHEN "dtnaster" THEN aux_dtnaster = DATE(tt-param.valorCampo).
            WHEN "nmendter" THEN aux_nmendter = tt-param.valorCampo.
            WHEN "flgimp2v" THEN aux_flgimp2v = LOGICAL(tt-param.valorCampo).
            WHEN "dsrepinc" THEN aux_dsrepinc = tt-param.valorCampo.
            WHEN "nrctrhcj" THEN aux_nrctrhcj = INTE(tt-param.valorCampo).
            WHEN "nrrepinc" THEN aux_nrrepinc = DECI(tt-param.valorCampo).
            WHEN "repsolic" THEN aux_repsolic = tt-param.valorCampo.
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "bfexiste" THEN aux_bfexiste = LOGICAL(tt-param.valorCampo).
            WHEN "nmabrevi" THEN aux_nmabrevi = LOGICAL(tt-param.valorCampo).
            WHEN "tipopesq" THEN aux_tipopesq = INTE(tt-param.valorCampo).
            WHEN "codnadmi" THEN aux_codnadmi = INTE(tt-param.valorCampo).
            WHEN "codaadmi" THEN aux_codaadmi = INTE(tt-param.valorCampo).
            WHEN "nrctaav1" THEN aux_nrctaav1 = INTE(tt-param.valorCampo).
            WHEN "nrcepav1" THEN aux_nrcepav1 = INTE(tt-param.valorCampo).
            WHEN "nrcpfav1" THEN aux_nrcpfav1 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav1" THEN aux_cpfcjav1 = DECI(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "nmdaval1" THEN aux_nmdaval1 = tt-param.valorCampo.
            WHEN "tpdocav1" THEN aux_tpdocav1 = tt-param.valorCampo.
            WHEN "dsdocav1" THEN aux_dsdocav1 = tt-param.valorCampo.
            WHEN "nmdcjav1" THEN aux_nmdcjav1 = tt-param.valorCampo.
            WHEN "tdccjav1" THEN aux_tdccjav1 = tt-param.valorCampo.
            WHEN "doccjav1" THEN aux_doccjav1 = tt-param.valorCampo.
            WHEN "ende1av1" THEN aux_ende1av1 = tt-param.valorCampo.
            WHEN "ende2av1" THEN aux_ende2av1 = tt-param.valorCampo.
            WHEN "nrfonav1" THEN aux_nrfonav1 = tt-param.valorCampo.
            WHEN "emailav1" THEN aux_emailav1 = tt-param.valorCampo.
            WHEN "nmcidav1" THEN aux_nmcidav1 = tt-param.valorCampo.
            WHEN "cdufava1" THEN aux_cdufava1 = tt-param.valorCampo.
            WHEN "tpdpagto" THEN aux_tpdpagto = INTE(tt-param.valorCampo).
            WHEN "tpenvcrd" THEN aux_tpenvcrd = INTE(tt-param.valorCampo).
            WHEN "nrctaav2" THEN aux_nrctaav2 = INTE(tt-param.valorCampo).
            WHEN "nrcepav2" THEN aux_nrcepav2 = INTE(tt-param.valorCampo).
            WHEN "nrcpfav2" THEN aux_nrcpfav2 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav2" THEN aux_cpfcjav2 = DECI(tt-param.valorCampo).     
            WHEN "nmdaval2" THEN aux_nmdaval2 = tt-param.valorCampo.
            WHEN "tpdocav2" THEN aux_tpdocav2 = tt-param.valorCampo.
            WHEN "dsdocav2" THEN aux_dsdocav2 = tt-param.valorCampo.
            WHEN "nmdcjav2" THEN aux_nmdcjav2 = tt-param.valorCampo.
            WHEN "tdccjav2" THEN aux_tdccjav2 = tt-param.valorCampo.
            WHEN "doccjav2" THEN aux_doccjav2 = tt-param.valorCampo.
            WHEN "ende1av2" THEN aux_ende1av2 = tt-param.valorCampo.
            WHEN "ende2av2" THEN aux_ende2av2 = tt-param.valorCampo.
            WHEN "nrfonav2" THEN aux_nrfonav2 = tt-param.valorCampo.
            WHEN "emailav2" THEN aux_emailav2 = tt-param.valorCampo.
            WHEN "nmcidav2" THEN aux_nmcidav2 = tt-param.valorCampo.
            WHEN "cdufava2" THEN aux_cdufava2 = tt-param.valorCampo.

            WHEN "nrender1" THEN aux_nrender1 = INTE(tt-param.valorCampo).
            WHEN "complen1" THEN aux_complen1 = tt-param.valorCampo.
            WHEN "nrcxaps1" THEN aux_nrcxaps1 = INTE(tt-param.valorCampo).
            WHEN "nrender2" THEN aux_nrender2 = INTE(tt-param.valorCampo).
            WHEN "complen2" THEN aux_complen2 = tt-param.valorCampo.
            WHEN "nrcxaps2" THEN aux_nrcxaps2 = INTE(tt-param.valorCampo).
            WHEN "dtvctini" THEN aux_dtvctini = DATE(tt-param.valorCampo).
            WHEN "dtvctfim" THEN aux_dtvctfim = DATE(tt-param.valorCampo).

            WHEN "nrregist"  THEN aux_nrregist  = INTE(tt-param.valorCampo).
            WHEN "nriniseq"  THEN aux_nriniseq  = INTE(tt-param.valorCampo).
            WHEN "flgpagin"  THEN aux_flgpagin  = LOGICAL(tt-param.valorCampo).
            WHEN "cddepart"  THEN aux_cddepart  = INTE(tt-param.valorCampo).
            WHEN "flag2via"  THEN aux_flag2via  = LOGICAL(tt-param.valorCampo).
            WHEN "nrcctitg"  THEN aux_nrcctitg  = DECI(tt-param.valorCampo).
            WHEN "nrcctitg2" THEN aux_nrcctitg2 = DECI(tt-param.valorCampo).            
            WHEN "dssentaa"  THEN aux_dssentaa  = tt-param.valorCampo.
            WHEN "dssencfm"  THEN aux_dssencfm  = tt-param.valorCampo.
            WHEN "dssennov"  THEN aux_dssennov  = tt-param.valorCampo.
            WHEN "dssencon"  THEN aux_dssencon  = tt-param.valorCampo.
            WHEN "dsrepres"  THEN aux_dsrepres  = tt-param.valorCampo.
            WHEN "flgdebit"  THEN aux_flgdebit  = LOGICAL(tt-param.valorCampo).
            WHEN "cddsenha"  THEN aux_cddsenha  = INTE(tt-param.valorCampo).
            
        END CASE.

    END. /** Fim do FOR EACH tt-param **/

END PROCEDURE.

/************************************
        PROCEDURES GERAIS
*************************************/
/******************************************************
    Verifica se um determinado cartao eh do BB
 *****************************************************/
PROCEDURE verifica_cartao_bb:

    RUN verifica_cartao_bb IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdadmcrd,
                                  OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
                        
END PROCEDURE.

/**********************************
    OPCAO PRINCIPAL
***********************************/
/******************************************************
    Lista os cartoes do cooperado
 *****************************************************/
PROCEDURE lista_cartoes:

    RUN lista_cartoes IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nrdconta,
                              INPUT aux_idorigem,
                              INPUT aux_idseqttl,
                              INPUT aux_nmdatela,
                              INPUT FALSE,
                             OUTPUT aux_flgativo,
                             OUTPUT aux_nrctrhcj,
                             OUTPUT aux_flgliber,
                             OUTPUT aux_dtassele,
                             OUTPUT aux_dsvlrprm,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-cartoes,
                             OUTPUT TABLE tt-lim_total).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO: 
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-cartoes:HANDLE,
                             INPUT "Dados").

            RUN piXmlAtributo (INPUT "flgativo",INPUT STRING(aux_flgativo)).
            RUN piXmlAtributo (INPUT "nrctrhcj",INPUT STRING(aux_nrctrhcj)).
            RUN piXmlAtributo (INPUT "flgliber",INPUT STRING(aux_flgliber)).
            RUN piXmlAtributo (INPUT "dtassele",INPUT STRING(aux_dtassele)).
            RUN piXmlAtributo (INPUT "dsvlrprm",INPUT STRING(aux_dsvlrprm)).

            RUN piXmlExport (INPUT TEMP-TABLE tt-lim_total:HANDLE,
                             INPUT "Limite").                             
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/********************
    OPCAO NOVO
********************/
/******************************************************
    Carregar dados para efetuar uma inclusao de cartao
 *****************************************************/
PROCEDURE carrega_dados_inclusao:

    RUN carrega_dados_inclusao IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nrdconta,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_idorigem,
                                       INPUT aux_idseqttl,
                                       INPUT aux_nmdatela,
                                       INPUT aux_bthabipj,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-nova_proposta).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-nova_proposta:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

/******************************************************
    Validar uma nova proposta de cartao de credito
 *****************************************************/
PROCEDURE valida_nova_proposta:
    
    RUN valida_nova_proposta IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_idorigem,
                                     INPUT aux_nmdatela,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_dsgraupr,
                                     INPUT aux_nmtitcrd,
                                     INPUT aux_dsadmcrd,
                                     INPUT aux_dscartao,
                                     INPUT aux_vllimpro,
                                     INPUT aux_vllimdeb,
                                     INPUT aux_nrcpfcpf,
                                     INPUT aux_dddebito,
                                     INPUT aux_dtnasccr,
                                     INPUT aux_nrdoccrd,
                                     INPUT aux_dsrepinc,
                                     INPUT aux_dsrepres,
                                     INPUT aux_flgdebit,
                                     INPUT aux_nrctrcrd,
                                    OUTPUT aux_solcoord,
                                    OUTPUT TABLE tt-msg-confirma, 
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Mensagem").
            RUN piXmlAtributo (INPUT "solcoord",INPUT STRING(aux_solcoord)).

            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF AVAILABLE tt-erro  THEN
                RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                                 INPUT "Erro").
            RUN piXmlSave.      
        END.
       
END PROCEDURE.

/******************************************************
    Efetuar o cadastro de um novo cartao de credito
 *****************************************************/
PROCEDURE cadastra_novo_cartao:

    RUN cadastra_novo_cartao IN hBO (INPUT aux_cdcooper,    
                                     INPUT aux_cdagenci,    
                                     INPUT aux_nrdcaixa,     
                                     INPUT aux_cdoperad,      
                                     INPUT aux_nrdconta,       
                                     INPUT aux_dtmvtolt,        
                                     INPUT aux_idorigem,         
                                     INPUT aux_idseqttl,          
                                     INPUT aux_nmdatela,           
                                     INPUT aux_dsgraupr,            
                                     INPUT aux_nrcpfcpf,
                                     INPUT aux_nmextttl,
                                     INPUT aux_nmtitcrd,
                                     INPUT aux_nmempres,
                                     INPUT aux_nrdoccrd,      
                                     INPUT aux_dtnasccr,       
                                     INPUT aux_dsadmcrd,        
                                     INPUT aux_cdadmcrd,
                                     INPUT aux_dscartao,         
                                     INPUT aux_vlsalari,          
                                     INPUT aux_vlsalcon,           
                                     INPUT aux_vloutras,            
                                     INPUT aux_vlalugue,             
                                     INPUT aux_dddebito,              
                                     INPUT aux_vllimpro,               
                                     INPUT aux_flgimpnp,                
                                     INPUT aux_vllimdeb,  
                                     INPUT aux_nrrepinc,
                                     INPUT aux_tpdpagto,
                                     INPUT aux_tpenvcrd,
                                     /** 1o avalista **/                  
                                     INPUT aux_nrctaav1,                   
                                     INPUT aux_nmdaval1,                    
                                     INPUT aux_nrcpfav1,                     
                                     INPUT aux_tpdocav1,                      
                                     INPUT aux_dsdocav1,                       
                                     INPUT aux_nmdcjav1,  
                                     INPUT aux_cpfcjav1,   
                                     INPUT aux_tdccjav1,    
                                     INPUT aux_doccjav1,     
                                     INPUT aux_ende1av1,      
                                     INPUT aux_ende2av1,       
                                     INPUT aux_nrfonav1,        
                                     INPUT aux_emailav1,         
                                     INPUT aux_nmcidav1,          
                                     INPUT aux_cdufava1,           
                                     INPUT aux_nrcepav1,
                                     INPUT aux_nrender1,
                                     INPUT aux_complen1,
                                     INPUT aux_nrcxaps1,
                                     /** 2o avalista **/             
                                     INPUT aux_nrctaav2,              
                                     INPUT aux_nmdaval2,               
                                     INPUT aux_nrcpfav2,                
                                     INPUT aux_tpdocav2,                 
                                     INPUT aux_dsdocav2,                  
                                     INPUT aux_nmdcjav2,                   
                                     INPUT aux_cpfcjav2,                    
                                     INPUT aux_tdccjav2,                     
                                     INPUT aux_doccjav2,  
                                     INPUT aux_ende1av2,   
                                     INPUT aux_ende2av2,    
                                     INPUT aux_nrfonav2,     
                                     INPUT aux_emailav2,      
                                     INPUT aux_nmcidav2,       
                                     INPUT aux_cdufava2,        
                                     INPUT aux_nrcepav2, 
                                     INPUT aux_nrender2,
                                     INPUT aux_complen2,
                                     INPUT aux_nrcxaps2,
                                     INPUT aux_dsrepres,
                                     INPUT aux_dsrepinc,
                                     INPUT aux_flgdebit,
                                     INPUT aux_nrctrcrd,
                                    OUTPUT TABLE tt-ctr_novo_cartao, 
                                    OUTPUT TABLE tt-msg-confirma, 
                                    OUTPUT TABLE tt-erro).        

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagem").
            RUN piXmlExport (INPUT TEMP-TABLE tt-ctr_novo_cartao:HANDLE,
                             INPUT "Numero_Contrato").
            RUN piXmlSave.
        END.        
        
END PROCEDURE.

/*********************
    OPCAO IMPRIMIR
*********************/
/**********************************************************
     Carregar dados para impressos do limite de credito    
***********************************************************/
PROCEDURE impressoes_cartoes:

    RUN impressoes_cartoes IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_cdagenci,
                                   INPUT aux_nrdcaixa,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_idorigem,
                                   INPUT aux_nrdconta,
                                   INPUT aux_idseqttl,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_dtmvtopr,
                                   INPUT aux_inproces,
                                   INPUT aux_idimpres,
                                   INPUT aux_nrctrcrd,
                                   INPUT aux_flgerlog,
                                   INPUT aux_flgimpnp,
                                   INPUT aux_cdmotivo,
                                  OUTPUT TABLE tt-dados_prp_ccr,
                                  OUTPUT TABLE tt-dados_prp_emiss_ccr,
                                  OUTPUT TABLE tt-outros_cartoes,
                                  OUTPUT TABLE tt-termo_cancblq_cartao,
                                  OUTPUT TABLE tt-ctr_credicard,
                                  OUTPUT TABLE tt-bdn_visa_cecred,
                                  OUTPUT TABLE tt-termo_solici2via,
                                  OUTPUT TABLE tt-avais-ctr,
                                  OUTPUT TABLE tt-ctr_bb,
                                  OUTPUT TABLE tt-termo_alt_dt_venc,
                                  OUTPUT TABLE tt-alt-limite-pj,
                                  OUTPUT TABLE tt-alt-dtvenc-pj,
                                  OUTPUT TABLE tt-termo-entreg-pj,
                                  OUTPUT TABLE tt-segviasen-cartao,
                                  OUTPUT TABLE tt-segvia-cartao,
                                  OUTPUT TABLE tt-termocan-cartao,
                                  OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_prp_ccr:HANDLE,
                             INPUT "Proposta").
            RUN piXmlExport (INPUT TEMP-TABLE tt-outros_cartoes:HANDLE,
                             INPUT "Outros_Cartoes").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo_cancblq_cartao:HANDLE,
                             INPUT "Cancelamento_Bloqueio").
            RUN piXmlExport (INPUT TEMP-TABLE tt-ctr_credicard:HANDLE,
                             INPUT "Contrato_Credicard").
            RUN piXmlExport (INPUT TEMP-TABLE tt-bdn_visa_cecred:HANDLE,
                             INPUT "Contrato_BRADESCO_CECRED__VISA").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo_solici2via:HANDLE,
                             INPUT "Termo_2via").
            RUN piXmlExport (INPUT TEMP-TABLE tt-avais-ctr:HANDLE,
                             INPUT "Avalistas").
            RUN piXmlExport (INPUT TEMP-TABLE tt-ctr_bb:HANDLE,
                             INPUT "Contrato_BB").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo_alt_dt_venc:HANDLE,
                             INPUT "Termo_Alt_Data_Vcto").   
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados_prp_emiss_ccr:HANDLE,
                             INPUT "Dados_Proposta_Emissao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-alt-limite-pj:HANDLE,
                             INPUT "Dados_Limite_PJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-alt-dtvenc-pj:HANDLE,
                             INPUT "Dados_Vencimento_PJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termo-entreg-pj:HANDLE,
                             INPUT "Termo_Entrega_PJ").
            RUN piXmlExport (INPUT TEMP-TABLE tt-segviasen-cartao:HANDLE,
                             INPUT "Dados_2Via_Senha").
            RUN piXmlExport (INPUT TEMP-TABLE tt-segvia-cartao:HANDLE,
                             INPUT "Dados_2Via").
            RUN piXmlExport (INPUT TEMP-TABLE tt-termocan-cartao:HANDLE,
                             INPUT "Termo_Cancelamento_PJ").
            RUN piXmlSave.
        END.
  
END PROCEDURE.

/*********************
    OPCAO CONSULTAR
*********************/    
/******************************************************
    Consultar os dados de um determinado cartao
 *****************************************************/
PROCEDURE consulta_dados_cartao:

    RUN consulta_dados_cartao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nrdconta,
                                      INPUT aux_nrctrcrd,
                                      INPUT aux_idorigem,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nmdatela,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-dados_cartao,
                                     OUTPUT TABLE tt-msg-confirma).

    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
       END.
    ELSE 
       DO:
           RUN piXmlNew. 
           RUN piXmlExport (INPUT TEMP-TABLE tt-dados_cartao:HANDLE,
                           INPUT "Dados").
           RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                            INPUT "Mensagens").
           RUN piXmlSave.                 
       END.                     

END PROCEDURE.

/**********************************************************
    Consultar os ultimos debitos de um determinado cartao
 **********************************************************/
PROCEDURE ult_debitos:

    RUN ult_debitos IN hBO (INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nrdconta,
                            INPUT aux_nrcrcard,
                            INPUT aux_idorigem,
                            INPUT aux_idseqttl,
                            INPUT aux_nmdatela,
                           OUTPUT TABLE tt-ult_deb).

    RUN piXmlSaida (INPUT TEMP-TABLE tt-ult_deb:HANDLE,
                    INPUT "Dados").

END PROCEDURE.

/******************************************************
    Carregar avalistas de um determinado cartao
 *****************************************************/
PROCEDURE carrega_dados_avais:

    RUN carrega_dados_avais IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_idorigem,
                                    INPUT aux_nrdconta,
                                    INPUT aux_idseqttl,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrctrcrd,
                                   OUTPUT TABLE tt-dados-avais,
                                   OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                        INPUT "Dados").
         
END PROCEDURE.

/************************
    OPCAO LIBERAR
*************************/
/******************************************************
    Validar e Efetuar a liberacao do cartao de credito
 *****************************************************/
PROCEDURE libera_cartao:

    RUN libera_cartao IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nrdconta,
                              INPUT aux_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_idseqttl,
                              INPUT aux_nmdatela,
                              INPUT aux_nrctrcrd,
                              INPUT aux_inconfir,
                             OUTPUT TABLE tt-msg-confirma,
                             OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Dados").
         
END PROCEDURE.

/******************************************************
    Desfazer a liberacao de um determinado cartao
 *****************************************************/
PROCEDURE desfaz_liberacao_cartao:

    RUN desfaz_liberacao_cartao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_idorigem,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nmdatela,
                                        INPUT aux_nrctrcrd,
                                       OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.         
        
END PROCEDURE.

/**************************
    OPCAO ENTREGAR
***************************/
/******************************************************
    Validar dados para efetuar a entregar de um cartao
 *****************************************************/
PROCEDURE valida_entrega_cartao:

    RUN valida_entrega_cartao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_idorigem,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nmdatela,
                                      INPUT aux_inconfir,
                                      INPUT aux_nrctrcrd,
                                      INPUT aux_nrcrcard,
                                      INPUT aux_nrcrcard2,
                                      INPUT aux_dtvalida,
                                      INPUT aux_repsolic,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-msg-confirma).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

PROCEDURE grava_dados_cartao_nao_gerado:

    RUN grava_dados_cartao_nao_gerado IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nrdconta,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_idorigem,
                                              INPUT aux_idseqttl,
                                              INPUT aux_nmdatela,
                                              INPUT aux_nrctrcrd,
                                              INPUT aux_nrcrcard,
                                              INPUT aux_nrcctitg,
                                              INPUT aux_nrcctitg2,
                                              INPUT aux_repsolic,
                                             OUTPUT TABLE tt-erro).
 
    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
       END.
    ELSE 
       DO:
           RUN piXmlNew.
           RUN piXmlSave.
       END.
END.

PROCEDURE valida_entrega_cartao_bancoob:

    RUN valida_entrega_cartao_bancoob IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nrdconta,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_idorigem,
                                              INPUT aux_idseqttl,
                                              INPUT aux_nmdatela,
                                              INPUT aux_nrctrcrd,
                                              INPUT aux_nrcrcard,
                                              INPUT aux_dtvalida,
                                              INPUT aux_flag2via,
                                             OUTPUT aux_flpurcrd,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-msg-confirma).
 
    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
       END.
    ELSE 
       DO:
           RUN piXmlNew.
           RUN piXmlExport(INPUT TEMP-TABLE tt-msg-confirma:HANDLE,INPUT "Dados").
           RUN piXmlAtributo (INPUT "flpurcrd",INPUT STRING(aux_flpurcrd)).
           RUN piXmlSave.
       END.                    

END PROCEDURE.

/******************************************************
    Efetuar a entrega de um determinado cartao
 *****************************************************/
PROCEDURE entrega_cartao:

    RUN entrega_cartao IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nrdconta,
                               INPUT aux_dtmvtolt,
                               INPUT aux_idorigem,
                               INPUT aux_idseqttl,
                               INPUT aux_nmdatela,
                               INPUT aux_nrctrcrd,
                               INPUT aux_nrcrcard,
                               INPUT aux_dtvalida,
                               INPUT DECI(aux_nrcpfrep),
                               INPUT aux_inpessoa,
                              OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE entrega_cartao_bancoob:

    RUN entrega_cartao_bancoob IN hBO (INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,
                                       INPUT aux_nrdcaixa,
                                       INPUT aux_cdoperad,
                                       INPUT aux_nrdconta,
                                       INPUT aux_dtmvtolt,
                                       INPUT aux_idorigem,
                                       INPUT aux_idseqttl,
                                       INPUT aux_nmdatela,
                                       INPUT aux_nrctrcrd,
                                       INPUT aux_nrcrcard,
                                       INPUT aux_dtvalida,
                                      OUTPUT TABLE tt-erro).
 
    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
       END.
    ELSE 
       DO:
           RUN piXmlNew.
           RUN piXmlSave.
       END.

END PROCEDURE.

/******************************************************
    Desfazer a entrega de um determinado cartao
 *****************************************************/
PROCEDURE desfaz_entrega_cartao:

    RUN desfaz_entrega_cartao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_idorigem,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nmdatela,
                                      INPUT aux_nrctrcrd,
                                      INPUT aux_inconfir,
                                     OUTPUT TABLE tt-msg-confirma, 
                                     OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Dados").

END PROCEDURE.

/**********************
    OPCAO ALTERAR
***********************/    
/********************************************************
    Verificar permissao para acessar a opcao alterar
 *******************************************************/
PROCEDURE verifica_acesso_alterar:

    RUN verifica_acesso_alterar IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrctrcrd,
                                       OUTPUT aux_flgadmbb, 
                                       OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgadmbb",INPUT STRING(aux_flgadmbb)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/******************************************************
    Carregar dados sobre limite de debito do cartao
    para efetuar a troca de limite
 *****************************************************/
PROCEDURE carrega_dados_limdeb_cartao:

    RUN carrega_dados_limdeb_cartao IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nrctrcrd,
                                           OUTPUT TABLE tt-limite_deb_cartao, 
                                           OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
         RUN piXmlSaida (INPUT TEMP-TABLE tt-limite_deb_cartao:HANDLE,
                         INPUT "Dados").

END PROCEDURE.

/******************************************************
    Efetuar a alteracao do limite de debito do cartao
 *****************************************************/
PROCEDURE altera_limdeb_cartao:

    RUN altera_limdeb_cartao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_idorigem,
                                     INPUT aux_idseqttl,
                                     INPUT aux_nmdatela,
                                     INPUT aux_nrctrcrd,
                                     INPUT aux_vllimdeb,
                                    OUTPUT TABLE tt-msg-confirma,
                                    OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").     
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Mensagem").
                        
END PROCEDURE.

/******************************************************
    Carregar dados do limite sobre limite de credito
    do cartao para efetuar uma troca do limite
 *****************************************************/
PROCEDURE carrega_dados_limcred_cartao:
    
    RUN carrega_dados_limcred_cartao IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nrdconta,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_idorigem,
                                             INPUT aux_idseqttl,
                                             INPUT aux_nmdatela,
                                             INPUT aux_nrctrcrd,
                                            OUTPUT TABLE tt-limite_crd_cartao, 
                                            OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-limite_crd_cartao:HANDLE,
                        INPUT "Dados").
         
END PROCEDURE.

/******************************************************
    Validar valor do novo limite de credito informado
    para o cartao de credito
 *****************************************************/
PROCEDURE valida_dados_limcred_cartao:

    RUN valida_dados_limcred_cartao IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                            INPUT aux_idseqttl,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nrctrcrd,
                                            INPUT aux_vllimcrd,
                                            INPUT aux_repsolic,
                                           OUTPUT TABLE tt-dados-avais, 
                                           OUTPUT TABLE tt-msg-confirma,
                                           OUTPUT TABLE tt-erro).
                                            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").     
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avalistas").
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagem").                             
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/******************************************************
    Efetuar a alteracao do limite de credito do cartao
 *****************************************************/
PROCEDURE altera_limcred_cartao:

    RUN altera_limcred_cartao IN hBO (INPUT aux_cdcooper,    
                                      INPUT aux_cdagenci,    
                                      INPUT aux_nrdcaixa,     
                                      INPUT aux_cdoperad,      
                                      INPUT aux_nrdconta,       
                                      INPUT aux_dtmvtolt,        
                                      INPUT aux_idorigem,         
                                      INPUT aux_idseqttl,          
                                      INPUT aux_nmdatela,           
                                      INPUT aux_nrctrcrd,            
                                      INPUT aux_vllimcrd,    
                                      INPUT aux_flgimpnp,   
                                      INPUT DECI(aux_nrcpfrep),
                                      /** 1o avalista **/                  
                                      INPUT aux_nrctaav1,                   
                                      INPUT aux_nmdaval1,                    
                                      INPUT aux_nrcpfav1,                     
                                      INPUT aux_tpdocav1,                      
                                      INPUT aux_dsdocav1,                       
                                      INPUT aux_nmdcjav1,  
                                      INPUT aux_cpfcjav1,   
                                      INPUT aux_tdccjav1,    
                                      INPUT aux_doccjav1,     
                                      INPUT aux_ende1av1,      
                                      INPUT aux_ende2av1,       
                                      INPUT aux_nrfonav1,        
                                      INPUT aux_emailav1,         
                                      INPUT aux_nmcidav1,          
                                      INPUT aux_cdufava1,           
                                      INPUT aux_nrcepav1, 
                                      INPUT aux_nrender1,
                                      INPUT aux_complen1,
                                      INPUT aux_nrcxaps1,
                                      /** 2o avalista **/             
                                      INPUT aux_nrctaav2,              
                                      INPUT aux_nmdaval2,               
                                      INPUT aux_nrcpfav2,                
                                      INPUT aux_tpdocav2,                 
                                      INPUT aux_dsdocav2,                  
                                      INPUT aux_nmdcjav2,                   
                                      INPUT aux_cpfcjav2,                    
                                      INPUT aux_tdccjav2,                     
                                      INPUT aux_doccjav2,  
                                      INPUT aux_ende1av2,   
                                      INPUT aux_ende2av2,    
                                      INPUT aux_nrfonav2,     
                                      INPUT aux_emailav2,      
                                      INPUT aux_nmcidav2,       
                                      INPUT aux_cdufava2,        
                                      INPUT aux_nrcepav2,     
                                      INPUT aux_nrender2,
                                      INPUT aux_complen2,
                                      INPUT aux_nrcxaps2,
                                     OUTPUT TABLE tt-erro).        
                
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/***************************************************************
        Carregar dados para alteração da data de vencimento
****************************************************************/
PROCEDURE carrega_dados_dtvencimento_cartao:
    
    RUN carrega_dados_dtvencimento_cartao 
                                  IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nrdconta,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_idorigem,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nmdatela,
                                          INPUT aux_nrctrcrd,
                                          INPUT aux_cdadmcrd,
                                         OUTPUT TABLE tt-erro, 
                                         OUTPUT TABLE tt-dtvencimento_cartao).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
         RUN piXmlSaida (INPUT TEMP-TABLE tt-dtvencimento_cartao:HANDLE,
                         INPUT "Dados").

END PROCEDURE.

/***************************************************************
        Carregar dados para alteração da data de vencimento - 2a via
****************************************************************/
PROCEDURE carrega_dados_dtvencimento_cartao_2via:
    
    RUN carrega_dados_dtvencimento_cartao_2via 
                                  IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_cdagenci,
                                          INPUT aux_nrdcaixa,
                                          INPUT aux_cdoperad,
                                          INPUT aux_nrdconta,
                                          INPUT aux_dtmvtolt,
                                          INPUT aux_idorigem,
                                          INPUT aux_idseqttl,
                                          INPUT aux_nmdatela,
                                          INPUT aux_nrctrcrd,
                                          INPUT aux_cdadmcrd,
                                         OUTPUT TABLE tt-erro, 
                                         OUTPUT TABLE tt-dtvencimento_cartao).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
         RUN piXmlSaida (INPUT TEMP-TABLE tt-dtvencimento_cartao:HANDLE,
                         INPUT "Dados").

END PROCEDURE.


/*************************************************************
        Efetuar a alteração da data de vencimento do cartão
*************************************************************/
PROCEDURE altera_dtvencimento_cartao:
    
    RUN altera_dtvencimento_cartao IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_nrdconta,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_idorigem,
                                           INPUT aux_idseqttl,
                                           INPUT aux_nmdatela,
                                           INPUT aux_nrctrcrd,
                                           INPUT aux_dddebito,
                                           INPUT DECI(aux_nrcpfrep),
                                           INPUT aux_repsolic,
                                          OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/*******************
    OPCAO 2VIA
*******************/
/***********************************************************************
      Verificar acesso para opcao de solicitacao da segunda via 
***********************************************************************/
PROCEDURE verifica_acesso_2via:

    RUN verifica_acesso_2via IN hBO (INPUT aux_cdcooper, 
                                     INPUT aux_cdagenci, 
                                     INPUT aux_nrdcaixa, 
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctrcrd, 
                                     INPUT aux_dtmvtolt,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/**********************************************************************
        Carregar os motivos da solicitação da segunda via
***********************************************************************/
PROCEDURE carrega_dados_solicitacao2via_cartao:

    RUN carrega_dados_solicitacao2via_cartao IN hBO 
                                             (INPUT aux_cdcooper, 
                                              INPUT aux_cdagenci, 
                                              INPUT aux_nrdcaixa, 
                                              INPUT aux_cdoperad, 
                                              INPUT aux_nrdconta, 
                                              INPUT aux_nrctrcrd, 
                                              INPUT aux_dtmvtolt, 
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-motivos_2via).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-motivos_2via:HANDLE,
                        INPUT "Motivos").
                        
END PROCEDURE.

/**********************************************************************
    Desfazer a solicitacao de segunda via de um determinado cartao
***********************************************************************/
PROCEDURE desfaz_solici2via_cartao:

    RUN desfaz_solici2via_cartao IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctrcrd,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_idorigem,
                                         INPUT aux_idseqttl,
                                         INPUT aux_nmdatela,
                                        OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
                        
END PROCEDURE.

/*******************************************************************************
    Desfazer a solicitacao de segunda via de senha de um determinado cartao
*******************************************************************************/
PROCEDURE desfaz_solici2via_senha:

    RUN desfaz_solici2via_senha IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl, 
                                        INPUT aux_idorigem,
                                        INPUT aux_nmdatela,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_nrctrcrd,
                                       OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
                        
END PROCEDURE.

/************************************************************************
        Efetuar a solicitacao da segunda via de um determinado cartao
************************************************************************/
PROCEDURE efetua_solicitacao2via_cartao:

    RUN efetua_solicitacao2via_cartao IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,              
                                              INPUT aux_nrdcaixa,  
                                              INPUT aux_cdoperad,  
                                              INPUT aux_nrdconta,
                                              INPUT aux_nrctrcrd,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_idorigem, 
                                              INPUT aux_idseqttl,
                                              INPUT aux_nmdatela,
                                              INPUT aux_cdadmcrd,
                                              INPUT aux_cdmotivo,
                                              INPUT aux_nmtitcrd,
                                              INPUT DECI(aux_nrcpfrep),
                                              INPUT aux_repsolic,
                                             OUTPUT TABLE tt-erro).   
                                     
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.                                 

END PROCEDURE.

/*******************************************************************************
        Efetuar a solicitacao da segunda via de senha de um determinado cartao
*******************************************************************************/
PROCEDURE efetua_solicitacao2via_senha:

    RUN efetua_solicitacao2via_senha IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,              
                                             INPUT aux_nrdcaixa,  
                                             INPUT aux_cdoperad,  
                                             INPUT aux_nrdconta,
                                             INPUT aux_idseqttl,
                                             INPUT aux_idorigem, 
                                             INPUT aux_nmdatela,
                                             INPUT aux_dtmvtolt,   
                                             INPUT aux_nrctrcrd,
                                             INPUT DECI(aux_nrcpfrep),
                                             INPUT aux_repsolic,
                                            OUTPUT TABLE tt-erro).   
                                     
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/**********************************************************************
        Valida se pode entregar e carrega os dados p/
        entregar a segunda via do cartao
***********************************************************************/
PROCEDURE valida_carregamento_entrega2via_cartao:
    
    RUN valida_carregamento_entrega2via_cartao IN hBO
                                              (INPUT aux_cdcooper, 
                                               INPUT aux_cdagenci, 
                                               INPUT aux_nrdcaixa, 
                                               INPUT aux_cdoperad, 
                                               INPUT aux_nrdconta,
                                               INPUT aux_nrctrcrd,
                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
    
END PROCEDURE.

/**********************************************************************
        Valida dados para efetuar a entrega da segunda via do cartao
***********************************************************************/
PROCEDURE valida_dados_entrega2via_cartao:
    
    RUN valida_dados_entrega2via_cartao IN hBO
                                       (INPUT aux_cdcooper, 
                                        INPUT aux_cdagenci, 
                                        INPUT aux_nrdcaixa, 
                                        INPUT aux_cdoperad, 
                                        INPUT aux_nrdconta,
                                        INPUT aux_dtmvtolt, 
                                        INPUT aux_idorigem,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nmdatela,
                                        INPUT aux_nrctrcrd,
                                        INPUT aux_nrcrcard,
                                        INPUT aux_dtvalida,
                                        INPUT aux_flgimpnp,
                                        INPUT aux_repsolic,
                                       OUTPUT TABLE tt-dados-avais, 
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
         RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                         INPUT "Dados").
    
END PROCEDURE.

/*******************************************************************
    Efetuar a entrega da segunda via de um determinado cartao
*******************************************************************/
PROCEDURE efetua_entrega2via_cartao:

    RUN efetua_entrega2via_cartao IN hBO (INPUT aux_cdcooper,    
                                          INPUT aux_cdagenci,    
                                          INPUT aux_nrdcaixa,     
                                          INPUT aux_cdoperad,      
                                          INPUT aux_nrdconta,       
                                          INPUT aux_dtmvtolt,        
                                          INPUT aux_idorigem,         
                                          INPUT aux_idseqttl,          
                                          INPUT aux_nmdatela,
                                          INPUT aux_cdadmcrd,
                                          INPUT aux_nrctrcrd,
                                          INPUT aux_nrcrcard,
                                          INPUT aux_dtvalida,
                                          INPUT aux_flgimpnp,
                                          /** 1o avalista **/                  
                                          INPUT aux_nrctaav1,                   
                                          INPUT aux_nmdaval1,  
                                          INPUT aux_nrcpfav1,   
                                          INPUT aux_tpdocav1,    
                                          INPUT aux_dsdocav1,    
                                          INPUT aux_nmdcjav1,  
                                          INPUT aux_cpfcjav1,   
                                          INPUT aux_tdccjav1,    
                                          INPUT aux_doccjav1,     
                                          INPUT aux_ende1av1,      
                                          INPUT aux_ende2av1,       
                                          INPUT aux_nrfonav1,        
                                          INPUT aux_emailav1,         
                                          INPUT aux_nmcidav1,          
                                          INPUT aux_cdufava1,           
                                          INPUT aux_nrcepav1,
                                          INPUT aux_nrender1,
                                          INPUT aux_complen1,
                                          INPUT aux_nrcxaps1,
                                          /** 2o avalista **/             
                                          INPUT aux_nrctaav2,              
                                          INPUT aux_nmdaval2,               
                                          INPUT aux_nrcpfav2,                
                                          INPUT aux_tpdocav2,                 
                                          INPUT aux_dsdocav2,                  
                                          INPUT aux_nmdcjav2,                   
                                          INPUT aux_cpfcjav2,    
                                          INPUT aux_tdccjav2,
                                          INPUT aux_doccjav2,  
                                          INPUT aux_ende1av2,   
                                          INPUT aux_ende2av2,    
                                          INPUT aux_nrfonav2,     
                                          INPUT aux_emailav2,      
                                          INPUT aux_nmcidav2,       
                                          INPUT aux_cdufava2,        
                                          INPUT aux_nrcepav2,
                                          INPUT aux_nrender2,
                                          INPUT aux_complen2,
                                          INPUT aux_nrcxaps2,
                                          INPUT DECI(aux_nrcpfrep),
                                         OUTPUT aux_nrctr2vi,     
                                         OUTPUT TABLE tt-erro).        

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nrctr2vi", INPUT STRING(aux_nrctr2vi)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/***********************
    OPCAO RENOVAR
***********************/    
/********************************************************
    Carregar dados sobre renovacao do cartao de credito
 *******************************************************/
PROCEDURE carrega_dados_renovacao:

    RUN carrega_dados_renovacao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrctrcrd,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_idorigem,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nmdatela,
                                       OUTPUT TABLE tt-dados_renovacao_cartao,
                                       OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
         RUN piXmlSaida (INPUT TEMP-TABLE tt-dados_renovacao_cartao:HANDLE,
                         INPUT "Dados").

END PROCEDURE.

/********************************************************
    Valida renovacao do cartao e carrega os avalistas
 *******************************************************/
PROCEDURE valida_renovacao_cartao:

    RUN valida_renovacao_cartao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_idorigem,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nmdatela,                                        
                                        INPUT aux_dtvalida,
                                        INPUT aux_nrctrcrd,
                                       OUTPUT TABLE tt-dados-avais,
                                       OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
         RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                         INPUT "Dados").

END PROCEDURE.

/*****************************************************
    Valida avalista e efetua a renovacao do cartao
*****************************************************/
PROCEDURE renova_cartao:

    RUN renova_cartao IN hBO (INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nrdconta,
                              INPUT aux_dtmvtolt,
                              INPUT aux_idorigem,
                              INPUT aux_idseqttl,
                              INPUT aux_nmdatela,
                              INPUT aux_nrctrcrd,
                              INPUT aux_dtvalida,
                              INPUT aux_flgimpnp,
                              /** 1o avalista **/                  
                              INPUT aux_nrctaav1,                   
                              INPUT aux_nmdaval1,                    
                              INPUT aux_nrcpfav1,                     
                              INPUT aux_tpdocav1,                      
                              INPUT aux_dsdocav1,                       
                              INPUT aux_nmdcjav1,  
                              INPUT aux_cpfcjav1,   
                              INPUT aux_tdccjav1,    
                              INPUT aux_doccjav1,     
                              INPUT aux_ende1av1,      
                              INPUT aux_ende2av1,       
                              INPUT aux_nrfonav1,        
                              INPUT aux_emailav1,         
                              INPUT aux_nmcidav1,          
                              INPUT aux_cdufava1,           
                              INPUT aux_nrcepav1,
                              INPUT aux_nrender1,
                              INPUT aux_complen1,
                              INPUT aux_nrcxaps1,
                              /** 2o avalista **/             
                              INPUT aux_nrctaav2,              
                              INPUT aux_nmdaval2,               
                              INPUT aux_nrcpfav2,                
                              INPUT aux_tpdocav2,                 
                              INPUT aux_dsdocav2,                  
                              INPUT aux_nmdcjav2,                   
                              INPUT aux_cpfcjav2,                    
                              INPUT aux_tdccjav2,                     
                              INPUT aux_doccjav2,  
                              INPUT aux_ende1av2,   
                              INPUT aux_ende2av2,    
                              INPUT aux_nrfonav2,     
                              INPUT aux_emailav2,      
                              INPUT aux_nmcidav2,       
                              INPUT aux_cdufava2,        
                              INPUT aux_nrcepav2, 
                              INPUT aux_nrender2,
                              INPUT aux_complen2,
                              INPUT aux_nrcxaps2,
                             OUTPUT TABLE tt-erro).

IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
        
END.
/************************************
    OPCAO CANCELAMENTO/BLOQUEIO
*************************************/
/********************************************************************
    Verificar permissao para acessar a opcao cancelamento/bloqueio
 ********************************************************************/
PROCEDURE verifica_acesso_cancblq:

    RUN verifica_acesso_cancblq IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrctrcrd,
                                       OUTPUT aux_flgadmbb, 
                                       OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgadmbb",INPUT STRING(aux_flgadmbb)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/***************************************************************
        Verificar se o cartao pode ou nao ser cancelado/bloquado
****************************************************************/
PROCEDURE verifica_canc_cartao:

    RUN verifica_canc_cartao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctrcrd,
                                    OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************
    Efetuar o bloqueio do cartao -> Cartoes do BB
                        OU
    Efetuar o cancelamento do cartao -> Demais cartoes
 *****************************************************/
PROCEDURE cancela_bloqueia_cartao:

    RUN cancela_bloqueia_cartao IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrctrcrd,
                                        INPUT aux_indposic,
                                        INPUT aux_dtmvtolt,
                                        INPUT aux_idorigem,
                                        INPUT aux_idseqttl,
                                        INPUT aux_nmdatela,
                                        INPUT aux_repsolic,
                                        INPUT DECI(aux_nrcpfrep),
                                       OUTPUT aux_msgalert,
                                       OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlSave.
        END.
                        
END PROCEDURE.

/******************************************************
    Desbloquear cartao BB ou 
    Desfazer cancelamento caso nao seja um cartao BB
 *****************************************************/
PROCEDURE desfaz_cancblq_cartao:

    RUN desfaz_cancblq_cartao IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nrdconta,
                                      INPUT aux_nrctrcrd,
                                      INPUT aux_indposic,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_idorigem,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nmdatela,
                                      INPUT 0,
                                     OUTPUT aux_msgalert,
                                     OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlSave.
        END.
                        
END PROCEDURE.


/************************************
    OPCAO ENCERRAMENTO
*************************************/
/*********************************************************************
    Verificar permissao para acessar a opcao encerramento
 *********************************************************************/
PROCEDURE verifica_acesso_enc:

    RUN verifica_acesso_enc IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nrctrcrd,
                                   OUTPUT aux_flgadmbb, 
                                   OUTPUT TABLE tt-erro).
 
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgadmbb",INPUT STRING(aux_flgadmbb)).
            RUN piXmlSave.
        END.    

END PROCEDURE.

/***************************************************************
        Verificar se o cartao pode ou nao ser encerrado
****************************************************************/
PROCEDURE verifica_enc_cartao:
    
    RUN verifica_enc_cartao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_cdagenci,
                                     INPUT aux_nrdcaixa,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nrdconta,
                                     INPUT aux_nrctrcrd,
                                    OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.    
                    
END PROCEDURE.

/******************************************************
    Efetuar o encerramento do cartao -> Cartoes do BB
 *****************************************************/
PROCEDURE encerra_cartao:

    RUN encerra_cartao IN hBO (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nrdconta,
                               INPUT aux_nrctrcrd,
                               INPUT aux_indposic,
                               INPUT aux_dtmvtolt,
                               INPUT aux_idorigem,
                               INPUT aux_idseqttl,
                               INPUT aux_nmdatela,
                               INPUT aux_repsolic,
                               INPUT DECI(aux_nrcpfrep),
                              OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.

/******************************************************
    Desfazer encerramento cartao BB
 *****************************************************/
PROCEDURE desfaz_enc_cartao:

    RUN desfaz_enc_cartao IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nrdconta,
                                  INPUT aux_nrctrcrd,
                                  INPUT aux_indposic,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_idorigem,
                                  INPUT aux_idseqttl,
                                  INPUT aux_nmdatela,
                                  INPUT 0,
                                 OUTPUT aux_msgalert,
                                 OUTPUT TABLE tt-erro).
                                           
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo(INPUT "msgalert", INPUT aux_msgalert).
            RUN piXmlSave.
        END.

END PROCEDURE.



/********************
    OPCAO EXCLUIR
********************/
/******************************************************
    Excluir um determinado cartao de credito
 *****************************************************/
PROCEDURE exclui_cartao:

    RUN exclui_cartao IN hBO (INPUT aux_cdcooper,    
                              INPUT aux_cdagenci,    
                              INPUT aux_nrdcaixa,     
                              INPUT aux_cdoperad,      
                              INPUT aux_nrdconta,
                              INPUT aux_nrctrcrd,
                              INPUT aux_dtmvtolt,        
                              INPUT aux_idorigem,         
                              INPUT aux_idseqttl,          
                              INPUT aux_nmdatela,           
                             OUTPUT TABLE tt-erro).        

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.
        
END PROCEDURE.

/************************************
    PROCEDURES REF. AOS AVALISTAS
*************************************/
/******************************************************************************/
/**        Procedure para carregar dados do avalista                         **/
/******************************************************************************/
PROCEDURE carrega_avalista:

    RUN carrega_avalista IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_cdagenci,
                                 INPUT aux_nrdcaixa,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_idorigem,
                                 INPUT aux_nrdconta,
                                 INPUT aux_idseqttl,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrctaava,
                                 INPUT aux_nrcpfcgc,
                                 INPUT TRUE, /** LOG **/
                                OUTPUT TABLE tt-dados-avais,
                                OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                        INPUT "Avalista").
       
END PROCEDURE.

PROCEDURE carrega_dados_habilitacao:
    
    RUN carrega_dados_habilitacao IN hBO (INPUT aux_cdcooper,
                                          INPUT aux_nrdconta,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-hab_cartao).
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-hab_cartao:HANDLE,
                        INPUT "Habilita").

END PROCEDURE.

PROCEDURE busca_dados_assoc:

    RUN busca_dados_assoc IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_nrcpfrep,
                                  INPUT aux_nmabrevi,
                                 OUTPUT aux_nmprimtl,
                                 OUTPUT aux_dtnasctl,
                                 OUTPUT aux_bfexiste).
                                          
    RUN piXmlNew.     
    RUN piXmlAtributo (INPUT "nmprimtl", 
                       INPUT aux_nmprimtl). 
    RUN piXmlAtributo (INPUT "dtnasctl", 
                       INPUT STRING(aux_dtnasctl,"99/99/9999")). 
    RUN piXmlAtributo (INPUT "bfexiste", 
                       INPUT STRING(aux_bfexiste)). 
    RUN piXmlSave.

END PROCEDURE.

PROCEDURE valida_habilitacao:

    RUN valida_habilitacao IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_nrdconta,
                                   INPUT aux_vllimglb,
                                   INPUT aux_flgativo,
                                   INPUT aux_nrcpfpri,
                                   INPUT aux_nrcpfseg,
                                   INPUT aux_nrcpfter,
                                   INPUT aux_nmpespri,
                                   INPUT aux_nmpesseg,
                                   INPUT aux_nmpester,
                                   INPUT aux_dtnaspri,
                                   INPUT aux_dtnasseg,
                                   INPUT aux_dtnaster,
                                  OUTPUT TABLE tt-msg-confirma,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                        INPUT "Confirmacao").

END PROCEDURE.

PROCEDURE grava_dados_habilitacao:

    EMPTY TEMP-TABLE tt-hab_cartao.
    CREATE tt-hab_cartao.
    ASSIGN tt-hab_cartao.vllimglb = aux_vllimglb
           tt-hab_cartao.flgativo = aux_flgativo
           tt-hab_cartao.nrcpfpri = aux_nrcpfpri
           tt-hab_cartao.nrcpfseg = aux_nrcpfseg
           tt-hab_cartao.nrcpfter = aux_nrcpfter
           tt-hab_cartao.nmpespri = aux_nmpespri
           tt-hab_cartao.dtnaspri = aux_dtnaspri
           tt-hab_cartao.nmpesseg = aux_nmpesseg
           tt-hab_cartao.dtnasseg = aux_dtnasseg
           tt-hab_cartao.nmpester = aux_nmpester
           tt-hab_cartao.dtnaster = aux_dtnaster.

    RUN grava_dados_habilitacao IN hBO
                               (INPUT aux_cdcooper,
                                INPUT aux_nrdconta,
                                INPUT aux_cdoperad,
                                INPUT aux_dtmvtolt,
                                INPUT aux_idorigem,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                /*** Dados do primeiro avalista ***/
                                INPUT aux_nrctaav1,
                                INPUT aux_nmdaval1,
                                INPUT aux_nrcpfav1,
                                INPUT aux_tpdocav1,
                                INPUT aux_dsdocav1,
                                INPUT aux_nmdcjav1,
                                INPUT aux_cpfcjav1,
                                INPUT aux_tdccjav1,
                                INPUT aux_doccjav1,
                                INPUT aux_ende1av1,
                                INPUT aux_ende2av1,
                                INPUT aux_nrfonav1,
                                INPUT aux_emailav1,
                                INPUT aux_nmcidav1,
                                INPUT aux_cdufava1,
                                INPUT aux_nrcepav1,
                                INPUT aux_nrender1,
                                INPUT aux_complen1,
                                INPUT aux_nrcxaps1,
                                /*** Dados do segundo avalista ***/
                                INPUT aux_nrctaav2,
                                INPUT aux_nmdaval2,
                                INPUT aux_nrcpfav2,
                                INPUT aux_tpdocav2,
                                INPUT aux_dsdocav2,
                                INPUT aux_nmdcjav2,
                                INPUT aux_cpfcjav2,
                                INPUT aux_tdccjav2,
                                INPUT aux_doccjav2,
                                INPUT aux_ende1av2,
                                INPUT aux_ende2av2,
                                INPUT aux_nrfonav2,
                                INPUT aux_emailav2,
                                INPUT aux_nmcidav2,
                                INPUT aux_cdufava2,
                                INPUT aux_nrcepav2,
                                INPUT aux_nrender2,
                                INPUT aux_complen2,
                                INPUT aux_nrcxaps2,
                               OUTPUT aux_nrctrcrd,
                                INPUT TABLE tt-hab_cartao,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nrctrcrd", INPUT STRING(aux_nrctrcrd)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.

PROCEDURE gera_impressao_contrato_cartao:

    RUN gera_impressao_contrato_cartao IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_idorigem,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_nrdconta,
                                               INPUT aux_dtmvtolt,
                                               INPUT aux_dtmvtopr,
                                               INPUT aux_inproces,
                                               INPUT aux_nrctrcrd,
                                               INPUT aux_nmendter,
                                               INPUT aux_flgimp2v,
                                              OUTPUT aux_nmarqimp,
                                              OUTPUT aux_nmarqpdf,
                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE gera_impressao_proposta_cartao:

    RUN gera_impressao_proposta_cartao IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_idorigem,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nmdatela,
                                               INPUT aux_nrdconta,
                                               INPUT aux_dtmvtolt,
                                               INPUT aux_dtmvtopr,
                                               INPUT aux_inproces,
                                               INPUT aux_nrctrcrd,
                                               INPUT aux_nmendter,
                                              OUTPUT aux_nmarqimp,
                                              OUTPUT aux_nmarqpdf,
                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE gera_impressao_emissao_cartao:

    RUN gera_impressao_emissao_cartao IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_idorigem,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nmdatela,
                                              INPUT aux_nrdconta,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_dtmvtopr,
                                              INPUT aux_inproces,
                                              INPUT aux_nrctrcrd,
                                              INPUT aux_nmendter,
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

PROCEDURE gera_impressao_entrega_carta:

    RUN gera_impressao_entrega_carta IN hBO (INPUT aux_cdcooper, 
                                             INPUT aux_idorigem,
                                             INPUT aux_cdoperad, 
                                             INPUT aux_nmdatela, 
                                             INPUT aux_nrdconta, 
                                             INPUT aux_dtmvtolt, 
                                             INPUT aux_dtmvtopr, 
                                             INPUT aux_inproces,  
                                             INPUT aux_nrctrcrd, 
                                             INPUT aux_nmendter, 
                                            OUTPUT aux_nmarqimp, 
                                            OUTPUT aux_nmarqpdf,
                                            OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.
          
PROCEDURE gera_impressao_entrega_cartao_bancoob:

    RUN gera_impressao_entrega_cartao_bancoob IN hBO (INPUT aux_cdcooper, 
                                                      INPUT aux_cdagenci,
                                                      INPUT aux_nrdcaixa,
                                                      INPUT aux_idorigem,
                                                      INPUT aux_nmdatela,
                                                      INPUT aux_dtmvtolt,
                                                      INPUT aux_nrdconta,
                                                      INPUT aux_nrctrcrd,
                                                      INPUT aux_nmendter, 
                                                     OUTPUT aux_nmarqimp, 
                                                     OUTPUT aux_nmarqpdf,
                                                     OUTPUT TABLE tt-erro).

    IF RETURN-VALUE = "NOK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF  NOT AVAILABLE tt-erro  THEN
               DO:
                   CREATE tt-erro.
                   ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                             "operacao.".
               END.

           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").
       END.
    ELSE 
       DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
           RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
           RUN piXmlSave.
       END.

END PROCEDURE.

PROCEDURE segunda_via_senha_cartao:

    RUN segunda_via_senha_cartao IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_idorigem, 
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_nrdconta,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrctrcrd,
                                         INPUT aux_nmendter,
                                        OUTPUT aux_nmarqimp,
                                        OUTPUT aux_nmarqpdf,
                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE segunda_via_cartao:

    RUN segunda_via_cartao IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_idorigem,
                                   INPUT aux_cdoperad,
                                   INPUT aux_nmdatela,
                                   INPUT aux_nrdconta,
                                   INPUT aux_dtmvtolt,
                                   INPUT aux_nrctrcrd,
                                   INPUT aux_nmendter,
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf,
                                  OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE termo_cancela_cartao:

    RUN termo_cancela_cartao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_idorigem,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_nrdconta,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrctrcrd,
                                     INPUT aux_nmendter,
                                    OUTPUT aux_nmarqimp,
                                    OUTPUT aux_nmarqpdf,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE imprimi_limite_pf:

    RUN imprimi_limite_pf IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_idorigem,
                                  INPUT aux_cdoperad, 
                                  INPUT aux_nmdatela,
                                  INPUT aux_nrdconta,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_inproces,
                                  INPUT aux_nrctrcrd,
                                  INPUT aux_nmendter,
                                 OUTPUT aux_nmarqimp,
                                 OUTPUT aux_nmarqpdf,
                                 OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE altera_limite_pj:

    RUN altera_limite_pj IN hBO (INPUT aux_cdcooper,
                                 INPUT aux_idorigem,
                                 INPUT aux_cdoperad,
                                 INPUT aux_nmdatela,
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrctrcrd,
                                 INPUT aux_nrdconta,
                                 INPUT aux_nmendter,
                                OUTPUT aux_nmarqimp,
                                OUTPUT aux_nmarqpdf,
                                OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE imprime_Alt_data_PF:

    RUN imprime_Alt_data_PF IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_idorigem,
                                    INPUT aux_cdoperad, 
                                    INPUT aux_nmdatela,
                                    INPUT aux_nrdconta,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_dtmvtopr,
                                    INPUT aux_inproces,
                                    INPUT aux_nrctrcrd,
                                    INPUT aux_nmendter,
                                   OUTPUT aux_nmarqimp,
                                   OUTPUT aux_nmarqpdf,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE imprime_Alt_data_PJ:

    RUN imprime_Alt_data_PJ IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_idorigem,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_nrctrcrd,
                                    INPUT aux_nrdconta,
                                    INPUT aux_nmendter,
                                   OUTPUT aux_nmarqimp,
                                   OUTPUT aux_nmarqpdf,
                                   OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE carrega_representante:

    RUN carrega_representante IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,  
                                     OUTPUT aux_represen,
                                     OUTPUT aux_cpfrepre).

    RUN piXmlNew.
    RUN piXmlAtributo (INPUT "represen", INPUT aux_represen).
    RUN piXmlAtributo (INPUT "cpfrepre", INPUT aux_cpfrepre[1] + "," +
                                               aux_cpfrepre[2] + "," +
                                               aux_cpfrepre[3]).
    RUN piXmlSave.

END PROCEDURE.

/*............................................................................*/

PROCEDURE termo_encerra_cartao:

    RUN termo_encerra_cartao IN hBO (INPUT aux_cdcooper,
                                     INPUT aux_idorigem,
                                     INPUT aux_cdoperad,
                                     INPUT aux_nmdatela,
                                     INPUT aux_nrdconta,
                                     INPUT aux_dtmvtolt,
                                     INPUT aux_nrctrcrd,
                                     INPUT aux_nmendter,
                                    OUTPUT aux_nmarqimp,
                                    OUTPUT aux_nmarqpdf,
                                    OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE extrato_cartao_bradesco:


    RUN extrato_cartao_bradesco IN hBO( INPUT aux_cdcooper,
                                        INPUT aux_nrdconta,
                                        INPUT aux_nrcrcard,
                                        INPUT aux_dtvctini, /* Variavel dia 01 mes */
                                        INPUT aux_dtvctfim, /* Variavel ult. dia mes  */
                                       OUTPUT TABLE tt-extrato-cartao,
                                       OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        RUN piXmlSaida (INPUT TEMP-TABLE tt-extrato-cartao:HANDLE,
                        INPUT "Extrato").

END PROCEDURE.

/*............................................................................*/

PROCEDURE extrato_bradesco_impressao:

    RUN extrato_bradesco_impressao IN hBO (INPUT aux_idorigem,
                                           INPUT aux_cdcooper,
                                           INPUT aux_nrdconta,
                                           INPUT aux_nrcrcard,
                                           INPUT aux_dtvctini,
                                           INPUT aux_dtvctfim,
                                           INPUT aux_nmendter,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp", INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf", INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE busca-cartao:

    RUN busca-cartao IN hBO( INPUT aux_cdcooper,
                             INPUT aux_tipopesq,
                             INPUT aux_dscartao,
                             INPUT aux_nrregist,
                             INPUT aux_nriniseq,
                             INPUT aux_flgpagin,
                             INPUT aux_cddepart,
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-cartao,
                             OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.

            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
      DO:
         RUN piXmlNew.
         RUN piXmlExport (INPUT TEMP-TABLE tt-cartao:HANDLE,
                          INPUT "Cartao").
         RUN piXmlAtributo (INPUT "qtregist", INPUT STRING(aux_qtregist)).
         RUN piXmlSave.

      END.

END PROCEDURE.

/******************************************************
    Gera impressao do contrato de cartoes BB
 *****************************************************/
PROCEDURE gera_impressao_contrato_bb:

    RUN gera_impressao_contrato_bb IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_nmdatela,
                                           INPUT aux_idorigem,
                                           INPUT aux_nrdconta,
                                           INPUT aux_idseqttl,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_dtmvtopr,
                                           INPUT aux_inproces,
                                           INPUT aux_nrctrcrd,
                                           INPUT aux_flgimpnp,
                                           INPUT aux_nmendter,
                                           INPUT aux_flgimp2v,
                                           INPUT aux_flgerlog,
                                           INPUT aux_cdmotivo,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO: 
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT STRING(aux_nmarqimp)).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT STRING(aux_nmarqpdf)).
            RUN piXmlSave.
        END.
        
END PROCEDURE.


/********************************************************
    Validar se primeiro titular possui cartao de credito
    para possibilitar inclusao de demais titulares
********************************************************/
PROCEDURE valida_dados_cartao:
    
    RUN valida_dados_cartao IN hBO (INPUT aux_cdcooper,
                                    INPUT aux_cdagenci,
                                    INPUT aux_nrdcaixa,
                                    INPUT aux_cdoperad,
                                    INPUT aux_nrdconta,
                                    INPUT aux_dtmvtolt,
                                    INPUT aux_idorigem,
                                    INPUT aux_nmdatela,
                                    INPUT aux_cdadmcrd,
                                    INPUT aux_nmtitcrd,
                                    INPUT aux_nrcpfcgc,
                                    INPUT aux_inpessoa,
                                   OUTPUT TABLE tt-dados-cartao, 
                                   OUTPUT TABLE tt-erro).
                                            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").     
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-cartao:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

PROCEDURE carrega_dados_administradoras:
    
    RUN carrega_dados_administradoras IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nrdconta,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_idorigem,
                                              INPUT aux_nmdatela,
                                              INPUT aux_nrcrcard,
                                             OUTPUT TABLE tt-dados-admin, 
                                             OUTPUT TABLE tt-erro).
                                            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").     
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-admin:HANDLE,
                             INPUT "Dados").
            RUN piXmlSave.
        END.
        
END PROCEDURE.

PROCEDURE altera_administradora:
    
    RUN altera_administradora IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nrdconta,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_idorigem,
                                      INPUT aux_nmdatela,
                                      INPUT aux_nrcrcard,
                                      INPUT aux_codaadmi,
                                      INPUT aux_codnadmi,
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT aux_nrctrcrd).
                                            
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").     
        END.
    ELSE
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "nrctrcrd",INPUT STRING(aux_nrctrcrd)).
            RUN piXmlSave.
        END.

        
END PROCEDURE.

PROCEDURE verifica_acesso_tela_taa:

    RUN verifica_acesso_tela_taa IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_idorigem,
                                         INPUT aux_nmdatela,
                                         INPUT aux_nrcrcard, 
                                         INPUT aux_nrctrcrd,
                                         OUTPUT aux_inacetaa,
                                         OUTPUT TABLE tt-erro).
                                            
    IF RETURN-VALUE = "NOK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.      
           IF NOT AVAILABLE tt-erro THEN
              DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "operacao.".
              END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").     
       END.
    ELSE 
       DO:
           RUN piXmlNew.        
           RUN piXmlAtributo (INPUT "inacetaa",INPUT STRING(aux_inacetaa)).
           RUN piXmlSave.
       END.
        
END PROCEDURE.

PROCEDURE valida_dados_liberacao_taa:

  RUN valida_dados_liberacao_taa IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_idorigem,
                                         INPUT aux_nmdatela,
                                         INPUT aux_nrcrcard,
                                         INPUT aux_nrctrcrd,
                                         OUTPUT TABLE tt-erro).
                                            
   IF RETURN-VALUE = "NOK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
              
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                          INPUT "Erro").     
      END.
   ELSE 
      DO:
          RUN piXmlNew.
          RUN piXmlSave.
      END.

END PROCEDURE.

PROCEDURE liberar_cartao_credito_taa:

    RUN liberar_cartao_credito_taa IN hBO (INPUT aux_cdcooper,
                                           INPUT aux_cdagenci,
                                           INPUT aux_nrdcaixa,
                                           INPUT aux_cdoperad,
                                           INPUT aux_nrdconta,
                                           INPUT aux_dtmvtolt,
                                           INPUT aux_idorigem,
                                           INPUT aux_nmdatela,                                           
                                           INPUT aux_nrcrcard,
                                           INPUT aux_dssentaa,
                                           INPUT aux_dssencfm,
                                           OUTPUT aux_flgcadas,
                                           OUTPUT TABLE tt-erro).
                                           
    IF RETURN-VALUE = "NOK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.      
           IF NOT AVAILABLE tt-erro THEN
              DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "operacao.".
              END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").     
       END.
    ELSE 
       DO:
           RUN piXmlNew.
           RUN piXmlAtributo (INPUT "flgcadas",INPUT STRING(aux_flgcadas)).
           RUN piXmlSave.
       END.
        
END PROCEDURE.

PROCEDURE valida_dados_bloqueio_taa:

   RUN valida_dados_bloqueio_taa IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nrdconta,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_idorigem,
                                         INPUT aux_nmdatela,
                                         INPUT aux_nrcrcard,
                                         INPUT aux_nrctrcrd,
                                         OUTPUT TABLE tt-erro).
                                            
   IF RETURN-VALUE = "NOK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
              
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                          INPUT "Erro").     
      END.
   ELSE 
      DO:
          RUN piXmlNew.
          RUN piXmlSave.
      END.
       
END PROCEDURE.   

PROCEDURE bloquear_cartao_credito_taa:

    RUN bloquear_cartao_credito_taa IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nrctrcrd,                                
                                            INPUT aux_nrcrcard,
                                            OUTPUT TABLE tt-erro).
                                            
    IF RETURN-VALUE = "NOK" THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.      
           IF NOT AVAILABLE tt-erro THEN
              DO:
                  CREATE tt-erro.
                  ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                            "operacao.".
              END.
               
           RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                           INPUT "Erro").     
       END.
    ELSE 
       DO:
           RUN piXmlNew.
           RUN piXmlSave.
       END.
        
END PROCEDURE.

PROCEDURE valida_dados_senha_numerica_taa:

   RUN valida_dados_senha_numerica_taa IN hBO (INPUT aux_cdcooper,
                                               INPUT aux_cdagenci,
                                               INPUT aux_nrdcaixa,
                                               INPUT aux_cdoperad,
                                               INPUT aux_nrdconta,
                                               INPUT aux_dtmvtolt,
                                               INPUT aux_idorigem,
                                               INPUT aux_nmdatela,
                                               INPUT aux_nrcrcard,
                                               INPUT aux_nrctrcrd,
                                               OUTPUT TABLE tt-erro).
                                            
   IF RETURN-VALUE = "NOK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
              
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                          INPUT "Erro").     
      END.
   ELSE 
      DO:
          RUN piXmlNew.
          RUN piXmlSave.
      END.
       
END PROCEDURE.

PROCEDURE grava_dados_senha_numerica_taa:

   RUN grava_dados_senha_numerica_taa IN hBO (INPUT aux_cdcooper,
                                              INPUT aux_cdagenci,
                                              INPUT aux_nrdcaixa,
                                              INPUT aux_cdoperad,
                                              INPUT aux_nrdconta,
                                              INPUT aux_dtmvtolt,
                                              INPUT aux_idorigem,
                                              INPUT aux_nmdatela,                                              
                                              INPUT aux_nrcrcard,
                                              INPUT aux_dssentaa,
                                              INPUT aux_dssencfm,
                                              INPUT TRUE, /* par_flgerlog */
                                              OUTPUT TABLE tt-erro).
                                              
   IF RETURN-VALUE = "NOK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
              
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                          INPUT "Erro").     
      END.
   ELSE 
      DO:
          RUN piXmlNew.
          RUN piXmlSave.
      END.
       
END PROCEDURE.

PROCEDURE valida_dados_senha_letras_taa:

   RUN valida_dados_senha_letras_taa IN hBO (INPUT aux_cdcooper,
                                             INPUT aux_cdagenci,
                                             INPUT aux_nrdcaixa,
                                             INPUT aux_cdoperad,
                                             INPUT aux_nrdconta,
                                             INPUT aux_dtmvtolt,
                                             INPUT aux_idorigem,
                                             INPUT aux_nmdatela,
                                             INPUT aux_nrcrcard,
                                             INPUT aux_nrctrcrd,
                                             OUTPUT TABLE tt-erro).
                                            
   IF RETURN-VALUE = "NOK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
              
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                          INPUT "Erro").     
      END.
   ELSE 
      DO:
          RUN piXmlNew.
          RUN piXmlSave.
      END.
       
END PROCEDURE.

PROCEDURE grava_dados_senha_letras_taa:

   RUN grava_dados_senha_letras_taa IN hBO (INPUT aux_cdcooper,
                                            INPUT aux_cdagenci,
                                            INPUT aux_nrdcaixa,
                                            INPUT aux_cdoperad,
                                            INPUT aux_nrdconta,
                                            INPUT aux_dtmvtolt,
                                            INPUT aux_idorigem,
                                            INPUT aux_nmdatela,
                                            INPUT aux_nrctrcrd,
                                            INPUT aux_nrcrcard,
                                            INPUT aux_dssennov,
                                            INPUT aux_dssencon,
                                            OUTPUT TABLE tt-erro).
                                              
   IF RETURN-VALUE = "NOK" THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.      
          IF NOT AVAILABLE tt-erro THEN
             DO:
                 CREATE tt-erro.
                 ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                           "operacao.".
             END.
              
          RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                          INPUT "Erro").     
      END.
   ELSE 
      DO:
          RUN piXmlNew.
          RUN piXmlSave.
      END.
       
END PROCEDURE.

PROCEDURE valida-senha-ta-online:

   RUN valida-senha-ta-online IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_nrdconta,
                                      INPUT aux_cddsenha,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_nrcrcard,
                                      OUTPUT aux_flgsenha,
                                      OUTPUT TABLE tt-erro).
                                      
    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
        IF NOT AVAILABLE tt-erro THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                      "operacao.".
        END.
        
        RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                        INPUT "Erro").     
    END.
    ELSE
    DO:
        RUN piXmlNew.
        RUN piXmlAtributo (INPUT "flgsenha",INPUT LOGICAL(aux_flgsenha)).
        RUN piXmlSave.
    END.
    
END PROCEDURE.
