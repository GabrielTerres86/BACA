/*.............................................................................

    Programa: fontes/crps636.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Lucas Lunelli
    Data    : Fevereiro/2013                  Ultima Atualizacao : 17/07/2017
    
    Dados referente ao programa:
    
    Frequencia : Diario (Batch). 
    Objetivo   : Convenios Sicredi - Geração dos arquivos de arrecadação de 
                                     faturas e de DARF.
                 Chamado Softdesk 43413.
                 
    Alteracoes : 06/05/2013 - Utilização imprim_unif e alteração do
                              dir do rel637 (Lucas).
                              
                 21/05/2013 - Alterações para DARFs (Lucas).
                 
                 22/05/2013 - Correção exportação DARFs (Lucas).
                 
                 29/05/2013 - Tratamento para guia sem data de apuracao (Elton)
                 
                 31/05/2013 - crrl637 132col. (Lucas).
                 
                 11/06/2013 - Melhorias desempenho das consultas (Lucas).
                 
                 10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                              a escrita será PA (André Euzébio - Supero).
                              
                 17/09/2013 - Incluido str_4 para consorcios crrl664, ajustes 
                              para enviar registro "F" de consorcios no str_2.
                              (Lucas R.)
                              
                 08/10/2013 - Ajustado para buscar apenas os 2 ultmos digitos
                              da agencia, por exemplo agencia 101, busca apenas
                              o 01 (Lucas R.).
                              
                 10/12/2013 - Incluido CREATE tt-rel664 no for da 
                              crapndb e adicionado campo dscritic no form
                              f_crrl664_det (Lucas R.).
                              
                 12/12/2013 - Incluido craplau.cdseqtel no registro "F"
                              (Lucas R.)
                              
                 07/01/2014 - Enviar arquivos de arrecadacao de faturas e
                              de DARFs para o email convenios@cecred.coop.br.
                              (Fabricio)
                 
                 17/01/2014 - Alteracao referente a integracao Progress X 
                              Dataserver Oracle 
                              Inclusao do VALIDATE ( Andre Euzebio / SUPERO)
                              
                 04/04/2014 - Incluir ajustes para gerar arquivo de exportacao
                              de debitos sicredi e criado novo relatorio
                              crrl674 (Lucas R.)
							  
				 29/04/2014 - Ajuste migracao Oracle (Elton).
                 
                 21/10/2014 - Ajustado crrl674 e geracao do registro "B"
                              (Lucas R.)
                              
                 02/12/2014 - Ajustado tt-rel674-cadastro.cdrefere para gravar
                              o codigo de referencia e nao o numero da conta
                            - Incluir campos nrdgrupo, dsconsor no frame 
                              f_crrl664_det (Lucas R. #228699)
                              
                 30/12/2014 - Alterado somatoria dos registros da craplcm para
                              contabilizar no final do for each.
                            - Arrumar format do cdagenci do registro "B" 
                            (Lucas R./Elton)
                            
                 13/01/2015 - Correção no contador das autorizações de débito
                              automático do SICREDI (Lunelli)
                              
                 22/01/2015 - Correção na busca da tabela de lançamentos
                              automático (Lunelli)
                              
                 11/02/2015 - Alterado procedure gera-linha-arquivo-exp-darf e
                              gera-linha-arquivo-exp-conv para armazenar campos
                              da tabela crapstn somente se existir a mesma
                              (Lucas R./Elton)
                              
                 23/03/2015 - Incluir verificacao de feriado ou fim de semana
                              (Lucas Ranghetti #238028)
                              
                 27/04/2015 - Adicionado verificacao da critica "99" na leitura 
                              da crapndb (Lucas Ranghetti #273400)
                              
                 21/05/2015 - Alterado para armazenar o campo tt-rel664.dsconsor
                              somente quando encontrar na tabela crapcns 
                              (Lucas Ranghetti #284291)
                              
                 09/06/2015 - Modificado a forma de como os arquivos eram
                              movidos para o diretorio do connect, ao inves
                              de serem movidos 1 a 1 de acordo com o que 
                              fossem gerados, apenas foi gravado o caminho 
                              para uma temp-table e movidos todos de uma 
                              vez para otimizar o processo e nao baguncar 
                              o log (SD279514 Tiago/Fabricio).
                              
                 30/07/2015 - Incluido os arquivos ARF na alteracao passada
                              (SD279514 Tiago/Fabricio).
                              
                 10/09/2015 - Ajustado busca por faturas de ate cinco dias
                              ainda nao enviadas. (Fabricio)
                              
                 29/09/2015 - Chamada da pc_relat_repasse_dpvat que gera o 
                              relatorio crrl709 - Repasses Convenio DPVAT 
                              Sicredi. (Jaison/Marcos-Supero)
                              
                 04/01/2016 - Tratamento na atribuicao do nro do documento para
                              montagem do relatorio 674, afim de garantir a
                              execucao do programa mesmo que o as posicoes 02-25
                              nao contenham apenas numericos, evitando assim
                              que deixemos de gerar retorno ao Sicredi.
                              (Chamado 381171) - (Fabricio)

                 31/05/2016 - Alteraçoes Oferta DEBAUT Sicredi (Lucas Lunelli - [PROJ320])
                 
                 25/07/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 11 
                              posicoes, devemos incluir um hifen para completar 12 posicoes 
                              ex: 40151016407- (Lucas Ranghetti #453337)

                 17/08/2016 - Incluir tratamento para os retornos de criticas:
                              04 - Outras restriçoes
                              05 - Valor debito excede limite aprovado
                              PRJ320 - Oferta Debaut (Odirlei-AMcom)
                              
                 24/08/2016 - Incluir tratamento para autorizações suspensas (Lucas Ranghetti #499496)
				                 
                 21/11/2016 - Efetuar replace de '-' por nada no nrdocmto da crapndb (Lucas Ranghetti #560620)

				 28/11/2016 - Alteraçao na composiçao do CPF/CNPJ do arquivo .ARF, 
                              colocando zeros a esquerda (Projeto 338 - Lucas Lunelli)

                 13/12/2016 - Ajustes referente a incorporaçao da Transulcred pela Transpocred. 
                              Os agendamentos recebidos antes da incorporaçao com vencimento após 
                              a incorporaçao serao gravados no arquivo da cooperativa antiga (Elton).             

                 04/01/2017 - Ajustar meio de coleta para codigo '3' quando 
				              for DARF 0385 paga em canal digital (David).
							  
                 03/07/2017 - Incluido condicao para nao pegar convenios com data de cancelamento
                              no for each da crapscn (Tiago/Fabricio #678625)
				 
                 17/07/2017 - Ajustes para permitir o agendamento de lancamentos da mesma
                              conta e referencia no mesmo dia(dtmvtolt) porem com valores
                              diferentes (Lucas Ranghetti #684123) 
............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

DEF  STREAM str_1.  /* Para relatorio crrl637 */
DEF  STREAM str_2.  /* Para arquivo de envio convenios */                     
DEF  STREAM str_3.  /* Para arquivo de envio darfs */         
DEF  STREAM str_4.  /* Para relatorio crrl664 */
DEF  STREAM str_5.  /* Para relatorio crrl674 */

DEF  VAR  rel_nmempres    AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF  VAR  rel_nmresemp    AS CHAR    FORMAT "x(15)"                   NO-UNDO.
DEF  VAR  rel_nmrelato    AS CHAR    FORMAT "x(40)" EXTENT 6          NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                            NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 9
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "CADASTROS",
                                     "PROCESSOS",
                                     "PARAMETRIZACAO",
                                     "SOLICITACOES",
                                     "GENERICO       "]               NO-UNDO.

DEF  VAR  aux_nmmesano    AS CHAR    EXTENT 12 INIT                   
                                [" JANEIRO ","FEVEREIRO",             
                                 "  MARCO  ","  ABRIL  ",             
                                 "  MAIO   ","  JUNHO  ",             
                                 " JULHO   "," AGOSTO  ",             
                                 "SETEMBRO "," OUTUBRO ",             
                                 "NOVEMBRO ","DEZEMBRO "]             NO-UNDO.

DEF  VAR  aux_nmarqdat    AS CHAR     FORMAT "x(20)"                  NO-UNDO.
DEF  VAR  aux_nmarqped    AS CHAR     FORMAT "x(20)"                  NO-UNDO.
DEF  VAR  aux_nmarqdar    AS CHAR     FORMAT "x(20)"                  NO-UNDO.
DEF  VAR  aux_nmexpdar    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_nmarqexp    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_nmarqcon    AS CHAR                                     NO-UNDO.

DEF  VAR  aux_nmarq664    AS CHAR                                     NO-UNDO.

DEF  VAR  aux_nmarqrel    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_nmarqprv    AS CHAR                                     NO-UNDO.

DEF  VAR  aux_dtmvtolt    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_dtmvtopr    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_cdpeslft    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_anomovto    AS CHAR     FORMAT "x(05)"                  NO-UNDO.
DEF  VAR  aux_mesmovto    AS CHAR     FORMAT "x(09)"                  NO-UNDO.
DEF  VAR  aux_nrsequen    AS CHAR                                     NO-UNDO.
DEF  VAR  rel_nmrescop    AS CHAR     EXTENT 2                        NO-UNDO.
DEF  VAR  aux_nmdbanco    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_nmcidade    AS CHAR     EXTENT 2                        NO-UNDO.
DEF  VAR  aux_cdpestit    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_digitmes    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_nmbandar    AS CHAR                                     NO-UNDO.
DEF  VAR  aux_nrseqndb    AS INTE                                     NO-UNDO.
DEF  VAR  aux_nrseqlcm    AS INTE                                     NO-UNDO.
DEF  VAR  aux_vllanmto    AS DEC                                      NO-UNDO.
DEF  VAR  aux_vlfatndb    AS DEC                                      NO-UNDO.
DEF  VAR  aux_vlfatlcm    AS DEC                                      NO-UNDO.

DEF  VAR  aux_vltrfuni    AS DECI                                     NO-UNDO.

DEF  VAR  aux_dtproces    AS DATE                                     NO-UNDO.
DEF  VAR  aux_dtproxim    AS DATE                                     NO-UNDO.
DEF  VAR  aux_dtanteri    AS DATE                                     NO-UNDO.
DEF  VAR  aux_dtvencto    AS DATE                                     NO-UNDO.
DEF  VAR  aux_dtrepass    AS DATE                                     NO-UNDO.

DEF  VAR  aux_nrseqdar    AS INTE                                     NO-UNDO.
DEF  VAR  aux_qtpalavr    AS INTE                                     NO-UNDO.
DEF  VAR  aux_contapal    AS INTE                                     NO-UNDO.
DEF  VAR  aux_nrseqarq    AS INTE     FORMAT "999999"                 NO-UNDO.
DEF  VAR  aux_diamovto    AS INTE     FORMAT "99"                     NO-UNDO.
DEF  VAR  aux_nrseqdig    AS INTE                                     NO-UNDO.
DEF  VAR  aux_nrlinhas    AS INTE                                     NO-UNDO.
DEF  VAR  aux_nrlindrf    AS INTE                                     NO-UNDO.
DEF  VAR  aux_nrdbanco    AS INTE     FORMAT "999"                    NO-UNDO.
DEF  VAR  aux_contador    AS INTE                                     NO-UNDO.
DEF  VAR  aux_dtmvtolt_lcm AS CHAR                                    NO-UNDO.

DEF  VAR  aux_flgvazio    AS LOGI                                     NO-UNDO.
DEF  VAR  aux_flgdarvz    AS LOGI                                     NO-UNDO.
                                                          
DEF  VAR  aux_dtapurac    AS CHAR                                     NO-UNDO.

DEF  VAR  aux_dslinreg    AS CHAR FORMAT "x(160)"                     NO-UNDO.

DEF  VAR  tot_qtfatcxa    AS INTE                                     NO-UNDO.
DEF  VAR  tot_qtfatint    AS INTE                                     NO-UNDO.
DEF  VAR  tot_qtfattaa    AS INTE                                     NO-UNDO.

DEF  VAR  tot_vlfatcxa    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vltarcxa    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlpagcxa    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlorpago    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlfatura    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vltotarq    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vltrfuni    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlapagar    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlfatur2    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlfatint    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vltarint    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlpagint    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlfattaa    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vltartaa    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlpagtaa    AS DECI                                     NO-UNDO.

/* Totais DARFS */
DEF  VAR  tot_vllanmto    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlrmulta    AS DECI                                     NO-UNDO.
DEF  VAR  tot_vlrjuros    AS DECI                                     NO-UNDO.

DEF  VAR  aux_tpconsor    AS INTE                                     NO-UNDO.
DEF  VAR  aux_nrctrato    AS CHAR FORMAT "x(22)"                      NO-UNDO.

DEF VAR aux_segmento AS CHAR                                          NO-UNDO.
DEF VAR aux_qttotseg AS INTE                                          NO-UNDO.
DEF VAR aux_vltotseg AS DECI                                          NO-UNDO.
DEF VAR tot_qtarecad AS INTE                                          NO-UNDO.
DEF VAR tot_vlarecad AS DECI                                          NO-UNDO.
DEF VAR aux_cdagenci AS CHAR FORMAT "x(3)"                            NO-UNDO.
DEF VAR aux_nrctacns AS INT                                           NO-UNDO.
DEF VAR aux_cdseqtel AS CHAR FORMAT "x(60)"                           NO-UNDO.
DEF VAR aux_cdmovmto AS INTE                                          NO-UNDO.
DEF VAR aux_dtmvtolt_atr AS CHAR FORMAT "x(8)"                        NO-UNDO.
DEF VAR aux_cdcritic AS INT                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                          NO-UNDO.
DEF VAR aux_emprelau AS CHAR                                          NO-UNDO.

DEF VAR aux_nrseqatr AS INTE                                          NO-UNDO. 
DEF VAR aux_vlfatatr AS DECI                                          NO-UNDO.
DEF VAR aux_cdrefere AS CHAR FORMAT "x(25)"                           NO-UNDO.
DEF VAR aux_cdempres AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqdeb AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarq674 AS CHAR                                          NO-UNDO.
DEF VAR aux_dsnomcnv AS CHAR                                          NO-UNDO.
DEF VAR aux_nmconsor AS CHAR                                          NO-UNDO.
DEF VAR aux_nrdgrupo LIKE crapcns.nrdgrupo                            NO-UNDO.
DEF VAR aux_nrcrcard AS DECIMAL                                       NO-UNDO.

DEF VAR aux_conteudo AS CHAR                                          NO-UNDO.
DEF VAR h-b1wgen0011 AS HANDLE                                        NO-UNDO.


DEF BUFFER crablau FOR craplau.


DEF TEMP-TABLE tt-arquiv NO-UNDO
    FIELD cdcooper  LIKE crapcop.cdcooper
    FIELD dsdircop  LIKE crapcop.dsdircop
    FIELD nmarqexp  AS CHAR
    FIELD nmarqped  AS CHAR.

DEF TEMP-TABLE tt-lancto NO-UNDO
    FIELD dsnomcnv  AS CHAR FORMAT "x(25)"      
    FIELD dtvencto  AS DATE FORMAT "99/99/9999" 
    FIELD cdbarras  AS CHAR FORMAT "X(44)"      
    FIELD vllanmto  AS DECI FORMAT "zzz,zz9.99" 
    FIELD dsempcnv  AS CHAR FORMAT "X(10)"      
    FIELD cdagenci  AS INTE FORMAT "zzz9"
    FIELD tpfatura  AS INTE.                    

DEF TEMP-TABLE tt-rel664 NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapcns.nrdconta
    FIELD dsconsor AS CHAR
    FIELD nrcotcns LIKE crapcns.nrcotcns
    FIELD qtparcns LIKE crapcns.qtparcns
    FIELD vlrcarta LIKE crapcns.vlrcarta
    FIELD vlparcns LIKE crapcns.vlparcns
    FIELD dscooper AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrctacns LIKE crapcns.nrctacns
    FIELD cdagenci AS INTE
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD tpconsor LIKE crapcns.tpconsor   
    FIELD nrdgrupo LIKE crapcns.nrdgrupo
    FIELD nmconsor LIKE crapcns.nmconsor
    FIELD dscritic AS CHAR.

DEF TEMP-TABLE tt-totais-crrl664 NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapcns.nrdconta
    FIELD nrcotcns LIKE crapcns.nrcotcns
    FIELD tpconsor LIKE crapcns.tpconsor
    FIELD dsconsor AS CHAR
    FIELD qttotseg AS INTE
    FIELD vltotseg AS DECI.

