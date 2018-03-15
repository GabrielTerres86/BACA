/*..............................................................................

   Programa: xb1wgen0002.p
   Autor   : Murilo/David
   Data    : Junho/2007                     Ultima atualizacao: 21/02/2018

   Dados referentes ao programa:

   Objetivo  : BO de Comunicacao XML VS BO de Saldo e Extrato de Emprestimos
               (b1wgen0002.p)

   Alteracoes: 07/05/2009 - Ajuste nos parametros da procedure obtem-dados-
                            emprestimos (David).
                            
               25/10/2010 - Projeto de melhorias de propostas, Fase II
                            (Gabriel)             
                            
               04/02/2011 - Incluir parametro par_flgcondc na procedure 
                             obtem-dados-emprestimos  (Gabriel - DB1).
                             
               10/03/2011 - Adicionado chamada para a procedure 
                            verifica-traz-avalista, consulta-avalista
                            (Gabriel - DB1).
                            
               24/03/2011 - Adicionado procedimento para chamada de
                            impressão. (André - DB1) 
                            
               14/04/2011 - Campos para CEP integrado. Incluidos campos 
                            nrendere, complend e nrcxapst no procedimento 
                            grava proposta completa para os dois avalistas. 
                            (André - DB1)  
                            
               05/05/2011 - Incluido procedimento valida-interv. (André - DB1)
               
               06/09/2011 - Incluido parametro aux_flgerlog na procedure 
                            obtem-dados-emprestimos. (Rogérius - DB1)
               
               16/09/2011 - Utilizar parametro aux_flgcondc na procedure
                            obtem-dados-emprestimos (David).
                            
               28/11/2011 - Incluido o parametro dsjusren na procedure 
                            grava proposta completa (Adriano).
               
               05/04/2012 - Incluido campo dtlibera (Gabriel).
               
               05/07/2012 - Alimentar valor de total de emprestimos
                            a liquidar antes de enviar como parametro
                            (Gabriel).   
                            
               29/10/2012 - Incluir parametros tt-ge-epr nas temp-tables
                            verifica-outras-propostas, valida-dados-gerais
                            (Lucas R.).
                                       
               25/02/2013 - Enviar o numero do contrato na validacao da 
                            liquidacao (Gabriel).      
                            
               28/06/2013 - Enviar como parametro a linha de credito na hora
                            da liquidacao (Gabriel).

               23/01/2014 - Adicionados parametros na procedure
                            'verifica-outras-propostas' para validação de
                            CPF/CNPJ do proprietário dos bens como
                            interveniente (Lucas).

               28/01/2014 - Novo parametro chassi para validacoes na procedure
                            valida-dados-alienacao
                          - Nova procedure retorna_uf_pa_ass

               24/02/2014 - Adicionado param. de paginacao em proc. 
                            obtem-dados-emprestimos em BO 0002.(Jorge)

               14/03/2014 - Novos parametros nrdconta, nrctremp, idseqbem e
                            regtbens para validacoes na procedure
                            valida-dados-alienacao (Guilherme/SUPERO)
                            
               06/06/2014 - Adiconado novos campos inpessoa e dtnascto para 
                            avalista 1 e 2, incluso parametros nas procedures
                            valida-avalistas e grava-proposta-completa 
                            (Daniel/Thiago).      
                            
               22/08/2014 - Projeto Automatização de Consultas em Propostas 
                            de Crédito (Jonata-RKAM). 
               
               26/08/2014 - Incluir procedure calcula-cet  
                            (Lucas R./Gielow - Projeto CET)

               18/11/2014 - Inclusao do parametro nrcpfope. (Jaison)
               
               20/01/2015 - Adicionado parametro dstipbem. 
                            (Jorge/Gielow) - SD 241854

              07/05/2015 - Inclusao da exclusao no log na procedure 
                           excluir-proposta. (Jaison/Gielow - SD: 283541)

              11/05/2015 - Inclusao da alteracao do numero do contrato na 
                           altera-numero-proposta. (Jaison/Gielow - SD: 282303)
                           
              18/05/2015 - Incluir procedure "carrega_dados_proposta_finalidade"
                           (James)             
                           
              27/05/2015 - Alterado para apresentar mensagem ao realizar inclusao 
                           de nova proposta de emprestimo para menores nao 
                           emancipados. (Reinert)
                          
              29/05/2015 - Padronizacao das consultas automatizadas
                           (Gabriel-RKAM).              
                           
              26/06/2015 - Ajuste nos parametros da procedure 
                           "carrega_dados_proposta_finalidade". (James)
                           
              30/09/2015 - Inclusao da procedure "recalcular_emprestimo". (James)  
              
              09/11/2015 - Merge das rotinas do projeto de Portabilidade (Carlos Rafael)
              
              12/11/2015 - Criacao da rotina de calculo de iof para emprestimos
                           Projeto 134 - Portabilidade de credito
                           (Carlos Rafael Tanholi)
                           
              16/11/2015 - Retirado parametro 'aux_nrctremp' da procedure 'gera-impressao-empr'.
                           (Lombardi - Projeto Portabilidade)                           
                                         
              21/01/2016 - Inclusao de parametros na procedure valida-dados-hipoteca e
                           valida-dados-alienacao. (James)             

              01/03/2016 - PRJ Esteira de Credito. (Jaison/Oscar)

              04/04/2017 - Adicionado parametros de carencia do produto Pos-Fixado. (Jaison/James - PRJ298)

			  25/04/2017 - Tratamentos para o projeto 337 - Motor de crédito. (Reinert)

              21/09/2017 - Projeto 410 - Incluir campo Indicador de 
                            financiamento do IOF (Diogo - Mouts)

			  21/02/2018 - Novo parametro na chamada da proc_qualif_operacao
                           (Diego/AMcom)

			  21/02/2018 - Alterado a rotina obtem-dados-liquidacoes para ao final da listagem 
						   trazer limite/adp para liquidar.(Diego/AMcom)

..............................................................................*/

DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                           NO-UNDO.
DEF VAR aux_cdpactra AS INTE                                           NO-UNDO.
DEF VAR aux_cdageass AS INTE                                           NO-UNDO.
DEF VAR aux_nrdcaixa AS INTE                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nomcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_nrctaava AS INTE                                           NO-UNDO.
DEF VAR aux_idseqttl AS INTE                                           NO-UNDO.
DEF VAR aux_nrctremp AS INTE                                           NO-UNDO.
DEF VAR aux_idorigem AS INTE                                           NO-UNDO.
DEF VAR aux_cdlcremp AS INTE                                           NO-UNDO.
DEF VAR aux_qtpreemp AS INTE                                           NO-UNDO.
DEF VAR aux_inconfir AS INTE                                           NO-UNDO.
DEF VAR aux_tpaltera AS INTE                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_ddmesnov AS INTE                                           NO-UNDO.
DEF VAR aux_cdfinemp AS INTE                                           NO-UNDO.
DEF VAR aux_qtdialib AS INTE                                           NO-UNDO.
DEF VAR aux_tplcremp AS INTE                                           NO-UNDO.
DEF VAR aux_qtpromis AS INTE                                           NO-UNDO.
DEF VAR aux_idavalis AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaav1 AS INTE                                           NO-UNDO.
DEF VAR aux_idcatbem AS INTE                                           NO-UNDO.
DEF VAR aux_tpchassi AS INTE                                           NO-UNDO.
DEF VAR aux_dschassi AS CHAR                                           NO-UNDO.
DEF VAR aux_nranobem AS INTE                                           NO-UNDO.
DEF VAR aux_nrmodbem AS INTE                                           NO-UNDO.
DEF VAR aux_inpessoa AS INTE                                           NO-UNDO.
DEF VAR aux_recidepr AS INTE                                           NO-UNDO.
DEF VAR aux_idimpres AS INTE                                           NO-UNDO.
DEF VAR aux_nrpagina AS INTE                                           NO-UNDO.
DEF VAR aux_promsini AS INTE                                           NO-UNDO.
DEF VAR aux_idquapro AS INTE                                           NO-UNDO.
DEF VAR aux_nrctaav2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrgarope AS INTE                                           NO-UNDO.
DEF VAR aux_nrperger AS INTE                                           NO-UNDO.
DEF VAR aux_nrinfcad AS INTE                                           NO-UNDO.
DEF VAR aux_qtopescr AS INTE                                           NO-UNDO.
DEF VAR aux_qtifoper AS INTE                                           NO-UNDO.
DEF VAR aux_nrliquid AS INTE                                           NO-UNDO.
DEF VAR aux_nrpatlvr AS INTE                                           NO-UNDO.
DEF VAR aux_nrctacje AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepav1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepav2 AS INTE                                           NO-UNDO.
DEF VAR aux_qtlinsel AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrant AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrobs AS INTE                                           NO-UNDO.
DEF VAR aux_nrctrem2 AS INTE                                           NO-UNDO.
DEF VAR aux_inusatab AS INTE                                           NO-UNDO.
DEF VAR aux_nralihip AS INTE                                           NO-UNDO.
DEF VAR aux_inmatric AS INTE                                           NO-UNDO.
DEF VAR aux_nriniseq AS INTE                                           NO-UNDO.
DEF VAR aux_nrregist AS INTE                                           NO-UNDO.
DEF VAR aux_qtregist AS INTE                                           NO-UNDO.
DEF VAR aux_inconcje AS LOGI                                           NO-UNDO.

DEF VAR aux_cdoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_cdprogra AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdatela AS CHAR                                           NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                           NO-UNDO.
DEF VAR aux_dsctrliq AS CHAR                                           NO-UNDO.
DEF VAR aux_dsmesage AS CHAR                                           NO-UNDO.
DEF VAR aux_dslcremp AS CHAR                                           NO-UNDO.
DEF VAR aux_dsfinemp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdavali AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendre1 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufresd AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_dscatbem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsbemfin AS CHAR                                           NO-UNDO.
DEF VAR aux_ufdplaca AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdplaca AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_dsiduser AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdidade AS CHAR                                           NO-UNDO.
DEF VAR aux_flgpagto AS CHAR                                           NO-UNDO.
DEF VAR aux_dsnivris AS CHAR                                           NO-UNDO.
DEF VAR aux_nmempcje AS CHAR                                           NO-UNDO.
DEF VAR aux_dsobserv AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdfinan AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdrendi AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdebens AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdalien AS CHAR                                           NO-UNDO.
DEF VAR aux_dsinterv AS CHAR                                           NO-UNDO.
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
DEF VAR aux_cdnacio1 AS INTE                                           NO-UNDO.
/* Campos para CEP integrado */
DEF VAR aux_nrender1 AS INTE                                           NO-UNDO.
DEF VAR aux_complen1 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps1 AS INTE                                           NO-UNDO.
DEF VAR aux_nrender2 AS INTE                                           NO-UNDO.
DEF VAR aux_complen2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcxaps2 AS INTE                                           NO-UNDO.
DEF VAR aux_nrcepend AS INTE                                           NO-UNDO.
DEF VAR aux_nmdaval2 AS CHAR                                           NO-UNDO.
DEF VAR par_dsdbeavt AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnacio2 AS INTE                                           NO-UNDO.
DEF VAR aux_tdccjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_doccjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende1av2 AS CHAR                                           NO-UNDO.
DEF VAR aux_ende2av2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_emailav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_cdufava2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdocav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdocav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nmdcjav2 AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdretor AS CHAR                                           NO-UNDO.
DEF VAR aux_msgretor AS CHAR                                           NO-UNDO.
DEF VAR aux_dsquapro AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_dstipbem AS CHAR                                           NO-UNDO.

