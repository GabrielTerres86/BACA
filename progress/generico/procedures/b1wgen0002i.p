/******************************************************************************
                           ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+--------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                  |
  +-------------------------------------+--------------------------------------+
  | b1wgen0002.p                        | EMPR0003                             |
  | busca_operacoes                     | EMPR0003.pc_busca_operacoes          |
  | gera_co_responsavel                 | EMPR0003.pc_gera_co_responsavel      |
  +-------------------------------------+--------------------------------------+
                             
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
                            
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*.............................................................................

   Programa: sistema/generico/procedures/b1wgen0002i.p
   Autor   : André - DB1.
   Data    : 23/03/2011                        Ultima atualizacao: 19/10/2018

   Dados referentes ao programa:

   Objetivo  : Tratar impressoes da BO 0002.

   Alteracoes: 23/05/2011 - Alteraçao do format dos campos nmbairro e nmcidade.
                            Passado de "x(15)" para, "x(40)" e "x(25)", 
                            respectivamente. (Fabricio)

               28/06/2011 - Ajuste na composicao do campo dspreapg para co-
                            responsabilidade (David).  

               26/07/2011 - Nao gerar a proposta quando a impressao for completa
                           (Isara - RKAM)

               11/08/2011 - Incluir dtrefere na obtem_risco - GE (Guilherme).

               05/09/2011 - Ajuste de format de variavel (Henrique).
               
               14/09/2011 - Nao imprimir rating para CECRED (Guilherme).
               
               14/02/2012 - Modificados layouts dos modelos 1,2 e 3 (Tiago).
               
               16/03/2012 - Correcoes nos layouts dos modelos 1,2 e 3 (Tiago).
               
               22/03/2012 - Correcoes nos layouts dos modelos 1,2 e 3 (Tiago).
               
               04/04/2012 - Incluir campo dtlibera (Gabriel).
              
               13/04/2012 - Modificado layout do form f_analise (Tiago).
               
               04/07/2012 - Tratamento do cdoperad "operador" de INTE
                            para CHAR. (Lucas R.)

               14/09/2012 - Ajuste de formatos de campos (Gabriel).

               18/09/2012 - Novos parametros DATA na chamada da procedure
                            obtem-dados-aplicacoes (Guilherme/Supero).
                            
               11/10/2012 - Incluido a passagem de um novo parametro na 
                            chamada da procedure saldo_utiliza - Projeto GE
                           (Adriano).             
                            
               01/11/2012 - Incluir chamada da procedure calc_endivid_grupo
                            e tratamento para verificar se conta eh ou nao do GE
                            (Lucas R.).

               28/12/2012 - Incluida a cooperativa 16 para imprimir o texto
                            especifico do BNDES. Estava fixo somente para
                            Viacredi. (Irlan)
                             
               29/01/2013 - Incluir complemento no titulo do f_cabecalho,
                            tratamento de identificacao com "*" se for 
                            tpemprst = 1 (Lucas R.).     
                            
               06/05/2013 - Adicionada área de uso da Digitalizaçao (Lucas).
               
               09/05/2013 - Ajuste na clausula "a/b" do form f_declaracao
                            na procedure trata-impressao-modelo1a (Adriano).
               
               26/06/2013 - Correçao na impressao da área "PARA USO DA DIGITALIZACAO"
                            na proposta de emprestimo e impressao de notas
                            promissorias (Lucas).
               
               23/08/2013 - Modificados layouts dos modelos 1,2 e 3 (Tiago).
               
               06/09/2013 - Ajustes na parte de multa dos contratos dos
                            modelos 1,2 e 3 (Tiago).             
                            
               08/10/2013 - Restruturaçao total dos Contratos Empr.
                          - Remoçao das procedures:
                                 - trata-impressao-modelo1a
                                 - trata-impressao-modelo2a
                                 - trata-impressao-modelo3a
                          - Criacao de procedures para novos modelos de contratos (Lucas).
              
               13/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow)           
                          
               02/12/2013 - Incluido linha para assinatura na procedure
                            insere-assinaturas-testemunhas.
                          - Ajustado aux_vlpreemp para grarvar valor da parcela
                            e nao numero do contrato na procedure 
                            insere-clausula-carta-consignacao.
                          - Na insere-clausula-data-prim-pagto incluido 
                            " Iniciando a partir de " (Lucas R.)
                            
               04/12/2013 - Ajustes na procedure impressao-prnf frame 
                            f_promissoria (Lucas R.)
               
               19/12/2013 - Correçao CPF avalista fiador/interveniente (Lucas).
               
               07/01/2014 - Quando qtpromis = 0, tratar como "Nao Imprimir".
                            (Jorge).
               
               24/01/2014 - Correçao clausula de Condiçoes Gerais das Prestaçoes
                            em contratos Pré-fixados (Lucas).
                                           
               20/02/2014 - Alteraçao do local do estado civil, da crapass para
                            a crapttl (Carlos)
               
               05/03/2014 - Adicionado param. de paginacao em procedure
                            obtem-dados-emprestimos em BO 0002.(Jorge)
                            
               12/03/2014 - Ajuste na procedure 
                            "insere-subclausula1-prazo-tolerancia" para pegar o
                            prazo de atraso da tabela crawepr.qttolatr. (James)
                            
               16/04/2014 - Trocado a posicao dos campos de linha de credito e
                            finalidade. (Reinert)                            
                            
               28/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).             
                            
               09/05/2014 - Retirada a alteracao de 20/02/2014, referente ao 
                            estado civil. Liberacao para junho (Carlos)

               19/05/2014 - Ajuste na busca do nome da cidade que consta na
                            nota promissoria (Douglas - Chamado 155637).
               
               26/05/2014 - Alterado a busca do estado civil, da crapass para
                            crapttl (Douglas - Chamado 131253).
                            
               28/05/2014 - Alteraçao na cláusula de Encargos Financeiros Remuneratórios
                            dos Contratos Price Pré Fixado (Lucas - Chamado 141528). 
                            
               25/06/2014 - Ajuste leitura CRAPRIS e incluso novo parametro na
                            procedure obtem_risco (Daniel) SoftDesk 137892.   
                            
               23/07/2014 - Alteraçao do uso da temp table tt-grupo da include b1wgen0138tt. 
                           (Tiago Castro - RKAM)
                           
               23/07/2014 - (Chamado 131438) Correçao na impressao para incluir  
                            "PARA USO DA DIGITALIZACAO" no cabeçalho.
                            (Tiago Castro - RKAM)

               29/07/2014 - Ajuste na exibiçao dos bens quando for APARTAMENTO
                            (Douglas - Chamado 177022)
                            
               26/08/2014 - Ajustes na procedure gera-impressao-empr - Projeto Cet
                            (Lucas R./Gielow)
                            
               29/08/2014 - Projeto Automatizaçao de Consultas em 
                            Propostas de Crédito (Jonata/RKAM).     
                            
               26/11/2014 - Aumentar formato dos valores das anotacoes
                            das consultas automatizadas. Retirar consultas
                            do 2.do titular (Jonata/RKAM).      
                            
               12/12/2014 - Retirado SKIP(1) do form f_dados_solic na procedure
                            impressao-prnf, pois nao estava quebrando pagina 
                            (Lucas R. #207453)
                            
               31/12/2014 - Ajuste format numero contrato/bordero na area
                            de 'USO DA DIGITALIZACAO'; adequacao ao format
                            pre-definido para nao ocorrer divergencia ao 
                            pesquisar no SmartShare. 
                            (Chamado 181988) - (Fabricio)
                            
               07/01/2015 - Ajuste para zerar campo rel_vldendiv em proc. 
                            impressao-prnf para cada socio. 
                            (Jorge/Gielow) - SD 240168 Melhoria
               
               13/01/2015 - (Chamado 235528) Complemento de Análise 
                            de Propostas Empréstimos e Financiamentos
                            (Tiago Castro - RKAM)
                           
               26/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               26/02/2015 - Alterado o formato do campo nrctrrat para 8 
                            caracters (Douglas - 233714)
                            
               11/03/2015 - Aumentado format da variavel rel_dslimite
                           (Tiago).             

               13/03/2015 - Alteracao da procedure busca-dados-impressao para consultar as 
                            novas aplicaçoes para obter o saldo para resgate. Alteracao da 
                            procedure calcula-apl-aval para levar em conta as o saldo das 
                            novas aplicacoes (Carlos Rafael Tanholi - Projeto Captacao).                                                   
               
               24/03/2015 - Ajustado quebra do relatorio de proposta de emprestimo
                            na rotina impressao-prnf, falta da quebra acarretava 
                            em nao geraçao dos cabeçalhos e tamanho menor na
                            geraçao do pdf SD265086 (Odirlei-Amcom)    
                          
               25/05/2015 - Ajuste para verificar se o emprestimo calcula Multa
                            (James)
                                                                              
               27/05/2015 - Consultas automatizadas (Gabriel-RKAM). 
         
               16/06/2015 - Ajustes no procedimento para controle das quebras de pagina
                           para nao gerar problema com o tamanho da fonte ao gerar PDF
                           SD 296491 (Odirlei-Amcom)
              
               30/06/2015 - Ajuste no controle de quebra de pagina SD300739
                           (Odirlei-AMcom)
               
               30/06/2015 - Ajuste no controle de quebra de pagina SD312420
                           (Odirlei-AMcom)            
                                   
               26/08/2015 - Ajuste no calculo do risco na procedure "impressao-prnf" 
                            (James)
                            
               17/09/2015 - Ajuste no topico 3.1 da proposta pois estava invertido
                            a linha de credito com a finalidade (Lombardi/Jaison)

			   14/09/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                            
               20/11/2015 - Ajustado para que a seja utilizado a procedure
                            obtem-saldo-dia convertida em Oracle
                            (Douglas - Chamado 285228)
               
               16/12/2015 - Ajustado a rotina parecer_credito para controlar 
                            a quebra de pagina e evitar o bug na geracao de pdf
                            que qnd quebra a pagina e a primeira linha esta em branco
                            nao conta como uma pagina nova SD366647 (Odirlei-AMcom)
                                                   
               26/01/2016 - Alteracao da procedure gera-impressao-empr para gerar o
							relatorio para o InternetBank. (Projeto Pre-Aprovado 
							Fase 2 - Carlos Rafael Tanholi)
              
			   10/03/2016 - Ajuste para impressao da proposta para a Esteira
			                PRJ207 - Esteira (Odirlei-AMcom)

               23/09/2016 - Correçao nas TEMP-TABLES colocar NO-UNDO, tt-dados-epr-out (Oscar).
                            Correçao deletar o Handle da b1wgen0001 esta gerando erro na geraçao
                            do PDF para envio da esteira (Oscar).
                            Correçao deletar o Handle da b1wgen0024 esta gerando erro na geraçao
                            do PDF para envio da esteira (Oscar).
                                                   
               10/10/2016 - Ajuste sempre gerar o PDF para esteira de credito (Oscar).                                    
                           
			   07/03/2017 - Ajuste na rotina impressao-prnf devido a conversao da busca-gncdocp
						    (Adriano - SD 614408).
               
			         25/04/2017 - Adicionado chamada para a procedure pc_obrigacao_analise_automatic
						                e novo parametro de saida na procedure valida_impressao. 
						                Projeto 337 - Motor de crédito. (Reinert)
                            
               27/04/2017 - Alterado rotinas gera_co_responsavel e busca_operacoes
                            para chamar respectiva versao oracle
						                Projeto 337 - Motor de crédito. (Odirlei-AMcom)             


               19/04/2017 - Removido DSNACION variavel nao utilizada.
                            PRJ339 - CRM (Odirlei-AMcom)  

               15/09/2017 - Ajuste na variavel de retorno dos co-responsaveis
                            pois estourava para conta com muitos AVAIS (Marcos-Supero)   
                            
               06/10/2017 - SD770151 - Correção de informações na proposta de empréstimo convertida (Marcos-Supero)                            
                            
               04/05/2018 - Alterado para buscar descricao da situacao de conta do oracle. PRJ366 (Lombardi)


			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).								
                                                   
               03/07/2018 - Utilizar trata-impressao-modelo1 para linhas de credito com tpctrato = 4. SCTASK0016657 (Lombardi)
               
               19/10/2018 - P442 - Inclusao de opcao OUTROS VEICULOS onde ha procura por CAMINHAO (Marcos-Envolti)
                                                   
               03/12/2018 - P410 - Ajuste no valor do campo Valor Operacao do item 3 na impressao 
                            da proposta (Douglas Pagel / AMcom).
                                                   
.............................................................................*/

/*................................ DEFINICOES ...............................*/
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }                     
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0024tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen0191tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_qtprecal LIKE crapepr.qtprecal                             NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dslcremp AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_flgimppr AS LOGI                                           NO-UNDO.
DEF VAR aux_flgimpnp AS LOGI                                           NO-UNDO.
DEF VAR aux_flgimpct AS LOGI                                           NO-UNDO.
DEF VAR aux_flgentra AS LOGI                                           NO-UNDO.
DEF VAR aux_nrpagina AS INTE                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdevias AS INTE                                           NO-UNDO.

DEF VAR aux_nmoperad AS CHAR                                           NO-UNDO.
DEF VAR aux_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR aux_cdempres AS INTE                                           NO-UNDO.
DEF VAR aux_dsliquid AS CHAR                                           NO-UNDO.
DEF VAR aux_incontad AS INTE                                           NO-UNDO.
DEF VAR aux_dsmesref AS CHAR                                           NO-UNDO.
DEF VAR aux_contames AS INTE                                           NO-UNDO.
DEF VAR aux_dsbranco AS CHAR                                           NO-UNDO.

DEF VAR aux_retorno  AS CHAR                                           NO-UNDO.

DEF VAR aux_des_erro AS CHAR                                           NO-UNDO.

DEF VAR rel_nmrescop AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_nrdconta AS INTE                                           NO-UNDO.
DEF VAR rel_nrpagina AS INTE    INIT 1                                 NO-UNDO.
DEF VAR rel_nrctremp AS INTE                                           NO-UNDO.
DEF VAR rel_ddmvtolt AS INTE                                           NO-UNDO.
DEF VAR rel_dddpagto AS INTE                                           NO-UNDO.
DEF VAR rel_aamvtolt AS INTE                                           NO-UNDO.
DEF VAR rel_qtpreemp AS INTE                                           NO-UNDO.
DEF VAR rel_dssitdct AS CHAR                                           NO-UNDO.
DEF VAR rel_cdagenci AS INTE                                           NO-UNDO.
DEF VAR rel_nrcepend AS INTE                                           NO-UNDO.
                                                                      
DEF VAR rel_dtadmemp AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR rel_dtdpagto AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR rel_dtadmiss AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR rel_dtfimemp AS DATE    FORMAT "99/99/9999"                    NO-UNDO.
                                                                      
DEF VAR rel_vlemprst AS DECI                                           NO-UNDO.
DEF VAR rel_vlpreemp AS DECI                                           NO-UNDO.
DEF VAR rel_vlsmdtri AS DECI                                           NO-UNDO.
DEF VAR rel_vlsalari AS DECI                                           NO-UNDO.
DEF VAR rel_vlsalcon AS DECI                                           NO-UNDO.
DEF VAR rel_vldrendi AS DECI                                           NO-UNDO.
DEF VAR rel_vlcaptal AS DECI                                           NO-UNDO.
DEF VAR rel_vldsaque AS DECI                                           NO-UNDO.
DEF VAR rel_vlprepla AS DECI                                           NO-UNDO.
DEF VAR rel_txminima AS DECI                                           NO-UNDO.
DEF VAR rel_txbaspre AS DECI                                           NO-UNDO.
DEF VAR rel_vllimcre AS DECI                                           NO-UNDO.
DEF VAR rel_dscatbem AS CHAR                                           NO-UNDO.

DEF VAR rel_dsdmoeda AS CHAR    EXTENT 2 INIT "R$"                     NO-UNDO.
DEF VAR rel_dspreemp AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dspresta AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsemprst AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_nmprimtl AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsliquid AS CHAR    EXTENT 3                               NO-UNDO.
DEF VAR rel_dsmvtolt AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsendres AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsendav1 AS CHAR    EXTENT 3                               NO-UNDO.
DEF VAR rel_dsendav2 AS CHAR    EXTENT 3                               NO-UNDO.
DEF VAR rel_dsfiador AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsfiaseg AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsminima AS CHAR    EXTENT 3                               NO-UNDO.
DEF VAR rel_dsjurfix AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dsjurmor AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_dscmulta AS CHAR    EXTENT 2                               NO-UNDO.
DEF VAR rel_prtlmult AS CHAR    EXTENT 2                               NO-UNDO.

DEF VAR rel_dsobscmt AS CHAR                                           NO-UNDO.
DEF VAR rel_dsobserv AS CHAR                                           NO-UNDO.
DEF VAR rel_dsdpagto AS CHAR    EXTENT 4                               NO-UNDO.
                                                                       
DEF VAR rel_dsbemfin AS CHAR    EXTENT 99                              NO-UNDO.
DEF VAR rel_dsbemseg AS CHAR    EXTENT 99                              NO-UNDO.
DEF VAR rel_dsbemter AS CHAR    EXTENT 99                              NO-UNDO.
DEF VAR rel_nmpropbm AS CHAR    EXTENT 99                              NO-UNDO.
                                                                       
DEF VAR rel_nmdaval1 AS CHAR                                           NO-UNDO.
DEF VAR rel_nmdaval2 AS CHAR                                           NO-UNDO.
DEF VAR rel_dsliqseg AS CHAR                                           NO-UNDO.
DEF VAR rel_dscpfcgc AS CHAR                                           NO-UNDO.
DEF VAR rel_dscpfav1 AS CHAR                                           NO-UNDO.
DEF VAR rel_dscpfav2 AS CHAR                                           NO-UNDO.
DEF VAR rel_dspreapg AS CHAR                                           NO-UNDO.
DEF VAR rel_dsvencto AS CHAR                                           NO-UNDO.
DEF VAR rel_dsvenseg AS CHAR                                           NO-UNDO.
DEF VAR rel_dsdtraco AS CHAR                                           NO-UNDO.
DEF VAR rel_dsliqant AS CHAR                                           NO-UNDO.
DEF VAR rel_nmcidade AS CHAR                                           NO-UNDO.
DEF VAR rel_nmbairro AS CHAR                                           NO-UNDO.
DEF VAR rel_cdufresd AS CHAR                                           NO-UNDO.
                                                                       
DEF VAR rel_dsfinemp AS CHAR                                           NO-UNDO.
DEF VAR rel_dslcremp AS CHAR                                           NO-UNDO.
DEF VAR rel_dsmesref AS CHAR                                           NO-UNDO.
DEF VAR rel_dsjurvar AS CHAR                                           NO-UNDO.
DEF VAR rel_nmempres AS CHAR                                           NO-UNDO.
DEF VAR rel_nmdsecao AS CHAR                                           NO-UNDO.
DEF VAR rel_tpctremp AS CHAR                                           NO-UNDO.
DEF VAR rel_nrcpfcgc AS CHAR                                           NO-UNDO.
DEF VAR rel_dsagenci AS CHAR                                           NO-UNDO.
DEF VAR rel_dsctremp AS CHAR                                           NO-UNDO.
DEF VAR rel_nmcjgav1 AS CHAR                                           NO-UNDO.
DEF VAR rel_nmcjgav2 AS CHAR                                           NO-UNDO.
DEF VAR rel_dscfcav1 AS CHAR                                           NO-UNDO.
DEF VAR rel_dscfcav2 AS CHAR                                           NO-UNDO.
DEF VAR rel_dscooper AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0002 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0043 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0056 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0030 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0027 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0006 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0001 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0021 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0028 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.
DEF VAR h-b1wgen0138 AS HANDLE                                         NO-UNDO.

DEF VAR aux_vlsldrgt AS DEC                                            NO-UNDO.
DEF VAR aux_vlsldtot AS DEC                                            NO-UNDO.
DEF VAR aux_vlsldapl AS DEC                                            NO-UNDO.

DEF TEMP-TABLE w-co-responsavel  NO-UNDO LIKE tt-dados-epr.  

DEF TEMP-TABLE tt-crapavl NO-UNDO
    FIELD nrdconta  LIKE crapavl.nrdconta.

DEF TEMP-TABLE tt-operati                                              NO-UNDO
    FIELD nrctremp  LIKE tt-dados-epr.nrctremp
    FIELD vlsdeved  LIKE tt-dados-epr.vlsdeved
    FIELD dspreapg  AS CHAR 
    FIELD vlpreemp  LIKE tt-dados-epr.vlpreemp
    FIELD qtprecal  LIKE tt-dados-epr.qtprecal
    FIELD dslcremp  LIKE tt-dados-epr.dslcremp
    FIELD dsfinemp  LIKE tt-dados-epr.dsfinemp  
    FIELD dsliqant  AS CHAR 
    FIELD garantia  AS CHAR FORMAT "x(18)"
    FIELD dsidenti AS CHAR.

DEF TEMP-TABLE cratepr                                                 NO-UNDO
    FIELD nrctremp  AS INTE
    FIELD dsgarant  AS CHAR FORMAT "x(18)".

/*................................. FUNCTIONS ..............................*/

/* Verifica da TAB016 se o interveniente esta habilitado */
FUNCTION verifica_interv RETURN LOGICAL 
    (par_cdagenci AS INTE, 
     par_cdcooper AS INTE):

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_flginter AS LOGI                                       NO-UNDO.
   
    DO aux_contador = 1 TO 2:
   
        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "PROPOSTEPR"   AND
                           craptab.tpregist = par_cdagenci   NO-LOCK NO-ERROR.
   
        IF  NOT AVAILABLE craptab  THEN
            IF   aux_contador > 1  THEN
                 .
            ELSE
                DO:
                    par_cdagenci = 0.
                    NEXT.
                END.
        ELSE
            ASSIGN aux_flginter = LOGICAL(SUBSTR(craptab.dstextab,56,03)).
    END.
   
    RETURN aux_flginter.

END.


FUNCTION valida_proprietario RETURNS CHAR 
    (par_nrcpfbem AS DEC,
     par_cdcooper AS INTE):

    /* Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
        parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE */
   
    DEF BUFFER crabass FOR crapass.
       
    /* CONTRATANTE */
    FIND FIRST crabass WHERE crabass.cdcooper = par_cdcooper       AND
                             crabass.nrcpfcgc = par_nrcpfbem       AND
                             crabass.nrdconta = crawepr.nrdconta
                             NO-LOCK NO-ERROR.
                             
    IF  AVAILABLE crabass  THEN
        RETURN crabass.nmprimtl.
         
    /* INTERVENIENTE ANUENTE */
    FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper       AND 
                             crapavt.nrcpfcgc = par_nrcpfbem       AND
                             crapavt.nrdconta = crawepr.nrdconta   AND
                             crapavt.nrctremp = crawepr.nrctremp   AND
                             crapavt.tpctrato = 9 NO-LOCK NO-ERROR.
                             
    IF  AVAILABLE crapavt  THEN
        RETURN crapavt.nmdavali.

    /* PRIMEIRO TITULAR caso nao encontrar interveniente ou proprietário */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper       AND 
                             crapass.nrdconta = crawepr.nrdconta   NO-LOCK NO-ERROR.

    IF  AVAILABLE crapass  THEN
        RETURN crapass.nmprimtl.
         
    RETURN "".

END FUNCTION.

/*........................... PROCEDURES EXTERNAS ..........................*/

/****************************************************************************/
/**     Procedure para busca de dados da impressao                         **/
/****************************************************************************/
PROCEDURE busca-dados-impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.  
    
    DEF OUTPUT PARAM par_vlsmdtri AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlcaptal AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlprepla AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotapl AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotrpp AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vlstotal AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotemp AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotccr AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM par_vltotpre AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR par_qtprecal AS INTE                                    NO-UNDO.
    DEF VAR par_flgativo AS LOGI                                    NO-UNDO.
    DEF VAR par_nrctrhcj AS INTE                                    NO-UNDO.
    DEF VAR par_flgliber AS logi                                    NO-UNDO.
	DEF VAR aux_dtassele AS DATE                                    NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR                                    NO-UNDO. /* Data de corte */

    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
        SET h-b1wgen0001.

    ASSIGN aux_retorno = "NOK".    

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        EMPTY TEMP-TABLE tt-erro.

        IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0001.".
                LEAVE Busca.
            END.
       
        RUN carrega_medias IN h-b1wgen0001 (INPUT   par_cdcooper,
                                            INPUT   par_cdagenci,
                                            INPUT   par_nrdcaixa, 
                                            INPUT   par_cdoperad,
                                            INPUT   par_nrdconta,
                                            INPUT   par_dtmvtolt,
                                            INPUT   par_idorigem,
                                            INPUT   par_idseqttl,
                                            INPUT   par_nmdatela,
                                            INPUT   par_flgerlog,
                                           OUTPUT TABLE tt-erro,
                                           OUTPUT TABLE tt-medias,
                                           OUTPUT TABLE tt-comp_medias).

                DELETE PROCEDURE h-b1wgen0001. 
        
        IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".

        FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.
       
        IF AVAIL tt-comp_medias THEN
            ASSIGN  par_vlsmdtri = tt-comp_medias.vlsmdtri.

        /* SALDOS */
        /* Buscar o valor do saldo */
        TRANS_SALDO:
        DO TRANSACTION ON ERROR UNDO, RETRY:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
    
            /* Utilizar o tipo de busca A, para carregar do dia anterior
              (U=Nao usa data, I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1) */ 
            RUN STORED-PROCEDURE pc_obtem_saldo_dia_prog
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad, 
                                         INPUT par_nrdconta,
                                         INPUT par_dtmvtolt,
                                         INPUT "A", /* Tipo Busca */
                                         OUTPUT 0,
                                         OUTPUT "").
    
            CLOSE STORED-PROC pc_obtem_saldo_dia_prog
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = ""
                   aux_cdcritic = pc_obtem_saldo_dia_prog.pr_cdcritic 
                                      WHEN pc_obtem_saldo_dia_prog.pr_cdcritic <> ?
                   aux_dscritic = pc_obtem_saldo_dia_prog.pr_dscritic
                                      WHEN pc_obtem_saldo_dia_prog.pr_dscritic <> ?. 


            IF aux_cdcritic <> 0   OR
               aux_dscritic <> ""  THEN
                DO:
                    IF aux_dscritic = "" THEN
                        DO:
                            FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                         NO-LOCK NO-ERROR.
                
                            IF AVAIL crapcri THEN
                                ASSIGN aux_dscritic = crapcri.dscritic.
                
                        END.

                    LEAVE Busca.
                END.
                                                      
            FIND FIRST wt_saldos NO-LOCK NO-ERROR.
            IF AVAIL wt_saldos THEN
                DO:
                    ASSIGN par_vlstotal = wt_saldos.vlsdchsl + 
                                          wt_saldos.vlsdblfp + 
                                          wt_saldos.vlsdblpr + 
                                          wt_saldos.vlsdbloq + 
                                          wt_saldos.vlsddisp.
                END.
        END.

        RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
            SET h-b1wgen0021.
      
        IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0021.".
                LEAVE Busca.
            END.

        RUN obtem_dados_capital IN h-b1wgen0021(INPUT par_cdcooper,
                                                INPUT par_cdagenci,
                                                INPUT par_nrdcaixa,
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_nrdconta,
                                                INPUT par_idseqttl,
                                                INPUT par_dtmvtolt,
                                                INPUT par_flgerlog,
                                               OUTPUT TABLE tt-dados-capital,
                                               OUTPUT TABLE tt-erro).
        DELETE PROCEDURE h-b1wgen0021.

        IF  RETURN-VALUE <> "OK"  THEN
            RETURN "NOK".
      
        FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
      
        IF AVAIL tt-dados-capital THEN
            ASSIGN  par_vlcaptal = tt-dados-capital.vlcaptal
                    par_vlprepla = tt-dados-capital.vlprepla.
      
                
                /* NOVOS PRODUTOS DE CAPTACAO */
        /** Saldo das aplicacoes **/
        RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
            SET h-b1wgen0081.
      
        IF  VALID-HANDLE(h-b1wgen0081)  THEN
            DO:
                ASSIGN aux_vlsldtot = 0.
    
      
                        RUN obtem-dados-aplicacoes IN h-b1wgen0081 (INPUT par_cdcooper,
                                                                    INPUT par_cdagenci,
                                                                    INPUT par_nrdcaixa,
                                                                    INPUT par_cdoperad,
                                                                    INPUT par_nmdatela,
                                                                    INPUT par_idorigem,
                                                                    INPUT par_nrdconta,
                                                                    INPUT par_idseqttl,
                                                                    INPUT 0,
                                                                    INPUT par_cdprogra,
                                                                    INPUT par_flgerlog,
                                                                    INPUT ?,
                                                                    INPUT ?,
                                                                   OUTPUT par_vltotapl,
                                                                   OUTPUT TABLE tt-saldo-rdca,
                                                                   OUTPUT TABLE tt-erro).
    
                IF  RETURN-VALUE = "NOK"  THEN
                    DO:
                        DELETE PROCEDURE h-b1wgen0081.
                        
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                     
                        IF  AVAILABLE tt-erro  THEN
                            MESSAGE tt-erro.dscritic.
                        ELSE
                            MESSAGE "Erro nos dados das aplicacoes.".
            
                        NEXT.
                    END.
    
        DELETE PROCEDURE h-b1wgen0081.
            END.
         
           DO TRANSACTION ON ERROR UNDO, RETRY:
             /*Busca Saldo Novas Aplicacoes*/
             
             { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
              RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
                aux_handproc = PROC-HANDLE NO-ERROR
                                        (INPUT par_cdcooper, /* Código da Cooperativa */
                                         INPUT '1',            /* Código do Operador */
                                         INPUT par_nmdatela, /* Nome da Tela */
                                         INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                         INPUT par_nrdconta, /* Número da Conta */
                                         INPUT 1,            /* Titular da Conta */
                                         INPUT 0,            /* Número da Aplicaçao / Parâmetro Opcional */
                                         INPUT par_dtmvtolt, /* Data de Movimento */
                                         INPUT 0,            /* Código do Produto */
                                         INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                         INPUT 0,            /* Identificador de Log (0 – Nao / 1 – Sim) */
                                        OUTPUT 0,            /* Saldo Total da Aplicaçao */
                                        OUTPUT 0,            /* Saldo Total para Resgate */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descriçao da crítica */
              
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
    
              IF aux_cdcritic <> 0   OR
                 aux_dscritic <> ""  THEN
                 DO:
                     IF aux_dscritic = "" THEN
                        DO:
                           FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                              NO-LOCK NO-ERROR.
            
                           IF AVAIL crapcri THEN
                              ASSIGN aux_dscritic = crapcri.dscritic.
            
                        END.
            
                     CREATE tt-erro.
            
                     ASSIGN tt-erro.cdcritic = aux_cdcritic
                            tt-erro.dscritic = aux_dscritic.
     
                             RETURN "NOK".
     
                 END.
                                                  
             ASSIGN par_vltotapl = aux_vlsldrgt + par_vltotapl.
         END.
         /*Fim Busca Saldo Novas Aplicacoes*/
                
        RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
            SET h-b1wgen0006.
     
        IF  NOT VALID-HANDLE(h-b1wgen0006)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0006.".
                LEAVE Busca.
            END.
     
        RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT 0,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT par_inproces,
                                               INPUT par_nmdatela,
                                               INPUT FALSE,
                                              OUTPUT par_vltotrpp,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-dados-rpp). 
    
        DELETE PROCEDURE h-b1wgen0006.
    
        IF  RETURN-VALUE <> "OK"  THEN
            RETURN "NOK".
      
        RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT 
            SET h-b1wgen0002.
      
        IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0002.".
                LEAVE Busca.
            END.
    
        RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT par_cdcooper,
                                               INPUT par_cdagenci, 
                                               INPUT par_nrdcaixa, 
                                               INPUT par_cdoperad, 
                                               INPUT par_nmdatela, 
                                               INPUT par_idorigem, 
                                               INPUT par_nrdconta, 
                                               INPUT par_idseqttl, 
                                               INPUT par_dtmvtolt, 
                                               INPUT par_dtmvtopr, 
                                               INPUT 0,
                                               INPUT par_cdprogra, 
                                               INPUT par_inproces, 
                                               INPUT par_flgerlog, 
                                              OUTPUT par_vltotemp, 
                                              OUTPUT par_vltotpre, 
                                              OUTPUT par_qtprecal,
                                              OUTPUT TABLE tt-erro).
    
        DELETE PROCEDURE h-b1wgen0002.
    
        IF  RETURN-VALUE <> "OK"  THEN
            RETURN "NOK".
     
        RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT 
            SET h-b1wgen0028.
     
        IF  NOT VALID-HANDLE(h-b1wgen0028)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0028.".
                LEAVE Busca.
            END.
    
        RUN lista_cartoes IN h-b1wgen0028 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,  
                                           INPUT par_nrdcaixa,  
                                           INPUT par_cdoperad,  
                                           INPUT par_nrdconta,  
                                           INPUT par_idorigem,  
                                           INPUT par_idseqttl,  
                                           INPUT par_nmdatela,  
                                           INPUT par_flgerlog,  
                                          OUTPUT par_flgativo,  
                                          OUTPUT par_nrctrhcj,  
                                          OUTPUT par_flgliber,
										  OUTPUT aux_dtassele,
										  OUTPUT aux_dsvlrprm,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-cartoes,
                                          OUTPUT TABLE tt-lim_total).
     
        DELETE PROCEDURE h-b1wgen0028.
    
        IF  RETURN-VALUE <> "OK"  THEN
            RETURN "NOK".
     
        FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
     
        IF  AVAIL tt-lim_total THEN
            ASSIGN  par_vltotccr = tt-lim_total.vltotccr.

    END. /* Busca */

    IF  aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_retorno = "OK".
                                       
    IF  par_flgerlog  THEN
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

/****************************************************************************/
/**     Procedure para tratamento da impressao                             **/
/****************************************************************************/
PROCEDURE gera-impressao-empr:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgescra AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrpagina AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtcalcul AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_promsini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgentra AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_flgentrv AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO. 
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                                        
                                                                               
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR  par_vlsmdtri AS DECI                                   NO-UNDO.
    DEF VAR  par_vlcaptal AS DECI                                   NO-UNDO.
    DEF VAR  par_vlprepla AS DECI                                   NO-UNDO.
    DEF VAR  par_vltotapl AS DECI                                   NO-UNDO.
    DEF VAR  par_vltotrpp AS DECI                                   NO-UNDO.
    DEF VAR  par_vlstotal AS DECI                                   NO-UNDO.
    DEF VAR  par_vltotemp AS DECI                                   NO-UNDO.
    DEF VAR  par_vltotccr AS DECI                                   NO-UNDO.
    DEF VAR  par_vltotpre AS DECI                                   NO-UNDO.
    DEF VAR  aux_flimpcet AS LOG                                    NO-UNDO.

    DEF VAR  aux_nmdoarqv AS CHAR                                   NO-UNDO.
    DEF VAR  aux_dtlibera AS DATE                                   NO-UNDO.
    DEF VAR  aux_dssrvarq AS CHAR                                   NO-UNDO.
    DEF VAR  aux_dsdirarq AS CHAR                                   NO-UNDO.

    ASSIGN aux_nrpagina = par_nrpagina
           aux_flgentra = par_flgentra
           aux_dsmesref = "janeiro,fevereiro,marco,abril," +
                          "maio,junho,julho,agosto,setembro," +
                          "outubro,novembro,dezembro"

           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_nrdevias = 1
           aux_retorno = "NOK".

    Gera: DO ON ERROR UNDO Gera, LEAVE Gera:
        EMPTY TEMP-TABLE tt-erro.

        FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crawepr   THEN
            DO:
                ASSIGN aux_cdcritic = 510
                       aux_dscritic = "".

                LEAVE Gera.
                  
            END.

        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                           craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE craplcr   THEN
            DO:
               ASSIGN aux_cdcritic = 363
                      aux_dscritic = "".
        
               LEAVE Gera.
            END.

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapcop  THEN
            DO:
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".

                LEAVE Gera.
       
            END.

        IF  (crawepr.flgimppr   OR   crawepr.flgimpnp OR  
            (par_idorigem = 9 AND par_idimpres = 3))  THEN  /* Sempre gerar o PDF para esteira de credito */
            DO:
                IF  par_idimpres = 1  THEN /* COMPLETA */
                    DO:
                        aux_dstransa = "Gerar impressao do contrato e " +
                                       "nota promissoria de emprestimo.".
        
                        IF  par_flgescra  THEN
                            DO:
                                ASSIGN aux_cdcritic = 36
                                       aux_dscritic = "".

                                LEAVE Gera.
                        
                            END.
            
                        ASSIGN aux_flgimpct = TRUE
                               aux_flgimpnp = crawepr.flgimpnp
                               aux_flgimppr = FALSE. /* crawepr.flgimppr */ 
        
                    END.
                ELSE
                IF  par_idimpres = 2  THEN /* CONTRATO */
                    DO:
                        aux_dstransa = "Gerar impressao do contrato " +
                                       "de emprestimo.".
                
                        ASSIGN aux_flgimpct = TRUE
                               aux_flgimpnp = FALSE
                               aux_flgimppr = FALSE.
                    END.
                ELSE
                IF  par_idimpres = 3  THEN /* PROPOSTA */
                    DO:
                        aux_dstransa = "Gerar impressao da proposta de " +
                                       "emprestimo.".
                
                         IF  (NOT crawepr.flgimppr) AND 
                             (par_idorigem <> 9) /* Esteira */  THEN 
                             DO:
                                 ASSIGN aux_cdcritic = 14
                                        aux_dscritic = "".

                                 LEAVE Gera.

                             END.
                         
                         ASSIGN aux_flgimpct = FALSE
                                aux_flgimpnp = FALSE
                                aux_flgimppr = TRUE.
                    END.
                ELSE
                IF  par_idimpres = 4  THEN
                    DO:
                        aux_dstransa = "Gerar impressao da nota promissoria " +
                                       "de emprestimo".
                
                        IF  crawepr.qtpromis = 0 THEN
                            DO:
                               ASSIGN aux_cdcritic = 0
                                      aux_dscritic = "Cooperativa configurada" +
                                                      " para nao gerar nota "  +
                                                      "promissoria".
                               LEAVE Gera.
                            END.

                        IF  NOT crawepr.flgimpnp   THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Contrato configurado " +
                                                      "para nao gerar nota "  +
                                                      "promissoria".
                                    
                                LEAVE Gera.
                       
                            END.

                        ASSIGN aux_flgimpct = FALSE
                               aux_flgimpnp = TRUE
                               aux_flgimppr = FALSE.
                    END.
                ELSE
                    aux_dstransa = "Gerar impressoes de emprestimo.".
            END.
        ELSE
            ASSIGN aux_flgimpct = TRUE
                   aux_flgimpnp = FALSE
                   aux_flgimppr = FALSE.

        IF  par_idimpres = 6  THEN /* CET */
            DO:
                aux_dstransa = "Gerar impressao do custo efetivo total".                
                ASSIGN aux_flimpcet = TRUE /* imprimir cet */
                       aux_flgimpct = FALSE
                       aux_flgimpnp = FALSE
                       aux_flgimppr = FALSE.
            END.

/*********************************************************************************************************************************************
**********************************************************************************************************************************************
                                                 NOVAS PROCEDURES DE MONTAGEM DE CONTRATOS
**********************************************************************************************************************************************
**********************************************************************************************************************************************/

        /* Se nao imprime nota promissória em impressao COMPLETA... */
        IF  NOT crawepr.flgimpnp AND
            par_idimpres = 1     THEN /* COMPLETA */
            ASSIGN par_idimpres = 2. /* Entao imprime apenas CONTRATO */

        /* Se for CONTRATO... */
        IF  aux_flgimpct      AND
            par_idimpres <> 1 THEN /* COMPLETA */
            DO:
                RUN nova-impressao-contratos (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_cdoperad,
                                              INPUT par_nrdcaixa,
                                              INPUT par_nmdatela,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dsiduser,
                                              INPUT par_idorigem,
                                              INPUT par_recidepr,
                                              INPUT par_idimpres,
                                              INPUT par_flgemail,
                                             OUTPUT par_nmarqimp,
                                             OUTPUT par_nmarqpdf,
                                             OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".               

                /* Se nao for completa */
                IF  par_idimpres <> 1 THEN
                    RETURN "OK".
            END.
            
/*********************************************************************************************************************************************
**********************************************************************************************************************************************
                                             FINAL CHAMADA NOVAS PROCEDURES DE MONTAGEM DE CONTRATOS
**********************************************************************************************************************************************
**********************************************************************************************************************************************/

        RUN busca-dados-impressao ( INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem,
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtopr,
                                    INPUT par_flgerlog,
                                    INPUT par_inproces,
                                    INPUT par_cdprogra,
                                    INPUT crawepr.nrctremp,
                                   OUTPUT par_vlsmdtri,
                                   OUTPUT par_vlcaptal,
                                   OUTPUT par_vlprepla,
                                   OUTPUT par_vltotapl,
                                   OUTPUT par_vltotrpp,
                                   OUTPUT par_vlstotal,
                                   OUTPUT par_vltotemp,
                                   OUTPUT par_vltotccr,
                                   OUTPUT par_vltotpre,
                                   OUTPUT TABLE tt-erro).


        ASSIGN aux_retorno = "NOK".
        
        IF  RETURN-VALUE <> "OK"  THEN
            RETURN "NOK".
               
        /* Se nao for cet cria o arquivo normalmente */
        IF  NOT aux_flimpcet THEN
            DO:
                ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                      par_dsiduser.
            
                UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
                ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                       aux_nmarqimp = aux_nmarquiv + ".ex"
                       aux_nmarqpdf = aux_nmarquiv + ".pdf".
            END.

        IF  NOT CAN-DO("1,2,3,4,6",STRING(par_idimpres))  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de impressao invalida.".

                LEAVE Gera.
                       
             END.
    
        /* Se for CET */
        IF  aux_flimpcet THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAIL crapass THEN
                    RETURN "NOK".
                
                FIND  crapepr WHERE crapepr.cdcooper = crawepr.cdcooper   AND
                                    crapepr.nrdconta = crawepr.nrdconta   AND
                                    crapepr.nrctremp = crawepr.nrctremp
                                    NO-LOCK NO-ERROR.

                IF  AVAIL crapepr THEN
                    ASSIGN aux_dtlibera = crapepr.dtmvtolt.
                ELSE
                    ASSIGN aux_dtlibera = crawepr.dtlibera. 

                RUN imprime_cet (INPUT par_cdcooper,     
                                 INPUT par_dtmvtolt, 
                                 INPUT par_cdprogra, 
                                 INPUT par_nrdconta, 
                                 INPUT crapass.inpessoa, 
                                 INPUT craplcr.cdusolcr, 
                                 INPUT craplcr.cdlcremp, 
                                 INPUT crawepr.tpemprst, 
                                 INPUT crawepr.nrctremp, 
                                 INPUT (IF aux_dtlibera <> ? THEN
                                           aux_dtlibera
                                        ELSE par_dtmvtolt), 
                                 INPUT TODAY, 
                                 INPUT crawepr.vlemprst, 
                                 INPUT crawepr.txmensal, 
                                 INPUT crawepr.vlpreemp, 
                                 INPUT crawepr.qtpreemp, 
                                 INPUT crawepr.dtdpagto, 
                                OUTPUT aux_nmdoarqv,
                                OUTPUT aux_dscritic).

                IF  RETURN-VALUE <> "OK" THEN
                    DO: 
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
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
                ELSE
                    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                          "/rl/" + aux_nmdoarqv
                           aux_nmarqimp = aux_nmarquiv + ".ex"  
                           aux_nmarqpdf = aux_nmarquiv + ".pdf". 

            END. /* Fim do Se for CET */

        IF  NOT aux_flimpcet THEN
            DO:
                IF  craplcr.tpctrato = 1 OR craplcr.tpctrato = 4  THEN
                    DO:
                        IF  aux_flgimpct  THEN
                            IF  aux_nrpagina = 0  THEN
                                aux_nrpagina = -1.
        
                        RUN trata-impressao-modelo1 (INPUT par_cdcooper,
                                                     INPUT par_cdoperad,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_idseqttl,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                     INPUT par_recidepr,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtcalcul,
                                                     INPUT par_flgerlog,
                                                     INPUT par_idorigem,
                                                    OUTPUT TABLE tt-erro).
        
        
                        IF  RETURN-VALUE <> "OK"  THEN
                            RETURN "NOK".
                    END.
                ELSE
                IF  craplcr.tpctrato = 2 THEN
                    DO:
                        RUN trata-impressao-modelo2 (INPUT par_cdcooper,
                                                     INPUT par_cdoperad,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_idseqttl,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                     INPUT par_recidepr,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtcalcul,
                                                     INPUT par_flgerlog,
                                                     INPUT par_idorigem,
                                                    OUTPUT TABLE tt-erro).
            
                        
                        IF  RETURN-VALUE <> "OK"  THEN
                            RETURN "NOK".
                    END.
                ELSE
                IF  craplcr.tpctrato = 3 THEN
                    DO:
                        RUN trata-impressao-modelo3 (INPUT par_cdcooper,       
                                                     INPUT par_cdoperad,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_idseqttl,
                                                     INPUT par_nmdatela,
                                                     INPUT par_nrdconta,
                                                     INPUT par_recidepr,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtcalcul,
                                                     INPUT par_flgerlog,
                                                     INPUT par_idorigem,
                                                    OUTPUT TABLE tt-erro).
            
                        IF  RETURN-VALUE <> "OK"  THEN
                            RETURN "NOK".
        
                        IF  NOT aux_flgimpct   THEN
                            UNIX SILENT VALUE("> " + aux_nmarqimp + " 2> /dev/null"). 
                    END.
        
                /*  Emissao da Proposta de Emprestimo e Nota promissoria  */
                IF  aux_flgimppr OR crawepr.flgimpnp THEN  
                    DO:
                        RUN impressao-prnf (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_cdoperad,
                                            INPUT par_nmdatela,
                                            INPUT par_idorigem,
                                            INPUT par_nrdconta,
                                            INPUT par_idseqttl,
                                            INPUT par_recidepr, 
                                            INPUT aux_nmarqimp,
                                            INPUT aux_flgimppr,
                                            INPUT par_dtmvtolt,
                                            INPUT par_vlsmdtri,
                                            INPUT par_vlcaptal,
                                            INPUT par_vlprepla,
                                            INPUT par_vltotapl,
                                            INPUT par_vltotrpp,
                                            INPUT par_vlstotal,
                                            INPUT par_vltotccr,
                                            INPUT par_vltotemp,
                                            INPUT par_vltotpre,
                                            INPUT par_dtmvtopr,
                                            INPUT par_inproces,
                                            INPUT par_promsini,
                                            INPUT par_cdprogra,
                                            INPUT par_flgerlog,
                                            INPUT par_dtcalcul,
                                            INPUT par_idimpres,
                                           OUTPUT TABLE tt-erro).
        
                        IF  RETURN-VALUE <> "OK"  THEN
                            RETURN "NOK".
        
                    END.
            END.

        IF  par_flgemail      OR   /** Enviar proposta via e-mail **/
                
           (par_idorigem = 5 OR     /** Ayllos Web **/
            par_idorigem = 3 OR     /** InternetBank **/
			par_idorigem = 9) THEN  /** Esteira de credito **/ 
            DO:
                Email: DO WHILE TRUE:
                    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                        SET h-b1wgen0024.
    
                    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                        DO:
                            ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                  "b1wgen0024.".
                                                  
                            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                                DELETE PROCEDURE h-b1wgen0024.    
                      
                            LEAVE Gera.
                        END.
                    
                    RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                            INPUT aux_nmarqpdf). 
                   
                    /** Copiar pdf para visualizacao no Ayllos WEB **/
                    IF  par_idorigem = 5  THEN
                        DO:
                            IF  SEARCH(aux_nmarqpdf) = ?  THEN
                                DO:
                                    ASSIGN aux_dscritic = "Nao foi possivel " +
                                                          "gerar a impressao.".
                                                          
                                    IF  VALID-HANDLE(h-b1wgen0024)  THEN
                                        DELETE PROCEDURE h-b1wgen0024.    
                                                         
                                    LEAVE Gera.                      
                                END.

                            UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                            '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                            ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                            '/temp/" 2>/dev/null').
                        END.

					/** Copiar pdf para visualizacao no Internet Bank **/
                    ELSE IF par_idorigem = 3 THEN
                    DO:
            
                        IF  SEARCH(aux_nmarqpdf) = ?  THEN
                        DO:
                            ASSIGN aux_dscritic = "Nao foi possivel " +
                                                  "gerar a impressao.".
                            
                            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                                DELETE PROCEDURE h-b1wgen0024.    
                            
                            LEAVE Gera.                      
                        END.
              
                        /* Regra para permitir a liberacao do piloto do novo IB 
                           Barramento SOA fara o download o PDF */
                        IF  par_cdprogra = "" THEN DO:              
                        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
                        RUN STORED-PROCEDURE pc_efetua_copia_arq_ib 
                            aux_handproc = PROC-HANDLE NO-ERROR
                                             (INPUT par_cdcooper, /* Cooperativa */
                                              INPUT aux_nmarqpdf, /* Arquivo PDF */
                                             OUTPUT "").
    
                        CLOSE STORED-PROC pc_efetua_copia_arq_ib 
                              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
                        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
                        ASSIGN aux_dscritic = ""
                               aux_dscritic = pc_efetua_copia_arq_ib.pr_des_erro 
                                              WHEN pc_efetua_copia_arq_ib.pr_des_erro <> ?.
    
                        IF  aux_dscritic <> ""  THEN
                        DO:                                
                           IF  VALID-HANDLE(h-b1wgen0024)  THEN
                               DELETE PROCEDURE h-b1wgen0024.    
                            
                            LEAVE Gera.
                        END.            
                        END.
                        ELSE DO:
                            FOR FIRST crapprm WHERE crapprm.cdcooper = 0              AND
                                                    crapprm.nmsistem = "CRED"         AND
                                                    crapprm.cdacesso = "ROOT_DIRCOOP" NO-LOCK. END.
                                                    
                            IF  NOT AVAIL crapprm  THEN
                                DO:
                                    ASSIGN aux_dscritic = "Diretorio da cooperativa nao parametrizado.".
                    
                                    IF  VALID-HANDLE(h-b1wgen0024)  THEN
                                        DELETE PROCEDURE h-b1wgen0024.    
                                
                                    LEAVE Gera.
                    END.

                            /* Separar nome do arquivo do diretorio.
                               Diretorio ROOT /usr/coop/ deve ser substituido pelo parametrizado pois o comando sera executado em PLSQL. */
                            ASSIGN aux_dsdirarq = REPLACE(SUBSTR(aux_nmarqpdf,1,R-INDEX(aux_nmarqpdf,"/")),"/usr/coop/",crapprm.dsvlrprm)
                                   aux_nmdoarqv = SUBSTR(aux_nmarqpdf,R-INDEX(aux_nmarqpdf,"/") + 1).
                            
                            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }                                                                               
                            
                            RUN STORED-PROCEDURE pc_copia_arq_para_download 
                                aux_handproc = PROC-HANDLE NO-ERROR
                                                 (INPUT par_cdcooper, /* Cooperativa                       */
                                                  INPUT aux_dsdirarq, /* Diretorio do arquivo              */
                                                  INPUT aux_nmdoarqv, /* Nome do arquivo                   */
                                                  INPUT 0,        /* Mover arquivo para novo diretorio */
                                                 OUTPUT "",
                                                 OUTPUT "",
                                                 OUTPUT "").
        
                            CLOSE STORED-PROC pc_copia_arq_para_download 
                                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        
                            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
                            ASSIGN aux_dscritic = ""
                                   aux_dssrvarq = ""
                                   aux_dsdirarq = ""
                                   aux_dscritic = pc_copia_arq_para_download.pr_des_erro 
                                                  WHEN pc_copia_arq_para_download.pr_des_erro <> ?
                                   aux_dssrvarq = pc_copia_arq_para_download.pr_dssrvarq 
                                                  WHEN pc_copia_arq_para_download.pr_dssrvarq <> ?
                                   aux_dsdirarq = pc_copia_arq_para_download.pr_dsdirarq 
                                                  WHEN pc_copia_arq_para_download.pr_dsdirarq <> ?.
        
                            IF  aux_dscritic <> ""  THEN
                            DO:                                
                               IF  VALID-HANDLE(h-b1wgen0024)  THEN
                                   DELETE PROCEDURE h-b1wgen0024.    
                                
                                LEAVE Gera.
                            END.                           
                        END.
                    
                    END.

                    /** Enviar proposta para o PAC Sede via e-mail **/
                    IF  par_flgemail  THEN
                        DO:
                            RUN executa-envio-email IN h-b1wgen0024 
                                                   (INPUT par_cdcooper, 
                                                    INPUT par_cdagenci, 
                                                    INPUT par_nrdcaixa, 
                                                    INPUT par_cdoperad, 
                                                    INPUT par_nmdatela, 
                                                    INPUT par_idorigem, 
                                                    INPUT par_dtmvtolt, 
                                                    INPUT 488,
                                                    INPUT aux_nmarqimp, 
                                                    INPUT aux_nmarqpdf,
                                                    INPUT par_nrdconta, 
                                                    INPUT 90 /* Emprest */, 
                                                    INPUT crawepr.nrctremp, 
                                                   OUTPUT TABLE tt-erro).

                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                   
                                    IF  AVAILABLE tt-erro  THEN
                                        ASSIGN aux_dscritic = tt-erro.dscritic.
                                    ELSE
                                        ASSIGN aux_dscritic = 
                                                         "Nao foi possivel " +
                                                         "gerar a impressao.".
                                   
                                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + 
                                                       "* 2>/dev/null"). 
                                   
                                    IF  VALID-HANDLE(h-b1wgen0024)  THEN
                                        DELETE PROCEDURE h-b1wgen0024.    
                                    
                                    LEAVE Gera.
                                END.
                        END.

                    IF  VALID-HANDLE(h-b1wgen0024)  THEN
                        DELETE PROCEDURE h-b1wgen0024.    

                    LEAVE Email.

                END. /** Fim do DO WHILE TRUE **/

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.
                
                IF  par_idorigem = 5  THEN
                    DO:
                        IF  aux_nmarquiv <> "" THEN
                            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                    END.
                ELSE
                IF  par_idorigem = 9  THEN
				    DO:
					  UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2>/dev/null").
				    END.
                  ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
         END. 
         
		 /* Para esteira deve enviar tambem o caminho */
        IF  par_idorigem = 3 AND par_cdprogra = "INTERNETBANK"  THEN
            ASSIGN par_nmarqpdf = aux_dsdirarq + aux_nmdoarqv
                   par_nmarqimp = aux_dssrvarq
                   par_flgentrv = aux_flgentra.
        ELSE
            DO:
                IF  par_idorigem = 9 THEN
		   ASSIGN par_nmarqpdf = aux_nmarqpdf.
		 ELSE
                    ASSIGN par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

         ASSIGN par_nmarqimp = aux_nmarqimp
                par_flgentrv = aux_flgentra.
            END.

    END. /* Gera */

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            EMPTY TEMP-TABLE tt-erro.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,           /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            ASSIGN aux_retorno = "NOK".
        END.
    ELSE
        ASSIGN aux_retorno = "OK".
                                       
    IF  par_flgerlog  THEN
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

/* Rotina para tratamento da impressao da proposta e/ou contrato
   de emprestimo (MODELO 1 - EMPRESTIMO) - Relatorio 488 - - proepr_ct01 */
PROCEDURE trata-impressao-modelo1:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_dtcalcul AS DATE                              NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
                                                                               
    DEF OUTPUT PARAM TABLE FOR tt-erro.                                        

    DEF VAR aux_txeanual           AS DECI DECIMALS 6                            NO-UNDO.
    DEF VAR aux_txanmora           AS DECI DECIMALS 6                            NO-UNDO.
    DEF VAR aux_contador           AS INTE                                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Tratar impressao de contrato - Modelo 1.".

    FIND crapass WHERE  crapass.cdcooper = par_cdcooper AND 
                        crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapass   THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
                                   
    IF  crapass.inpessoa = 1   THEN 
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
            IF   AVAIL crapttl  THEN
                 ASSIGN aux_cdempres = crapttl.cdempres.
        END.
    ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
        
            IF  AVAIL crapjur  THEN
                ASSIGN aux_cdempres = crapjur.cdempres.
        END.
    
    ASSIGN rel_nmprimtl = crapass.nmprimtl
           rel_nrdconta = crapass.nrdconta
           rel_cdagenci = crapass.cdagenci.
            
    IF  crapass.inpessoa = 1 THEN
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
    ELSE
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
    
    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
    
    ASSIGN rel_vlemprst = crawepr.vlemprst
           rel_vlpreemp = crawepr.vlpreemp
    
           rel_qtpreemp = IF crawepr.qtpreemp > 1
                             THEN crawepr.qtpreemp
                             ELSE crawepr.dtdpagto - par_dtmvtolt
    
           rel_nrctremp = crawepr.nrctremp
           rel_txminima = crawepr.txminima
           rel_txbaspre = crawepr.txbaspre
           rel_dtdpagto = crawepr.dtdpagto
           rel_dddpagto = DAY(crawepr.dtdpagto)
           /*rel_ddmvtolt = DAY(crawepr.dtmvtolt)*/
           rel_ddmvtolt = DAY(crawepr.dtaltpro) /*Rafael Ferreira (Mouts) - Story 19674*/
           /*rel_dsmesref = ENTRY(MONTH(crawepr.dtmvtolt),aux_dsmesref)*/
           rel_dsmesref = ENTRY(MONTH(crawepr.dtaltpro),aux_dsmesref) /*Rafael Ferreira (Mouts) - Story 19674*/
           rel_aamvtolt = YEAR(crawepr.dtmvtolt)
           aux_dsliquid = ""
    
           rel_dscpfav1 = crawepr.dscpfav1
           rel_dscpfav2 = crawepr.dscpfav2
           rel_dscfcav1 = crawepr.dscfcav1
           rel_dscfcav2 = crawepr.dscfcav2
           
           rel_nmdaval1 = crawepr.nmdaval1
           rel_nmcjgav1 = crawepr.nmcjgav1
           rel_nmdaval2 = crawepr.nmdaval2
           rel_nmcjgav2 = crawepr.nmcjgav2
    
           rel_dsliquid[1] = ""
           rel_dsliquid[2] = "".

    IF  rel_nmdaval1 = "" THEN
        rel_nmdaval1 = "________________________________________________".
    IF  rel_nmdaval2 = "" THEN
        rel_nmdaval2 = "_______________________________________________".
    IF  rel_nmcjgav1 = "" THEN
        rel_nmcjgav1 = "________________________________________________".
    IF  rel_nmcjgav2 = "" THEN
        rel_nmcjgav2 = "_______________________________________________".
    IF  rel_dscpfav1 = "" THEN
        rel_dscpfav1 = "________________________________________________".
    IF  rel_dscpfav2 = "" THEN
        rel_dscpfav2 = "_______________________________________________".
    IF  rel_dscfcav1 = "" THEN
        rel_dscfcav1 = "________________________________________________".
    IF  rel_dscfcav2 = "" THEN
        rel_dscfcav2 = "_______________________________________________".
          
    IF  par_dtcalcul = ?   THEN
        par_dtcalcul = par_dtmvtolt.
    
    IF  crawepr.tpdescto = 2  THEN
        ASSIGN rel_dsdpagto[1] = "Debito em consignacao em folha de pagamento."
               rel_dsdpagto[3] = "Iniciando a partir de " +
                                  STRING(MONTH(crawepr.dtdpagto),"99") + "/" + 
                                  STRING(YEAR(crawepr.dtdpagto),"9999").
    ELSE
    IF  crawepr.flgpagto   THEN
        DO:
            ASSIGN rel_dsdpagto[1] = "Debito em C/C na data do credito dos " +
                                     "salarios do COOPERADO(S)."
                   rel_dsdpagto[3] = "Iniciando a partir de " +
                                     STRING(crawepr.dtdpagto,"99/99/9999") + ".".
        END.
    ELSE
        DO:
            IF  crawepr.tpemprst = 0 THEN
                DO:     
                    ASSIGN rel_dsdpagto[1] = "Debito em C/C no dia " +
                           STRING(rel_dddpagto,"99") + ".".
                END.
            ELSE
                DO:
                    ASSIGN rel_dsdpagto[1] = "Debito  em  C/C  na   data   de   vencimento " +
                                             " escolhida  pelo"
                           rel_dsdpagto[4] = "     COOPERADO(S).".
                END.

            ASSIGN rel_dsdpagto[3] = "Iniciando a partir de " +
                                  STRING(crawepr.dtdpagto,"99/99/9999") + ".".
        END.

    DO aux_contador = 1 TO 10:
    
        IF  crawepr.nrctrliq[aux_contador] > 0   THEN
            ASSIGN rel_dsliquid[2] = rel_dsliquid[2] +
                           (IF rel_dsliquid[2] = ""
                               THEN TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                         "z,zzz,zz9"))
                               ELSE ", " +
                                    TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                         "z,zzz,zz9")))
                   aux_dsliquid = aux_dsliquid +
                                  TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                         "z,zzz,zz9")) + ",".
    
    END.  /*  Fim do DO .. TO  */
    
    rel_dsliquid[1] = "e para liquidar o(s) contrato(s):".
    
    IF  rel_dsliquid[2] <> ""   THEN
        rel_dsliquid[2] = rel_dsliquid[2] + ".".
    ELSE
        ASSIGN rel_dsliquid[1] = ""
               rel_dsliquid[2] = "".
    
    /*  Descricao da empresa  */
    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper     AND
                       crapemp.cdempres = aux_cdempres     NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapemp   THEN
        DO:
            ASSIGN aux_cdcritic = 40
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
    
    rel_nmempres = crapemp.nmextemp + ".".
    
    /*  Descricao da agencia  */
    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND 
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapage   THEN
        rel_dsagenci = STRING(crapass.cdagenci,"999") + " - NAO CADASTRADO.".
    ELSE
        rel_dsagenci = STRING(crapass.cdagenci,"999") + " - " +
                        crapage.nmresage.
    
    /*  Nome do analista de credito  */
    FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                       crapope.cdoperad = crawepr.cdoperad NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapope   THEN
        aux_nmoperad = crawepr.cdoperad + " - ** NAO CADASTRADO **".
    ELSE
        aux_nmoperad = crapope.nmoperad.
    
    /*  Leitura da descricao da LINHA DE CREDITO E FINALIDADE  */
    FIND crapfin WHERE crapfin.cdcooper = par_cdcooper     AND 
                       crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapfin   THEN
        DO:
            ASSIGN aux_cdcritic = 362
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
    
    FIND craplcr WHERE craplcr.cdcooper = par_cdcooper     AND
                       craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE craplcr   THEN
        DO:
            ASSIGN aux_cdcritic = 363
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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

    ASSIGN rel_dsfinemp = TRIM(crapfin.dsfinemp) + " (" +
                          STRING(crapfin.cdfinemp,"999") + ")"
    
           rel_dslcremp = TRIM(craplcr.dslcremp) + " (" +
                          STRING(craplcr.cdlcremp,"9999") + ")."
                          
           aux_nrdevias = craplcr.nrdevias.
    
    /*  Taxa de juros fixa  */
    
    ASSIGN rel_dsjurvar = "T.R. (Taxa Referencial de Juros);"
           aux_txeanual = ROUND((EXP(1 + (craplcr.txjurfix / 100),12) - 1) 
                          * 100,2).

    IF  crawepr.tpemprst = 0 THEN
        aux_txanmora = ROUND((EXP(1 + (craplcr.perjurmo / 100),12) - 1) 
                       * 100,2).
    ELSE
        aux_txanmora = ROUND((craplcr.perjurmo * 12) ,2).


    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
            SET h-b1wgen9999.
            
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                         
            RETURN "NOK".
        END.

    RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txeanual,       
                                       INPUT 48,                 
                                       INPUT 71,                 
                                       INPUT "P",                
                                       OUTPUT rel_dsjurfix[1],   
                                       OUTPUT rel_dsjurfix[2]).  

    rel_dsjurfix[1] = STRING(aux_txeanual,"999.99") + " % (" +
                      LC(rel_dsjurfix[1]).
    
    RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txanmora,       
                                       INPUT 48,                 
                                       INPUT 71,                 
                                       INPUT "P",                
                                       OUTPUT rel_dsjurmor[1],   
                                       OUTPUT rel_dsjurmor[2]).  

    rel_dsjurmor[1] = STRING(aux_txanmora,"999.99") + " % (" +
                      LC(rel_dsjurmor[1]).

    IF  crawepr.tpemprst = 0 THEN
        DO: 
            IF  LENGTH(TRIM(rel_dsjurfix[2])) = 0   THEN
                ASSIGN rel_dsjurfix[1] = rel_dsjurfix[1] + ")" + FILL("*",32)
                       rel_dsjurfix[2] = "ao ano; (" +
                                         STRING(craplcr.txjurfix,"999.99") + 
                                         " % a.m., capitalizados mensalmente)".
            ELSE
                ASSIGN rel_dsjurfix[1] = rel_dsjurfix[1] + FILL("*",32)
                       rel_dsjurfix[2] = LC(rel_dsjurfix[2]) + ") ao ano; (" +
                                         STRING(craplcr.txjurfix,"999.99") + 
                                         " % a.m., capitalizados mensalmente)".
        END.
    ELSE
        DO:
           IF  LENGTH(TRIM(rel_dsjurmor[2])) = 0   THEN
                ASSIGN rel_dsjurmor[1] = rel_dsjurmor[1] + ")" 
                       rel_dsjurmor[2] = "ao ano; (" +
                                         STRING(craplcr.perjurmo,"999.99") + 
                                         " % ao mes);".
            ELSE
                ASSIGN rel_dsjurmor[1] = rel_dsjurmor[1] 
                       rel_dsjurmor[2] = LC(rel_dsjurmor[2]) + ") ao ano; (" +
                                         STRING(craplcr.perjurmo,"999.99") + 
                                         " % ao mes);".
        END.
    
    /*  Taxa de juros minima anual  */
    rel_txminima = ROUND((EXP(1 + (crawepr.txminima / 100),12) - 1) * 100,2).

    IF  crawepr.tpemprst = 0 THEN
        DO: 

            RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_txminima,      
                                               INPUT 52,                 
                                               INPUT 71,                 
                                               INPUT "P",                
                                               OUTPUT rel_dsminima[1],   
                                               OUTPUT rel_dsminima[2]).  
        END.
    ELSE
        DO:
            RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_txminima,      
                                               INPUT 32,                 
                                               INPUT 71,                 
                                               INPUT "P",                
                                               OUTPUT rel_dsminima[1],   
                                               OUTPUT rel_dsminima[2]).  
        END.

    rel_dsminima[1] = STRING(rel_txminima,"999.99") + " % (" +
                      LC(rel_dsminima[1]).

    IF  LENGTH(TRIM(rel_dsminima[2])) = 0   THEN
        ASSIGN rel_dsminima[1] = rel_dsminima[1] + ")" + FILL("*",32)
               rel_dsminima[2] = "ao ano; (" +
                                 STRING(crawepr.txminima,"999.99") + 
                                 " % a.m., capitalizados mensalmente)".
    ELSE
        ASSIGN rel_dsminima[1] = rel_dsminima[1] + FILL("*",32)
               rel_dsminima[2] = LC(rel_dsminima[2]) + ") ao ano; (" +
                                 STRING(crawepr.txminima,"999.99") + 
                                 " % a.m., capitalizados mensalmente)".

    /*  Extensos diversos */
    RUN valor-extenso IN h-b1wgen9999 
                      (INPUT  rel_vlemprst, INPUT 53, INPUT 72, INPUT "M",
                       OUTPUT rel_dsemprst[1], OUTPUT rel_dsemprst[2]).

    RUN valor-extenso IN h-b1wgen9999 
                      (INPUT  rel_vlpreemp, INPUT 53, INPUT 72, INPUT "M",    
                       OUTPUT rel_dspreemp[1], OUTPUT rel_dspreemp[2]).       

    RUN valor-extenso IN h-b1wgen9999 
                      (INPUT  rel_qtpreemp, INPUT 37, INPUT 0, INPUT "I",  
                       OUTPUT rel_dspresta[1], OUTPUT aux_dsbranco).       
                                      
    ASSIGN rel_dsemprst[1] = "(" + rel_dsemprst[1]
           rel_dsemprst[2] = rel_dsemprst[2] + ");"
           rel_dspreemp[1] = "(" + rel_dspreemp[1]
           rel_dspreemp[2] = rel_dspreemp[2] + ");"
           rel_dspresta[1] = "(" + rel_dspresta[1] + ") " + FILL("*",50)
           rel_dspresta[2] = (IF crawepr.qtpreemp > 1
                                THEN "meses"
                                ELSE "dias") + 
                                ", contados desta data.".
    
    IF  craplcr.tplcremp = 2   THEN
        rel_tpctremp = "Reajustada de acordo com a equivalencia salarial;".
    ELSE
        rel_tpctremp = "Fixa;".

    IF VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.

/* Rotina para tratamento da impressao da proposta e/ou contrato
   de emprestimo (MODELO 2 - EMPRESTIMO) - Relatorio 488 - - proepr_ct02 */
PROCEDURE trata-impressao-modelo2:

   DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_recidepr AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF  INPUT PARAM par_dtcalcul AS DATE                              NO-UNDO.
   DEF  INPUT PARAM par_flgerlog AS LOGICAL                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-erro.                                        

   DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.
   DEF VAR aux_txeanual AS DECI DECIMALS 6                            NO-UNDO.
   DEF VAR aux_txanmora AS DECI DECIMALS 6                            NO-UNDO.
   DEF VAR aux_percmult AS DECI DECIMALS 6                            NO-UNDO.
   DEF VAR aux_contador AS INTE                                       NO-UNDO.
   DEF VAR aux_prtlmult AS INTE                                       NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
          aux_dstransa = "Tratar impressao de contrato - Modelo 2.".

   /*  Trata impressao do contrato ......................................... */
   
   FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                      crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
   

   IF   NOT AVAILABLE crapass   THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   ASSIGN aux_cdagenci = crapass.cdagenci.
   
   IF   crapass.inpessoa = 1   THEN 
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
      
            IF   AVAIL crapttl  THEN
                 ASSIGN aux_cdempres = crapttl.cdempres.
        END.
   ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
   
            IF   AVAIL crapjur  THEN
                 ASSIGN aux_cdempres = crapjur.cdempres.
        END.
   
   FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   /*  Leitura da descricao da LINHA DE CREDITO E FINALIDADE  */
   
   FIND crapfin WHERE crapfin.cdcooper = par_cdcooper AND 
                      crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapfin   THEN
        DO:
            ASSIGN aux_cdcritic = 362
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                      craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE craplcr   THEN
        DO:
            ASSIGN aux_cdcritic = 363
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   ASSIGN rel_dsfinemp = TRIM(crapfin.dsfinemp) + " (" +
                         STRING(crapfin.cdfinemp,"999") + ")."
   
          rel_dslcremp = TRIM(craplcr.dslcremp) + " (" +
                         STRING(craplcr.cdlcremp,"9999") + ")."
   
          aux_nrdevias = craplcr.nrdevias.
   
   /*  Descricao da empresa  */
   
   FIND crapemp WHERE crapemp.cdcooper = par_cdcooper   AND
                      crapemp.cdempres = aux_cdempres NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapemp   THEN
        DO:
            ASSIGN aux_cdcritic = 40
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   ASSIGN rel_nmempres = crapemp.nmextemp
          rel_nrctremp = crawepr.nrctremp
          /*rel_ddmvtolt = DAY(crawepr.dtmvtolt)*/
          rel_ddmvtolt = DAY(crawepr.dtaltpro) /*Rafael Ferreira (Mouts) - Story 19674*/
          /*rel_dsmesref = ENTRY(MONTH(crawepr.dtmvtolt),aux_dsmesref)*/
          rel_dsmesref = ENTRY(MONTH(crawepr.dtaltpro),aux_dsmesref) /*Rafael Ferreira (Mouts) - Story 19674*/
          rel_aamvtolt = YEAR(crawepr.dtmvtolt)
   
          rel_dsdtraco = FILL("_",125).
   
   /*  02 - FINANCIADO .................................................... */
   
   FIND crapenc WHERE crapenc.cdcooper = par_cdcooper      AND
                      crapenc.nrdconta = crapass.nrdconta  AND
                      crapenc.idseqttl = 1                 AND
                      crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.
   
   ASSIGN rel_nmprimtl    = crapass.nmprimtl
          rel_nrdconta    = crapass.nrdconta
          rel_cdagenci    = crapass.cdagenci
          rel_dsendres[1] = SUBSTRING(crapenc.dsendere,1,32) + " " +
                            TRIM(STRING(crapenc.nrendere,"zzz,zzz" ))
          rel_nmbairro    = crapenc.nmbairro
          rel_nmcidade    = crapenc.nmcidade
          rel_cdufresd    = crapenc.cdufende
          rel_nrcepend    = crapenc.nrcepend.            
                
   
   
   IF   crapass.inpessoa = 1 THEN
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
   ELSE
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
   
   /*  03 - VALOR FINANCIADO .............................................. */
   
   rel_vlemprst = crawepr.vlemprst.

   RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
           SET h-b1wgen9999.
           
   IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
       DO:
           ASSIGN aux_dscritic = "Handle invalido para BO b1wgen9999.".
                  
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                         
            RETURN "NOK".
       END.

   RUN valor-extenso IN h-b1wgen9999 
                        (INPUT  rel_vlemprst, INPUT 41, INPUT 65, INPUT "M", 
                         OUTPUT rel_dsemprst[1], OUTPUT rel_dsemprst[2]).    
                                      
   ASSIGN rel_dsemprst[1] = "(" + rel_dsemprst[1]
          rel_dsemprst[2] = rel_dsemprst[2] + ")."
   
          rel_dsliquid[1] = "e do saldo devedor no(s)"
    
          rel_dsliquid[2] = "contrato(s) anterior(es), tambem " +
                            "de responsabilidade do CON-"
   
          rel_dsliquid[3] = "TRATANTE, conforme numero(s) abaixo:"
          
          rel_dsliqseg    = ""
          aux_dsliquid    = "".
   
   DO aux_contador = 1 TO 10:
   
      IF   crawepr.nrctrliq[aux_contador] > 0   THEN
           ASSIGN rel_dsliqseg = rel_dsliqseg +
                          (IF rel_dsliqseg = ""
                              THEN TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                        "z,zzz,zz9"))
                              ELSE ", " +
                                   TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                        "z,zzz,zz9")))
                  aux_dsliquid = aux_dsliquid +
                                 TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                        "z,zzz,zz9")) + ",".
   
   END.  /*  Fim do DO .. TO  */
   
   IF   rel_dsliqseg = ""   THEN
        ASSIGN rel_dsliquid[1] = "."
               rel_dsliquid[2] = ""
               rel_dsliquid[3] = "".
   ELSE
        rel_dsliqseg = rel_dsliqseg + ".".

   /*  04 - ENCARGOS ...................................................... */
   
   /*  Taxa de juros variavel anual  */
   ASSIGN rel_dsjurvar = "T.R. (Taxa Referencial);"
          aux_txeanual = ROUND((EXP(1 + (craplcr.txjurfix / 100),12) - 1) 
                         * 100,2).

   IF crawepr.tpemprst = 0 THEN
      aux_txanmora = ROUND((EXP(1 + (craplcr.perjurmo / 100),12) - 1) 
                     * 100,2).           
   ELSE
       aux_txanmora = ROUND( (craplcr.perjurmo * 12), 2 ).
     
           /*  Taxa de juros fixa  */
   RUN valor-extenso IN h-b1wgen9999 (INPUT  aux_txeanual,       
                                       INPUT 44,                 
                                       INPUT 43,                 
                                       INPUT "P",                
                                       OUTPUT rel_dsjurfix[1],   
                                       OUTPUT rel_dsjurfix[2]).   
   
   RUN valor-extenso IN h-b1wgen9999 (INPUT  aux_txanmora,       
                                      INPUT 44,                 
                                      INPUT 43,                 
                                      INPUT "P",                
                                      OUTPUT rel_dsjurmor[1],   
                                      OUTPUT rel_dsjurmor[2]).   
  

   ASSIGN rel_dsjurfix[1] = TRIM(STRING(aux_txeanual,"zz9.99")) + " % (" +
                            LC(rel_dsjurfix[1]) + "*************************"
                     
          rel_dsjurfix[2] = LC(rel_dsjurfix[2]) + ") ao ano; (" + 
                            STRING(craplcr.txjurfix,"99.99") + 
                            "% a.m.);"

          rel_dsjurmor[1] = TRIM(STRING(aux_txanmora,"zz9.99")) + " % (" +
                            LC(rel_dsjurmor[1]) + "*************************"
                     
          rel_dsjurmor[2] = LC(rel_dsjurmor[2]) + ") ao ano; (" + 
                            STRING(craplcr.perjurmo,"99.99") + 
                            "% ao mes);". 


   /* Multa TAB0090 */ 
   FIND craptab WHERE craptab.cdcooper = 3           AND
                      craptab.nmsistem = "CRED"      AND
                      craptab.tptabela = "USUARI"    AND
                      craptab.cdempres = 11          AND
                      craptab.cdacesso = "PAREMPCTL" AND
                      craptab.tpregist = 01 
                      NO-LOCK NO-ERROR.

   IF  AVAIL(craptab) THEN
       DO:
           /* Verifica se a linha de credito cobra multa */
          IF craplcr.flgcobmu THEN
             ASSIGN aux_percmult = DEC(SUBSTRING(craptab.dstextab,1,6)).
          ELSE
             ASSIGN aux_percmult = 0.

           RUN valor-extenso IN h-b1wgen9999 (INPUT  aux_percmult,            
                                              INPUT 70,                      
                                              INPUT 72,
                                              INPUT "P",                     
                                              OUTPUT rel_dscmulta[1],        
                                              OUTPUT rel_dscmulta[2]).        

           ASSIGN rel_dscmulta[1] = STRING(aux_percmult,"99.99") + "% (" +
                                    LC(rel_dscmulta[1]) + ")".   
       END.

   /*  Taxa de juros minima anual  */
   rel_txminima = ROUND((EXP(1 + (crawepr.txminima / 100),12) - 1) * 100,2).

   RUN valor-extenso IN h-b1wgen9999 (INPUT rel_txminima,       
                                      INPUT 29,                 
                                      INPUT 59,                 
                                      INPUT "P",                
                                      OUTPUT rel_dsminima[1],   
                                      OUTPUT rel_dsminima[2]).   

   ASSIGN rel_dsminima[1] = "(" + LC(rel_dsminima[1]) 
          rel_dsminima[3] = LC(rel_dsminima[2]) + ") ao ano; (" +
                            STRING(crawepr.txminima,"99.99") + 
                            "% a.m.);"       
          rel_dsminima[2] = LC(rel_dsminima[2]) + ") ao ano; (" +
                            STRING(crawepr.txminima,"99.99") + 
                            "% a.m.)".
   
   
   /*  05 - PRESTACAO MENSAL ............................................. */
   
   rel_vlpreemp = crawepr.vlpreemp.


   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_vlpreemp,        
                                      INPUT 8,                   
                                      INPUT 59,                  
                                      INPUT "M",                 
                                      OUTPUT rel_dspreemp[1],    
                                      OUTPUT rel_dspreemp[2]).    
   
   ASSIGN rel_dspreemp[1] = "(" + rel_dspreemp[1]
          rel_dspreemp[2] = rel_dspreemp[2] + ");"
   
          rel_dsvencto    = "Vencimento: " +
                           (IF crawepr.flgpagto
                               THEN "ate o dia 10 de cada mes, vinculado  ao " 
                                    + " credito" 
                               ELSE "dia  " + 
                                    STRING(DAY(crawepr.dtdpagto),"99") + " " + 
                                    " de  cada  mes,  com  debito  em  conta-")
   
          rel_dsvenseg = IF crawepr.flgpagto
                            THEN "do salario."
                            ELSE "corrente."
   
          rel_qtpreemp = IF crawepr.qtpreemp > 1
                            THEN crawepr.qtpreemp
                            ELSE crawepr.dtdpagto - par_dtmvtolt.

   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_qtpreemp,          
                                      INPUT 12,                    
                                      INPUT 60,                    
                                      INPUT "I",                   
                                      OUTPUT rel_dspresta[1],      
                                      OUTPUT rel_dspresta[2]).      
  
   ASSIGN aux_prtlmult = crawepr.qttolatr.

   RUN valor-extenso IN h-b1wgen9999 (INPUT aux_prtlmult,      
                                      INPUT 92,                 
                                      INPUT 0,                 
                                      INPUT "I",                
                                      OUTPUT rel_prtlmult[1],   
                                      OUTPUT rel_prtlmult[2]).

   rel_prtlmult[1] = STRING(aux_prtlmult,"999") + " (" + 
                     LC(rel_prtlmult[1]) + ") dias".

   IF VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.
   
   ASSIGN rel_dspresta[1] = "(" + LC(rel_dspresta[1]) + " ************** " 
          rel_dspresta[2] = LC(rel_dspresta[2]) +
                            "**) " +
                            (IF crawepr.qtpreemp > 1
                               THEN "meses"
                               ELSE "dias") + 
                               ", contados desta data.".
   
   FIND crapepr WHERE crapepr.cdcooper = crawepr.cdcooper AND
                      crapepr.nrctremp = crawepr.nrctremp AND
                      crapepr.nrdconta = crawepr.nrdconta
                      NO-LOCK NO-ERROR.
   
   IF  AVAIL crapepr  THEN
       DO:
           /*Data prevista para o fim do contrato 
           (ultimo dia do mes da ultima prestacao)*/
           rel_dtfimemp = DATE(MONTH(crapepr.dtmvtolt),1,YEAR(crapepr.dtmvtolt)).
   
           DO aux_contador = 1 TO crapepr.qtpreemp + 1:
    
              IF   MONTH(rel_dtfimemp) = 12   THEN
                   DO:
                      rel_dtfimemp = DATE(1,
                                          DAY(rel_dtfimemp),
                                          YEAR(rel_dtfimemp) + 1).
                      NEXT.
                   END.
                
               rel_dtfimemp = DATE(MONTH(rel_dtfimemp) + 1,
                                   DAY(rel_dtfimemp),
                                   YEAR(rel_dtfimemp)).
           END.
   
           rel_dtfimemp = rel_dtfimemp - DAY(rel_dtfimemp).    
       END.
   ELSE
       DO:
           /*Data prevista para o fim do contrato 
           (ultimo dia do mes da ultima prestacao)*/
           rel_dtfimemp = DATE(MONTH(crawepr.dtmvtolt),1,YEAR(crawepr.dtmvtolt)).
   
           DO aux_contador = 1 TO crawepr.qtpreemp + 1:
    
              IF   MONTH(rel_dtfimemp) = 12   THEN
                   DO:
                      rel_dtfimemp = DATE(1,
                                          DAY(rel_dtfimemp),
                                          YEAR(rel_dtfimemp) + 1).
                      NEXT.
                   END.
                
               rel_dtfimemp = DATE(MONTH(rel_dtfimemp) + 1,
                                   DAY(rel_dtfimemp),
                                   YEAR(rel_dtfimemp)).
           END.
   
           rel_dtfimemp = rel_dtfimemp - DAY(rel_dtfimemp).
       END.
   
   /*  06 - BEM FINANCIADO ................................................ */
   
   ASSIGN aux_contador = 0.
   
   FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper   AND
                          crapbpr.nrdconta = crawepr.nrdconta   AND
                          crapbpr.tpctrpro = 90                 AND
                          crapbpr.nrctrpro = crawepr.nrctremp   AND
                          crapbpr.flgalien = TRUE               NO-LOCK:
      
      ASSIGN aux_contador = aux_contador + 1. 
   
      IF  TRIM(crapbpr.dsbemfin) <> ""   THEN
          IF CAN-DO("AUTOMOVEL,MOTO,CAMINHAO,EQUIPAMENTO,OUTROS VEICULOS",crapbpr.dscatbem) THEN
               DO:
                   ASSIGN rel_dsbemfin[aux_contador] =
                             "04." + STRING(aux_contador,"z9") + " - " +
                             TRIM(crapbpr.dscatbem)            + " "   +
                             TRIM(crapbpr.dsbemfin)            +
                            (IF crapbpr.nrrenava > 0 THEN ", RENAVAN " +
                                TRIM(STRING(crapbpr.nrrenava,"zzz,zzz,zzz,zz9"))
                             ELSE "") 
                         
                          rel_dsbemseg[aux_contador] =       
                            (IF TRIM(crapbpr.dschassi) <> "" THEN 
                                "       Chassi " + TRIM(crapbpr.dschassi) +
                               (IF crapbpr.tpchassi = 1 THEN " (1-REMARCADO)"
                                ELSE " (2-NORMAL)") +
                                
                               (IF TRIM(crapbpr.nrdplaca) <> "" THEN 
                                   ", Placa " + STRING(crapbpr.ufdplaca,"xx")
                                   + " " + STRING(crapbpr.nrdplaca,"xxxxxxx")
                                ELSE "") 
                             ELSE "       ")
                             
                          rel_dsbemter[aux_contador] =       
                            (IF TRIM(crapbpr.uflicenc) <> "" THEN 
                                "       LICENCIADO EM " + TRIM(crapbpr.uflicenc)
                             ELSE "       ") +
                                 (IF crapbpr.nranobem > 0 THEN ", Ano " +
                                     STRING(crapbpr.nranobem,"9999")
                                  ELSE "") +
                                      (IF crapbpr.nrmodbem > 0 THEN
                                          ", Modelo " +
                                          STRING(crapbpr.nrmodbem,"9999")
                                       ELSE "") +
                                           (IF TRIM(crapbpr.dscorbem) <> "" THEN 
                                               ", Cor " + TRIM(crapbpr.dscorbem)
                                            ELSE "").

                   rel_nmpropbm[aux_contador] = 
                      valida_proprietario (crapbpr.nrcpfbem, par_cdcooper).
                                                 
                   IF  rel_nmpropbm[aux_contador] <> ""   THEN
                       rel_nmpropbm[aux_contador] = "       PROPRIETARIO: " +
                                                    rel_nmpropbm[aux_contador].
               END.
          ELSE
          IF   crapbpr.dscatbem = "MAQUINA DE COSTURA"   THEN
               ASSIGN rel_dsbemfin[aux_contador] =
                                  "04." + STRING(aux_contador,"z9") + " - " +
                                  TRIM(crapbpr.dscatbem)            + " "   +
                                  TRIM(crapbpr.dsbemfin)            +
                                 (IF TRIM(crapbpr.dscorbem) <> "" THEN
                                     ", Classe " + TRIM(crapbpr.dscorbem)
                                  ELSE "")
                                     
                      rel_dsbemseg[aux_contador] =                
                                 (IF TRIM(crapbpr.dschassi) <> ""  THEN 
                                     "       Numero de serie " +
                                     TRIM(crapbpr.dschassi)
                                  ELSE "       ").
          ELSE
               ASSIGN rel_dsbemfin[aux_contador] =
                                  "04." + STRING(aux_contador,"z9") + " - " +
                                  TRIM(crapbpr.dscatbem)            + " " +
                                  TRIM(crapbpr.dsbemfin).

          ASSIGN rel_dscatbem = crapbpr.dscatbem.

   END.  /*  Fim do DO .. TO  */
   
   /*  07 - FIADORES ...................................................... */
   
   ASSIGN rel_dsfiador[1] = IF TRIM(crawepr.nmdaval1) <> ""
                               THEN crawepr.nmdaval1 
                               ELSE FILL("_",50)
   
          rel_dsfiaseg[1] = IF TRIM(crawepr.nmdaval1) <> ""
                               THEN (IF crawepr.nrctaav1 > 0
                                        THEN "Conta/dv: " +
                                             TRIM(STRING(crawepr.nrctaav1,
                                                         "zzzz,zzz,9")) + ", "
                                        ELSE "") +
                                             STRING(crawepr.dscpfav1,"x(22)")
                               ELSE FILL("_",50)
          
          rel_dsfiador[2] = IF TRIM(crawepr.nmdaval2) <> ""
                               THEN crawepr.nmdaval2 
                            ELSE FILL("_",40)
   
          rel_dsfiaseg[2] = IF TRIM(crawepr.nmdaval2) <> ""
                               THEN (IF crawepr.nrctaav2 > 0
                                        THEN "Conta/dv: " +
                                             TRIM(STRING(crawepr.nrctaav2,
                                                         "zzzz,zzz,9")) + ", "
                                        ELSE "") + 
                                             STRING(crawepr.dscpfav2,"x(22)")
                               ELSE FILL("_",40)
   
   /*.......................................................................*/
   
          rel_nmdaval1    = IF TRIM(crawepr.nmdaval1) <> ""
                               THEN crawepr.nmdaval1
                               ELSE FILL("_",40)
   
          rel_nmcjgav1    = IF TRIM(crawepr.nmcjgav1) <> ""
                               THEN crawepr.nmcjgav1
                               ELSE FILL("_",40)
   
          rel_nmdaval2    = IF TRIM(crawepr.nmdaval2) <> ""
                               THEN crawepr.nmdaval2
                               ELSE FILL("_",40)
   
          rel_nmcjgav2    = IF TRIM(crawepr.nmcjgav2) <> ""
                               THEN crawepr.nmcjgav2
                               ELSE FILL("_",40)
          
          rel_dscpfav1    = IF TRIM(crawepr.dscpfav1) <> ""
                               THEN crawepr.dscpfav1
                               ELSE FILL("_",40)
                          
          rel_dscfcav1    = IF TRIM(crawepr.dscfcav1) <> ""
                               THEN crawepr.dscfcav1
                               ELSE FILL("_",40)
                        
          rel_dscpfav2    = IF TRIM(crawepr.dscpfav2) <> ""
                               THEN crawepr.dscpfav2
                               ELSE FILL("_",40)
                               
          rel_dscfcav2    = IF TRIM(crawepr.dscfcav2) <> ""
                               THEN crawepr.dscfcav2
                               ELSE FILL("_",40).
   
   /* ...................................................................... */
   
   /*  Nome do analista de credito  */
   
   FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                      crapope.cdoperad = crawepr.cdoperad NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapope   THEN
        aux_nmoperad = crawepr.cdoperad + " - ** NAO CADASTRADO **".
   ELSE
        aux_nmoperad = crapope.nmoperad.

   

   RETURN "OK".
   
END PROCEDURE.

/* Rotina para tratamento da impressao da proposta e/ou contrato
   de emprestimo (MODELO 3 - EMPRESTIMO) - Relatorio 488 - - proepr_ct03 */
PROCEDURE trata-impressao-modelo3:

   DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_recidepr AS INTE                              NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                              NO-UNDO.
   DEF  INPUT PARAM par_dtcalcul AS DATE                              NO-UNDO.
   DEF  INPUT PARAM par_flgerlog AS LOGI                              NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-erro.                                        

   DEF VAR aux_txeanual AS DECI DECIMALS 6                            NO-UNDO.
   DEF VAR aux_txanmora AS DECI DECIMALS 6                            NO-UNDO.
   DEF VAR aux_percmult AS DECI DECIMALS 6                            NO-UNDO.
   DEF VAR aux_prtlmult AS INTE                                       NO-UNDO.
   DEF VAR aux_contador AS INTE                                       NO-UNDO.
   DEF VAR aux_cdestcvl LIKE crapttl.cdestcvl                         NO-UNDO.
   DEF VAR aux_nmconjug LIKE crapcje.nmconjug                         NO-UNDO.

   EMPTY TEMP-TABLE tt-erro.

   ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
          aux_dstransa = "Tratar impressao de contrato - Modelo 3.".

   /*  Trata impressao do contrato ........................................ */
   FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                      crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

   IF   NOT AVAILABLE crapass   THEN       
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   IF   crapass.inpessoa = 1   THEN 
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                               crapttl.nrdconta = crapass.nrdconta   AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
   
            IF   AVAIL crapttl  THEN
                 ASSIGN aux_cdempres = crapttl.cdempres.
        END.
   ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
            
            IF   AVAIL crapjur  THEN
                 ASSIGN aux_cdempres = crapjur.cdempres.
        END.
   
   
   FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   /*  Leitura da descricao da LINHA DE CREDITO E FINALIDADE  */
   FIND crapfin WHERE crapfin.cdcooper = par_cdcooper AND 
                      crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapfin   THEN    
        DO:
            ASSIGN aux_cdcritic = 362
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND 
                      craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE craplcr   THEN    
        DO:
            ASSIGN aux_cdcritic = 363
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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
   
   ASSIGN rel_dsfinemp = TRIM(crapfin.dsfinemp) + " (" +
                         STRING(crapfin.cdfinemp,"999") + ")."
   
          rel_dslcremp = TRIM(craplcr.dslcremp) + " (" +
                         STRING(craplcr.cdlcremp,"9999") + ")."
   
          aux_nrdevias = craplcr.nrdevias.
   
   /*  Descricao da empresa  */
   
   FIND crapemp WHERE crapemp.cdcooper = par_cdcooper   AND
                      crapemp.cdempres = aux_cdempres  NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapemp   THEN
        DO:
            ASSIGN aux_cdcritic = 40
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
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

   ASSIGN rel_nmempres = crapemp.nmextemp
   
          rel_nrctremp = crawepr.nrctremp
          /*rel_ddmvtolt = DAY(crawepr.dtmvtolt)*/
          rel_ddmvtolt = DAY(crawepr.dtaltpro) /*Rafael Ferreira (Mouts) - Story 19674*/
          /*rel_dsmesref = ENTRY(MONTH(crawepr.dtmvtolt),aux_dsmesref)*/
          rel_dsmesref = ENTRY(MONTH(crawepr.dtaltpro),aux_dsmesref) /*Rafael Ferreira (Mouts) - Story 19674*/
          rel_aamvtolt = YEAR(crawepr.dtmvtolt)
   
          rel_dsdtraco = FILL("_",125).
   
   
   /*  02 - FINANCIADO .................................................... */
   IF AVAIL crapttl THEN
       aux_cdestcvl = crapttl.cdestcvl.
   ELSE
       aux_cdestcvl = 0.

   FIND LAST crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                     crapcje.nrdconta = crapass.nrdconta AND 
                     crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
   IF AVAILABLE crapcje THEN
      ASSIGN aux_nmconjug = crapcje.nmconjug.

   ASSIGN rel_nmprimtl[1] = crapass.nmprimtl
          rel_nmprimtl[2] = IF CAN-DO("2,3,4,8,9,11", STRING(aux_cdestcvl))
                               THEN "E " + aux_nmconjug
                               ELSE ""   
          rel_nrdconta = crapass.nrdconta
          rel_cdagenci = crapass.cdagenci.
   
   IF   crapass.inpessoa = 1 THEN
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"    xxx.xxx.xxx-xx").
   ELSE
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
   
   /*  03 - VALOR FINANCIADO .............................................. */
   
   rel_vlemprst = crawepr.vlemprst.

   RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
       SET h-b1wgen9999.

   IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
       DO:
           ASSIGN aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                         
           RETURN "NOK".
   END.

   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_vlemprst,           
                                       INPUT 45,                     
                                       INPUT 67,                     
                                       INPUT "M",                    
                                       OUTPUT rel_dsemprst[1],       
                                       OUTPUT rel_dsemprst[2]).       

   ASSIGN rel_dsemprst[1] = "(" + rel_dsemprst[1]
          rel_dsemprst[2] = rel_dsemprst[2] + ")."
   
          rel_dsliquid[1] = "e do"
          rel_dsliquid[2] = "saldo  devedor  no(s) contrato(s) " +
                            "anterior(es),  tambem  de  responsabilidade  do"
          rel_dsliquid[3] = "FINANCIADO, conforme numero(s) "
   
          aux_dsliquid    = "".
   
   DO aux_contador = 1 TO 10:
   
      IF   crawepr.nrctrliq[aux_contador] > 0   THEN
           ASSIGN rel_dsliquid[3] = rel_dsliquid[3] +
                        (IF rel_dsliquid[3] = "FINANCIADO, conforme numero(s) "
                              THEN TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                        "z,zzz,zz9"))
                              ELSE ", " +
                                   TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                        "z,zzz,zz9")))
                  aux_dsliquid = aux_dsliquid +
                                 TRIM(STRING(crawepr.nrctrliq[aux_contador],
                                        "z,zzz,zz9")) + ",".
   
   END.  /*  Fim do DO .. TO  */
   
   
   /*  04 - ENCARGOS ...................................................... */
   
   /*  Taxa de juros variavel  */
   
   rel_dsjurvar = "T.R. (Taxa Referencial de Juros);".
              
   /*  Taxa de juros fixa  */
   ASSIGN aux_txeanual = ROUND((EXP(1 + (craplcr.txjurfix / 100),12) - 1) 
                         * 100,2).

   IF crawepr.tpemprst = 0 THEN
      aux_txanmora = ROUND((EXP(1 + (craplcr.perjurmo / 100),12) - 1) 
                     * 100,2).
   ELSE
      aux_txanmora = ROUND((craplcr.perjurmo * 12) , 2).

   RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txeanual,           
                                      INPUT 25,                     
                                      INPUT 71,                     
                                      INPUT "P",                    
                                      OUTPUT rel_dsjurfix[1],       
                                      OUTPUT rel_dsjurfix[2]).       
   
   IF   rel_dsjurfix[2] <> "" THEN
        DO:

           RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txeanual,           
                                              INPUT 52,                     
                                              INPUT 71,                     
                                              INPUT "P",                    
                                              OUTPUT rel_dsjurfix[1],       
                                              OUTPUT rel_dsjurfix[2]).       

           ASSIGN rel_dsjurfix[1] = STRING(aux_txeanual,"99.99") + "% (" +
                                    LC(rel_dsjurfix[1])
                  rel_dsjurfix[2] = LC(rel_dsjurfix[2]) + ") ao ano; (" + 
                                    STRING(craplcr.txjurfix,"99.99") + 
                                    "% a.m., capitalizados mensalmente);".
        END.
   ELSE
        ASSIGN rel_dsjurfix[1] = STRING(aux_txeanual,"99.99") + "% (" +
                                 LC(rel_dsjurfix[1]) + ") ao ano; (" +
                                 STRING(craplcr.txjurfix,"99.99") + 
                                 "% a.m., capitalizados mensalmente);"
               rel_dsjurfix[2] = "".
   
   /*taxa juros moratoria*/
   RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txanmora,           
                                      INPUT 25,                     
                                      INPUT 71,                     
                                      INPUT "P",                    
                                      OUTPUT rel_dsjurmor[1],       
                                      OUTPUT rel_dsjurmor[2]).       

   IF   rel_dsjurmor[2] <> "" THEN
        DO:

           RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txanmora,           
                                              INPUT 52,                     
                                              INPUT 71,                     
                                              INPUT "P",                    
                                              OUTPUT rel_dsjurmor[1],       
                                              OUTPUT rel_dsjurmor[2]).       

             ASSIGN rel_dsjurmor[1] = STRING(aux_txanmora,"99.99") + "% (" +
                                      LC(rel_dsjurmor[1])
                    rel_dsjurmor[2] = LC(rel_dsjurmor[2]) + ") ao ano; (" + 
                                      STRING(craplcr.perjurmo,"99.99") + 
                                      "% ao mes);".
        END.
   ELSE
        ASSIGN rel_dsjurmor[1] = STRING(aux_txanmora,"99.99") + "% (" +
                                 LC(rel_dsjurmor[1]) + ") ao ano; (" +
                                 STRING(craplcr.perjurmo,"99.99") + 
                                 "% ao mes);"
               rel_dsjurmor[2] = "".



   /*  Taxa de juros minima anual  */
                                                                         
   rel_txminima = ROUND((EXP(1 + (crawepr.txminima / 100),12) - 1) * 100,2).

   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_txminima,            
                                      INPUT 28,                      
                                      INPUT 72,                      
                                      INPUT "P",                     
                                      OUTPUT rel_dsminima[1],        
                                      OUTPUT rel_dsminima[2]).        
   
   IF   rel_dsminima[2] <> "" THEN
        DO:

           IF  crawepr.tpemprst = 0 THEN
               DO:
                   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_txminima,            
                                                      INPUT 55,                      
                                                      INPUT 72,                      
                                                      INPUT "P",                     
                                                      OUTPUT rel_dsminima[1],        
                                                      OUTPUT rel_dsminima[2]).        

                   ASSIGN rel_dsminima[1] = STRING(rel_txminima,"99.99") + "% (" +
                                            LC(rel_dsminima[1])
                          rel_dsminima[2] = LC(rel_dsminima[2]) + ") ao ano ; (" + 
                                            STRING(crawepr.txminima,"99.99") + 
                                            "% a.m., capitalizados mensalmente);".

               END.
           ELSE
               DO:
                   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_txminima,            
                                                      INPUT 35,                      
                                                      INPUT 72,                      
                                                      INPUT "P",                     
                                                      OUTPUT rel_dsminima[1],        
                                                      OUTPUT rel_dsminima[2]).        
        
                   ASSIGN rel_dsminima[1] = STRING(rel_txminima,"99.99") + "% (" +
                                            LC(rel_dsminima[1])
                          rel_dsminima[2] = LC(rel_dsminima[2]) + ") ao ano ; (" + 
                                            STRING(crawepr.txminima,"99.99") + 
                                            "% a.m.);".
               END.

        END.
   ELSE
        ASSIGN rel_dsminima[1] = STRING(rel_txminima,"99.99") + "% (" +
                                 LC(rel_dsminima[1]) + ") ao ano ; (" +
                                 STRING(crawepr.txminima,"99.99") + 
                                 "% a.m., capitalizados mensalmente);"
               rel_dsminima[2] = "".

   /*  05 - PRESTACAO MENSAL ............................................... */
   
   rel_vlpreemp = crawepr.vlpreemp.
   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_vlpreemp,           
                                      INPUT 33,                     
                                      INPUT 80, /*52*/              
                                      INPUT "M",                    
                                      OUTPUT rel_dspreemp[1],       
                                      OUTPUT rel_dspreemp[2]).       

   ASSIGN rel_dspreemp[1] = "(" + rel_dspreemp[1]
          rel_dspreemp[2] = rel_dspreemp[2] + ")"
   
          rel_dsvencto    = "Vencimento: " +
                           (IF crawepr.flgpagto
                               THEN "ate o dia 10 de cada mes, " +
                                    "vinculado ao credito do(s) salario(s);"
   
                               ELSE "dia " + STRING(DAY(crawepr.dtdpagto),"99") +
                                   " de cada mes, com debito em conta-corrente;") +
                            ""
   
          rel_qtpreemp = IF crawepr.qtpreemp > 1
                            THEN crawepr.qtpreemp
                            ELSE crawepr.dtdpagto - par_dtmvtolt.

   RUN valor-extenso IN h-b1wgen9999 (INPUT  rel_qtpreemp,          
                                      INPUT 33,                    
                                      INPUT 0,                     
                                      INPUT "I",                   
                                      OUTPUT rel_dspresta[1],      
                                      OUTPUT aux_dsbranco).         
   
   rel_dspresta[1] = "(" + LC(rel_dspresta[1]) + ") " +
                      (IF crawepr.qtpreemp > 1
                          THEN "meses"
                          ELSE "dias") + 
                          ", contados desta data.".
   
   /*  06 - BEM FINANCIADO ................................................
   
   TRATADO EM trata-impressao-modelo3a  */
   ASSIGN aux_prtlmult = crawepr.qttolatr.
   
   RUN valor-extenso IN h-b1wgen9999 (INPUT aux_prtlmult,      
                                      INPUT 92,                 
                                      INPUT 0,                 
                                      INPUT "I",                
                                      OUTPUT rel_prtlmult[1],   
                                      OUTPUT rel_prtlmult[2]).
   
   rel_prtlmult[1] = STRING(aux_prtlmult,"999") + " (" +
                     LC(rel_prtlmult[1]) + ")" + FILL("*", 30).

   /*  07 - FIADORES ..................................................... */
   
   ASSIGN rel_dsfiador[1] = IF TRIM(crawepr.nmdaval1) <> ""
                               THEN crawepr.nmdaval1 + ", " +
                                    (IF crawepr.nrctaav1 > 0
                                        THEN "Conta/dv: " +
                                             TRIM(STRING(crawepr.nrctaav1,
                                                         "zzzz,zzz,9"))
                                        ELSE "") + ", " +
                                    STRING(crawepr.dscpfav1,"x(50)")
                               ELSE ""
   
          rel_dsfiador[2] = IF TRIM(crawepr.nmdaval2) <> ""
                               THEN crawepr.nmdaval2 + ", " +
                                    (IF crawepr.nrctaav2 > 0
                                        THEN "Conta/dv: " +
                                             TRIM(STRING(crawepr.nrctaav2,
                                                         "zzzz,zzz,9"))
                                        ELSE "") + ", " +
                                    STRING(crawepr.dscpfav2,"x(50)")
                               ELSE ""
   
          rel_nmdaval1    = IF TRIM(crawepr.nmdaval1) <> ""
                               THEN crawepr.nmdaval1
                               ELSE FILL("_",40)
   
          rel_nmcjgav1    = IF TRIM(crawepr.nmcjgav1) <> ""
                               THEN crawepr.nmcjgav1
                               ELSE FILL("_",40)
   
          rel_nmdaval2    = IF TRIM(crawepr.nmdaval2) <> ""
                               THEN crawepr.nmdaval2
                               ELSE FILL("_",40)
   
          rel_nmcjgav2    = IF TRIM(crawepr.nmcjgav2) <> ""
                               THEN crawepr.nmcjgav2
                               ELSE FILL("_",40)
          
          rel_dscpfav1    = IF TRIM(crawepr.dscpfav1) <> ""
                               THEN crawepr.dscpfav1
                               ELSE FILL("_",40)
                          
          rel_dscfcav1    = IF TRIM(crawepr.dscfcav1) <> ""
                               THEN crawepr.dscfcav1
                               ELSE FILL("_",40)
                        
   
          rel_dscpfav2    = IF TRIM(crawepr.dscpfav2) <> ""
                               THEN crawepr.dscpfav2
                               ELSE FILL("_",40)
                               
          rel_dscfcav2    = IF TRIM(crawepr.dscfcav2) <> ""
                               THEN crawepr.dscfcav2
                               ELSE FILL("_",40).
                        
   /* ..................................................................... */
   /* Multa TAB0090 */
   FIND craptab WHERE craptab.cdcooper = 3           AND
                      craptab.nmsistem = "CRED"      AND
                      craptab.tptabela = "USUARI"    AND
                      craptab.cdempres = 11          AND
                      craptab.cdacesso = "PAREMPCTL" AND
                      craptab.tpregist = 01 NO-LOCK NO-ERROR.

   IF  AVAIL(craptab) THEN
       DO:
           IF craplcr.flgcobmu THEN
              ASSIGN aux_percmult = DEC(SUBSTRING(craptab.dstextab,1,6)).
           ELSE
              ASSIGN aux_percmult = 0.

           RUN valor-extenso IN h-b1wgen9999 (INPUT  aux_percmult,            
                                              INPUT 55,                      
                                              INPUT 72,
                                              INPUT "P",                     
                                              OUTPUT rel_dscmulta[1],        
                                              OUTPUT rel_dscmulta[2]).        

           ASSIGN rel_dscmulta[1] = STRING(aux_percmult,"99.99") + "% (" +
                                    LC(rel_dscmulta[1]) + ")". 
       END.

   /*  Nome do analista de credito  */
   
   FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                      crapope.cdoperad = crawepr.cdoperad NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapope   THEN
        aux_nmoperad = crawepr.cdoperad + " - ** NAO CADASTRADO **".
   ELSE
        aux_nmoperad = crapope.nmoperad.

   IF VALID-HANDLE(h-b1wgen9999) THEN
       DELETE PROCEDURE h-b1wgen9999.

   RETURN "OK".
END PROCEDURE.

/* Grava parecer analise credito */ 

PROCEDURE grava-parecer:

  DEF  INPUT PARAM par_valor         AS CHAR                             NO-UNDO. 
  DEF  INPUT PARAM par_condicao      AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdconta      AS CHAR                             NO-UNDO.
  DEF  INPUT PARAM par_dstippes      AS CHAR                             NO-UNDO.
  
  FIND tt-xml-parecer WHERE tt-xml-parecer.nrdconta = par_nrdconta AND
                            tt-xml-parecer.dstippes = par_dstippes NO-ERROR.
      
  IF   AVAILABLE tt-xml-parecer THEN
       DO: 
          IF   par_condicao = 2   THEN
               ASSIGN tt-xml-parecer.dsstatus     = TRIM(par_valor).
          ELSE 
          IF   par_condicao = 3   THEN
               ASSIGN tt-xml-parecer.dsmensag_pos = TRIM(par_valor).
          ELSE 
          IF   par_condicao = 4   THEN
               ASSIGN tt-xml-parecer.dsmensag_ate = TRIM(par_valor).
       END.
  ELSE  
       CREATE tt-xml-parecer.
       ASSIGN tt-xml-parecer.nrdconta     = par_nrdconta
              tt-xml-parecer.dstippes     = par_dstippes + " ".
 
  RETURN "OK".

END PROCEDURE.

/* retornar analise do parecer de credito */
PROCEDURE parecer_credito:

  DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
  DEF  INPUT PARAM par_nrctremp AS INTE                             NO-UNDO.                          
 
  DEF VAR xml_req      AS LONGCHAR                                  NO-UNDO.
  DEF VAR xDoc         AS HANDLE                                    NO-UNDO.  
  DEF VAR xRoot        AS HANDLE                                    NO-UNDO. 
  DEF VAR xRoot2       AS HANDLE                                    NO-UNDO. 
  DEF VAR xRoot3       AS HANDLE                                    NO-UNDO. 
  DEF VAR xRoot4       AS HANDLE                                    NO-UNDO. 
  DEF VAR xText        AS HANDLE                                    NO-UNDO.
  DEF VAR xField       AS HANDLE                                    NO-UNDO.
  DEF VAR aux_cont     AS INTE                                      NO-UNDO.
  DEF VAR aux_cont2    AS INTE                                      NO-UNDO.
  DEF VAR aux_cont3    AS INTE                                      NO-UNDO.
  DEF VAR aux_dsvldtag AS CHAR                                      NO-UNDO.
  DEF VAR aux_dstagavo AS CHAR                                      NO-UNDO.
  DEF VAR aux_dstagpai AS CHAR                                      NO-UNDO.
  DEF VAR aux_dstagfil AS CHAR                                      NO-UNDO.
  DEF VAR aux_dstagnet AS CHAR                                      NO-UNDO.
  DEF var vr_dscritic  AS CHAR                                      NO-UNDO.
  DEF VAR aux_dsparecer AS CHAR                                     NO-UNDO.  
  DEF VAR aux_nrdconta  AS CHAR                                     NO-UNDO.
  DEF VAR aux_dstippes  AS CHAR                                     NO-UNDO.
  DEF var aux_dsstatus  AS CHAR                                     NO-UNDO.
  DEF VAR aux_dsmensag_pos AS CHAR  FORMAT "x(132)"                 NO-UNDO.
  DEF VAR aux_dsmensag_ate AS CHAR  FORMAT "x(132)"                 NO-UNDO.
  DEF VAR aux_contador AS INT                                       NO-UNDO.  
  DEF VAR aux_parecer  AS CHAR FORMAT "x(130)"                      NO-UNDO.

  DEF VAR ponteiro_xml AS MEMPTR                                    NO-UNDO.
  
  DEF BUFFER crabass FOR crapass.

    FORM SKIP(1)
         "4.1 Parecer de Credito:"  aux_dsparecer FORMAT "x(40)"  
         
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_parecer_geral.
         
    FORM SKIP(1) aux_parecer         
         WITH DOWN NO-BOX NO-LABELS WIDTH 130 FRAME f_parecer.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_retorna_analise_ctr 
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctremp, 
                                             OUTPUT "",
                                             OUTPUT 0,
                                             OUTPUT ""). 
    
    CLOSE STORED-PROC pc_retorna_analise_ctr
       aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN vr_dscritic = pc_retorna_analise_ctr.pr_dscritic
                          WHEN pc_retorna_analise_ctr.pr_dscritic <> ?.
    
    IF  vr_dscritic <> ""   THEN
        RETURN "NOK".
    
    ASSIGN xml_req = pc_retorna_analise_ctr.pr_retxml.    
    
    IF  xml_req = "" OR xml_req = ? THEN
      RETURN "NOK".
      
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */
    CREATE X-NODEREF  xRoot.
    CREATE X-NODEREF  xRoot2. 
    CREATE X-NODEREF  xRoot3.
    CREATE X-NODEREF  xRoot4.
    CREATE X-NODEREF  xField. 
    CREATE X-NODEREF  xText.  
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1.
    PUT-STRING(ponteiro_xml,1) = xml_req.
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).
    
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
    EMPTY TEMP-TABLE tt-xml-parecer.
    EMPTY TEMP-TABLE tt-xml-geral.
     
    DO  aux_cont = 1 TO xRoot:NUM-CHILDREN:
      xRoot:GET-CHILD(xRoot2,aux_cont).
    
      ASSIGN aux_dstagavo = xRoot2:NAME
             aux_dsvldtag = xRoot2:NODE-VALUE NO-ERROR.
      
      IF   ERROR-STATUS:ERROR   THEN
             NEXT. 

      IF   xRoot2:SUBTYPE <> "ELEMENT"   THEN
           NEXT.
        
      CREATE tt-xml-geral.
        ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
               tt-xml-geral.dsdvalor = aux_dsvldtag.
      
      DO aux_cont2 = 1 TO xRoot2:NUM-CHILDREN:  
         xRoot2:GET-CHILD(xRoot3,aux_cont2).
         
         /* IF xRoot3:SUBTYPE <> "ELEMENT"   THEN
            NEXT. */
          
         ASSIGN aux_dstagpai = xRoot3:NAME
                aux_dsvldtag = xRoot3:NODE-VALUE NO-ERROR.
        
         IF  ERROR-STATUS:ERROR   THEN
             NEXT. 
             
         CREATE tt-xml-geral.
            ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
                   tt-xml-geral.dstagpai = aux_dstagpai
                   tt-xml-geral.dsdvalor = aux_dsvldtag. 
          
          DO aux_cont3 = 1 TO xRoot3:NUM-CHILDREN:    
              xRoot3:GET-CHILD(xRoot4,aux_cont3).               
              
              /* IF xRoot4:SUBTYPE <> "ELEMENT"   THEN
                NEXT. */
               ASSIGN aux_dstagfil = xRoot4:NAME
                      aux_dsvldtag = xRoot4:NODE-VALUE NO-ERROR.
             
             IF   ERROR-STATUS:ERROR   THEN
                  NEXT. 
             
             CREATE tt-xml-geral.
             ASSIGN tt-xml-geral.dstagavo = aux_dstagavo
                    tt-xml-geral.dstagpai = aux_dstagpai
                    tt-xml-geral.dstagfil = aux_dstagfil
                    tt-xml-geral.dsdvalor = aux_dsvldtag.
          END.
      END.
      
    END.

    SET-SIZE(ponteiro_xml) = 0.
    
    DELETE OBJECT xDoc.
    DELETE OBJECT xRoot.
    DELETE OBJECT xRoot2.
    DELETE OBJECT xRoot3.
    DELETE OBJECT xRoot4.
    DELETE OBJECT xText. 
    
    aux_dsparecer    = "".    
    aux_nrdconta     = "".
    aux_dstippes     = "".
    aux_dsstatus     = "".
    aux_dsmensag_pos = "".
    aux_dsmensag_ate = "". 
        
    FOR EACH tt-xml-geral NO-LOCK:      
        aux_dsmensag_ate = "". 
        
        IF aux_dsparecer = "" THEN
           IF tt-xml-geral.dstagavo = 'dsstatus' AND 
              tt-xml-geral.dstagpai = '#text'     THEN
              ASSIGN aux_dsparecer = tt-xml-geral.dsdvalor. 
          
        IF  tt-xml-geral.dstagavo = 'analise'  AND /* busca conta */
            tt-xml-geral.dstagpai = 'nrdconta' AND  
            tt-xml-geral.dstagfil = '#text'    THEN
            /* grava nr conta */ 
        DO:
            
            ASSIGN aux_nrdconta = tt-xml-geral.dsdvalor. 

            /*RUN grava-parecer (INPUT tt-xml-geral.dsdvalor,  
                               INPUT 0,
                               INPUT aux_nrdconta). */        
        END.
        IF  tt-xml-geral.dstagavo = 'analise'  AND /* busca tipo pessoa  */
            tt-xml-geral.dstagpai = 'dstippes' AND 
            tt-xml-geral.dstagfil = '#text'    THEN
            DO:
                         
            /* grava tipo pessoa */ 
            aux_dstippes = tt-xml-geral.dsdvalor.
            RUN grava-parecer (INPUT tt-xml-geral.dsdvalor,  
                               INPUT 0,
                               INPUT aux_nrdconta,
                               INPUT aux_dstippes).
            END.  
        IF  tt-xml-geral.dstagavo = 'analise'  AND /* busca parecer da pessoa */
            tt-xml-geral.dstagpai = 'dsstatus' AND
            tt-xml-geral.dstagfil = '#text'    THEN
            /* grava parecer da pessoa */ 
            RUN grava-parecer (INPUT tt-xml-geral.dsdvalor,  
                               INPUT 2,
                               INPUT aux_nrdconta,
                               INPUT aux_dstippes).
          
        IF  tt-xml-geral.dstagavo = 'analise'      AND /* busca pontos positivos */
            tt-xml-geral.dstagpai = 'dsmensag_pos' AND
            tt-xml-geral.dstagfil = '#text'        THEN
            /* grava pontos positivos */ 
            RUN grava-parecer (INPUT tt-xml-geral.dsdvalor,  
                               INPUT 3,
                               INPUT aux_nrdconta,
                               INPUT aux_dstippes).
      
        IF  tt-xml-geral.dstagavo = 'analise'      AND /* busca pontos atencao */
            tt-xml-geral.dstagpai = 'dsmensag_ate' AND
            tt-xml-geral.dstagfil = '#text' THEN
            /* grava pontos atencao */ 
            RUN grava-parecer (INPUT tt-xml-geral.dsdvalor,  
                               INPUT 4,
                               INPUT aux_nrdconta,
                               INPUT aux_dstippes).
      
      
      
    END.
    
    DISPLAY STREAM str_1 
            aux_dsparecer
            WITH FRAME f_parecer_geral.   
    
    ASSIGN aux_dsmensag_pos = ""
           aux_dsmensag_ate = "".

    FOR EACH tt-xml-parecer NO-LOCK:
    
      IF tt-xml-parecer.nrdconta <> "" THEN        
      DO:
          FIND crabass WHERE crabass.cdcooper =  par_cdcooper AND 
                             crabass.nrdconta =  int(tt-xml-parecer.nrdconta) NO-LOCK NO-ERROR.          
                    
          /* Verificar se ja ultrapassou o limite de linhas
            do relatorio e reiniciar pagina SD 296491*/
          IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
          DO:
              
              PAGE STREAM str_1.
              PUT STREAM str_1 SKIP
                         "4.1 Parecer de Credito: "
                          aux_dsparecer FORMAT "x(40)"
                         SKIP.
              
          END.

          ASSIGN aux_parecer = "Parecer de Credito do "  + tt-xml-parecer.dstippes + trim(tt-xml-parecer.nrdconta) + "-" + crabass.nmprimtl + ": " + tt-xml-parecer.dsstatus.
          DISPLAY STREAM str_1 
                aux_parecer          
                WITH FRAME f_parecer. 
        DOWN STREAM str_1 WITH FRAME f_parecer.
        
        DO aux_contador = 1 TO NUM-ENTRIES(tt-xml-parecer.dsmensag_pos,";"): 
           ASSIGN aux_dsmensag_pos = ENTRY(aux_contador,tt-xml-parecer.dsmensag_pos,";").           
           IF aux_contador = 1 THEN
               PUT STREAM str_1 "Pontos Positivos: " skip.
           
           IF  LINE-COUNTER(str_1) + 1 > PAGE-SIZE(str_1)   THEN
           DO:
               PAGE STREAM str_1.
           END.

           PUT STREAM str_1 aux_dsmensag_pos skip.
        END.
        
        IF tt-xml-parecer.dsmensag_ate <> "" THEN 
          DO aux_contador = 1 TO NUM-ENTRIES(tt-xml-parecer.dsmensag_ate,";"): 
              ASSIGN aux_dsmensag_ate = ENTRY(aux_contador,tt-xml-parecer.dsmensag_ate,";").
              IF aux_contador = 1 THEN
                  PUT STREAM str_1 "Pontos de Atencao: " skip.
              
              IF  LINE-COUNTER(str_1) + 1 > PAGE-SIZE(str_1)   THEN
              DO:
                  PAGE STREAM str_1.
              END.

              PUT STREAM str_1 aux_dsmensag_ate skip.
          END.                 
      END.
    END.
    
    RETURN "OK".

END PROCEDURE.

/* Rotina para tratamento da impressao da proposta e notas promissórias. */
PROCEDURE impressao-prnf:

   DEF INPUT  PARAM par_cdcooper AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_cdagenci AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                             NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                             NO-UNDO.
   DEF INPUT  PARAM par_idorigem AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_nrdconta AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_idseqttl AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_recidepr AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_nmarqimp AS CHAR                             NO-UNDO.
   DEF INPUT  PARAM par_flgimppr AS LOGI                             NO-UNDO.
   DEF INPUT  PARAM par_dtmvtolt AS DATE                             NO-UNDO.
   DEF INPUT  PARAM par_vlsmdtri AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vlcaptal AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vlprepla AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vltotapl AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vltotrpp AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vlstotal AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vltotccr AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vltotemp AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_vltotpre AS DECI                             NO-UNDO.
   DEF INPUT  PARAM par_dtmvtopr AS DATE                             NO-UNDO.
   DEF INPUT  PARAM par_inproces AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_promsini AS INTE                             NO-UNDO.
   DEF INPUT  PARAM par_cdprogra AS CHAR                             NO-UNDO.
   DEF INPUT  PARAM par_flgerlog AS LOGI                             NO-UNDO.
   DEF INPUT  PARAM par_dtcalcul AS DATE                             NO-UNDO.
   DEF INPUT  PARAM par_idimpres AS INTE                             NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.  

   EMPTY TEMP-TABLE tt-erro.

   FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crawepr   THEN
        RETURN.

   DEF BUFFER crabass FOR crapass.
   DEF BUFFER crabepr FOR crapepr.
   DEF BUFFER crabavt FOR crapavt.
   DEF BUFFER craxepr FOR crawepr.
   DEF BUFFER crablcr FOR craplcr.
   DEF BUFFER crabfin FOR crapfin.                      
 
   DEF VAR rel_dsdrisco        AS CHAR   FORMAT "x(02)"              NO-UNDO.
   DEF VAR rel_percentu        AS DECI   FORMAT "zz9.99"             NO-UNDO.
   DEF VAR rel_dsdrisco_calc   AS CHAR   FORMAT "x(02)"              NO-UNDO.
   DEF VAR rel_percentu_calc   AS DECI   FORMAT "zz9.99"             NO-UNDO.
                                                                     
   DEF VAR rel_nrdocnpj        AS CHAR                               NO-UNDO.
   DEF VAR aux_dsdlinha        AS CHAR                               NO-UNDO.
   DEF VAR aux_dsfinali        AS CHAR                               NO-UNDO.
   DEF VAR aux_dtlibera        AS DATE                               NO-UNDO.
   DEF VAR aux_dtvencto        AS DATE                               NO-UNDO.
   DEF VAR aux_nrcpfcgc        AS CHAR    FORMAT "x(18)"             NO-UNDO. 
   DEF VAR aux_vlpreemp        AS DECI                               NO-UNDO.
   DEF VAR aux_nrdmeses        AS INTE                               NO-UNDO.
   DEF VAR aux_nrctrrat        AS DECI                               NO-UNDO.
   DEF VAR aux_vlutlchq        AS DECI                               NO-UNDO.
   DEF VAR aux_tpdocged        AS INTE                               NO-UNDO.
   DEF VAR aux_dsemsnot        AS CHAR                               NO-UNDO.
   DEF VAR aux_dsvlpree        AS CHAR                               NO-UNDO.
   DEF VAR aux_dsoperac        LIKE craplcr.dsoperac                 NO-UNDO.
                                                                     
   DEF VAR pro_vlaplica        AS DECI                               NO-UNDO.
                                                                     
   DEF VAR aux_par_nrdconta    AS INTE                               NO-UNDO.
   DEF VAR aux_par_dsctrliq    AS CHAR                               NO-UNDO.
   DEF VAR aux_par_vlutiliz    AS DECI  FORMAT "z,zzz,zz9.99"        NO-UNDO.
                                                                     
   DEF VAR aux_vencimto        AS CHAR                               NO-UNDO.
   DEF VAR aux_vldctitu        AS DECI                               NO-UNDO.
   DEF VAR aux_vlutitit        AS DECI                               NO-UNDO.
   DEF VAR aux_vldscchq        AS DECI                               NO-UNDO.
                                                                     
   /** ROTATIVOS ATIVOS **/                                          
   /** Saldo Utilizado **/                                           
   DEF VAR aux_sld_cheque      AS DEC  FORMAT "zzz,zz9.99"           NO-UNDO.
   DEF VAR aux_sld_dscchq      AS DEC  FORMAT "zzz,zz9.99"           NO-UNDO.
   DEF VAR aux_sld_dsctit      AS DEC  FORMAT "zzz,zz9.99"           NO-UNDO.
                                                                     
   /** C.C.Garantidor **/                                            
   DEF VAR aux_ccg_chequ1      AS CHAR FORMAT "x(45)"                NO-UNDO.
   DEF VAR aux_ccg_dscch1      AS CHAR FORMAT "x(45)"                NO-UNDO.
   DEF VAR aux_ccg_dscti1      AS CHAR FORMAT "x(45)"                NO-UNDO.
   DEF VAR aux_ccg_crtcr1      AS CHAR FORMAT "x(45)"                NO-UNDO.
                                                                     
   DEF VAR aux_ccg_chequ2      AS CHAR FORMAT "x(45)"                NO-UNDO.
   DEF VAR aux_ccg_dscch2      AS CHAR FORMAT "x(45)"                NO-UNDO.
   DEF VAR aux_ccg_dscti2      AS CHAR FORMAT "x(45)"                NO-UNDO.
   DEF VAR aux_ccg_crtcr2      AS CHAR FORMAT "x(45)"                NO-UNDO.
                                                                     
   /** Data do contrato **/                                          
   DEF VAR aux_dtc_cheque      AS DATE FORMAT "99/99/9999"           NO-UNDO.
   DEF VAR aux_dtc_dscchq      AS DATE FORMAT "99/99/9999"           NO-UNDO.
   DEF VAR aux_dtc_dsctit      AS DATE FORMAT "99/99/9999"           NO-UNDO.
   DEF VAR aux_dtc_crtcre      AS DATE FORMAT "99/99/9999"           NO-UNDO.
                                                                     
   DEF VAR bkp_vltotrpp        AS DECI                               NO-UNDO.
                                                                     
   DEF VAR aux_qtdpremp        AS INTE FORMAT "z9"                   NO-UNDO.
   DEF VAR aux_existcrd        AS LOGI                               NO-UNDO.
   DEF VAR aux_qtdiaatr        AS INTE FORMAT "zzz9"                 NO-UNDO.
   DEF VAR rel_qtdiaatr        AS CHAR FORMAT "x(29)"                NO-UNDO.
   DEF VAR aux_garantia        AS CHAR                               NO-UNDO.
   DEF VAR rel_nmconjug        AS CHAR                               NO-UNDO.
   DEF VAR aux_dsquapro        AS CHAR                               NO-UNDO.
   DEF VAR aux_cdlcremp        LIKE craplcr.cdlcremp                 NO-UNDO.
   DEF VAR aux_idquapro        LIKE crawepr.idquapro                 NO-UNDO.
                                                                     
   DEF VAR rel_somadccf        AS INTE                               NO-UNDO.
   DEF VAR rel_valorccf        AS DECI                               NO-UNDO.
   DEF VAR rel_qtdevolu        AS INTE    FORMAT "z,zz9"             NO-UNDO.
   DEF VAR rel_dtultdev        AS DATE                               NO-UNDO.
   DEF VAR rel_flgcremp        AS LOGI    FORMAT "Sim/Nao"           NO-UNDO.
   DEF VAR rel_informac        AS CHAR                               NO-UNDO.
   DEF VAR rel_nrliquid        AS CHAR    FORMAT "x(55)"             NO-UNDO.
   DEF VAR rel_nrpatlvr        AS CHAR    FORMAT "x(48)"             NO-UNDO.
                                                                     
   DEF VAR rel_qtdaditi        AS INTE    FORMAT "zzz9"              NO-UNDO.
   DEF VAR rel_flgpreju        AS LOGI    FORMAT "Sim/Nao"           NO-UNDO.
   DEF VAR aux_vlslccap        AS DECI                               NO-UNDO.
                                                                     
   DEF VAR rel_lbcompre        AS CHAR    FORMAT "x(80)"             NO-UNDO.
   DEF VAR rel_comprend        AS DECI                               NO-UNDO.
                                                                     
   DEF VAR aux_qtopeliq        AS INTE    FORMAT "z9"                NO-UNDO.
                                                                     
   DEF VAR aux_vlrencje        AS DECI                               NO-UNDO.
   DEF VAR flg_temavali        AS LOGI                               NO-UNDO.
   DEF VAR rel_vlsmdsem        AS DECI                               NO-UNDO.
   DEF VAR rel_vldcotas        as DECI    FORMAT "zzz,zzz,zz9.99-"   NO-UNDO.
   DEF VAR rel_vlaplavl        AS DECI                               NO-UNDO.
   DEF VAR rel_vlrenavl        AS DECI                               NO-UNDO.
   DEF VAR rel_dsdrendi        AS CHAR                               NO-UNDO.
                                                                     
   DEF VAR rel_vldopera        as DECI    FORMAT "zzz,zzz,zz9.99-"   NO-UNDO.
   DEF VAR aux_dscatbem        AS CHAR                               NO-UNDO.
   DEF VAR aux_vlrtarif        AS DECI                               NO-UNDO.
   DEF VAR aux_vliofope        AS DECI                               NO-UNDO.
   DEF VAR aux_dsctrliq        AS CHAR                               NO-UNDO.
   DEF VAR aux_qtdias_carencia AS INTE                               NO-UNDO.
   DEF VAR i                   AS INTE                               NO-UNDO.
   
   DEF VAR h-b1wgen0097        AS HANDLE                             NO-UNDO.
                                                                     
   DEF VAR aux_linhacje        AS CHAR                               NO-UNDO.
   DEF VAR rel_vldendiv        AS DECI                               NO-UNDO.
   DEF VAR rel_dsavalde        AS CHAR                               NO-UNDO.
   DEF VAR rel_lblavali        AS CHAR    FORMAT "x(8)"              NO-UNDO.
   DEF VAR rel_qtdvezcl        AS INT     FORMAT "zz9"               NO-UNDO.
   DEF VAR rel_inpessoa        AS CHAR                               NO-UNDO.
   DEF VAR rel_nmrmativ        AS CHAR    FORMAT "x(35)"             NO-UNDO.
   DEF VAR rel_dtiniatv        LIKE crapjur.dtiniatv                 NO-UNDO.
   DEF VAR rel_perfatcl        LIKE crapjfn.perfatcl                 NO-UNDO.
   DEF VAR rel_lblimite        AS CHAR    FORMAT  "x(18)"            NO-UNDO.
   DEF VAR rel_lbconjug        AS CHAR    FORMAT "x(23)"             NO-UNDO.
   DEF VAR rel_lbctacje        AS CHAR    FORMAT "x(16)"             NO-UNDO.
   DEF VAR rel_lbperger        AS CHAR    FORMAT "x(38)"             NO-UNDO.
   DEF VAR rel_nrperger        AS CHAR    FORMAT "x(50)"             NO-UNDO.
                                                                     
   DEF VAR rel_lbptrpes        AS CHAR    FORMAT "x(47)"             NO-UNDO.
   DEF VAR rel_ptrpesga        AS CHAR    FORMAT "x(50)"             NO-UNDO.
                                                                     
   DEF VAR rel_dsfrmttl        AS CHAR    FORMAT "x(25)"             NO-UNDO.
   DEF VAR rel_nmextcop        AS CHAR    FORMAT "x(80)"             NO-UNDO.
   DEF VAR lbl_vldrendi        AS CHAR    FORMAT "x(27)"             NO-UNDO.
   DEF VAR lbl_dsdrendi        AS CHAR    FORMAT "x(33)"             NO-UNDO.
   DEF VAR aux_dsavlter        AS CHAR                               NO-UNDO.
                                                                     
   DEF VAR rel_modalida        AS CHAR    FORMAT "x(18)"             NO-UNDO.
   DEF VAR rel_dslimite        AS DECI                               NO-UNDO.
   DEF VAR rel_sldutili        AS DECI                               NO-UNDO.
   DEF VAR rel_garantid        AS CHAR    FORMAT "x(45)"             NO-UNDO.
   DEF VAR rel_dtcontra        AS DATE                               NO-UNDO.
                                                                     
   DEF VAR aux_qtmesdec        AS DECI                               NO-UNDO.
   DEF VAR aux_qtpreemp        AS DECI                               NO-UNDO.
   DEF VAR aux_restoobs        AS INTE                               NO-UNDO.
   DEF VAR rel_cpfctacj        AS CHAR     FORMAT "x(14)"            NO-UNDO.
   DEF VAR rel_nrctares        AS CHAR     FORMAT "x(18)"            NO-UNDO.
                                                                     
   DEF VAR tot_qtprecal        AS DECI                               NO-UNDO.
                                                                     
   DEF VAR rel_lbcotavl        AS CHAR     FORMAT "x(13)"            NO-UNDO.
   DEF VAR rel_lbsldavl        AS CHAR     FORMAT "x(11)"            NO-UNDO.
   DEF VAR rel_lbaplavl        AS CHAR     FORMAT "x(9)"             NO-UNDO.
   DEF VAR rel_dtliquid        AS DATE     FORMAT "99/99/9999"       NO-UNDO.
                                                                     
   DEF VAR lbl_dtoutspc        AS CHAR                               NO-UNDO.
   DEF VAR lbl_dtoutris        AS CHAR                               NO-UNDO.
   DEF VAR lbl_vltotsfn        AS CHAR                               NO-UNDO.
                                                                     
   DEF VAR aux_garantia1       AS CHAR                               NO-UNDO.
   DEF VAR aux_garantia2       AS CHAR                               NO-UNDO.
                                                                     
   DEF VAR par_vlsdeved        AS DECI                               NO-UNDO.
   DEF VAR par_vlpreemp        AS DECI                               NO-UNDO.
   DEF VAR par_qtmesatr        AS DECI                               NO-UNDO.
                                                                     
   DEF VAR tot_vlsdeved        AS DECI                               NO-UNDO.
   DEF VAR tot_vlpreemp        AS DECI                               NO-UNDO.
   DEF VAR tot_vlliquid        AS DECI                               NO-UNDO.
   DEF VAR aux_nmcidpac        AS CHAR                               NO-UNDO.
   DEF VAR aux_contador        AS INTE                               NO-UNDO.
   DEF VAR aux_nivrisco        AS CHAR                               NO-UNDO.
   DEF VAR aux_dtrefere        AS DATE                               NO-UNDO.
   DEF VAR tab_vltotemp        AS DECI                               NO-UNDO.
   DEF VAR aux_contapag        AS INTE                               NO-UNDO.
   DEF VAR aux_dsextens        AS CHAR                               NO-UNDO.
   DEF VAR aux_qtregist        AS INTE                               NO-UNDO.

   DEF VAR aux_cpfaval1        AS CHAR FORMAT "x(18)"                NO-UNDO.
   DEF VAR aux_nmdaval1        AS CHAR                               NO-UNDO.
   DEF VAR aux_cpfaval2        AS CHAR FORMAT "x(18)"                NO-UNDO.
   DEF VAR aux_nmdaval2        AS CHAR                               NO-UNDO.
   DEF VAR aux_ctaaval         AS INTE                               NO-UNDO.
   DEF VAR aux_iddoaval        AS INTE                               NO-UNDO.

   DEF VAR aux_dsdrisgp AS CHAR                                      NO-UNDO.
   DEF VAR aux_vlendivi AS DEC  FORMAT "zzz,zzz,zz9.99"              NO-UNDO.
   DEF VAR aux_nrdgrupo AS INTE                                      NO-UNDO.
   DEF VAR aux_gergrupo AS CHAR                                      NO-UNDO.
   DEF VAR aux_dsdrisco AS CHAR                                      NO-UNDO.
   DEF VAR aux_tpempres AS CHAR                                      NO-UNDO.
   DEF VAR aux_tpemprst AS CHAR  FORMAT "x(1)"                       NO-UNDO.
   DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.
   DEF VAR aux_nmconjug AS CHAR                                      NO-UNDO.
   DEF VAR aux_nrcpfcjg AS CHAR                                      NO-UNDO.
   DEF VAR aux_tpdoccjg AS CHAR                                      NO-UNDO.
   DEF VAR aux_nrdoccjg AS CHAR                                      NO-UNDO.
   DEF VAR aux_cpfcgav1 AS CHAR                                      NO-UNDO.
   DEF VAR aux_cpfcgav2 AS CHAR                                      NO-UNDO.
   DEF VAR aux_dtultdma AS DATE                                      NO-UNDO.
  
  /* Variaveis para o XML */ 
   DEF VAR xDoc          AS HANDLE                                   NO-UNDO.   
   DEF VAR xRoot         AS HANDLE                                   NO-UNDO.  
   DEF VAR xRoot2        AS HANDLE                                   NO-UNDO.  
   DEF VAR xField        AS HANDLE                                   NO-UNDO. 
   DEF VAR xText         AS HANDLE                                   NO-UNDO. 
   DEF VAR aux_cont_raiz AS INTEGER                                  NO-UNDO. 
   DEF VAR aux_cont      AS INTEGER                                  NO-UNDO. 
   DEF VAR ponteiro_xml  AS MEMPTR                                   NO-UNDO. 
   DEF VAR xml_req       AS LONGCHAR                                 NO-UNDO.

   DEF VAR aux_dssitcta AS CHAR                                      NO-UNDO.

   /*  Nota Promissoria .................................................... */
   
   FORM aux_vencimto AT 40     FORMAT "x(40)"
        SKIP(1)
        "NUMERO" rel_dsctremp  FORMAT "x(13)"
        rel_dsdmoeda[1]        FORMAT "x(5)"
        aux_vlpreemp           FORMAT "zzz,zzz,zz9.99"
        SKIP(1)
        "Ao(s)" rel_dsmvtolt[1] FORMAT "x(68)" 
        SKIP
        rel_dsmvtolt[2]        FORMAT "x(44)" "pagarei por esta unica via de" 
        SKIP
        "N O T A  P R O M I S S O R I A"  "a" 
        crapcop.nmrescop       FORMAT "x(11)" 
        SKIP
        crapcop.nmextcop       FORMAT "x(50)"       
        rel_nrdocnpj     AT 52 FORMAT "x(23)"
        SKIP
        "ou a sua ordem a quantia de"       
        rel_dspreemp[1] AT 29  FORMAT "x(46)" 
        SKIP
        rel_dspreemp[2]        FORMAT "x(74)" 
        SKIP
        "em moeda corrente deste pais."
        WITH COLUMN 7 NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_cab1_promissoria.
        
   FORM "Vencimento: " AT 30 
        aux_vencimto          FORMAT "x(16)"
        SKIP(1)
        "NUMERO" rel_dsctremp FORMAT "x(13)"
        rel_dsdmoeda[1]       FORMAT "x(5)"
        aux_vlpreemp          FORMAT "zzz,zzz,zz9.99"
        SKIP(1)              
        "Na apresentacao desta, pagarei por  esta  unica  via  de" AT 19 
        SKIP
        "N O T A  P R O M I S S O R I A"  "a" 
        crapcop.nmrescop       FORMAT "x(11)" 
        SKIP
        crapcop.nmextcop       FORMAT "x(50)"       
        rel_nrdocnpj     AT 52 FORMAT "x(23)"
        SKIP
        "ou a sua ordem a quantia de"       
        rel_dspreemp[1] AT 29 FORMAT "x(46)" 
        SKIP
        rel_dspreemp[2]       FORMAT "x(74)" 
        SKIP
        "em moeda corrente deste pais."
        WITH COLUMN 7 NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_cab2_promissoria.
   
   FORM SKIP(1)
        aux_dsemsnot    AT 28 FORMAT "x(45)"
        SKIP(1)
        "________________________________________________"
        SKIP
        rel_nmprimtl[1]      FORMAT "x(50)"
        SKIP
        rel_dscpfcgc         FORMAT "x(40)"
        SKIP
        "Conta/dv:"          rel_nrdconta FORMAT "zzzz,zzz,9"
        SKIP
        rel_dsendres[1]      FORMAT "x(40)"
        SKIP
        rel_dsendres[2]      FORMAT "x(81)"
        SKIP(1)
        "Avalista 1:"        
        "Avalista 2:" AT 50
        SKIP(3)
        "________________________________________________"
        "_______________________________________________"
        SKIP
        rel_nmdaval1            FORMAT "x(48)"
        rel_nmdaval2     AT 50  FORMAT "x(47)"
        SKIP              
        rel_dscpfav1            FORMAT "x(48)"
        rel_dscpfav2     AT 50  FORMAT "x(47)"
        SKIP
        rel_dsendav1[1]         FORMAT "x(48)"
        rel_dsendav2[1]  AT 50  FORMAT "x(47)"
        SKIP
        rel_dsendav1[2]         FORMAT "x(48)"
        rel_dsendav2[2]  AT 50  FORMAT "x(47)"
        SKIP
        rel_dsendav1[3]         FORMAT "x(48)"
        rel_dsendav2[3]  AT 50  FORMAT "x(47)"
        SKIP(3)
        "________________________________________________"
        "_______________________________________________"             
        SKIP
        rel_nmcjgav1            FORMAT "x(48)"
        rel_nmcjgav2     AT 50  FORMAT "x(47)"
        SKIP
        aux_cpfcgav1            FORMAT "x(48)"
        aux_cpfcgav2     AT 50  FORMAT "x(47)"
        SKIP
        WITH COLUMN 7 NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promissoria.
   
   FORM SKIP(3)
        WITH NO-BOX WIDTH 137 FRAME f_linhas.
   
   /*  Proposta de Emprestimo .............................................. */
   FORM  "PARA USO DA DIGITALIZACAO"                                  AT  80
         SKIP(1)
         rel_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT  79
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT  91
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT 102
         SKIP
         rel_nmextcop SKIP
         "PROPOSTA DE OPERACAO DE CREDITO PARA PESSOA" 
         rel_inpessoa 
         "- Operacao: " 
         aux_dsoperac FORMAT "x(30)" 
         SKIP
         "Linha:" aux_cdlcremp "-" 
         aux_dslcremp                        FORMAT "x(40)"
         SKIP  
         "Qualificacao da Operacao: " 
         aux_idquapro                        FORMAT "9"
         "-"                                 
         aux_dsquapro                        FORMAT "x(30)"
         SPACE(5) "Produto: " 
         aux_tpempres FORMAT "x(17)"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_cabecalho_uso_digitalizacao.
                               
   FORM  rel_nmextcop SKIP
         "PROPOSTA DE OPERACAO DE CREDITO PARA PESSOA" 
         rel_inpessoa 
         "- Operacao: " 
         aux_dsoperac FORMAT "x(30)"
         "Linha:" aux_cdlcremp "-" 
         aux_dslcremp         FORMAT "x(40)"
         SKIP  
         "Qualificacao da Operacao: " 
         aux_idquapro         FORMAT "9"
         "-" 
         aux_dsquapro             FORMAT "x(30)"
         SPACE(5) "Produto: " 
         aux_tpempres FORMAT "x(17)"
         SKIP(1)
         WITH PAGE-TOP NO-BOX NO-LABELS WIDTH 96 FRAME f_cabecalho.
   
   /******** 1 - DADOS DO ASSOCIADO ***********/
   
   FORM  "\033\105\ 1 - DADOS DO ASSOCIADO\033\106"
         SKIP(1)
         "\033\105"
         "Conta/dv:" rel_nrdconta     FORMAT "zzzz,zzz,9" 
         "\033\106"   
         "    PA:"   rel_dsagenci     FORMAT "x(25)"  
         "Nome:"    rel_nmprimtl[1]   FORMAT "x(35)"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_dados.
                                           
   FORM  "\033\017" 
         "CPF/CNPJ:"            aux_nrcpfcgc
         "Adm COOP:"            rel_dtadmiss     FORMAT "99/99/9999"
         "Empresa :"            rel_nmempres     FORMAT "x(30)"
         SKIP(1)               
         " Funcao:"             crapttl.dsproftl FORMAT "x(20)"
         "Profissao:"           rel_dsfrmttl     FORMAT "x(25)"
         "Adm empr:"            rel_dtadmemp     FORMAT "99/99/9999"
         "Salario:"             rel_vlsalari     FORMAT "z,zzz,zz9.99"
         SKIP(1)   
         " Empresa Conjuge:"    crapprp.nmempcje FORMAT "x(20)"
         "Salario do Conjuge:"   
         rel_vlsalcon                            FORMAT "z,zzz,zz9.99"
         SPACE(2)                
         "Salario Outros:"      crapprp.vloutras FORMAT "z,zzz,zz9.99"
         SPACE(1)                
         "Aluguel(Despesa):"   crapprp.vlalugue FORMAT "zzz,zz9.99"  
         "\022\033\115"          
         SKIP(1)                 
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_dados_fisica.
   
   FORM  "\033\017"       /* Letra menor*/
         lbl_vldrendi
         SPACE(2)
         lbl_dsdrendi 
         "\022\033\115"   /* Fim letra menor */
         SKIP
         WITH DOWN NO-BOX NO-LABELS WIDTH 96 FRAME f_rendas_fisica.
   
   FORM  "\033\017"       /* Letra menor*/
         "CPF/CNPJ:"                           aux_nrcpfcgc
         "Adm COOP:"                   AT 34   rel_dtadmiss FORMAT "99/99/9999"
         "Ramo de atividade:"          AT 56   rel_nmrmativ          
         SKIP
         SPACE(1)
         "Fundacao:"                           rel_dtiniatv
         "Fatur. medio bruto mes:"     AT 23   crapprp.vlmedfat 
         "Conc. Fatur. unico cliente:" AT 63   rel_perfatcl  
         "Aluguel(Despesa):"           AT 98 crapprp.vlalugue
         "\022\033\115"   /* Fim Letra menor */
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_dados_juridica.
   
   FORM  "\033\017"      /* Letra menor */  
         "Bens:"                crapbpr.dsrelbem  FORMAT "x(40)"  
         "Livre Onus:"          crapbpr.persemon  "%"
         "Qtd/Vlr Parc.:"       crapbpr.qtprebem  "x"  
                                crapbpr.vlprebem  FORMAT "zzz,zz9.99"
         "Vlr:"                 crapbpr.vlrdobem  FORMAT "zzz,zzz,zz9.99"
         "\022\033\115"  /* Fim letra menor */    
         WITH DOWN NO-LABELS WIDTH 130 FRAME f_bens.
        
   /************ 2- HISTORICO DO ASSOCIADO ***************/
   
   FORM  SKIP(1)         /* Letra em negrito */
         "\033\105\ 2 - HISTORICO DO ASSOCIADO\033\106"
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_historico.
   
   FORM  SKIP(1)
         "\033\017"   
         "Saldo Medio do Trimestre:" rel_vlsmdtri FORMAT "zzz,zzz,zz9.99"
         "Capital:"          AT  46  rel_vlcaptal FORMAT "zzz,zzz,zz9.99-"
         "Plano de Capital:" AT  71  rel_vlprepla FORMAT "zzz,zz9.99"
         "Aplicacoes:"       AT 101  pro_vlaplica FORMAT "zzz,zzz,zz9.99"
         "\022\033\115"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_historico_2.
   
   FORM  "\033\105\ 2.1 - ROTATIVOS ATIVOS\033\106"
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_cab_rotativos.  
   
   FORM  SKIP(1)
         "\033\017" 
         "Modalidade                Limites    Saldo Utilizado"     
         "C.C./CPF/CNPJ Garantidor                      Data do contrato" AT 60
         "\022\033\115"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_cab_rotativos_2.
   
   FORM  "\033\017"   
         rel_modalida  AT 4
         rel_dslimite  AT 25 FORMAT "zzz,zzz,zz9.99" 
         rel_sldutili  AT 46        
         rel_garantid  AT 60   
         rel_dtcontra  AT 114    
         "\022\033\115"    
         WITH DOWN NO-BOX NO-LABELS WIDTH 130 FRAME f_rotativos.
   
   FORM  SKIP(1)
         "\033\105"
         "2.2 - DEMAIS OPERACOES DE CREDITO ATIVAS ("
         aux_qtdpremp ")"
         "\033\106"    
         SKIP(1)
         "\033\017"
         "   Contrato  Saldo Devedor      Prestacoes"
         "Atraso/Parcela   Finalidade"                     AT 57
         "Linha de Credito       Garantia       Liquidar"  AT 95
         "\022\033\115"
         SKIP
         WITH NO-BOX NO-LABELS WIDTH 140 FRAME f_pro_ed1.
   
   FORM  "\033\017"
         tt-operati.dsidenti              FORMAT "x(1)"
         tt-operati.nrctremp              FORMAT "zz,zzz,zz9"
         tt-operati.vlsdeved              FORMAT "zzz,zzz,zz9.99"    
         tt-operati.dspreapg      AT  31  FORMAT "x(11)"
         tt-operati.vlpreemp      AT  43  FORMAT "zzzz,zz9.99"
         tt-operati.qtprecal      AT  58  FORMAT "zzz,zz9.9999"
         tt-operati.dsfinemp      AT  73  FORMAT "x(20)"
         tt-operati.dslcremp      AT  94  FORMAT "x(20)"
         tt-operati.garantia      AT 117  FORMAT "x(18)"     
         tt-operati.dsliqant      AT 137  FORMAT "x(3)"                 
         "\022\033\115"                  
         WITH NO-BOX NO-LABELS  DOWN WIDTH 150 FRAME f_dividas.
                                                                    
   FORM  "\033\017"
         cratepr.dsgarant         AT 116  FORMAT "x(18)" 
         "\022\033\115"                   
         WITH NO-BOX NO-LABELS DOWN  WIDTH 150 FRAME f_dividas_garantia.
                           
   
   FORM  "\033\017"
         "--------------                ------------  --------------"  AT 14
         SKIP
         " TOTAL"           
         tot_vlsdeved     AT 14 FORMAT "zzz,zzz,zz9.99"
         tot_vlpreemp     AT 40 FORMAT "zzzzz,zz9.99"
         tot_qtprecal     AT 56 FORMAT "zzz,zz9.9999" 
         "\022\033\115"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_tot_div.
   
   /**************** CO-RESPONSABILIDADE *****************/
   
   FORM  "\033\017" "\033\105Co-responsabilidade\033\106"
         SKIP(1)
         "  Contrato  Saldo Devedor         Prestacoes"
         "Atraso/Parcela Finalidade"                       AT 53
         "Linha de Credito           Responsabilidade"     AT 95
         "\022\033\115"
         WITH NO-BOX NO-LABELS WIDTH 140 FRAME f_pro_ed2.
   
   FORM  "\033\017"
         w-co-responsavel.nrctremp           FORMAT "zz,zzz,zz9"
         w-co-responsavel.vlsdeved           FORMAT "-zzz,zzz,zz9.99"
         rel_dspreapg       AT 30   FORMAT "x(11)"
         w-co-responsavel.vlpreemp   AT 43   FORMAT "zzzz,zz9.99"
         aux_qtprecal       AT 57   FORMAT "zzz,zz9.9999"
         w-co-responsavel.dsfinemp   AT 70   FORMAT "x(24)"   
         w-co-responsavel.dslcremp   AT 97   FORMAT "x(24)"             
         rel_nrctares       AT 124  
         "\022\033\115"
         WITH NO-BOX NO-LABELS DOWN WIDTH 145 FRAME f_co-responsavel.
   
   FORM  "\033\017"
         "--------------              ------------  -------------" AT 14
         SKIP
         " TOTAL"
         tot_vlsdeved     AT 12 FORMAT "zzz,zzz,zz9.99"
         tot_vlpreemp     AT 40 FORMAT "zzzzz,zz9.99"
         tot_qtprecal     AT 55 FORMAT "zzz,zz9.9999"
         "\022\033\115"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_tot_co-responsavel.
   
   FORM  "\033\105"
         "2.3 - ULTIMAS OPERACOES DE CREDITO LIQUIDADAS (" aux_qtopeliq ")"
         "\033\106"
         SKIP(1)                         
         "\033\017"
         "Contrato     Valor Operacao  Prestacoes    Finalidade"
         "Linha de credito             Liquidacao"             AT 75
         "Pontualidade"  AT 115                    
          "\022\033\115"
         WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_cab_ultimas.
        
   FORM  "\033\017"
         aux_tpemprst
         crapepr.nrctremp         FORMAT "zz,zzz,zz9"
         crapepr.vlemprst         FORMAT "zzz,zzz,zz9.99"
         crapepr.qtpreemp AT 33
         "/"              AT 36
         aux_dsvlpree     AT 37   FORMAT "x(10)"
         rel_dsfinemp     AT 47   FORMAT "x(25)"
         rel_dslcremp     AT 75   FORMAT "x(25)"
         rel_dtliquid     AT 104                                       
         rel_qtdiaatr     AT 115 
         "\022\033\115"
         WITH NO-ATTR-SPACE DOWN NO-LABELS WIDTH 150 FRAME f_ultimas_operac. 
         
   /*********** 3 - DADOS DA SOLICITACAO ***************/
   
   FORM  "\033\105"
         "3 - DADOS DA SOLICITACAO\033\106" SKIP(1)
         "\033\017"
         "Contrato  Valor Operacao   Prestacoes          Finalidade" 
         "Linha de Credito"        AT 93
         SKIP(1)
         crawepr.nrctremp            FORMAT "zz,zzz,zz9" 
         rel_vldopera        AT 12   FORMAT "zzz,zzz,zz9.99" 
         crawepr.qtpreemp    AT 28 
         "de"
         crawepr.vlpreemp            FORMAT "zzz,zz9.99"
         rel_dsfinemp        AT 49   FORMAT "x(40)"
         rel_dslcremp        AT 91   FORMAT "x(40)"
         SKIP(1)
         " Garantia: "
         aux_garantia                FORMAT "x(100)"
         "\022\033\115"
         WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_dados_solic.
   
   
   FORM "\033\105"
        "3.1 - OUTRAS PROPOSTAS EM ANDAMENTO" 
        "\033\106" 
        "\033\017"
        SKIP(1)
        " Data        Contrato     Valor Operacao   Prestacoes    "
        "Finalidade                        Linha de Credito"
        "\022\033\115"
        WITH WIDTH 132 FRAME f_outras.  
   
   FORM "\033\017"
        aux_tpemprst
        craxepr.dtmvtolt   
        craxepr.nrctremp  FORMAT "zz,zzz,zz9"
        craxepr.vlemprst   
        aux_dsvlpree      FORMAT "x(15)"
        aux_dsfinali      FORMAT "x(33)" 
        aux_dsdlinha      FORMAT "x(33)"
        SKIP(1)
        " Garantia:"
        aux_garantia      FORMAT "x(90)"
        SKIP(1)
        "\022\033\115"
        WITH NO-LABEL NO-UNDERLINE DOWN WIDTH 132 FRAME f_outras_prop.
   
   FORM SKIP(1)
        "\033\017"
        "CET:" crawepr.percetop "% a.a"
        SKIP(1)
        " VALOR DISPONIVEL EM" aux_dtlibera 
        ":" rel_vldsaque
        "TOTAL OP.CREDITO:" AT 62 aux_par_vlutiliz 
        SKIP(1)
        " AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS NOS SERVICOS"
        "DE PROTECAO AO CREDITO"                   
        SKIP
        " (SPC,SERASA,CADIN ...) ALEM DO CADASTRO DA CENTRAL DE RISCO DO"  
        "BANCO CENTRAL DO BRASIL E SISTEMA"  
        SKIP
        " AILOS."            
        SKIP(1)
        rel_lbconjug            
        crapprp.flgdocje
        rel_lbctacje  AT 50  rel_cpfctacj  
        "\022\033\115"   
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_dados_solic_2.
   
   FORM SKIP(1)
        "CONJUGE"
        SKIP(1)   
        tt-valores-gerais.nmprimtl LABEL "Nome"      FORMAT "x(30)"
        "\033\105" 
        tt-valores-gerais.nrdconta LABEL "Conta/dv"  FORMAT "zzzz,zzz,9"
        "\033\106"
        WITH SIDE-LABELS NO-BOX WIDTH 132 FRAME f_conjuge.
   
   FORM SKIP(1)
         "\033\017"
        "Emprestimos/Financiamentos"
        "\022\033\115"
        SKIP(1)    
        "\033\017"
        "Contrato Saldo Devedor  Prestacoes      Prestacao Atraso/Parcela "
        "Finalidade       Linha de Credito     Garantia"
        "\022\033\115"
        WITH COLUMN 1 NO-BOX WIDTH 132 FRAME f_conj_emprest.   
   
   FORM "\033\017"
        tt-dados-epr.nrctremp  FORMAT "zz,zzz,zz9"
        tt-dados-epr.vlsdeved  FORMAT "z,zzz,zz9.99"
        SPACE(2)
        tt-dados-epr.qtprecal  FORMAT "zzz,zz9.9999-"
        "/"
        tt-dados-epr.qtpreemp 
        tt-dados-epr.vlpreemp  FORMAT "zzz,zz9.99"
        tt-dados-epr.qtmesatr  FORMAT "zz9.9999"
        SPACE(7)        
        tt-dados-epr.dsfinemp  FORMAT "x(15)"
        tt-dados-epr.dslcremp  FORMAT "x(15)"
        tt-dados-epr.dsdavali  FORMAT "x(30)"  
        "\022\033\115"
        WITH NO-LABEL DOWN COLUMN 1 NO-BOX WIDTH 142 FRAME f_conj_emprest_2.
   
   FORM SKIP
        "\033\017"
        "------------" AT 14
        "---------"    AT 44
        "------"       AT 56
        SKIP
        " TOTAL"
        par_vlsdeved  FORMAT "z,zzz,zz9.99" AT 12 
        par_vlpreemp  FORMAT "zzz,zz9.99"   AT 41
        par_qtmesatr  FORMAT "zz9.9999"     AT 52
        "\022\033\115"
        WITH NO-LABEL COLUMN 1 NO-BOX WIDTH 142 FRAME f_conj_emprest_tot.
   
   
   FORM SKIP(1)
        aux_nmcidpac FORMAT "x(13)" AT 4 rel_ddmvtolt FORMAT "99"
        "de" rel_dsmesref FORMAT "x(9)"
        "de" rel_aamvtolt FORMAT "9999"
        SKIP(4)
        "__________________________________________________" AT  4
        aux_linhacje                   AT 62  FORMAT "x(36)"
        SKIP
        rel_nmprimtl[1]                AT 4   FORMAT "x(50)"
        rel_nmconjug                   AT 62  FORMAT "x(36)"
        SKIP(4)
        "___________________________________________" AT 4 SKIP
        "Operador:"                    AT 4
        aux_nmoperad                          FORMAT "x(40)"
        WITH NO-BOX NO-LABELS WIDTH 98 FRAME f_aprovacao.
        
   /**************  4- ANALISE DA PROPOSTA  ***************/
   
   FORM  "\033\1054 - ANALISE DA PROPOSTA\033\106" 
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_cab_analise.
   
   FORM  SKIP(1)
         "\033\105COMITE DE APROVACAO:\033\106"
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_cab_comite_observ.
   
   FORM  SKIP(1)
         "\033\105OBSERVACOES:\033\106"
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_cab_observac.
        
   FORM  rel_dsobscmt   AT 1 
         WITH NO-BOX NO-LABELS WIDTH 96 DOWN FRAME f_comite_observ.
   
   FORM  rel_dsobserv   AT 1 
         WITH NO-BOX NO-LABELS WIDTH 96 DOWN FRAME f_observac.
   
   FORM  SKIP(1)
         "\033\105SOCIOS \033\106" 
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_cab_socios.    
   
   FORM  SKIP(1)
         "Nome"           
         rel_lblavali                                AT 27
         "Endividamento"                             AT 39
         rel_lbcotavl                                AT 55
         rel_lbsldavl                                AT 71
         rel_lbaplavl                                AT 87
         SKIP
         crapavt.nmdavali      FORMAT "x(20)"       
         crapavt.nrdctato      FORMAT "zzzzzz,zzz,z" AT 23
         rel_vldendiv                                AT 42
         rel_vldcotas                                AT 54
         rel_vlsmdsem          FORMAT "zzzz,zz9.99"  AT 71
         rel_vlaplavl          FORMAT "zzzz,zz9.99"  AT 85
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_socios.
   
   
   FORM  rel_lbperger 
         rel_nrperger  
         SKIP(1)
         "INFORMACOES CADASTRAIS:"  rel_informac     FORMAT "x(33)"
         SKIP
         WITH NO-BOX NO-LABELS WIDTH 96 DOWN FRAME f_analise.
                                                                  
   FORM  lbl_dtoutspc FORMAT "x(42)" crapprp.dtoutspc  
         WITH NO-BOX NO-LABELS WIDTH 96 DOWN FRAME f_analise_2.

   FORM  "CENTRAL DE RISCO EM:"           crapprp.dtdrisco        
         "VLR TOTAL SFN C/COOP:"   AT 55  
         crapprp.vltotsfn FORMAT "zzz,zzz,zz9.99"
         SKIP
         lbl_dtoutris FORMAT "x(42)" crapprp.dtoutris
         lbl_vltotsfn FORMAT "x(21)" AT 55
         crapprp.vlsfnout FORMAT "zzz,zzz,zz9.99"
         SKIP
         "QTD DE OPERACOES:"              crapprp.qtopescr
         "QTDADE DE IF EM QUE POSSUI OPERACOES:" AT 35  crapprp.qtifoper
         SKIP
         "OP. VENCIDAS    :"              
         crapprp.vlopescr FORMAT "zzz,zzz,zz9.99" 
         SKIP
         "PREJUIZO        :"              
         crapprp.vlrpreju FORMAT "zzz,zzz,zz9.99"
         "CONSULTA DO CCF:"                      AT 56  rel_somadccf
         "CHEQUES" 
         SKIP 
         "VALOR TOTAL CCF:"                      AT 56
         rel_valorccf     FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "Sit.:"                          rel_dssitdct     FORMAT "x(26)"
         "Rating:"                 AT 35  rel_dsdrisco        
         "Prov:"                   AT 51  rel_percentu
         "Calc.:"                  AT 69  rel_dsdrisco_calc
         "Prov:"                   AT 83  rel_percentu_calc
         SKIP(1)
         "Cheques devolvidos:"            rel_qtdevolu
         "Data da ultima devolucao:"            AT 28   rel_dtultdev
         "Qtd. Adto. Depositante:"                      rel_qtdaditi
         "dias"
         SKIP(1)
         "EM CL:"                                       rel_qtdvezcl
         "meses"
         "A conta ja causou prejuizo na Coop.:" AT 19   rel_flgpreju
         "Tem linha de credito 800/900:"        AT 63   rel_flgcremp
         SKIP(1)
         "Valor Solicitado/Valor do capital:"           aux_vlslccap
         "vezes"
         SKIP
         "Liquidez das garantias:"                      rel_nrliquid
         SKIP(1)
         rel_lbcompre  
         rel_lbptrpes      
         rel_nrpatlvr   
         WITH NO-BOX NO-LABELS WIDTH 96 DOWN FRAME f_analise_3.

   /************* 5- GARANTIA ****************/
   
   FORM  SKIP(2)
         "\033\105\5 - GARANTIA\033\106" SKIP 
         WITH NO-BOX NO-LABELS WIDTH 120 DOWN FRAME f_garantia.
   
   FORM  SKIP(1)
         "Nome"                   
         rel_lblavali                              AT 24
         "Endividamento      Renda"                AT 33
         rel_lbcotavl                              AT 58
         rel_lbsldavl                              AT 73
         rel_lbaplavl                              AT 88
         SKIP
         "Mensal"           AT 51
         SKIP
         crawepr.nmdaval1          FORMAT "x(16)"
         crawepr.nrctaav1          FORMAT "zzzzzzzz,zzz,9"  
         rel_vldendiv      AT 33   FORMAT "zz,zzz,zz9.99"   
         rel_vlrenavl      AT 47   FORMAT "zzz,zz9.99"
         rel_vldcotas      AT 57   FORMAT "zzz,zzz,zz9.99"
         rel_vlsmdsem      AT 72   FORMAT "z,zzz,zz9.99"
         rel_vlaplavl      AT 85   FORMAT "z,zzz,zz9.99"      
         SKIP
         "Aval de:"  "\033\105" rel_dsavalde   FORMAT "x(85)"  "\033\106" 
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 120 DOWN FRAME f_garantia_avl.
   
   FORM  "\033\017Bens:"        crapbem.dsrelbem  FORMAT "x(40)"
         "Livre onus:"          crapbem.persemon  "%" 
         "Qtd/Vlr Parcela:"     crapbem.qtprebem  "x"
                                crapbem.vlprebem  FORMAT "zzz,zz9.99"
         "Vlr:"                 crapbem.vlrdobem  FORMAT "zzz,zzz,zz9.99"
         "\022\033\115" 
         WITH NO-BOX NO-LABELS WIDTH 130 DOWN FRAME f_garantia_bens_avl.
   
   
   FORM  SKIP(1)
         "Alienacao Fiduciaria"
         WITH NO-BOX NO-LABELS WIDTH 120 FRAME f_alienacao.
   
   FORM "\033\105Bem"
        aux_contador     NO-LABEL
        "\033\106"
        SKIP
        crapbpr.vlmerbem LABEL "Valor de mercado"
        SKIP(1)
        crapbpr.dscatbem LABEL "Categoria" FORMAT "x(30)"
        SKIP
        crapbpr.dsbemfin LABEL "Descricao" FORMAT "x(25)"
        crapbpr.nrrenava LABEL "Renavan"
        crapbpr.dschassi LABEL "Chassi"
        crapbpr.tpchassi LABEL "Tipo Chassi"
        SKIP
        crapbpr.ufdplaca LABEL "Placa"
        crapbpr.nrdplaca NO-LABEL
        crapbpr.uflicenc LABEL "Licenciado"
        crapbpr.nranobem LABEL "Ano"
        crapbpr.nrmodbem LABEL "Modelo"
        crapbpr.dscorbem LABEL "Cor"
        SKIP(1)
        WITH DOWN SIDE-LABELS WIDTH 132 FRAME f_bem_alienacao.
           
   FORM SKIP(1)
        "Hipoteca/Alienacao (Imoveis)"
        WITH NO-BOX NO-LABELS WIDTH 120 FRAME f_hipoteca.       
   
   FORM "\033\105Bem"   
        aux_contador     NO-LABEL
        "\033\106" 
        SKIP 
        crapbpr.vlmerbem LABEL "Valor de mercado"
        SKIP
        crapbpr.dscatbem NO-LABEL FORMAT "x(30)"
        SKIP
        crapbpr.dsbemfin NO-LABEL FORMAT "x(100)"
        SKIP
        crapbpr.dscorbem NO-LABEL FORMAT "x(100)"
        SKIP(1)
        WITH DOWN SIDE-LABELS WIDTH 120 FRAME f_bem_hipoteca.
   
   FORM "\033\105Bem"   
        aux_contador     NO-LABEL
        "\033\106" 
        SKIP 
        crapbpr.vlmerbem LABEL "Valor de mercado"
        SKIP
        crapbpr.dscatbem NO-LABEL FORMAT "x(30)"
        SKIP
        crapbpr.dsmarceq LABEL "Descricao" FORMAT "x(100)" /*descrição*/
        SKIP
        crapbpr.dsbemfin LABEL "Modelo" FORMAT "x(100)" /*Modelo*/        
        SKIP
        crapbpr.dschassi LABEL "Nr Serie" FORMAT "x(100)" /*nr serie*/
        SKIP
        crapbpr.nranobem LABEL "Ano Fabricacao"  /*Ano*/  
        SKIP(1)
        WITH DOWN SIDE-LABELS WIDTH 120 FRAME f_bem_maqequip.     
   
   FORM  SKIP(1)
         "PATR. GARANT./SOCIOS S/ ONUS:"
         rel_ptrpesga 
         WITH NO-BOX NO-LABELS WIDTH 96 DOWN FRAME f_patrimonio_socios.
   
   FORM  "Comite de Credito:"
         SKIP(1)
         "Aprovado: (  )"                  SKIP
         "Aprovado com Restricao: (  )"    SKIP
         "Refazer: (  )"                   SKIP
         "Nao aprovado:(  )"
         "Data da Analise: ___/___/______" AT 60
         SKIP(1)
         "Observacoes:" SKIP(1)
         "_________________________________________________________________"
         "___________________________" AT 66  SKIP(1)
         "_________________________________________________________________"
         "___________________________" AT 66  SKIP(1)
         "_________________________________________________________________"
         "___________________________" AT 66  SKIP(2)
        "Responsavel pela Aprovacao:____________________________" AT 30
        WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_comite. 
   
   FORM "Risco da Proposta:"                                       AT 01
        SKIP(1)
        tt-ratings.dsdopera LABEL "Operacao"    FORMAT "x(12)"     AT 01
        tt-ratings.nrctrrat LABEL "Contrato"    FORMAT "zz,zzz,zz9" AT 26
        tt-ratings.indrisco LABEL "Risco"       FORMAT "x(2)"      AT 49
        tt-ratings.nrnotrat LABEL "Nota"        FORMAT "zz9.99"    AT 61
        tt-ratings.dsdrisco NO-LABEL            FORMAT "x(20)"     AT 76
        WITH SIDE-LABEL WIDTH 120 FRAME f_rating_atual.
   
   FORM "Historico dos Ratings" AT 01
        WITH FRAME f_historico_rating_1.   
                                                                             
   FORM tt-ratings.dsdopera COLUMN-LABEL "Operacao"       FORMAT "x(18)" AT 01 
        tt-ratings.nrctrrat COLUMN-LABEL "Contrato"       FORMAT "zz,zzz,zz9"
        tt-ratings.indrisco COLUMN-LABEL "Risco"          FORMAT "x(2)"     
        tt-ratings.nrnotrat COLUMN-LABEL "Nota"           FORMAT "zz9.99"   
        tt-ratings.vloperac COLUMN-LABEL "Valor Operacao" FORMAT "zzz,zzz,zz9.99"
        tt-ratings.dsditrat COLUMN-LABEL "Situacao"       FORMAT "x(15)"
        WITH DOWN WIDTH 120 FRAME f_historico_rating_2.
   
   FORM "Grupo Economico:" AT 01
        SKIP(1)
        WITH FRAME f_grupo_1.
        
   FORM tt-grupo.cdagenci COLUMN-LABEL "PA "
        tt-grupo.nrctasoc COLUMN-LABEL "Conta"
        tt-grupo.vlendivi COLUMN-LABEL "Endividamento" FORMAT "zzz,zzz,zz9.99"
        tt-grupo.dsdrisco COLUMN-LABEL "Risco"
        WITH DOWN WIDTH 120 NO-BOX FRAME f_grupo.

   FORM SKIP(1) 
        aux_dsdrisco LABEL "Risco do Grupo"
        SKIP
        aux_vlendivi LABEL "Endividamento do Grupo"
        WITH NO-LABEL SIDE-LABEL WIDTH 120 NO-BOX FRAME f_grupo_2.
   
   /* Rodape de cada folha */
   FORM HEADER   
        crawepr.nrdconta
        "-"
        crawepr.nrctremp   FORMAT "zz,zzz,zz9"
        "-"   
        PAGE-NUMBER(str_1) FORMAT "999"
        WITH WIDTH 120 COLUMN 90 PAGE-BOTTOM NO-BOX NO-LABELS FRAME f_rodape. 
   
   
   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
   
   IF   NOT AVAILABLE crapcop   THEN
        RETURN.
   
   RUN p_divinome.

   rel_nrdocnpj = "CNPJ " + STRING(STRING(crapcop.nrdocnpj,"99999999999999"),
                                   "xx.xxx.xxx/xxxx-xx").
   
   FIND crapprp WHERE crapprp.cdcooper = crawepr.cdcooper   AND
                      crapprp.nrdconta = crawepr.nrdconta   AND
                      crapprp.nrctrato = crawepr.nrctremp   AND
                      crapprp.tpctrato = 90
                      NO-LOCK NO-ERROR.
   
   IF   NOT AVAIL crapprp THEN
        RETURN.
   
   ASSIGN rel_percentu      = 0
          rel_dsdrisco      = crawepr.dsnivris
          rel_percentu_calc = 0    
          rel_dsdrisco_calc = " ".

   IF NOT VALID-HANDLE(h-b1wgen9999) THEN
   RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
   
   /* Risco Obtido na Central de Risco */
   RUN obtem_risco IN h-b1wgen9999 (INPUT par_cdcooper,
                                    INPUT par_nrdconta,
                                    INPUT par_dtmvtolt,
                                    OUTPUT aux_nivrisco,
                                    OUTPUT aux_dtrefere). 
   
   IF VALID-HANDLE(h-b1wgen9999) THEN
      DELETE OBJECT h-b1wgen9999.

   ASSIGN rel_dsdrisco_calc = aux_nivrisco.
   IF  crawepr.dsnivris  <> " " THEN 
       DO:
          FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND 
                                 craptab.nmsistem = "CRED"       AND 
                                 craptab.tptabela = "GENERI"     AND 
                                 craptab.cdempres = 00           AND
                                 craptab.cdacesso = "PROVISAOCL" NO-LOCK:
              IF  TRIM(SUBSTR(craptab.dstextab,8,3)) = crawepr.dsnivris   THEN
                  DO:
                     ASSIGN rel_percentu = DEC(SUBSTR(craptab.dstextab,1,6)).
                     LEAVE.
                  END.
          END.
       END.

   IF  aux_nivrisco    <> " " THEN 
       DO:
          FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND 
                                 craptab.nmsistem = "CRED"       AND 
                                 craptab.tptabela = "GENERI"     AND 
                                 craptab.cdempres = 00           AND
                                 craptab.cdacesso = "PROVISAOCL" NO-LOCK:
              IF  TRIM(SUBSTR(craptab.dstextab,8,3)) = aux_nivrisco     THEN
                  DO:
                     ASSIGN rel_percentu_calc = 
                                           DEC(SUBSTR(craptab.dstextab,1,6)).
                     LEAVE.
                  END.
          END.
       END.
   
    FIND crapass WHERE  crapass.cdcooper = par_cdcooper AND 
                        crapass.nrdconta = crawepr.nrdconta 
                        NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapass   THEN
        RETURN.
       
   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) APPEND PAGED PAGE-SIZE 80.

   IF  par_idimpres = 1 THEN
       DO:
           RUN nova-impressao-contratos (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdcaixa,
                                         INPUT par_nmdatela,
                                         INPUT par_dtmvtolt,
                                         INPUT "",
                                         INPUT par_idorigem,
                                         INPUT par_recidepr,
                                         INPUT par_idimpres,
                                         INPUT FALSE,
                                        OUTPUT aux_nmarqimp,
                                        OUTPUT aux_nmarqpdf,
                                        OUTPUT TABLE tt-erro).

           IF  RETURN-VALUE <> "OK" THEN
               RETURN "NOK".
       END.

   IF crawepr.tpemprst = 1 THEN
      ASSIGN aux_tpempres = "Price Pre-Fixado".
   ELSE
      ASSIGN aux_tpempres = "Price TR".

   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
   IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

   ASSIGN aux_nrctrrat = crawepr.nrctremp.

   /*  Emissao da Proposta de Emprestimo .................................. */
   IF   aux_flgimppr   THEN
        DO:

            PAGE STREAM str_1.
     
            PUT STREAM str_1 CONTROL "\0330\033x0\022\033\115" NULL.
   
            FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND 
                               craplcr.cdlcremp = crawepr.cdlcremp
                               NO-LOCK NO-ERROR.
           
            ASSIGN rel_nmextcop = crapcop.nmextcop + " - " + crapcop.nmrescop.
            
            IF  crapass.inpessoa = 1 THEN 
                rel_inpessoa = "FISICA".
            ELSE
                rel_inpessoa = "JURIDICA".
            
            IF NOT VALID-HANDLE(h-b1wgen0043) THEN
            RUN sistema/generico/procedures/b1wgen0043.p 
                                 PERSISTENT SET h-b1wgen0043.
   
            RUN qualificacao-operacao IN h-b1wgen0043 
                                       (INPUT par_cdcooper,
                                        INPUT crawepr.idquapro,
                                        OUTPUT aux_dsquapro).
   
            IF VALID-HANDLE(h-b1wgen0043) THEN
               DELETE OBJECT h-b1wgen0043.

            ASSIGN aux_dsoperac = craplcr.dsoperac
                   aux_cdlcremp = craplcr.cdlcremp
                   aux_dslcremp = craplcr.dslcremp
                   aux_idquapro = crawepr.idquapro.
                   
            DISPLAY STREAM str_1 rel_nmextcop 
                                 rel_inpessoa 
                                 aux_dsoperac
                                 aux_cdlcremp
                                 aux_dslcremp
                                 aux_idquapro
                                 aux_dsquapro
                                 aux_tpempres

                                 rel_nrdconta 
                                 aux_nrctrrat               
                                 aux_tpdocged               
                                 WITH FRAME f_cabecalho_uso_digitalizacao.

            VIEW STREAM str_1 FRAME f_rodape.
            
            /****************** 1- DADOS DO ASSOCIADO *********************/
      
            FIND crapage WHERE crapage.cdcooper = par_cdcooper AND 
                               crapage.cdagenci = crapass.cdagenci
                               NO-LOCK NO-ERROR. 
      
            IF   NOT AVAILABLE crapage   THEN
                 rel_dsagenci = STRING(crapass.cdagenci,"999") +
                                " - NAO CADASTRADO.".
            ELSE
                 rel_dsagenci = STRING(crapage.cdagenci,"999") + " - " +
                                crapage.nmresage.
            
            IF  crapass.inpessoa = 1 THEN 
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 1  NO-LOCK NO-ERROR.
      
                    IF   AVAILABLE crapttl   THEN
                         ASSIGN rel_nmempres = crapttl.nmextemp
                                rel_dtadmemp = crapttl.dtadmemp.
                    ELSE
                         ASSIGN rel_nmdsecao = ""
                                rel_nmempres = ""
                                rel_dtadmemp = ?.
                END.


            /*** Busca Profissao do Titular ***/ 
            IF NOT VALID-HANDLE(h-b1wgen0059) THEN
            RUN sistema/generico/procedures/b1wgen0059.p 
                     PERSISTENT SET h-b1wgen0059.
        
            EMPTY TEMP-TABLE tt-gncdocp NO-ERROR.

            IF  AVAIL crapttl THEN
                DO:
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
 
					  /* Efetuar a chamada da rotina Oracle */ 
						RUN STORED-PROCEDURE pc_busca_gncdocp_car
							aux_handproc = PROC-HANDLE NO-ERROR(INPUT crapttl.cdocpttl, /*codigo da ocupaca*/                          
																INPUT "", /*descricao da ocupacao*/                                                                                            
																INPUT 1, /*nrregist*/
																INPUT 1, /*nriniseq*/
																OUTPUT "", /*Nome do Campo*/                
																OUTPUT "", /*Saida OK/NOK*/                          
																OUTPUT ?, /*Tabela Regionais*/                       
																OUTPUT 0, /*Codigo da critica*/                      
																OUTPUT ""). /*Descricao da critica*/ 
    
						/* Fechar o procedimento para buscarmos o resultado */ 
						CLOSE STORED-PROC pc_busca_gncdocp_car
								aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
         
						/* Efetuar a chamada da rotina Oracle */ 
						{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
						
						/* Busca possíveis erros */ 
						ASSIGN aux_cdcritic = 0
							   aux_dscritic = ""
							   aux_cdcritic = pc_busca_gncdocp_car.pr_cdcritic 
											  WHEN pc_busca_gncdocp_car.pr_cdcritic <> ?
							   aux_dscritic = pc_busca_gncdocp_car.pr_dscritic 
											  WHEN pc_busca_gncdocp_car.pr_dscritic <> ?.

						IF aux_cdcritic <> 0   OR
						   aux_dscritic <> ""  THEN
						DO:
							IF aux_dscritic = "" THEN
							   DO:
								  FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
													 NO-LOCK NO-ERROR.
    
								  IF AVAIL crapcri THEN
									 ASSIGN aux_dscritic = crapcri.dscritic.
    
							   END.
    
							CREATE tt-erro.
    
							ASSIGN tt-erro.cdcritic = aux_cdcritic
								   tt-erro.dscritic = aux_dscritic.
    
						   RETURN "NOK".

						END.

						/*Leitura do XML de retorno da proc e criacao dos registros na tt-gncdnto
							para visualizacao dos registros na tela */
            
						/* Buscar o XML na tabela de retorno da procedure Progress */ 
						ASSIGN xml_req = pc_busca_gncdocp_car.pr_clob_ret.
    
						/* Efetuar a leitura do XML*/ 
						SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
						PUT-STRING(ponteiro_xml,1) = xml_req. 
    
						/* Inicializando objetos para leitura do XML */ 
						CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
						CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
						CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
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
									DO:
                
										CREATE tt-gncdocp.
    
									END.
     
									DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
               
									xRoot2:GET-CHILD(xField,aux_cont).
                  
									IF xField:SUBTYPE <> "ELEMENT" THEN 
										NEXT. 
              
									xField:GET-CHILD(xText,1).
                  
									ASSIGN tt-gncdocp.cdocupa = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdocupa"
										   tt-gncdocp.dsdocupa = xText:NODE-VALUE WHEN xField:NAME = "dsdocupa"
											tt-gncdocp.rsdocupa = xText:NODE-VALUE WHEN xField:NAME = "rsdocupa".							   
                
									END. 
            
								END.
     
								SET-SIZE(ponteiro_xml) = 0. 
    
							END.
                    
						DELETE OBJECT xDoc. 
						DELETE OBJECT xRoot. 
						DELETE OBJECT xRoot2. 
						DELETE OBJECT xField. 
						DELETE OBJECT xText.
            
                    FIND tt-gncdocp WHERE tt-gncdocp.cdocupa = crapttl.cdocpttl
                          NO-LOCK NO-ERROR.

                    IF  AVAIL tt-gncdocp THEN
                        ASSIGN rel_dsfrmttl = tt-gncdocp.rsdocupa.
                END.

            IF VALID-HANDLE(h-b1wgen0059) THEN
               DELETE OBJECT h-b1wgen0059.

            ASSIGN rel_dtadmemp = crapass.dtadmemp
                   rel_dtadmiss = crapass.dtadmiss
                   rel_vlsalari = crapprp.vlsalari
                   rel_vlsalcon = crapprp.vlsalcon
                   aux_par_nrdconta = crapass.nrdconta
                   aux_par_dsctrliq = " " 
                   aux_par_vlutiliz = 0.
          
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
            RUN STORED-PROCEDURE pc_descricao_situacao_conta
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.cdsitdct, /* pr_cdsituacao */
                                                OUTPUT "",               /* pr_dssituacao */
                                                OUTPUT "",               /* pr_des_erro   */
                                                OUTPUT "").              /* pr_dscritic   */
            
            CLOSE STORED-PROC pc_descricao_situacao_conta
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
            ASSIGN aux_dssitcta = ""
                   aux_des_erro = ""
                   aux_dscritic = ""
                   aux_dssitcta = pc_descricao_situacao_conta.pr_dssituacao 
                                  WHEN pc_descricao_situacao_conta.pr_dssituacao <> ?
                   aux_des_erro = pc_descricao_situacao_conta.pr_des_erro 
                                  WHEN pc_descricao_situacao_conta.pr_des_erro <> ?
                   aux_dscritic = pc_descricao_situacao_conta.pr_dscritic
                                  WHEN pc_descricao_situacao_conta.pr_dscritic <> ?.
          
            IF aux_des_erro = "NOK" THEN 
                aux_dssitcta = "".

            ASSIGN rel_dssitdct = STRING(crapass.cdsitdct) +  "-" + UPPER(aux_dssitcta).

           IF NOT VALID-HANDLE(h-b1wgen9999) THEN
           RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
               SET h-b1wgen9999.
               
           IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
               DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Handle invalido para BO " +
                                         "b1wgen9999.".
                                      
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,            /** Sequencia **/
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
                         
                   RETURN "NOK".

               END.       
     
           RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT aux_par_nrdconta,
                                              INPUT par_idseqttl,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT aux_par_dsctrliq,
                                              INPUT par_inproces,
                                              INPUT FALSE, /*Consulta por cpf*/
                                             OUTPUT aux_par_vlutiliz,
                                             OUTPUT TABLE tt-erro).

            IF VALID-HANDLE(h-b1wgen9999) THEN
               DELETE OBJECT h-b1wgen9999.

            IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".


            /* Tratamento de CPF/CGC */
            IF crapass.inpessoa = 1 THEN
               ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                      aux_nrcpfcgc = STRING(aux_nrcpfcgc,"    xxx.xxx.xxx-xx").
            ELSE
               ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                      aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
                                    
           
            /** Pessoa Juridica **/
            IF  crapass.inpessoa = 2 THEN 
                DO:
                    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper     AND
                                       crapjur.nrdconta = crapass.nrdconta
                                       NO-LOCK NO-ERROR.

                    IF  AVAIL crapjur THEN
                        DO: 
                           ASSIGN rel_dtiniatv = crapjur.dtiniatv.

                           /*** Ramo de Atividade ***/
                            IF NOT VALID-HANDLE(h-b1wgen0059) THEN
                            RUN sistema/generico/procedures/b1wgen0059.p 
                                     PERSISTENT SET h-b1wgen0059.
                        
                            EMPTY TEMP-TABLE tt-gnrativ NO-ERROR.

                            RUN busca-gnrativ IN h-b1wgen0059 
                                             (INPUT crapjur.cdseteco,
                                              INPUT crapjur.cdrmativ,
                                              INPUT '',
                                              INPUT 1,
                                              INPUT 1,
                                             OUTPUT aux_qtregist,
                                             OUTPUT TABLE tt-gnrativ).

                            IF VALID-HANDLE(h-b1wgen0059) THEN
                               DELETE OBJECT h-b1wgen0059.

                           
                            FIND FIRST tt-gnrativ WHERE 
                                       tt-gnrativ.cdrmativ = crapjur.cdrmativ
                                       NO-LOCK NO-ERROR.
                                       
                            IF  AVAIL tt-gnrativ THEN
                                ASSIGN rel_nmrmativ = tt-gnrativ.nmrmativ.

                        END.

                    /*** Conc. Fatur. unico cliente ***/
                    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper    AND
                                       crapjfn.nrdconta = crapass.nrdconta
                                       NO-LOCK NO-ERROR.
                                       
                    IF AVAIL crapjfn THEN      
                       ASSIGN rel_perfatcl = crapjfn.perfatcl.
                END.


            DISPLAY STREAM str_1
                    rel_dsagenci
                    rel_nrdconta     
                    rel_nmprimtl[1]
                    WITH FRAME f_pro_dados.
                    
            /** Pessoa Fisica **/        
            IF  crapass.inpessoa = 1 THEN 
                DO:
                   DISPLAY  STREAM str_1
                            aux_nrcpfcgc
                            rel_dtadmiss
                            rel_nmempres
                            crapttl.dsproftl /** Funcao **/            
                            rel_dsfrmttl     /** Profissao **/ 
                            rel_vlsalari 
                            rel_dtadmemp
                            rel_vlsalcon
                            crapprp.nmempcje /** Empresa do Conjuge **/
                            crapprp.vloutras
                            crapprp.vlalugue
                            WITH FRAME f_pro_dados_fisica.
         

                   ASSIGN rel_vldrendi = 0.
                   
                   /* Outras Rendas */
                   FOR EACH craprpr WHERE 
                                    craprpr.cdcooper = par_cdcooper     AND
                                    craprpr.nrdconta = crawepr.nrdconta AND
                                    craprpr.tpctrato = 90               AND
                                    craprpr.nrctrato = crawepr.nrctremp
                                    NO-LOCK:
                   
                       FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                                          craptab.nmsistem = "CRED"       AND
                                          craptab.tptabela = "GENERI"     AND
                                          craptab.cdempres = 0            AND
                                          craptab.cdacesso = "DSRENDIMEN" AND
                                          craptab.tpregist = craprpr.tpdrendi
                                          NO-LOCK NO-ERROR.
                   
                       IF   AVAIL craptab THEN
                            ASSIGN rel_dsdrendi = craptab.dstextab.
                       ELSE
                            ASSIGN rel_dsdrendi = "NAO ENCONTRADO".
                   
                       ASSIGN rel_vldrendi = rel_vldrendi + craprpr.vldrendi
                   
                              lbl_vldrendi = "Outras Rendas:" +
                                 STRING(craprpr.vldrendi,"z,zzz,zz9.99")
                       
                              lbl_dsdrendi = "Origem: " + STRING(rel_dsdrendi).
                   
                       DISPLAY STREAM str_1 lbl_vldrendi
                                            lbl_dsdrendi
                                            WITH FRAME f_rendas_fisica.

                       DOWN WITH FRAME f_rendas_fisica.
 
                   END.

                END.
            ELSE
               DISPLAY STREAM str_1 
                       aux_nrcpfcgc 
                       rel_dtadmiss
                       rel_nmrmativ     
                       rel_dtiniatv
                       crapprp.vlmedfat
                       rel_perfatcl   
                       crapprp.vlalugue
                       WITH FRAME f_pro_dados_juridica.

            /* Bens associados a esta proposta */                              
            FOR EACH crapbpr WHERE crapbpr.cdcooper = par_cdcooper     AND
                                   crapbpr.nrdconta = crawepr.nrdconta AND
                                   crapbpr.tpctrpro = 90               AND
                                   crapbpr.nrctrpro = crawepr.nrctremp AND 
                                   crapbpr.flgalien = FALSE            NO-LOCK:
      
                DISPLAY STREAM str_1 crapbpr.dsrelbem
                                     crapbpr.persemon
                                     crapbpr.qtprebem
                                     crapbpr.vlprebem
                                     crapbpr.vlrdobem WITH DOWN FRAME f_bens.
      
                DOWN WITH FRAME f_bens. 
      
            END.

            /***************** 2- HISTORICO DO ASSOCIADO *******************/
          
            ASSIGN  rel_vlsmdtri = par_vlsmdtri
                    rel_vlcaptal = par_vlcaptal
                    rel_vlprepla = par_vlprepla
                    pro_vlaplica = par_vltotapl + par_vltotrpp.
            
            VIEW STREAM str_1 FRAME f_historico.  
        
            DISPLAY STREAM str_1
                    rel_vlsmdtri    rel_vlcaptal   
                    rel_vlprepla    pro_vlaplica 
                    WITH FRAME f_historico_2. 

            /*******************  2.1 ROTATIVOS ATIVOS  *********************/
         
            VIEW STREAM str_1 FRAME f_cab_rotativos.
         
            DISPLAY STREAM str_1 WITH FRAME f_cab_rotativos_2.
         
            ASSIGN aux_vldscchq = 0.           
                      
            /********* Cheque Especial *********/
            FIND FIRST craplim WHERE 
                               craplim.cdcooper = par_cdcooper     AND
                               craplim.nrdconta = crapass.nrdconta AND
                               craplim.tpctrlim = 1                AND
                               craplim.insitlim = 2 
                               USE-INDEX craplim1 NO-LOCK NO-ERROR.
            
            IF   AVAILABLE craplim   THEN
                 DO:         
                      IF  par_vlstotal < 0 THEN
                          ASSIGN aux_sld_cheque = par_vlstotal * -1.

                      /*** Avalistas / C.C. Garantidor ***/
                      RUN  lista-avalistas (INPUT 3,
                                            INPUT craplim.nrctrlim,
                                            INPUT craplim.nrctaav1,
                                            INPUT craplim.nrctaav2,
                                            INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,   
                                            INPUT par_idorigem,   
                                            INPUT par_idseqttl,   
                                            INPUT par_nmdatela,
                                            INPUT crapass.nrdconta,
                                           OUTPUT aux_ccg_chequ1,
                                           OUTPUT aux_ccg_chequ2,
                                           OUTPUT TABLE tt-erro).

                      IF RETURN-VALUE <> "OK" THEN
                          RETURN "NOK".
                            
                      ASSIGN rel_vllimcre    =  craplim.vllimite
                             aux_dtc_cheque  =  craplim.dtinivig.
                 END.
            
            IF  crapass.inpessoa = 1 THEN
                rel_modalida = "Cheque Especial".
            ELSE
                rel_modalida = "Limite Empresarial".
            
            ASSIGN  rel_dslimite = rel_vllimcre 
                    rel_sldutili = aux_sld_cheque
                    rel_garantid = aux_ccg_chequ1
                    rel_dtcontra = aux_dtc_cheque.  

            DISPLAY STREAM str_1 
                           rel_modalida 
                           rel_dslimite     
                           rel_sldutili     
                           rel_garantid 
                           rel_dtcontra WITH FRAME f_rotativos.          
            
            DOWN STREAM str_1 WITH FRAME f_rotativos.
            
            IF  aux_ccg_chequ2 <> "" THEN
                DO: 
                   ASSIGN rel_garantid = aux_ccg_chequ2.
                   
                   DISPLAY STREAM str_1
                           "" @  rel_modalida  
                           "" @  rel_dslimite
                           "" @  rel_sldutili  
                           rel_garantid
                           "" @  rel_dtcontra 
                           WITH FRAME f_rotativos.
                                                            
                   DOWN STREAM str_1 WITH FRAME f_rotativos.  
                END.
         
            /**********  Desconto de Cheques  **********/

            FIND FIRST craplim WHERE 
                               craplim.cdcooper = par_cdcooper     AND
                               craplim.nrdconta = crapass.nrdconta AND
                               craplim.tpctrlim = 2                AND
                               craplim.insitlim = 2 
                               NO-LOCK NO-ERROR.

            IF  AVAIL craplim THEN
                DO:               
                    /*** Avalistas / C.C. Garantidor ***/
                    RUN lista-avalistas(INPUT 2,
                                        INPUT craplim.nrctrlim,
                                        INPUT craplim.nrctaav1,
                                        INPUT craplim.nrctaav2,
                                        INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,   
                                        INPUT par_idorigem,   
                                        INPUT par_idseqttl,   
                                        INPUT par_nmdatela,
                                        INPUT crapass.nrdconta,
                                       OUTPUT aux_ccg_dscch1,
                                       OUTPUT aux_ccg_dscch2,
                                       OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".
                       
                       
                    ASSIGN  aux_vldscchq   = craplim.vllimite 
                            aux_dtc_dscchq = craplim.dtinivig.
                END.

            FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper        AND
                                   crapcdb.nrdconta = crapass.nrdconta    AND
                                   crapcdb.insitchq = 2                   AND
                                   crapcdb.dtlibera > par_dtmvtolt   NO-LOCK:
        
                ASSIGN aux_sld_dscchq = aux_sld_dscchq + crapcdb.vlcheque.
 
            END.
            
            ASSIGN  rel_modalida = "Descto. Cheques"
                    rel_dslimite = aux_vldscchq  
                    rel_sldutili = aux_sld_dscchq 
                    rel_garantid = aux_ccg_dscch1
                    rel_dtcontra = aux_dtc_dscchq.
                    
            DISPLAY STREAM str_1 
                           rel_modalida 
                           rel_dslimite 
                           rel_sldutili 
                           rel_garantid  
                           rel_dtcontra WITH FRAME f_rotativos.          
            
            DOWN STREAM str_1 WITH FRAME f_rotativos.
            
            IF  aux_ccg_dscch2 <> "" THEN
                DO:
                   ASSIGN rel_garantid = aux_ccg_dscch2.
                   
                   DISPLAY STREAM str_1
                           "" @  rel_modalida  
                           "" @  rel_dslimite
                           "" @  rel_sldutili  
                           rel_garantid
                           "" @  rel_dtcontra 
                           WITH FRAME f_rotativos.
                   
                   DOWN STREAM str_1 WITH FRAME f_rotativos.
                END.

            /************* Desconto de Titulos ************/
            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper       AND
                                     craplim.nrdconta = crapass.nrdconta   AND
                                     craplim.tpctrlim = 3                  AND
                                     craplim.insitlim = 2  NO-LOCK NO-ERROR.
            IF  AVAIL craplim THEN
                DO:
                   /*** Avalistas C.C. Garantidor ***/
                   
                   RUN lista-avalistas(INPUT 8,
                                       INPUT craplim.nrctrlim,
                                       INPUT craplim.nrctaav1,
                                       INPUT craplim.nrctaav2,
                                       INPUT par_cdcooper,
                                       INPUT par_cdoperad,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,   
                                       INPUT par_idorigem,   
                                       INPUT par_idseqttl,   
                                       INPUT par_nmdatela,
                                       INPUT crapass.nrdconta,
                                      OUTPUT aux_ccg_dscti1,
                                      OUTPUT aux_ccg_dscti2,
                                      OUTPUT TABLE tt-erro).

                   IF  RETURN-VALUE <> "OK" THEN
                       RETURN "NOK".
                     
                   ASSIGN aux_vldctitu    = craplim.vllimite
                          aux_dtc_dsctit =  craplim.dtinivig.
                END.
            
            FOR EACH craptdb WHERE (craptdb.cdcooper = par_cdcooper      AND
                                    craptdb.nrdconta = crapass.nrdconta  AND
                                    craptdb.insittit = 4)          
                                    OR
                                   (craptdb.cdcooper = par_cdcooper      AND
                                    craptdb.nrdconta = crapass.nrdconta  AND
                                    craptdb.insittit = 2                 AND
                                    craptdb.dtdpagto = par_dtmvtolt)
                                    NO-LOCK:
                
                   ASSIGN aux_sld_dsctit = aux_sld_dsctit + craptdb.vltitulo.
            END.
            
            ASSIGN  rel_modalida = "Descto. Titulos"
                    rel_dslimite = aux_vldctitu  
                    rel_sldutili = aux_sld_dsctit
                    rel_garantid = aux_ccg_dscti1
                    rel_dtcontra = aux_dtc_dsctit.
                    
            DISPLAY STREAM str_1 
                           rel_modalida 
                           rel_dslimite 
                           rel_sldutili 
                           rel_garantid 
                           rel_dtcontra WITH FRAME f_rotativos.          
            
            DOWN STREAM str_1 WITH FRAME f_rotativos.
            
            IF  aux_ccg_dscti2 <> "" THEN
                DO:
                   ASSIGN rel_garantid = aux_ccg_dscti2.
                   
                   DISPLAY STREAM str_1
                           "" @  rel_modalida  
                           "" @  rel_dslimite
                           "" @  rel_sldutili  
                           rel_garantid
                           "" @  rel_dtcontra 
                           WITH FRAME f_rotativos.
                   
                   DOWN STREAM str_1 WITH FRAME f_rotativos.
                END.
         
            /************** Cartao de Credito ***************/

            ASSIGN aux_ccg_crtcr1 = " "
                   aux_ccg_crtcr2 = " ".
                   
            FOR EACH crawcrd NO-LOCK WHERE 
                                     crawcrd.cdcooper = par_cdcooper       AND
                                     crawcrd.nrdconta = crapass.nrdconta   AND 
                                     crawcrd.insitcrd = 4 
                                     BREAK BY crawcrd.nrdconta:
                                              
                FIND  craptlc NO-LOCK WHERE
                                      craptlc.cdcooper = par_cdcooper     AND
                                      craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                                      craptlc.tpcartao = crawcrd.tpcartao AND
                                      craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                                      craptlc.dddebito = 0 
                                      USE-INDEX craptlc1 NO-ERROR.
                
                IF  AVAIL craptlc   AND 
                    craptlc.vllimcrd > 0 THEN
                    ASSIGN par_vltotccr = craptlc.vllimcrd.    
                
                /************* CC Garantidor **************/           
                RUN lista-avalistas(INPUT 4,
                                    INPUT crawcrd.nrctrcrd,
                                    INPUT crawcrd.nrctaav1,
                                    INPUT crawcrd.nrctaav2,
                                    INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,   
                                    INPUT par_idorigem,   
                                    INPUT par_idseqttl,   
                                    INPUT par_nmdatela,
                                    INPUT crapass.nrdconta,
                                   OUTPUT aux_ccg_crtcr1,
                                   OUTPUT aux_ccg_crtcr2,
                                   OUTPUT TABLE tt-erro).

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
                     
                ASSIGN aux_dtc_crtcre = crawcrd.dtentreg. 
                
                IF  aux_existcrd = FALSE THEN 
                    ASSIGN rel_modalida = "Cartao Credito".
                ELSE
                    ASSIGN rel_modalida = "".
                
                ASSIGN  rel_dslimite = par_vltotccr  
                        rel_garantid = aux_ccg_crtcr1
                        rel_dtcontra = aux_dtc_crtcre.
                    
                DISPLAY STREAM str_1 
                           rel_modalida rel_dslimite 
                           "" @ rel_sldutili 
                           rel_garantid 
                           rel_dtcontra WITH FRAME f_rotativos.          
                   
                DOWN STREAM str_1 WITH FRAME f_rotativos.
                   
                IF  aux_ccg_crtcr2 <> "" THEN
                    DO:
                       ASSIGN rel_garantid = aux_ccg_crtcr2.
                   
                       DISPLAY STREAM str_1
                               "" @  rel_modalida  
                               "" @  rel_dslimite
                               "" @  rel_sldutili  
                               rel_garantid
                               "" @  rel_dtcontra 
                               WITH FRAME f_rotativos.
                   
                       DOWN STREAM str_1 WITH FRAME f_rotativos.
                    END.
                
                ASSIGN aux_existcrd = TRUE.
                
            END.    /** Fim for each crawcrd **/                         
            
             /*** Somente para mostrar o Label "Cartao Credito" ***/
            IF  aux_existcrd = FALSE THEN 
                DO:
                   ASSIGN rel_modalida = "Cartao Credito"
                          rel_dslimite = 0.
                
                   DISPLAY STREAM str_1 
                           rel_modalida 
                           rel_dslimite 
                           "" @ rel_sldutili 
                           "" @ rel_garantid 
                           "" @ rel_dtcontra 
                           WITH FRAME f_rotativos.          
            
                   DOWN STREAM str_1 WITH FRAME f_rotativos.
                END.
             
            /******** 2.2- DEMAIS OPERACOES DE CREDITO ATIVAS *********/
                         
            FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "USUARI"        AND
                               craptab.cdempres = 11              AND
                               craptab.cdacesso = "PROPOSTEPR"    AND
                               craptab.tpregist = 0
                               NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL craptab THEN
                DO:
                    ASSIGN  aux_cdcritic = 55
                            aux_dscritic = "".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1, 
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                     RETURN "NOK".
                END.

            IF  crapass.inpessoa = 1 THEN  
                DO:                        
                    IF  AVAIL  craptab THEN
                        ASSIGN aux_qtdpremp =
                                   INTEGER(SUBSTRING(craptab.dstextab,40,03)).
                END.
            ELSE      /** Juridica **/
                DO:
                    IF  AVAIL  craptab THEN
                        ASSIGN aux_qtdpremp =
                                   INTEGER(SUBSTRING(craptab.dstextab,48,03)).
                END.

            IF   par_vltotemp > 0   THEN
                 DO: 
                     aux_contador = 1.                     
            
                     DISPLAY STREAM str_1 aux_qtdpremp   
                                    WITH FRAME f_pro_ed1.
            
                     /* busca informacoes de emprestimo e prestacoes (para nao 
                     utilizar mais a include "gera workepr.i") (Gabriel/DB1) */
                     IF NOT VALID-HANDLE(h-b1wgen0002) THEN
                     RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT
                         SET h-b1wgen0002.
            
                     IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
                         DO:
                             ASSIGN aux_dscritic = "Handle invalido para BO " +
                                                   "b1wgen0002.".
                             LEAVE.
                         END.
            
                     RUN obtem-dados-emprestimos IN h-b1wgen0002
                                         ( INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT par_dtcalcul,
                                           INPUT 0, /* Contrato par_nrctremp */
                                           INPUT par_cdprogra,
                                           INPUT par_inproces,
                                           INPUT par_flgerlog,
                                           INPUT TRUE,
                                           INPUT 0, /** nriniseq **/
                                           INPUT 0, /** nrregist **/
                                          OUTPUT aux_qtregist,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-dados-epr ).
              
                     IF VALID-HANDLE(h-b1wgen0002) THEN
                        DELETE OBJECT h-b1wgen0002.
              
                     IF  RETURN-VALUE <> "OK"  THEN
                         RETURN "NOK".

                     FOR EACH tt-dados-epr WHERE 
                              tt-dados-epr.vlsdeved > 0  NO-LOCK,
                         
                         FIRST crablcr WHERE 
                               crablcr.cdcooper = par_cdcooper AND
                               crablcr.cdlcremp = tt-dados-epr.cdlcremp NO-LOCK:
            
                         IF  aux_contador > aux_qtdpremp THEN
                             NEXT.
              
                         /* Se nao lista na proposta */
                         IF   NOT crablcr.flglispr THEN
                              NEXT.
              
                         /*********** Garantia ***************/
                         
                         ASSIGN flg_temavali = FALSE.
                             
                         FIND craxepr WHERE 
                              craxepr.cdcooper = par_cdcooper           AND
                              craxepr.nrdconta = tt-dados-epr.nrdconta  AND
                              craxepr.nrctremp = INT(tt-dados-epr.nrctremp)
                              NO-LOCK NO-ERROR.
                             
                         IF   CAN-FIND (FIRST crapbpr WHERE
                                crapbpr.cdcooper = craxepr.cdcooper AND
                                crapbpr.nrdconta = craxepr.nrdconta AND
                                crapbpr.tpctrpro = 90 /* Emprest.*/ AND
                                crapbpr.nrctrpro = craxepr.nrctremp AND
                                crapbpr.flgalien = TRUE) THEN
                                DO:
                                    CREATE cratepr.
                                    ASSIGN cratepr.nrctremp = craxepr.nrctremp
                                           cratepr.dsgarant = "Bem"
                                           flg_temavali     = TRUE.
                                END.
                      
                         RUN  lista-avalistas (INPUT  1,   /* Emprestimo */
                                               INPUT  craxepr.nrctremp,
                                               INPUT  craxepr.nrctaav1,
                                               INPUT  craxepr.nrctaav2,
                                               INPUT  par_cdcooper,
                                               INPUT  par_cdoperad,
                                               INPUT  par_cdagenci,
                                               INPUT  par_nrdcaixa,   
                                               INPUT  par_idorigem,   
                                               INPUT  par_idseqttl,   
                                               INPUT  par_nmdatela,
                                               INPUT tt-dados-epr.nrdconta,
                                               OUTPUT aux_garantia1,
                                               OUTPUT aux_garantia2,
                                               OUTPUT TABLE tt-erro).

                         IF  RETURN-VALUE <> "OK" THEN
                             RETURN "NOK".
                             
                         IF  aux_garantia1 <> "" THEN
                             DO:
                                 CREATE cratepr.
                                 ASSIGN cratepr.nrctremp = tt-dados-epr.nrctremp
                                        cratepr.dsgarant = "Aval " +
                                                          
                                   SUBSTR(STRING(aux_garantia1),1,INDEX(aux_garantia1,"-") - 1)
                  
                                        flg_temavali     = TRUE.
                             END.
                         
                         IF  aux_garantia2 <> "" THEN
                             DO:
                                 CREATE  cratepr.
                                 ASSIGN  cratepr.nrctremp = tt-dados-epr.nrctremp
                                         cratepr.dsgarant = "Aval " +
                                      
                                   SUBSTR(STRING(aux_garantia2),1,INDEX(aux_garantia2,"-") - 1)
                                          
                                     flg_temavali    = TRUE.
                             END.

                         IF  flg_temavali = FALSE   THEN
                             DO:   
                                 CREATE cratepr.
                                 ASSIGN cratepr.nrctremp = craxepr.nrctremp.
                                        cratepr.dsgarant = "        -      ".
                             END.

                         /*** Atraso/Parcela ***/   
                         ASSIGN aux_qtmesdec = 
                                  tt-dados-epr.qtmesdec - tt-dados-epr.qtprecal
                                aux_qtpreemp = 
                                  tt-dados-epr.qtpreemp - tt-dados-epr.qtprecal.
      
                         IF  aux_qtmesdec > aux_qtpreemp  THEN         
                             aux_qtprecal = aux_qtpreemp.
                         ELSE
                             aux_qtprecal = aux_qtmesdec.
                         
                         IF  aux_qtprecal < 0 THEN 
                             ASSIGN aux_qtprecal = 0.
                         
                         ASSIGN tot_vlsdeved = tot_vlsdeved + 
                                               tt-dados-epr.vlsdeved
                                tot_vlpreemp = tot_vlpreemp + 
                                               tt-dados-epr.vlpreemp
                                tot_qtprecal = tot_qtprecal + aux_qtprecal
                                rel_dspreapg = 
                                            SUBSTR(tt-dados-epr.dspreapg,5,11).
                          
                         IF   CAN-DO(aux_dsliquid,
                              TRIM(STRING(tt-dados-epr.nrctremp,"zz,zzz,zz9"))) 
                              THEN

                              ASSIGN rel_dsliqant = "Sim"
                                     tot_vlliquid = tot_vlliquid + 
                                                    tt-dados-epr.vlsdeved.
                         ELSE
                              rel_dsliqant = "Nao".  

                         CREATE tt-operati.
                         ASSIGN tt-operati.nrctremp = tt-dados-epr.nrctremp
                                tt-operati.vlsdeved = tt-dados-epr.vlsdeved
                                tt-operati.dspreapg = rel_dspreapg
                                tt-operati.vlpreemp = tt-dados-epr.vlpreemp  
                                tt-operati.qtprecal = aux_qtprecal
                                tt-operati.dslcremp = tt-dados-epr.dslcremp
                                tt-operati.dsfinemp = tt-dados-epr.dsfinemp
                                tt-operati.dsliqant = rel_dsliqant.
                                               
                         ASSIGN aux_contador = aux_contador + 1.
                  
                         IF craxepr.tpemprst = 1 THEN
                             ASSIGN tt-operati.dsidenti = "*".
                         ELSE
                             ASSIGN tt-operati.dsidenti = "".
                  
                     END.  /* Fim do FOR EACH - Leitura das dividas ativas */
                   
                     /*** Lista primeiro as dividas que serao liquidadas ***/
                     FOR EACH  tt-operati  
                               BY tt-operati.dsliqant  DESC
                                  BY tt-operati.nrctremp:

                         DISPLAY  STREAM str_1
                                  tt-operati.dsidenti       
                                  tt-operati.nrctremp  
                                  tt-operati.vlsdeved  
                                  tt-operati.dspreapg
                                  tt-operati.vlpreemp 
                                                 WHEN tt-operati.vlpreemp > 0
                                  tt-operati.qtprecal
                                  tt-operati.dslcremp
                                  tt-operati.dsfinemp  
                                  tt-operati.garantia  
                                  tt-operati.dsliqant           
                                  WITH FRAME f_dividas.
                                           
                         FOR EACH cratepr WHERE 
                                  cratepr.nrctremp = tt-operati.nrctremp
                                  BREAK BY cratepr.nrctremp:
                                               
                             IF  FIRST-OF(cratepr.nrctremp) THEN
                                 DO:  
                                      tt-operati.garantia =
                                                 cratepr.dsgarant.
                                      DISPLAY STREAM str_1
                                              tt-operati.garantia 
                                              WITH FRAME f_dividas.
                                      NEXT.
                                 END.       
                             DISPLAY STREAM str_1
                                            cratepr.dsgarant     
                                            WITH FRAME f_dividas_garantia.
                                          
                             DOWN STREAM str_1 WITH FRAME f_dividas_garantia.
                         END. /** Fim For each **/ 
                         DOWN STREAM str_1 WITH FRAME f_dividas.
                            
                     END.
                     
                     DISPLAY STREAM str_1
                             tot_vlsdeved  
                             tot_vlpreemp 
                             tot_qtprecal WITH FRAME f_tot_div.
                 END.
            ELSE 
                 DO:
                      DISPLAY STREAM str_1 aux_qtdpremp WITH FRAME f_pro_ed1.
                      DISPLAY STREAM str_1 WITH FRAME f_tot_div.
                 END.
         
            /**************** Co-Responsabilidade ********************/

            IF  crapass.inpessoa = 1 THEN /** Fisica **/
                DO:
                    DISPLAY STREAM str_1  WITH FRAME f_pro_ed2.

                    ASSIGN tot_vlsdeved = 0 
                           tot_vlpreemp = 0
                           tot_qtprecal = 0.

                    RUN gera_co_responsavel(INPUT par_cdcooper,
                                            INPUT par_idorigem,
                                            INPUT par_dtcalcul,
                                            INPUT aux_vldscchq,
                                            INPUT aux_vlutlchq,
                                            INPUT par_dtmvtolt,
                                            INPUT aux_vldctitu,
                                            INPUT aux_vlutitit,
                                            INPUT par_dtmvtopr,
                                            INPUT par_cdprogra,
                                            INPUT par_inproces,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT par_nmdatela,
                                            INPUT par_flgerlog,
                                            INPUT par_cdoperad,
                                            INPUT par_idseqttl,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE w-co-responsavel).

                    IF  RETURN-VALUE <> "OK"  THEN
                        RETURN "NOK".

                    ASSIGN tot_vlsdeved = 0 
                           tot_vlpreemp = 0
                           tot_qtprecal = 0.
                
                    FIND crawepr WHERE RECID(crawepr) = par_recidepr 
                                                        NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crawepr  THEN
                        RETURN.

                    FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND 
                                       crapass.nrdconta = crawepr.nrdconta 
                                                          NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE crapass  THEN
                        RETURN.
                    

                    FOR EACH w-co-responsavel,
                         
                         FIRST crablcr WHERE
                               crablcr.cdcooper = par_cdcooper AND
                               crablcr.cdlcremp = w-co-responsavel.cdlcremp 
                               NO-LOCK
                               BY w-co-responsavel.nrdconta
                                   BY w-co-responsavel.nrctremp:

                         /* Se nao lista na proposta */
                         IF   NOT crablcr.flglispr THEN
                              NEXT.

                         /* Se saldo devedor igual a 0 */
                         IF   w-co-responsavel.vlsdeved = 0   THEN
                              NEXT.
        
                         /*** Atraso/Parcela ***/
                         ASSIGN aux_qtmesdec = w-co-responsavel.qtmesdec -
                                               w-co-responsavel.qtprecal
                                aux_qtpreemp = w-co-responsavel.qtpreemp - 
                                               w-co-responsavel.qtprecal.
         
                         IF  aux_qtmesdec > aux_qtpreemp  THEN         
                             aux_qtprecal = aux_qtpreemp.
                         ELSE
                             aux_qtprecal = aux_qtmesdec.

                         
                         
                         IF  aux_qtprecal < 0 THEN 
                             ASSIGN aux_qtprecal = 0.

                         ASSIGN  tot_vlsdeved = tot_vlsdeved + 
                                                w-co-responsavel.vlsdeved
                                 tot_vlpreemp = tot_vlpreemp + 
                                                w-co-responsavel.vlpreemp
                                 tot_qtprecal = tot_qtprecal + aux_qtprecal
                                 rel_dspreapg = 
                                         SUBSTR(w-co-responsavel.dspreapg,5,11)
                                 rel_nrctares = "Aval de "+ 
                                         STRING(w-co-responsavel.nrdconta)
                                 rel_nrctares = rel_nrctares + "*" 
                                         WHEN w-co-responsavel.inprejuz = 1.
                         
                         /* Verificar se ja ultrapassou o limite de linhas
                            do relatorio e reiniciar pagina SD 296491*/
                         IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                         DO:
                             PAGE STREAM str_1.
                             DISPLAY STREAM str_1  WITH FRAME f_pro_ed2.
                         END.

                         DISPLAY  STREAM str_1
                                  w-co-responsavel.nrctremp  
                                  w-co-responsavel.vlsdeved  
                                  rel_dspreapg
                                  w-co-responsavel.vlpreemp  
                                             WHEN w-co-responsavel.vlpreemp > 0
                                  aux_qtprecal
                                  w-co-responsavel.dslcremp
                                  w-co-responsavel.dsfinemp  
                                  rel_nrctares  
                                  WITH FRAME f_co-responsavel.
                         DOWN STREAM str_1 WITH FRAME f_co-responsavel.
                    END.

                    DISPLAY STREAM str_1
                                   tot_vlsdeved  
                                   tot_vlpreemp 
                                   tot_qtprecal 
                                   WITH FRAME f_tot_co-responsavel.



            
                END. /** Fim do if inpessoa **/
                
            /********* 2.3 ULTIMAS OPERACOES DE CREDITO LIQUIDADAS **********/
      
            ASSIGN aux_contador = 1.
      
            FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                               craptab.nmsistem = "CRED"          AND
                               craptab.tptabela = "USUARI"        AND
                               craptab.cdempres = 11              AND
                               craptab.cdacesso = "PROPOSTEPR"    AND
                               craptab.tpregist = 0
                               NO-LOCK NO-ERROR.
                     
            IF  AVAIL craptab THEN
                IF  crapass.inpessoa = 1 THEN
                    aux_qtopeliq = INTEGER(SUBSTRING(craptab.dstextab,44,03)).
                ELSE   
                    aux_qtopeliq = INTEGER(SUBSTRING(craptab.dstextab,52,03)).
                
            DISPLAY STREAM str_1 aux_qtopeliq WITH FRAME f_cab_ultimas.

            FOR EACH crapepr WHERE  crapepr.cdcooper = par_cdcooper      AND  
                                    crapepr.nrdconta = crapass.nrdconta  AND
                                    crapepr.inliquid = 1 NO-LOCK 
                                       BY crapepr.dtultpag DESC:
          
                IF  aux_contador > aux_qtopeliq  THEN
                    NEXT.
                
                FIND  craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                                    craplcr.cdlcremp = crapepr.cdlcremp 
                                    NO-LOCK NO-ERROR.

                IF   AVAIL craplcr THEN  
                     DO:    
                         ASSIGN rel_dslcremp = STRING(crapepr.cdlcremp) + 
                                               " - " + craplcr.dslcremp.
                    
                         /* Se nao lista na proposta */
                         IF    NOT craplcr.flglispr   THEN
                               NEXT.
                     END.
                ELSE
                     rel_dslcremp = "".
                  
                ASSIGN aux_qtdiaatr = 0
                       rel_qtdiaatr = ""
                       rel_dsfinemp = ""
                       aux_contador = aux_contador + 1.
            
                FIND  crapfin WHERE crapfin.cdcooper = par_cdcooper AND
                                    crapfin.cdfinemp = crapepr.cdfinemp
                                    NO-LOCK NO-ERROR.
            
                IF  AVAIL crapfin THEN
                    rel_dsfinemp = STRING(crapepr.cdfinemp) + " - " +
                                   crapfin.dsfinemp.
                
                /*****  Liquidacao  *****/
                FOR EACH  craplem WHERE craplem.cdcooper = par_cdcooper     AND
                                        craplem.nrdconta = crapepr.nrdconta AND
                                        craplem.nrctremp = crapepr.nrctremp 
                                        NO-LOCK :
                    
                    FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                                       craphis.cdhistor = craplem.cdhistor AND
                                       craphis.indebcre = "C"
                                       NO-LOCK NO-ERROR.
                    
                    IF  AVAIL craphis THEN               
                        ASSIGN rel_dtliquid = craplem.dtmvtolt.     
                    
                END.

                /* Ultimo dia do mes passado */
                ASSIGN aux_dtultdma = par_dtmvtolt - DAY(par_dtmvtolt).

                /*** Pontualidade ***/
                FOR EACH   crapris WHERE  
                                   crapris.cdcooper = par_cdcooper      AND
                                   crapris.nrdconta = crapepr.nrdconta  AND
                                   crapris.nrctremp = crapepr.nrctremp  AND
                                   crapris.dtrefere <= aux_dtultdma     AND
                                   crapris.inddocto = 1    NO-LOCK:
                                           
                    IF  crapris.qtdiaatr > aux_qtdiaatr THEN
                        ASSIGN aux_qtdiaatr =  crapris.qtdiaatr.
                END.
                
                IF  aux_qtdiaatr = 0 THEN
                    ASSIGN rel_qtdiaatr = "Sem Atrasos".
                ELSE
                IF  aux_qtdiaatr < 60 THEN
                    ASSIGN rel_qtdiaatr = "Ate 60 dias".
                ELSE
                    ASSIGN rel_qtdiaatr = "Mais 60 dias ou renegociacoes".
                 
                /* Valor prestacao */
                ASSIGN aux_dsvlpree = 
                                   TRIM(STRING(crapepr.vlpreemp,"zzz,zz9.99")).
      
                IF crapepr.tpemprst = 1 THEN
                   ASSIGN aux_tpemprst = "*".
                ELSE
                   ASSIGN aux_tpemprst = "".

                /* Verificar se ja  ultrapassou o limite de linhas
                  do relatorio e reiniciar pagina SD 296491*/
                IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
                DO:
                   PAGE STREAM str_1.
                   DISPLAY STREAM str_1 aux_qtopeliq WITH FRAME f_cab_ultimas.
                END.
                
                DISPLAY STREAM str_1 
                               aux_tpemprst
                               crapepr.nrctremp  crapepr.vlemprst 
                               crapepr.qtpreemp  aux_dsvlpree
                               rel_dslcremp 
                               rel_dsfinemp      rel_dtliquid 
                               rel_qtdiaatr
                               WITH FRAME f_ultimas_operac.
      
                DOWN STREAM str_1 WITH FRAME f_ultimas_operac.
            END.           
      
            /********************* 3- DADOS DA SOLICITACAO *******************/
         
            ASSIGN rel_dslcremp = ""
                   rel_dsfinemp = ""
                   aux_garantia = ""
                   rel_vldopera = 0.
            
            /*** Garantia ***/       
            IF  crapass.inpessoa = 1 THEN
                DO:
                   ASSIGN  rel_lbconjug = "Conjuge co-responsavel?"
                           rel_lbctacje = "Conta/dv ou CPF:".

                   /* Tabela antiga do Rating (CADRAT) */
                   IF   crawepr.dtaltpro < 02/24/2010   THEN
                        DO:
                            FIND crapsir WHERE  
                                 crapsir.cdcooper = par_cdcooper     AND
                                 crapsir.nrtopico = 2                AND
                                 crapsir.nritetop = 2                AND
                                 crapsir.nrseqite = crapprp.nrgarope 
                                 NO-LOCK NO-ERROR.
                        
                            IF  AVAIL crapsir THEN
                                ASSIGN  aux_garantia = crapsir.dsseqite. 
                        END.
                   ELSE     /* Senao pegar da RATCAD */
                        DO:
                            FIND craprad WHERE 
                                 craprad.cdcooper = par_cdcooper   AND
                                 craprad.nrtopico = 2              AND
                                 craprad.nritetop = 2              AND
                                 craprad.nrseqite = crapprp.nrgarope
                                 NO-LOCK NO-ERROR.
         
                            IF   AVAIL craprad THEN
                                 ASSIGN aux_garantia = craprad.dsseqite.
         
                        END.                                   
                END.
            ELSE   /**Juridica **/
                DO:
                   ASSIGN  rel_lbconjug = ""
                           rel_lbctacje = "".
                   
                   IF   crawepr.dtaltpro < 02/24/2010  THEN
                        DO:
                            FIND crapsir WHERE  
                                 crapsir.cdcooper = par_cdcooper     AND
                                 crapsir.nrtopico = 4                AND
                                 crapsir.nritetop = 2                AND
                                 crapsir.nrseqite = crapprp.nrgarope 
                                 NO-LOCK NO-ERROR.
                           
                            IF  AVAIL crapsir THEN
                                ASSIGN  aux_garantia = crapsir.dsseqite.
                        END.
                   ELSE
                        DO:
                            FIND craprad WHERE
                                 craprad.cdcooper = par_cdcooper   AND
                                 craprad.nrtopico = 4              AND
                                 craprad.nritetop = 2              AND
                                 craprad.nrseqite = crapprp.nrgarope
                                 NO-LOCK NO-ERROR.
         
                            IF   AVAIL craprad   THEN
                                 ASSIGN aux_garantia = craprad.dsseqite.
                      
                        END.
                END.
            
            /*** Linha de Credito ***/
            FIND  craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                                craplcr.cdlcremp = crawepr.cdlcremp 
                                NO-LOCK NO-ERROR.
            IF AVAIL craplcr THEN
               rel_dslcremp = STRING(crawepr.cdlcremp) + " - " + 
                              craplcr.dslcremp.
            
            FIND  crapfin WHERE crapfin.cdcooper = par_cdcooper AND
                                crapfin.cdfinemp = crawepr.cdfinemp
                                NO-LOCK NO-ERROR.
            
            IF AVAIL crapfin THEN
               rel_dsfinemp = STRING(crawepr.cdfinemp) + " - " + 
                              crapfin.dsfinemp.
            
            IF   crawepr.tpemprst = 0   THEN
                 DO:
                     /*** Campo - Valor Disponivel em: (Data) ***/
                     ASSIGN  aux_contador = 1
                             aux_dtlibera = par_dtmvtolt.
                                                              
                     DO WHILE aux_contador <= crawepr.qtdialib.
                             
                        aux_dtlibera = aux_dtlibera + 1.
                                          
                        IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtlibera)))   OR
                             CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                             crapfer.dtferiad = aux_dtlibera) THEN
                             .
                        ELSE
                             aux_contador = aux_contador + 1.
                                                          
                     END.  /*  Fim do DO WHILE  */
                 END.
            ELSE
                 DO:
                     ASSIGN aux_dtlibera = crawepr.dtlibera.
                 END.
            
            /*** Campo - Valor Disponivel em: (Valor) ***/
            IF   tot_vlliquid > crawepr.vlemprst   THEN
                 rel_vldsaque = 0.
            ELSE
                 rel_vldsaque = crawepr.vlemprst - tot_vlliquid.
            
            /*** Conjuge co-responsavel ***/
            IF  crapprp.flgdocje = TRUE THEN
                DO:
                   IF  crapprp.nrctacje <> 0 THEN
                       ASSIGN  rel_cpfctacj = STRING(crapprp.nrctacje).
                   ELSE
                       ASSIGN  rel_cpfctacj = STRING(crapprp.nrcpfcje).
                       
                   /**** Busca nome do Conjuge ****/
                   FIND crapcje WHERE  
                                crapcje.cdcooper = par_cdcooper      AND 
                                crapcje.nrdconta = crawepr.nrdconta  AND
                                crapcje.idseqttl = 1  NO-LOCK NO-ERROR.
                   
                   IF  AVAIL crapcje THEN
                       DO:
                           IF  crapcje.nrctacje <> 0 THEN
                               DO:
                                   FIND  crabass WHERE 
                                         crabass.cdcooper = par_cdcooper    AND
                                         crabass.nrdconta = crapprp.nrctacje 
                                         NO-LOCK NO-ERROR.
                                   
                                   IF  AVAIL crabass THEN
                                       rel_nmconjug =  "Conjuge: " +
                                                       crabass.nmprimtl.
                               END.
                           ELSE
                                rel_nmconjug = "Conjuge: " + crapcje.nmconjug.
                       END.
                   
                   aux_linhacje = "____________________________________".
               
                END.
            
            /**Campo Valor Operacao*/
            IF crawepr.idfiniof > 0 THEN
              DO:
                /*Se Financiou IOF*/
                FIND  crapepr WHERE crapepr.cdcooper = crawepr.cdcooper   AND
                                    crapepr.nrdconta = crawepr.nrdconta   AND
                                    crapepr.nrctremp = crawepr.nrctremp
                                    NO-LOCK NO-ERROR.

                IF  AVAIL crapepr THEN
                    ASSIGN rel_vldopera = crawepr.vlemprst + crapepr.vliofepr + crapepr.vltarifa.
                ELSE
                  DO:
                    /*Nao tem o registro na CRAPEPR ainda, teremos que calcular o IOF e TAXA para adicionar no valor total*/
                    
                    /* Busca os bens em garantia */
                    ASSIGN aux_dscatbem = "".
                    FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper  AND
                                           crapbpr.nrdconta = crawepr.nrdconta  AND
                                           crapbpr.nrctrpro = crawepr.nrctremp  AND 
                                           crapbpr.tpctrpro = 90 NO-LOCK:
                        ASSIGN aux_dscatbem = aux_dscatbem + "|" + crapbpr.dscatbem.
                    END.
                    
                    /*Busca a tarifa*/
                    RUN sistema/generico/procedures/b1wgen0097.p 
                           
                    PERSISTENT SET h-b1wgen0097.               
                    RUN consulta_tarifa_emprst IN h-b1wgen0097 (INPUT  crawepr.cdcooper,
                                                                INPUT  crawepr.cdlcremp,
                                                                INPUT  crawepr.vlemprst,
                                                                INPUT  crawepr.nrdconta,
                                                                INPUT  crawepr.nrctremp,
                                                                INPUT  aux_dscatbem,
                                                                OUTPUT aux_vlrtarif,
                                                                OUTPUT TABLE tt-erro).                                
                    DELETE PROCEDURE h-b1wgen0097.
                           
                    IF RETURN-VALUE = "NOK" THEN
                      RETURN "NOK".
                    
                    IF  AVAIL crapepr THEN
                      ASSIGN aux_dtlibera = crapepr.dtmvtolt.
                    ELSE
                      ASSIGN aux_dtlibera = crawepr.dtlibera. 
                   
                   ASSIGN aux_dsctrliq = "".
                   
                   DO i = 1 TO 10:

                     IF  crawepr.nrctrliq[i] > 0  THEN
                       aux_dsctrliq = aux_dsctrliq +
                          (IF  aux_dsctrliq = ""  THEN
                               TRIM(STRING(crawepr.nrctrliq[i],
                                           "z,zzz,zz9"))
                           ELSE
                               ", " +
                               TRIM(STRING(crawepr.nrctrliq[i],
                                           "z,zzz,zz9"))).

                   END. /** Fim do DO ... TO **/
                   
                   /*Busca a carencia para usar na busca do IOF*/
                   ASSIGN aux_qtdias_carencia = 0.
                   IF crawepr.idcarenc > 0 THEN
                   DO:
                   
                     { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                     
                     /* Efetuar a chamada a rotina Oracle  */
                     RUN STORED-PROCEDURE pc_busca_qtd_dias_carencia
                         aux_handproc = PROC-HANDLE NO-ERROR (INPUT crawepr.idcarenc,
                                                             OUTPUT 0,   /* pr_qtddias */
                                                             OUTPUT 0,   /* pr_cdcritic */
                                                             OUTPUT ""). /* pr_dscritic */  

                     /* Fechar o procedimento para buscarmos o resultado */ 
                     CLOSE STORED-PROC pc_busca_qtd_dias_carencia
                            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = ""
                            aux_cdcritic = INT(pc_busca_qtd_dias_carencia.pr_cdcritic) 
                                           WHEN pc_busca_qtd_dias_carencia.pr_cdcritic <> ?
                            aux_dscritic = pc_busca_qtd_dias_carencia.pr_dscritic
                                           WHEN pc_busca_qtd_dias_carencia.pr_dscritic <> ?
                            aux_qtdias_carencia = INT(pc_busca_qtd_dias_carencia.pr_qtddias) 
                                                  WHEN pc_busca_qtd_dias_carencia.pr_qtddias <> ?.
                    END.
                    
                    /*Buscar o valor do IOF da operacao*/
                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                    RUN STORED-PROCEDURE pc_calcula_iof_epr
                    aux_handproc = PROC-HANDLE NO-ERROR(INPUT crawepr.cdcooper
                                                       ,INPUT crawepr.nrdconta
                                                       ,INPUT crawepr.nrctremp
                                                       ,INPUT crawepr.dtmvtolt
                                                       ,INPUT crapass.inpessoa
                                                       ,INPUT crawepr.cdlcremp
                                                       ,INPUT crawepr.cdfinemp                                                       
                                                       ,INPUT crawepr.qtpreemp
                                                       ,INPUT crawepr.vlpreemp
                                                       ,INPUT crawepr.vlemprst
                                                       ,INPUT crawepr.dtdpagto
                                                       ,INPUT aux_dtlibera
                                                       ,INPUT crawepr.tpemprst
                                                       ,INPUT crawepr.dtcarenc /* Data de carencia */
                                                       ,INPUT aux_qtdias_carencia /* dias de carencia */
                                                       ,INPUT aux_dscatbem     /* Bens em garantia */
                                                       ,INPUT crawepr.idfiniof /* Indicador de financiamento de iof e tarifa */
                                                       ,INPUT aux_dsctrliq /* pr_dsctrliq */
                                                       ,INPUT "N" /* Nao gravar valor nas parcelas */
                                                       ,OUTPUT 0 /* Valor calculado da Parcel */
                                                       ,OUTPUT 0 /* Valor calculado com o iof (principal + adicional) */
                                                       ,OUTPUT 0 /* Valor calculado do iof principal */
                                                       ,OUTPUT 0 /* Valor calculado do iof adicional */
                                                       ,OUTPUT 0 /* Imunidade tributária */
                                                       ,OUTPUT "").
            
                    CLOSE STORED-PROC pc_calcula_iof_epr 
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
                           
                    ASSIGN aux_vliofope = 0
                           aux_vliofope = pc_calcula_iof_epr.pr_valoriof 
                                                      WHEN pc_calcula_iof_epr.pr_valoriof <> ?.
               
                    ASSIGN rel_vldopera = crawepr.vlemprst + aux_vliofope + aux_vlrtarif.

                  END.  
                END.
              ELSE
              DO:
                /*Se NAO Financiou IOF*/
                rel_vldopera = crawepr.vlemprst.
              END.
            
            /* Verificar se ja  ultrapassou o limite de linhas
              do relatorio e reiniciar pagina SD 296491
              Controlar para manter na mesma pagina as linhas da opçao 3*/
            IF   LINE-COUNTER(str_1) + 28 > PAGE-SIZE(str_1)   THEN
            DO:
               PAGE STREAM str_1.
               DISPLAY STREAM str_1 rel_nmextcop
                                    rel_inpessoa
                                    aux_dsoperac
                                    aux_cdlcremp
                                    aux_dslcremp
                                    aux_idquapro
                                    aux_dsquapro
                                    aux_tpempres
                        WITH FRAME f_cabecalho.
            END.
            
            DISPLAY  STREAM str_1
                     crawepr.nrctremp 
                     rel_vldopera 
                     crawepr.qtpreemp 
                     crawepr.vlpreemp
                     rel_dslcremp
                     rel_dsfinemp
                     aux_garantia WITH FRAME f_dados_solic.

            
            /* Verificar se ja  ultrapassou o limite de linhas
              do relatorio e reiniciar pagina SD 296491
              Controlar para manter na mesma pagina as linhas da opçao 3*/
            IF   LINE-COUNTER(str_1) + 28 > PAGE-SIZE(str_1)   THEN
            DO:
               PAGE STREAM str_1.
               DISPLAY STREAM str_1 rel_nmextcop
                                    rel_inpessoa
                                    aux_dsoperac
                                    aux_cdlcremp
                                    aux_dslcremp
                                    aux_idquapro
                                    aux_dsquapro
                                    aux_tpempres
                          WITH FRAME f_cabecalho.
            END.
                                 
            /* Outras Propostas */
            VIEW STREAM str_1 FRAME f_outras.

            FOR EACH craxepr WHERE  
                              craxepr.cdcooper = par_cdcooper   AND
                              craxepr.nrdconta = par_nrdconta   AND
                              craxepr.nrctremp <> crawepr.nrctremp NO-LOCK,
                 
                 FIRST crablcr WHERE 
                               crablcr.cdcooper = par_cdcooper     AND
                               crablcr.cdlcremp = craxepr.cdlcremp NO-LOCK,
                 
                 FIRST crabfin WHERE 
                               crabfin.cdcooper = par_cdcooper     AND
                               crabfin.cdfinemp = craxepr.cdfinemp NO-LOCK:
         
                 IF   CAN-FIND (crapepr WHERE
                                crapepr.cdcooper = craxepr.cdcooper    AND
                                crapepr.nrdconta = craxepr.nrdconta    AND
                                crapepr.nrctremp = craxepr.nrctremp)   THEN
                     NEXT.

                 ASSIGN 
                     aux_garantia = ""
                     aux_dsvlpree = TRIM(STRING(craxepr.qtpreemp,"zz9")) + 
                                 " de " + 
                                 TRIM(STRING(craxepr.vlpreemp,"zzz,zz9.99"))
                     
                     aux_dsdlinha = TRIM(STRING(crablcr.cdlcremp,"zzz9")) + 
                                    "-" +
                                    crablcr.dslcremp
                     
                     aux_dsfinali = TRIM(STRING(crabfin.cdfinemp,"zz9")) +
                                    "-" +
                                    crabfin.dsfinemp.
         
                 IF   CAN-FIND (FIRST crapbpr WHERE
                                      crapbpr.cdcooper = craxepr.cdcooper AND
                                      crapbpr.nrdconta = craxepr.nrdconta AND
                                      crapbpr.tpctrpro = 90 /* Emprest.*/ AND
                                      crapbpr.nrctrpro = craxepr.nrctremp AND
                                      crapbpr.flgalien = TRUE) THEN
                      DO:
                          aux_garantia = "Bem".
                      END.

         
                 RUN lista-avalistas (INPUT  1,   /* Emprestimo */
                                      INPUT  craxepr.nrctremp,
                                      INPUT  craxepr.nrctaav1,
                                      INPUT  craxepr.nrctaav2,
                                      INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  par_cdagenci,
                                      INPUT  par_nrdcaixa,   
                                      INPUT  par_idorigem,   
                                      INPUT  par_idseqttl,   
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_garantia1,
                                      OUTPUT aux_garantia2,
                                      OUTPUT TABLE tt-erro).

                 IF  RETURN-VALUE <> "OK" THEN
                     RETURN "NOK".

                 IF   aux_garantia1  <>  ""   THEN
                      IF   aux_garantia = ""   THEN
                           aux_garantia = aux_garantia1.
                      ELSE 
                           aux_garantia = aux_garantia + "/" + aux_garantia1.
         
                 IF   aux_garantia2  <> ""   THEN
                      IF   aux_garantia = ""   THEN
                           aux_garantia = aux_garantia2.
                      ELSE
                           aux_garantia = aux_garantia + "/" + aux_garantia2.

                 IF craxepr.tpemprst = 1 THEN
                    ASSIGN aux_tpemprst = "*".
                 ELSE
                    ASSIGN aux_tpemprst = "".
                 
                 /* Verificar se ja  ultrapassou o limite de linhas
                  do relatorio e reiniciar pagina SD 296491*/
                 IF   LINE-COUNTER(str_1) + 7 > PAGE-SIZE(str_1)   THEN
                 DO:
                   PAGE STREAM str_1.
                   /* Outras Propostas */
                   VIEW STREAM str_1 FRAME f_outras.
                   
                 END.
                 DISPLAY STREAM str_1 aux_tpemprst
                                      craxepr.dtmvtolt
                                      craxepr.nrctremp
                                      craxepr.vlemprst
                                      aux_dsvlpree   
                                      aux_dsdlinha 
                                      aux_dsfinali 
                                      aux_garantia 
                                      WITH FRAME f_outras_prop.
         
                 DOWN STREAM str_1 WITH FRAME f_outras_prop.
         
             END.

             DISPLAY STREAM str_1  crawepr.percetop 
                                   aux_dtlibera 
                                   rel_vldsaque
                                   aux_par_vlutiliz
                                   rel_lbconjug
                                   crapprp.flgdocje   WHEN crapass.inpessoa = 1
                                   rel_lbctacje
                                   rel_cpfctacj 
                                   aux_nmcidpac
                                   WITH FRAME f_dados_solic_2.
             /* P. Fisica */
             IF   crapass.inpessoa = 1   THEN
                  DO:
                      FIND crapcje WHERE crapcje.cdcooper = par_cdcooper  AND
                                         crapcje.nrdconta = par_nrdconta  AND
                                         crapcje.idseqttl = 1
                                         NO-LOCK NO-ERROR.
         
                      IF   AVAIL crapcje           AND
                           crapcje.nrctacje <> 0   THEN
                           DO:
                               IF NOT VALID-HANDLE(h-b1wgen0024) THEN
                               RUN sistema/generico/procedures/b1wgen0024.p
                                                PERSISTENT SET h-b1wgen0024.
                           
                               RUN busca-rotativos IN h-b1wgen0024 
                                             (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_nmdatela,
                                              INPUT par_idorigem,
                                              INPUT par_dtmvtolt,
                                              INPUT par_dtmvtopr,
                                              INPUT crapcje.nrctacje,
                                              INPUT par_flgerlog,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-valores-gerais,
                                              OUTPUT TABLE tt-rotativos,
                                              OUTPUT TABLE tt-dados-epr,
                                              OUTPUT par_vlsdeved,
                                              OUTPUT par_vlpreemp,
                                              OUTPUT par_qtmesatr).
                           
                               IF VALID-HANDLE(h-b1wgen0024) THEN
                                  DELETE OBJECT h-b1wgen0024.
                           
                               IF  RETURN-VALUE <> "OK"  THEN
                                   RETURN "NOK".
         
                               FIND FIRST tt-valores-gerais NO-LOCK NO-ERROR.
                               IF   AVAIL tt-valores-gerais   THEN
                                    DO:
                                        DISPLAY STREAM str_1 
                                                 tt-valores-gerais.nmprimtl
                                                 tt-valores-gerais.nrdconta
                                               
                                                 WITH FRAME f_conjuge.  
                                  
                                        DISPLAY STREAM str_1 
                                                  tt-valores-gerais.vlsmdtri @ 
                                                                  rel_vlsmdtri
                                                  tt-valores-gerais.vldcotas @ 
                                                                  rel_vlcaptal
                                                  tt-valores-gerais.vlprepla @ 
                                                                  rel_vlprepla
                                                  tt-valores-gerais.vlsldapl @ 
                                                                  pro_vlaplica
                                          WITH FRAME f_historico_2.           
                                    END.

                               VIEW STREAM str_1 FRAME f_cab_rotativos_2.
         
                               FOR EACH tt-rotativos NO-LOCK:
         
                                   DISPLAY STREAM str_1 
                                       tt-rotativos.dsoperac @ rel_modalida
                                       tt-rotativos.vllimite @ rel_dslimite
                                       tt-rotativos.vlutiliz @ rel_sldutili
                                       tt-rotativos.dsgarant @ rel_garantid
                                       tt-rotativos.dtmvtolt @ rel_dtcontra
                                       WITH FRAME f_rotativos.
         
                                   DOWN WITH FRAME f_rotativos.
                                   
                               END.
         
                               VIEW STREAM str_1 FRAME f_conj_emprest.
         
                               FOR EACH tt-dados-epr NO-LOCK:
         
                                   DISPLAY STREAM str_1 
                                           tt-dados-epr.nrctremp
                                           tt-dados-epr.vlsdeved
                                           tt-dados-epr.qtprecal
                                           tt-dados-epr.qtpreemp
                                           tt-dados-epr.vlpreemp
                                           tt-dados-epr.qtmesatr
                                           tt-dados-epr.dslcremp
                                           tt-dados-epr.dsfinemp
                                           tt-dados-epr.dsdavali
         
                                           WITH FRAME f_conj_emprest_2.
         
                                   DOWN WITH FRAME f_conj_emprest_2.
         
                               END.

                               /* Se existem emprestimos */
                               IF   TEMP-TABLE tt-dados-epr:HAS-RECORDS  THEN
                                    DISPLAY STREAM str_1 
                                            par_vlsdeved
                                            par_vlpreemp
                                            par_qtmesatr
                                            WITH FRAME f_conj_emprest_tot.
                           END.
                  END.
            /** Nome da cidade do PAC do associado **/
            FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                               crapage.cdagenci = crapass.cdagenci  
                               NO-LOCK NO-ERROR.
                                  
            IF   NOT AVAILABLE crapage   THEN
                 aux_nmcidpac = TRIM(crapcop.nmcidade) + ",".
            ELSE
                 aux_nmcidpac = crapage.nmcidade + ",".
             
            
           /* Verificar se a inclusão das linhas irá
              ultrapassar o limite da pagina
              do relatorio e reiniciar pagina SD 296491*/
            IF   LINE-COUNTER(str_1) + 15 > PAGE-SIZE(str_1)   THEN
            DO:
               /* Devido para aalguns relatorios estar apresentando
                  mais de uma vez o cabeçalho, estamos forçando para que esconda e 
                  exiba novamente SD 296491*/
               HIDE STREAM str_1 FRAME f_cabecalho.
               
               PAGE STREAM str_1.
               DISPLAY STREAM str_1 rel_nmextcop
                                    rel_inpessoa
                                    aux_dsoperac
                                    aux_cdlcremp
                                    aux_dslcremp
                                    aux_idquapro
                                    aux_dsquapro
                                    aux_tpempres
                        WITH FRAME f_cabecalho.
            END.
           
            /*Rafael Ferreira (Mouts) - Story 19674
              Alterado para exibir data de alteraçao da proposta no relatório*/
            DISPLAY  STREAM str_1
                     aux_nmcidpac     rel_ddmvtolt     rel_dsmesref
                     rel_aamvtolt     rel_nmprimtl[1]  
                     rel_nmconjug     WHEN crapprp.flgdocje = TRUE 
                     aux_linhacje     WHEN crapprp.flgdocje = TRUE
                     aux_nmoperad @   aux_nmoperad     
                     WITH FRAME f_aprovacao.
       
            PAGE STREAM str_1.
                                            
            /****************** 4- ANALISE DA PROPOSTA *********************/ 
       
            DISPLAY STREAM str_1 WITH FRAME f_cab_analise.
       
            /***  Imprime o campo de Observacoes do Comite de Aprovacao  ***/
            DISPLAY STREAM str_1 WITH FRAME f_cab_comite_observ.
       
            ASSIGN aux_restoobs = LENGTH(crawepr.dsobscmt) MODULO 76
                   aux_incontad = 1.
                    
            IF  crawepr.dsobscmt <> "" THEN
                DO:
                    DO  aux_contador = 1 TO LENGTH(crawepr.dsobscmt):
                        IF  (aux_contador modulo 76 = 0) THEN
                            DO:   
                                rel_dsobscmt = 
                                      SUBSTR(crawepr.dsobscmt,aux_incontad,76).
       
                                DISPLAY STREAM str_1 
                                      rel_dsobscmt FORMAT "x(76)" 
                                      WITH FRAME f_comite_observ.
                                
                                DOWN WITH FRAME f_comite_observ. 
                                
                                ASSIGN aux_incontad = aux_incontad + 76.
                            END.
                    END.
                    
                    IF  LENGTH(crawepr.dsobscmt) > aux_restoobs THEN 
                        aux_incontad = LENGTH(crawepr.dsobscmt) - 
                                       aux_restoobs + 1.
                    ELSE
                        aux_incontad = 1.
                   
                    ASSIGN rel_dsobscmt =
                           SUBSTR(crawepr.dsobscmt,aux_incontad ,aux_restoobs).
            
                    DISPLAY STREAM str_1 rel_dsobscmt 
                        WITH FRAME f_comite_observ.
                END.
                               
            
            /***   Imprime o campo de Observacoes   ***/
            DISPLAY STREAM str_1 WITH FRAME f_cab_observac.
       
            ASSIGN aux_restoobs = LENGTH(crawepr.dsobserv) MODULO 76
                   aux_incontad = 1.
                    
            IF  crawepr.dsobserv <> "" THEN
                DO:
                    DO  aux_contador = 1 TO LENGTH(crawepr.dsobserv):
                        IF  (aux_contador modulo 76 = 0) THEN
                            DO:   
                                rel_dsobserv = 
                                      SUBSTR(crawepr.dsobserv,aux_incontad,76).
       
                                DISPLAY STREAM str_1 
                                        rel_dsobserv FORMAT "x(76)" 
                                        WITH FRAME f_observac.
                                
                                DOWN WITH FRAME f_observac. 
                                
                                ASSIGN aux_incontad = aux_incontad + 76.
                            END.
                    END.
                    
                    IF  LENGTH(crawepr.dsobserv) > aux_restoobs THEN 
                        aux_incontad = LENGTH(crawepr.dsobserv) - 
                                       aux_restoobs + 1.
                    ELSE
                        aux_incontad = 1.
                   
                    ASSIGN rel_dsobserv =
                           SUBSTR(crawepr.dsobserv,aux_incontad ,aux_restoobs).
            
                    DISPLAY STREAM str_1 rel_dsobserv WITH FRAME f_observac.
                END.
            
            /******** SOCIOS - Juridica ********/
            IF  crapass.inpessoa = 2 THEN  DO:       
                
                /* BACKUP da variavel utilizada em varios fontes */
                /* Usada para restaurar o valor */
                ASSIGN bkp_vltotrpp = par_vltotrpp. 
               
                FOR EACH crapavt NO-LOCK WHERE 
                                 crapavt.cdcooper = par_cdcooper       AND
                                 crapavt.nrdconta = crawepr.nrdconta   AND
                                 crapavt.tpctrato = 6                  AND
                                 crapavt.nrctremp = 0                  AND
                                 crapavt.dsproftl = "SOCIO/PROPRIETARIO"  
                                   BREAK BY crapavt.nrdctato:
                    
                    ASSIGN rel_vldendiv = 0.

                    IF  FIRST(crapavt.nrdctato) THEN
                        DISPLAY STREAM str_1 WITH FRAME f_cab_socios. 
                    
                    /*** Socio Cooperado ***/
                    IF  crapavt.nrdctato <> 0  THEN
                        DO:   
                            ASSIGN rel_lblavali = "   Conta"
                                   rel_lbcotavl = "Cotas Capital"             
                                   rel_lbsldavl = "Saldo Medio"
                                   rel_lbaplavl = "Aplicacao".
                            
                            FIND crabass WHERE 
                                         crabass.cdcooper = par_cdcooper    AND
                                         crabass.nrdconta = crapavt.nrdctato 
                                         NO-LOCK NO-ERROR.
                                 
                            IF  AVAIL crabass THEN DO:
                                /**** Valor das Cotas ****/ 
                                FIND crapcot WHERE 
                                     crapcot.cdcooper = par_cdcooper AND
                                     crapcot.nrdconta = crapavt.nrdctato
                                     NO-LOCK NO-ERROR.
                                
                                IF AVAIL crapcot THEN
                                   ASSIGN rel_vldcotas = crapcot.vldcotas.
                                
                                
                                /****** Saldo Medio Semestral do Socio *******/
                                FIND  crapsld WHERE 
                                      crapsld.cdcooper = par_cdcooper      AND
                                      crapsld.nrdconta = crapavt.nrdctato 
                                      NO-LOCK NO-ERROR.
                   
                                IF AVAIL crapsld THEN
                                   rel_vlsmdsem = 
                                   (crapsld.vlsmstre[1] + crapsld.vlsmstre[2] +
                                    crapsld.vlsmstre[3] + crapsld.vlsmstre[4] +
                                    crapsld.vlsmstre[5] + 
                                    crapsld.vlsmstre[6]) / 6.

                                /******** Aplicacaoes do Socio ********/
                                ASSIGN par_nrdconta = crapavt.nrdctato.  

                                RUN calcula-apl-aval (INPUT par_cdcooper,     
                                                      INPUT par_cdagenci,     
                                                      INPUT par_nrdcaixa,     
                                                      INPUT par_cdoperad,     
                                                      INPUT par_nrdconta,     
                                                      INPUT par_idorigem,
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_dtmvtopr,  
                                                      INPUT par_inproces,
                                                      INPUT par_idseqttl,
                                                      INPUT par_nmdatela,
                                                      INPUT par_flgerlog,
                                                      INPUT par_cdprogra,
                                                     OUTPUT par_vltotapl,
                                                     OUTPUT par_vltotrpp,
                                                     OUTPUT TABLE tt-erro).

                                IF  RETURN-VALUE <> "OK" THEN
                                    RETURN "NOK".

                                ASSIGN  rel_vlaplavl = par_vltotapl + 
                                                       par_vltotrpp
                                    
                                        /* Restaurar BACKUP */
                                        par_vltotrpp = bkp_vltotrpp. 
       
                                /*** Endividamento ***/
                                FOR EACH crapsdv NO-LOCK WHERE 
                                         crapsdv.cdcooper = par_cdcooper      AND
                                         crapsdv.nrdconta = crapavt.nrdctato  AND
                                        CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo)):
                                         ASSIGN rel_vldendiv = 
                                                rel_vldendiv + crapsdv.vldsaldo. 
                                END.
                                                     
                                DISPLAY   STREAM str_1
                                          rel_lblavali
                                          rel_lbcotavl                
                                          rel_lbsldavl
                                          rel_lbaplavl
                                          crabass.nmprimtl @ crapavt.nmdavali
                                          crapavt.nrdctato 
                                          rel_vldcotas 
                                          rel_vlsmdsem
                                          rel_vlaplavl
                                          rel_vldendiv
                                          WITH FRAME f_socios.
                                
                                DOWN STREAM str_1 WITH FRAME f_socios.
                 
                                /******* Bens do Socio *******/
                                FOR EACH crapbem WHERE  
                                         crapbem.cdcooper = par_cdcooper     AND
                                         crapbem.nrdconta = crapavt.nrdctato AND
                                         crapbem.idseqttl = 1   NO-LOCK: 
                                       
                                         DISPLAY STREAM str_1 
                                                 crapbem.dsrelbem
                                                 crapbem.persemon
                                                 crapbem.qtprebem
                                                 crapbem.vlprebem
                                                 crapbem.vlrdobem  
                                                 WITH FRAME f_garantia_bens_avl.
                    
                                         DOWN STREAM str_1 
                                              WITH FRAME f_garantia_bens_avl.
                                END. 
                            END.  /** Fim do if crabass **/
                        END.
                    ELSE    /*** Socio Nao Cooperado ***/
                       DO:
                           ASSIGN rel_lblavali = "     CPF".
                                   
                           DISPLAY  STREAM str_1 
                                    rel_lblavali
                                    ""               @ rel_lbcotavl          
                                    ""               @ rel_lbsldavl
                                    ""               @ rel_lbaplavl
                                    crapavt.nmdavali 
                                    crapavt.nrcpfcgc FORMAT "zzzzzzzzzzzz"  @
                                                             crapavt.nrdctato 
                                    ""               @ rel_vldcotas
                                    ""               @ rel_vlsmdsem
                                    ""               @ rel_vlaplavl
                                    crapavt.vledvmto @ rel_vldendiv
                                    WITH FRAME f_socios.
               
                           DOWN STREAM str_1 WITH FRAME f_socios.
               
                           DO  aux_contador = 1 TO 4:
                               IF  crapavt.dsrelbem[aux_contador] <> "" THEN
                                   DO:
                                       DISPLAY STREAM str_1 
                                             crapavt.dsrelbem[aux_contador] @
                                                             crapbem.dsrelbem
                                             crapavt.persemon[aux_contador] @
                                                             crapbem.persemon
                                             crapavt.qtprebem[aux_contador] @
                                                             crapbem.qtprebem
                                             crapavt.vlprebem[aux_contador] @
                                                             crapbem.vlprebem
                                             crapavt.vlrdobem[aux_contador] @
                                                             crapbem.vlrdobem
                                             WITH FRAME f_garantia_bens_avl.
                    
                                       DOWN STREAM str_1 
                                               WITH FRAME f_garantia_bens_avl.
                                   END.
                           END.
                        END.
              
                END.  /** Fim do FOR EACH **/
       
                ASSIGN rel_lbperger = "PERCEPCAO GERAL COM RELACAO A EMPRESA:".
                
                IF   crawepr.dtaltpro < 02/24/2010   THEN
                     DO:
                         FIND crapsir WHERE 
                                      crapsir.cdcooper = par_cdcooper   AND
                                      crapsir.nrtopico = 6              AND
                                      crapsir.nritetop = 3              AND
                                      crapsir.nrseqite = crapprp.nrperger
                                      NO-LOCK NO-ERROR.
                          
                          IF AVAIL crapsir THEN
                             rel_nrperger =  STRING(crapprp.nrperger) + " - " +
                                             crapsir.dsseqite.                 
                     END.
                ELSE
                     DO:
                         FIND craprad WHERE 
                                      craprad.cdcooper = par_cdcooper  AND
                                      craprad.nrtopico = 3             AND
                                      craprad.nritetop = 11            AND
                                      craprad.nrseqite = crapprp.nrperger
                                      NO-LOCK NO-ERROR.
       
                         IF   AVAIL craprad  THEN
                              rel_nrperger = STRING(crapprp.nrperger) + " - " +
                                             craprad.dsseqite.
       
                     END.
                                                                         
            END. /** Fim if inpessoa = 2 **/

       
            /** Informacoes Cadastrais **/
       
            IF   crawepr.dtaltpro < 02/24/2010   THEN
                 DO:
                     IF  crapass.inpessoa = 1 THEN
                         FIND crapsir WHERE 
                              crapsir.cdcooper = par_cdcooper     AND
                              crapsir.nrtopico = 1                AND
                              crapsir.nritetop = 4                AND
                              crapsir.nrseqite = crapprp.nrinfcad
                              NO-LOCK NO-ERROR.
                     ELSE
                         FIND crapsir WHERE 
                              crapsir.cdcooper = par_cdcooper     AND
                              crapsir.nrtopico = 6                AND
                              crapsir.nritetop = 2                AND
                              crapsir.nrseqite = crapprp.nrinfcad
                              NO-LOCK NO-ERROR.
                      
                     IF  AVAIL crapsir THEN                                   
                         ASSIGN rel_informac = 
                           STRING(crapprp.nrinfcad) + "-" + crapsir.dsseqite. 
                          
                 END.
            ELSE
                 DO:
                     IF   crapass.inpessoa = 1 THEN
                          FIND craprad WHERE
                               craprad.cdcooper = par_cdcooper   AND
                               craprad.nrtopico = 1              AND
                               craprad.nritetop = 4              AND
                               craprad.nrseqite = crapprp.nrinfcad
                               NO-LOCK NO-ERROR.
                     ELSE
                          FIND craprad WHERE
                               craprad.cdcooper = par_cdcooper   AND
                               craprad.nrtopico = 3              AND
                               craprad.nritetop = 3              AND
                               craprad.nrseqite = crapprp.nrinfcad
                               NO-LOCK NO-ERROR.
       
                     IF   AVAIL craprad   THEN
                          ASSIGN rel_informac =
                                 STRING (crapprp.nrinfcad) + "-" + 
                                 craprad.dsseqite.
                 END.
                                                        
            /*** Consulta no CCF ***/
            ASSIGN  rel_somadccf = 0
                    rel_valorccf = 0
                    rel_qtdevolu = 0
                    par_vltotpre = 0.
       
            /****Consulta do CCF - Cheques Devolvidos*****/
            FOR EACH crapneg WHERE  crapneg.cdcooper = par_cdcooper     AND
                                    crapneg.nrdconta = crapass.nrdconta AND
                                    crapneg.cdhisest = 1                AND
                                   CAN-DO("11,12,13", STRING(crapneg.cdobserv))
                                    NO-LOCK USE-INDEX crapneg2:
                                   
                    ASSIGN rel_qtdevolu = rel_qtdevolu + 1
                           rel_dtultdev = crapneg.dtiniest.
                           
                    IF  CAN-DO("12,13", STRING(crapneg.cdobserv)) AND
                        crapneg.flgctitg <> 0                     AND
                        crapneg.dtfimest = ?                      THEN
                        DO:                           
                            ASSIGN  rel_somadccf = rel_somadccf + 1
                                    rel_valorccf = rel_valorccf + 
                                                   crapneg.vlestour.
                                   
                        END.
            END.
                    
            /**** Quantidade Adto. Depositante ****/
            IF NOT VALID-HANDLE(h-b1wgen0027) THEN
            RUN sistema/generico/procedures/b1wgen0027.p 
                                           PERSISTENT SET h-b1wgen0027.
           
            RUN lista_ocorren IN h-b1wgen0027 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT crapass.nrdconta,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT par_inproces,
                                               INPUT par_idorigem,
                                               INPUT par_idseqttl,
                                               INPUT par_nmdatela,
                                               INPUT par_flgerlog,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-ocorren).
                                 
            IF VALID-HANDLE(h-b1wgen0027) THEN
               DELETE OBJECT h-b1wgen0027.
            
            FIND FIRST tt-ocorren  NO-LOCK NO-ERROR.
                            
            IF  AVAILABLE tt-ocorren   THEN
                ASSIGN  rel_qtdaditi = tt-ocorren.qtddtdev.
             
            IF  tt-ocorren.flgjucta = FALSE AND 
                tt-ocorren.flgpreju = FALSE THEN
                rel_flgpreju = FALSE.
            ELSE
                rel_flgpreju = TRUE.
            

            /* Ultimo dia do mes passado */
            ASSIGN aux_dtultdma = par_dtmvtolt - DAY(par_dtmvtolt).

            /********EM CL********/
            ASSIGN rel_qtdvezcl = 0.
            FOR EACH crapris NO-LOCK WHERE  
                                     crapris.cdcooper = par_cdcooper     AND
                                     crapris.cdmodali = 0101             AND
                                     crapris.nrdconta = crawepr.nrdconta AND
                                     crapris.nrctremp = crawepr.nrdconta AND
                                     crapris.cdorigem = 1                AND
                                     crapris.inddocto = 1                AND
                                     crapris.dtrefere <= aux_dtultdma:  
                
                ASSIGN rel_qtdvezcl = rel_qtdvezcl + 1.
                                       
            END.
                      
            FOR EACH crapepr WHERE  crapepr.cdcooper = par_cdcooper     AND
                                    crapepr.nrdconta = crapass.nrdconta AND
                                    crapepr.inliquid = 0 NO-LOCK:
                
                IF  NOT CAN-DO(aux_dsliquid,
                               TRIM(STRING(crapepr.nrctremp,"zz,zzz,zz9"))) THEN
                    ASSIGN par_vltotpre = par_vltotpre + crapepr.vlpreemp.
                
                IF  crapepr.cdlcremp = 800 OR
                    crapepr.cdlcremp = 900 THEN
                    ASSIGN rel_flgcremp = TRUE.
            END.
                
            /******* Valor Solicitado/Valor do capital *********/
            FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                               crapcot.nrdconta = crapass.nrdconta 
                               NO-LOCK NO-ERROR.
           
            IF  AVAIL crapcot THEN
                aux_vlslccap = crawepr.vlemprst / crapcot.vldcotas.  
                                            
       
            IF   crawepr.dtaltpro < 02/24/2010   THEN
                 DO:    
                     /***Liquidez das Garantias***/
                     IF crapass.inpessoa = 1 THEN
                        FIND crapsir WHERE  
                                     crapsir.cdcooper = par_cdcooper     AND
                                     crapsir.nrtopico = 2                AND
                                     crapsir.nritetop = 3                AND
                                     crapsir.nrseqite = crapprp.nrliquid
                                     NO-LOCK NO-ERROR.
                     ELSE   /** Juridica **/
                        FIND crapsir WHERE 
                                     crapsir.cdcooper = par_cdcooper     AND
                                     crapsir.nrtopico = 4                AND
                                     crapsir.nritetop = 3                AND
                                     crapsir.nrseqite = crapprp.nrliquid
                                     NO-LOCK NO-ERROR.
                        
                     IF AVAIL crapsir THEN
                        rel_nrliquid = STRING(crapprp.nrliquid) + " - " + 
                                       crapsir.dsseqite.               
                 END.
            ELSE
                 DO:
                     IF   crapass.inpessoa = 1  THEN
                          FIND craprad WHERE
                               craprad.cdcooper = par_cdcooper   AND
                               craprad.nrtopico = 2              AND
                               craprad.nritetop = 3              AND
                               craprad.nrseqite = crapprp.nrliquid
                               NO-LOCK NO-ERROR.
                     ELSE
                          FIND craprad WHERE
                               craprad.cdcooper = par_cdcooper   AND
                               craprad.nrtopico = 4              AND
                               craprad.nritetop = 3              AND
                               craprad.nrseqite = crapprp.nrliquid
                               NO-LOCK NO-ERROR.
                     
                     IF  AVAIL craprad  THEN
                         rel_nrliquid = STRING(crapprp.nrliquid) + " - " + 
                                        craprad.dsseqite.
                 END.
                                       
            /*** Salario do Conjuge ***/
            IF  crapprp.flgdocje = TRUE THEN
                DO:     
                    FIND crapcje WHERE  
                                 crapcje.cdcooper = par_cdcooper     AND
                                 crapcje.nrdconta = crapass.nrdconta AND
                                 crapcje.idseqttl = 1  NO-LOCK NO-ERROR.
                                       
                    IF  AVAIL crapcje THEN
                        ASSIGN  aux_vlrencje = crapcje.vlsalari.
                END.
                                         
            IF  crapass.inpessoa = 1 THEN  /** Fisica **/
                DO:    
                    ASSIGN rel_lbcompre = "Comprometimento da Renda:" 
                           rel_comprend = (crawepr.vlpreemp + par_vltotpre) / 
                                          (rel_vlsalari     + rel_vldrendi +
                                          crapprp.vloutras + crapprp.vlsalcon) 
                                          * 100
                           rel_lbptrpes = "Patr. Pessoal Livre em " +
                                          "Relacao ao Endiv. Total:".
                           
                        /** Mostra somente valores ateh 9999,99% **/
                    IF  rel_comprend <> 0 AND rel_comprend < 10000 THEN       
                        rel_lbcompre = rel_lbcompre +
                                       STRING(rel_comprend,"zzz9.99") + "%".
                END.
            ELSE    /**** Juridica ****/
                DO:   
                    ASSIGN rel_lbcompre  = "Fatur. medio bruto mensal com " +
                                           "comprometimento interno de:"
                           rel_comprend = (crawepr.vlpreemp + par_vltotpre) /
                                           crapprp.vlmedfat * 100.
                       
                       /** Mostra somente valores ateh 9999,99% **/
                    IF  rel_comprend <> 0 AND rel_comprend < 10000 THEN   
                        rel_lbcompre = rel_lbcompre  +         
                                       STRING(rel_comprend,"zzzz9.99") + "%".
                END.
            
            /*** Patrimonio Pessoal Livre ***/
            
            IF    crawepr.dtaltpro < 02/24/2010   THEN
                  DO:
                      FIND crapsir WHERE  
                           crapsir.cdcooper = par_cdcooper AND
                           crapsir.nrtopico = 3            AND
                           crapsir.nritetop = 2            AND
                           crapsir.nrseqite = crapprp.nrpatlvr
                           NO-LOCK NO-ERROR.
                     
                      IF  AVAIL crapsir THEN
                          rel_nrpatlvr = STRING(crapprp.nrpatlvr) + " - " + 
                                         crapsir.dsseqite.              
                  END.
            ELSE
                  DO:
                      FIND craprad WHERE 
                           craprad.cdcooper = par_cdcooper  AND
                           craprad.nrtopico = 1             AND
                           craprad.nritetop = 8             AND
                           craprad.nrseqite = crapprp.nrpatlvr
                           NO-LOCK NO-ERROR.
       
                      IF   AVAIL craprad  THEN
                           rel_nrpatlvr = STRING (crapprp.nrpatlvr) + " - " +
                                          craprad.dsseqite.
                  END.
       
       
            /* Esconder Campos especificos da pessoa fisica */
            IF   crapass.inpessoa = 1   THEN
                 ASSIGN 
                    lbl_dtoutspc = "CONSULTADO SPC CONJUGE EM :"
                    lbl_dtoutris = "CENTRAL DE RISCO CONJUGE EM:"
                    lbl_vltotsfn = "VLR TOTAL SFN C/COOP:".         
            ELSE 
                 ASSIGN lbl_dtoutspc = ""
                        lbl_dtoutris = ""
                        lbl_vltotsfn = "".
      
           /* Titular */
           RUN imprime-scr-consultas (INPUT par_cdcooper,
                                      INPUT par_cdoperad, 
                                      INPUT par_nmdatela, 
                                      INPUT par_idorigem, 
                                      INPUT par_dtmvtolt, 
                                      INPUT crapass.nrdconta,
                                      INPUT crawepr.nrctremp,
                                      INPUT crapass.inpessoa,
                                      INPUT crapass.nrdconta,
                                      INPUT 0, /* CPF */
                                      INPUT 0, /* Ind. aval */
                                     OUTPUT TABLE tt-erro).

           DISPLAY STREAM str_1 
                     lbl_dtoutspc WHEN crapass.inpessoa = 1
                     WITH FRAME f_analise_2.

           /* Conjuge */
           IF   crapass.inpessoa = 1   AND 
                AVAIL crapcje          AND 
                crawepr.inconcje = 1   THEN
                 RUN imprime-scr-consultas (INPUT par_cdcooper,
                                            INPUT par_cdoperad, 
                                            INPUT par_nmdatela, 
                                            INPUT par_idorigem, 
                                            INPUT par_dtmvtolt, 
                                            INPUT crapass.nrdconta,
                                            INPUT crawepr.nrctremp,
                                            INPUT 5, /* Conjuge */
                                            INPUT crapcje.nrctacje,
                                            INPUT crapcje.nrcpfcjg,
                                            INPUT 0, /* Ind. aval */ 
                                           OUTPUT TABLE tt-erro).

           DISPLAY STREAM str_1 
                    rel_lbperger      
                    rel_nrperger     WHEN crapass.inpessoa = 2
                    rel_informac     /**Informacoes Cadastrais**/
                    WITH FRAME f_analise.
                                  
           DISPLAY STREAM str_1 
                     crapprp.dtdrisco 
                     crapprp.vltotsfn  
                     crapprp.qtopescr
                     crapprp.qtifoper 
                     crapprp.vlopescr 
                     crapprp.vlrpreju
                     crapprp.dtoutspc WHEN crapass.inpessoa = 1
                     lbl_dtoutris     WHEN crapass.inpessoa = 1
                     crapprp.dtoutris WHEN crapass.inpessoa = 1 
                     lbl_vltotsfn     WHEN crapass.inpessoa = 1
                     crapprp.vlsfnout WHEN crapass.inpessoa = 1
                     rel_somadccf
                     rel_valorccf
                     rel_dssitdct
                     rel_dsdrisco
                     rel_percentu
                     rel_dsdrisco_calc
                     rel_percentu_calc
                     rel_qtdevolu
                     rel_dtultdev
                     rel_qtdaditi  /** Aditivo Depositante **/
                     rel_flgpreju  /** Prejuizo na Coop **/
                     rel_qtdvezcl  /** CL **/
                     rel_flgcremp
                     aux_vlslccap     WHEN aux_vlslccap < 99999.99   
                     rel_nrliquid   /** Liquidez **/
                     rel_lbcompre   
                     rel_lbptrpes     WHEN crapass.inpessoa = 1 
                     rel_nrpatlvr     WHEN crapass.inpessoa = 1
                     WITH FRAME f_analise_3.
            
            RUN parecer_credito( INPUT par_cdcooper,
                                 INPUT crapass.nrdconta,
                                 INPUT crawepr.nrctremp).
            
          
            /********************  5 - GARANTIA ***********************/
            
            ASSIGN flg_temavali = FALSE     
                   rel_lblavali = "   Conta"
                   rel_lbcotavl = "Cotas Capital"
                   rel_lbsldavl = "Saldo Medio"
                   rel_lbaplavl = "Aplicacao".    
            
            DISPLAY STREAM str_1 WITH FRAME f_garantia.
       
            /* BACKUP da variavel utilizada em varios fontes */
            /* Usada para restaurar o valor */

            ASSIGN bkp_vltotrpp = par_vltotrpp
                   aux_iddoaval = 0.

            FOR EACH crabass WHERE (crabass.cdcooper = par_cdcooper        AND 
                                    crabass.nrdconta = crawepr.nrctaav1)   OR
                                   (crabass.cdcooper = par_cdcooper        AND 
                                    crabass.nrdconta = crawepr.nrctaav2) 
                                   NO-LOCK:
                 
                 ASSIGN  rel_vlsmdsem = 0
                         rel_vlaplavl = 0
                         rel_vldendiv = 0
                         rel_vldcotas = 0
                         rel_vlrenavl = 0
                         aux_iddoaval = aux_iddoaval + 1.
        
                 FIND crapcot WHERE crapcot.cdcooper = par_cdcooper AND
                                    crapcot.nrdconta = crabass.nrdconta 
                                    NO-LOCK NO-ERROR.
                
                 IF  AVAIL crapcot THEN
                     ASSIGN rel_vldcotas = crapcot.vldcotas.
       
                 ASSIGN flg_temavali = TRUE
                        rel_dsavalde = "".
                
                 /******* Saldo Semestral do Avalista ********/
                 FIND crapsld WHERE crapsld.cdcooper = par_cdcooper AND
                                    crapsld.nrdconta = crabass.nrdconta 
                                    NO-LOCK NO-ERROR.
                   
                 IF AVAIL crapsld THEN
                    rel_vlsmdsem = (crapsld.vlsmstre[1] + crapsld.vlsmstre[2] +
                                    crapsld.vlsmstre[3] + crapsld.vlsmstre[4] +
                                    crapsld.vlsmstre[5] + crapsld.vlsmstre[6]) 
                                    / 6.

                 /******** Aplicacoes do Avalista ********/
                 ASSIGN par_nrdconta = crabass.nrdconta.

                 RUN calcula-apl-aval (INPUT par_cdcooper,     
                                       INPUT par_cdagenci,     
                                       INPUT par_nrdcaixa,     
                                       INPUT par_cdoperad,     
                                       INPUT par_nrdconta,     
                                       INPUT par_idorigem,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,  
                                       INPUT par_inproces,
                                       INPUT par_idseqttl,
                                       INPUT par_nmdatela,
                                       INPUT par_flgerlog,
                                       INPUT par_cdprogra,
                                      OUTPUT par_vltotapl,
                                      OUTPUT par_vltotrpp,
                                      OUTPUT TABLE tt-erro).

                 IF  RETURN-VALUE <> "OK"  THEN
                     RETURN "NOK".
                 
                 ASSIGN rel_vlaplavl = par_vltotapl + par_vltotrpp
                        par_vltotrpp = bkp_vltotrpp.

                 /*** Endividamento ***/
                 FOR EACH crapsdv WHERE 
                                  crapsdv.cdcooper = par_cdcooper      AND
                                  crapsdv.nrdconta = crabass.nrdconta  AND
                                  CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                  NO-LOCK:
                     ASSIGN rel_vldendiv = rel_vldendiv + crapsdv.vldsaldo. 
                 END.
                
                 /**** Renda Mensal do Avalista ****/
                 FIND crapttl WHERE crapttl.cdcooper = par_cdcooper      AND
                                    crapttl.nrdconta = crabass.nrdconta  AND
                                    crapttl.idseqttl = 1    NO-LOCK NO-ERROR.
                 
                 IF  AVAIL crapttl THEN     
                     ASSIGN rel_vlrenavl = 
                                crapttl.vlsalari + 
                                crapttl.vldrendi[1] + crapttl.vldrendi[2] +
                                crapttl.vldrendi[3] + crapttl.vldrendi[4].
                     
                 EMPTY TEMP-TABLE tt-crapavl.
                 
                 /*** Aval de ***/                  
                 FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper     AND
                                        crapavl.nrdconta = crabass.nrdconta 
                                        NO-LOCK:
                     
                     /**Mostra as contas nos quais o avalista tambem eh aval**/
                     RUN verifica-contas-avais (INPUT crapavl.nrctaavd,
                                                INPUT crapavl.nrctravd,
                                                INPUT crapavl.tpctrato,
                                                INPUT par_cdcooper,
                                                INPUT par_cdoperad,
                                                INPUT par_dtmvtolt,
                                                INPUT par_cdagenci, 
                                                INPUT par_nrdcaixa, 
                                                INPUT par_idorigem, 
                                                INPUT par_idseqttl, 
                                                INPUT par_flgerlog, 
                                                INPUT par_nmdatela).

                 END.  /** Fim - FOR EACH crapavl ***/
                 
                 FOR EACH tt-crapavl:
                         ASSIGN rel_dsavalde = rel_dsavalde +
                                               STRING(tt-crapavl.nrdconta) +
                                                " / ".
                 END.
                  
                 /** Retira a barra "/" do final da variavel **/
                 rel_dsavalde = SUBSTR(rel_dsavalde,1,LENGTH(rel_dsavalde) - 2).
                 
                 IF  crabass.nrdconta = crawepr.nrctaav1 THEN
                     DISPLAY STREAM str_1 
                             rel_lblavali
                             rel_lbcotavl
                             rel_lbsldavl
                             rel_lbaplavl
                             crawepr.nmdaval1  
                             crawepr.nrctaav1  
                             rel_vlaplavl      /** Aplicacoes **/
                             rel_vldendiv      /** Endividamento **/
                             rel_vlrenavl      /** Renda Mensal **/
                             rel_vldcotas      /** Cotas **/
                             rel_vlsmdsem      /** Saldo Medio **/
                             rel_dsavalde      /** Aval de     **/
                             WITH FRAME f_garantia_avl.
                 ELSE
                     DISPLAY STREAM str_1     /*** Segundo Avalista ***/
                             rel_lblavali
                             rel_lbcotavl
                             rel_lbsldavl
                             rel_lbaplavl
                             crawepr.nmdaval2 @ crawepr.nmdaval1

                             crawepr.nrctaav2 @ crawepr.nrctaav1 
                             rel_vlaplavl
                             rel_vldendiv      /** Endividamento **/
                             rel_vlrenavl      /** Renda Mensal **/
                             rel_vldcotas      /** Cotas **/
                             rel_vlsmdsem      /** Saldo Medio **/
                             rel_dsavalde      /** Aval de     **/  
                             WITH FRAME f_garantia_avl.             
                
                 DOWN STREAM str_1 WITH FRAME f_garantia_avl .

                 /* Avalista */
                 RUN imprime-scr-consultas
                         (INPUT par_cdcooper,
                          INPUT par_cdoperad, 
                          INPUT par_nmdatela, 
                          INPUT par_idorigem, 
                          INPUT par_dtmvtolt, 
                          INPUT crapass.nrdconta,
                          INPUT crawepr.nrctremp,
                          INPUT crabass.inpessoa,
                          INPUT crabass.nrdconta,
                          INPUT crabass.nrcpfcgc,
                          INPUT aux_iddoaval,
                         OUTPUT TABLE tt-erro).
                 
                 /*** Bens do Avalista ***/
                 FOR EACH crapbem WHERE  
                                  crapbem.cdcooper = par_cdcooper     AND
                                  crapbem.nrdconta = crabass.nrdconta AND
                                  crapbem.idseqttl = 1   NO-LOCK: 
                                       
                     DISPLAY STREAM str_1 
                                crapbem.dsrelbem  crapbem.persemon 
                                crapbem.qtprebem  crapbem.vlprebem
                                crapbem.vlrdobem  
                                WITH FRAME f_garantia_bens_avl.
                    
                     DOWN STREAM str_1 WITH FRAME f_garantia_bens_avl.
                
                 END.        
            END.
           
            /***  Devolve o valor original da variavel tel_nrdconta  ***/
            /***  porque ela eh utilizada por outros programas.      ***/
            ASSIGN par_nrdconta = crapass.nrdconta 
                   rel_dsavalde = "".
                
            /*** Avalistas Terceiros ***/
            FOR EACH crapavt WHERE  crapavt.cdcooper = par_cdcooper     AND
                                    crapavt.nrdconta = crawepr.nrdconta AND
                                    crapavt.nrctremp = crawepr.nrctremp AND
                /** Emprestimo **/  crapavt.tpctrato = 1 NO-LOCK:
               
                ASSIGN flg_temavali = TRUE
                       rel_lblavali = "CPF/CNPJ"
                       rel_dsavalde = ""
                       aux_iddoaval = aux_iddoaval + 1.    
                
                EMPTY TEMP-TABLE tt-crapavl.
                      
                /********* Avais de **********/
                FOR EACH crabavt WHERE crabavt.cdcooper = par_cdcooper    AND
                                       crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                       NO-LOCK: 
                                       
                    /* Mostra as contas nos quais o avalista tambem eh aval */
                    RUN verifica-contas-avais (INPUT crabavt.nrdconta,
                                               INPUT crabavt.nrctremp,
                                               INPUT crabavt.tpctrato,
                                               INPUT par_cdcooper,
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT par_cdagenci, 
                                               INPUT par_nrdcaixa, 
                                               INPUT par_idorigem, 
                                               INPUT par_idseqttl, 
                                               INPUT par_flgerlog, 
                                               INPUT par_nmdatela).

                END.
               
                FOR EACH tt-crapavl:
                         ASSIGN rel_dsavalde = rel_dsavalde +
                                               STRING(tt-crapavl.nrdconta) + 
                                               " / ".
                END.
                  
                /** Retira a barra "/" do final da variavel **/
                rel_dsavalde = SUBSTR(rel_dsavalde,1,LENGTH(rel_dsavalde) - 2).
                 
                DISPLAY  STREAM str_1 
                         rel_lblavali
                         ""               @ rel_lbcotavl
                         ""               @ rel_lbsldavl
                         ""               @ rel_lbaplavl
                         crapavt.nmdavali @ crawepr.nmdaval1
                         crapavt.nrcpfcgc FORMAT "zzzzzzzzzzzzzz" @
                                                  crawepr.nrctaav1 
                         crapavt.vledvmto @ rel_vldendiv  /**Endividamento**/
                         crapavt.vlrenmes @ rel_vlrenavl  /** Renda Mensal **/
                         ""               @ rel_vldcotas 
                         ""               @ rel_vlsmdsem
                         ""               @ rel_vlaplavl
                         rel_dsavalde
                         WITH FRAME f_garantia_avl.                    
               
                DOWN STREAM str_1 WITH FRAME f_garantia_avl.
               
                /* Avalista */
                RUN imprime-scr-consultas (INPUT par_cdcooper,
                                           INPUT par_cdoperad, 
                                           INPUT par_nmdatela, 
                                           INPUT par_idorigem, 
                                           INPUT par_dtmvtolt, 
                                           INPUT crapass.nrdconta,
                                           INPUT crawepr.nrctremp,
                                           INPUT crapavt.inpessoa,
                                           INPUT 0,
                                           INPUT crapavt.nrcpfcgc,
                                           INPUT aux_iddoaval,
                                          OUTPUT TABLE tt-erro).

                DO  aux_contador = 1 TO 4:
                    IF  crapavt.dsrelbem[aux_contador] <> "" THEN  DO:
                       
                        DISPLAY  STREAM str_1 
                                 crapavt.dsrelbem[aux_contador] @ 
                                                 crapbem.dsrelbem
                                 crapavt.persemon[aux_contador] @ 
                                                 crapbem.persemon 
                                 crapavt.qtprebem[aux_contador] @
                                                 crapbem.qtprebem
                                 crapavt.vlprebem[aux_contador] @ 
                                                 crapbem.vlprebem
                                 crapavt.vlrdobem[aux_contador] @ 
                                                 crapbem.vlrdobem
                                 WITH FRAME f_garantia_bens_avl.
                    
                        DOWN STREAM str_1 WITH FRAME f_garantia_bens_avl.
                    END.
                END.
            END.   /** For each crapavt **/

            /*** Patrimonio Pessoal dos Garantidores/Socios ***/
            IF  crapass.inpessoa = 2 THEN 
                DO:
                    IF   crawepr.dtaltpro < 02/24/2010   THEN
                         DO:
                             FIND crapsir WHERE
                                  crapsir.cdcooper = par_cdcooper     AND
                                  crapsir.nrtopico = 5                AND
                                  crapsir.nritetop = 5                AND
                                  crapsir.nrseqite = crapprp.nrpatlvr 
                                  NO-LOCK NO-ERROR.
                     
                             IF  AVAIL crapsir THEN
                                 ASSIGN rel_ptrpesga = STRING(crapprp.nrpatlvr)
                                                       + " - " + 
                                                       crapsir.dsseqite.       
                         END.
                    ELSE
                         DO:
                             FIND craprad WHERE
                                  craprad.cdcooper = par_cdcooper  AND
                                  craprad.nrtopico = 3             AND
                                  craprad.nritetop = 9             AND
                                  craprad.nrseqite = crapprp.nrpatlvr
                                  NO-LOCK NO-ERROR.
       
                             IF   AVAIL craprad THEN
                                  ASSIGN rel_ptrpesga = STRING(crapprp.nrpatlvr)
                                                        + " - " +
                                                        craprad.dsseqite.
                         END.
                   
                     DISPLAY STREAM str_1 rel_ptrpesga 
                                          WITH FRAME f_patrimonio_socios.
                END.              
       
            IF   craplcr.tpctrato = 2    THEN  /* Alienacao */
                 DO:
                     VIEW STREAM str_1 FRAME f_alienacao.         
                 END.
            ELSE
            IF   craplcr.tpctrato = 3   THEN   /* Hipoteca */
                 DO:
                     VIEW STREAM str_1 FRAME f_hipoteca.  
                 END.
       
            IF   CAN-DO ("2,3",STRING(craplcr.tpctrato))   THEN
                 DO:
                     aux_contador = 0.  
       
                     FOR EACH crapbpr WHERE
                                      crapbpr.cdcooper = par_cdcooper     AND
                                      crapbpr.nrdconta = par_nrdconta     AND
                                      crapbpr.tpctrpro = 90               AND
                                      crapbpr.nrctrpro = crawepr.nrctremp AND
                                      crapbpr.flgalien = YES         
                                      NO-LOCK:
       
                         aux_contador = aux_contador + 1.
       
                         IF   craplcr.tpctrato = 2 AND crapbpr.dscatbem <> "MAQUINA E EQUIPAMENTO" THEN /*prj438 - Bug 13356 - Paulo Martins*/
                              DO:
                                  DISPLAY STREAM str_1 
                                       aux_contador
                                       crapbpr.dsbemfin 
                                       crapbpr.nrrenava
                                       crapbpr.dschassi
                                       crapbpr.tpchassi
                                       crapbpr.vlmerbem
                                       crapbpr.dscatbem
                                       crapbpr.ufdplaca
                                       crapbpr.nrdplaca
                                       crapbpr.uflicenc
                                       crapbpr.nranobem
                                       crapbpr.nrmodbem
                                       crapbpr.dscorbem
                                       WITH FRAME f_bem_alienacao.
       
                                  DOWN WITH FRAME f_bem_alienacao. 
                              END.
                         ELSE
                              DO:
                                IF crapbpr.dscatbem = "MAQUINA E EQUIPAMENTO" THEN
                                    DO: 
                                  DISPLAY STREAM str_1
                                               aux_contador
                                               crapbpr.dscatbem /*Categoria*/
                                               crapbpr.dschassi /*nr serie*/
                                               crapbpr.vlmerbem /*valor de mercado*/
                                               crapbpr.dsbemfin /*Modelo*/
                                               crapbpr.dsmarceq /*descrição*/
                                               crapbpr.nranobem /*Ano bem*/
                                               WITH FRAME f_bem_maqequip.

                                          DOWN WITH FRAME f_bem_maqequip. 
                                    END. 
                                ELSE
                                  DO:
                                  DISPLAY STREAM str_1
                                           aux_contador
                                           crapbpr.vlmerbem
                                           crapbpr.dscatbem
                                           crapbpr.dsbemfin
                                           crapbpr.dscorbem
                                           WITH FRAME f_bem_hipoteca.
       
                                  DOWN WITH FRAME f_bem_hipoteca.
                              END.
       
                              END.
       
                     END. /* Bens alienados */
       
                 END.
            DISPLAY STREAM str_1 WITH FRAME f_comite.                          
                                              
            IF NOT VALID-HANDLE(h-b1wgen0043) THEN
            RUN sistema/generico/procedures/b1wgen0043.p 
                PERSISTENT SET h-b1wgen0043.

            RUN ratings-impressao IN h-b1wgen0043 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_cdoperad,
                                                   INPUT par_idorigem,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT crawepr.nrdconta,
                                                   INPUT crawepr.nrctremp,
                                                   INPUT 90, /* Emprestimo */
                                                   INPUT par_inproces,
                                                  OUTPUT TABLE tt-ratings).

            IF VALID-HANDLE(h-b1wgen0043) THEN
               DELETE OBJECT h-b1wgen0043.

            /* Rating desta proposta */
            IF  par_cdcooper <> 3  THEN /* nao imprime para CECRED */
            DO:
                
                FIND tt-ratings WHERE tt-ratings.tpctrrat = 90   AND
                                      tt-ratings.nrctrrat = crawepr.nrctremp
                                      NO-LOCK NO-ERROR.
                
                IF   AVAIL tt-ratings   THEN
                     DO:
                         DISPLAY STREAM str_1 
                                        tt-ratings.dsdopera
                                        tt-ratings.nrctrrat
                                        tt-ratings.indrisco
                                        tt-ratings.nrnotrat
                                        tt-ratings.dsdrisco
                                        WITH FRAME f_rating_atual.   
                     END.
    
                IF   CAN-FIND (FIRST tt-ratings WHERE NOT 
                               (tt-ratings.tpctrrat = 90  AND
                                tt-ratings.nrctrrat = crawepr.nrctremp))   THEN
           
                     VIEW STREAM str_1 FRAME f_historico_rating_1.
           
                /* Todos os outros ratings */
                FOR EACH tt-ratings WHERE 
                                    NOT (tt-ratings.tpctrrat = 90  AND
                                         tt-ratings.nrctrrat = crawepr.nrctremp) 
                                   NO-LOCK:
           
                    DISPLAY STREAM str_1 tt-ratings.dsdopera
                                         tt-ratings.nrctrrat
                                         tt-ratings.indrisco
                                         tt-ratings.nrnotrat
                                         tt-ratings.vloperac
                                         tt-ratings.dsditrat
                                         WITH FRAME f_historico_rating_2.
           
                    DOWN WITH FRAME f_historico_rating_2.
           
                END.

                IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                   RUN sistema/generico/procedures/b1wgen0138.p
                       PERSISTENT SET h-b1wgen0138.
                       
                IF DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                  INPUT par_cdcooper, 
                                                  INPUT par_nrdconta, 
                                                 OUTPUT aux_nrdgrupo,
                                                 OUTPUT aux_gergrupo,
                                                 OUTPUT aux_dsdrisgp) THEN
                   DO:          
                     /* Procedure responsavel para calcular o risco e o endividamento do grupo */
                      RUN calc_endivid_grupo IN h-b1wgen0138
                                            (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa, 
                                             INPUT par_cdoperad, 
                                             INPUT par_dtmvtolt, 
                                             INPUT par_nmdatela, 
                                             INPUT par_idorigem, 
                                             INPUT aux_nrdgrupo, 
                                             INPUT TRUE, /*Consulta por conta*/
                                            OUTPUT aux_dsdrisco, 
                                            OUTPUT aux_vlendivi,
                                            OUTPUT TABLE tt-grupo, 
                                            OUTPUT TABLE tt-erro).
                   
                      IF VALID-HANDLE(h-b1wgen0138) THEN
                         DELETE OBJECT h-b1wgen0138.  
                       
                      IF RETURN-VALUE <> "OK" THEN
                         RETURN "NOK".

                      IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                         DO:
                            VIEW STREAM str_1 FRAME f_grupo_1.

                            FOR EACH tt-grupo NO-LOCK BY tt-grupo.cdagenci:
                            
                                DISP STREAM str_1 tt-grupo.cdagenci
                                                  tt-grupo.nrctasoc
                                                  tt-grupo.vlendivi
                                                  tt-grupo.dsdrisco
                                                  WITH FRAME f_grupo.
                            
                                DOWN WITH FRAME f_grupo.
                            
                            END.                  
                            
                            DISP STREAM str_1 aux_dsdrisco 
                                        aux_vlendivi
                                        WITH FRAME f_grupo_2.

                         END.

                   END.

                IF VALID-HANDLE(h-b1wgen0138) THEN
                   DELETE OBJECT h-b1wgen0138.

            END.
       
        END.
         
        /** Fim Emissao da Proposta **/

   /*  Emissao das Notas Promissorias ....................................  */

   IF   aux_flgimpnp AND crawepr.qtpromis <> 0 THEN
        DO:
            ASSIGN aux_contapag = 0
                   aux_nrdmeses = crawepr.qtpreemp / crawepr.qtpromis
                   aux_contames = MONTH(crawepr.dtvencto) + (aux_nrdmeses - 1)
   
                   rel_ddmvtolt = DAY(crawepr.dtvencto)
                   rel_aamvtolt = YEAR(crawepr.dtvencto)
   
                   aux_vlpreemp = IF crawepr.qtpreemp = crawepr.qtpromis
                                     THEN crawepr.vlpreemp
                                     ELSE ROUND((crawepr.vlpreemp *
                                                     crawepr.qtpreemp) /
                                                         crawepr.qtpromis,2).

            DO WHILE aux_contames > 12:
   
               ASSIGN aux_contames = aux_contames - 12
                      rel_aamvtolt = rel_aamvtolt + 1.
   
            END.  /*  Fim do DO WHILE  */

            
            PAGE STREAM str_1.

            HIDE STREAM str_1 FRAME f_cabecalho.
            HIDE STREAM str_1 FRAME f_rodape.
   
            IF  crawepr.qtpromis = 1 AND
                crawepr.qtpreemp <> 1 THEN  
                .              /* Uma unica promissoria com vencto futuro */
            ELSE
                RUN calcula_data_inicial(INPUT par_promsini,
                                         INPUT aux_nrdmeses).
                
            IF NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
                SET h-b1wgen9999.

            RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem, 
                                                 INPUT crawepr.nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT 1, 
                                                 INPUT crawepr.nrctremp, 
                                                 INPUT crawepr.nrctaav1,  
                                                 INPUT crawepr.nrctaav2,
                                                OUTPUT TABLE tt-dados-avais,
                                                OUTPUT TABLE tt-erro).
                                              
            IF VALID-HANDLE(h-b1wgen9999) THEN
               DELETE OBJECT h-b1wgen9999.
          
            IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".

            /* Carrega dados dos avalistas/fiadores */
            RUN carrega-fiadores (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT par_recidepr,
                                 OUTPUT TABLE tt-fiadores,
                                 OUTPUT TABLE tt-erro).

            IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".

            /* Avalista 1 */
            FIND tt-fiadores WHERE tt-fiadores.inavalis = 1 NO-LOCK NO-ERROR.

            IF  AVAIL tt-fiadores THEN
                DO:
                    ASSIGN aux_nmdaval1     = tt-fiadores.nmdavali
                           rel_nmdaval1     = aux_nmdaval1
                           aux_cpfaval1     = tt-fiadores.nrcpfcgc
                           rel_nmcjgav1     = tt-fiadores.nmconjug
                           rel_dsendav1[1]  = tt-fiadores.dsendres
                           rel_dsendav1[2]  = tt-fiadores.nmbairro
                           aux_cpfcgav1     = IF tt-fiadores.inpessoa = 1 
                                                THEN "CPF  " + TRIM(tt-fiadores.nrcpfcjg)
                                                ELSE "CNPJ " + TRIM(tt-fiadores.nrcpfcjg)
                           rel_dscfcav1     = tt-fiadores.nrdocava
                           rel_dsendav1[3]  = STRING(tt-fiadores.nrcepend,"99999,999") + " - " +
                                              tt-fiadores.nmcidade + "/" + tt-fiadores.cdufresd
                           rel_dscpfav1     = IF tt-fiadores.inpessoa = 1 
                                                THEN "CPF  " + TRIM(aux_cpfaval1)
                                                ELSE "CNPJ " + TRIM(aux_cpfaval1).                       

                    IF  tt-fiadores.nrcpfcjg = ""  AND
                        tt-fiadores.nmconjug = ""  THEN
                        ASSIGN rel_nmcjgav1  = FILL("_",48)
                               aux_cpfcgav1  = rel_nmcjgav1.
                END.
            ELSE
                ASSIGN aux_nmdaval1    = ""
                       aux_cpfaval1    = ""
                       rel_nmcjgav1    = FILL("_",48)
                       aux_cpfcgav1    = rel_nmcjgav1
                       rel_dsendav1[1] = FILL("_",48)
                       rel_dsendav1[2] = FILL("_",48)
                       rel_dsendav1[3] = FILL("_",48).

            /* Avalista 2 */
            FIND tt-fiadores WHERE tt-fiadores.inavalis = 2 NO-LOCK NO-ERROR.

            IF  AVAIL tt-fiadores THEN
                DO:                    
                    ASSIGN aux_nmdaval2     = tt-fiadores.nmdavali
                           rel_nmdaval2     = aux_nmdaval2
                           aux_cpfaval2     = tt-fiadores.nrcpfcgc
                           rel_nmcjgav2     = tt-fiadores.nmconjug
                           rel_dsendav2[1]  = tt-fiadores.dsendres
                           rel_dsendav2[2]  = tt-fiadores.nmbairro
                           aux_cpfcgav2     = IF tt-fiadores.inpessoa = 1 
                                                THEN "CPF  " + TRIM(tt-fiadores.nrcpfcjg)
                                                ELSE "CNPJ " + TRIM(tt-fiadores.nrcpfcjg)
                           rel_dscfcav2     = tt-fiadores.nrdocava
                           rel_dsendav2[3]  = STRING(tt-fiadores.nrcepend,"99999,999") + " - " +
                                              tt-fiadores.nmcidade + "/" + tt-fiadores.cdufresd
                           rel_dscpfav2     = IF tt-fiadores.inpessoa = 1 
                                                THEN "CPF  " + TRIM(aux_cpfaval2)
                                                ELSE "CNPJ " + TRIM(aux_cpfaval2).

                    IF  tt-fiadores.nrcpfcjg = ""  AND
                        tt-fiadores.nmconjug = ""  THEN
                        ASSIGN rel_nmcjgav2  = FILL("_",47)
                               aux_cpfcgav2  = rel_nmcjgav2.
                END.
            ELSE
                ASSIGN aux_nmdaval2    = ""
                       aux_cpfaval2    = ""
                       rel_nmcjgav2    = FILL("_",47)
                       aux_cpfcgav2    = rel_nmcjgav2
                       rel_dsendav2[1] = FILL("_",47)
                       rel_dsendav2[2] = FILL("_",47)
                       rel_dsendav2[3] = FILL("_",47).

            ASSIGN aux_nmcidade = IF AVAIL crapage THEN
                                      crapage.nmcidade
                                  ELSE 
                                      FILL("_",25).

            FIND crapenc WHERE crapenc.cdcooper = par_cdcooper      AND
                               crapenc.nrdconta = crawepr.nrdconta  AND
                               crapenc.idseqttl = 1                 AND
                               crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.


            DO aux_contador = par_promsini TO crawepr.qtpromis:
                
               ASSIGN rel_dsctremp = STRING(crawepr.nrctremp,"zz,zzz,zz9") + 
                                     "/" +
                                     STRING(aux_contador,"999")
                      rel_dscpfcgc = IF LENGTH(TRIM(rel_nrcpfcgc)) = 14 /* CPF */
                                        THEN "CPF  " + TRIM(rel_nrcpfcgc)
                                        ELSE "CNPJ " + TRIM(rel_nrcpfcgc)  
                      rel_dsendres[1] = SUBSTRING(crapenc.dsendere,1,32) + 
                                        " " +
                                        TRIM(STRING(crapenc.nrendere,"zzz,zzz" ))
                      rel_dsendres[2] = TRIM(crapenc.nmbairro) + " - " +
                                        TRIM(crapenc.nmcidade) + " - " +
                                        STRING(crapenc.nrcepend,"99,999,999")                   
                      rel_dsmesref = ENTRY(aux_contames,aux_dsmesref)
                      aux_dsemsnot = SUBSTR(aux_nmcidade,1,25) + "," + 
                                     STRING(DAY(par_dtmvtolt),"99") + " de " +
                                     ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) +
                                     " de " +
                                     STRING(YEAR(par_dtmvtolt),"9999")
                      aux_dtvencto = DATE(aux_contames,rel_ddmvtolt,rel_aamvtolt).
                      
               IF   LENGTH(aux_dsemsnot) < 45   THEN
                    aux_dsemsnot = FILL(" ",45 - LENGTH(aux_dsemsnot)) +
                                   aux_dsemsnot.

               IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                  RUN sistema/generico/procedures/b1wgen9999.p 
                      PERSISTENT SET h-b1wgen9999.

               IF   DAY(aux_dtvencto) > 1   THEN
                    DO:
                       
                       IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                           DO:
                               ASSIGN aux_dscritic = "Handle invalido para " +
                                                     "BO b1wgen9999.".
                                       
                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT 1,  /** Sequencia **/
                                              INPUT aux_cdcritic,
                                              INPUT-OUTPUT aux_dscritic).
                         
                               RETURN "NOK".
                           END.
                    
                       RUN valor-extenso IN h-b1wgen9999 
                                            (INPUT DAY(aux_dtvencto), 
                                             INPUT 50,              
                                             INPUT 50, 
                                             INPUT "I",                  
                                             OUTPUT aux_dsextens, 
                                             OUTPUT aux_dsbranco).    

                        aux_dsextens = aux_dsextens + " DIAS DO MES DE " + 
                              CAPS(ENTRY(MONTH(aux_dtvencto),aux_dsmesref)) +
                              " DE ".
   
                        RUN valor-extenso IN h-b1wgen9999 
                                             (INPUT YEAR(aux_dtvencto),        
                                              INPUT 68 - LENGTH(aux_dsextens), 
                                              INPUT 44,                        
                                              INPUT "I",                       
                                              OUTPUT rel_dsmvtolt[1],          
                                              OUTPUT rel_dsmvtolt[2]).         
   
                        ASSIGN rel_dsmvtolt[1] = aux_dsextens + 
                                                 rel_dsmvtolt[1] + FILL("*",50)
                               rel_dsmvtolt[2] = rel_dsmvtolt[2] + 
                                                 FILL("*",50).
                    END.
               ELSE
                    DO:
                        aux_dsextens = "PRIMEIRO DIA DO MES DE " +
                                CAPS(ENTRY(MONTH(aux_dtvencto),aux_dsmesref)) +
                                " DE ".

                       RUN valor-extenso IN h-b1wgen9999 
                                            (INPUT YEAR(aux_dtvencto),        
                                             INPUT 68 - LENGTH(aux_dsextens), 
                                             INPUT 44,                        
                                             INPUT "I",                        
                                             OUTPUT rel_dsmvtolt[1],          
                                             OUTPUT rel_dsmvtolt[2]).          
   
                        ASSIGN rel_dsmvtolt[1] = aux_dsextens + 
                                                 rel_dsmvtolt[1] + FILL("*",50)
                               rel_dsmvtolt[2] = rel_dsmvtolt[2] + 
                                                 FILL("*",50).
                    END.

               
               RUN valor-extenso IN h-b1wgen9999 (INPUT aux_vlpreemp, 
                                                  INPUT 45,
                                                  INPUT 73, 
                                                  INPUT "M",         
                                                  OUTPUT rel_dspreemp[1],      
                                                  OUTPUT rel_dspreemp[2]).     
                                                 
               IF VALID-HANDLE(h-b1wgen9999) THEN
                  DELETE OBJECT h-b1wgen9999.

               ASSIGN rel_dspreemp[1] = "(" + rel_dspreemp[1]
                      rel_dspreemp[2] = rel_dspreemp[2] + ")".

               IF   crawepr.qtpromis = 1  THEN
                    DO:
                        ASSIGN aux_vencimto = "NA APRESENTACAO".
                        DISPLAY STREAM str_1
                            aux_vencimto     rel_dsctremp    crapcop.nmrescop
                            crapcop.nmextcop rel_nrdocnpj    rel_dspreemp[1]
                            rel_dspreemp[2]  rel_dsdmoeda[1] aux_vlpreemp
                            WITH FRAME f_cab2_promissoria.
                    END.
               ELSE
                    DO:
                        ASSIGN aux_vencimto = "Vencimento: " + 
                                      STRING(rel_ddmvtolt,"99") + " de " + 
                                      STRING(rel_dsmesref,"x(9)") + " de "
                                      + STRING(rel_aamvtolt,"9999").
                        DISPLAY STREAM str_1 
                             aux_vencimto    rel_dsctremp     rel_dsmvtolt[1]
                             rel_dsmvtolt[2] crapcop.nmrescop crapcop.nmextcop
                             rel_nrdocnpj    rel_dspreemp[1]  rel_dspreemp[2]
                             rel_dsdmoeda[1]  aux_vlpreemp
                             WITH FRAME f_cab1_promissoria.
                    END.

               DISPLAY STREAM str_1
                       aux_dsemsnot   
                       rel_nmprimtl[1]  rel_dscpfcgc     rel_nrdconta
                       rel_dsendres[1]  rel_dsendres[2]  rel_nmdaval1     
                       rel_nmdaval2     rel_dscpfav1     rel_dscpfav2     
                       aux_cpfcgav1     aux_cpfcgav2     
                       rel_dsendav1[1]  rel_dsendav2[1]  rel_dsendav1[2]  
                       rel_dsendav2[2]  rel_dsendav1[3]  rel_dsendav2[3]
                       rel_nmcjgav1     rel_nmcjgav2     WITH FRAME f_promissoria.
   
               DOWN STREAM str_1 WITH FRAME f_promissoria.

               aux_contapag = aux_contapag + 1.
   
               IF   aux_contapag = 2   THEN
                    DO:
                        IF   aux_contador <> crawepr.qtpromis   THEN
                             DO:
                                 PAGE STREAM str_1.
   
                                 PUT STREAM str_1 CONTROL
                                            "\0330\033x0\022\033\120" NULL.
                             END.
   
                        aux_contapag = 0.
                    END.
               ELSE
                    VIEW STREAM str_1 FRAME f_linhas.
   
               aux_contames = aux_contames + aux_nrdmeses.

               DO WHILE aux_contames > 12:
   
                  ASSIGN aux_contames = aux_contames - 12
                         rel_aamvtolt = rel_aamvtolt + 1.
   
               END.  /*  Fim do DO WHILE  */

            END.  /*  Fim do DO .. TO  */

        END.

        OUTPUT STREAM str_1 CLOSE.
        
   RETURN "OK".

END PROCEDURE.


PROCEDURE calcula_data_inicial:

   DEF INPUT PARAM par_promsini AS INTE                 NO-UNDO.
   DEF INPUT PARAM aux_nrdmeses AS INTE                 NO-UNDO.

   DEF VAR i_mes AS INTE                                NO-UNDO.

   ASSIGN i_mes = 1.

   /*---- Vencimentos a finais de cada promissoria---------------
   ASSIGN aux_contames = MONTH(crawepr.dtvencto).
   ASSIGN rel_aamvtolt = YEAR(crawepr.dtvencto).
   ---------------------------------------------------------*/
   DO WHILE i_mes LT par_promsini:
      ASSIGN i_mes = i_mes + 1
             aux_contames = aux_contames + aux_nrdmeses.
      IF  aux_contames > 12 THEN
          ASSIGN rel_aamvtolt = rel_aamvtolt + 1
                 aux_contames = aux_contames - 12.
   END.
 
END PROCEDURE.



PROCEDURE busca_operacoes:

   DEF INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_vldscchq AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_vlutlchq AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
   DEF INPUT PARAM par_vldctitu AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_vlutitit AS DECI                             NO-UNDO.
   DEF INPUT-OUTPUT PARAM TABLE FOR w-co-responsavel.
      
   DEF VAR xml_req      AS CHAR                                      NO-UNDO.
   DEF VAR xDoc         AS HANDLE                                    NO-UNDO.  
   DEF VAR xRoot        AS HANDLE                                    NO-UNDO. 
   DEF VAR xRoot2       AS HANDLE                                    NO-UNDO. 
   DEF VAR xRoot3       AS HANDLE                                    NO-UNDO. 
   DEF VAR xRoot4       AS HANDLE                                    NO-UNDO. 
   DEF VAR xText        AS HANDLE                                    NO-UNDO.
   DEF VAR xField       AS HANDLE                                    NO-UNDO.
   DEF VAR ponteiro_xml AS MEMPTR                                    NO-UNDO.
   DEF VAR aux_cont_raiz AS INTEGER                                     NO-UNDO. 
   DEF VAR aux_cont      AS INTEGER                                     NO-UNDO. 
   

   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
   
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_busca_operacoes_prog
     aux_handproc = PROC-HANDLE NO-ERROR 
                 ( INPUT par_cdcooper        /* pr_cdcooper --> Codigo da cooperativa  */
                  ,INPUT par_nrdconta        /* pr_nrdconta --> Numero da conta        */
                  ,INPUT par_dtmvtolt        /* pr_dtmvtolt --> Data de movimento      */
                  ,INPUT-OUTPUT par_vldscchq /* pr_vldscchq --> Valor de cheque        */  
                  ,INPUT-OUTPUT par_vlutlchq /* pr_vlutlchq --> Valor do ultimo cheque */                              
                  ,INPUT-OUTPUT par_vldctitu /* pr_vldctitu --> Valor de titulo de descont */
                  ,INPUT-OUTPUT par_vlutitit /* pr_vlutitit --> Valor do ultimo titulo de desconto */                  
                  /* --------- OUT --------- */
                  ,OUTPUT ""       /* pr_xml      --> Retorna dados        */
                  ,OUTPUT ""       /* pr_dscritic --> Descriçao da critica */
                  ,OUTPUT 0).      /* pr_cdcritic --> Codigo da critica    */
             

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_busca_operacoes_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                        
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
             
    /* Rotina original nao trata critica */
    ASSIGN aux_cdcritic = pc_busca_operacoes_prog.pr_cdcritic
                             WHEN pc_busca_operacoes_prog.pr_cdcritic <> ?
           aux_dscritic = pc_busca_operacoes_prog.pr_dscritic
                             WHEN pc_busca_operacoes_prog.pr_dscritic <> ?.
                        
   
     ASSIGN par_vldscchq = pc_busca_operacoes_prog.pr_vldscchq
                             WHEN pc_busca_operacoes_prog.pr_vldscchq <> ?
            par_vlutlchq = pc_busca_operacoes_prog.pr_vlutlchq
                             WHEN pc_busca_operacoes_prog.pr_vlutlchq <> ?
            par_vldctitu = pc_busca_operacoes_prog.pr_vldctitu
                             WHEN pc_busca_operacoes_prog.pr_vldctitu <> ?
            par_vlutitit = pc_busca_operacoes_prog.pr_vlutitit
                             WHEN pc_busca_operacoes_prog.pr_vlutitit <> ?.
             
    /*Leitura do XML de retorno da proc e criacao dos registros na w-co-responsavel */
              
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_busca_operacoes_prog.pr_xml_co_responsavel. 
     
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
                        CREATE w-co-responsavel.

                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).

                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField:GET-CHILD(xText,1) NO-ERROR. 

                    /* Se nao vier conteudo na TAG */ 
                    IF ERROR-STATUS:ERROR             OR  
                       ERROR-STATUS:NUM-MESSAGES > 0  THEN
                                     NEXT.

                    ASSIGN w-co-responsavel.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta". 
                    ASSIGN w-co-responsavel.nrctremp = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrctremp". 
                    ASSIGN w-co-responsavel.vlsdeved = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdeved". 
                    ASSIGN w-co-responsavel.dsfinemp =    (xText:NODE-VALUE) WHEN xField:NAME = "dsfinemp". 
                    ASSIGN w-co-responsavel.dslcremp =    (xText:NODE-VALUE) WHEN xField:NAME = "dslcremp". 

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
         
END PROCEDURE.


PROCEDURE gera_co_responsavel:

   DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_dtcalcul AS DATE                             NO-UNDO.
   DEF INPUT PARAM par_vldscchq AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_vlutlchq AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
   DEF INPUT PARAM par_vldctitu AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_vlutitit AS DECI                             NO-UNDO.
   DEF INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.
   DEF INPUT PARAM par_cdprogra AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_inproces AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
   DEF INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.

   DEF OUTPUT PARAM TABLE FOR tt-erro.
   DEF OUTPUT PARAM TABLE FOR w-co-responsavel.

   DEF VAR xml_req      AS LONGCHAR                                  NO-UNDO.
   DEF VAR xDoc         AS HANDLE                                    NO-UNDO.  
   DEF VAR xRoot        AS HANDLE                                    NO-UNDO. 
   DEF VAR xRoot2       AS HANDLE                                    NO-UNDO. 
   DEF VAR xRoot3       AS HANDLE                                    NO-UNDO. 
   DEF VAR xRoot4       AS HANDLE                                    NO-UNDO. 
   DEF VAR xText        AS HANDLE                                    NO-UNDO.
   DEF VAR xField       AS HANDLE                                    NO-UNDO.
   DEF VAR ponteiro_xml AS MEMPTR                                    NO-UNDO.
   DEF VAR aux_cont_raiz AS INTEGER                                     NO-UNDO. 
   DEF VAR aux_cont      AS INTEGER                                     NO-UNDO. 

 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_gera_co_responsavel_prog 
     aux_handproc = PROC-HANDLE NO-ERROR 
                 ( INPUT par_cdcooper /* pr_cdcooper -> Codigo da cooperativa */
                  ,INPUT par_cdagenci /* pr_cdagenci -> Codigo de agencia */
                  ,INPUT par_nrdcaixa /* pr_nrdcaixa -> Numero do caixa */
                  ,INPUT par_cdoperad /* pr_cdoperad -> Codigo do operador */
                  ,INPUT par_nmdatela /* pr_nmdatela -> Nome da tela */
                  ,INPUT par_idorigem /* pr_idorigem -> Identificado de oriem */
                  ,INPUT par_cdprogra /* pr_cdprogra -> Codigo do programa */
                  ,INPUT crapass.nrdconta /* pr_nrdconta -> Numero da conta */
                  ,INPUT par_idseqttl /* pr_idseqttl -> Sequencial do titular */
                  ,INPUT par_dtcalcul /* pr_dtcalcul -> Data do calculo       */                                                    
                  ,INPUT (IF par_flgerlog THEN  "S" ELSE "N") /* pr_flgerlog -> identificador se deve gerar log S-Sim e N-Nao */
                  ,INPUT-OUTPUT par_vldscchq /* pr_vldscchq -> Valor de cheque */
                  ,INPUT-OUTPUT par_vlutlchq /* pr_vlutlchq -> Valor do ultimo cheque                        */
                  ,INPUT-OUTPUT par_vldctitu /* pr_vldctitu -> Valor de titulo de descont */ 
                  ,INPUT-OUTPUT par_vlutitit /* pr_vlutitit -> Valor do ultimo titulo de desconto */                  
                  /* --------- OUT --------- */
                  ,OUTPUT ""       /* pr_xml      --> Retorna dados        */
                  ,OUTPUT ""       /* pr_dscritic --> Descriçao da critica */
                  ,OUTPUT 0).      /* pr_cdcritic --> Codigo da critica    */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_gera_co_responsavel_prog
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                                   
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = pc_gera_co_responsavel_prog.pr_cdcritic
                             WHEN pc_gera_co_responsavel_prog.pr_cdcritic <> ?
           aux_dscritic = pc_gera_co_responsavel_prog.pr_dscritic
                             WHEN pc_gera_co_responsavel_prog.pr_dscritic <> ?.


    IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
                     DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic). 
          RETURN "NOK".
                     END.
                
     ASSIGN par_vldscchq = pc_gera_co_responsavel_prog.pr_vldscchq
                             WHEN pc_gera_co_responsavel_prog.pr_vldscchq <> ?
            par_vlutlchq = pc_gera_co_responsavel_prog.pr_vlutlchq
                             WHEN pc_gera_co_responsavel_prog.pr_vlutlchq <> ?
            par_vldctitu = pc_gera_co_responsavel_prog.pr_vldctitu
                             WHEN pc_gera_co_responsavel_prog.pr_vldctitu <> ?
            par_vlutitit = pc_gera_co_responsavel_prog.pr_vlutitit
                             WHEN pc_gera_co_responsavel_prog.pr_vlutitit <> ?. 


    /*Leitura do XML de retorno da proc e criacao dos registros na w-co-responsavel */
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_gera_co_responsavel_prog.pr_xml_co_responsavel. 

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
                            CREATE w-co-responsavel.

                DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                    xRoot2:GET-CHILD(xField,aux_cont).

                    IF xField:SUBTYPE <> "ELEMENT" THEN 
                        NEXT. 

                    xField:GET-CHILD(xText,1) NO-ERROR. 
                    /* Se nao vier conteudo na TAG */ 
                    IF ERROR-STATUS:ERROR             OR  
                       ERROR-STATUS:NUM-MESSAGES > 0  THEN
                                     NEXT.
                                     
                    ASSIGN w-co-responsavel.nrdconta = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdconta". 
                    ASSIGN w-co-responsavel.cdagenci = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdagenci". 
                    ASSIGN w-co-responsavel.nmprimtl =    (xText:NODE-VALUE) WHEN xField:NAME = "nmprimtl". 
                    ASSIGN w-co-responsavel.nrctremp = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrctremp". 
                    ASSIGN w-co-responsavel.vlemprst = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlemprst".
                    ASSIGN w-co-responsavel.vlsdeved = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdeved".
                    ASSIGN w-co-responsavel.vlpreemp = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlpreemp".
                    ASSIGN w-co-responsavel.vlprepag = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlprepag".
                    ASSIGN w-co-responsavel.vljurmes = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vljurmes".
                    ASSIGN w-co-responsavel.vljuracu = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vljuracu".
                    ASSIGN w-co-responsavel.vlprejuz = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlprejuz".
                    ASSIGN w-co-responsavel.vlsdprej = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdprej".
                    ASSIGN w-co-responsavel.dtprejuz = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtprejuz".
                    ASSIGN w-co-responsavel.vljrmprj = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vljrmprj".
                    ASSIGN w-co-responsavel.vljraprj = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vljraprj". 
                    ASSIGN w-co-responsavel.inprejuz = INT(xText:NODE-VALUE) WHEN xField:NAME = "inprejuz".
                    ASSIGN w-co-responsavel.vlprovis = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlprovis". 
                    ASSIGN w-co-responsavel.flgpagto = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flgpagto". 
                    ASSIGN w-co-responsavel.dtdpagto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtdpagto".
                    ASSIGN w-co-responsavel.cdpesqui =    (xText:NODE-VALUE) WHEN xField:NAME = "cdpesqui". 
                    ASSIGN w-co-responsavel.dspreapg =    (xText:NODE-VALUE) WHEN xField:NAME = "dspreapg". 
                    ASSIGN w-co-responsavel.cdlcremp = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdlcremp". 
                    ASSIGN w-co-responsavel.dslcremp =    (xText:NODE-VALUE) WHEN xField:NAME = "dslcremp". 
                    ASSIGN w-co-responsavel.cdfinemp = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdfinemp". 
                    ASSIGN w-co-responsavel.dsfinemp =    (xText:NODE-VALUE) WHEN xField:NAME = "dsfinemp". 
                    ASSIGN w-co-responsavel.dsdaval1 =    (xText:NODE-VALUE) WHEN xField:NAME = "dsdaval1". 
                    ASSIGN w-co-responsavel.dsdaval2 =    (xText:NODE-VALUE) WHEN xField:NAME = "dsdaval2". 
                    ASSIGN w-co-responsavel.vlpreapg = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlpreapg". 
                    ASSIGN w-co-responsavel.qtmesdec = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtmesdec". 
                    ASSIGN w-co-responsavel.qtprecal = DECI(xText:NODE-VALUE) WHEN xField:NAME = "qtprecal". 
                    ASSIGN w-co-responsavel.vlacresc = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlacresc". 
                    ASSIGN w-co-responsavel.vlrpagos = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlrpagos". 
                    ASSIGN w-co-responsavel.slprjori = DECI(xText:NODE-VALUE) WHEN xField:NAME = "slprjori". 
                    ASSIGN w-co-responsavel.dtmvtolt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtmvtolt".
                    ASSIGN w-co-responsavel.qtpreemp = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtpreemp". 
                    ASSIGN w-co-responsavel.dtultpag = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtultpag".
                    ASSIGN w-co-responsavel.vlrabono = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlrabono". 
                    ASSIGN w-co-responsavel.qtaditiv = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtaditiv". 
                    ASSIGN w-co-responsavel.dsdpagto =    (xText:NODE-VALUE) WHEN xField:NAME = "dsdpagto". 
                    ASSIGN w-co-responsavel.dsdavali =    (xText:NODE-VALUE) WHEN xField:NAME = "dsdavali". 
                    ASSIGN w-co-responsavel.qtmesatr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "qtmesatr". 
                    ASSIGN w-co-responsavel.qtpromis = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtpromis". 
                    ASSIGN w-co-responsavel.flgimppr = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flgimppr". 
                    ASSIGN w-co-responsavel.flgimpnp = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flgimpnp". 
                    ASSIGN w-co-responsavel.idseleca =    (xText:NODE-VALUE) WHEN xField:NAME = "idseleca". 
                    ASSIGN w-co-responsavel.nrdrecid = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdrecid". 
                    ASSIGN w-co-responsavel.tplcremp = INT(xText:NODE-VALUE) WHEN xField:NAME = "tplcremp". 
                    ASSIGN w-co-responsavel.tpemprst = INT(xText:NODE-VALUE) WHEN xField:NAME = "tpemprst". 
                    ASSIGN w-co-responsavel.cdtpempr =    (xText:NODE-VALUE) WHEN xField:NAME = "cdtpempr". 
                    ASSIGN w-co-responsavel.dstpempr =    (xText:NODE-VALUE) WHEN xField:NAME = "dstpempr". 
                    ASSIGN w-co-responsavel.permulta = DECI(xText:NODE-VALUE) WHEN xField:NAME = "permulta". 
                    ASSIGN w-co-responsavel.perjurmo = DECI(xText:NODE-VALUE) WHEN xField:NAME = "perjurmo".                     
                    ASSIGN w-co-responsavel.dtpripgt = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtpripgt".
                    ASSIGN w-co-responsavel.inliquid = INT(xText:NODE-VALUE) WHEN xField:NAME = "inliquid". 
                    ASSIGN w-co-responsavel.txmensal = DECI(xText:NODE-VALUE) WHEN xField:NAME = "txmensal".
                    ASSIGN w-co-responsavel.flgatras = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flgatras". 
                    ASSIGN w-co-responsavel.dsidenti =    (xText:NODE-VALUE) WHEN xField:NAME = "dsidenti". 
                    ASSIGN w-co-responsavel.flgdigit = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flgdigit". 
                    ASSIGN w-co-responsavel.tpdocged = INT(xText:NODE-VALUE) WHEN xField:NAME = "tpdocged".
                    ASSIGN w-co-responsavel.qtlemcal = DECI(xText:NODE-VALUE) WHEN xField:NAME = "qtlemcal".                     
                    ASSIGN w-co-responsavel.vlmrapar = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlmrapar".                     
                    ASSIGN w-co-responsavel.vlmtapar = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlmtapar".                     
                    ASSIGN w-co-responsavel.vltotpag = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vltotpag".                     
                    ASSIGN w-co-responsavel.vlprvenc = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlprvenc".                     
                    ASSIGN w-co-responsavel.vlpraven = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlpraven". 
                    ASSIGN w-co-responsavel.flgpreap = LOGICAL(xText:NODE-VALUE) WHEN xField:NAME = "flgpreap".                     
                    ASSIGN w-co-responsavel.vlttmupr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlttmupr".                     
                    ASSIGN w-co-responsavel.vlttjmpr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlttjmpr".                     
                    ASSIGN w-co-responsavel.vlpgmupr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlpgmupr".                     
                    ASSIGN w-co-responsavel.vlpgjmpr = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlpgjmpr".                     
                    ASSIGN w-co-responsavel.vlsdpjtl = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlsdpjtl".  
                    ASSIGN w-co-responsavel.cdorigem = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdorigem".
                    ASSIGN w-co-responsavel.nrseqrrq = INT(xText:NODE-VALUE) WHEN xField:NAME = "nrseqrrq".
                    ASSIGN w-co-responsavel.portabil =    (xText:NODE-VALUE) WHEN xField:NAME = "portabil". 
                    ASSIGN w-co-responsavel.liquidia = INT(xText:NODE-VALUE) WHEN xField:NAME = "liquidia".
                    ASSIGN w-co-responsavel.tipoempr =    (xText:NODE-VALUE) WHEN xField:NAME = "tipoempr". 
                    ASSIGN w-co-responsavel.qtimpctr = INT(xText:NODE-VALUE) WHEN xField:NAME = "qtimpctr". 
                    ASSIGN w-co-responsavel.dtapgoib = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtapgoib".
                    
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



END PROCEDURE.



PROCEDURE lista-avalistas:
    
   DEF INPUT  PARAM aux_tpctrato    AS INTE                         NO-UNDO. 
   DEF INPUT  PARAM aux_nrctrato    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM aux_nrctaav1    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM aux_nrctaav2    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM par_cdcooper    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM par_cdoperad    AS CHAR                         NO-UNDO.
   DEF INPUT  PARAM par_cdagenci    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM par_idorigem    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM par_idseqttl    AS INTE                         NO-UNDO.
   DEF INPUT  PARAM par_nmdatela    AS CHAR                         NO-UNDO.
   DEF INPUT  PARAM par_nrdconta    AS INTE                         NO-UNDO.
   DEF OUTPUT PARAM aux_dsavali1    AS CHAR                         NO-UNDO.
   DEF OUTPUT PARAM aux_dsavali2    AS CHAR                         NO-UNDO.
   DEF OUTPUT PARAM TABLE FOR tt-erro.

   RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

   RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nmdatela,
                                        INPUT par_idorigem, 
                                        INPUT par_nrdconta,
                                        INPUT par_idseqttl,
                                        INPUT aux_tpctrato, 
                                        INPUT aux_nrctrato, 
                                        INPUT aux_nrctaav1,  
                                        INPUT aux_nrctaav2,
                                       OUTPUT TABLE tt-dados-avais,
                                       OUTPUT TABLE tt-erro).
                                     
   DELETE PROCEDURE h-b1wgen9999.

   IF  RETURN-VALUE <> "OK"  THEN
       RETURN "NOK".

   FOR EACH tt-dados-avais:
       IF  tt-dados-avais.nrctaava = 0 THEN
           DO:
               IF  aux_dsavali1 =  ""  THEN
                   aux_dsavali1 =  STRING(tt-dados-avais.nrcpfcgc) + " - " +
                                   tt-dados-avais.nmdavali.
               ELSE
                   aux_dsavali2 =  STRING(tt-dados-avais.nrcpfcgc) + " - " +
                                   tt-dados-avais.nmdavali.
           END.
       ELSE    
           DO:
               IF  aux_dsavali1 =  ""  THEN
                   aux_dsavali1 =  STRING(tt-dados-avais.nrctaava) + " - " +
                                   tt-dados-avais.nmdavali.
               ELSE
                   aux_dsavali2 =  STRING(tt-dados-avais.nrctaava) + " - " +
                                   tt-dados-avais.nmdavali. 
           END.
   END.

   RETURN "OK".
         
END PROCEDURE.


PROCEDURE verifica-contas-avais:

   DEF INPUT PARAM aux_nrctaavd LIKE crapavl.nrctaavd.
   DEF INPUT PARAM aux_nrctravd LIKE crapavl.nrctravd.
   DEF INPUT PARAM aux_tpctrato LIKE crapavl.tpctrato.
   DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
   DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
   DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
   DEF INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
   DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.

   /** Desconsidera se a conta e o contrato forrm os mesmos da proposta **/
   IF  aux_nrctaavd = crapass.nrdconta AND 
       aux_nrctravd = crawepr.nrctremp THEN   
       NEXT.   
                 
   FIND tt-crapavl WHERE tt-crapavl.nrdconta = aux_nrctaavd  NO-ERROR.
                 
   /*** Se ja existir conta avalisada vai pro proximo ***/
   IF  AVAIL tt-crapavl THEN 
       NEXT.
   
   /*** Emprestimo ***/
   IF  aux_tpctrato = 1 THEN
       DO:
           /*** Se emprestimo for liquidado nao mostra ***/
           FIND crapepr WHERE 
                        crapepr.cdcooper = par_cdcooper     AND
                        crapepr.nrdconta = aux_nrctaavd AND
                        crapepr.nrctremp = aux_nrctravd AND
                        crapepr.inprejuz = 0                AND
                        crapepr.inliquid <> 0 NO-LOCK NO-ERROR.
           IF  AVAIL crapepr THEN
               NEXT.
       END.                   
                 
   /**** Cheque Especial ****/
   IF  aux_tpctrato = 3  THEN 
       DO:
           FIND craplim WHERE 
                        craplim.cdcooper = par_cdcooper        AND
                        craplim.nrdconta = aux_nrctaavd    AND
                        craplim.tpctrlim = 1                   AND
                        craplim.nrctrlim = aux_nrctravd    AND
                        craplim.insitlim <> 2           
                        USE-INDEX craplim1 NO-LOCK NO-ERROR.

           IF   AVAIL craplim THEN
                NEXT.
       END.
                 
   /*** Cartao de Credito ***/     
   IF  aux_tpctrato = 4 THEN
       DO:
           FIND crawcrd WHERE    crawcrd.cdcooper = par_cdcooper     AND
                                 crawcrd.nrdconta = aux_nrctaavd AND
                                 crawcrd.nrctrcrd = aux_nrctravd
                                 NO-LOCK NO-ERROR.
                          
           IF   AVAIL crawcrd THEN
                IF   crawcrd.insitcrd <> 4 THEN 
                     NEXT.
       END.
                
   /*** Desconto de Cheque e Desconto de Titulos ***/
   RUN sistema/generico/procedures/b1wgen0030.p 
       PERSISTENT SET h-b1wgen0030.
                 
   RUN busca_total_descontos IN h-b1wgen0030 (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_cdoperad,
                                              INPUT par_dtmvtolt,
                                              INPUT aux_nrctaavd,
                                              INPUT par_idseqttl,
                                              INPUT par_idorigem,
                                              INPUT par_nmdatela,
                                              INPUT par_flgerlog,
                                             OUTPUT TABLE tt-tot_descontos).

   FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

   IF  AVAILABLE tt-tot_descontos  THEN
       DO: 
           /** Desconto de Cheques **/
           IF  aux_tpctrato = 2 THEN
               IF  tt-tot_descontos.vldscchq = 0 THEN
                   NEXT.
               ELSE   
           /** Desconto de Titulos **/
           IF  aux_tpctrato = 8 THEN
               IF  tt-tot_descontos.vldsctit = 0 THEN
                   NEXT.
       END.              
                                   
   DELETE PROCEDURE h-b1wgen0030.
                 
   CREATE tt-crapavl.
   ASSIGN tt-crapavl.nrdconta = aux_nrctaavd.

END.

/**********************************************************************/
/**        Procedure para calcular aplicacoes do avalista            **/
/**********************************************************************/
PROCEDURE calcula-apl-aval:

   DEF INPUT  PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF INPUT  PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF INPUT  PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF INPUT  PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF INPUT  PARAM par_nrdconta AS INTE                           NO-UNDO.
   DEF INPUT  PARAM par_idorigem AS INTE                           NO-UNDO.
  
   DEF INPUT  PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   DEF INPUT  PARAM par_dtmvtopr AS DATE                           NO-UNDO.
   DEF INPUT  PARAM par_inproces AS INTE                           NO-UNDO.
   DEF INPUT  PARAM par_idseqttl AS INTE                           NO-UNDO.
   DEF INPUT  PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF INPUT  PARAM par_flgerlog AS LOGI                           NO-UNDO.
   DEF INPUT  PARAM par_cdprogra AS CHAR                           NO-UNDO.

   DEF OUTPUT PARAM par_vltotapl AS DECI                           NO-UNDO.
   DEF OUTPUT PARAM par_vltotrpp AS DECI                           NO-UNDO.
   
   DEF OUTPUT PARAM TABLE FOR tt-erro.

        /* NOVOS PRODUTOS DE CAPTACAO */   
    /** Saldo das aplicacoes **/
   RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
       SET h-b1wgen0081.

   IF  VALID-HANDLE(h-b1wgen0081)  THEN
       DO:
           ASSIGN aux_vlsldtot = 0.
    
    
           RUN obtem-dados-aplicacoes IN h-b1wgen0081 
                                         (INPUT par_cdcooper, 
                                          INPUT par_cdagenci, 
                                          INPUT par_nrdcaixa, 
                                          INPUT par_cdoperad, 
                                          INPUT par_nmdatela, 
                                          INPUT par_idorigem, 
                                          INPUT par_nrdconta, 
                                          INPUT par_idseqttl, 
                                          INPUT 0, 
                                          INPUT par_cdprogra, 
                                          INPUT par_flgerlog,
                                          INPUT ?,
                                          INPUT ?,
                                         OUTPUT par_vltotapl, 
                                         OUTPUT TABLE tt-saldo-rdca,
                                         OUTPUT TABLE tt-erro).

           IF  RETURN-VALUE = "NOK"  THEN
               DO:
                           DELETE PROCEDURE h-b1wgen0081.
           
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                   IF  AVAILABLE tt-erro  THEN
                       MESSAGE tt-erro.dscritic.
                   ELSE
                       MESSAGE "Erro nos dados das aplicacoes.".
    
                   NEXT.
               END.
    
           DELETE PROCEDURE h-b1wgen0081.
       END.
    
      DO TRANSACTION ON ERROR UNDO, RETRY:
        /*Busca Saldo Novas Aplicacoes*/
    
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
         RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
           aux_handproc = PROC-HANDLE NO-ERROR
                                   (INPUT par_cdcooper, /* Código da Cooperativa */
                                    INPUT '1',            /* Código do Operador */
                                    INPUT par_nmdatela, /* Nome da Tela */
                                    INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
                                    INPUT par_nrdconta, /* Número da Conta */
                                    INPUT 1,            /* Titular da Conta */
                                    INPUT 0,            /* Número da Aplicaçao / Parâmetro Opcional */
                                    INPUT par_dtmvtolt, /* Data de Movimento */
                                    INPUT 0,            /* Código do Produto */
                                    INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
                                    INPUT 0,            /* Identificador de Log (0 – Nao / 1 – Sim) */
                                   OUTPUT 0,            /* Saldo Total da Aplicaçao */
                                   OUTPUT 0,            /* Saldo Total para Resgate */
                                   OUTPUT 0,            /* Código da crítica */
                                   OUTPUT "").          /* Descriçao da crítica */
    
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
    
         IF aux_cdcritic <> 0   OR
            aux_dscritic <> ""  THEN
            DO:
                IF aux_dscritic = "" THEN
                   DO:
                      FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
                                         NO-LOCK NO-ERROR.
    
                      IF AVAIL crapcri THEN
                         ASSIGN aux_dscritic = crapcri.dscritic.
    
                   END.
    
                CREATE tt-erro.
    
                ASSIGN tt-erro.cdcritic = aux_cdcritic
                       tt-erro.dscritic = aux_dscritic.
    
               RETURN "NOK".
               END.

        ASSIGN par_vltotapl = aux_vlsldrgt + par_vltotapl.
    END.
    /*Fim Busca Saldo Novas Aplicacoes*/
        
           
   /** Saldo de poupanca programada **/
   RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
       SET h-b1wgen0006.

   IF  VALID-HANDLE(h-b1wgen0006)  THEN
       DO:                      
           RUN consulta-poupanca IN h-b1wgen0006 
                                   (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem,
                                    INPUT par_nrdconta,
                                    INPUT par_idseqttl,
                                    INPUT 0,
                                    INPUT par_dtmvtolt,
                                    INPUT par_dtmvtopr,
                                    INPUT par_inproces,
                                    INPUT par_nmdatela,
                                    INPUT FALSE,
                                   OUTPUT par_vltotrpp,
                                   OUTPUT TABLE tt-erro,
                                   OUTPUT TABLE tt-dados-rpp). 
                                  
           DELETE PROCEDURE h-b1wgen0006.
           
           IF  RETURN-VALUE <> "OK"  THEN
               RETURN "NOK".
       END.

   RETURN "OK".

END PROCEDURE.

/*****************************************************************************
               Divide o campo crapcop.nmextcop em duas Strings
 *****************************************************************************/
PROCEDURE p_divinome:

   DEF VAR aux_qtpalavr AS INTE                                  NO-UNDO.
   DEF VAR aux_contapal AS INT                                   NO-UNDO.
   
   ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
                         rel_nmrescop = "".
   
   DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
      IF   aux_contapal <= aux_qtpalavr   THEN
           rel_nmrescop[1] = rel_nmrescop[1] +   
                       (IF TRIM(rel_nmrescop[1]) = "" THEN "" ELSE " ") 
                            + ENTRY(aux_contapal,crapcop.nmextcop," ").
      ELSE
           rel_nmrescop[2] = rel_nmrescop[2] +
                       (IF TRIM(rel_nmrescop[2]) = "" THEN "" ELSE " ")      
                            + ENTRY(aux_contapal,crapcop.nmextcop," ").
   END.  /*  Fim DO .. TO  */ 
            
   ASSIGN rel_nmrescop[1] = 
            FILL(" ",16 - INT(LENGTH(rel_nmrescop[1]) / 2)) + rel_nmrescop[1]
          rel_nmrescop[2] = FILL(" ",16 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                            rel_nmrescop[2].

END PROCEDURE.

/*****************************************************************************
               Valida Impressao da proposta de emprestimo
 *****************************************************************************/
PROCEDURE valida_impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_tplcremp AS INTE                              NO-UNDO.
    
    DEF OUTPUT PARAM par_inobriga AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_cdagenci AS INTE                                       NO-UNDO.
    DEF VAR aux_returnvl AS CHAR                                       NO-UNDO.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida impressao."
           aux_returnvl = "OK"
           par_inobriga = "N".

    Valida: DO ON ERROR UNDO Valida, LEAVE Valida:
        EMPTY TEMP-TABLE tt-erro.

        IF  par_tplcremp <> 2 THEN
            LEAVE Valida.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
       
        IF  NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                ASSIGN aux_returnvl = "NOK".
                LEAVE Valida.
            END.
       
        ASSIGN aux_cdagenci = crapass.cdagenci.
    
        FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
       
        IF  NOT AVAILABLE crawepr   THEN
            DO:
                ASSIGN aux_cdcritic = 510
                       aux_dscritic = "".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
                ASSIGN aux_returnvl = "NOK".
                LEAVE Valida.
            END.
    
        FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper   AND
                               crapbpr.nrdconta = crawepr.nrdconta   AND
                               crapbpr.tpctrpro = 90                 AND
                               crapbpr.nrctrpro = crawepr.nrctremp   AND
                               crapbpr.flgalien = TRUE               NO-LOCK:

            IF  valida_proprietario (crapbpr.nrcpfbem, par_cdcooper) = "" THEN
                DO:
                    /* Se o interveniente esta habilitado */
                    IF  verifica_interv (aux_cdagenci, par_cdcooper) THEN 
                        DO:                                                              
                            ASSIGN aux_dscritic = 
                                       "O Proprietario do bem " +
                                       TRIM(STRING(crapbpr.dsbemfin,"x(18)")) +
                                       " nao faz parte do contrato.".
    
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,      
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                
                            ASSIGN aux_returnvl = "NOK".
                            LEAVE Valida.                            
                        END.
                END.
        END.

        END.

    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
    
    IF  AVAILABLE crawepr   THEN
        DO:
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
        
        /* Se ainda nao Enviada ou Enviada mas com Erro Consultas */
        /* IF  crawepr.insitest < 2 OR crawepr.insitapr = 5 THEN */
		IF  crawepr.insitest < 2 OR CAN-DO ("5,6",STRING(crawepr.insitapr)) THEN /* bug 14748 rubens */
            DO:
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

              /* Efetuar a chamada a rotina Oracle */ 
              RUN STORED-PROCEDURE pc_obrigacao_analise_automatic
               aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, /* Código da Cooperativa */
                                                    INPUT crapass.inpessoa, /* Tipo da Pessoa */
                                                    INPUT crawepr.cdfinemp, /* Código da finalidade de crédito */
                                                    INPUT crawepr.cdlcremp, /* Código da linha de crédito */
                                                   OUTPUT "",           /* Obrigaçao de análise automática (S/N) */
                                                   OUTPUT 0,            /* Código da crítica */
                                                   OUTPUT "").          /* Descriçao da crítica */
              
              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_obrigacao_analise_automatic
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN par_inobriga = pc_obrigacao_analise_automatic.pr_inobriga
                                       WHEN pc_obrigacao_analise_automatic.pr_inobriga <> ?
                     aux_cdcritic = pc_obrigacao_analise_automatic.pr_cdcritic
                                       WHEN pc_obrigacao_analise_automatic.pr_cdcritic <> ?
                     aux_dscritic = pc_obrigacao_analise_automatic.pr_dscritic
                                       WHEN pc_obrigacao_analise_automatic.pr_dscritic <> ?.

              IF aux_cdcritic > 0 OR 
                 aux_dscritic <> '' THEN
                 DO:
                    CREATE tt-erro.
                    ASSIGN tt-erro.cdcritic = aux_cdcritic
                           tt-erro.dscritic = aux_dscritic.

                    ASSIGN aux_returnvl = "NOK".

    END.
            END.
        END.    

    IF  aux_returnvl = "NOK" THEN
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

    RETURN aux_returnvl.

END.

/* ......................................................................... */



/*********************************************************************************************************************************************
**********************************************************************************************************************************************
                                                            FINAL DA BO2i ORIGINAL
**********************************************************************************************************************************************
**********************************************************************************************************************************************/
/*********************************************************************************************************************************************
**********************************************************************************************************************************************
                                                                 INICIO DA BO2i
**********************************************************************************************************************************************
**********************************************************************************************************************************************/

/*..............................................................................

Contratos Abrangidos:

     1 - Empréstimo e Financiamento Padrao - Pós-fixado - Folha de Rosto             
     2 - Empréstimo e Financiamento BNDES - Pós-fixado - Folha de Rosto              
     3 - Empréstimo e Financiamento ABN e SANTANDER - Pós-fixado - Folha de Rosto    /* Desativado */
     4 - Alienacao Fiduciaria em Garantia - Automoveis - Pós-fixado                  
     5 - Alienacao Fiduciaria em Garantia - Maquinas - Pós-fixado                    
     6 - Alienacao Fiduciaria em Garantia - Hipoteca - Pós-fixado                    
     7 - Empréstimo e Financiamento Padrao - Pré-fixado - Folha de Rosto             
     8 - Empréstimo e Financiamento BNDES - Pre-fixado - Folha de Rosto              
     9 - Empréstimo e Financiamento ABN e SANTANDER - Pré-fixado - Folha de Rosto    
    10 - Alienacao Fiduciaria em Garantia - Automoveis - Pré-fixado                                
    11 - Alienacao Fiduciaria em Garantia - Maquinas - Pré-fixado                    
    12 - Alienacao Fiduciaria em Garantia - Hipoteca - Pré-fixado                    
    
..............................................................................*/
/*................................. DEFINICOES ...............................*/

DEF VAR aux_nrdoitem AS INTE                                           NO-UNDO.

DEF VAR aux_dsdoitem AS CHAR                                           NO-UNDO.
DEF VAR aux_dsdmoeda AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.

ASSIGN aux_dsdmoeda = "R$". /* Real */

FORM aux_nrdoitem FORMAT "9"
     SPACE(0)
     "."
     aux_dsdoitem FORMAT "X(60)"
     WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_item.

/*................................. PROCEDURE ................................*/
/*.................................. DESVIO ..................................*/

PROCEDURE nova-impressao-contratos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                  

    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.

IF  crawepr.tpemprst = 0 THEN /* Pós-Fixado */
    DO:
        IF  craplcr.tpctrato = 1  THEN
            DO:
                RUN monta-emprestimo-padrao-bndes-pos-fixado (INPUT par_cdcooper,
                                                              INPUT par_cdagenci,
                                                              INPUT par_cdoperad,
                                                              INPUT par_nrdcaixa,
                                                              INPUT par_nmdatela,
                                                              INPUT par_dtmvtolt,
                                                              INPUT par_dsiduser,
                                                              INPUT par_idorigem,
                                                              INPUT crawepr.nrdconta, 
                                                              INPUT crawepr.nrctremp,
                                                              INPUT par_idimpres,
                                                              INPUT par_flgemail,
                                                             OUTPUT par_nmarqimp,
                                                             OUTPUT par_nmarqpdf,
                                                             OUTPUT TABLE tt-erro).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
        ELSE
        IF  craplcr.tpctrato = 2 THEN /* ALIENACAO */
            DO:
                /* Traz os bens associados ao emprestimo em questao */
                RUN busca-bens-alienacao (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_recidepr,
                                         OUTPUT TABLE tt-bens-contratos,
                                         OUTPUT TABLE tt-erro).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".

                /* Verifica se os bens associados aos Emprestimo sao veículos */
                FIND FIRST tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*AUTOMOVEL*" OR
                                                    tt-bens-contratos.dscatbem MATCHES "*MOTO*"      OR
                                                    tt-bens-contratos.dscatbem MATCHES "*CAMINHAO*"  OR
                                                    tt-bens-contratos.dscatbem MATCHES "*OUTROS VEICULOS*") NO-LOCK NO-ERROR NO-WAIT.
                IF  AVAIL tt-bens-contratos THEN
                    DO:
                        RUN monta-alienacao-fiduciaria-automovel-pos-fixado (INPUT par_cdcooper,
                                                                             INPUT par_cdagenci,
                                                                             INPUT par_cdoperad,
                                                                             INPUT par_nrdcaixa,
                                                                             INPUT par_nmdatela,
                                                                             INPUT par_dtmvtolt,
                                                                             INPUT par_dsiduser,
                                                                             INPUT par_idorigem,
                                                                             INPUT crawepr.nrdconta, 
                                                                             INPUT crawepr.nrctremp,
                                                                             INPUT par_idimpres,
                                                                             INPUT par_flgemail,
                                                                            OUTPUT par_nmarqimp,
                                                                            OUTPUT par_nmarqpdf,
                                                                            OUTPUT TABLE tt-erro).
                        IF  RETURN-VALUE <> "OK" THEN          
                            RETURN "NOK".
                    END.

                /* Verifica se os bens associados aos Emprestimo sao máquinas */
                FIND FIRST tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*MAQUINA*"      OR
                                                    tt-bens-contratos.dscatbem MATCHES "*EQUIPAMENTO*") NO-LOCK NO-ERROR NO-WAIT.

                IF  AVAIL tt-bens-contratos THEN
                    DO:
                        RUN monta-alienacao-fiduciaria-maquina-pos-fixado (INPUT par_cdcooper,
                                                                           INPUT par_cdagenci,
                                                                           INPUT par_cdoperad,
                                                                           INPUT par_nrdcaixa,
                                                                           INPUT par_nmdatela,
                                                                           INPUT par_dtmvtolt,
                                                                           INPUT par_dsiduser,
                                                                           INPUT par_idorigem,
                                                                           INPUT crawepr.nrdconta, 
                                                                           INPUT crawepr.nrctremp,
                                                                           INPUT par_idimpres,
                                                                           INPUT par_flgemail,
                                                                          OUTPUT par_nmarqimp,
                                                                          OUTPUT par_nmarqpdf,
                                                                          OUTPUT TABLE tt-erro).
                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN "NOK".
                    END.
            END.
        ELSE
        IF  craplcr.tpctrato = 3 THEN /* HIPOTECA */
            DO:
                RUN monta-alienacao-fiduciaria-hipoteca-pos-fixado (INPUT par_cdcooper,
                                                                    INPUT par_cdagenci,
                                                                    INPUT par_cdoperad,
                                                                    INPUT par_nrdcaixa,
                                                                    INPUT par_nmdatela,
                                                                    INPUT par_dtmvtolt,
                                                                    INPUT par_dsiduser,
                                                                    INPUT par_idorigem,
                                                                    INPUT crawepr.nrdconta, 
                                                                    INPUT crawepr.nrctremp,
                                                                    INPUT par_idimpres,
                                                                    INPUT par_flgemail,
                                                                   OUTPUT par_nmarqimp,
                                                                   OUTPUT par_nmarqpdf,
                                                                   OUTPUT TABLE tt-erro).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
    END.
ELSE                          /* Pré-Fixado */
    DO:
        IF  craplcr.tpctrato = 1  THEN
            DO:
                RUN monta-emprestimo-padrao-bndes-pre-fixado (INPUT par_cdcooper,
                                                              INPUT par_cdagenci,
                                                              INPUT par_cdoperad,
                                                              INPUT par_nrdcaixa,
                                                              INPUT par_nmdatela,
                                                              INPUT par_dtmvtolt,
                                                              INPUT par_dsiduser,
                                                              INPUT par_idorigem,
                                                              INPUT crawepr.nrdconta, 
                                                              INPUT crawepr.nrctremp,
                                                              INPUT par_idimpres,
                                                              INPUT par_flgemail,
                                                             OUTPUT par_nmarqimp,
                                                             OUTPUT par_nmarqpdf,
                                                             OUTPUT TABLE tt-erro).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
        ELSE
        IF  craplcr.tpctrato = 2 THEN /* ALIENACAO */
            DO:
                /* Traz os bens associados ao emprestimo em questao */
                RUN busca-bens-alienacao (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_recidepr,
                                         OUTPUT TABLE tt-bens-contratos,
                                         OUTPUT TABLE tt-erro).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".

                /* Verifica se os bens associados aos Emprestimo sao veículos */
                FIND FIRST tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*AUTOMOVEL*" OR
                                                    tt-bens-contratos.dscatbem MATCHES "*MOTO*"      OR
                                                    tt-bens-contratos.dscatbem MATCHES "*CAMINHAO*"  OR
                                                    tt-bens-contratos.dscatbem MATCHES "*OUTROS VEICULOS*") NO-LOCK NO-ERROR NO-WAIT.

                IF  AVAIL tt-bens-contratos THEN
                    DO:
                        RUN monta-alienacao-fiduciaria-automovel-pre-fixado (INPUT par_cdcooper,
                                                                             INPUT par_cdagenci,
                                                                             INPUT par_cdoperad,
                                                                             INPUT par_nrdcaixa,
                                                                             INPUT par_nmdatela,
                                                                             INPUT par_dtmvtolt,
                                                                             INPUT par_dsiduser,
                                                                             INPUT par_idorigem,
                                                                             INPUT crawepr.nrdconta, 
                                                                             INPUT crawepr.nrctremp,
                                                                             INPUT par_idimpres,
                                                                             INPUT par_flgemail,
                                                                            OUTPUT par_nmarqimp,
                                                                            OUTPUT par_nmarqpdf,
                                                                            OUTPUT TABLE tt-erro).
                        IF  RETURN-VALUE <> "OK" THEN          
                            RETURN "NOK".
                    END.

                /* Verifica se os bens associados aos Emprestimo sao máquinas */
                FIND FIRST tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*MAQUINA*"      OR
                                                    tt-bens-contratos.dscatbem MATCHES "*EQUIPAMENTO*") NO-LOCK NO-ERROR NO-WAIT.

                IF  AVAIL tt-bens-contratos THEN
                    DO:
                        RUN monta-alienacao-fiduciaria-maquina-pre-fixado (INPUT par_cdcooper,
                                                                           INPUT par_cdagenci,
                                                                           INPUT par_cdoperad,
                                                                           INPUT par_nrdcaixa,
                                                                           INPUT par_nmdatela,
                                                                           INPUT par_dtmvtolt,
                                                                           INPUT par_dsiduser,
                                                                           INPUT par_idorigem,
                                                                           INPUT crawepr.nrdconta, 
                                                                           INPUT crawepr.nrctremp,
                                                                           INPUT par_idimpres,
                                                                           INPUT par_flgemail,
                                                                          OUTPUT par_nmarqimp,
                                                                          OUTPUT par_nmarqpdf,
                                                                          OUTPUT TABLE tt-erro).
                        IF  RETURN-VALUE <> "OK" THEN
                            RETURN "NOK".
                    END.
            END.
        ELSE
        IF  craplcr.tpctrato = 3 THEN /* HIPOTECA */
            DO:
                RUN monta-alienacao-fiduciaria-hipoteca-pre-fixado (INPUT par_cdcooper,
                                                                    INPUT par_cdagenci,
                                                                    INPUT par_cdoperad,
                                                                    INPUT par_nrdcaixa,
                                                                    INPUT par_nmdatela,
                                                                    INPUT par_dtmvtolt,
                                                                    INPUT par_dsiduser,
                                                                    INPUT par_idorigem,
                                                                    INPUT crawepr.nrdconta, 
                                                                    INPUT crawepr.nrctremp,
                                                                    INPUT par_idimpres,
                                                                    INPUT par_flgemail,
                                                                   OUTPUT par_nmarqimp,
                                                                   OUTPUT par_nmarqpdf,
                                                                   OUTPUT TABLE tt-erro).
                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.
    END.

END PROCEDURE.

/*................................ PROCEDURES ...............................*/
/*................................. MODELOS .................................*/

PROCEDURE modelo-emprestimo-padrao-bndes-folha-rosto-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "2. VALOR DO EMPRESTIMO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "FINALIDADE DO EMPRESTIMO E DA LINHA DE CREDITO:").
        
        RUN insere-clausula-finalidade       (INPUT "3.1.").
        RUN insere-clausula-linha-de-credito (INPUT "3.2.").

        /* BNDES */
        IF  craplcr.cdusolcr = 1 THEN
            RUN insere-clausula-declaracao-bndes (INPUT "3.3.").

        PUT STREAM str_1 SKIP(1).

        RUN insere-item (INPUT 4,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros-remun-minimos (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "4.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.
        
        RUN insere-subclausula-composicao-encargos-financeiros (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "4.1.",
                                                                INPUT "4.1.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "4.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.
        
        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "4.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "4.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 5,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "5.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "5.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "5.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "5.4.").

        RUN insere-item (INPUT 6,
                         INPUT "FIADOR(ES):").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-item (INPUT 7,
                         INPUT "DECLARACAO INERENTE A FOLHA DE ROSTO:").

        RUN insere-clausula-declaracao-inerente-folha-rosto.

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.
            
        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-emprestimo-padrao-bndes-folha-rosto-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "2. VALOR DO EMPRESTIMO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "FINALIDADE DO EMPRESTIMO E DA LINHA DE CREDITO:").
        
        RUN insere-clausula-finalidade       (INPUT "3.1.").
        RUN insere-clausula-linha-de-credito (INPUT "3.2.").

        /* BNDES */
        IF  craplcr.cdusolcr = 1 THEN
            RUN insere-clausula-declaracao-bndes (INPUT "3.3.").

        PUT STREAM str_1 SKIP(1).
  
        RUN insere-item (INPUT 4,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "4.1.",
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.
        
        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "4.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.
        
        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "4.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.
  
        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "4.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 5,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "5.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "5.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "5.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "5.4.").

        RUN insere-item (INPUT 6,
                         INPUT "DA TOLERANCIA:").

        RUN insere-subclausula1-prazo-tolerancia (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "6.1.",
                                                  INPUT "4.", /* ENCARGOS FINANCEIROS */
                                                  INPUT crawepr.qttolatr,
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                       
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula2-prazo-tolerancia (INPUT "6.2.",
                                                  INPUT "6.1."). /* DIAS DE TOLERANCIA */

        RUN insere-item (INPUT 7,
                         INPUT "FIADOR(ES):").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-item (INPUT 8,
                         INPUT "DECLARACAO INERENTE A FOLHA DE ROSTO:").

        RUN insere-clausula-declaracao-inerente-folha-rosto.

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).
  
        ASSIGN aux_flgsuces = TRUE.

        LEAVE.
  
    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-alienacao-fiduciaria-automovel-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-item (INPUT 2,
                         INPUT "TERCEIROS GARANTIDORES:").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "BEM(NS) FINANCIADO(S)/GARANTIA:").
        
        RUN insere-clausula-bens-garantia-automovel (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT "3.",    /* BENS GARANTIA    */
                                                     INPUT RECID(crawepr),
                                                    OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "4. VALOR FINANCIADO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-item (INPUT 5,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "5.1.",
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN          
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "5.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "5.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "5.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 6,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "6.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "6.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "6.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "6.4.").

        RUN insere-item (INPUT 7,
                         INPUT "DA TOLERANCIA:").

        RUN insere-subclausula1-prazo-tolerancia (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "7.1.",
                                                  INPUT "5.", /* ENCARGOS FINANCEIROS */
                                                  INPUT crawepr.qttolatr,
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                       
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula2-prazo-tolerancia (INPUT "7.2.",
                                                  INPUT "7.1."). /* DIAS DE TOLERANCIA */

        RUN insere-item (INPUT 8,
                         INPUT "CONDICOES GERAIS:").

        RUN insere-clausula-condicoes-gerais-contratantes (INPUT "8.1.",
                                                           INPUT "1.1.", /* CONTRATADA  */
                                                           INPUT "1.2.", /* CONTRATANTE */
                                                           INPUT crapcop.nmextcop,
                                                           INPUT crapcop.nmrescop).

        RUN insere-clausula-condicoes-gerais-financiamento (INPUT "8.2.",
                                                            INPUT "4.",    /* VALOR FINANCIADO */
                                                            INPUT "3.",    /* BENS GARANTIA    */
                                                            INPUT "1.2."). /* CONTRATANTE      */

        RUN insere-clausula-condicoes-gerais-encargos-financeiros-pre-fixado (INPUT "8.3.",
                                                                              INPUT "5.").  /* ENCARGOS FINANCEIROS */
        
        RUN insere-subclausula1-condicoes-gerais-encargos-financeiros (INPUT "8.3.1.").
        RUN insere-subclausula4-condicoes-gerais-encargos-financeiros (INPUT "8.3.2.").
        
        RUN insere-clausula-condicoes-gerais-prestacoes (INPUT "8.4.",
                                                         INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula1-condicoes-gerais-prestacoes-pre-fixado (INPUT "8.4.1.",
                                                                        INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula2-condicoes-gerais-prestacoes (INPUT "8.4.2.",
                                                             INPUT "6.3.").   /* FORMA DE PAGAMENTO */
        
        RUN insere-subclausula3-condicoes-gerais-prestacoes (INPUT "8.4.3.",
                                                             INPUT "6.",    /* DAS PRESTACOES MENSAIS */
                                                             INPUT "1.2."). /* CONTRATANTE      */
        
        RUN insere-clausula-condicoes-gerais-vencimento-antecipado (INPUT "8.5.",
                                                                    INPUT "8.6.2."). /* DAS GARANTIAS - ALIENAÇAO FIDUCIÁRIA OBRIGAÇAO LEGAL */

        RUN insere-subclausula1-condicoes-gerais-vencimento-antecipado-pre-fixada (INPUT "8.5.1.").

        RUN insere-clausula-condicoes-gerais-garantias-alienacao (INPUT "8.6.",
                                                                  INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula1-condicoes-gerais-garantias-alienacao-veiculo (INPUT "8.6.1.").

        RUN insere-subclausula2-condicoes-gerais-garantias-alienacao (INPUT "8.6.2.",
                                                                      INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula3-condicoes-gerais-garantias-alienacao (INPUT "8.6.3.",
                                                                      INPUT "2.").   /* FIADORES */
                                                                     
        RUN insere-subclausula4-condicoes-gerais-garantias-alienacao (INPUT "8.6.4.").

        RUN insere-subclausula5-condicoes-gerais-garantias-alienacao (INPUT "8.6.5.").

        RUN insere-clausula-condicoes-gerais-seguro (INPUT "8.7.").

        RUN insere-subclausula1-condicoes-gerais-seguro (INPUT "8.7.1.").

        RUN insere-clausula-condicoes-gerais-inadimplemento (INPUT "8.8.",
                                                             INPUT "5.").  /* ENCARGOS FINANCEIROS */

        RUN insere-clausula-condicoes-gerais-condicao-especial (INPUT "8.9.").

        RUN insere-subclausula1-condicoes-gerais-condicao-especial (INPUT "8.9.1.").

        RUN insere-clausula-condicoes-gerais-despesas (INPUT "8.10.").

        RUN insere-clausula-condicoes-gerais-efeitos-contrato (INPUT "8.11.").

        RUN insere-clausula-condicoes-gerais-liberacao-inf-bc (INPUT "8.12.").

        RUN insere-clausula-condicoes-gerais-vinculo-cooperativo (INPUT "8.13.").

        RUN insere-clausula-condicoes-gerais-ouvidoria (INPUT "8.14.").

        RUN insere-clausula-condicoes-gerais-foro (INPUT "8.15.").

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-clausula-termo-assinatura-alienacao (INPUT "8.16.").

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-intervenientes (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT RECID(crawepr),
                                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-alienacao-fiduciaria-automovel-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-item (INPUT 2,
                         INPUT "TERCEIROS GARANTIDORES:").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "BEM(NS) FINANCIADO(S)/GARANTIA:").
        
        RUN insere-clausula-bens-garantia-automovel (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT "3.",    /* BENS GARANTIA    */
                                                     INPUT RECID(crawepr),
                                                    OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "4. VALOR FINANCIADO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-item (INPUT 5,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros-remun-minimos (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "5.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula-composicao-encargos-financeiros (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "5.1.",
                                                                INPUT "5.1.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "5.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "5.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "5.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 6,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "6.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "6.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "6.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "6.4.").

        RUN insere-item (INPUT 7,
                         INPUT "CONDICOES GERAIS:").
                                                         
        RUN insere-clausula-condicoes-gerais-contratantes (INPUT "7.1.",
                                                           INPUT "1.1.", /* CONTRATADA  */
                                                           INPUT "1.2.", /* CONTRATANTE */
                                                           INPUT crapcop.nmextcop,
                                                           INPUT crapcop.nmrescop).

        RUN insere-clausula-condicoes-gerais-financiamento (INPUT "7.2.",
                                                            INPUT "4.",    /* VALOR FINANCIADO */
                                                            INPUT "3.",    /* BENS GARANTIA    */
                                                            INPUT "1.2."). /* CONTRATANTE      */

        RUN insere-clausula-condicoes-gerais-encargos-financeiros (INPUT "7.3.",
                                                                   INPUT "5.").  /* ENCARGOS FINANCEIROS */
        
        RUN insere-subclausula1-condicoes-gerais-encargos-financeiros (INPUT "7.3.1.").

        RUN insere-subclausula2-condicoes-gerais-encargos-financeiros (INPUT "7.3.2.",
                                                                       INPUT "5.1.1.",  /* JUROS REMUNERATORIOS */
                                                                       INPUT "7.8.").     /*  DO INADIMPLEMENTO   */
        
        RUN insere-subclausula3-condicoes-gerais-encargos-financeiros (INPUT "7.3.3.").
        
        RUN insere-subclausula4-condicoes-gerais-encargos-financeiros (INPUT "7.3.4.").
        
        RUN insere-clausula-condicoes-gerais-prestacoes (INPUT "7.4.",
                                                         INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula1-condicoes-gerais-prestacoes (INPUT "7.4.1.",
                                                             INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula2-condicoes-gerais-prestacoes (INPUT "7.4.2.",
                                                             INPUT "6.3.").   /* FORMA DE PAGAMENTO */
        
        RUN insere-subclausula3-condicoes-gerais-prestacoes (INPUT "7.4.3.",
                                                             INPUT "6.",    /* DAS PRESTACOES MENSAIS */
                                                             INPUT "1.2."). /* CONTRATANTE      */
        
        RUN insere-clausula-condicoes-gerais-vencimento-antecipado (INPUT "7.5.",
                                                                    INPUT "7.6.2."). /* DAS GARANTIAS - ALIENAÇAO FIDUCIÁRIA OBRIGAÇAO LEGAL */

        RUN insere-subclausula1-condicoes-gerais-vencimento-antecipado (INPUT "7.5.1.").

        RUN insere-clausula-condicoes-gerais-garantias-alienacao (INPUT "7.6.",
                                                                  INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula1-condicoes-gerais-garantias-alienacao-veiculo (INPUT "7.6.1.").

        RUN insere-subclausula2-condicoes-gerais-garantias-alienacao (INPUT "7.6.2.",
                                                                      INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula3-condicoes-gerais-garantias-alienacao (INPUT "7.6.3.",
                                                                      INPUT "2.").   /* FIADORES */
                                                                     
        RUN insere-subclausula4-condicoes-gerais-garantias-alienacao (INPUT "7.6.4.").

        RUN insere-subclausula5-condicoes-gerais-garantias-alienacao (INPUT "7.6.5.").

        RUN insere-clausula-condicoes-gerais-seguro (INPUT "7.7.").

        RUN insere-subclausula1-condicoes-gerais-seguro (INPUT "7.7.1.").

        RUN insere-clausula-condicoes-gerais-inadimplemento (INPUT "7.8.",
                                                             INPUT "5.").  /* ENCARGOS FINANCEIROS */

        RUN insere-clausula-condicoes-gerais-condicao-especial (INPUT "7.9.").

        RUN insere-subclausula1-condicoes-gerais-condicao-especial (INPUT "7.9.1.").

        RUN insere-clausula-condicoes-gerais-despesas (INPUT "7.10.").

        RUN insere-clausula-condicoes-gerais-efeitos-contrato (INPUT "7.11.").

        RUN insere-clausula-condicoes-gerais-liberacao-inf-bc (INPUT "7.12.").

        RUN insere-clausula-condicoes-gerais-vinculo-cooperativo (INPUT "7.13.").

        RUN insere-clausula-condicoes-gerais-ouvidoria (INPUT "7.14.").

        RUN insere-clausula-condicoes-gerais-foro (INPUT "7.15.").

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-clausula-termo-assinatura-alienacao (INPUT "7.16.").

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-intervenientes (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT RECID(crawepr),
                                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-alienacao-fiduciaria-maquina-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-item (INPUT 2,
                         INPUT "TERCEIROS GARANTIDORES:").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "BEM(NS) FINANCIADO(S)/GARANTIA:").
        
        RUN insere-clausula-bens-garantia-maquina (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT "3.",    /* BENS GARANTIA    */
                                                   INPUT RECID(crawepr),
                                                  OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        PUT STREAM str_1 SKIP(1).

        RUN insere-clausula-bens-garantia-maquina-nota.

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "4. VALOR FINANCIADO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-item (INPUT 5,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros-remun-minimos (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "5.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula-composicao-encargos-financeiros (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "5.1.",
                                                                INPUT "5.1.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "5.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "5.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "5.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 6,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "6.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "6.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "6.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "6.4.").

        RUN insere-item (INPUT 7,
                         INPUT "CONDICOES GERAIS:").

        RUN insere-clausula-condicoes-gerais-contratantes (INPUT "7.1.",
                                                           INPUT "1.1.", /* CONTRATADA  */
                                                           INPUT "1.2.", /* CONTRATANTE */
                                                           INPUT crapcop.nmextcop,
                                                           INPUT crapcop.nmrescop).

        RUN insere-clausula-condicoes-gerais-financiamento (INPUT "7.2.",
                                                            INPUT "4.",     /* VALOR FINANCIADO */
                                                            INPUT "3.",     /* BENS GARANTIA    */
                                                            INPUT "1.2."). /* CONTRATANTE      */

        RUN insere-clausula-condicoes-gerais-encargos-financeiros-maquina-pos-fixado (INPUT "7.3.",
                                                                                      INPUT "5.").  /* ENCARGOS FINANCEIROS */
        
        RUN insere-subclausula1-condicoes-gerais-encargos-financeiros (INPUT "7.3.1.").

        RUN insere-subclausula2-condicoes-gerais-encargos-financeiros (INPUT "7.3.2.",
                                                                       INPUT "5.1.1.",  /* JUROS REMUNERATORIOS */
                                                                       INPUT "7.7.").     /*  DO INADIMPLEMENTO   */
        
        RUN insere-subclausula3-condicoes-gerais-encargos-financeiros (INPUT "7.3.3.").
        
        RUN insere-subclausula4-condicoes-gerais-encargos-financeiros (INPUT "7.3.4.").
        
        RUN insere-clausula-condicoes-gerais-prestacoes (INPUT "7.4.",
                                                         INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula1-condicoes-gerais-prestacoes (INPUT "7.4.1.",
                                                             INPUT "6.").      /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula2-condicoes-gerais-prestacoes (INPUT "7.4.2.",
                                                             INPUT "6.3.").   /* FORMA DE PAGAMENTO */
        
        RUN insere-subclausula3-condicoes-gerais-prestacoes (INPUT "7.4.3.",
                                                             INPUT "6.",     /* DAS PRESTACOES MENSAIS */
                                                             INPUT "1.2."). /* CONTRATANTE      */
        
        RUN insere-clausula-condicoes-gerais-vencimento-antecipado (INPUT "7.5.",
                                                                    INPUT "7.6.2.").

        RUN insere-subclausula1-condicoes-gerais-vencimento-antecipado (INPUT "7.5.1.").

        RUN insere-clausula-condicoes-gerais-garantias-alienacao (INPUT "7.6.",
                                                                  INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula1-condicoes-gerais-garantias-alienacao (INPUT "7.6.1.").

        RUN insere-subclausula2-condicoes-gerais-garantias-alienacao (INPUT "7.6.2.",
                                                                      INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula3-condicoes-gerais-garantias-alienacao (INPUT "7.6.3.",
                                                                      INPUT "2.").   /* FIADORES */
                                                                     
        RUN insere-subclausula4-condicoes-gerais-garantias-alienacao (INPUT "7.6.4.").

        RUN insere-subclausula5-condicoes-gerais-garantias-alienacao (INPUT "7.6.5.").

        RUN insere-clausula-condicoes-gerais-inadimplemento (INPUT "7.7.",
                                                             INPUT "5.").  /* ENCARGOS FINANCEIROS */

        RUN insere-clausula-condicoes-gerais-condicao-especial (INPUT "7.8.").

        RUN insere-subclausula1-condicoes-gerais-condicao-especial (INPUT "7.8.1.").

        RUN insere-clausula-condicoes-gerais-despesas (INPUT "7.9.").

        RUN insere-clausula-condicoes-gerais-efeitos-contrato (INPUT "7.10.").

        RUN insere-clausula-condicoes-gerais-liberacao-inf-bc (INPUT "7.11.").

        RUN insere-clausula-condicoes-gerais-vinculo-cooperativo (INPUT "7.12.").

        RUN insere-clausula-condicoes-gerais-ouvidoria (INPUT "7.13.").

        RUN insere-clausula-condicoes-gerais-foro (INPUT "7.14.").

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-clausula-termo-assinatura-alienacao (INPUT "7.15.").

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-intervenientes (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT RECID(crawepr),
                                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-alienacao-fiduciaria-maquina-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-item (INPUT 2,
                         INPUT "TERCEIROS GARANTIDORES:").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "BEM(NS) FINANCIADO(S)/GARANTIA:").
        
        RUN insere-clausula-bens-garantia-maquina (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT "3.",    /* BENS GARANTIA    */
                                                   INPUT RECID(crawepr),
                                                  OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        PUT STREAM str_1 SKIP(1).

        RUN insere-clausula-bens-garantia-maquina-nota.

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "4. VALOR FINANCIADO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-item (INPUT 5,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "5.1.",
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN          
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "5.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "5.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "5.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 6,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "6.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "6.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "6.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "6.4.").

        RUN insere-item (INPUT 7,
                         INPUT "DA TOLERANCIA:").

        RUN insere-subclausula1-prazo-tolerancia (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "7.1.",
                                                  INPUT "5.", /* ENCARGOS FINANCEIROS */
                                                  INPUT crawepr.qttolatr,
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                       
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula2-prazo-tolerancia (INPUT "7.2.",
                                                  INPUT "7.1."). /* DIAS DE TOLERANCIA */

        RUN insere-item (INPUT 8,
                         INPUT "CONDICOES GERAIS:").

        RUN insere-clausula-condicoes-gerais-contratantes (INPUT "8.1.",
                                                           INPUT "1.1.", /* CONTRATADA  */
                                                           INPUT "1.2.", /* CONTRATANTE */
                                                           INPUT crapcop.nmextcop,
                                                           INPUT crapcop.nmrescop).

        RUN insere-clausula-condicoes-gerais-financiamento (INPUT "8.2.",
                                                            INPUT "4.",     /* VALOR FINANCIADO */
                                                            INPUT "3.",     /* BENS GARANTIA    */
                                                            INPUT "1.2."). /* CONTRATANTE      */

        RUN insere-clausula-condicoes-gerais-encargos-financeiros-pre-fixado (INPUT "8.3.",
                                                                              INPUT "5.").  /* ENCARGOS FINANCEIROS */
        
        RUN insere-subclausula1-condicoes-gerais-encargos-financeiros (INPUT "8.3.1.").
        RUN insere-subclausula4-condicoes-gerais-encargos-financeiros (INPUT "8.3.2.").
        
        RUN insere-clausula-condicoes-gerais-prestacoes (INPUT "8.4.",
                                                         INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula1-condicoes-gerais-prestacoes-pre-fixado (INPUT "8.4.1.",
                                                                        INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula2-condicoes-gerais-prestacoes (INPUT "8.4.2.",
                                                             INPUT "6.3.").   /* FORMA DE PAGAMENTO */
        
        RUN insere-subclausula3-condicoes-gerais-prestacoes (INPUT "8.4.3.",
                                                             INPUT "6.",     /* DAS PRESTACOES MENSAIS */
                                                             INPUT "1.2."). /* CONTRATANTE      */
        
        RUN insere-clausula-condicoes-gerais-vencimento-antecipado (INPUT "8.5.",
                                                                    INPUT "8.6.2."). /* DAS GARANTIAS - ALIENAÇAO FIDUCIÁRIA OBRIGAÇAO LEGAL */

        RUN insere-subclausula1-condicoes-gerais-vencimento-antecipado-pre-fixada (INPUT "8.5.1.").

        RUN insere-clausula-condicoes-gerais-garantias-alienacao (INPUT "8.6.",
                                                                  INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula1-condicoes-gerais-garantias-alienacao (INPUT "8.6.1.").

        RUN insere-subclausula2-condicoes-gerais-garantias-alienacao (INPUT "8.6.2.",
                                                                      INPUT "3.").   /* BENS GARANTIA    */

        RUN insere-subclausula3-condicoes-gerais-garantias-alienacao (INPUT "8.6.3.",
                                                                      INPUT "2.").   /* FIADORES */
                                                                     
        RUN insere-subclausula4-condicoes-gerais-garantias-alienacao (INPUT "8.6.4.").

        RUN insere-subclausula5-condicoes-gerais-garantias-alienacao (INPUT "8.6.5.").

        RUN insere-clausula-condicoes-gerais-inadimplemento (INPUT "8.7.",
                                                             INPUT "5.").  /* ENCARGOS FINANCEIROS */

        RUN insere-clausula-condicoes-gerais-condicao-especial (INPUT "8.8.").

        RUN insere-subclausula1-condicoes-gerais-condicao-especial (INPUT "8.8.1.").

        RUN insere-clausula-condicoes-gerais-despesas (INPUT "8.9.").

        RUN insere-clausula-condicoes-gerais-efeitos-contrato (INPUT "8.10.").

        RUN insere-clausula-condicoes-gerais-liberacao-inf-bc (INPUT "8.11.").

        RUN insere-clausula-condicoes-gerais-vinculo-cooperativo (INPUT "8.12.").

        RUN insere-clausula-condicoes-gerais-ouvidoria (INPUT "8.13.").

        RUN insere-clausula-condicoes-gerais-foro (INPUT "8.14.").

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-clausula-termo-assinatura-alienacao (INPUT "8.15.").

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-intervenientes (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT RECID(crawepr),
                                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-alienacao-fiduciaria-hipoteca-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-item (INPUT 2,
                         INPUT "TERCEIROS GARANTIDORES:").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "IMOVEL(EIS) FINANCIADO(S)/GARANTIA:").
        
        RUN insere-clausula-garantia-imovel-financiado (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT "3.",    /* BENS GARANTIA    */
                                                        INPUT RECID(crawepr),
                                                       OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "4. VALOR FINANCIADO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-item (INPUT 5,
                         INPUT "ENCARGOS FINANCEIROS:").
                                               
        RUN insere-clausula-encargos-financeiros (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "5.1.",
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "5.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "5.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "5.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 6,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "6.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "6.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "6.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "6.4.").

        RUN insere-item (INPUT 7,
                         INPUT "DA TOLERANCIA:").

        RUN insere-subclausula1-prazo-tolerancia (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT "7.1.",
                                                  INPUT "5.", /* ENCARGOS FINANCEIROS */
                                                  INPUT crawepr.qttolatr,
                                                 OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                       
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula2-prazo-tolerancia (INPUT "7.2.",
                                                  INPUT "7.1."). /* DIAS DE TOLERANCIA */

        RUN insere-item (INPUT 8,
                         INPUT "CONDICOES GERAIS:").

        RUN insere-clausula-condicoes-gerais-contratantes (INPUT "8.1.",
                                                           INPUT "1.1.", /* CONTRATADA  */
                                                           INPUT "1.2.", /* CONTRATANTE */
                                                           INPUT crapcop.nmextcop,
                                                           INPUT crapcop.nmrescop).

        RUN insere-clausula-condicoes-gerais-financiamento-imovel (INPUT "8.2.",
                                                                   INPUT "4.",     /* VALOR FINANCIADO */
                                                                   INPUT "3.",     /* IMOVEL    */
                                                                   INPUT "1.2."). /* CONTRATANTE      */

        RUN insere-clausula-condicoes-gerais-encargos-financeiros-pre-fixado (INPUT "8.3.",
                                                                              INPUT "5.").  /* ENCARGOS FINANCEIROS */
        
        RUN insere-subclausula1-condicoes-gerais-encargos-financeiros (INPUT "8.3.1.").
        RUN insere-subclausula4-condicoes-gerais-encargos-financeiros (INPUT "8.3.2.").
        
        RUN insere-clausula-condicoes-gerais-prestacoes (INPUT "8.4.",
                                                         INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula1-condicoes-gerais-prestacoes-pre-fixado (INPUT "8.4.1.",
                                                                        INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula2-condicoes-gerais-prestacoes (INPUT "8.4.2.",
                                                             INPUT "6.3.").   /* FORMA DE PAGAMENTO */
        
        RUN insere-subclausula3-condicoes-gerais-prestacoes (INPUT "8.4.3.",
                                                             INPUT "6.",     /* DAS PRESTACOES MENSAIS */
                                                             INPUT "1.2."). /* CONTRATANTE      */
        
        RUN insere-clausula-condicoes-gerais-vencimento-antecipado-imovel (INPUT "8.5.").

        RUN insere-subclausula1-condicoes-gerais-vencimento-antecipado-pre-fixada (INPUT "8.5.1.").

        RUN insere-clausula-condicoes-gerais-garantias-alienacao-imovel (INPUT "8.6.",
                                                                         INPUT "3.").   /* IMOVEL    */

        RUN insere-subclausula3-condicoes-gerais-garantias-alienacao (INPUT "8.6.1.",
                                                                      INPUT "2.").   /* FIADORES */
                                                                     
        RUN insere-subclausula4-condicoes-gerais-garantias-alienacao (INPUT "8.6.2.").

        RUN insere-subclausula5-condicoes-gerais-garantias-alienacao (INPUT "8.6.3.").

        RUN insere-clausula-condicoes-gerais-seguro-imovel (INPUT "8.7.").

        RUN insere-subclausula1-condicoes-gerais-seguro (INPUT "8.7.1.").

        RUN insere-clausula-condicoes-gerais-inadimplemento (INPUT "8.8.",
                                                             INPUT "5.").  /* ENCARGOS FINANCEIROS */

        RUN insere-clausula-condicoes-gerais-condicao-especial (INPUT "8.9.").

        RUN insere-subclausula1-condicoes-gerais-condicao-especial (INPUT "8.9.1.").

        RUN insere-clausula-condicoes-gerais-despesas (INPUT "8.10.").

        RUN insere-clausula-condicoes-gerais-efeitos-contrato (INPUT "8.11.").

        RUN insere-clausula-condicoes-gerais-liberacao-inf-bc (INPUT "8.12.").

        RUN insere-clausula-condicoes-gerais-vinculo-cooperativo (INPUT "8.13.").

        RUN insere-clausula-condicoes-gerais-ouvidoria (INPUT "8.14.").

        RUN insere-clausula-condicoes-gerais-foro (INPUT "8.15.").

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-clausula-termo-assinatura-alienacao (INPUT "8.16.").

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-intervenientes (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT RECID(crawepr),
                                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE modelo-alienacao-fiduciaria-hipoteca-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_flgsuces AS LOGI INIT FALSE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    RUN busca-dados-padrao (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_recidepr,
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    CHAMADAS_CLAUSULAS:
    DO WHILE TRUE:

        RUN insere-item (INPUT 1,
                         INPUT "IDENTIFICACAO:").

        RUN insere-clausula-contratada  (INPUT "1.1.").
        RUN insere-clausula-contratante (INPUT "1.2.").

        RUN insere-item (INPUT 2,
                         INPUT "TERCEIROS GARANTIDORES:").

        RUN insere-terceiros-garantidores (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT RECID(crawepr),
                                          OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 3,
                         INPUT "IMOVEL(EIS) FINANCIADO(S)/GARANTIA:").
        
        RUN insere-clausula-garantia-imovel-financiado (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT "3.",    /* BENS GARANTIA    */
                                                        INPUT RECID(crawepr),
                                                       OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-valor-extenso (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT "4. VALOR FINANCIADO:",
                                           INPUT crawepr.vlemprst,
                                          OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-item (INPUT 5,
                         INPUT "ENCARGOS FINANCEIROS:").

        RUN insere-clausula-encargos-financeiros-remun-minimos (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "5.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-subclausula-composicao-encargos-financeiros (INPUT par_cdcooper,
                                                                INPUT par_cdagenci,
                                                                INPUT par_nrdcaixa,
                                                                INPUT "5.1.",
                                                                INPUT "5.1.1.",
                                                               OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-juros-moratorios (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT "5.2.",
                                             OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-multa (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT "5.3.",
                                   INPUT craplcr.flgcobmu,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.


        RUN insere-clausula-cet (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT "5.4.",
                                OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-item (INPUT 6,
                         INPUT "PRESTACOES MENSAIS:").

        RUN insere-clausula-valor-extenso-prestacoes (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT par_nrdcaixa,
                                                      INPUT "6.1.",
                                                      INPUT crawepr.vlpreemp,
                                                     OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            LEAVE CHAMADAS_CLAUSULAS.

        RUN insere-clausula-parc-mens-previstas (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_dtmvtolt,
                                                 INPUT "6.2.",
                                                OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.
            
        RUN insere-clausula-forma-pagto (INPUT "6.3.").
        RUN insere-clausula-data-prim-pagto (INPUT "6.4.").
                                                    
        RUN insere-item (INPUT 7,
                         INPUT "CONDICOES GERAIS:").

        RUN insere-clausula-condicoes-gerais-contratantes (INPUT "7.1.",
                                                           INPUT "1.1.", /* CONTRATADA  */
                                                           INPUT "1.2.", /* CONTRATANTE */
                                                           INPUT crapcop.nmextcop,
                                                           INPUT crapcop.nmrescop).

        RUN insere-clausula-condicoes-gerais-financiamento-imovel (INPUT "7.2.",
                                                                   INPUT "4.",     /* VALOR FINANCIADO */
                                                                   INPUT "3.",     /* IMOVEL    */
                                                                   INPUT "1.2."). /* CONTRATANTE      */

        RUN insere-clausula-condicoes-gerais-encargos-financeiros (INPUT "7.3.",
                                                                   INPUT "5.").  /* ENCARGOS FINANCEIROS */
        
        RUN insere-subclausula1-condicoes-gerais-encargos-financeiros (INPUT "7.3.1.").

        RUN insere-subclausula2-condicoes-gerais-encargos-financeiros (INPUT "7.3.2.",
                                                                       INPUT "5.1.1.",  /* JUROS REMUNERATORIOS */
                                                                       INPUT "7.8.").     /*  DO INADIMPLEMENTO   */
        
        RUN insere-subclausula3-condicoes-gerais-encargos-financeiros (INPUT "7.3.3.").
        
        RUN insere-subclausula4-condicoes-gerais-encargos-financeiros (INPUT "7.3.4.").
        
        RUN insere-clausula-condicoes-gerais-prestacoes (INPUT "7.4.",
                                                         INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula1-condicoes-gerais-prestacoes (INPUT "7.4.1.",
                                                             INPUT "6.").   /* DAS PRESTACOES MENSAIS */
        
        RUN insere-subclausula2-condicoes-gerais-prestacoes (INPUT "7.4.2.",
                                                             INPUT "6.3.").   /* FORMA DE PAGAMENTO */
        
        RUN insere-subclausula3-condicoes-gerais-prestacoes (INPUT "7.4.3.",
                                                             INPUT "6.",    /* DAS PRESTACOES MENSAIS */
                                                             INPUT "1.2."). /* CONTRATANTE      */
        
        RUN insere-clausula-condicoes-gerais-vencimento-antecipado-imovel (INPUT "7.5.").

        RUN insere-subclausula1-condicoes-gerais-vencimento-antecipado (INPUT "7.5.1.").

        RUN insere-clausula-condicoes-gerais-garantias-alienacao-imovel (INPUT "7.6.",
                                                                         INPUT "3.").   /* IMOVEL    */

        RUN insere-subclausula3-condicoes-gerais-garantias-alienacao (INPUT "7.6.1.",
                                                                      INPUT "2.").   /* FIADORES */
                                                                     
        RUN insere-subclausula4-condicoes-gerais-garantias-alienacao (INPUT "7.6.2.").

        RUN insere-subclausula5-condicoes-gerais-garantias-alienacao (INPUT "7.6.3.").

        RUN insere-clausula-condicoes-gerais-seguro-imovel (INPUT "7.7.").

        RUN insere-subclausula1-condicoes-gerais-seguro (INPUT "7.7.1.").

        RUN insere-clausula-condicoes-gerais-inadimplemento (INPUT "7.8.",
                                                             INPUT "5.").  /* ENCARGOS FINANCEIROS */

        RUN insere-clausula-condicoes-gerais-condicao-especial (INPUT "7.9.").

        RUN insere-subclausula1-condicoes-gerais-condicao-especial (INPUT "7.9.1.").

        RUN insere-clausula-condicoes-gerais-despesas (INPUT "7.10.").

        RUN insere-clausula-condicoes-gerais-efeitos-contrato (INPUT "7.11.").

        RUN insere-clausula-condicoes-gerais-liberacao-inf-bc (INPUT "7.12.").

        RUN insere-clausula-condicoes-gerais-vinculo-cooperativo (INPUT "7.13.").

        RUN insere-clausula-condicoes-gerais-ouvidoria (INPUT "7.14.").

        RUN insere-clausula-condicoes-gerais-foro (INPUT "7.15.").

        IF  LINE-COUNTER(str_1) + 14 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-clausula-termo-assinatura-alienacao (INPUT "7.16.").

        RUN insere-local-data (INPUT par_cdcooper,
                               INPUT crapass.cdagenci).

        RUN insere-assinaturas-cooperado-cooperativa (INPUT crapass.nmprimtl,
                                                      INPUT crapcop.nmextcop,
                                                      INPUT crapcop.nmrescop).

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-intervenientes (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT RECID(crawepr),
                                              OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 6 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-fiadores (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT RECID(crawepr),
                                        OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN                      
            LEAVE CHAMADAS_CLAUSULAS.

        IF  LINE-COUNTER(str_1) + 10 > PAGE-SIZE(str_1) THEN
            PAGE STREAM str_1.

        RUN insere-assinaturas-testemunhas.

        RUN insere-operador (INPUT RECID(crawepr)).

        RUN insere-clausula-declaracao.

        IF  crawepr.tpdescto = 2  THEN
            RUN insere-clausula-carta-consignacao (INPUT par_dtmvtolt).

        ASSIGN aux_flgsuces = TRUE.

        LEAVE.

    END. /* DO WHILE TRUE CHAMADAS_CLAUSULAS */

    IF  NOT aux_flgsuces THEN
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.


/*................................ PROCEDURES ...............................*/
/*................................ CONSTRUCAO ...............................*/

/* Empréstimo e Financiamento Padrao - Pre-fixado - Folha de Rosto */
/* Empréstimo e Financiamento BNDES  - Pre-fixado - Folha de Rosto */
PROCEDURE monta-emprestimo-padrao-bndes-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE EMPRESTIMO PRICE PRE-FIXADO - N." AT 1
         crawepr.nrctremp                FORMAT "99,999,999"
         "PARA USO DA DIGITALIZACAO"                    AT   69
         SKIP(1)
         "FOLHA DE ROSTO"                               AT 1         
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   62
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   79
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   91                  
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_titulo_padrao_bndes_pre_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
            
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         par_nrdconta 
                         aux_nrctrrat 
                         aux_tpdocged 
    WITH FRAME f_titulo_padrao_bndes_pre_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-emprestimo-padrao-bndes-folha-rosto-pre-fixado (INPUT par_cdcooper,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_dtmvtolt,
                                                               INPUT par_idorigem,
                                                               INPUT RECID(crawepr),
                                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
        END.

    RETURN "OK".

END PROCEDURE.

/* Empréstimo e Financiamento Padrao - Pós-fixado - Folha de Rosto */
/* Empréstimo e Financiamento BNDES  - Pós-fixado - Folha de Rosto */
PROCEDURE monta-emprestimo-padrao-bndes-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF VAR aux_tpdocged        AS INTE                             NO-UNDO.
    DEF VAR aux_nrctrrat        AS DECI                               NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).
       
    FORM "CONTRATO DE EMPRESTIMO PRICE TR - N."  AT 1
         crawepr.nrctremp                        FORMAT "99,999,999"
         "PARA USO DA DIGITALIZACAO"             AT   69
         SKIP(1)
         "FOLHA DE ROSTO"                        AT 1
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   62
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   79
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   91         
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_titulo_padrao_bndes_pos_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.
    
    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         par_nrdconta
                         aux_nrctrrat
                         aux_tpdocged                         
    WITH FRAME f_titulo_padrao_bndes_pos_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-emprestimo-padrao-bndes-folha-rosto-pos-fixado (INPUT par_cdcooper,
                                                               INPUT par_cdagenci,
                                                               INPUT par_nrdcaixa,
                                                               INPUT par_dtmvtolt,
                                                               INPUT par_idorigem,
                                                               INPUT RECID(crawepr),
                                                              OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
        END.

    RETURN "OK".

END PROCEDURE.

/* Alienacao Fiduciaria em Garantia - Hipoteca - Pré-fixado */
PROCEDURE monta-alienacao-fiduciaria-hipoteca-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE FINANCIAMENTO COM ALIENACAO FIDUCIARIA EM GARANTIA PRICE PRE-FIXADO" 
          "PARA USO DA DIGITALIZACAO"                    AT   75
          SKIP(1) 
         "N."                                           AT 30
         crawepr.nrctremp                         FORMAT "99,999,999"         
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   75
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   87
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   98
         SKIP(1)
         WITH NO-BOX  NO-LABELS WIDTH 101 FRAME f_titulo_alienacao_fiduciaria_pre_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
            
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         crawepr.nrctremp
                         par_nrdconta    
                         aux_nrctrrat    
                         aux_tpdocged    
    WITH FRAME f_titulo_alienacao_fiduciaria_pre_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-alienacao-fiduciaria-hipoteca-pre-fixado (INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_idorigem,
                                                         INPUT RECID(crawepr),
                                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:            
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
        END.

    RETURN "OK".

END PROCEDURE.

/* Alienacao Fiduciaria em Garantia - Hipoteca - Pós-fixado */
PROCEDURE monta-alienacao-fiduciaria-hipoteca-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE FINANCIAMENTO COM ALIENACAO FIDUCIARIA EM GARANTIA PRICE TR"  
         "PARA USO DA DIGITALIZACAO"                    AT   75
         SKIP(1) 
         "N."                                           AT 30
         crawepr.nrctremp                         FORMAT "99,999,999"
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   75
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   87
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   98  
         SKIP(1)
         WITH NO-BOX  NO-LABELS WIDTH 101 FRAME f_titulo_alienacao_fiduciaria_pos_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         par_nrdconta
                         aux_nrctrrat
                         aux_tpdocged                         
    WITH FRAME f_titulo_alienacao_fiduciaria_pos_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-alienacao-fiduciaria-hipoteca-pos-fixado (INPUT par_cdcooper,
                                                         INPUT par_cdagenci,
                                                         INPUT par_nrdcaixa,
                                                         INPUT par_dtmvtolt,
                                                         INPUT par_idorigem,
                                                         INPUT RECID(crawepr),
                                                        OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
        END.

    RETURN "OK".

END PROCEDURE.

/* Alienacao Fiduciaria em Garantia - Maquinas - Pré-fixado */
PROCEDURE monta-alienacao-fiduciaria-maquina-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE FINANCIAMENTO COM ALIENACAO FIDUCIARIA EM GARANTIA PRICE PRE-FIXADO" 
         "PARA USO DA DIGITALIZACAO"                    AT   75
         SKIP(1)
         "N."                                           AT 30
         crawepr.nrctremp                         FORMAT "99,999,999"         
         SKIP
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   75
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   87 
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   98 
         SKIP(1)
         WITH NO-BOX  NO-LABELS WIDTH 101 FRAME f_titulo_alienacao_fiduciaria_pre_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         crawepr.nrctremp
                         par_nrdconta    
                         aux_nrctrrat    
                         aux_tpdocged    
    WITH FRAME f_titulo_alienacao_fiduciaria_pre_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-alienacao-fiduciaria-maquina-pre-fixado (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_idorigem,
                                                        INPUT RECID(crawepr),
                                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
        END.

    RETURN "OK".

END PROCEDURE.

/* Alienacao Fiduciaria em Garantia - Maquinas - Pós-fixado */
PROCEDURE monta-alienacao-fiduciaria-maquina-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE FINANCIAMENTO COM ALIENACAO FIDUCIARIA EM GARANTIA PRICE TR" 
         "PARA USO DA DIGITALIZACAO"                    AT   75
         SKIP(1) 
         "N."                                           AT 30
         crawepr.nrctremp                         FORMAT "99,999,999"
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   75
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   87 
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   98    
         SKIP(1)
         WITH NO-BOX  NO-LABELS WIDTH 101 FRAME f_titulo_alienacao_fiduciaria_pos_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         par_nrdconta
                         aux_nrctrrat 
                         aux_tpdocged                           
    WITH FRAME f_titulo_alienacao_fiduciaria_pos_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-alienacao-fiduciaria-maquina-pos-fixado (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT par_dtmvtolt,
                                                        INPUT par_idorigem,
                                                        INPUT RECID(crawepr),
                                                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:            
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).

                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

        END.

    RETURN "OK".

END PROCEDURE.

/* Alienacao Fiduciaria em Garantia - Automoveis - Pré-fixado */
PROCEDURE monta-alienacao-fiduciaria-automovel-pre-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE FINANCIAMENTO COM ALIENACAO FIDUCIARIA EM GARANTIA PRICE PRE-FIXADO" 
         "PARA USO DA DIGITALIZACAO"                    AT   75
         SKIP(1) 
         "N."                                           AT 30
         crawepr.nrctremp                         FORMAT "99,999,999"
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   75
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   87 
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   98    
         SKIP(1)
         WITH NO-BOX  NO-LABELS WIDTH 101 FRAME f_titulo_alienacao_fiduciaria_pre_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         crawepr.nrctremp
                         par_nrdconta    
                         aux_nrctrrat    
                         aux_tpdocged    
    WITH FRAME f_titulo_alienacao_fiduciaria_pre_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-alienacao-fiduciaria-automovel-pre-fixado (INPUT par_cdcooper,
                                                          INPUT par_cdagenci,
                                                          INPUT par_nrdcaixa,
                                                          INPUT par_dtmvtolt,
                                                          INPUT par_idorigem,
                                                          INPUT RECID(crawepr),
                                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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

            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
        END.

    RETURN "OK".

END PROCEDURE.

/*  Alienacao Fiduciaria em Garantia - Automoveis - Pós-fixado */
PROCEDURE monta-alienacao-fiduciaria-automovel-pos-fixado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    
    DEF VAR aux_nrctrrat          AS DECI                           NO-UNDO.
    DEF VAR aux_tpdocged          AS INTE                           NO-UNDO.
    

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_nrctrrat = crawepr.nrctremp.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                      craptab.nmsistem = "CRED"         AND         
                      craptab.tptabela = "GENERI"       AND         
                      craptab.cdempres = 00             AND         
                      craptab.cdacesso = "DIGITALIZA"   AND
                      craptab.tpregist = 5    /* Contrt. emprestimo/financiamento (GED) */
                      NO-LOCK NO-ERROR NO-WAIT.
                     
    IF  AVAIL craptab THEN
       ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).

    FORM "CONTRATO DE FINANCIAMENTO COM ALIENACAO FIDUCIARIA EM GARANTIA PRICE TR" 
         "PARA USO DA DIGITALIZACAO"                    AT   75
         SKIP(1) 
         "N."                                           AT 30
         crawepr.nrctremp                         FORMAT "99,999,999"
         par_nrdconta                    NO-LABEL FORMAT "zzzz,zzz,9" AT   75
         aux_nrctrrat                    NO-LABEL FORMAT "zz,zzz,zz9" AT   87 
         aux_tpdocged                    NO-LABEL FORMAT "zz9"        AT   98    
         SKIP(1)
         WITH NO-BOX  NO-LABELS WIDTH 101 FRAME f_titulo_alienacao_fiduciaria_pos_fixado.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
    IF  NOT AVAIL crapcop THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    FIND crawepr WHERE crawepr.cdcooper = par_cdcooper  AND
                       crawepr.nrdconta = par_nrdconta  AND
                       crawepr.nrctremp = par_nrctremp 
                       NO-LOCK NO-ERROR NO-WAIT.

    IF  NOT AVAILABLE crawepr   THEN
        DO:
            ASSIGN aux_cdcritic = 510
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                  
            RETURN "NOK".
        END.

    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + par_dsiduser.

            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
            
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 87 PAGED.
        END.

    PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.
    PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

    DISPLAY STREAM str_1 crawepr.nrctremp 
                         par_nrdconta
                         aux_nrctrrat
                         aux_tpdocged
    WITH FRAME f_titulo_alienacao_fiduciaria_pos_fixado.

    /* Chama modelo de montagem do contrato */
    RUN modelo-alienacao-fiduciaria-automovel-pos-fixado (INPUT par_cdcooper,
                                                          INPUT par_cdagenci,
                                                          INPUT par_nrdcaixa,
                                                          INPUT par_dtmvtolt,
                                                          INPUT par_idorigem,
                                                          INPUT RECID(crawepr),
                                                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".
        
    /* se nao for completa... */
    IF  par_idimpres <> 1 THEN
        DO:
            OUTPUT STREAM str_1 CLOSE.

            IF  par_flgemail     OR
                par_idorigem = 5 THEN  /** Ayllos Web **/
                DO:
                    RUN prepara-pdf-contrato (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT par_idorigem,
                                              INPUT aux_nmarquiv,
                                              INPUT aux_nmarqimp,
                                              INPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
        
                    IF  RETURN-VALUE <> "OK" THEN
                        RETURN "NOK".

                    IF  par_flgemail THEN
                        DO:
                            RUN envia-email-proposta-sede (INPUT par_cdcooper,
                                                           INPUT par_cdagenci,
                                                           INPUT par_cdoperad,
                                                           INPUT par_nrdcaixa,
                                                           INPUT par_nmdatela,
                                                           INPUT par_dtmvtolt,
                                                           INPUT par_dsiduser,
                                                           INPUT par_idorigem,
                                                           INPUT par_nrdconta,
                                                           INPUT par_nrctremp,
                                                           INPUT par_idimpres,
                                                           INPUT aux_nmarqimp,
                                                           INPUT aux_nmarqpdf).
                   
                            IF  RETURN-VALUE <> "OK" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "Nao foi possivel enviar o email".
                            
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
                
            IF  par_idorigem = 5  THEN
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
                ELSE
                    UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null"). 

            ASSIGN par_nmarqimp = aux_nmarqimp
                   par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").            

        END.

    RETURN "OK".

END PROCEDURE.


/*................................. FUNCTIONS ..............................*/
/*................................. INTERNAS ................................*/

/* Verifica da TAB016 se o interveniente esta habilitado */
FUNCTION verifica-interveniente RETURN LOGICAL 
    (par_cdagenci AS INTE, 
     par_cdcooper AS INTE):

    DEF VAR aux_contador AS INTE                                       NO-UNDO.
    DEF VAR aux_flginter AS LOGI                                       NO-UNDO.
   
    DO aux_contador = 1 TO 2:

        FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND 
                           craptab.nmsistem = "CRED"         AND
                           craptab.tptabela = "USUARI"       AND
                           craptab.cdempres = 11             AND
                           craptab.cdacesso = "PROPOSTEPR"   AND
                           craptab.tpregist = par_cdagenci   NO-LOCK NO-ERROR.
   
        IF  NOT AVAILABLE craptab  THEN
            IF  aux_contador > 1  THEN
                .
            ELSE
                DO:
                    par_cdagenci = 0.
                    NEXT.
                END.
        ELSE
            ASSIGN aux_flginter = LOGICAL(SUBSTR(craptab.dstextab,56,03)).
    END.

    RETURN aux_flginter.

END.

FUNCTION valida-proprietario RETURNS CHAR 
    (par_nrcpfbem AS DECI,
     par_cdcooper AS INTE):

    /* Verifica se o CPF/CNPJ informado como sendo proprietario do bem, faz
        parte do contrato sendo CONTRATANTE OU INTERVENIENTE ANUENTE */
   
    DEF BUFFER crabass FOR crapass.

    /* CONTRATANTE */
    FIND FIRST crabass WHERE crabass.cdcooper = par_cdcooper       AND
                             crabass.nrcpfcgc = par_nrcpfbem       AND
                             crabass.nrdconta = crawepr.nrdconta
                             NO-LOCK NO-ERROR.

    IF  AVAILABLE crabass  THEN
        RETURN crabass.nmprimtl.
         
    /* INTERVENIENTE ANUENTE */
    FIND FIRST crapavt WHERE crapavt.cdcooper = par_cdcooper       AND 
                             crapavt.nrcpfcgc = par_nrcpfbem       AND
                             crapavt.nrdconta = crawepr.nrdconta   AND
                             crapavt.nrctremp = crawepr.nrctremp   AND
                             crapavt.tpctrato = 9 NO-LOCK NO-ERROR.

    IF  AVAILABLE crapavt  THEN
        RETURN crapavt.nmdavali.

    /* PRIMEIRO TITULAR caso nao encontrar interveniente ou proprietário */
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper       AND 
                             crapass.nrdconta = crawepr.nrdconta   NO-LOCK NO-ERROR.

    IF  AVAILABLE crapass  THEN
        RETURN crapass.nmprimtl.

    RETURN "".

END FUNCTION.

/*................................ PROCEDURES ...............................*/
/*................................. INTERNAS ................................*/

PROCEDURE envia-email-proposta-sede:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
        SET h-b1wgen0024.

    IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
        RETURN "NOK".

    /** Enviar proposta para o PAC Sede via e-mail **/
    RUN executa-envio-email IN h-b1wgen0024 
                           (INPUT par_cdcooper, 
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa, 
                            INPUT par_cdoperad, 
                            INPUT par_nmdatela, 
                            INPUT par_idorigem, 
                            INPUT par_dtmvtolt, 
                            INPUT 488,
                            INPUT par_nmarqimp, 
                            INPUT par_nmarqpdf,
                            INPUT par_nrdconta, 
                            INPUT 90 /* Emprest */, 
                            INPUT par_nrctremp, 
                           OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    IF  VALID-HANDLE(h-b1wgen0024)  THEN
         DELETE PROCEDURE h-b1wgen0024.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca-bens-alienacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-bens-contratos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nmpropri AS CHAR                                     NO-UNDO.

    DEF BUFFER crabass FOR crapass.
                             
    EMPTY TEMP-TABLE tt-bens-contratos.
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.

    FIND crabass WHERE crabass.cdcooper = crawepr.cdcooper AND 
                       crabass.nrdconta = crawepr.nrdconta NO-LOCK NO-ERROR.

    FOR EACH crapbpr WHERE crapbpr.cdcooper = crawepr.cdcooper   AND
                           crapbpr.nrdconta = crawepr.nrdconta   AND
                           crapbpr.tpctrpro = 90                 AND
                           crapbpr.nrctrpro = crawepr.nrctremp   AND
                           crapbpr.flgalien = TRUE               NO-LOCK:

        IF  TRIM(crapbpr.dsbemfin) = ""   THEN
            NEXT.

        IF  crapbpr.dscatbem <> "CASA"    AND
            crapbpr.dscatbem <> "TERRENO" AND 
            crapbpr.dscatbem <> "APARTAMENTO" THEN /* Nao possuem CPF de proprietários cadastrado */
            DO:
                ASSIGN aux_nmpropri = valida-proprietario (crapbpr.nrcpfbem, par_cdcooper).
                
                IF  aux_nmpropri = "" THEN
                    DO:
                        IF  verifica-interveniente (crabass.cdagenci, par_cdcooper) THEN 
                            DO: 
                                ASSIGN aux_dscritic = "O Proprietario do bem "               +
                                                      TRIM(STRING(crapbpr.dsbemfin,"x(18)")) +
                                                      " nao faz parte do contrato.".
                                
                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,      
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).
                                               
                                RETURN "NOK".
                            END.
                    END.
            END.

        CREATE tt-bens-contratos.
        ASSIGN tt-bens-contratos.cdcooper = crapbpr.cdcooper
               tt-bens-contratos.dscatbem = CAPS(crapbpr.dscatbem)
               tt-bens-contratos.dsbemfin = crapbpr.dsbemfin
               tt-bens-contratos.dsrenava = TRIM(STRING(crapbpr.nrrenava,"999,999,999,999"))
               tt-bens-contratos.dschassi = TRIM(crapbpr.dschassi)
               tt-bens-contratos.nrdplaca = TRIM(crapbpr.nrdplaca)
               tt-bens-contratos.uflicenc = TRIM(crapbpr.uflicenc)
               tt-bens-contratos.dsanobem = STRING(crapbpr.nranobem,"9999")
               tt-bens-contratos.dsmodbem = STRING(crapbpr.nrmodbem,"9999")
               tt-bens-contratos.nmpropri = aux_nmpropri
               tt-bens-contratos.dscorbem = TRIM(crapbpr.dscorbem).
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE retorna-dados-conjuge:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nmconjug AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_tpdoccjg AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdoccjg AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nrcpfcjg AS CHAR                           NO-UNDO.

    DEF BUFFER crabass  FOR crapass.

    FIND crapcje WHERE  crapcje.cdcooper = par_cdcooper  AND 
                        crapcje.nrdconta = par_nrdconta  AND
                        crapcje.idseqttl = 1  NO-LOCK NO-ERROR.

    IF  AVAIL crapcje THEN
        DO:
            IF  crapcje.nrctacje <> 0 THEN
                DO:
                    FIND crabass WHERE 
                         crabass.cdcooper = crapcje.cdcooper    AND
                         crabass.nrdconta = crapcje.nrctacje
                         NO-LOCK NO-ERROR.

                    IF  AVAIL crabass THEN
                        DO:
                            ASSIGN par_nrdoccjg = STRING(crabass.nrdocptl)
                                   par_tpdoccjg = crabass.tpdocptl                               
                                   par_nmconjug = crabass.nmprimtl.

                            IF  crabass.nrcpfcgc > 0 THEN
                                ASSIGN par_nrcpfcjg = STRING(crabass.nrcpfcgc,"99999999999")
                                       par_nrcpfcjg = STRING(par_nrcpfcjg,"xxx.xxx.xxx-xx").
                        END.
                END.
            ELSE
                DO:
                    ASSIGN par_nrdoccjg = STRING(crapcje.nrdoccje)
                           par_tpdoccjg = crapcje.tpdoccje
                           par_nmconjug = crapcje.nmconjug.

                    IF  crapcje.nrcpfcjg > 0 THEN
                        ASSIGN par_nrcpfcjg = STRING(crapcje.nrcpfcjg,"99999999999")
                               par_nrcpfcjg = STRING(par_nrcpfcjg,"xxx.xxx.xxx-xx").
                END.
        END.

    IF  par_nrdoccjg = "" THEN
        ASSIGN par_tpdoccjg = "CI".

    RETURN "OK".

END PROCEDURE.

PROCEDURE prepara-pdf-contrato:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarquiv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.
    
        IF  NOT AVAIL crapcop THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.

        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
            SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
                ASSIGN aux_dscritic = "Handle invalido para BO b1wgen0024.".
                LEAVE.
            END.

        RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                INPUT par_nmarqpdf).

        /** Copiar pdf para visualizacao no Ayllos WEB **/
        IF  par_idorigem = 5  THEN
            DO:
                IF  SEARCH(par_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar a impressao.".
                        LEAVE.                      
                    END.
                    
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                   '"scp ' + par_nmarqpdf + ' scpuser@' + aux_srvintra +
                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                   '/temp/" 2>/dev/null').
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  VALID-HANDLE(h-b1wgen0024)  THEN
        DELETE PROCEDURE h-b1wgen0024.

    IF  aux_dscritic <> ""  OR
        aux_cdcritic  > 0   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-erro  THEN
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

PROCEDURE busca-dados-padrao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    BUSCA_DADOS:
    DO WHILE TRUE:

        FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.
        
        IF   NOT AVAILABLE crawepr   THEN
             DO:
                 ASSIGN aux_cdcritic = 510
                        aux_dscritic = "".

                 LEAVE BUSCA_DADOS.
             END.
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper     AND
                           crapass.nrdconta = crawepr.nrdconta
                           NO-LOCK NO-ERROR NO-WAIT.
    
        IF  NOT AVAIL crapass THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                LEAVE BUSCA_DADOS.
            END.
        
        FIND crapenc WHERE crapenc.cdcooper = par_cdcooper      AND
                           crapenc.nrdconta = crapass.nrdconta  AND
                           crapenc.idseqttl = 1                 AND
                           crapenc.cdseqinc = 1 
                           NO-LOCK NO-ERROR NO-WAIT.
    
        IF  NOT AVAIL crapenc THEN
            DO:
                ASSIGN aux_cdcritic = 247
                       aux_dscritic = "".
    
                LEAVE BUSCA_DADOS.
            END.

        FIND crapfin WHERE crapfin.cdcooper = par_cdcooper     AND 
                           crapfin.cdfinemp = crawepr.cdfinemp NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapfin   THEN
            DO:
                ASSIGN aux_cdcritic = 362
                       aux_dscritic = "".
                
                LEAVE BUSCA_DADOS.
            END.
        
        FIND craplcr WHERE craplcr.cdcooper = par_cdcooper     AND
                           craplcr.cdlcremp = crawepr.cdlcremp NO-LOCK NO-ERROR.
        
        IF  NOT AVAILABLE craplcr   THEN
            DO:
                ASSIGN aux_cdcritic = 363
                       aux_dscritic = "".
        
                LEAVE BUSCA_DADOS.
            END.
        
        LEAVE.
    END. /* DO WHILE TRUE BUSCA_DADOS */

    IF  aux_cdcritic <> 0  OR
        aux_dscritic <> "" THEN
        DO:
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

PROCEDURE declara-handle-bo9999:


    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                    SET h-b1wgen9999.
            
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
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

PROCEDURE deleta-handle-bo9999:

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE PROCEDURE h-b1wgen9999.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-item:

    DEF  INPUT PARAM par_nrdoitem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdoitem AS CHAR                           NO-UNDO.

    ASSIGN aux_nrdoitem = par_nrdoitem
           aux_dsdoitem = par_dsdoitem.

    DISPLAY STREAM str_1 aux_nrdoitem
                         aux_dsdoitem WITH FRAME f_item.
    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega-fiadores:
                                     
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-fiadores.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nmconjug AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcpfcjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_tpdoccjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrdoccjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcpfcgc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_inpessoa AS INTE                                   NO-UNDO.
    DEF  VAR aux_inavalis AS INTE                                   NO-UNDO.
    DEF  VAR aux_stsnrcal AS LOGI                                   NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-fiadores.
    EMPTY TEMP-TABLE tt-erro.
                   
    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.

    IF  crawepr.nrctaav1 > 0   THEN
        DO:
            FIND crabass WHERE crabass.cdcooper = par_cdcooper     AND 
                               crabass.nrdconta = crawepr.nrctaav1 NO-LOCK NO-ERROR.

            IF  NOT AVAIL crabass THEN
                DO:
                    ASSIGN aux_cdcritic = 365
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

            FIND crapenc WHERE crapenc.cdcooper = par_cdcooper      AND
                               crapenc.nrdconta = crabass.nrdconta  AND
                               crapenc.idseqttl = 1                 AND
                               crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

            IF  crabass.inpessoa = 1 THEN /* Pessoa Física */
                DO:
                    ASSIGN aux_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999")
                           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
                    
                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                                       crapttl.nrdconta = crabass.nrdconta   AND
                                       crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                        IF  AVAIL crapttl  THEN
                            DO:
                                FIND gnetcvl WHERE gnetcvl.cdestcvl = crapttl.cdestcvl NO-LOCK NO-ERROR.
                                
                                IF  NOT AVAIL gnetcvl THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 35
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

                    /* dados do conjug */
                    RUN retorna-dados-conjuge (INPUT crabass.cdcooper,
                                               INPUT crabass.nrdconta,
                                              OUTPUT aux_nmconjug,
                                              OUTPUT aux_tpdoccjg,
                                              OUTPUT aux_nrdoccjg,
                                              OUTPUT aux_nrcpfcjg).                    
                END.
            ELSE /* Pessoa Jurídica */
                ASSIGN aux_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999999")
                       aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

            CREATE tt-fiadores.
            ASSIGN tt-fiadores.nrctaava = crawepr.nrctaav1
                   tt-fiadores.nmdavali = crabass.nmprimtl
                   tt-fiadores.inavalis = 1
                   tt-fiadores.nrcpfcgc = aux_nrcpfcgc WHEN crabass.nrcpfcgc > 0
                   tt-fiadores.tpdocava = crabass.tpdocptl
                   tt-fiadores.nrdocava = crabass.nrdocptl
                   tt-fiadores.nmconjug = aux_nmconjug
                   tt-fiadores.nrcpfcjg = aux_nrcpfcjg
                   tt-fiadores.nrdoccjg = aux_nrdoccjg
                   tt-fiadores.dsendres = SUBSTRING(crapenc.dsendere,1,32)
                   tt-fiadores.nmcidade = crapenc.nmcidade
                   tt-fiadores.nmbairro = crapenc.nmbairro
                   tt-fiadores.cdufresd = crapenc.cdufende
                   tt-fiadores.nrcepend = crapenc.nrcepend
                   tt-fiadores.inpessoa = crabass.inpessoa
                   tt-fiadores.nrendere = TRIM(STRING(crapenc.nrendere,"999,999" ))
                   tt-fiadores.dsestcvl = gnetcvl.rsestcvl WHEN AVAIL gnetcvl
                   tt-fiadores.tpdoccjg = IF aux_nrdoccjg = "" THEN "CI" ELSE aux_tpdoccjg.
        END.

    /* Zerar variaveis */
    ASSIGN aux_nmconjug = ""
           aux_tpdoccjg = ""
           aux_nrdoccjg = ""
           aux_nrcpfcjg = "".

    IF  crawepr.nrctaav2 > 0   THEN
        DO:
            FIND crabass WHERE crabass.cdcooper = par_cdcooper AND 
                               crabass.nrdconta = crawepr.nrctaav2 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crabass THEN
                DO:
                    ASSIGN aux_cdcritic = 365
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

            FIND crapenc WHERE crapenc.cdcooper = par_cdcooper      AND
                               crapenc.nrdconta = crabass.nrdconta  AND
                               crapenc.idseqttl = 1                 AND
                               crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

            IF  crabass.inpessoa = 1 THEN /* Pessoa Física */
                DO:
                    ASSIGN aux_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999")
                           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").

                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                                       crapttl.nrdconta = crabass.nrdconta   AND
                                       crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                    IF  AVAIL crapttl  THEN
                        DO:
                            FIND gnetcvl WHERE gnetcvl.cdestcvl = crapttl.cdestcvl NO-LOCK NO-ERROR.                    
                        
                            IF  NOT AVAIL gnetcvl THEN
                                DO:
                                    ASSIGN aux_cdcritic = 35
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

                    /* dados do conjug */
                    RUN retorna-dados-conjuge (INPUT crabass.cdcooper,
                                               INPUT crabass.nrdconta,
                                              OUTPUT aux_nmconjug,
                                              OUTPUT aux_tpdoccjg,
                                              OUTPUT aux_nrdoccjg,
                                              OUTPUT aux_nrcpfcjg).                    
                END.
            ELSE /* Pessoa Jurídica */
                 ASSIGN aux_nrcpfcgc = STRING(crabass.nrcpfcgc,"99999999999999")
                        aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").


            CREATE tt-fiadores.
            ASSIGN tt-fiadores.nrctaava = crawepr.nrctaav2
                   tt-fiadores.nmdavali = crabass.nmprimtl
                   tt-fiadores.inavalis = 2
                   tt-fiadores.nrcpfcgc = aux_nrcpfcgc WHEN crabass.nrcpfcgc > 0
                   tt-fiadores.tpdocava = crabass.tpdocptl
                   tt-fiadores.nrdocava = crabass.nrdocptl
                   tt-fiadores.nmconjug = aux_nmconjug
                   tt-fiadores.nrcpfcjg = aux_nrcpfcjg
                   tt-fiadores.nrdoccjg = aux_nrdoccjg
                   tt-fiadores.dsendres = SUBSTRING(crapenc.dsendere,1,32)
                   tt-fiadores.nmcidade = crapenc.nmcidade
                   tt-fiadores.nmbairro = crapenc.nmbairro
                   tt-fiadores.cdufresd = crapenc.cdufende
                   tt-fiadores.nrcepend = crapenc.nrcepend
                   tt-fiadores.inpessoa = crabass.inpessoa
                   tt-fiadores.nrendere = TRIM(STRING(crapenc.nrendere,"999,999" ))
                   tt-fiadores.dsestcvl = gnetcvl.rsestcvl WHEN AVAIL gnetcvl
                   tt-fiadores.tpdoccjg = IF aux_nrdoccjg = "" THEN "CI" ELSE aux_tpdoccjg.
        END.
         
    IF  (crawepr.nmdaval1 <> " "  AND  crawepr.nrctaav1 = 0)   OR       
        (crawepr.nmdaval2 <> " "  AND  crawepr.nrctaav2 = 0)   THEN
         FOR EACH crapavt NO-LOCK WHERE   
                  crapavt.cdcooper = par_cdcooper     AND 
                  crapavt.tpctrato = 1                AND
                  crapavt.nrctremp = crawepr.nrctremp AND
                  crapavt.nrdconta = crawepr.nrdconta BY ROWID(crapavt):
    
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
      
            RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT crapavt.nrcpfcgc,
                                                OUTPUT aux_stsnrcal,
                                                OUTPUT aux_inpessoa).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.
            
            IF  NOT aux_stsnrcal  THEN
                DO:
                    ASSIGN aux_dscritic = "CPF do conjuge do 1o avalista " +
                                          "com erro.".
    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

            IF  aux_inpessoa = 1   THEN /* Pessoa Física */
                DO:
                    ASSIGN aux_nrcpfcgc = STRING(crapavt.nrcpfcgc,"99999999999")
                           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx")
                           aux_nrcpfcjg = STRING(crapavt.nrcpfcjg,"99999999999")
                           aux_nrcpfcjg = STRING(aux_nrcpfcjg,"xxx.xxx.xxx-xx").

                    FIND gnetcvl WHERE gnetcvl.cdestcvl = crapavt.cdestcvl NO-LOCK NO-ERROR.

                END.                 
             ELSE /* Pessoa Jurídica */
                  ASSIGN aux_nrcpfcgc = STRING(crapavt.nrcpfcgc,"99999999999999")
                         aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

            FIND tt-fiadores WHERE tt-fiadores.inavalis = 1 NO-LOCK NO-ERROR.

            IF  NOT AVAIL tt-fiadores THEN
                ASSIGN aux_inavalis = 1.
            ELSE
                DO:
                    FIND LAST tt-fiadores NO-LOCK NO-ERROR.

                    IF  AVAIL tt-fiadores THEN
                        ASSIGN aux_inavalis = tt-fiadores.inavalis + 1.
                END.

            CREATE tt-fiadores.
            ASSIGN tt-fiadores.nrctaava = 0
                   tt-fiadores.nmdavali = crapavt.nmdavali
                   tt-fiadores.inavalis = aux_inavalis
                   tt-fiadores.nrcpfcgc = aux_nrcpfcgc WHEN crapavt.nrcpfcgc > 0
                   tt-fiadores.tpdocava = crapavt.tpdocava
                   tt-fiadores.nrdocava = crapavt.nrdocava
                   tt-fiadores.nmconjug = crapavt.nmconjug
                   tt-fiadores.nrcpfcjg = aux_nrcpfcjg WHEN crapavt.nrcpfcjg > 0
                   tt-fiadores.nrdoccjg = crapavt.nrdoccjg
                   tt-fiadores.dsendres = crapavt.dsendres[1]
                   tt-fiadores.nmcidade = crapavt.nmcidade
                   tt-fiadores.nmbairro = crapavt.dsendres[2]
                   tt-fiadores.cdufresd = crapavt.cdufresd
                   tt-fiadores.nrcepend = crapavt.nrcepend
                   tt-fiadores.inpessoa = aux_inpessoa
                   tt-fiadores.nrendere = TRIM(STRING(crapavt.nrendere,"999,999"))
                   tt-fiadores.dsestcvl = gnetcvl.rsestcvl WHEN AVAIL gnetcvl
                   tt-fiadores.tpdoccjg = IF crapavt.nrdoccjg = "" THEN "CI" ELSE crapavt.tpdoccjg.
         END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE carrega-intervenientes-alienacao:
                                     
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-intervenientes.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nrcpfcgc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcpfcjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_inpessoa AS INTE                                   NO-UNDO.
    DEF  VAR aux_stsnrcal AS LOGI                                   NO-UNDO.

    DEF BUFFER crabass FOR crapass.

    EMPTY TEMP-TABLE tt-intervenientes.
    EMPTY TEMP-TABLE tt-erro.

    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper       AND 
                           crapavt.nrdconta = crawepr.nrdconta   AND
                           crapavt.nrctremp = crawepr.nrctremp   AND
                           crapavt.tpctrato = 9                  NO-LOCK:

        FIND FIRST crabass WHERE crabass.cdcooper = crapavt.cdcooper   AND
                                 crabass.nrcpfcgc = crapavt.nrcpfcgc
                                 NO-LOCK NO-ERROR.

        RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                  OUTPUT TABLE tt-erro).
        IF  RETURN-VALUE <> "OK" THEN
            RETURN "NOK".
  
        RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT crapavt.nrcpfcgc,
                                            OUTPUT aux_stsnrcal,
                                            OUTPUT aux_inpessoa).
        IF  RETURN-VALUE <> "OK" THEN
            DO:
                RUN deleta-handle-bo9999.
                RETURN "NOK".
            END.
    
        RUN deleta-handle-bo9999.

        IF  NOT aux_stsnrcal  THEN
            DO:
                ASSIGN aux_dscritic = "CPF do interveniente " +
                                      "com erro.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                RETURN "NOK".
            END.

        IF  aux_inpessoa = 1   THEN /* Pessoa Física */
            DO:
                ASSIGN aux_nrcpfcgc = STRING(crapavt.nrcpfcgc,"99999999999")
                       aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx")
                       aux_nrcpfcjg = STRING(crapavt.nrcpfcjg,"99999999999")
                       aux_nrcpfcjg = STRING(aux_nrcpfcjg,"xxx.xxx.xxx-xx").
                
                IF  AVAIL crabass THEN
                    DO:
                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper       AND
                                           crapttl.nrdconta = crabass.nrdconta   AND
                                           crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                        IF  AVAIL crapttl  THEN
                            DO:
                                FIND gnetcvl WHERE gnetcvl.cdestcvl = crapttl.cdestcvl NO-LOCK NO-ERROR.
                            END.
                    END.
            END.
        ELSE /* Pessoa Jurídica */
             ASSIGN aux_nrcpfcgc = STRING(crapavt.nrcpfcgc,"99999999999999")
                    aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

        CREATE tt-intervenientes.
        ASSIGN tt-intervenientes.nrctaava = crabass.nrdconta WHEN AVAIL crabass
               tt-intervenientes.nmdavali = crapavt.nmdavali
               tt-intervenientes.nrcpfcgc = aux_nrcpfcgc WHEN crapavt.nrcpfcgc > 0
               tt-intervenientes.tpdocava = crapavt.tpdocava
               tt-intervenientes.nrdocava = crapavt.nrdocava
               tt-intervenientes.nmconjug = crapavt.nmconjug
               tt-intervenientes.nrcpfcjg = aux_nrcpfcjg WHEN crapavt.nrcpfcjg > 0
               tt-intervenientes.nrdoccjg = crapavt.nrdoccjg
               tt-intervenientes.dsendres = crapavt.dsendres[1]
               tt-intervenientes.nmcidade = crapavt.nmcidade
               tt-intervenientes.nmbairro = crapavt.dsendres[2]
               tt-intervenientes.cdufresd = crapavt.cdufresd
               tt-intervenientes.nrcepend = crapavt.nrcepend
               tt-intervenientes.inpessoa = aux_inpessoa
               tt-intervenientes.nrendere = TRIM(STRING(crapavt.nrendere,"999,999"))
               tt-intervenientes.dsestcvl = gnetcvl.rsestcvl WHEN AVAIL gnetcvl
               tt-intervenientes.tpdoccjg = IF crapavt.nrdoccjg = "" THEN "CI" ELSE crapavt.tpdoccjg.
    END.                       

    RETURN "OK".

END PROCEDURE.
              
/*................................ PROCEDURES ...............................*/
/*................................ CLAUSULAS ................................*/

PROCEDURE insere-clausula-contratada:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_nrdocnpj AS CHAR                                   NO-UNDO.
    DEF  VAR aux_cdagenci AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcepend AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmcidauf AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmcooper AS CHAR                                   NO-UNDO.

    FORM SKIP(1)
         par_dsnrclau     FORMAT "X(4)"
         "CONTRATADA:" 
         aux_nmcooper FORMAT "x(64)"
         SPACE(6)
         "PA"
         crapass.cdagenci FORMAT "999"
         SKIP
         "INSCRITA NO CNPJ "
         aux_nrdocnpj     FORMAT "x(18)"
         SPACE(2) 
         "ESTABELECIDA NA"
         crapcop.dsendcop
         SKIP
         "N."
         crapcop.nrendcop FORMAT "99,999"
         SPACE(0)
         " BAIRRO"
         crapcop.nmbairro
         SPACE(26)
         aux_nmcidauf FORMAT "X(28)"
         SPACE(0)
         " CEP"
         aux_nrcepend FORMAT "X(09)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_contratada.
         
    ASSIGN aux_nrdocnpj = STRING(STRING(crapcop.nrdocnpj, "99999999999999"), "xx.xxx.xxx/xxxx-xx")
           aux_nrcepend = STRING(STRING(crapcop.nrcepend, "99999999"), "xxxxx-xxx")
           aux_nmcidauf = crapcop.nmcidade + "/" + crapcop.cdufdcop
           aux_nmcooper = crapcop.nmextcop + " - " + crapcop.nmrescop.

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_nmcooper
                         crapass.cdagenci
                         crapcop.dsendcop
                         crapcop.nrendcop
                         crapcop.nmbairro
                         aux_nrcepend
                         aux_nrdocnpj
                         aux_nmcidauf
                         WITH FRAME f_clausula_contratada.
                         
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-contratante:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_nrcpfcgc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrdoccjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_tpdoccjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcpfcjg AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nrcepend AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmconjug AS CHAR                                   NO-UNDO.
    DEF  VAR aux_tpcpfcgc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmcidauf AS CHAR                                   NO-UNDO.
    DEF  VAR aux_rsestcvl AS CHAR                                   NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(4)"
         "CONTRATANTE:" 
         crapass.nmprimtl
         SPACE(7)
         "CONTA-CORRENTE" 
         crapass.nrdconta 
         SKIP
         aux_tpcpfcgc     FORMAT "X(04)"
         aux_nrcpfcgc     FORMAT "x(18)"         
         crapass.tpdocptl 
         crapass.nrdocptl
         aux_rsestcvl     FORMAT "x(25)"
         SKIP
         "RESIDENTE E DOMICILIADO NA" crapenc.dsendere
         SPACE(8)
         "N."
         crapenc.nrendere
         SKIP
         "BAIRRO"
         crapenc.nmbairro
         SPACE(11)
         aux_nmcidauf FORMAT "X(28)"
         SPACE(1)
         "CEP"
         aux_nrcepend FORMAT "X(09)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_contratante.
         
    FORM par_dsnrclau     FORMAT "X(4)"
         "CONTRATANTE: " crapass.nmprimtl
         SPACE(6)
         "CONTA-CORRENTE:" 
         crapass.nrdconta
         SKIP
         aux_tpcpfcgc     FORMAT "X(04)" 
         aux_nrcpfcgc     FORMAT "x(18)"
         SPACE(0)
         crapass.tpdocptl 
         crapass.nrdocptl
         aux_rsestcvl     FORMAT "x(25)"
         SKIP
         "RESIDENTE E DOMICILIADO NA" 
         crapenc.dsendere
         SPACE(8)
         "N."
         crapenc.nrendere
         SPACE(0)
         SKIP
         "BAIRRO"
         crapenc.nmbairro
         SPACE(11)
         aux_nmcidauf FORMAT "X(28)"
         SPACE(1)
         "CEP"
         aux_nrcepend FORMAT "X(09)"
         SKIP(0)
         "CONJUGE:"
         aux_nmconjug FORMAT "x(40)"
         SPACE(9)
         "CPF"
         aux_nrcpfcjg FORMAT "x(14)"
         SPACE(1)     
         aux_tpdoccjg FORMAT "x(02)"
         aux_nrdoccjg FORMAT "x(21)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_contratante_conjuge.

    IF  crapass.inpessoa = 1 THEN /* Pessoa Física */
        DO:
            ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                   aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx")
                   aux_tpcpfcgc = "CPF"
                   aux_rsestcvl = "ESTADO CIVIL ".

            FIND FIRST crapttl WHERE crapttl.cdcooper = crapass.cdcooper
                                 AND crapttl.nrdconta = crapass.nrdconta
                                 AND crapttl.idseqttl = 1
                               NO-LOCK NO-ERROR.

            IF  AVAIL crapttl THEN
                DO:
                    FIND gnetcvl WHERE gnetcvl.cdestcvl = crapttl.cdestcvl NO-LOCK NO-ERROR.

                    IF  AVAIL gnetcvl THEN
                        ASSIGN aux_rsestcvl = aux_rsestcvl + gnetcvl.rsestcvl.
                END.

            /* dados do conjuge */
            RUN retorna-dados-conjuge (INPUT crapass.cdcooper,
                                       INPUT crapass.nrdconta,
                                      OUTPUT aux_nmconjug,
                                      OUTPUT aux_tpdoccjg,
                                      OUTPUT aux_nrdoccjg,
                                      OUTPUT aux_nrcpfcjg).
        END.
    ELSE /* Pessoa Jurídica */
        ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx")
               aux_tpcpfcgc = "CNPJ".

    ASSIGN aux_nrcepend = STRING(STRING(crapenc.nrcepend, "99999999"), "xxxxx-xxx")
           aux_nmcidauf = crapenc.nmcidade + "/" + crapenc.cdufende.    

    IF  aux_nmconjug <> "" THEN
        DISPLAY STREAM str_1 par_dsnrclau
                             crapass.nmprimtl
                             crapass.nrdconta
                             aux_nrcpfcgc WHEN crapass.nrcpfcgc > 0
                             aux_tpcpfcgc
                             aux_nmcidauf
                             aux_rsestcvl
                             crapenc.dsendere
                             crapenc.nrendere
                             crapass.tpdocptl
                             crapass.nrdocptl
                             crapenc.nmbairro
                             aux_nrcepend
                             aux_nmconjug
                             aux_tpdoccjg
                             aux_nrdoccjg
                             aux_nrcpfcjg WHEN aux_nrcpfcjg <> ""
                             WITH FRAME f_clausula_contratante_conjuge.
    ELSE
        DISPLAY STREAM str_1 par_dsnrclau
                             crapass.nmprimtl
                             crapass.nrdconta
                             aux_nrcpfcgc WHEN crapass.nrcpfcgc > 0
                             aux_tpcpfcgc
                             aux_nmcidauf
                             aux_rsestcvl
                             crapenc.dsendere
                             crapass.tpdocptl
                             crapass.nrdocptl
                             crapenc.nrendere
                             crapenc.nmbairro
                             aux_nrcepend
                             WITH FRAME f_clausula_contratante.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-valor-extenso-prestacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlnumero LIKE crawepr.vlpreemp             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nrcpfcgc  AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdlinha  AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdlinha2 AS CHAR                                   NO-UNDO.
    DEF  VAR aux_vlnumero  AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsvalext  AS CHAR    EXTENT 3                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau     FORMAT "X(4)"
         aux_dsdlinha     FORMAT "X(96)"
         SKIP
         aux_dsdlinha2     FORMAT "X(101)"
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_valor_extenso.

    RUN declara-handle-bo9999 (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                              OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlnumero,
                                       INPUT 70,
                                       INPUT 99,
                                       INPUT "M",
                                      OUTPUT aux_dsvalext[1],
                                      OUTPUT aux_dsvalext[2]).
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            RUN deleta-handle-bo9999.
            RETURN "NOK".
        END.

    RUN deleta-handle-bo9999.

    ASSIGN aux_dsvalext[1] = LC(aux_dsvalext[1])
           aux_dsvalext[2] = LC(aux_dsvalext[2])
           aux_vlnumero    = STRING(par_vlnumero,"999,999,999,999.99")
           aux_vlnumero    = STRING(aux_vlnumero,"xxxxxxxxxxxxxxxxxx")
           aux_vlnumero    = LEFT-TRIM(aux_vlnumero, "0.")
           aux_dsdlinha    = "Valor: " + aux_dsdmoeda + " " + aux_vlnumero + " (" + aux_dsvalext[1]
           aux_dsdlinha    = aux_dsdlinha + FILL("*", INTEGER(96 - LENGTH(aux_dsdlinha)))
           aux_dsdlinha2   = aux_dsvalext[2]
           aux_dsdlinha2   = aux_dsdlinha2 + ").".

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_dsdlinha
                         aux_dsdlinha2
                         WITH FRAME f_clausula_valor_extenso.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-valor-extenso:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlnumero LIKE crawepr.vlpreemp             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nrcpfcgc  AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdlinha  AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdlinha2 AS CHAR                                   NO-UNDO.
    DEF  VAR aux_vlnumero  AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsvalext  AS CHAR    EXTENT 3                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau     FORMAT "X(23)"
         aux_dsdlinha     FORMAT "X(77)"
         SKIP
         aux_dsdlinha2    FORMAT "X(101)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_valor_extenso.

    RUN declara-handle-bo9999 (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                              OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RUN valor-extenso IN h-b1wgen9999 (INPUT par_vlnumero,
                                       INPUT 54,
                                       INPUT 99,
                                       INPUT "M",
                                      OUTPUT aux_dsvalext[1],
                                      OUTPUT aux_dsvalext[2]).
    IF  RETURN-VALUE <> "OK" THEN
        DO:
            RUN deleta-handle-bo9999.
            RETURN "NOK".
        END.

    RUN deleta-handle-bo9999.

    ASSIGN aux_dsvalext[1] = LC(aux_dsvalext[1])
           aux_dsvalext[2] = LC(aux_dsvalext[2])
           aux_vlnumero    = STRING(par_vlnumero,"999,999,999,999.99")
           aux_vlnumero    = STRING(aux_vlnumero,"xxxxxxxxxxxxxxxxxx")
           aux_vlnumero    = LEFT-TRIM(aux_vlnumero, "0.")
           aux_dsdlinha    = aux_dsdmoeda + " " + aux_vlnumero + " (" + aux_dsvalext[1]
           aux_dsdlinha    = aux_dsdlinha + FILL("*", INTEGER(77 - LENGTH(aux_dsdlinha)))
           aux_dsdlinha2   = aux_dsvalext[2]
           aux_dsdlinha2   = aux_dsdlinha2 + ").".

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_dsdlinha
                         aux_dsdlinha2
                         WITH FRAME f_clausula_valor_extenso.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-prazo-tolerancia:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clencfin AS CHAR                           NO-UNDO. /* ENCARGOS FINANCEIROS */
    DEF  INPUT PARAM par_qttolatr AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsvalext AS CHAR    EXTENT 3                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau     FORMAT "X(4)"
         "Para fins de cobranca dos juros moratorios e da multa previstos no item" par_clencfin ","
         "fica estabelecido o prazo de tolerancia de"
         par_qttolatr     FORMAT "z9"
         "(" 
         SPACE(0)
         aux_dsvalext[1]  FORMAT "X(20)"
         SPACE(0)
         ") dias corridos, contados da data"
         "de vencimento da parcela nao paga." 
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_subclausula1_prazo_tolerancia.

    IF  par_qttolatr > 0 THEN
        DO:
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
            
            RUN valor-extenso IN h-b1wgen9999 (INPUT par_qttolatr,
                                               INPUT 25,
                                               INPUT 71,
                                               INPUT "I",
                                              OUTPUT aux_dsvalext[1],
                                              OUTPUT aux_dsvalext[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
            
            RUN deleta-handle-bo9999.

            ASSIGN aux_dsvalext[1] = LC(aux_dsvalext[1]) + FILL("*", INTEGER(20 - LENGTH(aux_dsvalext[1])))
                   aux_dsvalext[2] = LC(aux_dsvalext[2]).
        END.

    DISPLAY STREAM str_1 par_dsnrclau
                         par_qttolatr
                         par_clencfin FORMAT "X(06)"
                         aux_dsvalext[1]
                         WITH FRAME f_subclausula1_prazo_tolerancia.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula2-prazo-tolerancia:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cldiasto AS CHAR                           NO-UNDO. /* DIAS DE TOLERANCIA */
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "Decorrido o prazo de tolerancia previsto no item" par_cldiasto ", incidirao sobre o encargo mensal"
         "vencido e nao pago, juros moratorios e multa, retroativos a data de vencimento da parcela, sem"
         "prejuizo dos demais encargos contratualmente previstos."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_subclausula2_prazo_tolerancia.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_cldiasto FORMAT "X(06)"
                              WITH FRAME f_subclausula2_prazo_tolerancia.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-finalidade:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_dsfinemp AS CHAR                                   NO-UNDO.

    FORM par_dsnrclau                FORMAT "X(4)"
         "Finalidade:" aux_dsfinemp  FORMAT "x(50)"
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_finalidade.

    ASSIGN aux_dsfinemp = TRIM(crapfin.dsfinemp) + " (" +
                          STRING(crapfin.cdfinemp,"999") + ").".

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_dsfinemp
                         WITH FRAME f_clausula_finalidade.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-linha-de-credito:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_dslcremp AS CHAR                                   NO-UNDO.

    FORM par_dsnrclau                      FORMAT "X(4)"
         "Linha de Credito:" aux_dslcremp  FORMAT "x(50)"
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_clausula_linha_de_credito.

    ASSIGN aux_dslcremp = TRIM(craplcr.dslcremp) + " (" +
                        STRING(craplcr.cdlcremp,"9999") + ").".

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_dslcremp
                         WITH FRAME f_clausula_linha_de_credito.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-encargos-financeiros:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsremuan AS CHAR    EXTENT 3                       NO-UNDO.
    DEF  VAR aux_dsremuam AS CHAR    EXTENT 3                       NO-UNDO.
    DEF  VAR aux_taxreman AS DECI                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau     FORMAT "X(4)"
         "Encargos Financeiros Remuneratorios:"
         aux_taxreman     FORMAT "999.99"
         SPACE(0)
         "% ("
         SPACE(0)
         aux_dsremuan[1]  FORMAT "X(50)"
         aux_dsremuan[2]  FORMAT "X(30)"
         SPACE(0)
         ") ao ano;"
         craplcr.txminima FORMAT "999.99"
         SPACE(0)
         "% ("
         SPACE(0)
         aux_dsremuam[1]  FORMAT "X(52)"
         aux_dsremuam[2]  FORMAT "X(30)"
         SPACE(0)
         ") ao mes, capitalizados mensalmente. "
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 
         FRAME f_insere_clausula_encargos_financeiros_remun.

    IF  craplcr.txminima > 0 THEN
        DO:
            ASSIGN aux_taxreman = ROUND((EXP(1 + (craplcr.txminima / 100),12) - 1) * 100,2).
            
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_taxreman,
                                               INPUT 50,
                                               INPUT 30,
                                               INPUT "P",
                                              OUTPUT aux_dsremuan[1],
                                              OUTPUT aux_dsremuan[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.

            RUN valor-extenso IN h-b1wgen9999 (INPUT craplcr.txminima,
                                               INPUT 50,
                                               INPUT 30,
                                               INPUT "P",
                                              OUTPUT aux_dsremuam[1],
                                              OUTPUT aux_dsremuam[2]).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
                
            RUN deleta-handle-bo9999.
            
            ASSIGN aux_dsremuan[1] = LC(aux_dsremuan[1]) + FILL("*", INTEGER(50 - LENGTH(aux_dsremuan[1])))
                   aux_dsremuan[2] = LC(aux_dsremuan[2]) + FILL("*", INTEGER(30 - LENGTH(aux_dsremuan[2])))                   
                   aux_dsremuam[1] = LC(aux_dsremuam[1]) + FILL("*", INTEGER(52 - LENGTH(aux_dsremuam[1])))
                   aux_dsremuam[2] = LC(aux_dsremuam[2]) + FILL("*", INTEGER(30 - LENGTH(aux_dsremuam[2]))).
        END.
    ELSE
        ASSIGN aux_dsremuan[1] = "zero por cento" + FILL("*", INTEGER(50 - 14))
               aux_dsremuan[2] = FILL("*", 30)
               aux_dsremuam[1] = "zero por cento" + FILL("*", INTEGER(52 - 14))
               aux_dsremuam[2] = FILL("*", 30).

    DISPLAY STREAM str_1 par_dsnrclau
                         craplcr.txminima
                         aux_taxreman
                         aux_dsremuan[1]
                         aux_dsremuan[2]
                         aux_dsremuam[1]
                         aux_dsremuam[2]
                         WITH FRAME f_insere_clausula_encargos_financeiros_remun.
    RETURN "OK".

END PROCEDURE.
                                      
PROCEDURE insere-clausula-encargos-financeiros-remun-minimos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsremuan AS CHAR    EXTENT 3                       NO-UNDO.
    DEF  VAR aux_dsremuam AS CHAR    EXTENT 3                       NO-UNDO.
    DEF  VAR aux_taxreman AS DECI                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau     FORMAT "X(4)"
         "Encargos Financeiros Remuneratorios Minimos:"
         aux_taxreman     FORMAT "999.99"
         SPACE(0)
         "% ("
         SPACE(0)
         aux_dsremuan[1]  FORMAT "X(42)"
         aux_dsremuan[2]  FORMAT "X(30)"
         SPACE(0)
         ") ao ano, capitalizados mensalmente pela taxa de"
         craplcr.txminima FORMAT "999.99"
         SPACE(0)
         "% ("
         SPACE(0)
         aux_dsremuam[1]  FORMAT "X(13)"
         aux_dsremuam[2]  FORMAT "X(65)"
         SPACE(0)
         ") ao mes."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 
         FRAME f_insere_clausula_encargos_financeiros_remun_minimos.

    IF  craplcr.txminima > 0 THEN
        DO:
            ASSIGN aux_taxreman = ROUND((EXP(1 + (craplcr.txminima / 100),12) - 1) * 100,2).
            
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_taxreman,
                                               INPUT 42,
                                               INPUT 30,
                                               INPUT "P",
                                              OUTPUT aux_dsremuan[1],
                                              OUTPUT aux_dsremuan[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
            
            RUN valor-extenso IN h-b1wgen9999 (INPUT craplcr.txminima,
                                               INPUT 13,
                                               INPUT 65,
                                               INPUT "P",
                                              OUTPUT aux_dsremuam[1],
                                              OUTPUT aux_dsremuam[2]).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.

            ASSIGN aux_dsremuan[1] = LC(aux_dsremuan[1]) + FILL("*", INTEGER(42 - LENGTH(aux_dsremuan[1])))
                   aux_dsremuan[2] = LC(aux_dsremuan[2]) + FILL("*", INTEGER(30 - LENGTH(aux_dsremuan[2])))
                   aux_dsremuam[1] = LC(aux_dsremuam[1]) + FILL("*", INTEGER(13 - LENGTH(aux_dsremuam[1])))
                   aux_dsremuam[2] = LC(aux_dsremuam[2]) + FILL("*", INTEGER(65 - LENGTH(aux_dsremuam[2]))).
        END.
    ELSE
        ASSIGN aux_dsremuan[1] = "zero por cento" + FILL("*", INTEGER(42 - 14))
               aux_dsremuan[2] = FILL("*", 30)
               aux_dsremuam[1] = "zero por cento" + FILL("*", INTEGER(13 - 14))
               aux_dsremuam[2] = FILL("*", 65).

    DISPLAY STREAM str_1 par_dsnrclau
                         craplcr.txminima
                         aux_dsremuam[1]
                         aux_dsremuam[2]
                         aux_taxreman
                         aux_dsremuan[1]
                         aux_dsremuan[2]
                         WITH FRAME f_insere_clausula_encargos_financeiros_remun_minimos.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula-composicao-encargos-financeiros:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclan AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsjremam AS CHAR    EXTENT 2                       NO-UNDO.
    DEF  VAR aux_dsjreman AS CHAR    EXTENT 2                       NO-UNDO.
    DEF  VAR aux_taxjrean AS DECI                                   NO-UNDO.
    DEF  VAR aux_taxjream AS DECI                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    FORM par_dsnrclau     FORMAT "X(6)"
         "Para a composicao dos Encargos Financeiros Minimos fixados no item"  par_dsnrclan FORMAT "X(4)" "foram considerados os"
         "seguintes parametros:"
         SKIP
         "a) Juros remuneratorios de"
         aux_taxjrean     FORMAT "999.99"
         SPACE(0)
         "% ("
         SPACE(0)
         aux_dsjreman[1]  FORMAT "X(65)" 
         aux_dsjreman[2]  FORMAT "X(11)"
         SPACE(0)
         ") ao ano, fixos"
         aux_taxjream     FORMAT "999.99"
         SPACE(0)
         "% ("
         SPACE(0)
         aux_dsjremam[1]  FORMAT "X(65)" 
         aux_dsjremam[2]  FORMAT "X(09)"
         SPACE(0)
         ") ao mes."
         SKIP
         "b) Atualizacao monetaria por estimativa, projetada como base de referencia pelo"
         "INPC/IBGE."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula_composicao_encargos_financeiros.

    IF  crawepr.tpemprst = 0 THEN /* Pós-fixado */
        ASSIGN aux_taxjream = craplcr.txjurfix.
    ELSE
    IF  crawepr.tpemprst = 1 THEN /* Pré-fixado */
        ASSIGN aux_taxjream = craplcr.perjurmo.

    IF  aux_taxjream > 0 THEN
        DO:
            ASSIGN aux_taxjrean = ROUND((EXP(1 + (aux_taxjream / 100),12) - 1) * 100,2).

            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_taxjrean,
                                               INPUT 65,
                                               INPUT 11,
                                               INPUT "P",
                                              OUTPUT aux_dsjreman[1],
                                              OUTPUT aux_dsjreman[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
                
            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_taxjream,
                                               INPUT 65,
                                               INPUT 9,
                                               INPUT "P",
                                              OUTPUT aux_dsjremam[1],
                                              OUTPUT aux_dsjremam[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.

            ASSIGN aux_dsjreman[1] = LC(aux_dsjreman[1]) + FILL("*", INTEGER(65 - LENGTH(aux_dsjreman[1])))
                   aux_dsjreman[2] = LC(aux_dsjreman[2]) + FILL("*", INTEGER(11 - LENGTH(aux_dsjreman[2])))
                   aux_dsjremam[1] = LC(aux_dsjremam[1]) + FILL("*", INTEGER(65 - LENGTH(aux_dsjremam[1])))
                   aux_dsjremam[2] = LC(aux_dsjremam[2]) + FILL("*", INTEGER(09 - LENGTH(aux_dsjremam[2]))).
        END.
    ELSE
        ASSIGN aux_dsjreman[1] = "zero por cento" + FILL("*", INTEGER(65 - 14))
               aux_dsjreman[2] = FILL("*", 11)
               aux_dsjremam[1] = "zero por cento" + FILL("*", INTEGER(65 - 14))
               aux_dsjremam[2] = FILL("*", 09).

    DISPLAY STREAM str_1 par_dsnrclau
                         par_dsnrclan
                         aux_taxjrean
                         aux_dsjreman[1]
                         aux_dsjreman[2] 
                         aux_taxjream
                         aux_dsjremam[1]
                         aux_dsjremam[2]
                         WITH FRAME f_insere_subclausula_composicao_encargos_financeiros.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-juros-moratorios:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsjmoran AS CHAR    EXTENT 2                       NO-UNDO.
    DEF  VAR aux_txjmoran AS DECI                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau     FORMAT "X(4)"
         "Juros moratorios:"
         aux_txjmoran     FORMAT "999.99"
         SPACE(0)
         "% (" 
         SPACE(0)
         aux_dsjmoran[1]  FORMAT "X(69)"
         aux_dsjmoran[2]  FORMAT "X(08)"
         SPACE(0)
         ") ao ano ("
         SPACE(0)
         craplcr.perjurmo FORMAT "999.99"
         "% ao mes)."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 
         FRAME f_insere_clausula_juros_moratorios.

    IF  craplcr.perjurmo > 0 THEN
        DO:
            ASSIGN aux_txjmoran = (craplcr.perjurmo * 12).

            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_txjmoran,
                                               INPUT 69,
                                               INPUT 08,
                                               INPUT "P",
                                              OUTPUT aux_dsjmoran[1],
                                              OUTPUT aux_dsjmoran[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.

            ASSIGN aux_dsjmoran[1] = LC(aux_dsjmoran[1]) + FILL("*", INTEGER(69 - LENGTH(aux_dsjmoran[1])))
                   aux_dsjmoran[2] = LC(aux_dsjmoran[2]) + FILL("*", INTEGER(08 - LENGTH(aux_dsjmoran[2]))).
        END.
    ELSE
        ASSIGN aux_dsjmoran[1] = "zero por cento" + FILL("*", INTEGER(69 - 14))
               aux_dsjmoran[2] = FILL("*", 08).

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_txjmoran
                         aux_dsjmoran[1]
                         aux_dsjmoran[2]
                         craplcr.perjurmo
                         WITH FRAME f_insere_clausula_juros_moratorios.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-multa:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgcobmu AS LOGICAL                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsmultam AS CHAR    EXTENT 2                       NO-UNDO.
    DEF  VAR aux_permulam AS DECI                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau    FORMAT "X(4)"
         "Multa:"
         aux_permulam    FORMAT "999.99" 
         SPACE(0)
         "% (" 
         SPACE(0)
         aux_dsmultam[1] FORMAT "X(79)"
         SPACE(0)
         ")"
         "sobre o valor da parcela vencida e nao paga."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_multa.

    /* Verifica se cobra multa */
    IF par_flgcobmu THEN
       DO:
            FIND craptab WHERE craptab.cdcooper = 3              AND
                               craptab.nmsistem = "CRED"         AND
                               craptab.tptabela = "USUARI"       AND
                               craptab.cdempres = 11             AND
                               craptab.cdacesso = "PAREMPCTL"    AND
                               craptab.tpregist = 01    
                               NO-LOCK NO-ERROR.
        
            IF  AVAIL craptab THEN
                ASSIGN aux_permulam = DEC(SUBSTRING(craptab.dstextab,1,6)).

       END.

    IF  aux_permulam > 0 THEN
        DO:
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_permulam,
                                               INPUT 79,
                                               INPUT 10,
                                               INPUT "P",
                                               OUTPUT aux_dsmultam[1],
                                               OUTPUT aux_dsmultam[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.

            ASSIGN aux_dsmultam[1] = LC(aux_dsmultam[1]) + FILL("*", INTEGER(79 - LENGTH(aux_dsmultam[1]))).

        END.
    ELSE
        ASSIGN aux_dsmultam[1] = "zero por cento" + FILL("*", INTEGER(79 - 14)).

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_dsmultam[1]
                         aux_permulam
                         WITH FRAME f_insere_clausula_multa.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-cet:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dstaxcet AS CHAR    EXTENT 2                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Custo Efetivo Total - CET:"
         crawepr.percetop
         SPACE(0)
         "% (" 
         SPACE(0)
         aux_dstaxcet[1]   FORMAT "X(60)"
         aux_dstaxcet[2]   FORMAT "X(14)"
         SPACE(0)
         ") ao ano."       
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_cet.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Custo Efetivo Total - CET:"
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_cet_vazio.

    IF  crawepr.percetop > 0 THEN
        DO:
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".
            
            IF crawepr.percetop > 100 THEN
            DO:
                RUN deleta-handle-bo9999.

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Para efetuar a impressao, " +
                                      "informe percentual do CET abaixo de 100%.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
    
                RETURN "NOK".
            END.

            RUN valor-extenso IN h-b1wgen9999 (INPUT crawepr.percetop,
                                               INPUT 60,
                                               INPUT 14,
                                               INPUT "P",
                                              OUTPUT aux_dstaxcet[1],
                                              OUTPUT aux_dstaxcet[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel compor valor por extenso.".
        
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.

            ASSIGN aux_dstaxcet[1] = LC(aux_dstaxcet[1]) + FILL("*", INTEGER(60 - LENGTH(aux_dstaxcet[1]))).
                   aux_dstaxcet[2] = LC(aux_dstaxcet[2]) + FILL("*", INTEGER(14 - LENGTH(aux_dstaxcet[2]))).

            DISPLAY STREAM str_1 par_dsnrclau
                                 crawepr.percetop
                                 aux_dstaxcet[1]
                                 aux_dstaxcet[2]
                                 WITH FRAME f_insere_clausula_cet.
        END.
    ELSE
        DISPLAY STREAM str_1 par_dsnrclau WITH FRAME f_insere_clausula_cet_vazio.
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-parc-mens-previstas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dspreemp AS CHAR    EXTENT 2                       NO-UNDO.
    DEF  VAR aux_qtpreemp AS INTE                                   NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Total de parcelas mensais previstas:"
         aux_qtpreemp      FORMAT "999"
         "(" 
         SPACE(0)
         aux_dspreemp[1]   FORMAT "X(23)"
         SPACE(0)
         ")."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_parc_mens_previstas.

    ASSIGN aux_qtpreemp = crawepr.qtpreemp.

    IF  aux_qtpreemp > 0 THEN
        DO:
            RUN declara-handle-bo9999 (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
            IF  RETURN-VALUE <> "OK" THEN
                RETURN "NOK".

            RUN valor-extenso IN h-b1wgen9999 (INPUT aux_qtpreemp,
                                               INPUT 23,
                                               INPUT 20,
                                               INPUT "I",
                                               OUTPUT aux_dspreemp[1],
                                               OUTPUT aux_dspreemp[2]).
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN deleta-handle-bo9999.
                    RETURN "NOK".
                END.
        
            RUN deleta-handle-bo9999.

            ASSIGN aux_dspreemp[1] = LC(aux_dspreemp[1]) + FILL("*", INTEGER(23 - LENGTH(aux_dspreemp[1]))).
        END.
    ELSE
        ASSIGN aux_dspreemp[1] = "zero".

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_qtpreemp
                         aux_dspreemp[1]
                         WITH FRAME f_insere_clausula_parc_mens_previstas.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-data-prim-pagto:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_dsdpagto AS CHAR                                   NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Data do primeiro pagamento:"
         aux_dsdpagto      FORMAT "x(32)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_data_prim_pagto.

    IF  crawepr.tpdescto = 2  THEN
        ASSIGN aux_dsdpagto = " Iniciando a partir de " + 
                              TRIM(STRING(MONTH(crawepr.dtdpagto),"99")) + "/" + 
                              TRIM(STRING(YEAR(crawepr.dtdpagto),"9999")) + ".".
    ELSE
        ASSIGN aux_dsdpagto = TRIM(STRING(crawepr.dtdpagto,"99/99/9999")) + ".".

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_dsdpagto WITH FRAME f_insere_clausula_data_prim_pagto.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-forma-pagto:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_diapagto AS INTE                                   NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Forma de pagamento: Debito em consignacao em folha de pagamento."
         SKIP
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_forma_pagto_folha.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Forma de pagamento: Debito em conta corrente no dia"
         aux_diapagto      FORMAT "z9"
         "de cada mes."
         SKIP
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_forma_pagto_cc.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Forma de pagamento: Debito em conta corrente na data do credito dos salarios "
         SKIP
         "do COOPERADO(A)."
         SKIP
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_forma_pagto_cc_salario.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Debito em conta corrente na data de vencimento"
         "escolhida pelo COOPERADO(S)."
         SKIP
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_forma_pagto_cc_pre_fixada.

    ASSIGN aux_diapagto = DAY(crawepr.dtdpagto).

    IF  crawepr.tpdescto = 2  THEN
        DISPLAY STREAM str_1 par_dsnrclau WITH FRAME f_insere_clausula_forma_pagto_folha.
    ELSE
        IF  crawepr.flgpagto   THEN
            DISPLAY STREAM str_1 par_dsnrclau WITH FRAME f_insere_clausula_forma_pagto_cc_salario.
        ELSE
            IF  crawepr.tpemprst = 0 THEN
                DISPLAY STREAM str_1 par_dsnrclau aux_diapagto WITH FRAME f_insere_clausula_forma_pagto_cc.
            ELSE
                DISPLAY STREAM str_1 par_dsnrclau WITH FRAME f_insere_clausula_forma_pagto_cc_pre_fixada.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-terceiros-garantidores:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FORM "NAO HA TERCEIROS GARANTIDORES"
         SKIP(1)
         WITH COLUMN 2 NO-BOX NO-LABELS WIDTH 101 FRAME f_sem_garantidores_fiadores.
    
    RUN carrega-fiadores (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_recidepr,
                         OUTPUT TABLE tt-fiadores,
                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN                      
        RETURN "NOK".

    RUN carrega-intervenientes-alienacao (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_recidepr,
                                         OUTPUT TABLE tt-intervenientes,
                                         OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN                      
        RETURN "NOK".

    IF  NOT TEMP-TABLE tt-fiadores:HAS-RECORDS       AND
        NOT TEMP-TABLE tt-intervenientes:HAS-RECORDS THEN
        DO:
            DISPLAY  STREAM str_1 WITH FRAME f_sem_garantidores_fiadores.
            RETURN "OK".
        END.

    DISPLAY STREAM str_1 SKIP.

    /* Encontrados Terceiros Garantidores para esse contrado */
    RUN insere-clausula-fiador (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT RECID(crawepr),
                               OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN                      
        RETURN "NOK".

    RUN insere-clausula-interveniente (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT RECID(crawepr),
                                      OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN                      
        RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-fiador:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nrdfiado AS INTE                                   NO-UNDO.
    DEF  VAR aux_nrultreg AS INTE                                   NO-UNDO.
    DEF  VAR aux_dsendres AS CHAR                                   NO-UNDO.
    DEF  VAR aux_tpcpfcgc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmcidauf AS CHAR                                   NO-UNDO.
    DEF  VAR aux_rsestcvl AS CHAR                                   NO-UNDO.

    FORM "FIADOR"
         aux_nrdfiado      FORMAT "9" 
         SPACE(0)
         ":"
         tt-fiadores.nmdavali 
         aux_rsestcvl               FORMAT "x(25)"
         SPACE(0)
         aux_dsendres               FORMAT "x(48)" 
         SPACE(3)
         "BAIRRO"
         tt-fiadores.nmbairro 
         SPACE(0)         
         aux_nmcidauf               FORMAT "X(28)"
         SPACE(23)
         aux_tpcpfcgc               FORMAT "X(04)"
         tt-fiadores.nrcpfcgc       FORMAT "x(18)"
         tt-fiadores.tpdocava 
         tt-fiadores.nrdocava
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS DOWN WIDTH 101 FRAME f_insere_clausula_fiador.

    FORM "FIADOR"
         aux_nrdfiado      FORMAT "9" 
         SPACE(0)
         ":"
         tt-fiadores.nmdavali 
         aux_rsestcvl               FORMAT "x(25)"
         SPACE(0)
         aux_dsendres               FORMAT "x(48)" 
         SPACE(3)
         "BAIRRO"
         SPACE(3)
         tt-fiadores.nmbairro 
         SPACE(0)
         aux_nmcidauf               FORMAT "X(28)"
         SPACE(23)
         aux_tpcpfcgc               FORMAT "X(04)"
         tt-fiadores.nrcpfcgc       FORMAT "x(18)"
         tt-fiadores.tpdocava 
         tt-fiadores.nrdocava
         SKIP
         "CONJUGE:"
         tt-fiadores.nmconjug 
         SPACE(2)
         "CPF"
         SPACE(2)
         tt-fiadores.nrcpfcjg       FORMAT "X(14)"
         SPACE(5)
         tt-fiadores.tpdoccjg       FORMAT "X(02)"
         tt-fiadores.nrdoccjg       FORMAT "X(21)"         
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS DOWN WIDTH 101 FRAME f_insere_clausula_fiador_conjuge.

    FOR EACH tt-fiadores NO-LOCK BY tt-fiadores.inavalis:

        ASSIGN aux_rsestcvl = ""
               aux_nrdfiado = aux_nrdfiado + 1
               aux_dsendres = tt-fiadores.dsendres
               aux_nmcidauf = tt-fiadores.nmcidade + "/" + tt-fiadores.cdufresd
               aux_dsendres = aux_dsendres + 
                              IF tt-fiadores.nrendere <> "" THEN
                                 " N. " + tt-fiadores.nrendere
                              ELSE "".
        
        IF  tt-fiadores.inpessoa = 1 THEN /* Pessoa Física */
            DO:
                ASSIGN aux_tpcpfcgc = "CPF"
                       aux_rsestcvl = "ESTADO CIVIL ".

                IF  tt-fiadores.dsestcvl <> "" THEN
                    ASSIGN aux_rsestcvl = aux_rsestcvl + tt-fiadores.dsestcvl.
            END.
        ELSE /* Pessoa Jurídica */
            ASSIGN aux_tpcpfcgc = "CNPJ".

        IF  tt-fiadores.nmconjug <> "" THEN
            DO:                                 
                DISPLAY STREAM str_1 aux_nrdfiado
                                     aux_dsendres
                                     aux_tpcpfcgc
                                     aux_nmcidauf
                                     aux_rsestcvl
                                     tt-fiadores.nmdavali
                                     tt-fiadores.nmbairro
                                     tt-fiadores.nrcpfcgc WHEN tt-fiadores.nrcpfcgc <> ""
                                     tt-fiadores.tpdocava
                                     tt-fiadores.nrdocava
                                     tt-fiadores.nmconjug
                                     tt-fiadores.tpdoccjg
                                     tt-fiadores.nrcpfcjg WHEN tt-fiadores.nrcpfcjg <> ""
                                     tt-fiadores.nrdoccjg
                                     WITH FRAME f_insere_clausula_fiador_conjuge.

                DOWN WITH FRAME f_insere_clausula_fiador_conjuge.
            END.
        ELSE
            DO:
                DISPLAY STREAM str_1 aux_nrdfiado
                                     aux_dsendres
                                     aux_tpcpfcgc
                                     aux_nmcidauf
                                     aux_rsestcvl
                                     tt-fiadores.nmdavali
                                     tt-fiadores.nmbairro
                                     tt-fiadores.nrcpfcgc WHEN tt-fiadores.nrcpfcgc <> ""
                                     tt-fiadores.tpdocava
                                     tt-fiadores.nrdocava
                                     WITH FRAME f_insere_clausula_fiador.

                DOWN WITH FRAME f_insere_clausula_fiador.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-interveniente:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_nrdinter AS INTE                                   NO-UNDO.
    DEF  VAR aux_nrultreg AS INTE                                   NO-UNDO.
    DEF  VAR aux_dsendres AS CHAR                                   NO-UNDO.
    DEF  VAR aux_tpcpfcgc AS CHAR                                   NO-UNDO.
    DEF  VAR aux_nmcidauf AS CHAR                                   NO-UNDO.
    DEF  VAR aux_rsestcvl AS CHAR                                   NO-UNDO.

    FORM "INTERVENIENTE ANUENTE/FIADOR"
         SPACE(1)
         aux_nrdinter      FORMAT "9"
         SPACE(0)
         ":"
         tt-intervenientes.nmdavali
         SPACE(4)
         aux_rsestcvl                 FORMAT "x(25)"
         SPACE(0)
         aux_dsendres                 FORMAT "x(48)" 
         SPACE(0)
         "BAIRRO"
         tt-intervenientes.nmbairro 
         SPACE(0)
         aux_nmcidauf                 FORMAT "X(28)"         
         SPACE(20)
         aux_tpcpfcgc                 FORMAT "X(04)"
         tt-intervenientes.nrcpfcgc   FORMAT "x(18)"
         tt-intervenientes.tpdocava 
         tt-intervenientes.nrdocava
         SKIP(1)
         WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 FRAME f_insere_clausula_interveniente.
    
    FORM "INTERVENIENTE ANUENTE/FIADOR"
         SPACE(1)
         aux_nrdinter      FORMAT "9" 
         SPACE(0)
         ":"
         tt-intervenientes.nmdavali 
         SPACE(4)
         aux_rsestcvl                 FORMAT "x(25)"
         SPACE(0)
         aux_dsendres                 FORMAT "x(48)" 
         SPACE(2)
         "BAIRRO"
         tt-intervenientes.nmbairro 
         SPACE(0)
         aux_nmcidauf                 FORMAT "X(28)"
         SPACE(22)
         aux_tpcpfcgc                 FORMAT "X(04)"
         tt-intervenientes.nrcpfcgc   FORMAT "x(18)"
         tt-intervenientes.tpdocava   FORMAT "X(02)"
         tt-intervenientes.nrdocava   FORMAT "X(21)"
         SKIP
         "CONJUGE:"
         tt-intervenientes.nmconjug 
         SPACE(1)
         "CPF"
         SPACE(2)
         tt-intervenientes.nrcpfcjg FORMAT "X(14)"
         SPACE(5)
         tt-intervenientes.tpdoccjg FORMAT "X(02)"
         tt-intervenientes.nrdoccjg FORMAT "X(21)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 FRAME f_insere_clausula_interveniente_conjuge.

    FOR EACH tt-intervenientes NO-LOCK:

        ASSIGN aux_rsestcvl = ""
               aux_nrdinter = aux_nrdinter + 1
               aux_dsendres = tt-intervenientes.dsendres
               aux_nmcidauf = tt-intervenientes.nmcidade + "/" + tt-intervenientes.cdufresd
               aux_dsendres = aux_dsendres + 
                              IF tt-intervenientes.nrendere <> "" THEN
                                 " N. " + tt-intervenientes.nrendere
                              ELSE "".

        IF  tt-intervenientes.inpessoa = 1 THEN  /* Pessoa Física */
            DO:
                ASSIGN aux_tpcpfcgc = "CPF"
                       aux_rsestcvl = "ESTADO CIVIL ".

                IF  tt-intervenientes.dsestcvl <> "" THEN
                    ASSIGN aux_rsestcvl = aux_rsestcvl + tt-intervenientes.dsestcvl.

            END.
        ELSE  /* Pessoa Jurídica */
            ASSIGN aux_tpcpfcgc = "CNPJ".

        IF  tt-intervenientes.nmconjug <> "" THEN
            DO:
                DISPLAY STREAM str_1 aux_nrdinter
                                     aux_dsendres
                                     aux_tpcpfcgc
                                     aux_nmcidauf
                                     aux_rsestcvl
                                     tt-intervenientes.nmdavali
                                     tt-intervenientes.nmbairro
                                     tt-intervenientes.nrcpfcgc WHEN tt-intervenientes.nrcpfcgc <> ""
                                     tt-intervenientes.tpdocava
                                     tt-intervenientes.nrdocava WHEN tt-intervenientes.nrdocava <> ""
                                     tt-intervenientes.nmconjug
                                     tt-intervenientes.tpdoccjg
                                     tt-intervenientes.nrdoccjg
                                     tt-intervenientes.nrcpfcjg WHEN tt-intervenientes.nrcpfcjg <> ""
                                     WITH FRAME f_insere_clausula_interveniente_conjuge.

                DOWN WITH FRAME f_insere_clausula_interveniente_conjuge.
            END.
        ELSE
            DO:
                DISPLAY STREAM str_1 aux_nrdinter
                                     aux_dsendres
                                     aux_tpcpfcgc
                                     aux_nmcidauf
                                     aux_rsestcvl
                                     tt-intervenientes.nmdavali
                                     tt-intervenientes.nmbairro
                                     tt-intervenientes.nrcpfcgc WHEN tt-intervenientes.nrcpfcgc <> ""
                                     tt-intervenientes.tpdocava
                                     tt-intervenientes.nrdocava WHEN tt-intervenientes.tpdocava <> ""
                                     WITH FRAME f_insere_clausula_interveniente.

                DOWN WITH FRAME f_insere_clausula_interveniente.
            END.
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-declaracao-inerente-folha-rosto:

    FORM "Declaram as partes abaixo assinadas, que a presente Folha de Rosto e"
         "parte integrante das CONDICOES" 
         SKIP
         "GERAIS do Contrato de Emprestimo,"
         "cujas condicoes aceitam e prometem cumprir."
         SKIP(2)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101
         FRAME f_insere_clausula_declaracao.

   VIEW STREAM str_1 FRAME f_insere_clausula_declaracao.

   RETURN "OK".

END PROCEDURE.

PROCEDURE insere-local-data:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.

    DEF  VAR aux_nmcidade LIKE crapage.nmcidade                     NO-UNDO.
    DEF  VAR aux_cdufdcop LIKE crapage.cdufdcop                     NO-UNDO.
    DEF  VAR aux_dsclausu AS CHAR                                   NO-UNDO.

    FORM aux_dsclausu FORMAT "X(101)"
         SKIP(2)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_local_data.

    FIND crapage WHERE crapage.cdcooper = par_cdcooper     AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

     IF  NOT AVAILABLE crapage   THEN
         ASSIGN aux_nmcidade = "____________________________"
                aux_cdufdcop = "__________".
     ELSE
         ASSIGN aux_nmcidade = crapage.nmcidade
                aux_cdufdcop = crapage.cdufdcop.

     ASSIGN aux_dsclausu = aux_nmcidade + " / " + aux_cdufdcop + ",______________________________________________________.".

     DISPLAY STREAM str_1 aux_dsclausu WITH FRAME f_insere_local_data.

     RETURN "OK".

END PROCEDURE.

PROCEDURE insere-assinaturas-intervenientes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador  AS INTE                                  NO-UNDO.
    DEF  VAR aux_tpcpfcgc  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_contador2 AS INTE                                  NO-UNDO.

    FORM
    "________________________________________________     ________________________________________________"
    SKIP
    "Interveniente Anuente/Fiador" 
    aux_contador                            FORMAT "9" 
    "Conjuge Interveniente Anuente/Fiador"                 AT 54
    aux_contador2                           FORMAT "9"    
    SKIP
    "Nome:"
    tt-intervenientes.nmdavali              FORMAT "X(42)"
    "Nome:"                                                AT 54
    tt-intervenientes.nmconjug              FORMAT "X(42)"
    SKIP                                    
    aux_tpcpfcgc                            FORMAT "X(05)"
    tt-intervenientes.nrcpfcgc              FORMAT "X(18)"    
    "CPF:"                                                 AT 54
    tt-intervenientes.nrcpfcjg              FORMAT "X(14)"   
    SKIP(2)
    WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 FRAME f_insere_assinaturas_intervenientes.

    RUN carrega-intervenientes-alienacao (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_recidepr,
                                         OUTPUT TABLE tt-intervenientes,
                                         OUTPUT TABLE tt-erro).
    IF  RETURN-VALUE <> "OK" THEN                      
        RETURN "NOK".

    FOR EACH tt-intervenientes NO-LOCK:

        ASSIGN aux_contador  = aux_contador + 1
               aux_contador2 = aux_contador.

        IF  tt-intervenientes.inpessoa = 1 THEN 
            ASSIGN aux_tpcpfcgc = "CPF:".
        ELSE
            ASSIGN aux_tpcpfcgc = "CNPJ:".
            
        DISPLAY STREAM str_1 aux_contador
                             aux_contador2
                             aux_tpcpfcgc
                             tt-intervenientes.nmdavali
                             tt-intervenientes.nrcpfcgc WHEN tt-intervenientes.nrcpfcgc <> ""
                             tt-intervenientes.nmconjug
                             tt-intervenientes.nrcpfcjg WHEN tt-intervenientes.nrcpfcjg <> ""
                             WITH FRAME f_insere_assinaturas_intervenientes.

        DOWN WITH FRAME f_insere_assinaturas_intervenientes.
    END.

    RETURN "OK".
     
END PROCEDURE.

PROCEDURE insere-assinaturas-fiadores:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador  AS INTE                                  NO-UNDO.
    DEF  VAR aux_contador2 AS INTE                                  NO-UNDO.
    DEF  VAR aux_tpcpfcgc AS CHAR                                   NO-UNDO.

    FORM
    "________________________________________________     ________________________________________________"
    SKIP
    "Fiador" 
    aux_contador              FORMAT "9" 
    "Conjuge Fiador"                            AT 54
    aux_contador2             FORMAT "9"
    SKIP                                        
    "Nome:"                                     
    tt-fiadores.nmdavali      FORMAT "X(42)"
    "Nome:"                                     AT 54
    tt-fiadores.nmconjug      FORMAT "X(42)"    
    SKIP                      
    aux_tpcpfcgc              FORMAT "X(05)"
    tt-fiadores.nrcpfcgc      FORMAT "x(18)"    
    "CPF:"                                      AT 54
    tt-fiadores.nrcpfcjg      FORMAT "x(14)"    
    SKIP(2)
    WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 FRAME f_insere_assinaturas_fiadores.

    RUN carrega-fiadores (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT par_recidepr,
                         OUTPUT TABLE tt-fiadores,
                         OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN                      
        RETURN "NOK".

    FOR EACH tt-fiadores NO-LOCK BY tt-fiadores.inavalis:

        ASSIGN aux_contador  = aux_contador + 1
               aux_contador2 = aux_contador.

        IF  tt-fiadores.inpessoa = 1 THEN
            ASSIGN aux_tpcpfcgc = "CPF:".
        ELSE
            ASSIGN aux_tpcpfcgc = "CNPJ:".

        DISPLAY STREAM str_1 aux_contador
                             aux_contador2
                             aux_tpcpfcgc
                             tt-fiadores.nmdavali
                             tt-fiadores.nrcpfcgc WHEN tt-fiadores.nrcpfcgc  <> ""
                             tt-fiadores.nmconjug
                             tt-fiadores.nrcpfcjg WHEN tt-fiadores.nrcpfcjg  <> ""
                             WITH FRAME f_insere_assinaturas_fiadores.

        DOWN WITH FRAME f_insere_assinaturas_fiadores.
    END.

    RETURN "OK".
     
END PROCEDURE.

PROCEDURE insere-assinaturas-cooperado-cooperativa:

    DEF  INPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmextcop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.

    FORM SKIP(1)
    "________________________________________________     ________________________________________________"
    SKIP
    par_nmprimtl                  FORMAT "X(42)"    AT 01
    par_nmextcop                  FORMAT "X(48)"    AT 54
    SKIP
    par_nmrescop                  FORMAT "X(42)"    AT 54
    SKIP(2)
    WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 FRAME f_insere_assinaturas_fiadores.

    DISPLAY STREAM str_1 par_nmprimtl
                         par_nmextcop
                         par_nmrescop
                         WITH FRAME f_insere_assinaturas_fiadores.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-assinaturas-testemunhas:

    FORM
    "________________________________________________     ________________________________________________"
    SKIP
    "Testemunha 1"                AT 01
    "Testemunha 2"                AT 54
    SKIP(1)
    "CPF/MF:"                     AT 01
    "________________________________________"
    "CPF/MF:"                     AT 54
    "________________________________________"
    SKIP(1)
    "CI:"                         AT 01
    "____________________________________________"
    "CI:"                         AT 54
    "____________________________________________"
    SKIP(1)
    "________________________________________________" AT 54
    WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_assinaturas_testemunhas.

    VIEW STREAM str_1 FRAME f_insere_assinaturas_testemunhas.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-operador:

    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.

    DEF  VAR aux_nmoperad  LIKE crapope.nmoperad                    NO-UNDO.
    
    FORM SKIP
    "Operador:"   AT 54
    aux_nmoperad
    WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_operador.

    FIND crawepr WHERE RECID(crawepr) = par_recidepr NO-LOCK NO-ERROR.

    FIND crapope WHERE crapope.cdcooper = crawepr.cdcooper AND
                       crapope.cdoperad = crawepr.cdoperad NO-LOCK NO-ERROR.
   
    IF   NOT AVAILABLE crapope   THEN
         aux_nmoperad = crawepr.cdoperad + " - ** NAO CADASTRADO **".
    ELSE
         aux_nmoperad = crapope.nmoperad.
    
    DISPLAY STREAM str_1 aux_nmoperad WITH FRAME f_insere_operador.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-declaracao-bndes:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "Tratando-se de operacao de credito que tenha como origem recursos de fontes do BNDES, o(a)"
         SKIP
         "cooperado(a) declara expressamente que:"
         SKIP
         "a) tem a obrigacao de nao utilizar os recursos recebidos para microcredito produtivo em finalidade"
         SKIP
         "diversa da estipulada contratualmente;"
         SKIP
         "b) tem a obrigacao de nao utilizar os recursos recebidos em medidas ou acoes que causem danos ao"
         SKIP
         "meio ambiente, seguranca e medicina do trabalho; e"
         SKIP
         "c) o credito objeto desse contrato encontra-se cedido fiduciariamente ao BNDES, devendo  o(a)"
         SKIP
         "Cooperado(a) realizar pagamentos em conta indicada pela referida instituicao, caso seja notificado"
         SKIP
         "para tanto."
         SKIP
         'Paragrafo unico. O descumprimento das obrigacoes previstas nas alineas "a" e "b" do "caput" desta'
         SKIP
         "clausula acarretara o vencimento antecipado da integralidade do saldo remanescente do debito."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_declaracao_bndes.

         DISPLAY STREAM str_1 par_dsnrclau WITH FRAME f_insere_clausula_declaracao_bndes.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-bens-garantia-automovel:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_contador  AS INTE                                  NO-UNDO.
    DEF  VAR aux_subclaut  AS CHAR                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM aux_subclaut FORMAT "X(14)"
         tt-bens-contratos.dsbemfin
         "RENAVAN"
         tt-bens-contratos.dsrenava FORMAT "X(15)"
         SKIP
         "CHASSI"
         tt-bens-contratos.dschassi
         "PLACA"
         tt-bens-contratos.nrdplaca
         "LICENCIADO EM"
         tt-bens-contratos.uflicenc
         "ANO"
         tt-bens-contratos.dsanobem FORMAT "X(04)"
         "MODELO"
         tt-bens-contratos.dsmodbem FORMAT "X(04)"
         SKIP
         "COR"
         tt-bens-contratos.dscorbem FORMAT "x(23)"
         "PROPRIETARIO"
         tt-bens-contratos.nmpropri FORMAT "X(40)"
         SKIP(1)
         "Nota: O(s) bem(ns) identificado(s) neste item, devera(ao) ser registrado(s) em nome do(s)"
         "depositario(s), seja(m) este(s) CONTRATANTE ou INTERVENIENTE(S) ANUENTE(S)/FIADOR(ES), acima"
         "qualificado(s)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 
         FRAME f_insere_clausula_bens_garantia_automovel.

    RUN busca-bens-alienacao (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_recidepr,
                             OUTPUT TABLE tt-bens-contratos,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    ASSIGN aux_contador = 1.

    FOR EACH tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*AUTOMOVEL*" OR
                                      tt-bens-contratos.dscatbem MATCHES "*MOTO*"      OR
                                      tt-bens-contratos.dscatbem MATCHES "*CAMINHAO*"  OR
                                      tt-bens-contratos.dscatbem MATCHES "*OUTROS VEICULOS*") NO-LOCK:

        ASSIGN aux_subclaut = par_clbemgar + STRING(aux_contador) + ". " +  tt-bens-contratos.dscatbem 
               aux_contador = aux_contador + 1.

        DISPLAY STREAM str_1 aux_subclaut
                             tt-bens-contratos.dsbemfin
                             tt-bens-contratos.dsrenava
                             tt-bens-contratos.dschassi
                             tt-bens-contratos.nrdplaca
                             tt-bens-contratos.uflicenc
                             tt-bens-contratos.dsanobem
                             tt-bens-contratos.dsmodbem
                             tt-bens-contratos.nmpropri
                             tt-bens-contratos.dscorbem 
                             WITH FRAME f_insere_clausula_bens_garantia_automovel.

        DOWN WITH FRAME f_insere_clausula_bens_garantia_automovel.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-garantia-imovel-financiado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsbemmaq  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_dsbemfi1  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_dsbemfi2  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_subclimv  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_contador  AS INTE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM aux_subclimv               FORMAT "X(25)"
         aux_dsbemfi1 FORMAT "x(75)"  
         aux_dsbemfi2 FORMAT "x(100)" 
         SKIP
         "NOME DO PROPRIETARIO:"    AT 5
         tt-bens-contratos.nmpropri FORMAT "X(40)"
         SKIP(1)
         WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 
         FRAME f_insere_clausula_bens_garantia_imovel.

    RUN busca-bens-alienacao (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_recidepr,
                             OUTPUT TABLE tt-bens-contratos,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    ASSIGN aux_contador = 1.

    FOR EACH tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*CASA*"     OR
                                      tt-bens-contratos.dscatbem MATCHES "*TERRENO*"  OR
                                      tt-bens-contratos.dscatbem MATCHES "*APARTAMENTO*") NO-LOCK:

        ASSIGN aux_subclimv = par_clbemgar + STRING(aux_contador) + ". " +  "DESCRICAO DO IMOVEL:"
               aux_contador = aux_contador + 1.
        
        IF  tt-bens-contratos.dsbemfin = "" THEN
            ASSIGN aux_dsbemfi1 = ""
                   aux_dsbemfi2 = "".
        ELSE
            ASSIGN aux_dsbemfi1 = SUBSTRING(tt-bens-contratos.dsbemfin, 1 ,75)
                   aux_dsbemfi2 = FILL(" ",25) + " " + SUBSTRING(tt-bens-contratos.dsbemfin, 75).


        DISPLAY STREAM str_1 aux_subclimv
                             aux_dsbemfi1
                             aux_dsbemfi2
                             WITH FRAME f_insere_clausula_bens_garantia_imovel.

        DOWN WITH FRAME f_insere_clausula_bens_garantia_imovel.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-bens-garantia-maquina:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_recidepr AS RECID                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR aux_dsbemmaq  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_subclmaq  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_contador  AS INTE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FORM aux_subclmaq FORMAT "X(13)"
         aux_dsbemmaq FORMAT "X(86)"         
         WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 
         FRAME f_insere_clausula_bens_garantia_maquina.

    RUN busca-bens-alienacao (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT par_recidepr,
                             OUTPUT TABLE tt-bens-contratos,
                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    ASSIGN aux_contador = 1.

    FOR EACH tt-bens-contratos WHERE (tt-bens-contratos.dscatbem MATCHES "*MAQUINA*"      OR
                                      tt-bens-contratos.dscatbem MATCHES "*EQUIPAMENTO*") NO-LOCK:

        ASSIGN aux_dsbemmaq = tt-bens-contratos.dscatbem + " " + tt-bens-contratos.dsbemfin
               aux_subclmaq = par_clbemgar + STRING(aux_contador) + ". " +  "MAQUINA:"
               aux_contador = aux_contador + 1.

        DISPLAY STREAM str_1 aux_dsbemmaq
                             aux_subclmaq
                             WITH FRAME f_insere_clausula_bens_garantia_maquina.
                
        DOWN WITH FRAME f_insere_clausula_bens_garantia_maquina.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-bens-garantia-maquina-nota:

    FORM "Nota: O(s) bem(ns) identificado(s) neste item, devera(ao) ser registrado(s) em nome do(s)"
         "depositario(s), seja(m) este(s) CONTRATANTE ou INTERVENIENTE(S) ANUENTE(S)/FIADOR(ES), acima"
         "qualificado(s)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 DOWN NO-LABELS WIDTH 101 FRAME f_insere_clausula_bens_garantia_maquina_nota.

    DISPLAY STREAM str_1 WITH FRAME f_insere_clausula_bens_garantia_maquina_nota.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-contratantes:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clctrata AS CHAR                           NO-UNDO. /* CONTRATADA  */
    DEF  INPUT PARAM par_clctrate AS CHAR                           NO-UNDO. /* CONTRATANTE */
    DEF  INPUT PARAM par_nmextcop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmrescop AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_nmcooper  AS CHAR                                  NO-UNDO.

    ASSIGN aux_nmcooper = par_nmextcop + " - " + par_nmrescop.

    FORM par_dsnrclau      FORMAT "X(4)"
         "CONTRATANTES" aux_chrhifen FORMAT "X(01)" "Sao partes contratantes neste instrumento, de um lado, como FINANCIADOR(A), a" 
         aux_nmcooper ", qualificada no item" par_clctrata ", por" 
         "seu(s) representante(s) ao final assinado(s) e doravante denominada simplesmente COOPERATIVA e," 
         "de outro lado, como FINANCIADO(A) a pessoa nomeada e qualificada no item" par_clctrate "e, daqui em diante,"
         "denominada COOPERADO(A)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_contratantes.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau 
                              aux_chrhifen
                              par_clctrata FORMAT "X(06)" 
                              par_clctrate FORMAT "X(06)"
                              aux_nmcooper FORMAT "x(64)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_contratantes.
                              
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-financiamento:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clvalfin AS CHAR                           NO-UNDO. /* VALOR FINANCIADO */
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO. /* BENS GARANTIA    */
    DEF  INPUT PARAM par_clctrate AS CHAR                           NO-UNDO. /* CONTRATANTE      */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "FINANCIAMENTO" aux_chrhifen FORMAT "X(01)" "O credito ora aberto, e aceito pelo(a) COOPERADO(A), no valor estipulado no"
         "item" par_clvalfin ", tem como garantia o(s) bem(ns) indicado(s) no item" par_clbemgar ". O valor sera liberado pela"
         "COOPERATIVA, mediante credito em conta-corrente de deposito do(a) COOPERADO(A), especificada no" 
         "item" par_clctrate "ou diretamente ao fornecedor do(s) bem(ns), nos casos em que o credito destinar-se a"
         "aquisicao deste(s)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_financiamento.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau 
                              aux_chrhifen
                              par_clvalfin FORMAT "X(06)"
                              par_clbemgar FORMAT "X(06)"
                              par_clctrate FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_financiamento.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-financiamento-imovel:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clvalfin AS CHAR                           NO-UNDO. /* VALOR FINANCIADO */
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO. /* IMOVEIS    */
    DEF  INPUT PARAM par_clctrate AS CHAR                           NO-UNDO. /* CONTRATANTE      */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "FINANCIAMENTO" aux_chrhifen FORMAT "X(01)" "O credito ora aberto, e aceito pelo(a) COOPERADO(A), no valor estipulado no"
         "item" par_clvalfin ", destina-se a financiar a aquisicao do(s) imovel(eis) indicado no item" par_clbemgar "ou a"
         "credito nao direcionado. O valor e sera liberado, pela COOPERATIVA, mediante credito em"
         "conta-corrente de deposito do(a) COOPERADO(A), especificada no item" par_clctrate "ou diretamente ao"
         "fornecedor do(s) imovel(eis)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_imovel.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau 
                              aux_chrhifen
                              par_clvalfin FORMAT "X(06)"
                              par_clbemgar FORMAT "X(06)"
                              par_clctrate FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_imovel.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-encargos-financeiros-maquina-pos-fixado:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clencfin AS CHAR                           NO-UNDO. /* ENCARGOS FINANCEIROS */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "ENCARGOS FINANCEIROS" aux_chrhifen FORMAT "X(01)" "A COOPERATIVA e o(a) COOPERADO(A) tem justo e acordado que sobre o"
         "valor do presente contrato, bem como das quantias dele decorrentes, devidas a titulo de acessorios,"
         "taxas e despesas, incidirao encargos financeiros remuneratorios, capitalizados mensalmente, na forma"
         "prevista no item" par_clencfin "."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_encargos_financeiros_maquinas.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              par_clencfin FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_encargos_financeiros_maquinas.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-encargos-financeiros:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clencfin AS CHAR                           NO-UNDO. /* ENCARGOS FINANCEIROS */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "ENCARGOS FINANCEIROS" aux_chrhifen FORMAT "X(01)" "A COOPERATIVA e o(a) COOPERADO(A) tem justo e acordado que sobre o"
         "valor do presente contrato, incidirao encargos financeiros remuneratorios, capitalizados"
         "mensalmente, na forma prevista no item" par_clencfin "."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_encargos_financeiros.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              par_clencfin FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_encargos_financeiros.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-encargos-financeiros-pre-fixado:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clencfin AS CHAR                           NO-UNDO. /* ENCARGOS FINANCEIROS */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "ENCARGOS FINANCEIROS" aux_chrhifen FORMAT "X(01)" "A COOPERATIVA e o(a) COOPERADO(A) tem justo e acordado que sobre o"
         "valor do presente contrato, incidirao encargos financeiros remuneratorios na forma prevista"
         "no item" par_clencfin "."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_encargos_financeiros.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              par_clencfin FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_encargos_financeiros.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-encargos-financeiros:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         'Alem dos encargos previstos no "caput" desta clausula, igualmente serao devidas comissoes e'
         "taxas de servicos inerentes ao contrato, conforme estabelecido nas normas regulamentares da"
         "COOPERATIVA."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_encargos_financeiros.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_encargos_financeiros.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula2-condicoes-gerais-encargos-financeiros:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cljurrem AS CHAR                           NO-UNDO. /* JUROS REMUNERATORIOS */
    DEF  INPUT PARAM par_clinadim AS CHAR                           NO-UNDO. /* DO INADIMPLEMENTO */

    FORM par_dsnrclau     FORMAT "X(6)"
         "Em ocorrendo inflacao, apurada pelo INPC/IBGE, superior a 8% (oito por cento) ao ano, o"
         "valor do saldo remanescente do debito devera ser corrigido pelo referido indice, acrescido dos" 
         'juros remuneratorios estabelecidos na alinea "a" do item' par_cljurrem ', alem dos encargos moratorios e'
         "demais cominacoes legais, conforme disposto na Clausula" par_clinadim "do presente instrumento."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula2_condicoes_gerais_encargos_financeiros.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_cljurrem FORMAT "X(06)"
                              par_clinadim FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula2_condicoes_gerais_encargos_financeiros.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula3-condicoes-gerais-encargos-financeiros:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "Na impossibilidade legal do uso do indice de atualizacao basica previsto no paragrafo"
         "anterior, aplicar-se-a o indice que vier a substitui-lo, e, nao tendo substituto, qualquer outro"
         "indice legalmente instituido que venha a ser utilizado para as obrigacoes financeiras, a criterio"
         "da COOPERATIVA e desde que nao venha a afetar o equilibrio do contrato."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula3_condicoes_gerais_encargos_financeiros.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula3_condicoes_gerais_encargos_financeiros.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula4-condicoes-gerais-encargos-financeiros:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "O COOPERADO(A) declara ter ciencia de todos os encargos e despesas incluidos no" 
         "financiamento e que integram o Custo Efetivo Total - CET."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula4_condicoes_gerais_encargos_financeiros.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula4_condicoes_gerais_encargos_financeiros.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-prestacoes:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clprstme AS CHAR                           NO-UNDO. /* DAS PRESTACOES MENSAIS */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(4)"
         "PRESTACOES" aux_chrhifen FORMAT "X(01)" "Os valores devidos a titulo de principal, encargos financeiros e demais"
         "acessorios serao exigiveis em prestacoes mensais e sucessivas, segundo o valor, a quantidade e os"
         "vencimentos previstos no item" par_clprstme "."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_prestacoes.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau 
                              aux_chrhifen
                              par_clprstme FORMAT "X(06)" 
                              WITH FRAME f_insere_clausula_condicoes_gerais_prestacoes.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-prestacoes:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clprstme AS CHAR                           NO-UNDO. /* DAS PRESTACOES MENSAIS */

    FORM par_dsnrclau     FORMAT "X(6)"
         "O prazo de vigencia do contrato e o numero de prestacoes previstas no item" par_clprstme  ","
         "prorrogar-se-ao automaticamente, ate a liquidacao total do debito, caso nao seja possivel corrigir"
         "as prestacoes mensais em decorrencia de elevacao do indice de Atualizacao Basica, ou ocorram"
         "atrasos, por qualquer causa, nos pagamentos mensais das prestacoes, inclusive decorrentes de"
         "carencia maior de 30 (trinta) dias para o pagamento da primeira parcela."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_prestacoes.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_clprstme FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_prestacoes.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-prestacoes-pre-fixado:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clprstme AS CHAR                           NO-UNDO. /* DAS PRESTACOES MENSAIS */

    FORM par_dsnrclau     FORMAT "X(6)"
         "O prazo de vigencia do contrato e o numero de prestacoes previstas no item" par_clprstme  ","
         "prorrogar-se-ao automaticamente, ate a liquidacao total do debito, ou caso ocorram atrasos, por"
         "qualquer causa, nos pagamentos mensais das prestacoes."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_prestacoes_pre_fixado.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_clprstme FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_prestacoes_pre_fixado.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula2-condicoes-gerais-prestacoes:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clfrmpag AS CHAR                           NO-UNDO. /* FORMA DE PAGAMENTO */

    FORM par_dsnrclau     FORMAT "X(6)"
         "O debito mensal em conta-corrente devera ocorrer na data em que forem creditados os"
         "salarios do(a) COOPERADO(A) ou em data diversa, conforme opcao registrada pelo COOPERADO(A) no" 
         "item" par_clfrmpag "."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula2_condicoes_gerais_prestacoes.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_clfrmpag FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula2_condicoes_gerais_prestacoes.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula3-condicoes-gerais-prestacoes:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clprstme AS CHAR                           NO-UNDO. /* DAS PRESTACOES MENSAIS */
    DEF  INPUT PARAM par_clctrate AS CHAR                           NO-UNDO. /* CONTRATANTE      */

    FORM par_dsnrclau     FORMAT "X(6)"
         "Para o pagamento do valor total da divida, suas prestacoes, encargos, despesas e demais"
         "acessorios decorrentes da celebracao do presente contrato, na forma dos vencimentos especificados"
         "no item" par_clprstme ", o(a) COOPERADO(A), em carater irrevogavel e irretratavel, autoriza a COOPERATIVA a"
         "proceder os pertinentes e necessarios lancamentos a debito na conta-corrente de depositos,"
         "especificada no item" par_clctrate ", obrigando-se a manter, nas epocas proprias, disponibilidade financeira"
         "suficiente a acolhida de tais lancamentos, assim como autoriza o saque de aplicacoes financeiras"
         "mantidas junto a COOPERATIVA para abatimento das parcelas vencidas e nao pagas, independentemente"
         "de aviso ou notificacao."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula3_condicoes_gerais_prestacoes.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_clprstme FORMAT "X(06)"
                              par_clctrate FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula3_condicoes_gerais_prestacoes.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-vencimento-antecipado:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clgarali AS CHAR                           NO-UNDO. /* DAS GARANTIAS - ALIENAÇAO FIDUCIÁRIA OBRIGAÇAO LEGAL */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "VENCIMENTO ANTECIPADO" aux_chrhifen FORMAT "X(01)" "O presente contrato considerar-se-a vencido antecipadamente e, por"
         "conseguinte tornar-se-a liquido, certo e exigivel, podendo a COOPERATIVA executa-lo imediatamente e"
         "exercer os demais direitos pertinentes, nos seguintes casos:"
         SKIP
         "a) nao pagamento de 2 (duas) prestacoes mensais consecutivas ou alternadas;"
         SKIP
         "b) nao comprovacao dentro do prazo contratual, do competente registro da alienacao fiduciaria nos"
         "orgaos competentes, na forma do estabelecido no item" par_clgarali "abaixo; e"
         SKIP
         "c) nao cumprimento de qualquer outra clausula contratual."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_vencimento_antecipado.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              par_clgarali FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_vencimento_antecipado.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-vencimento-antecipado-imovel:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "VENCIMENTO ANTECIPADO" aux_chrhifen FORMAT "X(01)" "O presente contrato considerar-se-a vencido antecipadamente e, por"
         "conseguinte tornar-se-a liquido, certo e exigivel, podendo a COOPERATIVA executa-lo imediatamente e"
         "exercer os demais direitos pertinentes, nos seguintes casos:"
         SKIP
         "a) nao pagamento de 2 (duas) prestacoes mensais consecutivas ou alternadas;"
         SKIP
         "b) recaindo sob o(s) imovel(eis) hipotecado(s)/alienado(s) qualquer execucao ou vindo a ser(em)"
         "objeto de demanda;"
         SKIP
         "c) nao comprovacao dentro do prazo contratual, do competente registro da hipoteca/alienacao nos"
         "orgaos competentes; e"
         SKIP
         "d) nao cumprimento de qualquer outra clausula contratual."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_vencimento_antecipado_imovel.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_vencimento_antecipado_imovel.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-vencimento-antecipado-pre-fixada:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "O(a) COOPERADO(A) podera antecipar o pagamento de parcelas, fazendo jus a um desconto"
         'proporcional no valor dos encargos financeiros, apurados "pro rata temporis" pelo periodo'
         "compreendido entre o pagamento antecipado e o efetivo vencimento das parcelas vincendas, cujo"
         "montante apurado sera deduzido do valor da respectiva parcela, no momento da antecipacao"
         "do pagamento."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_vencimento_antecipado_pre_fixado.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_vencimento_antecipado_pre_fixado.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-vencimento-antecipado:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "O(A) COOPERADO(A) podera antecipar o pagamento de parcelas, fazendo jus a um desconto"
         'proporcional no valor dos encargos financeiros, apurados "pro rata temporis" pelo periodo'
         "compreendido entre o pagamento antecipado e o efetivo vencimento das  parcelas vincendas, cujo"
         "montante apurado sera deduzido do valor projetado das parcelas no momento da liquidacao do contrato."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_vencimento_antecipado.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_vencimento_antecipado.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-garantias-alienacao-imovel:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO. /* IMOVEIS    */

    DEF  VAR aux_chrhifen   AS CHAR                                 NO-UNDO.
    DEF  VAR aux_chrhifen2  AS CHAR                                 NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "GARANTIAS" aux_chrhifen FORMAT "X(01)" "DA ALIENACAO FIDUCIARIA" aux_chrhifen2 FORMAT "X(01)"
         "Em garantia do integral cumprimento de todas as"
         "obrigacoes assumidas neste contrato, o(a) COOPERADO(A), em primeira e especial garantia, aliena"
         "o(s) imovel(eis) descrito(s) no item" par_clbemgar ", que se acha(m) livre(s) e desembaracado(s) de qualquer"
         "onus."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_garantias_alienacao_imovel.

         ASSIGN aux_chrhifen = CHR(45)
               aux_chrhifen2 = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen2
                              aux_chrhifen
                              par_clbemgar FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_garantias_alienacao_imovel.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-garantias-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO. /* BENS GARANTIA    */

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_chrhifen2  AS CHAR                                 NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "GARANTIAS" aux_chrhifen FORMAT "X(01)" "ALIENACAO FIDUCIARIA" aux_chrhifen2 FORMAT "X(01)"
         "Em garantia do integral cumprimento de todas as"
         "obrigacoes assumidas neste contrato, o(a) COOPERADO(A) da em alienacao fiduciaria a COOPERATIVA,"
         "nos termos do Decreto-Lei n. 911, de 01/10/1969, e demais disposicoes legais aplicaveis, o(s)"
         "bem(ns) descrito(s) no item" par_clbemgar ", que se acha(m) livre(s) e desembaracado(s) de qualquer onus."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_garantias_alienacao.

         ASSIGN aux_chrhifen  = CHR(45)
                aux_chrhifen2 = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen2
                              aux_chrhifen
                              par_clbemgar FORMAT "X(06)"
                              WITH FRAME f_insere_clausula_condicoes_gerais_garantias_alienacao.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-garantias-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "O(A)COOPERADO(A) obriga-se ainda a apresentar a COOPERATIVA, na mesma data em que for" 
         "firmado o presente contrato, a nota fiscal de compra do bem dado em garantia."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_garantias_alienacao.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_garantias_alienacao.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-garantias-alienacao-veiculo:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "Tratando-se de financiamento para a aquisicao de veiculo automotor, o(a) COOPERADO(A)"
         "obriga-se, ainda, a apresentar a COOPERATIVA, dentro de 15 (quinze) dias, contados da data deste"
         "contrato, o Certificado de Registro de Veiculos - CRV, contendo o onus de alienacao fiduciaria"
         "em favor da COOPERATIVA."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_garantias_alienacao_veiculo.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_garantias_alienacao_veiculo.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula2-condicoes-gerais-garantias-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clbemgar AS CHAR                           NO-UNDO. /* BENS GARANTIA    */

    FORM par_dsnrclau     FORMAT "X(6)"
         "Igualmente em face de alienacao fiduciaria, o(a) COOPERADO(A) e/ou FIADOR(ES) e"
         "INTERVENIENTE(S) ANUENTE(S)/FIADOR(ES) assume(m) a obrigacao de depositario(s) do(s) bem(ns)"
         "descrito(s) no item" par_clbemgar ", na forma do art. 627 e seguintes, do Codigo Civil Brasileiro, assumindo"
         "todas as obrigacoes de depositario, devendo tomar todas as medidas necessarias para evitar a"
         "alienacao ou penhora do(s) referido(s) bem(ns), assim como, resguardar-se de esbulhos e turbacoes,"
         "sendo que este somente sera(ao) liberado(s) apos o integral pagamento das parcelas na forma do" 
         "convencionado, declarando-se ainda ciente(s) de que, em caso de nao pagamento parcial ou total do"
         "convencionado, devera(ao) entregar o(s) referido(s) bem(ns) a COOPERATIVA, e, na falta deste(s),"
         "automaticamente estara(ao) sujeito(s) as penalidades legais, em especial o ressarcimento dos"
         "prejuizos a COOPERATIVA."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula2_condicoes_gerais_garantias_alienacao.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_clbemgar FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula2_condicoes_gerais_garantias_alienacao.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula3-condicoes-gerais-garantias-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cldsfiad AS CHAR                           NO-UNDO. /* FIADORES */

    FORM par_dsnrclau     FORMAT "X(6)"
         "FIADOR(ES) - Para garantir o cumprimento das obrigacoes assumidas no presente contrato"
         "comparecem o(s) FIADOR(ES) nominado(s) no item" par_cldsfiad ", o(s) qual(is) expressamente declara(m)"
         "que se responsabiliza(m), solidariamente, como principal(is) pagador(es), pelo cumprimento de"
         "todas as obrigacoes assumidas pelo(a) COOPERADO(A) neste contrato, renunciando, expressamente,"
         "aos beneficios de ordem que trata o art. 827, em conformidade com o art. 828, incisos I e II,"
         "e art. 838 do Codigo Civil Brasileiro."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula3_condicoes_gerais_garantias_alienacao.

         DISPLAY STREAM str_1 par_dsnrclau
                              par_cldsfiad FORMAT "X(06)"
                              WITH FRAME f_insere_subclausula3_condicoes_gerais_garantias_alienacao.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula4-condicoes-gerais-garantias-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "O(S) FIADOR(ES) autoriza(m) desde ja, o debito das parcelas e/ou do saldo devedor, apurado"
         "na forma do presente contrato, na(s) sua(s) conta(s)-corrente(s) mantida junto a COOPERATIVA,"
         "assim como autoriza(m) o saque das aplicacoes financeiras para abatimento das parcelas vencidas e"
         "nao pagas, independentemente de aviso ou notificacao."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula4_condicoes_gerais_garantias_alienacao.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula4_condicoes_gerais_garantias_alienacao.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula5-condicoes-gerais-garantias-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "Em caso de fianca prestada conjuntamente por conjuges ou companheiros, cada qual assina o"
         "presente contrato com a finalidade de prestar a fianca por si e conceder ao outro a outorga"
         "necessaria."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula5_condicoes_gerais_garantias_alienacao.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula5_condicoes_gerais_garantias_alienacao.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-seguro:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "SEGURO" aux_chrhifen FORMAT "X(01)" "O(A) COOPERADO(A) obriga-se a contratar seguro do(s) bem(ns) alienado(s)"
         "fiduciariamente durante toda a vigencia do contrato, na mais ampla forma, contra todos os riscos a"
         "que possam estar sujeito(s) o(s) bem(ns), incluida, no caso de veiculos, a cobertura de"
         "responsabilidade civil, tanto a danos pessoais, como a propriedade de terceiros, designando a"
         "COOPERATIVA, no caso de perda total, em razao da propriedade resoluvel, como unica e exclusiva"
         "beneficiaria das indenizacoes devidas."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_seguro.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_seguro.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-seguro-imovel:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "SEGURO" aux_chrhifen FORMAT "X(01)" "O(a) COOPERADO(A) obriga-se a contratar seguro do(s) imovel(eis) alienado(s)"
         "fiduciariamente durante toda a vigencia do contrato, na mais ampla forma, contra todos os riscos a"
         "que possa(m) estar sujeito(s) o(s) imovel(eis), no minimo pelo valor do financiamento, designando a"
         "COOPERATIVA, no caso de perda total, em razao da propriedade resoluvel, como unica e exclusiva"
         "beneficiaria das indenizacoes devidas."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_seguro_imovel.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_seguro_imovel.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-seguro:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "A indenizacao paga pela seguradora nos termos previstos no presente contrato, sera aplicada"
         "na amortizacao ou liquidacao das obrigacoes aqui assumidas, revertendo ao COOPERADO(A), apos a"
         "quitacao do saldo devedor, eventual valor excedente apurado. Se o valor do seguro nao bastar para o"
         "pagamento do credito da COOPERATIVA, o(a) COOPERADO(A) e o(s) FIADOR(ES) continuarao responsaveis"
         "pelo pagamento do saldo devedor."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_gerais_seguro.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_gerais_seguro.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-inadimplemento:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_clencfin AS CHAR                           NO-UNDO. /* ENCARGOS FINANCEIROS */

    DEF  VAR aux_clencfin2 AS CHAR                                  NO-UNDO.
    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "INADIMPLEMENTO" aux_chrhifen FORMAT "X(01)" "Sobre o montante da quantia devida e nao paga, incidirao, alem dos encargos"
         "financeiros remuneratorios especificados no item" par_clencfin ", juros de mora ambos incidentes da data de"
         "vencimento ate a data do efetivo pagamento e multa sobre o montante vencido e nao pago, tudo conforme"
         "especificado no item" aux_clencfin2 ", alem dos impostos que incidam ou venham a incidir sobre a operacao"
         "contratada."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_inadimplemento.
             
    ASSIGN aux_clencfin2 = par_clencfin
           aux_chrhifen  = CHR(45).

    DISPLAY STREAM str_1 par_dsnrclau
                         aux_chrhifen
                         par_clencfin   FORMAT "X(06)"
                         aux_clencfin2  FORMAT "X(06)"
                         WITH FRAME f_insere_clausula_condicoes_gerais_inadimplemento.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-condicao-especial:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(4)"
         "CONDICAO ESPECIAL" aux_chrhifen FORMAT "X(01)" "O presente contrato reveste-se da condicao de titulo executivo"
         "extrajudicial, nos termos do artigo 585, II, do Codigo de Processo Civil, reconhecendo as partes,"
         "desde ja, a sua liquidez, certeza e exigibilidade."
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_condicao_especial.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_condicao_especial.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-subclausula1-condicoes-gerais-condicao-especial:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau     FORMAT "X(6)"
         "A eventual tolerancia por parte da COOPERATIVA, em exigir o cumprimento do presente"
         "contrato, nao acarretara no cancelamento das penalidades previstas, as quais poderao ser aplicadas"
         "e exigidas a qualquer tempo, ainda que a tolerancia ou a nao aplicacao das cominacoes ocorram"
         "repetidas vezes, consecutivas ou alternadamente, o que nao implicara em precedentes, renovacao ou"
         "modificacao de quaisquer das disposicoes deste contrato, as quais permanecerao integras e em pleno"
         "vigor."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_subclausula1_condicoes_gerais_condicao_especial.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_subclausula1_condicoes_gerais_condicao_especial.
    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-despesas:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(5)"
         "DESPESAS" aux_chrhifen FORMAT "X(01)" "Todas as despesas decorrentes do presente contrato, inclusive impostos, seguros,"
         "registros, arquivamentos e formalizacoes, deverao ser custeadas pelo(a) COOPERADO(A)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_despesas.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_despesas.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-efeitos-contrato:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(5)"
         "EFEITOS DO CONTRATO" aux_chrhifen FORMAT "X(01)" "Este contrato obriga a COOPERATIVA, o(a) COOPERADO(A) e o(s)"
         "FIADOR(ES), ao fiel cumprimento das clausulas e condicoes nele estabelecidas, sendo celebrado em"
         "carater irrevogavel e irretratavel, obrigando tambem, seus herdeiros, cessionarios e sucessores, a"
         "qualquer titulo, permitindo-se a cessao do credito pela COOPERATIVA, desde que notificada ao(a)"
         "COOPERADO(A) e ao(s) FIADOR(ES)."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_efeitos_contrato.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_efeitos_contrato.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-liberacao-inf-bc:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(5)"
         "LIBERACAO DE INFORMACOES AO BANCO CENTRAL DO BRASIL E DEMAIS AUTORIZACOES PARA CONSULTAS" aux_chrhifen FORMAT "X(01)"
         "O(A) COOPERADO(A) e o(s) FIADOR(ES) autorizam desde ja a COOPERATIVA a transmitir ao Banco"
         "Central do Brasil, informacoes inerentes as operacoes do presente contrato, com intuito de alimentar"
         "o Sistema de Informacoes de Credito do Banco Central do Brasil - SCR daquela instituicao, sendo"
         "passivel de acesso por outras instituicoes financeiras, bem como autorizam a consulta das"
         "informacoes constantes no referido cadastro, e nos Servicos de Protecao ao Credito"
         "(SPC, SERASA etc), responsabilizando-se sob as penas da Lei, pela exatidao das informacoes"
         "prestadas."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_liberacao_inf_bc.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_liberacao_inf_bc.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-vinculo-cooperativo:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(5)"
         "VINCULO COOPERATIVO" aux_chrhifen FORMAT "X(01)" "As partes declaram que o presente contrato esta tambem vinculado"
         "as disposicoes legais que regulam o cooperativismo, o Estatuto Social da COOPERATIVA, as" 
         "deliberacoes assembleares desta e as do seu Conselho de Administracao, aos quais o(a) COOPERADO(A)"
         "livre e espontaneamente aderiu ao integrar o quadro social da COOPERATIVA e cujo teor as partes"
         "ratificam, reconhecendo nesta operacao a celebracao de um ATO COOPERATIVO."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_vinculo_cooperativo.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_vinculo_cooperativo.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-ouvidoria:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(5)"
         "OUVIDORIA" aux_chrhifen FORMAT "X(01)" "A COOPERATIVA dispoe de um canal de ouvidoria para atender o(a) COOPERADO(A) pelo"
         crapcop.nrtelouv FORMAT "x(12)"
         SPACE(0)
         ", em dias uteis das 08h00min as 17h00min."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_ouvidoria.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              crapcop.nrtelouv
                              WITH FRAME f_insere_clausula_condicoes_gerais_ouvidoria.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-condicoes-gerais-foro:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    DEF  VAR aux_chrhifen  AS CHAR                                  NO-UNDO.
    
    FORM par_dsnrclau      FORMAT "X(5)"
         "FORO" aux_chrhifen FORMAT "X(01)" "As partes, de comum acordo, elegem o foro da Comarca do domicilio do(a) COOPERADO(A),"
         "com exclusao de qualquer outro, por mais privilegiado que seja, para dirimir quaisquer questoes"
         "resultantes do presente contrato."
         SKIP(1)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_condicoes_gerais_foro.

         ASSIGN aux_chrhifen = CHR(45).

         DISPLAY STREAM str_1 par_dsnrclau
                              aux_chrhifen
                              WITH FRAME f_insere_clausula_condicoes_gerais_foro.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-termo-assinatura-alienacao:

    DEF  INPUT PARAM par_dsnrclau AS CHAR                           NO-UNDO.

    FORM par_dsnrclau      FORMAT "X(5)"
         "E assim, por se acharem justos e contratados, assinam o presente contrato em 02 (duas)"
         "vias de igual teor e forma, na presenca de 02 (duas) testemunhas abaixo, que, estando cientes,"
         "tambem assinam, para que produza os devidos e legais efeitos."
         SKIP(2)
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_termo_assinatura_alienacao.

         DISPLAY STREAM str_1 par_dsnrclau
                              WITH FRAME f_insere_clausula_termo_assinatura_alienacao.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-declaracao:

    DEF  VAR aux_nrcpfcgc  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_nmprimtl  AS CHAR                                  NO-UNDO.
    DEF  VAR aux_nmcidade  LIKE crapenc.nmcidade                    NO-UNDO.

    FORM "DECLARACAO" AT 44 SKIP (4)    
         "O cooperado(a) " crapass.nmprimtl ", sob" SKIP 
         "matricula nro" crapass.nrmatric "na" crapcop.nmextcop SKIP 
         "na pretensao de contratar operacao de microcredito e na forma da" 
         "legislacao em" AT 66 SKIP 
         "vigor, declara que:" SKIP(2)
         "a) No caso de realizar operacoes de microcredito na forma do art. 2," 
         AT 4 "inciso" AT 73  SKIP
         "I, letra c, da Resolucao nro 4.000/2011, do Banco Central do" AT 7
         "Brasil, nao" SKIP          
         "possui outras operacoes desta especie em curso, bem como nao" AT 7
         "detem saldo" SKIP
         "medio mensal em conta deposito que, em conjunto com as" AT 7
         "demais aplicacoes," SKIP
         "superem a R$ 3.000,00 (TRES MIL REAIS)."
         AT 07 SKIP(2)
         "b) No caso de realizar operacoes de microcredito na forma do art. 2," 
         AT 4 "inciso" AT 73 SKIP
         "III, da Resolucao nro 4.000/2011, do Banco Central do Brasil," AT 7
         "nao possui" SKIP 
         "outras operacoes desta especie em curso, bem como o somatorio da" AT 7
         SKIP
         "operacao de microcredito pretendida e o saldo de suas outras operacoes de" AT 7
         SKIP
         "credito em curso, excetuadas as operacoes de credito habitacional, nao" AT 7
         SKIP
         "ultrapassa R$ 40.000,00 (QUARENTA MIL REAIS)."
         AT 07 SKIP(1)
         aux_nmcidade  
         SPACE(0)
         ",_________________________________________________."
         SKIP(2)
         "--------------------------------------------------" 
         SKIP
         "Nome:" aux_nmprimtl     FORMAT "x(50)"
         SKIP
         "CPF:"  aux_nrcpfcgc     FORMAT "x(18)"
         SKIP
         "C/C:"  crapass.nrdconta FORMAT "9999,999,9"
         WITH NO-BOX COLUMN 2 NO-LABELS WIDTH 101 FRAME f_insere_clausula_declaracao.

         /*** Impressao da declaracao de microcredito ***/
         IF  craplcr.cdusolcr = 1 AND craplcr.flgimpde  THEN
             DO:
                ASSIGN aux_nmprimtl = crapass.nmprimtl.

                IF  crapass.inpessoa = 1 THEN
                    ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"    xxx.xxx.xxx-xx").
                ELSE
                    ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").

                FIND crapage WHERE crapage.cdcooper = crapass.cdcooper  AND
                                   crapage.cdagenci = crapass.cdagenci  NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapage   THEN
                    ASSIGN aux_nmcidade = "____________________________".
                ELSE
                    DO:
                        ASSIGN aux_nmcidade = crapage.nmcidade
                               aux_nmcidade = FILL(" ", 25 - LENGTH(aux_nmcidade)) + aux_nmcidade.
                    END.
                    
                PAGE STREAM str_1.
                DISPLAY STREAM str_1 crapcop.nmextcop crapass.nmprimtl crapass.nrmatric
                                     aux_nmcidade     crapass.nrdconta aux_nmprimtl
                                     aux_nrcpfcgc     WITH FRAME f_insere_clausula_declaracao.
             END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE insere-clausula-carta-consignacao:

    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF VAR aux_dsdcoop1 AS CHAR    FORMAT "x(80)"                   NO-UNDO.
    DEF VAR aux_dsdcoop2 AS CHAR    FORMAT "x(80)"                   NO-UNDO.
    DEF VAR aux_dsdcoop3 AS CHAR    FORMAT "x(80)"                   NO-UNDO.
    DEF VAR aux_dsdaemp1 AS CHAR    FORMAT "x(80)"                   NO-UNDO.
    DEF VAR aux_dsdaemp2 AS CHAR    FORMAT "x(91)"                   NO-UNDO. 
    DEF VAR aux_dsdaemp3 AS CHAR    FORMAT "x(80)"                   NO-UNDO.
    DEF VAR aux_dsassoci AS CHAR    FORMAT "x(44)"                   NO-UNDO.
    DEF VAR aux_dsciddat AS CHAR    FORMAT "x(80)"                   NO-UNDO.
    DEF VAR aux_nmassptl AS CHAR    FORMAT "x(44)"                   NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                     NO-UNDO.

    DEF VAR aux_qtpreemp AS CHAR                                     NO-UNDO.
    DEF VAR aux_vlpreemp AS CHAR                                     NO-UNDO.
    DEF VAR aux_nrctremp AS CHAR                                     NO-UNDO.

    FORM aux_dsdcoop1 SKIP
         aux_dsdcoop2 SKIP
         aux_dsdcoop3 SKIP(2)
         aux_dsdaemp1 SKIP     
         aux_dsdaemp2 SKIP
         aux_dsdaemp3 SKIP(4)
         "AUTORIZACAO DE CONSIGNACAO EM FOLHA DE PAGAMENTO" AT 15 SKIP(4)
         aux_dsassoci " venho, pela presente, com base na" SKIP
         "legislacao vigente, especialmente a Lei N.o. 10.820, de 17 de "
         "Dezembro de 2003," SKIP
         "autorizar expressamente, de forma irrevogavel e irretratavel, "
         "enquanto perdurar" SKIP
         "o financiamento e/ou o emprego, a consignacao e desconto  em folha de"
         "pagamento" SKIP
         "de meu salario junto a empresa" crapemp.nmresemp
         "         , inclusive das verbas" SKIP
         "rescisorias, das parcelas inerentes ao  emprestimo pessoal de"
         "Numero" aux_nrctremp FORMAT "x(08)" "," SKIP
         "formalizado  em" crawepr.dtmvtolt
         ", em um total de" aux_qtpreemp FORMAT "x(03)" "parcelas  "
         "ainda nao liquidadas," SKIP 
         "no valor de R$" aux_vlpreemp   FORMAT "x(14)"
         "cada parcela."     SKIP(2)
         aux_dsciddat SKIP(5)
         "Ciente: ___/___/______" SKIP(5)
         "__________________________________________________" AT  1
         crapass.nmprimtl  AT 1      SKIP
         "CPF:" AT 1 aux_nrcpfcgc FORMAT "x(18)" SKIP(5)
          "\033\106"
         WITH WIDTH 132 NO-LABEL NO-BOX ROW 3 FRAME frAutorizacao.

    IF  crapass.inpessoa = 1   THEN
        DO:
            FIND crapttl WHERE crapttl.cdcooper = crapcop.cdcooper AND
                               crapttl.nrdconta = crapass.nrdconta AND
                               crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
    
            IF  AVAIL crapttl  THEN
                ASSIGN aux_cdempres = crapttl.cdempres.
        END.
    ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = crapcop.cdcooper AND
                               crapjur.nrdconta = crapass.nrdconta
                               NO-LOCK NO-ERROR.
    
            IF   AVAIL crapjur  THEN
                 ASSIGN aux_cdempres = crapjur.cdempres.
        END.

    IF   crapass.inpessoa = 1 THEN
        ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
               aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
   ELSE
        ASSIGN aux_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
    
    FIND crapemp WHERE crapemp.cdcooper = crapcop.cdcooper  AND
                       crapemp.cdempres = aux_cdempres      NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapemp   THEN
         RETURN.
                                                     
    ASSIGN aux_qtpreemp = TRIM(STRING(crawepr.qtpreemp,"zz9"))
           aux_vlpreemp = TRIM(STRING(crawepr.vlpreemp,"zzz,zzz,zz9.99"))
           aux_nrctremp = TRIM(STRING(crawepr.nrctremp,"zz,zzz,zz9")).

    ASSIGN aux_dsdcoop1 = TRIM(crapcop.nmextcop) + " - " + 
                          TRIM(crapcop.nmrescop) 
           aux_dsdcoop2 = TRIM(crapcop.dsendcop) + ", " + 
                          STRING(crapcop.nrendcop) +
                          " - " + TRIM(crapcop.nmbairro)
           aux_dsdcoop3 = STRING(crapcop.nrcepend, "99999999")
           aux_dsdcoop3 = TRIM(crapcop.nmcidade) + "/" + crapcop.cdufdcop +
                          "      CEP:" + STRING(aux_dsdcoop3, "xx.xxx-xxx") 
           aux_dsdaemp1 = crapemp.nmextemp      
           aux_dsdaemp2 = TRIM(crapemp.dsendemp) + ", " + 
                          STRING(crapemp.nrendemp) +
                          " - " + TRIM(crapemp.nmbairro)
           aux_dsdaemp3 = STRING(crapemp.nrcepend, "99999999")
           aux_dsdaemp3 = TRIM(crapemp.nmcidade) + "/" + crapemp.cdufdemp +  
                          "      CEP:" +  STRING(aux_dsdaemp3, "xx.xxx-xxx")
           aux_dsassoci = "Eu, " + STRING(crapass.nmprimtl, "x(50)") 
           aux_dsciddat = TRIM(crapcop.nmcidade) + ", " + 
                          STRING(par_dtmvtolt, "99/99/9999")
           aux_nmassptl = crapass.nmprimtl.
    
    PAGE STREAM str_1.
    DISPLAY STREAM str_1     aux_dsassoci     aux_dsciddat
            aux_dsdcoop1     aux_dsdcoop2     aux_dsdcoop3
            aux_dsdaemp1     aux_dsdaemp2     aux_dsdaemp3
            aux_qtpreemp     aux_vlpreemp     aux_nrctremp
            crapass.nmprimtl crapemp.nmresemp crawepr.nrctremp
            crawepr.dtmvtolt crawepr.qtpreemp crawepr.vlpreemp
            crapass.nmprimtl aux_nrcpfcgc                       
            WITH FRAME frAutorizacao.

    PAGE STREAM str_1.
    DISPLAY STREAM str_1     aux_dsassoci     aux_dsciddat
            aux_dsdcoop1     aux_dsdcoop2     aux_dsdcoop3
            aux_dsdaemp1     aux_dsdaemp2     aux_dsdaemp3
            aux_qtpreemp     aux_vlpreemp     aux_nrctremp
            crapass.nmprimtl crapemp.nmresemp crawepr.nrctremp
            crawepr.dtmvtolt crawepr.qtpreemp crawepr.vlpreemp
            crapass.nmprimtl aux_nrcpfcgc                         
            WITH FRAME frAutorizacao.
    
    RETURN "OK".

END PROCEDURE.
    
PROCEDURE imprime_cet:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpemprst AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtlibera AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-dtultpag AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-vlpreemp AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-qtpreemp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtdpagto AS DATE                                 NO-UNDO.
    
    DEF OUTPUT PARAM par_nmdoarqv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_imprime_emprestimos_cet 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio  */
                          INPUT p-tpemprst, /* Tipo da operacao */
                          INPUT p-nrctremp, /* Contrato         */
                          INPUT p-dtlibera, /* Data liberacao   */
                          INPUT p-dtultpag, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/craplrt.txmensal */
                          INPUT p-vlpreemp, /* valor parcela    */
                          INPUT p-qtpreemp, /* prestacoes       */
                          INPUT p-dtdpagto, /* data pagamento   */
                         OUTPUT "",
                         OUTPUT "", 
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_imprime_emprestimos_cet 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdoarqv = ""
           par_nmdoarqv = pc_imprime_emprestimos_cet.pr_nmarqimp
                          WHEN pc_imprime_emprestimos_cet.pr_nmarqimp <> ? 
           aux_cdcritic = pc_imprime_emprestimos_cet.pr_cdcritic 
                          WHEN pc_imprime_emprestimos_cet.pr_cdcritic <> ?
           aux_dscritic = pc_imprime_emprestimos_cet.pr_dscritic 
                          WHEN pc_imprime_emprestimos_cet.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE imprime-scr-consultas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtipcon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctacon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcon AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_iddoaval AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.                                                                                            

    
    DEF  VAR aux_nmarquiv AS CHAR                                   NO-UNDO.
    DEF  VAR aux_dsdlinha AS CHAR                                   NO-UNDO. 
    DEF  VAR h-b1wgen0191 AS HANDLE                                 NO-UNDO.

    

    RUN sistema/generico/procedures/b1wgen0191.p
        PERSISTENT SET h-b1wgen0191.

    RUN Imprime_Dados_Proposta IN h-b1wgen0191 (INPUT par_cdcooper, 
                                                INPUT par_cdoperad,
                                                INPUT par_nmdatela,
                                                INPUT par_idorigem,
                                                INPUT par_dtmvtolt,
                                                INPUT par_nrdconta,
                                                INPUT 1, /* inprodut */
                                                INPUT par_nrctrato,
                                                INPUT par_cdtipcon,
                                                INPUT par_nrctacon,
                                                INPUT par_nrcpfcon,
                                                INPUT par_iddoaval,
                                               OUTPUT aux_nmarquiv,
                                               OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0191.

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /* Importar o arquivo gerado e jogar no da proposta  */
    INPUT STREAM str_2 FROM VALUE (aux_nmarquiv) NO-ECHO.
                     
    /* Ler linha a linha e imprimir na proposta */
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IMPORT STREAM str_2 UNFORMATTED aux_dsdlinha.

        PUT STREAM str_1 aux_dsdlinha FORMAT "x(137)" SKIP.

    END.

    INPUT STREAM str_2 CLOSE.
                                                           
    RETURN "OK".

END PROCEDURE.

/*********************************************************************************************************************************************
**********************************************************************************************************************************************
                                                                FINAL  DA BO2i
**********************************************************************************************************************************************
**********************************************************************************************************************************************/