DEF TEMP-TABLE tt-rel674-cadastro NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD cdrefere LIKE crapatr.cdrefere
    FIELD dsnomcnv LIKE crapscn.dsnomcnv
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dsmovmto AS CHAR.

DEF TEMP-TABLE tt-rel674-lancamentos NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nrctacns LIKE crapass.nrctacns
    FIELD dsnomcnv LIKE crapscn.dsnomcnv
    FIELD nrdocmto LIKE craplcm.nrdocmto
    FIELD vllanmto LIKE craplcm.vllanmto
    FIELD dscritic AS CHAR.

FORM SKIP(1)
     aux_nmarqdat   AT  06  LABEL "NOME DO ARQUIVO"
     SKIP(1)
     WITH NO-BOX DOWN SIDE-LABELS  WIDTH 132 FRAME f_label.
                                                      
FORM tt-lancto.dsnomcnv                               COLUMN-LABEL "CONVENIO"
     tt-lancto.dsempcnv                               COLUMN-LABEL "COD.SICREDI"
     tt-lancto.cdagenci                               COLUMN-LABEL "PA"
     tt-lancto.dtvencto                               COLUMN-LABEL "VENCIMENTO"
     tt-lancto.cdbarras                               COLUMN-LABEL "COD.BARRAS" 
     tt-lancto.vllanmto FORMAT "zzz,zzz,zz9.99"       COLUMN-LABEL "VALOR"
     WITH NO-BOX DOWN WIDTH 132 FRAME f_lancto.        

FORM SKIP(2)
     tot_qtfatcxa AT 28 FORMAT "            zzz,zz9"  LABEL "FATURAS CAIXA"
     tot_vlfatcxa AT 25 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "ARRECADADO CAIXA"
     tot_vltarcxa AT 28 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "TARIFAS CAIXA"
     tot_vlpagcxa AT 28 FORMAT "zzzz,zzz,zzz,zz9.99-" LABEL "A PAGAR CAIXA"
     SKIP(1)
     tot_qtfatint AT 25 FORMAT "            zzz,zz9"  LABEL "FATURAS INTERNET"
     tot_vlfatint AT 22 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "ARRECADADO INTERNET"
     tot_vltarint AT 25 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "TARIFAS INTERNET"
     tot_vlpagint AT 25 FORMAT "zzzz,zzz,zzz,zz9.99-" LABEL "A PAGAR INTERNET"
     SKIP(1)
     tot_qtfattaa AT 30 FORMAT "            zzz,zz9"  LABEL "FATURAS TAA"
     tot_vlfattaa AT 27 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "ARRECADADO TAA"
     tot_vltartaa AT 30 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "TARIFAS TAA"
     tot_vlpagtaa AT 30 FORMAT "zzzz,zzz,zzz,zz9.99-" LABEL "A PAGAR TAA"
     SKIP(1)
     aux_nrseqdig AT 20 FORMAT "            zzz,zz9"  LABEL "QUANTIDADE DE FATURAS"
     tot_vlfatura AT 25 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "TOTAL ARRECADADO"
     tot_vltrfuni AT 25 FORMAT "zzzz,zzz,zzz,zz9.99"  LABEL "TOTAL DE TARIFAS"
     tot_vlapagar AT 28 FORMAT "zzzz,zzz,zzz,zz9.99-" LABEL "TOTAL A PAGAR"
     WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_total.

FORM tt-rel664.cdagenci FORMAT "zz9"        COLUMN-LABEL "PA" 
     tt-rel664.nrdconta FORMAT "zzzz,zzz,9" COLUMN-LABEL "CONTA/DV"
     tt-rel664.nrctacns FORMAT "zzzz,zzz,9" COLUMN-LABEL "CTA.CONSOR"
     tt-rel664.nmconsor FORMAT "x(33)"      COLUMN-LABEL "CONSORCIADO"
     tt-rel664.nrdgrupo FORMAT "zzzzzzzz9"  COLUMN-LABEL "GRUPO"
     tt-rel664.dsconsor FORMAT "x(10)"      COLUMN-LABEL "SEGMENTO"
     tt-rel664.nrcotcns FORMAT "zzzzz9"     COLUMN-LABEL "COTA"
     tt-rel664.vlparcns FORMAT "zzz,zz9.99" COLUMN-LABEL "PARCELA"
     tt-rel664.dscritic FORMAT "x(32)"      COLUMN-LABEL "CRITICA"
     WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl664_det.

FORM tt-totais-crrl664.dsconsor FORMAT "x(10)"          COLUMN-LABEL "SEGMENTO"
     tt-totais-crrl664.qttotseg FORMAT "zzzz,zz9"       COLUMN-LABEL "QTD."
     tt-totais-crrl664.vltotseg FORMAT "zzz,zzz,zz9.99" COLUMN-LABEL "VALOR"
     WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl664_tot.

FORM tt-rel674-cadastro.cdagenci FORMAT "zz9"               COLUMN-LABEL "  PA"
     tt-rel674-cadastro.nrdconta FORMAT "zzzzz,zz9,9"       COLUMN-LABEL "CONTA/DV"
     tt-rel674-cadastro.dsnomcnv FORMAT "x(35)"             COLUMN-LABEL "CONVENIO"
     tt-rel674-cadastro.cdrefere FORMAT "zzzzzzzzzzzzzzzzzzzzzzzz9" COLUMN-LABEL "IDENTIFICACAO"
     tt-rel674-cadastro.dsmovmto FORMAT "x(35)"             COLUMN-LABEL "OPERACAO"
    WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl674_cadastro.

FORM tt-rel674-lancamentos.cdagenci FORMAT "zz9"               COLUMN-LABEL "  PA"       
     tt-rel674-lancamentos.nrdconta FORMAT "zzzzz,zz9,9"       COLUMN-LABEL "CONTA/DV" 
     tt-rel674-lancamentos.nrctacns FORMAT "zzz,zz9,9"         COLUMN-LABEL "CT SICREDI"
     tt-rel674-lancamentos.dsnomcnv FORMAT "x(35)"             COLUMN-LABEL "CONVENIO" 
     tt-rel674-lancamentos.nrdocmto FORMAT "zzzzzzzzzzzzzzzzzzzzzzzz9" COLUMN-LABEL "IDENTIFICACAO"
     tt-rel674-lancamentos.vllanmto FORMAT "zzz,zz9.99"        COLUMN-LABEL "VALOR"
    WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl674_lancamentos.

FORM tt-rel674-lancamentos.cdagenci FORMAT "zz9"               COLUMN-LABEL "  PA"       
     tt-rel674-lancamentos.nrdconta FORMAT "zzzzz,zz9,9"       COLUMN-LABEL "CONTA/DV" 
     tt-rel674-lancamentos.nrctacns FORMAT "zzz,zz9,9"         COLUMN-LABEL "CT SICREDI"
     tt-rel674-lancamentos.dsnomcnv FORMAT "x(28)"             COLUMN-LABEL "CONVENIO" 
     tt-rel674-lancamentos.nrdocmto FORMAT "zzzzzzzzzzzzzzzzzzzzzzzz9" COLUMN-LABEL "IDENTIFICACAO"
     tt-rel674-lancamentos.vllanmto FORMAT "zzz,zz9.99"        COLUMN-LABEL "VALOR"
     tt-rel674-lancamentos.dscritic FORMAT "x(38)"             COLUMN-LABEL "CRITICA"
    WITH NO-BOX DOWN WIDTH 132 FRAME f_crrl674_lancamentos_criticas.


/* Mantem flgbatch como FALSE para rodar o programa manualmente na tela PRCCON */
ASSIGN glb_flgbatch = FALSE
       glb_cdprogra = "crps636"
       glb_cdempres = 11
       glb_cdcooper = 3.

UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")                       +
                   " - "   + STRING(TIME,"HH:MM:SS")                          +
                   " - "   + glb_cdprogra + "' --> '"                         +
                   "Iniciada geracao dos arquivos de arrecadacao do Sicredi." +
                   " >> log/prccon.log").

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '"  +
                            glb_dscritic + " >> log/proc_batch.log").

         RETURN.
     END.

/* Verificar se e fim de semana ou feriado */
IF  CAN-DO("1,7",STRING(WEEKDAY(TODAY))) OR
    CAN-FIND(crapfer WHERE 
             crapfer.cdcooper = crapcop.cdcooper  AND
             crapfer.dtferiad = TODAY) THEN
    DO:

        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")              +
                          " - "   + STRING(TIME,"HH:MM:SS")                  +
                          " - "   + glb_cdprogra + "' --> '"                 +
                          "Geracao de arquivos nao realizada por ser fim de" +
                          " semana ou feriado." + " >> log/prccon.log").
        RETURN.
    END.

FIND crapdat WHERE crapdat.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
    
IF  NOT AVAIL crapdat THEN
    DO:
        glb_cdcritic = 1.
        RUN fontes/critic.p.
        UNIX SILENT VALUE ("echo " + STRING(TODAY) + " - "              + 
                          STRING(TIME,"HH:MM:SS") + " - "               +
                          glb_cdprogra + "' --> '" + glb_dscritic       +
                          " - Cooperativa: " + STRING(glb_cdcooper)     +
                          " " + " >> log/proc_batch.log").
        RETURN.
    END.

FIND crapres WHERE crapres.cdcooper = glb_cdcooper AND
                   crapres.cdprogra = glb_cdprogra NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapres THEN
     DO TRANSACTION:

        CREATE crapres.
        ASSIGN crapres.cdprogra = glb_cdprogra
               crapres.nrdconta = 0
               glb_nrctares     = 0
               glb_inrestar     = 0
               glb_dsrestar     = ""
               crapres.cdcooper = glb_cdcooper.
        VALIDATE crapres.

     END.  /*  Fim da transacao  */
ELSE
     DO:
         ASSIGN glb_nrctares = crapres.nrdconta
                glb_dsrestar = crapres.dsrestar
                glb_inrestar = 1
                glb_cdcritic = 152.

         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS")     + 
                            " - " + glb_cdprogra + "' --> '"      + 
                            glb_dscritic + " " +
                            STRING(crapres.nrdconta,"zzzz,zzz,9") +
                            " >> log/proc_batch.log").

         glb_cdcritic = 0.
     END.

IF  glb_cdcritic > 0 THEN
    RETURN.

ASSIGN  glb_dtmvtolt = crapdat.dtmvtolt
        glb_dtmvtoan = crapdat.dtmvtoan 
        glb_dtmvtopr = crapdat.dtmvtopr
        aux_dtproxim = glb_dtmvtopr + 1.

DO WHILE TRUE:          /* Procura pela proxima data */

   IF   NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtproxim))) AND
        NOT CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper   AND
                                   crapfer.dtferiad = aux_dtproxim)  THEN
        LEAVE.

   ASSIGN aux_dtproxim = aux_dtproxim + 1.

END.  /*  Fim do DO WHILE TRUE  */

ASSIGN aux_nmcidade[1] = TRIM(crapcop.nmcidade) + ", "
       aux_nmcidade[2] = TRIM(crapcop.nmcidade) + " - " + 
                         TRIM(crapcop.cdufdcop).

ASSIGN aux_dtmvtolt = STRING(YEAR(glb_dtmvtolt),"9999") +
                      STRING(MONTH(glb_dtmvtolt),"99")  +
                      STRING(DAY(glb_dtmvtolt),"99")       
       aux_dtanteri = glb_dtmvtolt -  5
       aux_diamovto = DAY(aux_dtproxim)
       aux_mesmovto = aux_nmmesano[MONTH(aux_dtproxim)]
       aux_anomovto = STRING(YEAR(aux_dtproxim),"9999") + "."
       aux_nmcidade[1] = aux_nmcidade[1] 
                       + STRING(aux_diamovto) 
                       + " DE "
                       + STRING(aux_mesmovto)
                       + " DE "
                       + aux_anomovto.

ASSIGN glb_cdrelato[1] = 637
       glb_cdrelato[4] = 664
       glb_cdrelato[5] = 674
       glb_progerad    = "636"
       glb_cdempres    = 11
       
       glb_nmdestin[1] = "DESTINO: ADMINISTRATIVO" 
       glb_nmdestin[4] = "DESTINO: ADMINISTRATIVO" 
       glb_nmdestin[5] = "DESTINO: ADMINISTRATIVO".
       
{ includes/cabrel132_1.i }
{ includes/cabrel132_4.i }
{ includes/cabrel132_5.i }

EMPTY TEMP-TABLE tt-arquiv.