DEF VAR aux_dtcalcul AS DATE                                           NO-UNDO.
DEF VAR aux_dtiniper AS DATE                                           NO-UNDO.
DEF VAR aux_dtfimper AS DATE                                           NO-UNDO.
DEF VAR aux_dtdpagto AS DATE                                           NO-UNDO.
DEF VAR aux_dtdpagt2 AS DATE                                           NO-UNDO.
DEF VAR aux_dtcnsspc AS DATE                                           NO-UNDO.
DEF VAR aux_dtoutspc AS DATE                                           NO-UNDO.
DEF VAR aux_dtoutris AS DATE                                           NO-UNDO.
DEF VAR aux_dtdrisco AS DATE                                           NO-UNDO.
DEF VAR aux_dtmvtoep AS DATE                                           NO-UNDO.
DEF VAR aux_dtdpagt3 AS DATE                                           NO-UNDO.

DEF VAR aux_nrcpfcgc AS DECI                                           NO-UNDO.
DEF VAR aux_vlsdeved AS DECI                                           NO-UNDO.
DEF VAR aux_vltotpre AS DECI                                           NO-UNDO.
DEF VAR aux_vlmaxutl AS DECI                                           NO-UNDO.
DEF VAR aux_vlmaxleg AS DECI                                           NO-UNDO.
DEF VAR aux_vlcnsscr AS DECI                                           NO-UNDO.
DEF VAR aux_vlemprst AS DECI                                           NO-UNDO.
DEF VAR aux_vlpreant AS DECI                                           NO-UNDO.
DEF VAR aux_vlpreemp AS DECI                                           NO-UNDO.
DEF VAR aux_vlutiliz AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfav1 AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcjg AS DECI                                           NO-UNDO.
DEF VAR aux_vlmerbem AS DECI                                           NO-UNDO.
DEF VAR aux_nrrenava AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfbem AS DECI                                           NO-UNDO.
DEF VAR aux_vltotemp AS DECI                                           NO-UNDO.
DEF VAR aux_vleprori AS DECI                                           NO-UNDO.
DEF VAR aux_vlminimo AS DECI                                           NO-UNDO.
DEF VAR aux_vllimapv AS DECI                                           NO-UNDO.
DEF VAR aux_percetop AS DECI                                           NO-UNDO.
DEF VAR aux_vltotsfn AS DECI                                           NO-UNDO.
DEF VAR aux_vlopescr AS DECI                                           NO-UNDO.
DEF VAR aux_vlrpreju AS DECI                                           NO-UNDO.
DEF VAR aux_vlsfnout AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalari AS DECI                                           NO-UNDO.
DEF VAR aux_vloutras AS DECI                                           NO-UNDO.
DEF VAR aux_vlsalcon AS DECI                                           NO-UNDO.
DEF VAR aux_vlalugue AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfcje AS DECI                                           NO-UNDO.
DEF VAR aux_perfatcl AS DECI                                           NO-UNDO.
DEF VAR aux_vlmedfat AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav1 AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenme1 AS DECI                                           NO-UNDO.
DEF VAR aux_vledvmt1 AS DECI                                           NO-UNDO.
DEF VAR aux_nrcpfav2 AS DECI                                           NO-UNDO.
DEF VAR aux_vledvmt2 AS DECI                                           NO-UNDO.
DEF VAR aux_vlrenme2 AS DECI                                           NO-UNDO.
DEF VAR aux_cpfcjav2 AS DECI                                           NO-UNDO.
DEF VAR aux_tosdeved AS DECI                                           NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.
DEF VAR aux_flgemail AS LOGI                                           NO-UNDO.
DEF VAR aux_flgentra AS LOGI                                           NO-UNDO.
DEF VAR aux_flgentrv AS LOGI                                           NO-UNDO.
DEF VAR aux_flgcmtlc AS LOGI                                           NO-UNDO.
DEF VAR aux_flgimppr AS LOGI                                           NO-UNDO.
DEF VAR aux_flgimpnp AS LOGI                                           NO-UNDO.
DEF VAR aux_flgdocje AS LOGI                                           NO-UNDO.
DEF VAR aux_flgcondc AS LOGI INIT FALSE                                NO-UNDO.
DEF VAR aux_flgpagt2 AS LOGI                                           NO-UNDO.
DEF VAR aux_flgerlog AS LOGI INIT TRUE                                 NO-UNDO.

DEF VAR aux_tpdocava AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdocava AS CHAR                                           NO-UNDO.
DEF VAR aux_cdnacion AS INTE                                           NO-UNDO.
DEF VAR aux_nmconjug AS CHAR                                           NO-UNDO.
DEF VAR aux_tpdoccjg AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdoccjg AS CHAR                                           NO-UNDO.
DEF VAR aux_dsendre2 AS CHAR                                           NO-UNDO.
DEF VAR aux_nrfonres AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdemail AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_dsjusren AS CHAR                                           NO-UNDO.

DEF VAR aux_qtprecal LIKE crapepr.qtprecal                             NO-UNDO.
DEF VAR aux_tpemprst AS INTE                                           NO-UNDO.
DEF VAR aux_idenempr AS INTE										   NO-UNDO.	
DEF VAR aux_dtlibera AS DATE                                           NO-UNDO.

DEF VAR aux_nrdgrupo AS INT                                            NO-UNDO.
DEF VAR aux_gergrupo AS LOG                                            NO-UNDO.
DEF VAR aux_tpdecons AS LOG                                            NO-UNDO.
DEF VAR aux_dsdrisco AS CHAR                                           NO-UNDO.
DEF VAR aux_vlendivi AS DEC                                            NO-UNDO.
DEF VAR aux_inconfi2 AS INTE                                           NO-UNDO.
DEF VAR aux_rowidaux AS ROWID                                          NO-UNDO.

DEF VAR aux_uflicenc AS CHAR                                           NO-UNDO.
DEF VAR aux_dscorbem AS CHAR                                           NO-UNDO.
DEF VAR aux_idseqbem AS INTE                                           NO-UNDO.

DEF VAR aux_txcetano AS CHAR                                           NO-UNDO.
DEF VAR aux_txcetmes AS CHAR                                           NO-UNDO.

DEF VAR aux_dtnascto AS DATE                                           NO-UNDO.
DEF VAR aux_inpesso1 AS INTE                                           NO-UNDO.
DEF VAR aux_dtnasct1 AS DATE                                           NO-UNDO.
DEF VAR aux_inpesso2 AS INTE                                           NO-UNDO.
DEF VAR aux_dtnasct2 AS DATE                                           NO-UNDO.
DEF VAR aux_flgconsu AS LOGI                                           NO-UNDO.
DEF VAR aux_flmudfai AS CHAR                                           NO-UNDO.
DEF VAR aux_nrcpfope AS DECI                                           NO-UNDO. 
DEF VAR aux_nivrisco AS CHAR                                           NO-UNDO. 
DEF VAR aux_cdmodali AS CHAR                                           NO-UNDO.
DEF VAR aux_vllanmto AS DECI                                           NO-UNDO.
DEF VAR aux_txccdiof AS DECI                                           NO-UNDO.
DEF VAR aux_flgsenha AS INTE                                           NO-UNDO.
DEF VAR aux_dsmensag AS CHAR                                           NO-UNDO.

DEF VAR aux_inobriga AS CHAR                                           NO-UNDO.
DEF VAR aux_idfiniof AS INTE                                           NO-UNDO.
DEF VAR aux_vliofepr LIKE crapepr.vliofepr                             NO-UNDO.
DEF VAR aux_vlrtarif AS DECI                                           NO-UNDO.
DEF VAR aux_vlrtotal AS DECI                                           NO-UNDO.

DEF VAR aux_idcarenc AS INTE                                           NO-UNDO.
DEF VAR aux_dtcarenc AS DATE                                           NO-UNDO.

/** ------------------------- Variaveis Lojista CDC ---------------------- **/
DEF VAR aux_cdcoploj AS INTE                                           NO-UNDO.
DEF VAR aux_nrcntloj AS DECI                                           NO-UNDO.

{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen0059tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/supermetodos.i }

DEF TEMP-TABLE tt-aval-crapbem                                         NO-UNDO
    LIKE tt-crapbem.