/* Para cada cooperativa */
FOR EACH crapcop NO-LOCK.

    EMPTY TEMP-TABLE tt-lancto.
    EMPTY TEMP-TABLE tt-rel664.
    EMPTY TEMP-TABLE tt-totais-crrl664.
    EMPTY TEMP-TABLE tt-rel674-cadastro.
    EMPTY TEMP-TABLE tt-rel674-lancamentos.

    ASSIGN glb_nmrescop = crapcop.nmrescop.

    /* Monta digito do Mês para nome o arquivo SICREDI */
    IF  MONTH(glb_dtmvtolt) = 10 THEN
        ASSIGN aux_digitmes = "O".
    ELSE
    IF  MONTH(glb_dtmvtolt) = 11 THEN
        ASSIGN aux_digitmes = "N".
    ELSE
    IF  MONTH(glb_dtmvtolt) = 12 THEN
        ASSIGN aux_digitmes = "D".
    ELSE
        ASSIGN aux_digitmes = STRING(MONTH(glb_dtmvtolt),"9").

    /* Adquire sequencial do arquivo */
    FIND craptab WHERE craptab.cdcooper = crapcop.cdcooper  AND         
                       craptab.nmsistem = "CRED"            AND         
                       craptab.tptabela = "GENERI"          AND         
                       craptab.cdempres = 00                AND         
                       craptab.cdacesso = "ARQSICREDI"      AND
                       craptab.tpregist = 00
                       NO-LOCK NO-ERROR.

    ASSIGN aux_nrseqdig = 0
           tot_vlfatura = 0 
           tot_vltrfuni = 0 
           tot_vlapagar = 0
           tot_qtfatcxa = 0 
           tot_vlfatcxa = 0
           tot_vltarcxa = 0
           tot_vlpagcxa = 0
           tot_qtfatint = 0 
           tot_vlfatint = 0
           tot_vltarint = 0
           tot_vlpagint = 0
           tot_qtfattaa = 0 
           tot_vlfattaa = 0
           tot_vltartaa = 0
           tot_vlpagtaa = 0
           tot_vlfatur2 = 0
           tot_vlorpago = 0
           tot_vllanmto = 0
           tot_vlrmulta = 0
           tot_vlrjuros = 0
           aux_qttotseg = 0
           aux_vltotseg = 0

           aux_nrlinhas = 0
           aux_nrlindrf = 0
           tot_vltotarq = 0
           aux_flgvazio = TRUE
           aux_flgdarvz = TRUE
           aux_nmdbanco = "SICREDI"     /* Fixo */
           aux_nmbandar = "BANSICREDI"  /* Fixo */
           aux_nrdbanco = 748           /* Fixo */
           aux_nrseqdar = INT(SUBSTR(craptab.dstextab,8,6))
           aux_nrseqarq = INT(SUBSTR(craptab.dstextab,1,6))
           aux_nrsequen = STRING(aux_nrseqarq,"999999")
           aux_nmarqdat = STRING(MONTH(glb_dtmvtolt),"99")   +
                          STRING(DAY(glb_dtmvtolt),"99")     +  "." +
                          SUBSTR(aux_nrsequen,4,3)
           aux_nmarqrel = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/rlnsv/crrl637.lst"
           aux_nmarqprv = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/rl/crrl637.lst"        
           aux_nmarqcon = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/rlnsv/crrl664.lst" 
           aux_nmarq664 = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/rl/crrl664.lst"  
           aux_nmarqdeb = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/rlnsv/crrl674.lst" 
           aux_nmarq674 = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/rl/crrl674.lst"  
           aux_nmarqexp = "0"                                             +
                          FILL("0", 4 - LENGTH(STRING(crapcop.nrctasic))) + 
                               TRIM(SUBSTR(STRING(crapcop.nrctasic),1,4)) +  
                          aux_digitmes                                    +  
                          STRING(DAY  (glb_dtmvtolt),"99")                +  
                          ".EFE"
           aux_nmarqped = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/arq/" + aux_nmarqexp
           aux_nmarqdar = "0"                                             +
                          FILL("0", 4 - LENGTH(STRING(crapcop.nrctasic))) + 
                               TRIM(SUBSTR(STRING(crapcop.nrctasic),1,4)) +  
                          aux_digitmes                                    +
                          STRING(DAY  (glb_dtmvtolt),"99")                +  
                          ".ARF"
           aux_nmexpdar = "/usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/arq/" + aux_nmarqdar.

    
    OUTPUT STREAM str_1 TO VALUE(aux_nmarqrel) PAGED PAGE-SIZE 84. /*rel. 637*/
    
    OUTPUT STREAM str_2 TO VALUE(aux_nmarqped).  /* arq. exportar */
    OUTPUT STREAM str_3 TO VALUE(aux_nmexpdar).  /* arq. exportar darfs */ 

    /*** crrl664 referente ao relatorio de consorcios ***/
    OUTPUT STREAM str_4 TO VALUE(aux_nmarqcon) PAGED PAGE-SIZE 84. 

    /*** crrl674 referente ao relatorio de Importacao de debitos ***/
    OUTPUT STREAM str_5 TO VALUE(aux_nmarqdeb) PAGED PAGE-SIZE 84. 

    
    /* Header */
    PUT STREAM str_2 "A2"          
                     FILL(" ",40)  FORMAT "X(40)" 
                     aux_nrdbanco  FORMAT "999" 
                     aux_nmdbanco  FORMAT "x(20)"
                     aux_dtmvtolt  FORMAT "x(08)" 
                     aux_nrseqarq  FORMAT "999999"
                     "04DEBITO AUTOMATICO"
                     FILL(" ",62)  FORMAT "X(62)"
                     SKIP. 

    /* Header DARF */
    PUT STREAM str_3 "A1"          
         FILL(" ",40)  FORMAT "X(40)" 
         aux_nrdbanco  FORMAT "999" 
         aux_nmbandar  FORMAT "x(20)"
         aux_dtmvtolt  FORMAT "x(08)" 
         aux_nrseqdar  FORMAT "999999"
         FILL(" ",141) FORMAT "X(141)"
         SKIP.
    
    /************************************************************************/
    /******************************** REGISTRO B ****************************/
    /************************************************************************/

    ASSIGN aux_nrseqatr = 0.
           
    aux_cdempres = "".

    /*** Debito automático Sicredi ***/ 
    FOR EACH crapatr WHERE crapatr.cdcooper = crapcop.cdcooper AND
            			   crapatr.cdhistor = 1019             AND  
                          (crapatr.dtiniatr = glb_dtmvtolt     OR
                           crapatr.dtfimatr = glb_dtmvtolt     OR
                           crapatr.dtinisus = glb_dtmvtolt     OR
                           /* final de semana e feriados */
                          (crapatr.dtfimsus > glb_dtmvtoan     AND
                           crapatr.dtfimsus <= glb_dtmvtolt))
                           NO-LOCK:
        
        IF  crapatr.dtfimatr = glb_dtmvtolt  OR
            crapatr.dtinisus = glb_dtmvtolt  THEN
            ASSIGN aux_cdmovmto = 1.   /** cancelamento **/
        ELSE
            ASSIGN aux_cdmovmto = 2. /** inclusao **/

        IF  aux_cdmovmto = 1 THEN
            IF  crapatr.dtfimatr = glb_dtmvtolt THEN
                /* Quando estiver cancelando a autorizacao */
            ASSIGN aux_dtmvtolt_atr = STRING(YEAR(crapatr.dtfimatr),"9999") +
                                      STRING(MONTH(crapatr.dtfimatr),"99")  +
                                      STRING(DAY(crapatr.dtfimatr),"99").
        ELSE
                /* Quando estiver suspendendo a autorizacao */
                ASSIGN aux_dtmvtolt_atr = STRING(YEAR(crapatr.dtinisus),"9999") +
                                          STRING(MONTH(crapatr.dtinisus),"99")  +
                                          STRING(DAY(crapatr.dtinisus),"99").
        ELSE
            IF  crapatr.dtfimsus = glb_dtmvtolt THEN
                /* Quando estiver cancelando a suspensao da autorizacao */
                ASSIGN aux_dtmvtolt_atr = STRING(YEAR(glb_dtmvtolt),"9999") +
                                          STRING(MONTH(glb_dtmvtolt),"99")  +
                                          STRING(DAY(glb_dtmvtolt),"99").
            ELSE 
                /* Quando estiver autorizando o debito */
            ASSIGN aux_dtmvtolt_atr = STRING(YEAR(crapatr.dtiniatr),"9999") +
                                      STRING(MONTH(crapatr.dtiniatr),"99")  +
                                      STRING(DAY(crapatr.dtiniatr),"99").

        FIND FIRST crapass WHERE crapass.cdcooper = crapatr.cdcooper AND
                                 crapass.nrdconta = crapatr.nrdconta
                                 NO-LOCK NO-ERROR.

        IF  NOT AVAIL crapass THEN
            ASSIGN aux_cdagenci = "000"
                   glb_cdcritic = 15.
        ELSE
            ASSIGN aux_cdagenci = STRING(crapass.cdagenci,"999").

        FIND crapscn WHERE crapscn.cdempres = crapatr.cdempres 
                           NO-LOCK NO-ERROR NO-WAIT.

        IF  NOT AVAIL crapscn THEN
            NEXT.

        ASSIGN aux_flgvazio = FALSE.

        /* Se for o convenio 045 - 14 BRT CELULAR - FEBRABAN, devemos completar com um hifen
           para completar 12 posicoes ex:(40151016407-) chamado 453337 */
        IF  crapatr.cdempres = "045" THEN
            DO:
                IF  LENGTH(STRING(crapatr.cdrefere)) = 11 THEN
                    aux_cdrefere = STRING(crapatr.cdrefere) + "-" + FILL(" ",13).
                ELSE 
                    RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                                 INPUT 25,
                                                 INPUT crapscn.tppreenc,
                                                 INPUT crapatr.cdrefere,
                                                OUTPUT aux_cdrefere).
            END.
        ELSE 
        /* retornar o valor formatado corretamente */
        RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                     INPUT 25,
                                     INPUT crapscn.tppreenc,
                                     INPUT crapatr.cdrefere,
                                    OUTPUT aux_cdrefere). 

         /* retornar o valor formatado corretamente */
        RUN retorna_valor_formatado (INPUT 10,
                                     INPUT 10,
                                     INPUT 0,
                                     INPUT crapscn.cdempres,
                                    OUTPUT aux_cdempres). 

        

        ASSIGN aux_dslinreg = "B" +
                              SUBSTRING(aux_cdrefere,1,25)      +     
                              STRING(crapcop.cdagesic,"9999")   +
                              STRING(crapass.nrctacns,"999999") +
                              FILL(" ", 8)                      +
                              STRING(aux_dtmvtolt_atr)          +
	                          FILL(" ", 93)                     +
                              SUBSTRING(aux_cdagenci,2,2)       +
                              aux_cdempres                      +
                              STRING(aux_cdmovmto)              +
                              FILL(" ",2).  

        PUT STREAM str_2 aux_dslinreg FORMAT "x(160)" SKIP.

        ASSIGN aux_nrseqatr = aux_nrseqatr + 1.

        CREATE tt-rel674-cadastro.       
        ASSIGN tt-rel674-cadastro.cdcooper = crapatr.cdcooper
               tt-rel674-cadastro.nrdconta = crapatr.nrdconta
               tt-rel674-cadastro.cdrefere = crapatr.cdrefere
               tt-rel674-cadastro.dsnomcnv = crapscn.dsnomcnv
               tt-rel674-cadastro.cdagenci = crapass.cdagenci
               tt-rel674-cadastro.dsmovmto = IF  aux_cdmovmto = 1 THEN
                                                 "Exclusao"
                                             ELSE "Inclusao".

    END.

    /************************************************************************/
    /******************************** REGISTRO F ****************************/
    /************************************************************************/

    ASSIGN aux_nrseqlcm = 0
           aux_vlfatlcm = 0
           glb_dscritic = "".

    /* craplcm para consorcios */
    FOR EACH craplcm WHERE craplcm.cdcooper = crapcop.cdcooper AND
                           craplcm.dtmvtolt = glb_dtmvtolt     AND
                          (craplcm.cdhistor = 1230             OR
                           craplcm.cdhistor = 1231             OR
                           craplcm.cdhistor = 1232             OR
                           craplcm.cdhistor = 1233             OR
                           craplcm.cdhistor = 1234             OR
                           craplcm.cdhistor = 1019)
                           NO-LOCK:

        IF  craplcm.cdhistor <> 1019 THEN
            DO:
                CASE craplcm.cdhistor:
                     WHEN 1230 THEN
                          ASSIGN aux_tpconsor = 1.
                     WHEN 1231 THEN
                          ASSIGN aux_tpconsor = 2.
                     WHEN 1232 THEN
                          ASSIGN aux_tpconsor = 3.
                     WHEN 1233 THEN
                          ASSIGN aux_tpconsor = 4.
                     WHEN 1234 THEN
                          ASSIGN aux_tpconsor = 5.
                END CASE.
            END.

        /* converte data para AAAA/MM/DD */
        ASSIGN aux_dtmvtolt_lcm = STRING(YEAR(craplcm.dtmvtolt),"9999") +
                                  STRING(MONTH(craplcm.dtmvtolt),"99")  +
                                  STRING(DAY(craplcm.dtmvtolt),"99").
                     
        FIND FIRST crapass WHERE crapass.cdcooper = craplcm.cdcooper AND
                                 crapass.nrdconta = craplcm.nrdconta 
                                 NO-LOCK NO-ERROR NO-WAIT.
                              
        IF  AVAIL crapass THEN
            ASSIGN aux_cdagenci = STRING(crapass.cdagenci,"999")
                   aux_nrctacns = crapass.nrctacns.
        ELSE
            ASSIGN aux_cdagenci = "000"
                   aux_nrctacns = 0.
                   
        FIND FIRST craplau WHERE craplau.cdcooper = craplcm.cdcooper AND
                                 craplau.dtdebito = craplcm.dtmvtolt AND
                                 craplau.cdhistor = craplcm.cdhistor AND
                                 craplau.nrdconta = craplcm.nrdconta AND
                                 craplau.nrdocmto = craplcm.nrdocmto 
                                 NO-LOCK NO-ERROR. 
                         
        IF  AVAIL craplau THEN
            DO:
                IF  craplau.cdseqtel <> "" THEN
                    ASSIGN aux_cdseqtel = SUBSTR(craplau.cdseqtel,1,60).
                ELSE
                    ASSIGN aux_cdseqtel = FILL(" ",60).
                
                IF  craplau.cdempres <> "" THEN
                    ASSIGN aux_emprelau = craplau.cdempres.
                ELSE
                    ASSIGN aux_emprelau = "0".
            END.
        ELSE
            DO:
                /* Se nao existir empresa cadastrada para o lacanemto nao permite
                   seguir normalmente o programa, gera critica no log e no relatorio */
                glb_cdcritic = 501.
                RUN fontes/critic.p.
                UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")              +
                " - " + STRING(TIME,"HH:MM:SS") + " - "   + glb_cdprogra + "' --> '" +
                glb_dscritic + 
                " Cooperativa: " + STRING(craplcm.cdcooper)        +
                " Conta: " + STRING(craplcm.nrdconta,"zzzz,zzz,9") +
                " Historico: " + STRING(craplcm.cdhistor)          +
                " Documento: " + STRING(craplcm.nrdocmto)          +
                " >> log/prccon.log").

                IF  craplcm.cdhistor <> 1019 THEN
                    DO:
                        aux_nrctrato = STRING(craplcm.nrdocmto,"9999999999999999999999").
                                                                
                        /*  tabela referente aos consorcios sicredi */
                        FOR EACH crapcns WHERE 
                                 crapcns.cdcooper = crapcop.cdcooper              AND
                                 crapcns.tpconsor = aux_tpconsor                  AND
                                 crapcns.nrdconta = craplcm.nrdconta              AND
                                 crapcns.nrctrato = DEC(SUBSTR(aux_nrctrato,1,8)) 
                                 NO-LOCK.
                        
                            /* cria temp-table para crrl664 */
                            CREATE tt-rel664.
                            ASSIGN tt-rel664.nrdconta = crapcns.nrdconta
                                   tt-rel664.nrcotcns = crapcns.nrcotcns
                                   tt-rel664.qtparcns = crapcns.qtparcns
                                   tt-rel664.vlrcarta = crapcns.vlrcarta
                                   tt-rel664.vlparcns = crapcns.vlparcns
                                   tt-rel664.nrctacns = crapcns.nrctacns
                                   tt-rel664.cdcooper = crapcns.cdcooper
                                   tt-rel664.nrdocmto = craplcm.nrdocmto
                                   tt-rel664.cdagenci = INT(aux_cdagenci)
                                   tt-rel664.tpconsor = crapcns.tpconsor
                                   tt-rel664.nmconsor = crapcns.nmconsor
                                   tt-rel664.nrdgrupo = crapcns.nrdgrupo
                                   tt-rel664.dscritic = glb_dscritic.
                        
                            /*** busca tipo de consorcio ***/
                            CASE crapcns.tpconsor:
                                WHEN 1 THEN
                                     ASSIGN tt-rel664.dsconsor = "MOTO".
                                WHEN 2 THEN
                                     ASSIGN tt-rel664.dsconsor = "AUTO".
                                WHEN 3 THEN
                                     ASSIGN tt-rel664.dsconsor = "PESADOS".
                                WHEN 4 THEN
                                     ASSIGN tt-rel664.dsconsor = "IMOVEIS".
                                WHEN 5 THEN
                                     ASSIGN tt-rel664.dsconsor = "SERVICOS".
                            END CASE.
                        END.
                    END.
                ELSE
                    DO:
                        CREATE tt-rel674-lancamentos.
                        ASSIGN tt-rel674-lancamentos.cdcooper = craplcm.cdcooper
                               tt-rel674-lancamentos.cdagenci = INT(aux_cdagenci)
                               tt-rel674-lancamentos.nrdconta = craplcm.nrdconta
                               tt-rel674-lancamentos.nrctacns = aux_nrctacns
                               tt-rel674-lancamentos.dsnomcnv = ""
                               tt-rel674-lancamentos.nrdocmto = craplcm.nrdocmto
                               tt-rel674-lancamentos.vllanmto = craplcm.vllanmto
                               tt-rel674-lancamentos.dscritic = glb_dscritic.
                    END.

                NEXT.
            END.

        /* Consorcios continuam utilizando o nrdocmto, a regra nao foi alterada */
        IF craplau.cdhistor <> 1019 THEN                         
           ASSIGN aux_nrcrcard = craplau.nrdocmto.        

        /* retornar o valor do documento formatado corretamente */
        IF  craplcm.cdhistor = 1019 THEN
            DO:
                /* Verificar se referencia(novas) ainda existe */
                FIND crapatr WHERE
                     crapatr.cdcooper = crapcop.cdcooper AND
                     crapatr.nrdconta = craplcm.nrdconta AND             
                     crapatr.cdhistor = craplau.cdhistor AND
                     crapatr.cdrefere = craplau.nrcrcard  
                     NO-LOCK NO-ERROR.
                    
                    IF  NOT AVAILABLE crapatr THEN
                        DO:
                            /* Verificar referencias antigas */
                              FIND crapatr WHERE 
                                   crapatr.cdcooper = crapcop.cdcooper AND
                                   crapatr.nrdconta = craplcm.nrdconta AND
                                   crapatr.cdhistor = craplau.cdhistor AND
                                   crapatr.cdrefere = craplau.nrdocmto 
                                   NO-LOCK NO-ERROR.
                     
                          IF  NOT AVAILABLE crapatr THEN
                              DO:
                                  glb_cdcritic = 453.
                                  RUN fontes/critic.p.
                                  UNIX SILENT
                                       VALUE("echo " + STRING(TODAY,"99/99/9999") + " " 
                                       + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " Conta = " +
                                       STRING(craplcm.nrdconta,"zzzz,zz9,9") +
                                       " Documento = " + STRING(craplcm.nrdocmto) +
                                       " >> log/prccon.log").
                                  NEXT.
                              END.
                        END.   

                ASSIGN aux_nrcrcard = crapatr.cdrefere. 
            
                FIND crapscn WHERE crapscn.cdempres = aux_emprelau 
                                   NO-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crapscn THEN
                    DO: /* Se nao existir empresa cadastrada para o lacanemto nao permite
                           seguir normalmente o programa, gera critica no log e no relatorio */
                        glb_cdcritic = 563.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")              +
                        " - " + STRING(TIME,"HH:MM:SS") + " - "   + glb_cdprogra + "' --> '" +
                        glb_dscritic + 
                        " Cooperativa: " + STRING(craplcm.cdcooper)        +
                        " Conta: " + STRING(craplcm.nrdconta,"zzzz,zzz,9") +
                        " Historico: " + STRING(craplcm.cdhistor)          +
                        " Documento: " + STRING(craplcm.nrdocmto)          +
                        " >> log/prccon.log").

                        CREATE tt-rel674-lancamentos.
                        ASSIGN tt-rel674-lancamentos.cdcooper = craplcm.cdcooper
                               tt-rel674-lancamentos.cdagenci = INT(aux_cdagenci)
                               tt-rel674-lancamentos.nrdconta = craplcm.nrdconta
                               tt-rel674-lancamentos.nrctacns = aux_nrctacns
                               tt-rel674-lancamentos.dsnomcnv = ""
                               tt-rel674-lancamentos.nrdocmto = craplcm.nrdocmto
                               tt-rel674-lancamentos.vllanmto = craplcm.vllanmto
                               tt-rel674-lancamentos.dscritic = glb_dscritic.
                        NEXT.

                    END.
               
                               
                /***** Se for lançamento de conta incorporada aonde o agendamento ocorreu antes 
                da incorporaçao, ou seja, na cooperativa anterior, nao será gerado o retorno na 
                cooperativa em que ocorreu o débito. O retorno ocorrerá através da cooperativa 
                que recebeu o agendamento. *****/
                FIND FIRST craptco WHERE craptco.cdcooper = crapcop.cdcooper AND
                                         craptco.nrdconta = craplcm.nrdconta AND
                                         craptco.flgativo = TRUE 
                                         NO-LOCK NO-ERROR.

                IF AVAIL craptco THEN
                   DO:
                      IF  craplau.cdcritic = 951 THEN
                          DO:
                              CREATE tt-rel674-lancamentos.
                              ASSIGN tt-rel674-lancamentos.cdcooper = craplcm.cdcooper
                                     tt-rel674-lancamentos.cdagenci = INT(aux_cdagenci)
                                     tt-rel674-lancamentos.nrdconta = craplcm.nrdconta
                                     tt-rel674-lancamentos.nrctacns = aux_nrctacns
                                     tt-rel674-lancamentos.dsnomcnv = crapscn.dsnomcnv + " - Conta Migrada"
                                     tt-rel674-lancamentos.nrdocmto = craplcm.nrdocmto
                                     tt-rel674-lancamentos.vllanmto = craplcm.vllanmto.
                              NEXT.
                           END.   
                    END.
               
                /* Se for o convenio 045 - 14 BRT CELULAR - FEBRABAN, devemos completar com um hifen
                   para completar 12 posicoes ex:(40151016407-) chamado 453337 */
                IF  crapscn.cdempres = "045" THEN
                    DO:
                        IF  LENGTH(STRING(aux_nrcrcard)) = 11 THEN
                            aux_cdrefere = STRING(aux_nrcrcard) + "-" + FILL(" ",13).
                        ELSE 
                            RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                                         INPUT 25,
                                                         INPUT crapscn.tppreenc,
                                                         INPUT aux_nrcrcard,
                                                        OUTPUT aux_cdrefere).
                    END.
                ELSE 
                RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                             INPUT 25,
                                             INPUT crapscn.tppreenc,
                                             INPUT aux_nrcrcard,
                                            OUTPUT aux_cdrefere).
            END.
        ELSE 
            ASSIGN aux_cdrefere = STRING(aux_nrcrcard,"9999999999999999999999") 
                                  + FILL(" ",3).

        /* formatar codigo da empresa */
        RUN retorna_valor_formatado (INPUT 10, /* max. de digitos na variavel */                                 
                                     INPUT 10, /* quantidade max characteres a completar */ 
                                     INPUT 0,                        
                                     INPUT craplau.cdempres,         
                                    OUTPUT aux_cdempres).            

        /* Registro F referente aos consorcios SICREDI, lista antes de todos */
        ASSIGN aux_dslinreg = 
                    "F" +
                    SUBSTRING(aux_cdrefere,1,25)                     +
                    STRING(crapcop.cdagesic,"9999")                  +
                    STRING(aux_nrctacns,"999999")                    +
                    FILL(" ", 8)                                     +
                    STRING(aux_dtmvtolt_lcm, "x(8)")                 +
                    STRING(craplcm.vllanmto * 100,"999999999999999") +
                    "00"                                             +
                    aux_cdseqtel                                     +
                    FILL(" ", 16)                                    +
                    SUBSTRING(aux_cdagenci,2,2)                      +
                    aux_cdempres                                     +
                    "0".

        PUT STREAM str_2 aux_dslinreg FORMAT "x(160)" SKIP.

        IF  craplcm.cdhistor <> 1019 THEN
            DO:
                aux_nrctrato = STRING(aux_nrcrcard,"9999999999999999999999").
                                                        
                /*  tabela referente aos consorcios sicredi */
                FOR EACH crapcns WHERE 
                         crapcns.cdcooper = crapcop.cdcooper              AND
                         crapcns.tpconsor = aux_tpconsor                  AND
                         crapcns.nrdconta = craplcm.nrdconta              AND
                         crapcns.nrctrato = DEC(SUBSTR(aux_nrctrato,1,8)) 
                         NO-LOCK.
                
                    /* cria temp-table para crrl664 */
                    CREATE tt-rel664.
                    ASSIGN tt-rel664.nrdconta = crapcns.nrdconta
                           tt-rel664.nrcotcns = crapcns.nrcotcns
                           tt-rel664.qtparcns = crapcns.qtparcns
                           tt-rel664.vlrcarta = crapcns.vlrcarta
                           tt-rel664.vlparcns = crapcns.vlparcns
                           tt-rel664.nrctacns = crapcns.nrctacns
                           tt-rel664.cdcooper = crapcns.cdcooper
                           tt-rel664.nrdocmto = craplcm.nrdocmto
                           tt-rel664.cdagenci = INT(aux_cdagenci)
                           tt-rel664.tpconsor = crapcns.tpconsor
                           tt-rel664.nmconsor = crapcns.nmconsor
                           tt-rel664.nrdgrupo = crapcns.nrdgrupo
                           tt-rel664.dscritic = "".
                
                    /*** busca tipo de consorcio ***/
                    CASE crapcns.tpconsor:
                        WHEN 1 THEN
                             ASSIGN tt-rel664.dsconsor = "MOTO".
                        WHEN 2 THEN
                             ASSIGN tt-rel664.dsconsor = "AUTO".
                        WHEN 3 THEN
                             ASSIGN tt-rel664.dsconsor = "PESADOS".
                        WHEN 4 THEN
                             ASSIGN tt-rel664.dsconsor = "IMOVEIS".
                        WHEN 5 THEN
                             ASSIGN tt-rel664.dsconsor = "SERVICOS".
                    END CASE.                                                           
                
                END.
            END.
        ELSE /* somente para historico 1019 */
            DO: 
                CREATE tt-rel674-lancamentos.
                ASSIGN tt-rel674-lancamentos.cdcooper = craplcm.cdcooper
                       tt-rel674-lancamentos.cdagenci = INT(aux_cdagenci)
                       tt-rel674-lancamentos.nrdconta = craplcm.nrdconta
                       tt-rel674-lancamentos.nrctacns = aux_nrctacns
                       tt-rel674-lancamentos.dsnomcnv = crapscn.dsnomcnv
                       tt-rel674-lancamentos.nrdocmto = craplcm.nrdocmto
                       tt-rel674-lancamentos.vllanmto = craplcm.vllanmto
                       tt-rel674-lancamentos.dscritic = "".
            END.

        /* Somatoria dos registros e valor de lancamento 
           Nao deve contabilizar se ocorreu critica */
        ASSIGN aux_nrseqlcm = aux_nrseqlcm + 1
               aux_vlfatlcm = aux_vlfatlcm + craplcm.vllanmto
               aux_flgvazio = FALSE.

    END. /* fim do craplcm */

    ASSIGN aux_nrseqndb = 0
           aux_vlfatndb = 0.

    FOR EACH crapndb WHERE crapndb.cdcooper = crapcop.cdcooper AND
                           crapndb.dtmvtolt = glb_dtmvtolt     AND
                          (crapndb.cdhistor = 1230             OR   
                           crapndb.cdhistor = 1231             OR  
                           crapndb.cdhistor = 1232             OR  
                           crapndb.cdhistor = 1233             OR  
                           crapndb.cdhistor = 1234             OR
                           crapndb.cdhistor = 1019)            
                           NO-LOCK:

        ASSIGN aux_dslinreg = STRING(SUBSTR(crapndb.dstexarq,1,160),"x(160)").

        IF  crapndb.cdhistor <> 1019 THEN
            DO:
                FIND FIRST crapcns WHERE 
                           crapcns.cdcooper = crapcop.cdcooper              AND
                           crapcns.nrctrato = INT(SUBSTR(aux_dslinreg,2,8)) AND
                           crapcns.nrcpfcgc = DEC(SUBSTR(aux_dslinreg,10,14))
                           NO-LOCK NO-ERROR.

                IF  AVAIL crapcns THEN
                    ASSIGN aux_nmconsor = crapcns.nmconsor
                           aux_nrdgrupo = crapcns.nrdgrupo.
                ELSE
                    ASSIGN aux_nmconsor = ""
                           aux_nrdgrupo = 0.

                CREATE tt-rel664.
                ASSIGN tt-rel664.cdagenci = INT(SUBSTR(aux_dslinreg,146,2))
                       tt-rel664.nrdconta = crapndb.nrdconta
                       tt-rel664.nrctacns = DEC(SUBSTR(aux_dslinreg,31,7))
                       tt-rel664.nmconsor = aux_nmconsor
                       tt-rel664.nrdgrupo = aux_nrdgrupo
                       tt-rel664.vlparcns = (DEC(SUBSTR(aux_dslinreg,53,15)) 
                                                      / 100).

                IF  AVAIL crapcns THEN 
                    DO:
                        ASSIGN tt-rel664.nrcotcns = crapcns.nrcotcns.

                        CASE crapcns.tpconsor:
                            WHEN 1 THEN
                                 ASSIGN tt-rel664.dsconsor = "MOTO".
                            WHEN 2 THEN
                                 ASSIGN tt-rel664.dsconsor = "AUTO".
                            WHEN 3 THEN
                                 ASSIGN tt-rel664.dsconsor = "PESADOS".
                            WHEN 4 THEN
                                 ASSIGN tt-rel664.dsconsor = "IMOVEIS".
                            WHEN 5 THEN
                                 ASSIGN tt-rel664.dsconsor = "SERVICOS".
                        END CASE.

                    END.
                ELSE 
                    ASSIGN tt-rel664.nrcotcns = 0
                           tt-rel664.dsconsor = "".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "15" THEN
                    ASSIGN tt-rel664.dscritic = "15 - Conta corrente invalida".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "30" THEN
                    ASSIGN tt-rel664.dscritic = "30 - Sem contrato de debito".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "01" THEN
                    ASSIGN tt-rel664.dscritic = "01 - Insuficiencia de fundos".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "97" THEN
                    ASSIGN tt-rel664.dscritic = "97 - Cacelamento - Nao encontrado".

                IF  SUBSTR(aux_dslinreg,68,2) = "99" THEN
                    ASSIGN tt-rel664.dscritic = "99 - Cancelado conforme solic.".
                    
                IF  SUBSTR(aux_dslinreg,68,2) = "04" THEN
                    ASSIGN tt-rel664.dscritic = "04 - Outras restricoes".
                    
                IF  SUBSTR(aux_dslinreg,68,2) = "05" THEN
                    ASSIGN tt-rel664.dscritic = "05 - Valor debito excede limite aprovado".    
            END.
        ELSE
            DO:
                FIND FIRST crapscn WHERE crapscn.cdempres = TRIM(SUBSTR(aux_dslinreg,148,10))
                                         NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapscn THEN
                    DO:
                        glb_cdcritic = 563.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") +
                        " - " + STRING(TIME,"HH:MM:SS") + " - "                 + 
                        glb_cdprogra + "' --> '" + glb_dscritic                 + 
                        " Cooperativa: " + STRING(crapndb.cdcooper)             +
                        " Conta: " + STRING(crapndb.nrdconta,"zzzz,zzz,9")      +
                        " Historico: " + STRING(crapndb.cdhistor)               +
                        " Documento: " + STRING(SUBSTR(aux_dslinreg,2,25))      +
                        " Convenio: " + TRIM(SUBSTR(aux_dslinreg,148,10))       +
                        " >> log/prccon.log").

                        aux_dsnomcnv = "".
                    END.
                ELSE
                    aux_dsnomcnv = crapscn.dsnomcnv.


                /***** Se for lançamento de conta incorporada aonde o agendamento ocorreu antes 
                da incorporaçao, ou seja, na cooperativa anterior, nao será gerado o retorno na 
                cooperativa em que ocorreu  a crítica. O retorno ocorrerá através da cooperativa 
                que recebeu o agendamento. *****/
                FIND FIRST craptco WHERE craptco.cdcooper = crapcop.cdcooper AND
                                         craptco.nrdconta = crapndb.nrdconta AND
                                         craptco.flgativo = TRUE 
                                         NO-LOCK NO-ERROR.

                IF AVAIL craptco THEN
                   DO:       
                        /*** Nao sera utilizado o cdcritic 951 da craplau para esse caso porque ele é 
                             substituido quando gravado no crapndb da cooperativa nova. ****/            
                        FIND FIRST craplau WHERE  craplau.cdcooper = craptco.cdcopant                 AND      
                                                  craplau.nrdconta = craptco.nrctaant                 AND 
                                                  craplau.cdhistor = crapndb.cdhistor                 AND
                                                  craplau.nrdocmto = DECI(SUBSTR(aux_dslinreg,2,25))  AND
                                                  craplau.dtmvtopg  > glb_dtmvtoan                    AND
                                                  craplau.dtmvtopg <= glb_dtmvtolt                    AND
                                                  craplau.insitlau = 1 NO-LOCK NO-ERROR.
                   
                        IF  AVAIL craplau THEN
                            DO:
                                 CREATE tt-rel674-lancamentos.
                                 ASSIGN tt-rel674-lancamentos.cdcooper = crapndb.cdcooper
                                        tt-rel674-lancamentos.cdagenci = INT(SUBSTR(aux_dslinreg,146,2))
                                        tt-rel674-lancamentos.nrdconta = crapndb.nrdconta
                                        tt-rel674-lancamentos.nrctacns = DEC(SUBSTR(aux_dslinreg,31,7))
                                        tt-rel674-lancamentos.dsnomcnv = aux_dsnomcnv
                                        tt-rel674-lancamentos.vllanmto = (DEC(SUBSTR(aux_dslinreg,53,15)) / 100).
                                        tt-rel674-lancamentos.dscritic = "Conta Migrada".
                                 NEXT.
                            END.
                   END. 


                CREATE tt-rel674-lancamentos.
                ASSIGN tt-rel674-lancamentos.cdcooper = crapndb.cdcooper
                       tt-rel674-lancamentos.cdagenci = INT(SUBSTR(aux_dslinreg,146,2))
                       tt-rel674-lancamentos.nrdconta = crapndb.nrdconta
                       tt-rel674-lancamentos.nrctacns = DEC(SUBSTR(aux_dslinreg,31,7))
                       tt-rel674-lancamentos.dsnomcnv = aux_dsnomcnv
                       tt-rel674-lancamentos.vllanmto = (DEC(SUBSTR(aux_dslinreg,53,15)) / 100).
                        
                IF  SUBSTR(aux_dslinreg,68,2) = "15" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "15 - conta corrente invalida".
                                                         
                IF  SUBSTR(aux_dslinreg,68,2) = "30" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "30" +
                           " - Sem contrato de debito automatico".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "01" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "01 - Insuficiencia de fundos".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "97" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "97 - Cacelamento - Nao encontrato".

                IF  SUBSTR(aux_dslinreg,68,2) = "99" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "99 - Cancelado conforme solicitacao".

                IF  SUBSTR(aux_dslinreg,68,2) = "04" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "04 - Outras restricoes".
                    
                IF  SUBSTR(aux_dslinreg,68,2) = "05" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "05 - Valor debito excede limite aprovado".    

                ASSIGN tt-rel674-lancamentos.nrdocmto = DECI(REPLACE(SUBSTR(aux_dslinreg,2,25),"-","")) NO-ERROR.
            END.

        PUT STREAM str_2 aux_dslinreg FORMAT "x(160)" SKIP.
        
        ASSIGN aux_flgvazio = FALSE
               aux_nrseqndb = aux_nrseqndb + 1
               aux_vllanmto = DECIMAL(SUBSTRING(crapndb.dstexarq,53,15))
               aux_vllanmto = aux_vllanmto / 100
               aux_vlfatndb = aux_vlfatndb + aux_vllanmto.

    END. /*fim do crapndb*/



    /**** Leitura dos agendamentos importados para as contas incorporadas antes da data da incorporaçao 
          com data de débito para depois da incorporaçao, aonde o lançamento ocorre na cooperativa nova 
          e o retorno deverá ser feito na cooperativa anterior. O insitlau lido será 1 porque na cooperativa 
          anterior o agendamento ficará pendente e nao será atualizado por nao haver processo.  ****/
    FOR EACH craplau WHERE  craplau.cdcooper = crapcop.cdcooper AND     
                            craplau.dtmvtopg >  glb_dtmvtoan    AND  
		                  	    craplau.dtmvtopg <= glb_dtmvtolt    AND
			                      craplau.insitlau = 1		            AND
                            craplau.cdhistor = 1019             NO-LOCK:  
             

        FIND FIRST craptco WHERE craptco.cdcopant = craplau.cdcooper AND
                                 craptco.nrctaant = craplau.nrdconta AND
              	                 craptco.flgativo = TRUE 
				                         NO-LOCK NO-ERROR.

        IF  NOT AVAIL craptco THEN          
            NEXT.
           
        /*** Leitura principal parte da cooperativa antiga, se nao tiver o 
             agendamento na cooperativa atual ocorre NEXT ***/
        FIND crablau WHERE crablau.cdcooper = craptco.cdcooper  AND    
                           crablau.nrdconta = craptco.nrdconta  AND
                           crablau.dtdebito = glb_dtmvtolt      AND
                           crablau.dtmvtolt = craplau.dtmvtolt  AND  
                           crablau.nrdocmto = craplau.nrdocmto  AND
                           crablau.cdhistor = craplau.cdhistor 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crablau THEN
            NEXT.

        /* Verificar se referencia(novas) ainda existe */
        FIND crapatr WHERE
             crapatr.cdcooper = crapcop.cdcooper AND
             crapatr.nrdconta = craplcm.nrdconta AND             
             crapatr.cdhistor = craplau.cdhistor AND
             crapatr.cdrefere = craplau.nrcrcard  
             NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE crapatr THEN
                DO:
                    /* Verificar referencias antigas */
                      FIND crapatr WHERE 
                           crapatr.cdcooper = crapcop.cdcooper AND
                           crapatr.nrdconta = craplcm.nrdconta AND
                           crapatr.cdhistor = craplau.cdhistor AND
                           crapatr.cdrefere = craplau.nrdocmto 
                           NO-LOCK NO-ERROR.
             
                  IF  NOT AVAILABLE crapatr THEN
                      DO:
                          glb_cdcritic = 453.
                          RUN fontes/critic.p.
                          UNIX SILENT
                               VALUE("echo " + STRING(TODAY,"99/99/9999") + " " 
                               + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " Conta = " +
                               STRING(craplcm.nrdconta,"zzzz,zz9,9") +
                               " Documento = " + STRING(craplcm.nrdocmto) +
                               " >> log/prccon.log").
                          NEXT.
                      END.
                END.   

        ASSIGN aux_nrcrcard = crapatr.cdrefere. 

        FIND FIRST craplcm WHERE craplcm.cdcooper = craptco.cdcooper AND
                                 craplcm.dtmvtolt = glb_dtmvtolt     AND
                                 craplcm.cdhistor = craplau.cdhistor AND
                                 craplcm.nrdconta = craptco.nrdconta AND
                                 craplcm.nrdocmto = craplau.nrdocmto 
                                 NO-LOCK NO-ERROR.  
        IF AVAIL craplcm THEN
    	     DO:
              ASSIGN aux_dtmvtolt_lcm = STRING(YEAR(craplcm.dtmvtolt),"9999") +
                                        STRING(MONTH(craplcm.dtmvtolt),"99")  +
                                        STRING(DAY(craplcm.dtmvtolt),"99").
                                 
              FIND FIRST crapass WHERE crapass.cdcooper = craptco.cdcopant AND
                                       crapass.nrdconta = craptco.nrctaant 
                                       NO-LOCK NO-ERROR NO-WAIT.
                                            
              IF  AVAIL crapass THEN
                  ASSIGN aux_cdagenci = STRING(crapass.cdagenci,"999")
                         aux_nrctacns = crapass.nrctacns.
              ELSE
                  ASSIGN aux_cdagenci = "000"
                               aux_nrctacns = 0.


              IF  craplau.cdseqtel <> "" THEN
                  ASSIGN aux_cdseqtel = SUBSTR(craplau.cdseqtel,1,60).
              ELSE
                  ASSIGN aux_cdseqtel = FILL(" ",60).
              
              IF  craplau.cdempres <> "" THEN
                  ASSIGN aux_emprelau = craplau.cdempres.
              ELSE
                  ASSIGN aux_emprelau = "0".

                            
              FIND crapscn WHERE crapscn.cdempres = aux_emprelau 
                                 NO-LOCK NO-ERROR NO-WAIT.

              IF  NOT AVAIL crapscn THEN
                  DO: /* Se nao existir empresa cadastrada para o lacanemto nao permite
                         seguir normalmente o programa, gera critica no log e no relatorio */
                      glb_cdcritic = 563.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")              +
                      " - " + STRING(TIME,"HH:MM:SS") + " - "   + glb_cdprogra + "' --> '" +
                      glb_dscritic + 
                      " Cooperativa: " + STRING(craplau.cdcooper)        +
                      " Conta: " + STRING(craplau.nrdconta,"zzzz,zzz,9") +
                      " Historico: " + STRING(craplau.cdhistor)          +
                      " Documento: " + STRING(craplau.nrdocmto)          +
                      " >> log/prccon.log").

                      CREATE tt-rel674-lancamentos.
                      ASSIGN tt-rel674-lancamentos.cdcooper = craplau.cdcooper 
                             tt-rel674-lancamentos.cdagenci = INT(aux_cdagenci)
                             tt-rel674-lancamentos.nrdconta = craplau.nrdconta 
                             tt-rel674-lancamentos.nrctacns = aux_nrctacns
                             tt-rel674-lancamentos.dsnomcnv = ""
                             tt-rel674-lancamentos.nrdocmto = craplau.nrdocmto 
                             tt-rel674-lancamentos.vllanmto = craplau.vllanaut 
                             tt-rel674-lancamentos.dscritic = glb_dscritic.
                      NEXT.
                  END.



             /* Se for o convenio 045 - 14 BRT CELULAR - FEBRABAN, devemos completar com um hifen
                 para completar 12 posicoes ex:(40151016407-) chamado 453337 */
              IF  crapscn.cdempres = "045" THEN
                  DO:
                      IF  LENGTH(STRING(aux_nrcrcard)) = 11 THEN
                          aux_cdrefere = STRING(aux_nrcrcard) + "-" + FILL(" ",13).
                      ELSE 
                          RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                                       INPUT 25,
                                                       INPUT crapscn.tppreenc,
                                                       INPUT aux_nrcrcard,
                                                      OUTPUT aux_cdrefere).
                  END.
              ELSE 
              RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                           INPUT 25,
                                           INPUT crapscn.tppreenc,
                                           INPUT aux_nrcrcard,
                                          OUTPUT aux_cdrefere).

              /* formatar codigo da empresa */
              RUN retorna_valor_formatado (INPUT 10, /* max. de digitos na variavel */                                 
                                           INPUT 10, /* quantidade max characteres a completar */ 
                                           INPUT 0,                        
                                           INPUT craplau.cdempres,         
                                          OUTPUT aux_cdempres).           


             /* Registro F referente aos consorcios SICREDI, lista antes de todos */
              ASSIGN aux_dslinreg = 
                          "F" +
                          SUBSTRING(aux_cdrefere,1,25)                     +
                          STRING(crapcop.cdagesic,"9999")                  +
                          STRING(aux_nrctacns,"999999")                    +
                          FILL(" ", 8)                                     +
                          STRING(aux_dtmvtolt_lcm, "x(8)")                 +
                          STRING(craplcm.vllanmto * 100,"999999999999999") +
                          "00"                                             +
                          aux_cdseqtel                                     +
                          FILL(" ", 16)                                    +
                          SUBSTRING(aux_cdagenci,2,2)                      +
                          aux_cdempres                                     +
                          "0".

              PUT STREAM str_2 aux_dslinreg FORMAT "x(160)" SKIP.


              CREATE tt-rel674-lancamentos.
              ASSIGN tt-rel674-lancamentos.cdcooper = craplcm.cdcooper
                     tt-rel674-lancamentos.cdagenci = INT(aux_cdagenci)
                     tt-rel674-lancamentos.nrdconta = craplcm.nrdconta
                     tt-rel674-lancamentos.nrctacns = aux_nrctacns
                     tt-rel674-lancamentos.dsnomcnv = crapscn.dsnomcnv + " - Conta Migrada"
                     tt-rel674-lancamentos.nrdocmto = craplcm.nrdocmto
                     tt-rel674-lancamentos.vllanmto = craplcm.vllanmto.
           

              /* Somatoria dos registros e valor de lancamento 
                 Nao deve contabilizar se ocorreu critica */
              ASSIGN aux_nrseqlcm = aux_nrseqlcm + 1
                     aux_vlfatlcm = aux_vlfatlcm + craplcm.vllanmto
                     aux_flgvazio = FALSE.      

           END. /*** Fim IF craplcm ***/
      ELSE
           DO:   /*** Le rejeitados da cooperativa atual para ser lançado no arquivo da anterior ***/
                FIND FIRST crapndb WHERE crapndb.cdcooper = craptco.cdcooper and
                                         crapndb.nrdconta = craptco.nrdconta and
                                         crapndb.cdhistor = 1019		         and
                                         crapndb.dtmvtolt = glb_dtmvtolt 
                                         NO-LOCK NO-ERROR.

                IF   DECI(SUBSTR(crapndb.dstexarq,2,25)) <> aux_nrcrcard THEN 
                     NEXT.


                /*** Alterado agencia do registro da leitura do crapndb dentro do arquivo 
                     para que nao fosse necessario fazer tratamento na DEBSIC ***/
                ASSIGN aux_dslinreg = STRING(SUBSTR(crapndb.dstexarq,1,26),"x(26)") + 
                                      STRING(crapcop.cdagesic,"9999") + 
                                      STRING(SUBSTR(crapndb.dstexarq,31,130),"x(130)").

                FIND FIRST crapscn WHERE crapscn.cdempres = TRIM(SUBSTR(aux_dslinreg,148,10))
                                          NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapscn THEN
                    DO:
                        glb_cdcritic = 563.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999") +
                        " - " + STRING(TIME,"HH:MM:SS") + " - "                 + 
                        glb_cdprogra + "' --> '" + glb_dscritic                 + 
                        " Cooperativa: " + STRING(crapndb.cdcooper)             +
                        " Conta: " + STRING(crapndb.nrdconta,"zzzz,zzz,9")      +
                        " Historico: " + STRING(crapndb.cdhistor)               +
                        " Documento: " + STRING(SUBSTR(aux_dslinreg,2,25))      +
                        " Convenio: " + TRIM(SUBSTR(aux_dslinreg,148,10))       +
                        " >> log/prccon.log").

                        aux_dsnomcnv = "".
                    END.
                ELSE
                    aux_dsnomcnv = crapscn.dsnomcnv.

                CREATE tt-rel674-lancamentos.
                ASSIGN tt-rel674-lancamentos.cdcooper = crapndb.cdcooper
                       tt-rel674-lancamentos.cdagenci = INT(SUBSTR(aux_dslinreg,146,2))
                       tt-rel674-lancamentos.nrdconta = crapndb.nrdconta
                       tt-rel674-lancamentos.nrctacns = DEC(SUBSTR(aux_dslinreg,31,7))
                       tt-rel674-lancamentos.dsnomcnv = aux_dsnomcnv
                       tt-rel674-lancamentos.vllanmto = (DEC(SUBSTR(aux_dslinreg,53,15)) / 100).
                        
                IF  SUBSTR(aux_dslinreg,68,2) = "15" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "15 - conta corrente invalida".
                                                         
                IF  SUBSTR(aux_dslinreg,68,2) = "30" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "30" +
                           " - Sem contrato de debito automatico".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "01" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "01 - Insuficiencia de fundos".
                
                IF  SUBSTR(aux_dslinreg,68,2) = "97" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "97 - Cacelamento - Nao encontrato".

                IF  SUBSTR(aux_dslinreg,68,2) = "99" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "99 - Cancelado conforme solicitacao".

                IF  SUBSTR(aux_dslinreg,68,2) = "04" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "04 - Outras restricoes".
                    
                IF  SUBSTR(aux_dslinreg,68,2) = "05" THEN
                    ASSIGN tt-rel674-lancamentos.dscritic = "05 - Valor debito excede limite aprovado".    

                ASSIGN tt-rel674-lancamentos.dscritic = tt-rel674-lancamentos.dscritic + " - Conta migrada"
                       tt-rel674-lancamentos.nrdocmto = DECI(SUBSTR(aux_dslinreg,2,25)) NO-ERROR.
      

                PUT STREAM str_2 aux_dslinreg FORMAT "x(160)" SKIP.
                
                ASSIGN aux_flgvazio = FALSE
                       aux_nrseqndb = aux_nrseqndb + 1
                       aux_vllanmto = DECIMAL(SUBSTRING(crapndb.dstexarq,53,15))
                       aux_vllanmto = aux_vllanmto / 100
                       aux_vlfatndb = aux_vlfatndb + aux_vllanmto.
          
           END. /** Fim crapndb***/
    END. /*** Fim craplau ***/


    /* Para cada convenio */
    /* Convenios diferente de debito automatico */
    FOR EACH crapscn WHERE crapscn.dsoparre <> "E" AND crapscn.dtencemp = ? NO-LOCK.

        IF  glb_nrctares = 0 THEN
            DO:
                ASSIGN aux_dtproces = glb_dtmvtolt.

                /* Gera linha de arquivo para Exp. de Conv. para cada Cod. da 
                   Empresa cadastrado */
                IF  crapscn.cdempcon <> 0 THEN  
                    DO: 
                         DO aux_dtvencto = aux_dtanteri TO glb_dtmvtolt:

                             /* Procura algum registro de 5 dias atras até 
                                a data atual */
                             FIND FIRST craplft WHERE
                                        craplft.cdcooper = crapcop.cdcooper AND
                                        craplft.cdempcon = crapscn.cdempcon AND
                                STRING(craplft.cdsegmto) = crapscn.cdsegmto AND
                                        craplft.dtvencto = aux_dtvencto     AND
                                        craplft.insitfat = 1                AND
                                        craplft.tpfatura <> 2               AND
                                        craplft.cdhistor = 1154  /* SICREDI */
                                        NO-LOCK NO-ERROR.
                             
                             IF  AVAIL craplft THEN
                             DO:                             
                                 ASSIGN aux_dtproces = craplft.dtvencto.
                                 LEAVE.
                             END.

                         END. /* DO... TO */
                            
                        RUN gera-linha-arquivo-exp-conv (crapscn.cdempcon).

                    END.
                    
                IF  crapscn.cdempco2 <> 0 THEN
                    DO:
                        DO aux_dtvencto = aux_dtanteri TO glb_dtmvtolt:

                            /* Procura algum registro de 5 dias atras até a 
                               data atual */
                            FIND FIRST craplft WHERE
                                       craplft.cdcooper  = crapcop.cdcooper AND
                                       craplft.cdempcon  = crapscn.cdempco2 AND
                                STRING(craplft.cdsegmto) = crapscn.cdsegmto AND
                                       craplft.dtvencto  = aux_dtvencto     AND
                                       craplft.insitfat  = 1                AND
                                       craplft.tpfatura <> 2                AND
                                       craplft.cdhistor  = 1154  /* SICREDI */
                                       NO-LOCK NO-ERROR.
                            
                            IF  AVAIL craplft THEN
                            DO:                            
                                ASSIGN aux_dtproces = craplft.dtvencto.
                                LEAVE.
                            END.

                        END. /* DO... TO */

                        RUN gera-linha-arquivo-exp-conv (crapscn.cdempco2).

                    END. 
            END.

        IF (NOT aux_flgvazio) OR (glb_nrctares = 999)   THEN
            DO:
                /* Atualiza situação da fatura para cada Cod. da 
                   Empresa cadastrado */
                IF  crapscn.cdempcon <> 0 THEN
                    DO:
                        DO aux_dtvencto = aux_dtproces TO glb_dtmvtolt:

                            FOR EACH craplft WHERE 
                                     craplft.cdcooper  = crapcop.cdcooper AND
                                     craplft.cdempcon  = crapscn.cdempcon AND
                              STRING(craplft.cdsegmto) = crapscn.cdsegmto AND
                                     craplft.dtvencto  = aux_dtvencto     AND
                                     craplft.insitfat  = 1                AND
                                     craplft.tpfatura <> 2                AND
                                     craplft.cdhistor  = 1154 /* SICREDI */
                                     EXCLUSIVE-LOCK:

                                ASSIGN craplft.insitfat = 2
                                       craplft.dtdenvio = aux_dtproxim.
                            END.
                        END. /* DO... TO */
                    END.

                IF  crapscn.cdempco2 <> 0 THEN
                    DO:
                        DO aux_dtvencto = aux_dtproces TO glb_dtmvtolt:

                            FOR EACH craplft WHERE 
                                     craplft.cdcooper  = crapcop.cdcooper AND
                                     craplft.cdempcon  = crapscn.cdempco2 AND
                              STRING(craplft.cdsegmto) = crapscn.cdsegmto AND
                                     craplft.dtvencto  = aux_dtvencto     AND
                                     craplft.insitfat  = 1                AND
                                     craplft.tpfatura <> 2                AND
                                     craplft.cdhistor  = 1154 /* SICREDI */
                                     EXCLUSIVE-LOCK:

                                ASSIGN craplft.insitfat = 2
                                       craplft.dtdenvio = aux_dtproxim.
                            END.
                        END. /* DO... TO */
                    END.
            END.

    END. /* FOR EACH crapscn */

    /* Gera arquivo de exportacao com arredação de DARFs */
    RUN gera-arq-darf. 

    ASSIGN aux_nrlinhas = aux_nrlinhas + aux_nrseqndb + aux_nrseqlcm + aux_nrseqatr
           tot_vltotarq = tot_vltotarq + aux_vlfatndb + aux_vlfatlcm.

    /* Trailer */
    PUT STREAM str_2
         "Z" (aux_nrlinhas + 2)     FORMAT "999999"
             (tot_vltotarq * 100)   FORMAT "99999999999999999"
              FILL(" ", 136)        FORMAT "X(136)"
              SKIP.

    /* Trailer DARF */
    PUT STREAM str_3
         "Z" (aux_nrlindrf + 2)     FORMAT "999999"
             (tot_vllanmto * 100)   FORMAT "99999999999999999"
             (tot_vlrmulta * 100)   FORMAT "99999999999999999"
             (tot_vlrjuros * 100)   FORMAT "99999999999999999"
              FILL(" ", 162)        FORMAT "X(162)"
              SKIP.

    OUTPUT STREAM str_3 CLOSE.  /* Fecha arq. exp DARF */

    ASSIGN glb_nrcopias = 1
           glb_nmformul = "132col"
           glb_nmarqimp = aux_nmarqrel /* "rlnsv/crrl637.lst" */.
      
    RUN exibe-rel-637.
    
    OUTPUT STREAM str_1 CLOSE. /* Fecha relatorio 637 */
    
    IF  NOT TEMP-TABLE tt-lancto:HAS-RECORDS THEN
        UNIX SILENT VALUE ("rm " + aux_nmarqrel + "* 2>/dev/null").
    ELSE
        DO:
            /* Necessário para postagem na Intranet */
            UNIX SILENT VALUE("cp " + aux_nmarqrel + "  " +
                              aux_nmarqprv + " 2>/dev/null").

            UNIX SILENT VALUE("chmod 666 " + aux_nmarqprv + " 2>/dev/null").
            UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").

            RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).
        END.
        
    ASSIGN glb_nrcopias = 1
           glb_nmarqimp = aux_nmarqcon. /* "rlnsv/crrl664.lst" */

    RUN exibe-rel-664.

    OUTPUT STREAM str_2 CLOSE.  /* Fecha arq. exp conv */
    OUTPUT STREAM str_4 CLOSE. /* Fecha relatorio 664 */

    IF  NOT TEMP-TABLE tt-rel664:HAS-RECORDS  THEN
        UNIX SILENT VALUE ("rm " + aux_nmarqcon + " 2>/dev/null").
    ELSE  
        DO:
            /* Necessário para postagem na Intranet */
            UNIX SILENT VALUE("cp " + aux_nmarqcon + "  " +
                              aux_nmarq664 + " 2>/dev/null").

            UNIX SILENT VALUE("chmod 666 " + aux_nmarq664 + " 2>/dev/null").
            UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").

            RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).
        END.

    ASSIGN glb_nrcopias = 1
           glb_nmarqimp = aux_nmarqdeb. /* "rlnsv/crrl674.lst" */

    RUN exibe-rel-674.
    
    OUTPUT STREAM str_5 CLOSE.

     IF  NOT TEMP-TABLE tt-rel674-cadastro:HAS-RECORDS AND 
         NOT TEMP-TABLE tt-rel674-lancamentos:HAS-RECORDS THEN
         UNIX SILENT VALUE ("rm " + aux_nmarqdeb + " 2>/dev/null").
     ELSE  
         DO:
             /* Necessário para postagem na Intranet */
             UNIX SILENT VALUE("cp " + aux_nmarqdeb + "  " +
                               aux_nmarq674 + " 2>/dev/null").
             
             UNIX SILENT VALUE("chmod 666 " + aux_nmarq674 + " 2>/dev/null").
             UNIX SILENT VALUE("chmod 666 " + glb_nmarqimp + " 2>/dev/null").
             
             RUN fontes/imprim_unif.p (INPUT crapcop.cdcooper).
         END.

    /* Arquivo Exp. Conv. Vazio */
    IF  aux_flgvazio THEN
        UNIX SILENT VALUE ("rm " + aux_nmarqped + "* 2>/dev/null").
    ELSE  
        DO:
            UNIX SILENT VALUE("chmod 666 " + aux_nmarqped + " 2>/dev/null").

            CREATE tt-arquiv.
            ASSIGN tt-arquiv.cdcooper = crapcop.cdcooper
                   tt-arquiv.dsdircop = crapcop.dsdircop
                   tt-arquiv.nmarqped = aux_nmarqped
                   tt-arquiv.nmarqexp = aux_nmarqexp.

            VALIDATE tt-arquiv.

            /* Copia para o diretorio converte para poder anexar ao email */
            UNIX SILENT VALUE("cp " +  aux_nmarqped + " /usr/coop/" + 
                                  TRIM(crapcop.dsdircop) + "/converte/").

            ASSIGN aux_conteudo = "Segue em anexo arquivo de arrecadacao "  +
                                  "de faturas do dia " + 
                                  STRING(glb_dtmvtolt, "99/99/9999") + ". " +
                                  "Arquivo: " + aux_nmarqexp.

            IF NOT VALID-HANDLE(h-b1wgen0011) THEN
                RUN sistema/generico/procedures/b1wgen0011.p 
                                                PERSISTENT SET h-b1wgen0011.
             
            RUN enviar_email_completo IN h-b1wgen0011
                (INPUT crapcop.cdcooper,
                 INPUT "crps636",
                 INPUT "cpd@cecred.coop.br",
                 INPUT "convenios@cecred.coop.br",
                 INPUT "Arquivo de arrecadacao de faturas - " + 
                       crapcop.nmrescop + " - " + aux_nmarqexp,
                 INPUT "",
                 INPUT aux_nmarqexp,
                 INPUT aux_conteudo,
                 INPUT FALSE).                  
                      
            IF VALID-HANDLE(h-b1wgen0011) THEN
                DELETE PROCEDURE h-b1wgen0011.

        END.

    /* Arquivo Exp. DARF Vazio */
    IF  aux_flgdarvz THEN
        UNIX SILENT VALUE ("rm " + aux_nmexpdar + "* 2>/dev/null").
    ELSE
        DO:
            UNIX SILENT VALUE("chmod 666 " + aux_nmexpdar + " 2>/dev/null").

            CREATE tt-arquiv.
            ASSIGN tt-arquiv.cdcooper = crapcop.cdcooper
                   tt-arquiv.dsdircop = crapcop.dsdircop
                   tt-arquiv.nmarqped = aux_nmexpdar
                   tt-arquiv.nmarqexp = aux_nmarqdar.

            VALIDATE tt-arquiv.

            /* Copia para o diretorio converte para poder anexar ao email */
            UNIX SILENT VALUE("cp " +  aux_nmexpdar + " /usr/coop/" + 
                                  TRIM(crapcop.dsdircop) + "/converte/").

            ASSIGN aux_conteudo = "Segue em anexo arquivo de arrecadacao "  +
                                  "de DARFs do dia " + 
                                  STRING(glb_dtmvtolt, "99/99/9999") + ". " +
                                  "Arquivo: " + aux_nmarqdar.

            IF NOT VALID-HANDLE(h-b1wgen0011) THEN
                RUN sistema/generico/procedures/b1wgen0011.p 
                                                PERSISTENT SET h-b1wgen0011.
             
            RUN enviar_email_completo IN h-b1wgen0011
                (INPUT crapcop.cdcooper,
                 INPUT "crps636",
                 INPUT "cpd@cecred.coop.br",
                 INPUT "convenios@cecred.coop.br",
                 INPUT "Arquivo de arrecadacao de DARFs - " + 
                       crapcop.nmrescop + " - " + aux_nmarqdar,
                 INPUT "",
                 INPUT aux_nmarqdar,
                 INPUT aux_conteudo,
                 INPUT FALSE).                  
                      
            IF VALID-HANDLE(h-b1wgen0011) THEN
                DELETE PROCEDURE h-b1wgen0011.

        END.

    IF  NOT aux_flgdarvz OR
        NOT aux_flgvazio THEN
        RUN atualiza_controle.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    RUN STORED-PROCEDURE pc_relat_repasse_dpvat aux_handproc = PROC-HANDLE NO-ERROR
                        (INPUT crapcop.cdcooper,
                         INPUT glb_dtmvtolt,
                         INPUT glb_cdprogra,
                         OUTPUT 0,
                         OUTPUT "").
    CLOSE STORED-PROC pc_relat_repasse_dpvat aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_relat_repasse_dpvat.pr_cdcritic
                          WHEN pc_relat_repasse_dpvat.pr_cdcritic <> ?
           aux_dscritic = pc_relat_repasse_dpvat.pr_dscritic
                          WHEN pc_relat_repasse_dpvat.pr_dscritic <> ?.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN DO:
        UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           STRING(aux_cdcritic) + " - " + aux_dscritic + 
                           " >> log/proc_batch.log").
        RETURN.
    END.
        
END. /* crapcop */

/*mover todos arquivos das cooperativas de uma vez para 
  o diretorio do connect e depois para o salvar */
FOR EACH tt-arquiv NO-LOCK:

    /* Faz ux2dos e move o arq. para o dir do Connect Direct  */
    UNIX SILENT VALUE("ux2dos < " + tt-arquiv.nmarqped + ' | tr -d "\032"' + 
                      " > /usr/connect/sicredi/envia/" + 
                      tt-arquiv.nmarqexp + " 2>/dev/null").

    /* Move o arq. de exportacao para o dir salvar */
    UNIX SILENT VALUE("mv " +  tt-arquiv.nmarqped + " /usr/coop/" + 
                          TRIM(tt-arquiv.dsdircop) + "/salvar/").


END.                                   

UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")                       +
                      " - "   + STRING(TIME,"HH:MM:SS")                       +
                 " - "   + glb_cdprogra + "' --> '"                           +
                 "Finalizada geracao dos arquivos de arrecadacao do Sicredi." +
                 " >> log/prccon.log").

PROCEDURE gera-linha-arquivo-exp-conv:

    DEF  INPUT   PARAM  par_cdempcon    AS INTE                   NO-UNDO.
    
    DEF  VAR aux_cdtransa AS CHAR                                 NO-UNDO.

    /* Percorre da data do vencto da fat anterior até a data atual */
    DO aux_dtvencto = aux_dtproces TO glb_dtmvtolt:

        FOR EACH craplft WHERE
                 craplft.cdcooper  = crapcop.cdcooper   AND
                 craplft.cdempcon  = par_cdempcon       AND
          STRING(craplft.cdsegmto) = crapscn.cdsegmto   AND
                 craplft.dtvencto  = aux_dtvencto       AND
                 craplft.insitfat  = 1                  AND
                 craplft.tpfatura <> 2                  AND
                 craplft.cdhistor  = 1154  /* SICREDI */
                 NO-LOCK:

            ASSIGN aux_cdagenci = STRING(craplft.cdagenci,"999").

            /* Temp-table para lançamentos */
            CREATE tt-lancto.
            ASSIGN tt-lancto.dsnomcnv = crapscn.dsnomcnv
                   tt-lancto.dtvencto = craplft.dtvencto
                   tt-lancto.cdbarras = craplft.cdbarras
                   tt-lancto.vllanmto = craplft.vllanmto
                   tt-lancto.dsempcnv = crapscn.cdempres
                   tt-lancto.cdagenci = craplft.cdagenci
                   tt-lancto.tpfatura = craplft.tpfatura.
        
            IF  craplft.cdagenci = 90 THEN  /** Internet**/   
                DO:  
                    /* Obter cod. da transacao e vl tarifa */
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres   AND
                                             crapstn.tpmeiarr = "D"                AND
                                             IF crapscn.cdempres = 'K0'  THEN crapstn.cdtransa = '0XY' ELSE TRUE
                                             AND
                                             IF crapscn.cdempres = '147' THEN crapstn.cdtransa = '1CK' ELSE TRUE
                               				 NO-LOCK NO-ERROR.
        
                    IF  AVAIL crapstn THEN
                        ASSIGN aux_cdtransa = crapstn.cdtransa
                               aux_vltrfuni = crapstn.vltrfuni.
                    ELSE
                        ASSIGN aux_vltrfuni = 0.
                    
                    ASSIGN tot_qtfatint = tot_qtfatint + 1
                           tot_vlfatint = tot_vlfatint + craplft.vllanmto
                           tot_vltarint = tot_vltarint + aux_vltrfuni.
                END.
            ELSE                    
            IF  craplft.cdagenci = 91 THEN  /** TAA **/
                DO:
                    /* Obter cod. da transacao e vl tarifa */
                    FIND FIRST crapstn WHERE 
                               crapstn.cdempres = crapscn.cdempres AND
                               crapstn.tpmeiarr = "A"
                               NO-LOCK NO-ERROR.
                
                    IF  AVAIL crapstn THEN
                        ASSIGN aux_cdtransa = crapstn.cdtransa
                               aux_vltrfuni = crapstn.vltrfuni.
                    ELSE
                        ASSIGN aux_vltrfuni = 0.

                    ASSIGN tot_qtfattaa = tot_qtfattaa + 1
                           tot_vlfattaa = tot_vlfattaa + craplft.vllanmto
                           tot_vltartaa = tot_vltartaa + aux_vltrfuni.
                END.
            ELSE                            /** Caixa **/
                DO:
                    /* Obter cod. da transacao e vl tarifa */
                    FIND FIRST crapstn WHERE 
                               crapstn.cdempres = crapscn.cdempres AND
                               crapstn.tpmeiarr = "C"
                               NO-LOCK NO-ERROR.
        
                    IF  AVAIL crapstn THEN
                        ASSIGN aux_cdtransa = crapstn.cdtransa
                               aux_vltrfuni = crapstn.vltrfuni.
                    ELSE
                        ASSIGN aux_vltrfuni = 0.

                    ASSIGN tot_qtfatcxa = tot_qtfatcxa + 1
                           tot_vlfatcxa = tot_vlfatcxa + craplft.vllanmto
                           tot_vltarcxa = tot_vltarcxa + aux_vltrfuni.
                END.
        
            /* Calcula data de repasse */
            ASSIGN aux_dtrepass = glb_dtmvtolt
                   aux_contador = 1.
        
            IF  crapscn.dsdianor = "U" THEN /* Dias úteis */
                DO:
                    DO  WHILE TRUE:
        
                        ASSIGN aux_dtrepass = aux_dtrepass + 1.
        
                        IF  CAN-DO("1,7",STRING(WEEKDAY(aux_dtrepass))) OR
                            CAN-FIND(crapfer WHERE 
                                     crapfer.cdcooper = glb_cdcooper   AND
                                     crapfer.dtferiad = aux_dtrepass)  THEN
                            NEXT.
        
                        IF  aux_contador = crapscn.nrrenorm THEN
                            LEAVE.
        
                        ASSIGN aux_contador = aux_contador + 1.
        
                    END.
                END.
            ELSE    /* Dias corridos */
                DO:
                    ASSIGN aux_dtrepass = aux_dtrepass + crapscn.nrrenorm.
        
                    DO  WHILE TRUE:
        
                        IF  NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtrepass))) AND
                            NOT CAN-FIND(crapfer WHERE 
                                         crapfer.cdcooper = glb_cdcooper   AND
                                         crapfer.dtferiad = aux_dtrepass)  THEN
                            LEAVE.
                    
                        ASSIGN aux_dtrepass = aux_dtrepass + 1.
                    
                    END.
                    
                END.
        
            ASSIGN aux_flgvazio = FALSE
                   aux_nrseqdig = aux_nrseqdig + 1
                   aux_nrlinhas = aux_nrlinhas + 1
                   aux_dtmvtopr = STRING(YEAR(aux_dtrepass),"9999") +
                                  STRING(MONTH(aux_dtrepass),"99")  +
                                  STRING(DAY(aux_dtrepass),"99")
                   tot_vlfatura = tot_vlfatura + craplft.vllanmto
                   tot_vltotarq = tot_vltotarq + craplft.vllanmto
                   tot_vltrfuni = tot_vltrfuni + aux_vltrfuni
                   aux_cdpeslft = STRING(craplft.dtmvtolt,"99/99/9999") + "-" +
                                 STRING(SUBSTR(aux_cdagenci,2,2),"999") + "-" +
                                 STRING(craplft.cdbccxlt,"999")         + "-" +
                                 STRING(craplft.nrdolote,"999999").
        
            /* Detalhe */
            ASSIGN aux_dslinreg = "G" + FILL(" ", 20)                         +
                                STRING(aux_dtmvtolt, "99999999")              +
                                STRING(aux_dtmvtopr, "99999999")              +
                                STRING(craplft.cdbarras, "x(44)")             +
                                STRING(craplft.vllanmto * 100,"999999999999") +
                                FILL("0", 19)                                 +
                                STRING(crapcop.cdagesic,"9999")               +
                                STRING(aux_cdtransa, "999")                   +
                                FILL(" ", 26)                                 +
                                SUBSTR(aux_cdagenci,2,2)                      +
                                STRING(crapscn.cdempres, "9999999999")        +
                                FILL(" ", 3).
            
            PUT STREAM str_2 aux_dslinreg FORMAT "x(160)" SKIP. /* 160Col. */
        
        END.  /* For each craplft */
    END. /* DO.. TO */
   
    /* TOTAIS */
    ASSIGN tot_vlapagar = tot_vlfatura - tot_vltrfuni
           tot_vlpagcxa = tot_vlfatcxa - tot_vltarcxa
           tot_vlpagint = tot_vlfatint - tot_vltarint
           tot_vlpagtaa = tot_vlfattaa - tot_vltartaa.