/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**      Procedure para atribuicao dos dados de entrada enviados por XML     **/
/******************************************************************************/
PROCEDURE valores_entrada:    

    FOR EACH tt-param:

        CASE tt-param.nomeCampo:

            WHEN "cdcooper" THEN aux_cdcooper = INTE(tt-param.valorCampo).
            WHEN "cdagenci" THEN aux_cdagenci = INTE(tt-param.valorCampo).
			WHEN "cdpactra" THEN aux_cdpactra = INTE(tt-param.valorCampo).			
            WHEN "nrdcaixa" THEN aux_nrdcaixa = INTE(tt-param.valorCampo).
            WHEN "cdoperad" THEN aux_cdoperad = tt-param.valorCampo.
            WHEN "nmdatela" THEN aux_nmdatela = tt-param.valorCampo.
            WHEN "nrdconta" THEN aux_nrdconta = INTE(tt-param.valorCampo).
            WHEN "nrctaava" THEN aux_nrctaava = INTE(tt-param.valorCampo).
            WHEN "nrcpfcgc" THEN aux_nrcpfcgc = DECI(tt-param.valorCampo).
            WHEN "idseqttl" THEN aux_idseqttl = INTE(tt-param.valorCampo).
            WHEN "nrctremp" THEN aux_nrctremp = INTE(tt-param.valorCampo).
            WHEN "cddopcao" THEN aux_cddopcao = tt-param.valorCampo.
            WHEN "dtcalcul" THEN aux_dtcalcul = DATE(tt-param.valorCampo).
            WHEN "dtiniper" THEN aux_dtiniper = DATE(tt-param.valorCampo).
            WHEN "dtfimper" THEN aux_dtfimper = DATE(tt-param.valorCampo).
            WHEN "cdprogra" THEN aux_cdprogra = tt-param.valorCampo.
            WHEN "idorigem" THEN aux_idorigem = INTE(tt-param.valorCampo).
            WHEN "cdageass" THEN aux_cdageass = INTE(tt-param.valorCampo).
            WHEN "cdlcremp" THEN aux_cdlcremp = INTE(tt-param.valorCampo).
            WHEN "qtpreemp" THEN aux_qtpreemp = INTE(tt-param.valorCampo).
            WHEN "dsctrliq" THEN aux_dsctrliq = tt-param.valorCampo.
            WHEN "vlmaxutl" THEN aux_vlmaxutl = DECI(tt-param.valorCampo).
            WHEN "vlmaxleg" THEN aux_vlmaxleg = DECI(tt-param.valorCampo).
            WHEN "vlcnsscr" THEN aux_vlcnsscr = DECI(tt-param.valorCampo).
            WHEN "vlemprst" THEN aux_vlemprst = DECI(tt-param.valorCampo).
            WHEN "dtdpagto" THEN aux_dtdpagto = DATE(tt-param.valorCampo).
            WHEN "inconfir" THEN aux_inconfir = INTE(tt-param.valorCampo).
            WHEN "inconfi2" THEN aux_inconfi2 = INTE(tt-param.valorCampo).
            WHEN "tpaltera" THEN aux_tpaltera = INTE(tt-param.valorCampo).
            WHEN "cdempres" THEN aux_cdempres = INTE(tt-param.valorCampo).
            WHEN "flgpagto" THEN aux_flgpagto = tt-param.valorCampo.
            WHEN "dtdpagt2" THEN aux_dtdpagt2 = DATE(tt-param.valorCampo).
            WHEN "ddmesnov" THEN aux_ddmesnov = INTE(tt-param.valorCampo).
            WHEN "cdfinemp" THEN aux_cdfinemp = INTE(tt-param.valorCampo).
            WHEN "qtdialib" THEN aux_qtdialib = INTE(tt-param.valorCampo).
            WHEN "qtpromis" THEN aux_qtpromis = INTE(tt-param.valorCampo).
            WHEN "nrcpfav1" THEN aux_nrcpfav1 = DECI(tt-param.valorCampo).
            WHEN "idavalis" THEN aux_idavalis = INTE(tt-param.valorCampo).
            WHEN "nmdavali" THEN aux_nmdavali = tt-param.valorCampo.
            WHEN "nrcpfcjg" THEN aux_nrcpfcjg = DECI(tt-param.valorCampo).
            WHEN "dsendre1" THEN aux_dsendre1 = tt-param.valorCampo.
            WHEN "cdufresd" THEN aux_cdufresd = tt-param.valorCampo.
            WHEN "nrctaav1" THEN aux_nrctaav1 = INTE(tt-param.valorCampo).
            WHEN "dscorbem" THEN aux_dscorbem = tt-param.valorCampo.
            WHEN "dscatbem" THEN aux_dscatbem = tt-param.valorCampo.
            WHEN "dsbemfin" THEN aux_dsbemfin = tt-param.valorCampo.
            WHEN "vlmerbem" THEN aux_vlmerbem = DECI(tt-param.valorCampo).
            WHEN "idcatbem" THEN aux_idcatbem = INTE(tt-param.valorCampo).
            WHEN "tpchassi" THEN aux_tpchassi = INTE(tt-param.valorCampo).
            WHEN "dschassi" THEN aux_dschassi = tt-param.valorCampo.
            WHEN "ufdplaca" THEN aux_ufdplaca = tt-param.valorCampo.
            WHEN "nrdplaca" THEN aux_nrdplaca = tt-param.valorCampo.
            WHEN "nrrenava" THEN aux_nrrenava = DECI(tt-param.valorCampo).
            WHEN "nranobem" THEN aux_nranobem = INTE(tt-param.valorCampo).
            WHEN "nrmodbem" THEN aux_nrmodbem = INTE(tt-param.valorCampo).
            WHEN "idseqbem" THEN aux_idseqbem = INTE(tt-param.valorCampo).
            WHEN "nrcpfbem" THEN aux_nrcpfbem = DECI(tt-param.valorCampo).
            WHEN "vltotemp" THEN aux_vltotemp = DECI(tt-param.valorCampo).
            WHEN "vleprori" THEN aux_vleprori = DECI(tt-param.valorCampo).
            WHEN "vlminimo" THEN aux_vlminimo = DECI(tt-param.valorCampo).
            WHEN "recidepr" THEN aux_recidepr = INTE(tt-param.valorCampo).
            WHEN "idimpres" THEN aux_idimpres = INTE(tt-param.valorCampo). 
            WHEN "flgescra" THEN aux_flgescra = LOGICAL(tt-param.valorCampo).  
            WHEN "nrpagina" THEN aux_nrpagina = INTE(tt-param.valorCampo).  
            WHEN "flgemail" THEN aux_flgemail = LOGICAL(tt-param.valorCampo).  
            WHEN "dsiduser" THEN aux_dsiduser = tt-param.valorCampo.            
            WHEN "inproces" THEN aux_inproces = INTE(tt-param.valorCampo).            
            WHEN "promsini" THEN aux_promsini = INTE(tt-param.valorCampo).
            WHEN "flgentra" THEN aux_flgentra = LOGICAL(tt-param.valorCampo).            
            WHEN "flgentrv" THEN aux_flgentrv = LOGICAL(tt-param.valorCampo).
            WHEN "inpessoa" THEN aux_inpessoa = INTE(tt-param.valorCampo).
            WHEN "idquapro" THEN aux_idquapro = INTE(tt-param.valorCampo).
            WHEN "nrctaav2" THEN aux_nrctaav2 = INTE(tt-param.valorCampo).
            WHEN "nrgarope" THEN aux_nrgarope = INTE(tt-param.valorCampo).
            WHEN "nrperger" THEN aux_nrperger = INTE(tt-param.valorCampo).
            WHEN "nrinfcad" THEN aux_nrinfcad = INTE(tt-param.valorCampo).
            WHEN "qtopescr" THEN aux_qtopescr = INTE(tt-param.valorCampo).
            WHEN "qtifoper" THEN aux_qtifoper = INTE(tt-param.valorCampo).
            WHEN "nrliquid" THEN aux_nrliquid = INTE(tt-param.valorCampo).
            WHEN "nrpatlvr" THEN aux_nrpatlvr = INTE(tt-param.valorCampo).
            WHEN "nrctacje" THEN aux_nrctacje = INTE(tt-param.valorCampo).
            WHEN "nrcepav1" THEN aux_nrcepav1 = INTE(tt-param.valorCampo).
            WHEN "nrcepav2" THEN aux_nrcepav2 = INTE(tt-param.valorCampo).
            WHEN "nrctrant" THEN aux_nrctrant = INTE(tt-param.valorCampo).
            WHEN "nrctrobs" THEN aux_nrctrobs = INTE(tt-param.valorCampo).
            WHEN "inmatric" THEN aux_inmatric = INTE(tt-param.valorCampo).
            WHEN "flgcmtlc" THEN aux_flgcmtlc = LOGICAL(tt-param.valorCampo).
            WHEN "flgimppr" THEN aux_flgimppr = LOGICAL(tt-param.valorCampo).
            WHEN "flgimpnp" THEN aux_flgimpnp = LOGICAL(tt-param.valorCampo).
            WHEN "flgdocje" THEN aux_flgdocje = LOGICAL(tt-param.valorCampo).
            WHEN "flgcondc" THEN aux_flgcondc = LOGICAL(tt-param.valorCampo).
            WHEN "vllimapv" THEN aux_vllimapv = DECI(tt-param.valorCampo).
            WHEN "vlpreant" THEN aux_vlpreant = DECI(tt-param.valorCampo).
            WHEN "percetop" THEN aux_percetop = DECI(tt-param.valorCampo).
            WHEN "vltotsfn" THEN aux_vltotsfn = DECI(tt-param.valorCampo).
            WHEN "vlopescr" THEN aux_vlopescr = DECI(tt-param.valorCampo).
            WHEN "vlrpreju" THEN aux_vlrpreju = DECI(tt-param.valorCampo).
            WHEN "vlsfnout" THEN aux_vlsfnout = DECI(tt-param.valorCampo).
            WHEN "vlsalari" THEN aux_vlsalari = DECI(tt-param.valorCampo).
            WHEN "vloutras" THEN aux_vloutras = DECI(tt-param.valorCampo).
            WHEN "vlalugue" THEN aux_vlalugue = DECI(tt-param.valorCampo).
            WHEN "vlsalcon" THEN aux_vlsalcon = DECI(tt-param.valorCampo).
            WHEN "nrcpfcje" THEN aux_nrcpfcje = DECI(tt-param.valorCampo).
            WHEN "vlmedfat" THEN aux_vlmedfat = DECI(tt-param.valorCampo).
            WHEN "vlrenme1" THEN aux_vlrenme1 = DECI(tt-param.valorCampo).
            WHEN "nrcpfav2" THEN aux_nrcpfav2 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav2" THEN aux_cpfcjav2 = DECI(tt-param.valorCampo).
            WHEN "vledvmt2" THEN aux_vledvmt2 = DECI(tt-param.valorCampo).
            WHEN "vlrenme2" THEN aux_vlrenme2 = DECI(tt-param.valorCampo).
            WHEN "cpfcjav1" THEN aux_cpfcjav1 = DECI(tt-param.valorCampo).
            WHEN "vlsdeved" THEN aux_vlsdeved = DECI(tt-param.valorCampo).
            WHEN "vlutiliz" THEN aux_vlutiliz = DECI(tt-param.valorCampo).
            WHEN "vlpreemp" THEN aux_vlpreemp = DECI(tt-param.valorCampo).
            WHEN "perfatcl" THEN aux_perfatcl = DECI(tt-param.valorCampo).
            WHEN "vledvmt1" THEN aux_vledvmt1 = DECI(tt-param.valorCampo).
            WHEN "dtcnsspc" THEN aux_dtcnsspc = DATE(tt-param.valorCampo).
            WHEN "dtdrisco" THEN aux_dtdrisco = DATE(tt-param.valorCampo).
            WHEN "dtoutspc" THEN aux_dtoutspc = DATE(tt-param.valorCampo).
            WHEN "dtoutris" THEN aux_dtoutris = DATE(tt-param.valorCampo).
            WHEN "dtmvtoep" THEN aux_dtmvtoep = DATE(tt-param.valorCampo).
            WHEN "dsnivris" THEN aux_dsnivris = tt-param.valorCampo.
            WHEN "nmempcje" THEN aux_nmempcje = tt-param.valorCampo.
            WHEN "dsobserv" THEN aux_dsobserv = tt-param.valorCampo.
            WHEN "dsdfinan" THEN aux_dsdfinan = tt-param.valorCampo.
            WHEN "dsdrendi" THEN aux_dsdrendi = tt-param.valorCampo.
            WHEN "dsdebens" THEN aux_dsdebens = tt-param.valorCampo.
            WHEN "dsdalien" THEN aux_dsdalien = tt-param.valorCampo.
            WHEN "dsinterv" THEN aux_dsinterv = tt-param.valorCampo.
            WHEN "nmdaval1" THEN aux_nmdaval1 = tt-param.valorCampo.
            WHEN "tpdocav1" THEN aux_tpdocav1 = tt-param.valorCampo.
            WHEN "dsdocav1" THEN aux_dsdocav1 = tt-param.valorCampo.
            WHEN "nmdcjav1" THEN aux_nmdcjav1 = tt-param.valorCampo.
            WHEN "tdccjav1" THEN aux_tdccjav1 = tt-param.valorCampo.
            WHEN "doccjav1" THEN aux_doccjav1 = tt-param.valorCampo.
            WHEN "dsquapro" THEN aux_dsquapro = tt-param.valorCampo.
            WHEN "dsdopcao" THEN aux_dsdopcao = tt-param.valorCampo.
            WHEN "nrctrem2" THEN aux_nrctrem2 = INTE(tt-param.valorCampo).
            WHEN "inusatab" THEN aux_inusatab = INTE(tt-param.valorCampo).
            WHEN "nralihip" THEN aux_nralihip = INTE(tt-param.valorCampo).
            WHEN "tplcremp" THEN aux_tplcremp = INTE(tt-param.valorCampo).
            WHEN "ende1av1" THEN aux_ende1av1 = tt-param.valorCampo.
            WHEN "ende2av1" THEN aux_ende2av1 = tt-param.valorCampo.
            WHEN "nrfonav1" THEN aux_nrfonav1 = tt-param.valorCampo.
            WHEN "emailav1" THEN aux_emailav1 = tt-param.valorCampo.
            WHEN "nmcidav1" THEN aux_nmcidav1 = tt-param.valorCampo.
            WHEN "ende2av2" THEN aux_ende2av2 = tt-param.valorCampo.
            WHEN "nrfonav2" THEN aux_nrfonav2 = tt-param.valorCampo.
            WHEN "emailav2" THEN aux_emailav2 = tt-param.valorCampo.
            WHEN "nmcidav2" THEN aux_nmcidav2 = tt-param.valorCampo.
            WHEN "cdufava2" THEN aux_cdufava2 = tt-param.valorCampo.
            WHEN "dsdbeavt" THEN par_dsdbeavt = tt-param.valorCampo.
            WHEN "cdnacio2" THEN aux_cdnacio2 = INTE(tt-param.valorCampo).
            WHEN "cdufava1" THEN aux_cdufava1 = tt-param.valorCampo.
            WHEN "cdnacio1" THEN aux_cdnacio1 = INTE(tt-param.valorCampo).
            WHEN "nmdaval2" THEN aux_nmdaval2 = tt-param.valorCampo.
            WHEN "tpdocav2" THEN aux_tpdocav2 = tt-param.valorCampo.
            WHEN "dsdocav2" THEN aux_dsdocav2 = tt-param.valorCampo.
            WHEN "nmdcjav2" THEN aux_nmdcjav2 = tt-param.valorCampo.
            WHEN "tdccjav2" THEN aux_tdccjav2 = tt-param.valorCampo.
            WHEN "doccjav2" THEN aux_doccjav2 = tt-param.valorCampo.
            WHEN "ende1av2" THEN aux_ende1av2 = tt-param.valorCampo.
            
            WHEN "nrender1" THEN aux_nrender1 = INTE(tt-param.valorCampo).
            WHEN "complen1" THEN aux_complen1 = tt-param.valorCampo.
            WHEN "nrcxaps1" THEN aux_nrcxaps1 = INTE(tt-param.valorCampo).
            WHEN "nrender2" THEN aux_nrender2 = INTE(tt-param.valorCampo).
            WHEN "complen2" THEN aux_complen2 = tt-param.valorCampo.
            WHEN "nrcxaps2" THEN aux_nrcxaps2 = INTE(tt-param.valorCampo).
            WHEN "nrcepend" THEN aux_nrcepend = INTE(tt-param.valorCampo).

            WHEN "tpdocava" THEN aux_tpdocava = tt-param.valorCampo.
            WHEN "nrdocava" THEN aux_nrdocava = tt-param.valorCampo.
            WHEN "cdnacion" THEN aux_cdnacion = INTE(tt-param.valorCampo).
            WHEN "nmconjug" THEN aux_nmconjug = tt-param.valorCampo.
            WHEN "tpdoccjg" THEN aux_tpdoccjg = tt-param.valorCampo.
            WHEN "nrdoccjg" THEN aux_nrdoccjg = tt-param.valorCampo.
            WHEN "dsendre2" THEN aux_dsendre2 = tt-param.valorCampo.
            WHEN "nrfonres" THEN aux_nrfonres = tt-param.valorCampo.
            WHEN "dsdemail" THEN aux_dsdemail = tt-param.valorCampo.
            WHEN "nmcidade" THEN aux_nmcidade = tt-param.valorCampo.
            WHEN "flgerlog" THEN aux_flgerlog = LOGICAL(tt-param.valorCampo).
            WHEN "tpemprst" THEN aux_tpemprst = INTE(tt-param.valorCampo).
			WHEN "idenempr" THEN aux_idenempr = INTE(tt-param.valorCampo).
            WHEN "dsjusren" THEN aux_dsjusren = tt-param.valorCampo.
            WHEN "dtlibera" THEN aux_dtlibera = DATE(tt-param.valorCampo).
            WHEN "dtmvtolt" THEN aux_dtmvtolt = DATE(tt-param.valorCampo).
            WHEN "tosdeved" THEN aux_tosdeved = DECI(tt-param.valorCampo).

            WHEN "nriniseq" THEN aux_nriniseq = INTE(tt-param.valorCampo).
            WHEN "nrregist" THEN aux_nrregist = INTE(tt-param.valorCampo).

            WHEN "dtnascto" THEN aux_dtnascto = DATE(tt-param.valorCampo).

            WHEN "inpesso1" THEN aux_inpesso1 = INTE(tt-param.valorCampo).
            WHEN "dtnasct1" THEN aux_dtnasct1 = DATE(tt-param.valorCampo).
            WHEN "inpesso2" THEN aux_inpesso2 = INTE(tt-param.valorCampo).
            WHEN "dtnasct2" THEN aux_dtnasct2 = DATE(tt-param.valorCampo).
            WHEN "inconcje" THEN aux_inconcje = LOGICAL(tt-param.valorCampo).
            WHEN "flgconsu" THEN aux_flgconsu = LOGICAL(tt-param.valorCampo).
            WHEN "nrcpfope" THEN aux_nrcpfope = DECI(tt-param.valorCampo).
            WHEN "uflicenc" THEN aux_uflicenc = tt-param.valorCampo.      
            WHEN "dstipbem" THEN aux_dstipbem = tt-param.valorCampo.
            WHEN "cdmodali" THEN aux_cdmodali = tt-param.valorCampo.

            WHEN "idfiniof" THEN aux_idfiniof = INTE(tt-param.valorCampo).
            WHEN "vliofepr" THEN aux_vliofepr = DECI(tt-param.valorCampo).
            WHEN "vlrtarif" THEN aux_vlrtarif = DECI(tt-param.valorCampo).
            WHEN "vlrtotal" THEN aux_vlrtotal = DECI(tt-param.valorCampo).

            WHEN "idcarenc" THEN aux_idcarenc = INTE(tt-param.valorCampo).
            WHEN "dtcarenc" THEN aux_dtcarenc = DATE(tt-param.valorCampo).

            WHEN "cdcoploj" THEN aux_cdcoploj = INTE(tt-param.valorCampo).
            WHEN "nrcntloj" THEN aux_nrcntloj = DECI(tt-param.valorCampo).

        END CASE.
    
    END. /** Fim do FOR EACH tt-param **/   

    FOR EACH tt-param-i 
         BREAK BY tt-param-i.nomeTabela
               BY tt-param-i.sqControle:

        CASE tt-param-i.nomeTabela:

            WHEN "Intervenientes" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:                        
                        CREATE tt-interv-anuentes.
                        ASSIGN aux_rowidaux = ROWID(tt-interv-anuentes).
                    END.

               FIND tt-interv-anuentes WHERE 
                     ROWID(tt-interv-anuentes) = aux_rowidaux NO-ERROR.

               CASE tt-param-i.nomeCampo:
                   WHEN "nrcpfcgc" THEN
                       tt-interv-anuentes.nrcpfcgc = DECI(tt-param-i.valorCampo).
               END CASE.

            END.

            WHEN "Alienacao" THEN DO:

                IF  FIRST-OF(tt-param-i.sqControle) THEN
                    DO:                        
                        CREATE tt-bens-alienacao.
                        ASSIGN aux_rowidaux = ROWID(tt-bens-alienacao).
                    END.

               FIND tt-bens-alienacao WHERE 
                     ROWID(tt-bens-alienacao) = aux_rowidaux NO-ERROR.

               CASE tt-param-i.nomeCampo:
                   WHEN "nrcpfbem" THEN
                       tt-bens-alienacao.nrcpfbem = DECI(tt-param-i.valorCampo).
               END CASE.

            END.
            
        END CASE.

    END. /* Fim FOR EACH tt-param-i */