END PROCEDURE. /* gera-linha-arquivo-exp-conv */

PROCEDURE atualiza_controle:

    /* Sequencial do arquivo */
    DO TRANSACTION ON ENDKEY UNDO, LEAVE:

        DO aux_contador = 1 TO 10:

            FIND craptab WHERE 
                 craptab.cdcooper = crapcop.cdcooper  AND         
                 craptab.nmsistem = "CRED"            AND         
                 craptab.tptabela = "GENERI"          AND         
                 craptab.cdempres = 00                AND         
                 craptab.cdacesso = "ARQSICREDI"      AND
                 craptab.tpregist = 00
                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE craptab   THEN
                IF  LOCKED craptab   THEN
                    NEXT.
                ELSE
                    LEAVE.

            LEAVE.
           
        END.  /*  Fim do DO .. TO  */

        IF  NOT aux_flgdarvz THEN
            DO:
                ASSIGN SUBSTR(craptab.dstextab,8,6) = STRING(aux_nrseqdar + 1,"999999").

                /* LOG */
                ASSIGN glb_dscritic = CAPS(crapcop.nmrescop)          +
                                      " - Gerado o arquivo "          +
                                      aux_nmarqdar                    + 
                                      " com sucesso.".
                
                UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")   + 
                                   " - "   + STRING(TIME,"HH:MM:SS")      +
                                   " - "   +  glb_cdprogra  + "' --> '"   + 
                                                glb_dscritic              +
                                   " >> log/prccon.log").
            END.
            
        IF  NOT aux_flgvazio THEN
            DO:
                ASSIGN SUBSTR(craptab.dstextab,1,6) = STRING(aux_nrseqarq + 1,"999999").

                /* LOG */
                ASSIGN glb_dscritic = CAPS(crapcop.nmrescop)          +
                                      " - Gerado o arquivo "          +
                                      aux_nmarqexp                    + 
                                      " com sucesso.".
                
                UNIX SILENT VALUE ("echo " + STRING(TODAY,"99/99/9999")   + 
                                   " - "   + STRING(TIME,"HH:MM:SS")      +
                                   " - "   +  glb_cdprogra  + "' --> '"   + 
                                                glb_dscritic              +
                                   " >> log/prccon.log").
            END.
            
    END.
    
    DO  TRANSACTION:
    
        DO WHILE TRUE:
    
            FIND crapres WHERE crapres.cdcooper = crapcop.cdcooper AND
                               crapres.cdprogra = glb_cdprogra
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAILABLE crapres   THEN
                IF  LOCKED crapres   THEN
                    DO:
                       PAUSE 1 NO-MESSAGE.
                       NEXT.
                    END.
                ELSE
                    UNDO, RETURN.
            
                LEAVE.
                      
        END.

        ASSIGN crapres.nrdconta = 999.
    
    END.  /*  Fim da Transacao  */
    
END PROCEDURE. 

PROCEDURE exibe-rel-637:

    DEF  VAR  aux_flgprlin    AS LOGI                                     NO-UNDO.

    VIEW STREAM   str_1 FRAME f_cabrel132_1.

    /* Exibição */
    DISPLAY STREAM str_1 aux_nmarqdat 
                         WITH FRAME f_label.

    FOR EACH tt-lancto NO-LOCK BREAK BY tt-lancto.tpfatura
                                     BY tt-lancto.dsempcnv.

        IF  LINE-COUNTER(str_1) > (PAGE-SIZE(str_1) - 10) THEN
            DO:
                PAGE STREAM str_1.
       
                DISPLAY STREAM str_1 aux_nmarqdat 
                                     WITH FRAME f_label.
       
                DOWN STREAM str_1 WITH FRAME f_label.

                /* Primeira linha */
                ASSIGN aux_flgprlin = TRUE.

            END.

        DISPLAY STREAM str_1 tt-lancto.dsnomcnv WHEN FIRST-OF (tt-lancto.dsempcnv) OR aux_flgprlin
                             tt-lancto.dtvencto   
                             tt-lancto.cdbarras
                             tt-lancto.vllanmto
                             tt-lancto.dsempcnv
                             tt-lancto.cdagenci 
                             WITH FRAME f_lancto.
       
        DOWN STREAM str_1 WITH FRAME f_lancto.

        ASSIGN aux_flgprlin = FALSE.

    END.

    DISPLAY STREAM str_1
                   tot_qtfatcxa  tot_vlfatcxa 
                   tot_vltarcxa  tot_vlpagcxa
                   aux_nrseqdig  tot_vlfatura
                   tot_vltrfuni  tot_vlapagar 
                   tot_qtfatint  tot_vlfatint 
                   tot_vltarint  tot_vlpagint 
                   tot_qtfattaa  tot_vlfattaa 
                   tot_vltartaa  tot_vlpagtaa 
                   WITH FRAME f_total.
  
    DOWN STREAM str_1 WITH FRAME f_total.
    