END PROCEDURE.

PROCEDURE valida-analise-proposta:

    RUN valida-analise-proposta IN hBO (INPUT aux_cdcooper,
                                        INPUT aux_cdagenci,
                                        INPUT aux_nrdcaixa,
                                        INPUT aux_cdoperad,
                                        INPUT aux_nmdatela,
                                        INPUT aux_idorigem,
                                        INPUT aux_nrdconta,
                                        INPUT aux_idseqttl,
                                        INPUT aux_dtmvtolt,
                                        INPUT TRUE,
                                        INPUT aux_dtcnsspc,
                                        INPUT aux_nrinfcad,
                                        INPUT aux_dtoutspc,
                                        INPUT aux_dtdrisco,
                                        INPUT aux_dtoutris,
                                        INPUT aux_nrgarope,
                                        INPUT aux_nrliquid,
                                        INPUT aux_nrpatlvr,
                                        INPUT aux_nrperger,
                                       OUTPUT aux_nomcampo,
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

            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                             INPUT "Erro").
            RUN piXmlAtributo (INPUT "nomcampo", INPUT TRIM(aux_nomcampo)).
            RUN piXmlSave.
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**           Procedure para calcular saldo devedor de emprestimos           **/
/******************************************************************************/
PROCEDURE saldo-devedor-epr:

    RUN saldo-devedor-epr IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_nrctremp,
                                  INPUT aux_cdprogra,
                                  INPUT aux_inproces,
                                  INPUT TRUE,
                                 OUTPUT aux_vlsdeved,
                                 OUTPUT aux_vltotpre,
                                 OUTPUT aux_qtprecal,
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
            RUN piXmlAtributo (INPUT "vlsdeved",INPUT STRING(aux_vlsdeved)).
            RUN piXmlAtributo (INPUT "qtprecal",INPUT STRING(aux_qtprecal)).
            RUN piXmlAtributo (INPUT "vltotpre",INPUT STRING(aux_vltotpre)).
            RUN piXmlSave.
        END.