END.

PROCEDURE exibe-rel-664:

     VIEW STREAM   str_4 FRAME f_cabrel132_4.

     FOR EACH tt-rel664 NO-LOCK BREAK 
                                 BY tt-rel664.cdagenci
                                 BY tt-rel664.tpconsor    
                                 BY tt-rel664.nrdconta:

         IF  LINE-COUNTER(str_4) > (PAGE-SIZE(str_4) - 10) THEN
             PAGE STREAM str_4.

         DISP STREAM str_4 tt-rel664.cdagenci
                           tt-rel664.nrdconta
                           tt-rel664.nrctacns
                           tt-rel664.nmconsor
                           tt-rel664.nrdgrupo
                           tt-rel664.dsconsor
                           tt-rel664.nrcotcns
                           tt-rel664.vlparcns
                           tt-rel664.dscritic
                           WITH FRAME f_crrl664_det.    

         DOWN STREAM str_4 WITH FRAME f_crrl664_det.
         
         FIND FIRST tt-totais-crrl664 WHERE 
                    tt-totais-crrl664.dsconsor = tt-rel664.dsconsor 
                    NO-LOCK NO-ERROR.

         IF  NOT AVAIL tt-totais-crrl664 THEN 
             DO:
                 CREATE tt-totais-crrl664.
                 ASSIGN tt-totais-crrl664.tpconsor = tt-rel664.tpconsor
                        tt-totais-crrl664.qttotseg = tt-totais-crrl664.qttotseg + 1 
                        tt-totais-crrl664.vltotseg = tt-totais-crrl664.vltotseg + tt-rel664.vlparcns
                        tt-totais-crrl664.dsconsor = tt-rel664.dsconsor.
             END.
         ELSE
             DO:
                 ASSIGN tt-totais-crrl664.vltotseg = tt-totais-crrl664.vltotseg + tt-rel664.vlparcns
                        tt-totais-crrl664.qttotseg = tt-totais-crrl664.qttotseg + 1.
             
             END.  
     END.
         
     ASSIGN tot_qtarecad = 0
            tot_vlarecad = 0.

     PUT STREAM str_4 SKIP(1).
     
     FOR EACH tt-totais-crrl664 NO-LOCK WHERE tt-totais-crrl664.dsconsor <> ""
                                BREAK BY tt-totais-crrl664.tpconsor:

         ASSIGN tot_qtarecad = tot_qtarecad + tt-totais-crrl664.qttotseg
                tot_vlarecad = tot_vlarecad + tt-totais-crrl664.vltotseg.

         DISP STREAM str_4 tt-totais-crrl664.dsconsor
                           tt-totais-crrl664.qttotseg
                           tt-totais-crrl664.vltotseg
                           WITH FRAME f_crrl664_tot.

         DOWN STREAM str_4 WITH FRAME f_crrl664_tot. 
        
     END.
     
     /* Total geral dos consorcios */
     PUT STREAM str_4 "---------- -------- --------------"
                      SKIP
                      "TOTAL" AT 01          
                      tot_qtarecad FORMAT "zzzz,zz9" AT 12
                      tot_vlarecad FORMAT "zzz,zzz,zz9.99" AT 21.

END.

PROCEDURE exibe-rel-674:

    DEF VAR tot_qtdlanct AS INTE                                    NO-UNDO.
    DEF VAR tot_qtdcriti AS INTE                                    NO-UNDO.
    DEF VAR tot_vllancto AS DECI                                    NO-UNDO.
    DEF VAR tot_lancefet AS INTE                                    NO-UNDO.

    VIEW STREAM   str_5 FRAME f_cabrel132_5.

    FIND FIRST tt-rel674-cadastro NO-LOCK NO-ERROR.

    IF  AVAIL tt-rel674-cadastro THEN
        PUT STREAM str_5 "INCLUSAO/EXCLUSAO" SKIP(1).

    FOR EACH tt-rel674-cadastro NO-LOCK
                   BY tt-rel674-cadastro.cdagenci
                   BY tt-rel674-cadastro.nrdconta:

        IF  LINE-COUNTER(str_5) > (PAGE-SIZE(str_5) - 10) THEN
            PAGE STREAM str_5.

        DISP STREAM str_5 tt-rel674-cadastro.cdagenci  
                          tt-rel674-cadastro.nrdconta
                          tt-rel674-cadastro.cdrefere
                          tt-rel674-cadastro.dsnomcnv
                          tt-rel674-cadastro.cdagenci 
                          tt-rel674-cadastro.dsmovmto
                          WITH FRAME f_crrl674_cadastro.

        DOWN STREAM str_5 WITH FRAME f_crrl674_cadastro.

    END.

    ASSIGN tot_qtdlanct = 0
           tot_qtdcriti = 0
           tot_vllancto = 0
           tot_lancefet = 0.

    /*****************************************/
    /*** LANCAMENTOS DE DEBITOS EFETIVADOS ***/
    /*****************************************/

    FIND FIRST tt-rel674-lancamentos WHERE 
               tt-rel674-lancamentos.dscritic = "" 
               NO-LOCK NO-ERROR.

    IF  AVAIL tt-rel674-lancamentos THEN
        PUT STREAM str_5 SKIP(2) 
                         "LANCAMENTOS DE DEBITOS - EFETIVADOS" SKIP(1).

    FOR EACH tt-rel674-lancamentos WHERE 
             tt-rel674-lancamentos.dscritic = ""  NO-LOCK
                   BY tt-rel674-lancamentos.cdagenci
                   BY tt-rel674-lancamentos.nrdconta
                   BY tt-rel674-lancamentos.nrdocmto:

        IF  LINE-COUNTER(str_5) > (PAGE-SIZE(str_5) - 10) THEN
            PAGE STREAM str_5.

        ASSIGN tot_lancefet = tot_lancefet + 1.

        ASSIGN tot_qtdlanct = tot_qtdlanct + 1
               tot_vllancto = tot_vllancto + tt-rel674-lancamentos.vllanmto.

        DISP STREAM str_5 tt-rel674-lancamentos.cdagenci
                          tt-rel674-lancamentos.nrdconta
                          tt-rel674-lancamentos.nrctacns
                          tt-rel674-lancamentos.dsnomcnv
                          tt-rel674-lancamentos.nrdocmto
                          tt-rel674-lancamentos.vllanmto
                          WITH FRAME f_crrl674_lancamentos.

        DOWN STREAM str_5 WITH FRAME f_crrl674_lancamentos.

    END.

    /********************************************************/
    /*** LANCAMENTOS DE DEBITOS CRITICADOS/NAO EFETIVADOS ***/
    /********************************************************/
    
    FIND FIRST tt-rel674-lancamentos WHERE 
               tt-rel674-lancamentos.dscritic <> "" 
               NO-LOCK NO-ERROR.

    IF  AVAIL tt-rel674-lancamentos THEN
        PUT STREAM str_5 SKIP(2) 
                         "LANCAMENTOS DE DEBITOS - CRITICADOS" SKIP(1).

    FOR EACH tt-rel674-lancamentos WHERE 
             tt-rel674-lancamentos.dscritic <> ""  NO-LOCK
                   BY tt-rel674-lancamentos.cdagenci
                   BY tt-rel674-lancamentos.nrdconta
                   BY tt-rel674-lancamentos.nrdocmto:

        IF  LINE-COUNTER(str_5) > (PAGE-SIZE(str_5) - 10) THEN
            PAGE STREAM str_5.
        
        ASSIGN tot_qtdcriti = tot_qtdcriti + 1.

        ASSIGN tot_qtdlanct = tot_qtdlanct + 1
               tot_vllancto = tot_vllancto + tt-rel674-lancamentos.vllanmto.

        DISP STREAM str_5 tt-rel674-lancamentos.cdagenci
                          tt-rel674-lancamentos.nrdconta
                          tt-rel674-lancamentos.nrctacns
                          tt-rel674-lancamentos.dsnomcnv
                          tt-rel674-lancamentos.nrdocmto
                          tt-rel674-lancamentos.vllanmto
                          tt-rel674-lancamentos.dscritic
                          WITH FRAME f_crrl674_lancamentos_criticas.

        DOWN STREAM str_5 WITH FRAME f_crrl674_lancamentos_criticas.

    END.

    FIND FIRST tt-rel674-lancamentos NO-LOCK NO-ERROR.

    IF  AVAIL tt-rel674-lancamentos THEN
        PUT STREAM str_5 SKIP(2)
                         "TOTAIS LANCAMENTOS"
                         SKIP(1)
                         " QUANTIDADE          VALOR EFETIVADOS CRITICADOS"
                         SKIP
                         "----------- -------------- ---------- ----------"
                         SKIP                                     
                         tot_qtdlanct AT 01 FORMAT "   zzzz,zz9"
                         tot_vllancto AT 13 FORMAT "zzz,zzz,zz9.99"
                         tot_lancefet AT 28 FORMAT "zzzzzz,zz9"
                         tot_qtdcriti AT 39 FORMAT "zzzzzz,zz9".