END PROCEDURE.


/******************************************************************************/
/**          Procedure para obter dados de emprestimos do associado          **/
/******************************************************************************/
PROCEDURE obtem-dados-emprestimos:
 
    RUN obtem-dados-emprestimos IN hBO (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_dtmvtopr,
                                  INPUT aux_dtcalcul,
                                  INPUT aux_nrctremp,
                                  INPUT aux_cdprogra,
                                  INPUT aux_inproces,
                                  INPUT aux_flgerlog,
                                  INPUT aux_flgcondc,
                                  INPUT aux_nriniseq,
                                  INPUT aux_nrregist,
                                 OUTPUT aux_qtregist,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados-epr).

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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-dados-epr:HANDLE,
                               INPUT "Dados").
            RUN piXmlAtributo (INPUT "qtregist",INPUT STRING(aux_qtregist)).
            RUN piXmlSave.
        END.
END PROCEDURE.


/******************************************************************************/
/**                Procedure para obter extrato de emprestimos               **/
/******************************************************************************/
PROCEDURE obtem-extrato-emprestimo:

    RUN obtem-extrato-emprestimo IN hBO (INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_nrdconta,
                                         INPUT aux_idseqttl,
                                         INPUT aux_nrctremp,
                                         INPUT aux_dtiniper,
                                         INPUT aux_dtfimper,
                                         INPUT TRUE,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-extrato_epr).

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
        RUN piXmlSaida (INPUT TEMP-TABLE tt-extrato_epr:HANDLE,
                        INPUT "Dados").

END PROCEDURE.


/****************************************************************************
   Procedure para obter todas as propostas de emprestimo do cooperado     
*****************************************************************************/

PROCEDURE obtem-propostas-emprestimo:

    RUN obtem-propostas-emprestimo IN hBO 
                               (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_dtmvtolt,
                                INPUT aux_nrctremp,
                                INPUT TRUE,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-proposta-epr,
                               OUTPUT TABLE tt-dados-gerais,
                               OUTPUT aux_dsdidade).

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
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
             RUN piXmlExport (INPUT TEMP-TABLE tt-proposta-epr:HANDLE,
                              INPUT "Proposta").
             RUN piXmlExport (INPUT TEMP-TABLE tt-dados-gerais:HANDLE,
                              INPUT "Dados_Gerais").
             RUN piXmlAtributo (INPUT "dsdidade",INPUT aux_dsdidade).
             RUN piXmlSave.
         END.
         
END PROCEDURE.


/******************************************************************************/
/**       Procedure para obter todos os dados da proposta de emprestimo      **/
/******************************************************************************/
PROCEDURE obtem-dados-proposta-emprestimo:

    RUN obtem-dados-proposta-emprestimo IN hBO 
                                 (INPUT aux_cdcooper,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_cdoperad,
                                  INPUT aux_nmdatela,
                                  INPUT aux_inproces,
                                  INPUT aux_idorigem,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_dtmvtolt,
                                  INPUT aux_nrctremp,
                                  INPUT aux_cddopcao,
                                  INPUT aux_inconfir,
                                  INPUT TRUE,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados-coope,
                                 OUTPUT TABLE tt-dados-assoc,
                                 OUTPUT TABLE tt-tipo-rendi,
                                 OUTPUT TABLE tt-itens-topico-rating,
                                 OUTPUT TABLE tt-proposta-epr,
                                 OUTPUT TABLE tt-crapbem,
                                 OUTPUT TABLE tt-bens-alienacao,
                                 OUTPUT TABLE tt-rendimento,
                                 OUTPUT TABLE tt-faturam,
                                 OUTPUT TABLE tt-dados-analise,
                                 OUTPUT TABLE tt-interv-anuentes,
                                 OUTPUT TABLE tt-hipoteca,
                                 OUTPUT TABLE tt-dados-avais,
                                 OUTPUT TABLE tt-aval-crapbem,
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
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-coope:HANDLE,
                             INPUT "Cooperativa").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-assoc:HANDLE,
                             INPUT "Associado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-tipo-rendi:HANDLE,
                             INPUT "Tipos_Rendimentos").
            RUN piXmlExport (INPUT TEMP-TABLE tt-itens-topico-rating:HANDLE,
                             INPUT "Itens_Rating").
            RUN piXmlExport (INPUT TEMP-TABLE tt-proposta-epr:HANDLE,
                             INPUT "Proposta").
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapbem:HANDLE,
                             INPUT "Bens_Assoiado").
            RUN piXmlExport (INPUT TEMP-TABLE tt-bens-alienacao:HANDLE,
                             INPUT "Alienacao").
            RUN piXmlExport (INPUT TEMP-TABLE tt-rendimento:HANDLE,
                             INPUT "Rendimento").
            RUN piXmlExport (INPUT TEMP-TABLE tt-faturam:HANDLE,
                             INPUT "Faturamentos").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-analise:HANDLE,
                             INPUT "Analise").
            RUN piXmlExport (INPUT TEMP-TABLE tt-interv-anuentes:HANDLE,
                             INPUT "Intervenientes_Anuentes").
            RUN piXmlExport (INPUT TEMP-TABLE tt-hipoteca:HANDLE,
                             INPUT "Hipoteca").
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avalistas").
            RUN piXmlExport (INPUT TEMP-TABLE tt-aval-crapbem:HANDLE,
                             INPUT "Bens_Aval").
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagens").
            RUN piXmlSave.
        END.

END PROCEDURE.

/**************************************************************************
 Trazer um determinado avalista (cooperado ou terceiro) e pesquisar
 os contratos onde ele já é aval.
**************************************************************************/
PROCEDURE verifica-traz-avalista:

    RUN verifica-traz-avalista IN hBO
                          (INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_cdoperad,
                           INPUT aux_nmdatela,
                           INPUT aux_idorigem,
                           INPUT aux_nrdconta,
                           INPUT aux_nrctaava,
                           INPUT aux_nrcpfcgc,
                           INPUT aux_idseqttl,
                           INPUT aux_dtmvtolt,
                           INPUT aux_dtmvtopr,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-dados-avais,
                           OUTPUT TABLE tt-crapbem,
                           OUTPUT TABLE tt-fiador,
                           OUTPUT aux_nmprimtl).

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
            RUN piXmlAtributo (INPUT "nmprimtl",INPUT aux_nmprimtl).
            RUN piXmlExport (INPUT TEMP-TABLE tt-fiador:HANDLE,
                             INPUT "Fiador").
            RUN piXmlExport (INPUT TEMP-TABLE tt-crapbem:HANDLE,
                             INPUT "Bens_Assoiado").
            RUN piXmlSave.
        END.

END.

/**************************************************************************
 Trazer um determinado avalista (cooperado ou terceiro) e pesquisar
 os contratos onde ele já é aval.
**************************************************************************/
PROCEDURE consulta-avalista:

    RUN consulta-avalista IN hBO
                        ( INPUT aux_cdcooper,
                          INPUT aux_cdagenci,
                          INPUT aux_nrdcaixa,
                          INPUT aux_idorigem,
                          INPUT aux_nrdconta,
                          INPUT aux_dtmvtolt,
                          INPUT aux_nrctaava,
                          INPUT aux_nrcpfcgc,
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
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-avais:HANDLE,
                             INPUT "Avalistas").
            RUN piXmlSave.
        END.

END.

/*****************************************************************************
 Fazer as validacoes quando for alteracao do tipo 'Toda a Proposta de 
 Emprestimo' e 'Somente o Valor da Proposta'.
******************************************************************************/
PROCEDURE valida-dados-gerais:
   
    RUN valida-dados-gerais IN hBO
                          ( INPUT aux_cdcooper,
                            INPUT aux_cdagenci,
                            INPUT aux_nrdcaixa,
                            INPUT aux_cdoperad,
                            INPUT aux_nmdatela,
                            INPUT aux_idorigem,
                            INPUT aux_nrdconta,
                            INPUT aux_idseqttl,
                            INPUT aux_dtmvtolt,
                            INPUT aux_dtmvtopr,
                            INPUT aux_cddopcao,
                            INPUT aux_inproces,
                            INPUT aux_cdageass,
                            INPUT aux_nrctremp,
                            INPUT aux_cdlcremp,
                            INPUT aux_qtpreemp,
                            INPUT aux_dsctrliq,
                            INPUT aux_vlmaxutl,
                            INPUT aux_vlmaxleg, 
                            INPUT aux_vlcnsscr,
                            INPUT aux_vlemprst,
                            INPUT aux_dtdpagto,
                            INPUT aux_inconfir,
                            INPUT aux_tpaltera,
                            INPUT aux_cdempres,
                            INPUT aux_flgpagto,
                            INPUT aux_dtdpagt2,
                            INPUT aux_ddmesnov,
                            INPUT aux_cdfinemp,
                            INPUT aux_qtdialib,
                            INPUT aux_inmatric,
                            INPUT FALSE,
                            INPUT aux_tpemprst,
                            INPUT aux_dtlibera,
                            INPUT aux_inconfi2,
                            INPUT aux_nrcpfope,
                            INPUT aux_cdmodali,
                            INPUT aux_idcarenc,
                            INPUT aux_dtcarenc,
                            INPUT aux_idfiniof,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-msg-confirma,
                            OUTPUT TABLE tt-ge-epr,
                            OUTPUT aux_dsmesage,
                            OUTPUT aux_vlpreemp,
                            OUTPUT aux_dslcremp,
                            OUTPUT aux_dsfinemp,
                            OUTPUT aux_tplcremp,
                            OUTPUT aux_flgpagt2,
                            OUTPUT aux_dtdpagt3,
                            OUTPUT aux_vlutiliz,
                            OUTPUT aux_nivrisco ).

    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-erro:HANDLE,
                                   INPUT "Erro").
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                   INPUT "Mensagens").
            RUN piXmlExport (INPUT TEMP-TABLE tt-ge-epr:HANDLE,
                                   INPUT "GrupoEconomico").
            RUN piXmlSave.

        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                                   INPUT "Mensagens").
            RUN piXmlAtributo (INPUT "dsmesage",INPUT aux_dsmesage).
            RUN piXmlAtributo (INPUT "vlpreemp",INPUT aux_vlpreemp).
            RUN piXmlAtributo (INPUT "dslcremp",INPUT aux_dslcremp).
            RUN piXmlAtributo (INPUT "dsfinemp",INPUT aux_dsfinemp).
            RUN piXmlAtributo (INPUT "tplcremp",INPUT aux_tplcremp).
            RUN piXmlAtributo (INPUT "vlutiliz",INPUT aux_vlutiliz).
            RUN piXmlAtributo (INPUT "flgpagto",INPUT aux_flgpagt2).
            RUN piXmlAtributo (INPUT "dtdpagto",INPUT STRING(aux_dtdpagt3,"99/99/9999")).
            RUN piXmlAtributo (INPUT "nivrisco",INPUT aux_nivrisco).
            RUN piXmlExport   (INPUT TEMP-TABLE tt-ge-epr:HANDLE,
                                     INPUT "GrupoEconomico").
            RUN piXmlSave.
           
        END.

END.

/******************************************************************************
 Procedure para validar os avalistas por separado. (Um aval por tela)
 ******************************************************************************/
PROCEDURE valida-avalistas:

    RUN valida-avalistas IN hBO 
                        (INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_nrdconta,
                         INPUT aux_qtpromis,
                         INPUT aux_qtpreemp,
                         INPUT aux_nrctaav1,
                         INPUT aux_nrcpfav1,
                         INPUT aux_idavalis,
                         INPUT aux_nrctaava,
                         INPUT aux_nmdavali,
                         INPUT aux_nrcpfcgc,
                         INPUT aux_nrcpfcjg,
                         INPUT aux_dsendre1,
                         INPUT aux_cdufresd,
                         INPUT aux_nrcepend,
                         INPUT aux_inpessoa,
                         INPUT aux_dtnascto,
                        OUTPUT aux_nmdcampo,
                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
            
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlSave.
           
        END.

END.

/**************************************************************************
 Validar os dados do imovel cadastrado na proposta de emprestimo com linha 
 de credito do tipo hipoteca.
**************************************************************************/
PROCEDURE valida-dados-hipoteca:

    RUN valida-dados-hipoteca IN hBO
                            ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_dscatbem,
                              INPUT aux_dsbemfin,
                              INPUT aux_vlmerbem,
                              INPUT aux_idcatbem,
                              INPUT FALSE,
                              INPUT aux_vlemprst,
                             OUTPUT TABLE tt-erro,
                             OUTPUT aux_nmdcampo,
                             OUTPUT aux_flgsenha,
                             OUTPUT aux_dsmensag).

     IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgsenha",INPUT aux_flgsenha).
            RUN piXmlAtributo (INPUT "dsmensag",INPUT aux_dsmensag).
            RUN piXmlSave.
        END.

END.

/**************************************************************************
 Validar os bens cadastrado na proposta de emprestimo com linha 
 de credito do tipo alienacao.
**************************************************************************/
PROCEDURE valida-dados-alienacao:

    RUN valida-dados-alienacao IN hBO
                              (INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               
                               INPUT aux_cddopcao,
                               INPUT aux_nrdconta,
                               INPUT aux_nrctremp,
                               INPUT aux_dscorbem,
                               INPUT aux_nrdplaca,
                               INPUT aux_idseqbem,
                               
                               INPUT aux_dscatbem,
                               INPUT aux_dstipbem,
                               INPUT aux_dsbemfin,
                               INPUT aux_vlmerbem,
                               INPUT aux_tpchassi,
                               INPUT aux_dschassi,
                               INPUT aux_ufdplaca,
                               INPUT aux_uflicenc,
                               INPUT aux_nrrenava,
                               INPUT aux_nranobem,
                               INPUT aux_nrmodbem,
                               INPUT aux_nrcpfbem,
                               INPUT aux_idcatbem,
                               INPUT FALSE,       
                               INPUT aux_vlemprst,
                               OUTPUT TABLE tt-erro,
                               OUTPUT aux_nmdcampo,
                               OUTPUT aux_flgsenha,
                               OUTPUT aux_dsmensag).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlAtributo (INPUT "flgsenha",INPUT aux_flgsenha).
            RUN piXmlAtributo (INPUT "dsmensag",INPUT aux_dsmensag).
            RUN piXmlSave.
        END.


END.

/**************************************************************************
 Montar as mensagens de alerta no final do prenchimento das alteraçoes
 ou inclusoes de propostas de emprestimo.
**************************************************************************/
PROCEDURE verifica-outras-propostas:
          
    RUN verifica-outras-propostas IN hBO
                                ( INPUT aux_cdcooper, 
                                  INPUT aux_cdagenci, 
                                  INPUT aux_nrdcaixa, 
                                  INPUT aux_cdoperad, 
                                  INPUT aux_nmdatela, 
                                  INPUT aux_idorigem, 
                                  INPUT aux_nrdconta, 
                                  INPUT aux_nrctremp, 
                                  INPUT aux_idseqttl, 
                                  INPUT aux_dtmvtolt, 
                                  INPUT aux_dtmvtopr, 
                                  INPUT aux_vlemprst, 
                                  INPUT aux_vleprori, 
                                  INPUT aux_vlminimo, 
                                  INPUT aux_qtpromis, 
                                  INPUT aux_qtpreemp, 
                                  INPUT aux_cdlcremp,
                                  INPUT TABLE tt-interv-anuentes,
                                  INPUT TABLE tt-bens-alienacao,
                                 OUTPUT TABLE tt-erro,                                  
                                 OUTPUT TABLE tt-msg-confirma,
                                 OUTPUT TABLE tt-ge-epr  ).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a"
                                                            + " operacao.".
                END.
                
            RUN piXmlSaida (INPUT TEMP-TABLE tt-erro:HANDLE,
                            INPUT "Erro").
        END.
    ELSE 
        DO:
            RUN piXmlNew.
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagens").

            RUN piXmlExport (INPUT TEMP-TABLE tt-ge-epr:HANDLE,
                             INPUT "GrupoEconomico").
            RUN piXmlSave.
        END.


END.

/******************************************************************************/
/**        Procedure para carregar dados para impressos do emprestimo        **/
/******************************************************************************/
PROCEDURE gera-impressao-empr:

    RUN gera-impressao-empr IN hBO
                           ( INPUT aux_cdcooper, 
                             INPUT aux_cdagenci, 
                             INPUT aux_nrdcaixa, 
                             INPUT aux_cdoperad, 
                             INPUT aux_nmdatela, 
                             INPUT aux_idorigem, 
                             INPUT aux_nrdconta, 
                             INPUT aux_idseqttl, 
                             INPUT aux_dtmvtolt, 
                             INPUT aux_dtmvtopr, 
                             INPUT TRUE, 
                             INPUT aux_recidepr, 
                             INPUT aux_idimpres, 
                             INPUT FALSE, 
                             INPUT aux_nrpagina, 
                             INPUT aux_flgemail, 
                             INPUT aux_dsiduser, 
                             INPUT aux_dtcalcul, 
                             INPUT aux_inproces, 
                             INPUT aux_promsini, 
                             INPUT aux_cdprogra, 
                             INPUT aux_flgentra,
							/* INPUT aux_nrctremp, */
                            OUTPUT aux_flgentrv,
                            OUTPUT aux_nmarqimp,  
                            OUTPUT aux_nmarqpdf, 
                            OUTPUT TABLE tt-erro ).

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
            RUN piXmlAtributo (INPUT "flgentrv",INPUT aux_flgentrv).
            RUN piXmlAtributo (INPUT "nmarqimp",INPUT aux_nmarqimp).
            RUN piXmlAtributo (INPUT "nmarqpdf",INPUT aux_nmarqpdf).
            RUN piXmlSave.
        END.                   
   
END.

/************************************************************************** 
 Alterar todos os dados da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
**************************************************************************/
PROCEDURE grava-proposta-completa:       
  
    RUN grava-proposta-completa IN hBO
                               (INPUT aux_cdcooper,
                                INPUT aux_cdagenci,
								INPUT aux_cdpactra,
                                INPUT aux_nrdcaixa,
                                INPUT aux_cdoperad,
                                INPUT aux_nmdatela,
                                INPUT aux_idorigem,
                                INPUT aux_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_dtmvtolt,
                                INPUT aux_inpessoa,
                                INPUT aux_nrctremp,
                                INPUT aux_tpemprst,
                                INPUT aux_flgcmtlc,
                                INPUT aux_vlutiliz,
                                INPUT aux_vllimapv,
                                INPUT aux_cddopcao,
                                INPUT aux_vlemprst,
                                INPUT aux_vlpreant,
                                INPUT aux_vlpreemp,
                                INPUT aux_qtpreemp,
                                INPUT aux_dsnivris,
                                INPUT aux_cdlcremp,
                                INPUT aux_cdfinemp,
                                INPUT aux_qtdialib,
                                INPUT aux_flgimppr,
                                INPUT aux_flgimpnp,
                                INPUT aux_percetop,
                                INPUT aux_idquapro,
                                INPUT aux_dtdpagto,
                                INPUT aux_qtpromis,
                                INPUT aux_flgpagto,
                                INPUT aux_dsctrliq,
                                INPUT aux_nrctaava,
                                INPUT aux_nrctaav2,
                                INPUT aux_idcarenc,
                                INPUT aux_dtcarenc,
                                INPUT aux_nrgarope,
                                INPUT aux_nrperger,
                                INPUT aux_dtcnsspc,
                                INPUT aux_nrinfcad,
                                INPUT aux_dtdrisco,
                                INPUT aux_vltotsfn,
                                INPUT aux_qtopescr,
                                INPUT aux_qtifoper,
                                INPUT aux_nrliquid,
                                INPUT aux_vlopescr,
                                INPUT aux_vlrpreju,
                                INPUT aux_nrpatlvr,
                                INPUT aux_dtoutspc,
                                INPUT aux_dtoutris,
                                INPUT aux_vlsfnout,
                                INPUT aux_vlsalari,
                                INPUT aux_vloutras,
                                INPUT aux_vlalugue,
                                INPUT aux_vlsalcon,
                                INPUT aux_nmempcje,
                                INPUT aux_flgdocje,
                                INPUT aux_nrctacje,
                                INPUT aux_nrcpfcje,
                                INPUT aux_perfatcl,
                                INPUT aux_vlmedfat,
                                INPUT aux_inconcje,
                                INPUT aux_flgconsu,
                                INPUT aux_dsobserv,
                                INPUT aux_dsdfinan,        
                                INPUT aux_dsdrendi,        
                                INPUT aux_dsdebens,        
                                INPUT aux_dsdalien,        
                                INPUT aux_dsinterv,        
                                INPUT "",          
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
                                INPUT aux_cdnacio1,
                                INPUT aux_vledvmt1,        
                                INPUT aux_vlrenme1,
                                INPUT aux_nrender1,
                                INPUT aux_complen1,
                                INPUT aux_nrcxaps1,
                                INPUT aux_inpesso1,
                                INPUT aux_dtnasct1,
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
                                INPUT aux_cdnacio2,        
                                INPUT aux_vledvmt2,        
                                INPUT aux_vlrenme2,
                                INPUT aux_nrender2,
                                INPUT aux_complen2,
                                INPUT aux_nrcxaps2,
                                INPUT aux_inpesso2,
                                INPUT aux_dtnasct2,
                                INPUT par_dsdbeavt,        
                                INPUT TRUE,
                                INPUT aux_dsjusren,
                                INPUT aux_dtlibera,
                                INPUT aux_idfiniof,
                                INPUT aux_dscatbem,
                                OUTPUT TABLE tt-erro,                          
                                OUTPUT TABLE tt-msg-confirma,
                                OUTPUT aux_recidepr,
                                OUTPUT aux_nrctremp,
                                OUTPUT aux_flmudfai). 

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
                             INPUT "Mensagens").
            RUN piXmlAtributo (INPUT "recidepr",INPUT aux_recidepr).
            RUN piXmlAtributo (INPUT "nrctremp",INPUT aux_nrctremp).
            RUN piXmlAtributo (INPUT "flmudfai",INPUT aux_flmudfai).
            RUN piXmlSave.
        END.