END.


PROCEDURE gera-linha-arquivo-exp-darf:

    DEF  VAR  aux_dsmeicol    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_dscodbar    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_nrrefere    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_vlpercen    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_vlrecbru    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_nrcpfcgc    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_dtlimite    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_cdtransa    AS CHAR                                  NO-UNDO.
    DEF  VAR  aux_dstipdrf    AS CHAR                                  NO-UNDO.

    /* Percorre da data do vencto da fat da darf anterior até a data atual */
    DO aux_dtvencto = aux_dtproces TO glb_dtmvtolt:

        FOR EACH craplft WHERE
                 craplft.cdcooper  = crapcop.cdcooper   AND
                 craplft.dtvencto  = aux_dtvencto       AND
                 craplft.insitfat  = 1                  AND
                 craplft.tpfatura  = 2                  AND
                 craplft.cdhistor  = 1154  /* SICREDI */
                 NO-LOCK:
            
            ASSIGN aux_cdagenci = STRING(craplft.cdagenci,"999").

            IF  craplft.cdempcon = 0 THEN
                DO:    
                    IF  craplft.cdtribut = "6106" THEN /* DARF SIMPLES */
                        DO:
                            FIND FIRST crapscn WHERE crapscn.cdempres = "D0"
                                                     NO-LOCK NO-ERROR NO-WAIT.
        
                            IF  NOT AVAIL crapscn THEN
                                NEXT.
                        END.
                    ELSE
                        DO: /* DARF PRETO EUROPA */
                            FIND FIRST crapscn WHERE crapscn.cdempres = "A0"
                                                    NO-LOCK NO-ERROR NO-WAIT.
        
                            IF  NOT AVAIL crapscn THEN
                                NEXT.
                        END.
                END.
            ELSE
                DO:                                       
                    FIND FIRST crapscn WHERE 
                               crapscn.cdempcon = craplft.cdempcon AND
                               crapscn.cdsegmto = STRING(craplft.cdsegmto) AND
							   crapscn.dtencemp = ?
                               NO-LOCK NO-ERROR NO-WAIT.
        
                    IF  NOT AVAIL crapscn THEN
                        NEXT.
                        
                END.
        
            /* Temp-table para lançamentos */
            CREATE tt-lancto.
            ASSIGN tt-lancto.dsnomcnv = crapscn.dsnomcnv
                   tt-lancto.dtvencto = craplft.dtvencto
                   tt-lancto.cdbarras = craplft.cdbarras
                   tt-lancto.vllanmto = (craplft.vllanmto + craplft.vlrjuros + 
                                                            craplft.vlrmulta)
                   tt-lancto.dsempcnv = crapscn.cdempres
                   tt-lancto.cdagenci = INT(SUBSTR(aux_cdagenci,2,2))
                   tt-lancto.tpfatura = craplft.tpfatura.
        
            IF  craplft.cdagenci = 90 THEN  /** Internet**/   
                DO:
                    /* Obter cod. da transacao e vl tarifa */
                    FIND FIRST crapstn WHERE crapstn.cdempres = crapscn.cdempres   AND
                                             crapstn.tpmeiarr = "D"                AND
                                             IF crapscn.cdempres = 'K0'  THEN crapstn.cdtransa = '0XY' ELSE TRUE
                                             AND
                                             IF crapscn.cdempres = '147' THEN crapstn.cdtransa = '1CK' ELSE TRUE
                               NO-LOCK NO-ERROR.
        
                    IF  AVAIL crapstn THEN
                        ASSIGN aux_cdtransa = crapstn.cdtransa
                               aux_vltrfuni = crapstn.vltrfuni
                               aux_dstipdrf = crapstn.dstipdrf.
                    ELSE
                        ASSIGN aux_vltrfuni = 0.

                    ASSIGN  tot_qtfatint = tot_qtfatint + 1
                            tot_vlfatint = tot_vlfatint + (craplft.vllanmto + 
                                                           craplft.vlrjuros + 
                                                           craplft.vlrmulta)
                            tot_vltarint = tot_vltarint + aux_vltrfuni
                            aux_dsmeicol = IF craplft.cdempcon = 385 AND craplft.cdsegmto = 5 THEN "3" ELSE "8".
                END.
            ELSE                    
            IF  craplft.cdagenci = 91 THEN  /** TAA **/
                DO:
                    /* Obter cod. da transacao e vl tarifa */
                    FIND FIRST crapstn WHERE 
                               crapstn.cdempres = crapscn.cdempres AND
                               crapstn.tpmeiarr = "A"
                               NO-LOCK NO-ERROR.
                
                    IF  AVAIL crapstn THEN
                        ASSIGN aux_cdtransa = crapstn.cdtransa
                               aux_vltrfuni = crapstn.vltrfuni
                               aux_dstipdrf = crapstn.dstipdrf.
                    ELSE
                        ASSIGN aux_vltrfuni = 0.

                    ASSIGN  tot_qtfattaa = tot_qtfattaa + 1
                            tot_vlfattaa = tot_vlfattaa + (craplft.vllanmto + 
                                                           craplft.vlrjuros + 
                                                           craplft.vlrmulta)
                            tot_vltartaa = tot_vltartaa + aux_vltrfuni
                            aux_dsmeicol = IF craplft.cdempcon = 385 AND craplft.cdsegmto = 5 THEN "3" ELSE "8".
                END.
            ELSE                            /** Caixa **/
                DO:
                    /* Obter cod. da transacao e vl tarifa */
                    FIND FIRST crapstn WHERE 
                               crapstn.cdempres = crapscn.cdempres AND
                               crapstn.tpmeiarr = "C"
                               NO-LOCK NO-ERROR.
        
                    IF  AVAIL crapstn THEN
                        ASSIGN aux_cdtransa = crapstn.cdtransa
                               aux_vltrfuni = crapstn.vltrfuni
                               aux_dstipdrf = crapstn.dstipdrf.
                    ELSE
                        ASSIGN aux_vltrfuni = 0.

                    ASSIGN  tot_qtfatcxa = tot_qtfatcxa + 1
                            tot_vlfatcxa = tot_vlfatcxa + (craplft.vllanmto + 
                                                           craplft.vlrjuros + 
                                                           craplft.vlrmulta)
                            tot_vltarcxa = tot_vltarcxa + aux_vltrfuni
                            aux_dsmeicol = "1".
                END.
                
            /* Calcula data de repasse */
            ASSIGN aux_dtrepass = glb_dtmvtolt
                   aux_contador = 1.
                
            IF  crapscn.dsdianor = "U" THEN /* Dias úteis */
                DO:
                    DO WHILE TRUE:
        
                        ASSIGN aux_dtrepass = aux_dtrepass + 1.
        
                        IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtrepass))) OR
                             CAN-FIND(crapfer WHERE
                                      crapfer.cdcooper = glb_cdcooper   AND
                                      crapfer.dtferiad = aux_dtrepass)  THEN
                             NEXT.
        
                        IF  aux_contador = crapscn.nrrenorm THEN
                            LEAVE.
        
                        ASSIGN aux_contador = aux_contador + 1.
        
                    END.
                END.
            ELSE    /* Dias corridos */
                DO:
                    ASSIGN aux_dtrepass = aux_dtrepass + crapscn.nrrenorm.
        
                    DO  WHILE TRUE:
        
                        IF  NOT CAN-DO("1,7",STRING(WEEKDAY(aux_dtrepass))) AND
                            NOT CAN-FIND(crapfer WHERE 
                                         crapfer.cdcooper = glb_cdcooper  AND
                                         crapfer.dtferiad = aux_dtrepass) THEN
                            LEAVE.
                    
                        ASSIGN aux_dtrepass = aux_dtrepass + 1.
                    
                    END.
                    
                END.
        
            ASSIGN /* Totais DARF */
                   tot_vllanmto = tot_vllanmto + craplft.vllanmto
                   tot_vlrmulta = tot_vlrmulta + craplft.vlrmulta
                   tot_vlrjuros = tot_vlrjuros + craplft.vlrjuros
        
                   aux_flgdarvz = FALSE
                   aux_nrseqdig = aux_nrseqdig + 1
                   aux_nrlindrf = aux_nrlindrf + 1
                   aux_dtmvtopr = STRING(YEAR(aux_dtrepass),"9999") +
                                  STRING(MONTH(aux_dtrepass),"99")  +
                                  STRING(DAY(aux_dtrepass),"99")
                   tot_vlfatura = tot_vlfatura + (craplft.vllanmto + 
                                                  craplft.vlrjuros + 
                                                  craplft.vlrmulta)
                   tot_vltrfuni = tot_vltrfuni + aux_vltrfuni
                   aux_cdpeslft = STRING(craplft.dtmvtolt,"99/99/9999")  + "-" +
                                  STRING(SUBSTR(aux_cdagenci,2,2),"999") + "-" +
                                  STRING(craplft.cdbccxlt,"999")         + "-" +
                                  STRING(craplft.nrdolote,"999999")
                   aux_vlpercen = IF  craplft.cdtribut = "6106" THEN  /* DARF SIMPLES */
                                      STRING(craplft.vlpercen * 100, "9999")
                                  ELSE
                                      FILL(" ", 04)
                   aux_vlrecbru = IF  craplft.vlrecbru <> 0 THEN
                                      STRING(craplft.vlrecbru * 100,"999999999")
                                  ELSE
                                      FILL(" ", 09)
                   aux_dscodbar = IF  craplft.cdbarras = "" THEN
                                      STRING(aux_nrlindrf, "99999999999")       
                                  ELSE
                                      "COD.BARRAS ". 
        
            IF  craplft.cdbarras <> "" OR 
                craplft.nrrefere  = "" OR
                craplft.nrrefere  = ?  THEN
                ASSIGN aux_nrrefere = FILL(" ", 17).
            ELSE
                DO:
                    IF  craplft.nrrefere <> "" THEN
                        ASSIGN aux_nrrefere = FILL("0", 17 - LENGTH(craplft.nrrefere)) +
                                              TRIM(SUBSTR(craplft.nrrefere,1,17)).
                END.
        
            ASSIGN aux_nrcpfcgc = TRIM(SUBSTR(STRING(craplft.nrcpfcgc),1,14)) +
                                  FILL(" ", 14 - LENGTH(STRING(craplft.nrcpfcgc))).
        
            DATE(craplft.dtlimite) NO-ERROR.
        
            IF  NOT ERROR-STATUS:ERROR AND
                craplft.dtlimite <> ?  THEN
                ASSIGN aux_dtlimite = STRING(YEAR(craplft.dtlimite), "9999") +
                                      STRING(MONTH(craplft.dtlimite), "99")  +
                                      STRING(DAY(craplft.dtlimite), "99").     
            ELSE
                ASSIGN aux_dtlimite  = FILL(" ", 08).
                       
            IF  craplft.dtapurac <> ? THEN
                ASSIGN aux_dtapurac = STRING(YEAR(craplft.dtapurac), "9999") +
                                      STRING(MONTH(craplft.dtapurac), "99")  +
                                      STRING(DAY(craplft.dtapurac), "99").
            ELSE
                ASSIGN aux_dtapurac = FILL(" ", 08). 
                                    
             /* Detalhe DARF */
            ASSIGN aux_dslinreg = "D" + 
                                  STRING(aux_cdtransa, "999")   +
                                  STRING(crapcop.nrctasic,"999999") +
                                  SUBSTRING(aux_cdagenci,2,2)       + 
                                  aux_dscodbar                      +
                                  STRING(aux_dstipdrf, "9")     +
                                  "10"  /* Regiao Fiscal - FIXO */  +
                                  STRING(aux_dtmvtolt, "99999999")  +
                                  STRING(aux_dtmvtolt, "99999999")  +
                                  aux_dtapurac                      +
                                  aux_nrcpfcgc                      +
                                  STRING(craplft.cdtribut, "9999")  +
                                  aux_nrrefere                      +
                                  aux_dtlimite                      +
                                  aux_vlrecbru                      +
                                  aux_vlpercen                      +
                                  STRING(craplft.vllanmto * 100,    
                                         "999999999999999")         +
                                  STRING(craplft.vlrmulta * 100,    
                                         "999999999999999")         +
                                  STRING(craplft.vlrjuros * 100,    
                                         "999999999999999")         +
                                  STRING(aux_dtmvtopr, "99999999")  +
                                  STRING(aux_dsmeicol, "9")         +
                                  "0"                               +
                                  FILL(" ", 15)                     + 
                                  STRING(craplft.cdbarras).     
        
            PUT STREAM str_3 aux_dslinreg  FORMAT "x(220)" SKIP. /* 220Col. */
        
        END.  /* For each craplft */
    END. /* DO... TO */
   
    /* TOTAIS */
    ASSIGN tot_vlapagar = tot_vlfatura - tot_vltrfuni
           tot_vlpagcxa = tot_vlfatcxa - tot_vltarcxa
           tot_vlpagint = tot_vlfatint - tot_vltarint
           tot_vlpagtaa = tot_vlfattaa - tot_vltartaa.

END PROCEDURE. /* gera-linha-arquivo-exp-darf */


PROCEDURE gera-arq-darf:

    ASSIGN aux_dtproces = glb_dtmvtolt.

    DO aux_dtvencto = aux_dtanteri TO glb_dtmvtolt:

        FIND FIRST  craplft WHERE craplft.cdcooper  = crapcop.cdcooper      AND
                                  craplft.dtvencto  = aux_dtvencto          AND
                                  craplft.insitfat  = 1                     AND
                                  craplft.tpfatura  = 2                     AND
                                  craplft.cdhistor  = 1154                 /* SICREDI */
                                  NO-LOCK NO-ERROR.
        IF  AVAIL craplft THEN
            ASSIGN aux_dtproces = craplft.dtvencto.

    END. /* DO.. TO */

    RUN gera-linha-arquivo-exp-darf.

    IF (NOT aux_flgdarvz) OR (glb_nrctares = 999)   THEN
        DO:
            DO aux_dtvencto = aux_dtproces TO glb_dtmvtolt:

                FOR EACH craplft WHERE craplft.cdcooper  = crapcop.cdcooper      AND
                                       craplft.dtvencto  = aux_dtvencto          AND
                                       craplft.insitfat  = 1                     AND
                                       craplft.tpfatura  = 2                     AND
                                       craplft.cdhistor  = 1154                 /* SICREDI */
                                       EXCLUSIVE-LOCK:

                           ASSIGN craplft.insitfat = 2
                                  craplft.dtdenvio = aux_dtproxim.
                END.
            END. /* DO.. TO */
        END.

END PROCEDURE.

PROCEDURE retorna_valor_formatado:

    DEF INPUT PARAM par_qtdigito   AS INTE NO-UNDO. /* max. de digitos na variavel */
    DEF INPUT PARAM par_qtdcchar   AS INTE NO-UNDO. /* quantidade de characteres a completar */
    DEF INPUT PARAM par_indposic   AS INTE NO-UNDO. /* 0-esquerda/direita/espacos*/
    DEF INPUT PARAM par_valor      AS CHAR NO-UNDO. /* valor a ser retornado */
    DEF OUTPUT PARAM par_resultado AS CHAR NO-UNDO. /* resultado */
    
    DEF VAR aux_length AS INTE NO-UNDO.
    DEF VAR aux_soma   AS INTE NO-UNDO.
    DEF VAR aux_tpfill AS CHAR NO-UNDO.

    IF  par_indposic = 1 OR par_indposic = 2 THEN
        ASSIGN aux_tpfill = "0".
    ELSE
        ASSIGN aux_tpfill = " ".

    ASSIGN aux_length = LENGTH(TRIM(par_valor))
           aux_soma = par_qtdigito - aux_length.

    CASE par_indposic:
         WHEN 2 THEN
             par_resultado = par_valor + FILL(aux_tpfill,aux_soma).
         WHEN 1 THEN
              par_resultado = FILL(aux_tpfill,aux_soma) + par_valor.
         OTHERWISE
               par_resultado = par_valor + FILL(aux_tpfill,aux_soma).
    END CASE.    

    /* completar com espacos */
    ASSIGN aux_soma = par_qtdcchar - par_qtdigito
           par_resultado = par_resultado + FILL(" ",aux_soma).

END. 