END.

PROCEDURE obtem-dados-liquidacoes:

    RUN obtem-dados-emprestimos IN hBO
                              ( INPUT aux_cdcooper, 
                                INPUT aux_cdagenci, 
                                INPUT aux_nrdcaixa, 
                                INPUT aux_cdoperad, 
                                INPUT aux_nmdatela, 
                                INPUT aux_idorigem, 
                                INPUT aux_nrdconta, 
                                INPUT aux_idseqttl, 
                                INPUT aux_dtmvtolt, 
                                INPUT aux_dtmvtopr, 
                                INPUT aux_dtcalcul, 
                                INPUT aux_nrctremp, 
                                INPUT aux_cdprogra, 
                                INPUT aux_inproces, 
                                INPUT TRUE, 
                                INPUT TRUE,
                                INPUT aux_nriniseq,
                                INPUT aux_nrregist,
                               OUTPUT aux_qtregist,
                               OUTPUT TABLE tt-erro,
                               OUTPUT TABLE tt-dados-epr ).

    IF  RETURN-VALUE <> "OK"  OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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

    EMPTY TEMP-TABLE tt-erro.

	RUN obtem-dados-limite-adp IN hBO 
							 ( INPUT aux_cdcooper,
							   INPUT aux_nrdconta,
							  OUTPUT TABLE tt-erro,
					  	       INPUT-OUTPUT TABLE tt-dados-epr ).

	IF  RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    /* Pre-selecao das linhas do browse */
    RUN obtem-emprestimos-selecionados IN hBO
                                     ( INPUT aux_cdcooper,
                                       INPUT aux_cdagenci,           
                                       INPUT aux_nrdcaixa,           
                                       INPUT aux_cdoperad,
                                       INPUT aux_nmdatela,
                                       INPUT aux_idorigem,           
                                       INPUT aux_nrdconta,
                                       INPUT aux_idseqttl,           
                                       INPUT TRUE,
                                       INPUT aux_dsctrliq,
                                       INPUT aux_cdlcremp,
                                       INPUT-OUTPUT TABLE tt-dados-epr,
                                      OUTPUT TABLE tt-erro ).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
            RUN piXmlExport (INPUT TEMP-TABLE tt-dados-epr:HANDLE,
                             INPUT "Proposta").
            RUN piXmlSave.
        END.
   

END.

/******************************************************************************
 Procedure para validar a liquidacao de emprestimos do associado         
 ******************************************************************************/
PROCEDURE valida-liquidacao-emprestimos:
    
     RUN valida-liquidacao-emprestimos IN hBO
                                     ( INPUT aux_cdcooper,  
                                       INPUT aux_cdagenci,  
                                       INPUT aux_nrdcaixa,  
                                       INPUT aux_cdoperad,  
                                       INPUT aux_nmdatela,  
                                       INPUT aux_idorigem,  
                                       INPUT aux_nrdconta, 
                                       INPUT aux_nrctremp,
                                       INPUT aux_idseqttl,  
                                       INPUT aux_dtmvtolt,  
                                       INPUT aux_dtmvtoep,  
                                       INPUT aux_qtlinsel,  
                                       INPUT aux_vlemprst,
                                       INPUT aux_vlsdeved,
                                       INPUT aux_tosdeved,  
                                       INPUT TRUE,          
									   INPUT aux_idenempr,     /* identificador limite/adp */    
                                      OUTPUT aux_tpdretor,
                                      OUTPUT aux_msgretor,
                                      OUTPUT TABLE tt-erro ).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
            RUN piXmlAtributo (INPUT "tpdretor",INPUT aux_tpdretor).
            RUN piXmlAtributo (INPUT "msgretor",INPUT aux_msgretor).
            RUN piXmlSave.
        END.

END.

/**************************************************************************
 Trazer a qualificao da operacao.
 Na alteraçao e inclusao de proposta. 
**************************************************************************/
PROCEDURE proc_qualif_operacao:

    RUN proc_qualif_operacao IN hBO
                            (INPUT aux_cdcooper,
                             INPUT aux_cdagenci,  
                             INPUT aux_nrdcaixa,
                             INPUT aux_cdoperad,
                             INPUT aux_nmdatela,
                             INPUT aux_idorigem,
                             INPUT aux_nrdconta,
                             INPUT aux_dsctrliq,
                             INPUT aux_dtmvtolt,
                             INPUT aux_dtmvtopr,
                             INPUT aux_dtmvtoan,
                            OUTPUT aux_idquapro,
                            OUTPUT aux_dsquapro ).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
            RUN piXmlAtributo (INPUT "idquapro",INPUT STRING(aux_idquapro)).
            RUN piXmlAtributo (INPUT "dsquapro",INPUT aux_dsquapro).
            RUN piXmlSave.
        END.

END.

/**************************************************************************
 Procedure para alterar o valor da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
 E utilizada na Inclusao da proposta.
**************************************************************************/
PROCEDURE altera-valor-proposta:

    RUN altera-valor-proposta IN hBO
                            ( INPUT aux_cdcooper,
                              INPUT aux_cdagenci,
                              INPUT aux_nrdcaixa,
                              INPUT aux_cdoperad,
                              INPUT aux_nmdatela,
                              INPUT aux_idorigem,
                              INPUT aux_nrdconta,
                              INPUT aux_idseqttl,
                              INPUT aux_dtmvtolt,
                              INPUT aux_nrctremp,
                              INPUT aux_flgcmtlc,
                              INPUT aux_vlemprst,
                              INPUT aux_vlpreemp,
                              INPUT aux_vlutiliz,
                              INPUT aux_vleprori,
                              INPUT aux_vllimapv,
                              INPUT FALSE,
                              INPUT aux_dsdopcao,
                              INPUT aux_dtlibera,
                              INPUT aux_idfiniof,
                              INPUT aux_dscatbem,
                             OUTPUT aux_flmudfai,
                             OUTPUT TABLE tt-erro,
                             OUTPUT TABLE tt-msg-confirma).

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
            RUN piXmlAtributo (INPUT "flmudfai",INPUT aux_flmudfai).            
            RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                             INPUT "Mensagem").
            RUN piXmlSave.
        END.

END.

/***************************************************************************
 Procedure para alterar o numero da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
***************************************************************************/
PROCEDURE altera-numero-proposta:

    RUN altera-numero-proposta IN hBO
                             ( INPUT aux_cdcooper,
                               INPUT aux_cdagenci,
                               INPUT aux_nrdcaixa,
                               INPUT aux_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT aux_idorigem,
                               INPUT aux_nrdconta,
                               INPUT aux_idseqttl,
                               INPUT aux_dtmvtolt,
                               INPUT aux_nrctrant,
                               INPUT aux_nrctremp,
                               INPUT aux_cdlcremp,
                               INPUT TRUE,
                              OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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

/****************************************************************************/
/**                  Procedure para Busca de Observação                    **/
/****************************************************************************/
PROCEDURE traz-observacao:

     RUN traz-observacao IN hBO
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_nrdconta,
                         INPUT aux_nrctrobs,
                        OUTPUT aux_dsobserv,
                        OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
              RUN piXmlAtributo (INPUT "dsobserv",INPUT aux_dsobserv).
              RUN piXmlSave.
          END.

END.

/****************************************************************************/
/**               Procedure para verificar se contrato é valido            **/
/****************************************************************************/
PROCEDURE verifica-contrato:

     RUN verifica-contrato IN hBO
                         ( INPUT aux_cdcooper,
                           INPUT aux_cdagenci,
                           INPUT aux_nrdcaixa,
                           INPUT aux_nrdconta,
                           INPUT aux_nrctremp,
                           INPUT aux_nrctrem2,
                           INPUT aux_inusatab,
                           INPUT aux_nralihip,
                          OUTPUT TABLE tt-erro).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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

/****************************************************************************/
/**                    Procedure para validar interveniente                **/
/****************************************************************************/
PROCEDURE valida-interv:

     RUN valida-interv IN hBO
                         ( INPUT aux_cdcooper, 
                           INPUT aux_cdagenci, 
                           INPUT aux_nrdcaixa, 
                           INPUT aux_cdoperad, 
                           INPUT aux_nmdatela, 
                           INPUT aux_idorigem, 
                           INPUT aux_nrctaava, 
                           INPUT aux_nmdavali, 
                           INPUT aux_nrcpfcgc, 
                           INPUT aux_tpdocava, 
                           INPUT aux_nrdocava, 
                           INPUT aux_cdnacion, 
                           INPUT aux_nmconjug, 
                           INPUT aux_nrcpfcjg, 
                           INPUT aux_tpdoccjg, 
                           INPUT aux_nrdoccjg, 
                           INPUT aux_dsendre1,
                           INPUT aux_dsendre2,
                           INPUT aux_nrfonres, 
                           INPUT aux_dsdemail, 
                           INPUT aux_nmcidade, 
                           INPUT aux_cdufresd, 
                           INPUT aux_nrcepend, 
                          OUTPUT TABLE tt-erro,
                          OUTPUT aux_nmdcampo ).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF  NOT AVAILABLE tt-erro  THEN
                DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.dscritic = "Nao foi possivel concluir a " +
                                              "operacao.".
                END.
                
            RUN piXmlNew.
            RUN piXmlExport   (INPUT TEMP-TABLE tt-erro:HANDLE,
                               INPUT "Erro").
            RUN piXmlAtributo (INPUT "nmdcampo",INPUT aux_nmdcampo).
            RUN piXmlSave.
        END.
      ELSE
          DO:
              RUN piXmlNew.
              RUN piXmlSave.
          END.

END.

/*...........................................................................*/

/*****************************************************************************
 Excluir a proposta de emprestimo, Opcao excluir na rotina de emprestimos 
 da tela ATENDA.
*****************************************************************************/
PROCEDURE excluir-proposta:

    RUN excluir-proposta IN hBO 
                       ( INPUT aux_cdcooper,
                         INPUT aux_cdagenci,
                         INPUT aux_nrdcaixa,
                         INPUT aux_cdoperad,
                         INPUT aux_nmdatela,
                         INPUT aux_idorigem,
                         INPUT aux_nrdconta,
                         INPUT aux_idseqttl,
                         INPUT aux_dtmvtolt,
                         INPUT aux_nrctremp,
                         INPUT TRUE,
                        OUTPUT TABLE tt-erro ).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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

/******************************************************************************/
/**        Procedure para carregar dados para impressos do emprestimo        **/
/******************************************************************************/
PROCEDURE valida_impressao:

    RUN valida_impressao IN hBO ( INPUT aux_cdcooper,
                                  INPUT aux_cdoperad,
                                  INPUT aux_cdagenci,
                                  INPUT aux_nrdcaixa,
                                  INPUT aux_idorigem,
                                  INPUT aux_nmdatela,
                                  INPUT aux_nrdconta,
                                  INPUT aux_idseqttl,
                                  INPUT aux_recidepr,
                                  INPUT aux_tplcremp,
                                 OUTPUT aux_inobriga,
                                 OUTPUT TABLE tt-erro ). 

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
            RUN piXmlAtributo (INPUT "inobriga",INPUT aux_inobriga).
            RUN piXmlSave.
        END.                   

END PROCEDURE.

PROCEDURE retornaDataUtil:

    RUN retornaDataUtil IN hBo (INPUT aux_cdcooper,
                                INPUT aux_dtmvtolt, /* Data do emprestimo */
                                INPUT aux_qtdialib,
                               OUTPUT aux_dtlibera).

     RUN piXmlNew.
     RUN piXmlAtributo (INPUT "dtlibera",INPUT STRING(aux_dtlibera,"99/99/9999")).
     RUN piXmlSave.

END PROCEDURE.

PROCEDURE retorna_UF_PA_ASS:

    RUN retorna_UF_PA_ASS  IN hBO (INPUT aux_cdcooper,
                                   INPUT aux_nrdconta,
                                  OUTPUT aux_uflicenc).

    RUN piXmlNew.
    RUN piXmlAtributo (INPUT "uflicenc", INPUT aux_uflicenc).
    RUN piXmlSave.

END PROCEDURE.

/*****************************************************************************/
/**        Procedure para calcular o custo efetivo total CET                **/
/*****************************************************************************/
PROCEDURE calcula-cet:
    
    RUN calcula-cet IN hBO ( INPUT aux_cdcooper, 
                             INPUT aux_cdagenci, 
                             INPUT aux_nrdcaixa, 
                             INPUT aux_cdoperad, 
                             INPUT aux_nmdatela, 
                             INPUT aux_idorigem, 
                             INPUT aux_dtmvtolt,

                             INPUT aux_qtpreemp,
                             INPUT aux_vlpreemp,
                             INPUT aux_vlemprst,
                             INPUT aux_dtlibera,
                             INPUT aux_dtdpagto,
                            OUTPUT aux_txcetano,
                            OUTPUT TABLE tt-erro ). 
    
    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlAtributo (INPUT "txcetano", INPUT SUBSTR(aux_txcetano,1,5)).
            RUN piXmlSave.
        END.                   
     
END PROCEDURE.


/*****************************************************************************/
/**        Procedure para calcular o custo efetivo total CET novo           **/
/*****************************************************************************/
PROCEDURE calcula_cet_novo:
    
    RUN calcula_cet_novo IN hBO (INPUT aux_cdcooper, 
                                 INPUT aux_cdagenci, 
                                 INPUT aux_nrdcaixa, 
                                 INPUT aux_cdoperad, 
                                 INPUT aux_nmdatela, 
                                 INPUT aux_idorigem, 
                                 INPUT aux_dtmvtolt,
                                 INPUT aux_nrdconta,

                                 INPUT aux_inpessoa,
                                 INPUT 2, /* cdusolcr */
                                 INPUT aux_cdlcremp,
                                 INPUT aux_tpemprst,
                                 INPUT aux_nrctremp,
                                 INPUT aux_dtlibera,
                                 INPUT aux_vlemprst,
                                 INPUT aux_vlpreemp,
                                 INPUT aux_qtpreemp,
                                 INPUT aux_dtdpagto,
                                 INPUT aux_cdfinemp,
                                 INPUT aux_dscatbem,
                                 INPUT aux_idfiniof,
                                 INPUT aux_dsctrliq,
                                OUTPUT aux_txcetano,
                                OUTPUT aux_txcetmes,
                                OUTPUT TABLE tt-erro ). 
    
    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlAtributo (INPUT "txcetano", INPUT STRING(aux_txcetano) ).
            RUN piXmlSave.
        END.                   
     
END PROCEDURE.

PROCEDURE carrega_dados_proposta_finalidade:
    
    RUN carrega_dados_proposta_finalidade IN hBO (INPUT aux_cdcooper, 
                                                  INPUT aux_cdagenci, 
                                                  INPUT aux_nrdcaixa, 
                                                  INPUT aux_cdoperad, 
                                                  INPUT aux_nmdatela, 
                                                  INPUT aux_idorigem, 
                                                  INPUT aux_dtmvtolt,
                                                  INPUT aux_nrdconta,
                                                  INPUT aux_tpemprst,
                                                  INPUT aux_cdfinemp,
                                                  INPUT aux_cdlcremp,
                                                  INPUT TRUE,
                                                  INPUT aux_dsctrliq,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-dados-proposta-fin). 
    
    IF  RETURN-VALUE <> "OK"  THEN
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
            RUN piXmlExport   (INPUT TEMP-TABLE tt-dados-proposta-fin:HANDLE,
                               INPUT "Dados").
            RUN piXmlSave.
        END.                   
    
END PROCEDURE.

PROCEDURE carrega_dados_proposta_linha_credito:

    RUN carrega_dados_proposta_linha_credito IN hBO (INPUT aux_cdcooper, 
                                                     INPUT aux_cdagenci, 
                                                     INPUT aux_nrdcaixa, 
                                                     INPUT aux_cdoperad, 
                                                     INPUT aux_nmdatela, 
                                                     INPUT aux_idorigem, 
                                                     INPUT aux_dtmvtolt,
                                                     INPUT aux_nrdconta,
                                                     INPUT aux_cdfinemp,
                                                     INPUT aux_cdlcremp,
                                                     INPUT aux_dsctrliq,
                                                     OUTPUT TABLE tt-erro,
                                                     OUTPUT aux_dsnivris,
                                                     OUTPUT aux_inobriga).

    IF RETURN-VALUE <> "OK"  THEN
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
           RUN piXmlAtributo (INPUT "dsnivris",INPUT aux_dsnivris).            
           RUN piXmlAtributo (INPUT "inobriga",INPUT aux_inobriga).
           RUN piXmlSave.
       END.                   
    
END PROCEDURE.    

PROCEDURE atualiza_risco_proposta:

    RUN atualiza_risco_proposta IN hBO ( INPUT aux_cdcooper,
                                         INPUT aux_cdagenci,
                                         INPUT aux_nrdcaixa,
                                         INPUT aux_cdoperad,
                                         INPUT aux_nmdatela,
                                         INPUT aux_idorigem,
                                         INPUT aux_dtmvtolt,
                                         INPUT aux_nrdconta,
                                         INPUT aux_nrctremp,
                                        OUTPUT TABLE tt-erro ). 

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

PROCEDURE recalcular_emprestimo:

    RUN recalcular_emprestimo IN hBO (INPUT aux_cdcooper,
                                      INPUT aux_cdagenci,
                                      INPUT aux_nrdcaixa,
                                      INPUT aux_cdoperad,
                                      INPUT aux_nmdatela,
                                      INPUT aux_idorigem,
                                      INPUT aux_dtmvtolt,
                                      INPUT aux_dtmvtopr,
                                      INPUT aux_nrdconta,
                                      INPUT aux_idseqttl,
                                      INPUT aux_nrctremp,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-msg-confirma). 

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
           RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                            INPUT "Mensagens").
           RUN piXmlSave.
       END.        

END PROCEDURE.

/***************************************************************************
 Procedure para alterar o avalista da proposta de emprestimo.
 Opcao de Alterar na rotina Emprestimo da tela ATENDA.
***************************************************************************/
PROCEDURE atualiza_dados_avalista_proposta:

    RUN atualiza_dados_avalista_proposta IN hBO
        (INPUT aux_cdcooper,
         INPUT aux_cdagenci,
         INPUT aux_nrdcaixa,
         INPUT aux_cdoperad,
         INPUT aux_nmdatela,
         INPUT aux_idorigem,
         INPUT aux_nrdconta,
         INPUT aux_idseqttl,
         INPUT aux_dtmvtolt,
         INPUT aux_nrctremp,
         INPUT TRUE,      /* flgerlog */
         INPUT "ASA",     /* Alterar Somente Avalistas */
         INPUT aux_nrctaava,
         INPUT aux_nrctaav2,
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
         INPUT aux_cdnacio1,
         INPUT aux_vledvmt1,
         INPUT aux_vlrenme1,
         INPUT aux_nrender1,
         INPUT aux_complen1,
         INPUT aux_nrcxaps1,
         INPUT aux_inpesso1,
         INPUT aux_dtnasct1,
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
         INPUT aux_cdnacio2,
         INPUT aux_vledvmt2,
         INPUT aux_vlrenme2,
         INPUT aux_nrender2,
         INPUT aux_complen2,
         INPUT aux_nrcxaps2,
         INPUT aux_inpesso2,
         INPUT aux_dtnasct2,
         INPUT par_dsdbeavt,
        OUTPUT aux_flmudfai,
        OUTPUT TABLE tt-erro,
        OUTPUT TABLE tt-msg-confirma).

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
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
              RUN piXmlAtributo (INPUT "flmudfai",INPUT aux_flmudfai).            
              RUN piXmlExport (INPUT TEMP-TABLE tt-msg-confirma:HANDLE,
                               INPUT "Mensagem").
              RUN piXmlSave.
          END.


END.
